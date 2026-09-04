[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ManifestPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [ValidateSet('anthropic','gemini')][string]$Provider = 'anthropic',
    [string]$Model,
    [string]$RoutingOutputPath,
    [string]$RepositoryRoot,
    [string]$PromptPath,
    [string]$RequestSchemaPath,
    [string]$InputSchemaPath,
    [string]$ResponseSchemaPath,
    [ValidateRange(10, 600)][int]$TimeoutSeconds = 120,
    [ValidateRange(0, 6)][int]$RetryCount = 2,
    [ValidateRange(512, 32000)][int]$MaxOutputTokens = 12000,
    [ValidateSet('default','disabled')][string]$AnthropicThinkingMode = 'disabled',
    [ValidateSet('after_major','after_any_revision','never')][string]$ReauditPolicy = 'after_major',
    [switch]$PrepareOnly,
    [switch]$ConfirmExternalSend
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pipelineRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = [IO.Path]::GetFullPath((Join-Path $pipelineRoot '..\..'))
}
if ([string]::IsNullOrWhiteSpace($PromptPath)) {
    $PromptPath = Join-Path $pipelineRoot 'prompts\external_audit_prompt.md'
}
if ([string]::IsNullOrWhiteSpace($InputSchemaPath)) {
    $InputSchemaPath = Join-Path $pipelineRoot 'schemas\audit_input.schema.json'
}
if ([string]::IsNullOrWhiteSpace($RequestSchemaPath)) {
    $RequestSchemaPath = Join-Path $pipelineRoot 'schemas\audit_request.schema.json'
}
if ([string]::IsNullOrWhiteSpace($ResponseSchemaPath)) {
    $ResponseSchemaPath = Join-Path $pipelineRoot 'schemas\audit_response.schema.json'
}

Import-Module (Join-Path $pipelineRoot 'src\ExternalAudit.psm1') -Force

try {
    # Stop before manifest processing or credential access. PrepareOnly stays local.
    if (-not $PrepareOnly) { throw 'BLOCKED_APPROVAL_RUNTIME: live external audits are disabled pending trusted Human evidence ingress.' }
    $manifest = Read-ExternalAuditJsonFile -Path $ManifestPath
    $auditInput = New-ExternalAuditInput `
        -ManifestPath $ManifestPath `
        -RepositoryRoot $RepositoryRoot `
        -RequestSchemaPath $RequestSchemaPath `
        -InputSchemaPath $InputSchemaPath
    $systemPrompt = Get-Content -Raw -Encoding UTF8 -LiteralPath $PromptPath
    $auditInputJson = $auditInput | ConvertTo-Json -Depth 100

    if ($PrepareOnly) {
        $package = [ordered]@{
            package_type = 'external_audit_prepare_only'
            provider = $Provider
            model = $Model
            input_sha256 = Get-ExternalAuditSha256 -Text $auditInputJson
            system_prompt = $systemPrompt
            audit_input = $auditInput
        }
        Write-ExternalAuditJsonFile -Value $package -Path $OutputPath
        [ordered]@{
            status = 'PREPARED_NOT_SENT'
            output_path = [IO.Path]::GetFullPath($OutputPath)
            input_sha256 = $package.input_sha256
        } | ConvertTo-Json -Compress
        exit 0
    }

    if (-not $ConfirmExternalSend) {
        throw 'Real API execution requires -ConfirmExternalSend.'
    }
    Assert-ExternalAuditSharingApproval -Manifest $manifest
    if ([string]::IsNullOrWhiteSpace($Model)) {
        throw 'Real API execution requires an explicit -Model.'
    }

    $keyName = switch ($Provider) {
        'anthropic' { 'ANTHROPIC_API_KEY' }
        'gemini' { 'GEMINI_API_KEY' }
    }
    $apiKey = [Environment]::GetEnvironmentVariable($keyName, 'Process')
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        $apiKey = [Environment]::GetEnvironmentVariable($keyName, 'User')
    }
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        $apiKey = [Environment]::GetEnvironmentVariable($keyName, 'Machine')
    }
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "Required environment variable is not set: $keyName"
    }

    $providerResponse = Invoke-ExternalAuditProvider `
        -Provider $Provider `
        -ApiKey $apiKey `
        -Model $Model `
        -SystemPrompt $systemPrompt `
        -AuditInputJson $auditInputJson `
        -TimeoutSeconds $TimeoutSeconds `
        -RetryCount $RetryCount `
        -MaxOutputTokens $MaxOutputTokens `
        -AnthropicThinkingMode $AnthropicThinkingMode
    $apiKey = $null

    $auditResult = ConvertFrom-ExternalAuditModelResponse `
        -Text $providerResponse.text `
        -ResponseSchemaPath $ResponseSchemaPath
    $routing = Get-ExternalAuditRouting -AuditResult $auditResult -ReauditPolicy $ReauditPolicy

    if ([string]::IsNullOrWhiteSpace($RoutingOutputPath)) {
        $outputFull = [IO.Path]::GetFullPath($OutputPath)
        $RoutingOutputPath = Join-Path (Split-Path -Parent $outputFull) (([IO.Path]::GetFileNameWithoutExtension($outputFull)) + '.routing.json')
    }
    Write-ExternalAuditJsonFile -Value $auditResult -Path $OutputPath
    $routingRecord = [ordered]@{
        audit_id = "ext-$([Guid]::NewGuid().ToString('N'))"
        audited_at_utc = [DateTime]::UtcNow.ToString('o')
        provider = $Provider
        model = $Model
        anthropic_thinking_mode = if ($Provider -eq 'anthropic') { $AnthropicThinkingMode } else { $null }
        provider_request_id = $providerResponse.request_id
        input_sha256 = Get-ExternalAuditSha256 -Text $auditInputJson
        result_sha256 = Get-ExternalAuditSha256 -Text ($auditResult | ConvertTo-Json -Depth 100 -Compress)
        routing = $routing
    }
    Write-ExternalAuditJsonFile -Value $routingRecord -Path $RoutingOutputPath

    [ordered]@{
        status = $auditResult.audit_status
        action = $routing.action
        result_path = [IO.Path]::GetFullPath($OutputPath)
        routing_path = [IO.Path]::GetFullPath($RoutingOutputPath)
    } | ConvertTo-Json -Compress

    if ($routing.action -eq 'HUMAN_DECISION_REQUIRED') { exit 20 }
    exit 0
}
catch {
    $safeMessage = $_.Exception.Message
    if ($safeMessage -match '(?i)(sk-ant-|AIza|api[_-]?key\s*[:=]|bearer\s+)[A-Za-z0-9_\-]{8,}') {
        $safeMessage = 'External audit failed. Diagnostic suppressed because it may contain secret-like text.'
    }
    [Console]::Error.WriteLine($safeMessage)
    exit 1
}
