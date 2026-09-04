Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Offline evidence verifier only. A caller-supplied public key is NOT a production
# trust anchor. No result of this module is a capability to execute a tool.
function Test-ExternalApprovalEvidence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Request,
        [AllowNull()][System.Collections.IDictionary]$Envelope,
        [Parameter(Mandatory)][byte[]]$PayloadBytes,
        [Parameter(Mandatory)][string]$Destination,
        [Parameter(Mandatory)][string]$Purpose,
        [string]$TrustedPublicKeyPem,
        [Parameter(Mandatory)][DateTimeOffset]$CheckedAt,
        [Nullable[DateTimeOffset]]$InvocationStartedAt,
        [switch]$PriorIncident
    )
    $result = [ordered]@{
        state = 'APPROVAL_REQUIRED'; evidence_result = 'FAIL'; reason = 'APPROVAL_REQUIRED'
        control_scope = 'offline-evidence-verification-only'; external_invocation_allowed = $false
        platform_enforced = $false
    }
    if ($PriorIncident) { $result.state = 'INCIDENT'; $result.reason = 'PRIOR_INCIDENT_NO_RETROACTIVE_PASS'; return $result }
    try {
        foreach ($key in @('request_id','payload_sha256','destination','purpose','requested_at','waiting_at')) {
            if (-not $Request.Contains($key) -or [string]::IsNullOrWhiteSpace([string]$Request[$key])) { throw 'INCOMPLETE_REQUEST' }
        }
        $result.state = 'APPROVAL_REQUESTED'
        $requested = [DateTimeOffset]::Parse($Request.requested_at)
        $waiting = [DateTimeOffset]::Parse($Request.waiting_at)
        if ($waiting -lt $requested -or $CheckedAt -lt $waiting) { throw 'INVALID_REQUEST_ORDER' }
        $result.state = 'WAITING_FOR_HUMAN'
        if ($null -eq $Envelope) { throw 'HUMAN_EVIDENCE_MISSING' }
        if ([string]::IsNullOrWhiteSpace($TrustedPublicKeyPem)) { throw 'TRUSTED_INGRESS_UNAVAILABLE' }
        if ($Envelope.Count -ne 2 -or -not $Envelope.Contains('statement_base64') -or -not $Envelope.Contains('signature_base64')) { throw 'UNAUTHENTICATED_AGENT_ASSERTION' }
        $statement = [Convert]::FromBase64String($Envelope.statement_base64)
        $signature = [Convert]::FromBase64String($Envelope.signature_base64)
        $rsa = [Security.Cryptography.RSA]::Create()
        try {
            $rsa.ImportFromPem($TrustedPublicKeyPem)
            if (-not $rsa.VerifyData($statement, $signature, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pss)) { throw 'INVALID_HUMAN_EVIDENCE_SIGNATURE' }
        } finally { $rsa.Dispose() }
        $json = [Text.UTF8Encoding]::new($false, $true).GetString($statement)
        if (-not (Test-Json -Json $json -SchemaFile (Join-Path $PSScriptRoot '../schemas/human_approval.schema.json') -ErrorAction Stop)) { throw 'APPROVAL_SCHEMA_FAIL' }
        # Read JSON date strings without PowerShell's automatic DateTime coercion.
        # Windows local timezone must not shift the authenticated UTC event time.
        $document = [Text.Json.JsonDocument]::Parse($json)
        try {
            $evidence = @{}
            foreach ($property in $document.RootElement.EnumerateObject()) { $evidence[$property.Name] = $property.Value.GetString() }
        } finally { $document.Dispose() }
        $received = [DateTimeOffset]::Parse($evidence.received_at)
        if ($received -le $waiting -or $received -gt $CheckedAt) { throw 'HUMAN_RESPONSE_NOT_AVAILABLE_BEFORE_CHECK' }
        if ($null -ne $InvocationStartedAt -and $received -ge $InvocationStartedAt) { throw 'LATE_APPROVAL' }
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($PayloadBytes)).ToLowerInvariant()
        if ($Request.payload_sha256 -cne $hash -or $evidence.payload_sha256 -cne $hash -or
            $Request.destination -cne $Destination -or $evidence.destination -cne $Destination -or
            $Request.purpose -cne $Purpose -or $evidence.purpose -cne $Purpose -or
            $evidence.request_id -cne $Request.request_id -or $evidence.requested_at -cne $Request.requested_at) { throw 'APPROVAL_SCOPE_MISMATCH' }
        if ($evidence.decision -cne 'APPROVE' -or $evidence.actor -cne 'human') { throw 'EXPLICIT_HUMAN_APPROVAL_REQUIRED' }
        $result.state = 'APPROVAL_GRANTED'; $result.evidence_result = 'PASS'; $result.reason = 'AUTHENTICATED_BOUND_EVIDENCE'
        return $result
    } catch {
        # Do not echo input, signatures, key material or parser diagnostics.
        $codes = @('INCOMPLETE_REQUEST','INVALID_REQUEST_ORDER','HUMAN_EVIDENCE_MISSING','TRUSTED_INGRESS_UNAVAILABLE','UNAUTHENTICATED_AGENT_ASSERTION','INVALID_HUMAN_EVIDENCE_SIGNATURE','APPROVAL_SCHEMA_FAIL','HUMAN_RESPONSE_NOT_AVAILABLE_BEFORE_CHECK','LATE_APPROVAL','APPROVAL_SCOPE_MISMATCH','EXPLICIT_HUMAN_APPROVAL_REQUIRED')
        $result.reason = if ($_.Exception.Message -cin $codes) { $_.Exception.Message } else { 'INVALID_APPROVAL_EVIDENCE' }
        if ($null -ne $InvocationStartedAt) { $result.state = 'INCIDENT' }
        return $result
    }
}

function Assert-ExternalAuditRuntimeApproval {
    # No authenticated Human-event ingress / protected trust anchor is installed.
    # Do not add an approved boolean, arbitrary log path, callback, environment
    # variable or caller-selected signer as a bypass. All live entry points stop.
    throw 'BLOCKED_APPROVAL_RUNTIME: trusted Human evidence ingress is not installed; external invocation disabled.'
}

Export-ModuleMember -Function Test-ExternalApprovalEvidence, Assert-ExternalAuditRuntimeApproval
