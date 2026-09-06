[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$RepositoryRoot,
    [Parameter(Mandatory = $true)] [string]$RecordPath,
    [Parameter(Mandatory = $true)] [ValidateSet('chat','work','cloud-work','local-codex','responses-api')] [string]$Environment,
    [Parameter(Mandatory = $true)] [string]$OutputPath,
    [string]$ActualToolRequestPath,
    [string]$ImageGenerationToolEvidence,
    [string]$AssetInspectionEvidence
)

$ErrorActionPreference = 'Stop'

function Get-CanonicalJsonHash {
    param($Value)
    $json = $Value | ConvertTo-Json -Depth 30 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

$visualValidator = Join-Path $PSScriptRoot 'Test-VisualProduction.ps1'
& $visualValidator -RepositoryRoot $RepositoryRoot -RecordPath $RecordPath | Out-Null
$record = Get-Content -Raw -LiteralPath $RecordPath -Encoding UTF8 | ConvertFrom-Json
$validatedHash = Get-CanonicalJsonHash $record.tool_request
$now = [DateTimeOffset]::Now.ToString('o')

if ($Environment -in @('chat','work')) {
    $receipt = [ordered]@{
        schema_version = 'visual-runtime-receipt/v1'
        task_id = $record.task_id
        production_version = $record.production_version
        environment = $Environment
        implementation_id = 'repository-boundary-audit/v1'
        route = 'builtin-direct'
        capabilities = [ordered]@{
            current_source_resolution = 'UNVERIFIED'
            repository_script_execution = 'UNAVAILABLE'
            image_generation_tool = 'VERIFIED'
            asset_inspection = 'UNVERIFIED'
            client_visible_request_binding = 'UNAVAILABLE'
            platform_tool_choice_control = 'UNAVAILABLE'
        }
        request_binding = [ordered]@{ validated_request_sha256 = $validatedHash; actual_request_sha256 = ('0' * 64); match = $false }
        boundary = [ordered]@{ repository_enforcement_scope = 'detect-only'; platform_enforced = $false; acknowledged = $true }
        evidence = @('Standard built-in image generation has no verified Repository script interception in this environment')
        result = 'BLOCKED_PLATFORM_BOUNDARY'
        checked_at = $now
    }
    $receipt | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    throw "VISUAL_RUNTIME_BLOCKED: $Environment built-in image generation is outside the verified Repository-enforced path"
}

if ($Environment -eq 'responses-api') {
    throw 'VISUAL_RUNTIME_BLOCKED: no approved Responses API visual orchestrator is implemented in this Repository'
}

if ($Environment -eq 'cloud-work') {
    throw 'VISUAL_RUNTIME_BLOCKED: Cloud Work receipts must be built from a current-task native Tool event by cloud-work-header-bridge.mjs'
}

if (-not $ActualToolRequestPath) { throw 'VISUAL_RUNTIME_QA FAIL: Local Codex requires the exact actual Tool Request file' }
if ([string]::IsNullOrWhiteSpace($ImageGenerationToolEvidence)) { throw 'VISUAL_RUNTIME_QA FAIL: image generation tool capability evidence is required' }
if ([string]::IsNullOrWhiteSpace($AssetInspectionEvidence)) { throw 'VISUAL_RUNTIME_QA FAIL: asset inspection capability evidence is required' }

$actualRequest = Get-Content -Raw -LiteralPath $ActualToolRequestPath -Encoding UTF8 | ConvertFrom-Json
$actualHash = Get-CanonicalJsonHash $actualRequest
if ($actualHash -ne $validatedHash) { throw 'VISUAL_RUNTIME_QA FAIL: actual Tool Request differs from the validated request' }

$receipt = [ordered]@{
    schema_version = 'visual-runtime-receipt/v1'
    task_id = $record.task_id
    production_version = $record.production_version
    environment = 'local-codex'
    implementation_id = 'repo-skill:visual-production-bridge/v1'
    route = 'repository-skill-request-bound'
    capabilities = [ordered]@{
        current_source_resolution = 'VERIFIED'
        repository_script_execution = 'VERIFIED'
        image_generation_tool = 'VERIFIED'
        asset_inspection = 'VERIFIED'
        client_visible_request_binding = 'VERIFIED'
        platform_tool_choice_control = 'UNAVAILABLE'
    }
    request_binding = [ordered]@{ validated_request_sha256 = $validatedHash; actual_request_sha256 = $actualHash; match = $true }
    boundary = [ordered]@{ repository_enforcement_scope = 'client-visible-request'; platform_enforced = $false; acknowledged = $true }
    evidence = @($ImageGenerationToolEvidence, $AssetInspectionEvidence, 'Request SHA-256 matched before invocation')
    result = 'REQUEST_BOUND'
    checked_at = $now
}
$receipt | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8

$runtimeValidator = Join-Path $PSScriptRoot 'Test-VisualRuntimeReceipt.ps1'
& $runtimeValidator -RepositoryRoot $RepositoryRoot -RecordPath $RecordPath -ReceiptPath $OutputPath -ActualToolRequestPath $ActualToolRequestPath
