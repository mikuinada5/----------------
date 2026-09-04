Import-Module (Join-Path $PSScriptRoot '../src/ExternalApproval.psm1') -Force
Import-Module (Join-Path $PSScriptRoot '../src/ExternalAudit.psm1') -Force

function New-SignedFixture($statement, $key) {
    $bytes = [Text.Encoding]::UTF8.GetBytes(($statement | ConvertTo-Json -Depth 10 -Compress))
    @{
        statement_base64 = [Convert]::ToBase64String($bytes)
        signature_base64 = [Convert]::ToBase64String($key.SignData($bytes, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pss))
    }
}
function Test-Blocked([scriptblock]$Action) {
    try { & $Action | Out-Null; return $false } catch { return $_.Exception.Message.Contains('BLOCKED_APPROVAL_RUNTIME') }
}

Describe 'External Approval Gate: offline authenticated-evidence contract' {
    BeforeEach {
        # Ephemeral synthetic authority; never installed or used by live transport.
        $signer = [Security.Cryptography.RSA]::Create(2048)
        $bytes = [Text.Encoding]::UTF8.GetBytes('SYNTHETIC complete serialized provider request')
        $request = @{
            request_id = 'synthetic-request-1'; payload_sha256 = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
            destination = 'https://api.anthropic.com/v1/messages'; purpose = 'synthetic offline audit'
            requested_at = '2026-09-04T00:00:00Z'; waiting_at = '2026-09-04T00:00:01Z'
        }
        $statement = @{
            schema_version = 'human-approval/v1'; request_id = $request.request_id; event_id = 'synthetic-human-event-1'
            actor = 'human'; decision = 'APPROVE'; payload_sha256 = $request.payload_sha256
            destination = $request.destination; purpose = $request.purpose
            requested_at = $request.requested_at; received_at = '2026-09-04T00:00:02Z'
        }
        $argsGate = @{
            Request = $request; Envelope = (New-SignedFixture $statement $signer); PayloadBytes = $bytes
            Destination = $request.destination; Purpose = $request.purpose
            TrustedPublicKeyPem = $signer.ExportSubjectPublicKeyInfoPem(); CheckedAt = [DateTimeOffset]'2026-09-04T00:00:03Z'
        }
    }
    AfterEach { $signer.Dispose() }
    It 'A: displayed question alone stays WAITING_FOR_HUMAN and cannot invoke' {
        $argsGate.Envelope = $null
        $r = Test-ExternalApprovalEvidence @argsGate
        $r.state | Should Be 'WAITING_FOR_HUMAN'
        $r.evidence_result | Should Be 'FAIL'
        $r.external_invocation_allowed | Should Be $false
    }
    It 'B: repeated retry before the response remains blocked' {
        $argsGate.Envelope = $null
        1..3 | ForEach-Object { (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL' }
        $argsGate.Envelope = New-SignedFixture $statement $signer
        $argsGate.CheckedAt = [DateTimeOffset]'2026-09-04T00:00:01.500Z'
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
    }
    It 'C: agent approved assertion is not Human evidence' {
        $argsGate.Envelope = @{approved=$true; approval_ref='Human approved'; actor='human'}
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
        (Test-Blocked { Assert-ExternalAuditSharingApproval -Manifest @{external_sharing=@{approved=$true; approval_ref='Human approved'}} }) | Should Be $true
    }
    It 'D: approval after invocation is INCIDENT and can never retroactively pass' {
        $r = Test-ExternalApprovalEvidence @argsGate -InvocationStartedAt ([DateTimeOffset]'2026-09-04T00:00:01.900Z')
        $r.state | Should Be 'INCIDENT'
        $r.evidence_result | Should Be 'FAIL'
        (Test-ExternalApprovalEvidence @argsGate -PriorIncident).state | Should Be 'INCIDENT'
    }
    It 'E: mismatched payload, destination, purpose or request fails' {
        foreach ($field in @('payload_sha256','destination','purpose','request_id','requested_at')) {
            $changed = $statement.Clone()
            $changed[$field] = switch ($field) { 'payload_sha256' { '0' * 64 } 'destination' { 'https://example.invalid/' } 'requested_at' { '2026-09-03T00:00:00Z' } default { 'different' } }
            $argsGate.Envelope = New-SignedFixture $changed $signer
            (Test-ExternalApprovalEvidence @argsGate).reason | Should Be 'APPROVAL_SCOPE_MISMATCH'
        }
    }
    It 'F: authentic fixture for identical request can PASS offline after Human response' {
        $r = Test-ExternalApprovalEvidence @argsGate
        $r.state | Should Be 'APPROVAL_GRANTED'
        $r.evidence_result | Should Be 'PASS'
        $r.external_invocation_allowed | Should Be $false
        (Test-Blocked { Assert-ExternalAuditRuntimeApproval }) | Should Be $true
    }
    It 'rejects an attacker signature despite claiming actor human' {
        $attacker = [Security.Cryptography.RSA]::Create(2048)
        try { $argsGate.Envelope = New-SignedFixture $statement $attacker } finally { $attacker.Dispose() }
        (Test-ExternalApprovalEvidence @argsGate).reason | Should Be 'INVALID_HUMAN_EVIDENCE_SIGNATURE'
    }
    It 'rejects signed agent assertion, denial and missing trusted ingress' {
        $statement.actor = 'agent'; $argsGate.Envelope = New-SignedFixture $statement $signer
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
        $statement.actor = 'human'; $statement.decision = 'REJECT'; $argsGate.Envelope = New-SignedFixture $statement $signer
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
        $argsGate.TrustedPublicKeyPem = ''
        (Test-ExternalApprovalEvidence @argsGate).reason | Should Be 'TRUSTED_INGRESS_UNAVAILABLE'
    }
    It 'changed actual request bytes invalidate the grant' {
        $argsGate.PayloadBytes = [Text.Encoding]::UTF8.GetBytes('different provider request or system prompt')
        (Test-ExternalApprovalEvidence @argsGate).reason | Should Be 'APPROVAL_SCOPE_MISMATCH'
    }
    It 'schema rejects missing event identity and unknown approval fields' {
        $statement.Remove('event_id'); $argsGate.Envelope = New-SignedFixture $statement $signer
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
        $statement.event_id='event'; $statement.approved=$true; $argsGate.Envelope=New-SignedFixture $statement $signer
        (Test-ExternalApprovalEvidence @argsGate).evidence_result | Should Be 'FAIL'
    }
    It 'records invalid or absent evidence as INCIDENT when invocation already started' {
        $argsGate.Envelope = $null
        (Test-ExternalApprovalEvidence @argsGate -InvocationStartedAt ([DateTimeOffset]'2026-09-04T00:00:01.500Z')).state | Should Be 'INCIDENT'
    }
    It 'direct provider dispatch and both leaf adapters fail before HTTP' {
        # Sentinel rejects unexpected network calls; no credentials are read.
        $m = Get-Module ExternalAudit
        & $m {
            function Invoke-RestMethod { throw 'UNEXPECTED_NETWORK_SENTINEL' }
            foreach ($provider in @('anthropic','gemini')) {
                $caught = ''
                try { Invoke-ExternalAuditProvider -Provider $provider -ApiKey 'synthetic' -Model 'synthetic' -SystemPrompt 'synthetic' -AuditInputJson '{}' } catch { $caught=$_.Exception.Message }
                $caught.StartsWith('BLOCKED_APPROVAL_RUNTIME') | Should Be $true
            }
            foreach ($leaf in @('Invoke-AnthropicExternalAudit','Invoke-GeminiExternalAudit')) {
                $caught = ''
                try { & $leaf -ApiKey 'synthetic' -Model 'synthetic' -SystemPrompt 'synthetic' -AuditInputJson '{}' } catch { $caught=$_.Exception.Message }
                $caught.StartsWith('BLOCKED_APPROVAL_RUNTIME') | Should Be $true
            }
        }
    }
    It 'CLI blocks even with ConfirmExternalSend before reading nonexistent manifest' {
        $output = & (Get-Command pwsh).Source -NoProfile -File (Join-Path $PSScriptRoot '../scripts/Invoke-ExternalAudit.ps1') -ManifestPath 'nonexistent.json' -OutputPath 'nonexistent-output.json' -ConfirmExternalSend 2>&1
        $LASTEXITCODE | Should Be 1
        ($output -join '').Contains('BLOCKED_APPROVAL_RUNTIME') | Should Be $true
    }
}
