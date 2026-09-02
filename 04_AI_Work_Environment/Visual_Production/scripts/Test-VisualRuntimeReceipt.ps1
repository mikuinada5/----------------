[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$RepositoryRoot,
    [Parameter(Mandatory = $true)] [string]$RecordPath,
    [Parameter(Mandatory = $true)] [string]$ReceiptPath,
    [string]$ActualToolRequestPath
)

$ErrorActionPreference = 'Stop'

function Stop-RuntimeValidation {
    param([string]$Message)
    throw "VISUAL_RUNTIME_QA FAIL`n- $Message"
}

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

try { $record = Get-Content -Raw -LiteralPath $RecordPath -Encoding UTF8 | ConvertFrom-Json }
catch { Stop-RuntimeValidation "Visual Production Record is unreadable: $($_.Exception.Message)" }
try { $receipt = Get-Content -Raw -LiteralPath $ReceiptPath -Encoding UTF8 | ConvertFrom-Json }
catch { Stop-RuntimeValidation "Runtime Receipt is unreadable: $($_.Exception.Message)" }

$required = @('schema_version','task_id','production_version','environment','implementation_id','route','capabilities','request_binding','boundary','result','checked_at')
foreach ($name in $required) {
    if ($null -eq $receipt.PSObject.Properties[$name]) { Stop-RuntimeValidation "Missing field: $name" }
}
if ($receipt.schema_version -ne 'visual-runtime-receipt/v1') { Stop-RuntimeValidation 'schema_version must be visual-runtime-receipt/v1' }
if ($receipt.task_id -ne $record.task_id -or $receipt.production_version -ne $record.production_version) {
    Stop-RuntimeValidation 'Runtime Receipt does not match the Visual Production task/version'
}
if ([string]::IsNullOrWhiteSpace([string]$receipt.implementation_id)) { Stop-RuntimeValidation 'implementation_id is required' }
if ($receipt.boundary.acknowledged -ne $true) { Stop-RuntimeValidation 'Platform boundary must be acknowledged' }

$validatedHash = Get-CanonicalJsonHash $record.tool_request
if ([string]$receipt.request_binding.validated_request_sha256 -ne $validatedHash) {
    Stop-RuntimeValidation 'Receipt is not bound to the validated Tool Request'
}

if ($ActualToolRequestPath) {
    try { $actualRequest = Get-Content -Raw -LiteralPath $ActualToolRequestPath -Encoding UTF8 | ConvertFrom-Json }
    catch { Stop-RuntimeValidation "Actual Tool Request is unreadable: $($_.Exception.Message)" }
    $actualHash = Get-CanonicalJsonHash $actualRequest
    if ($actualHash -ne $validatedHash) { Stop-RuntimeValidation 'Actual Tool Request differs from the validated request' }
    if ([string]$receipt.request_binding.actual_request_sha256 -ne $actualHash -or $receipt.request_binding.match -ne $true) {
        Stop-RuntimeValidation 'Actual Tool Request binding evidence is missing or false'
    }
}
elseif ($receipt.result -eq 'REQUEST_BOUND') {
    Stop-RuntimeValidation 'REQUEST_BOUND requires the actual Tool Request to be supplied to validation'
}

$environment = [string]$receipt.environment
$route = [string]$receipt.route
if ($environment -in @('chat','work')) {
    if ($receipt.result -ne 'BLOCKED_PLATFORM_BOUNDARY' -or $route -ne 'builtin-direct') {
        Stop-RuntimeValidation "$environment built-in image generation is not a verified Repository-enforced route"
    }
    if ($receipt.boundary.platform_enforced -eq $true) { Stop-RuntimeValidation 'Chat/Work direct route must not claim platform enforcement' }
}
elseif ($environment -eq 'local-codex') {
    if ($route -ne 'repository-skill-request-bound') { Stop-RuntimeValidation 'Local Codex must use the Repository Skill request-bound route' }
    foreach ($capability in @('current_source_resolution','repository_script_execution','image_generation_tool','asset_inspection','client_visible_request_binding')) {
        if ([string]$receipt.capabilities.$capability -ne 'VERIFIED') { Stop-RuntimeValidation "Local Codex capability is not VERIFIED: $capability" }
    }
    if ($receipt.capabilities.platform_tool_choice_control -eq 'VERIFIED') {
        Stop-RuntimeValidation 'Local Codex request binding is not platform-wide tool-choice enforcement'
    }
    if ($receipt.boundary.repository_enforcement_scope -ne 'client-visible-request' -or $receipt.boundary.platform_enforced -ne $false) {
        Stop-RuntimeValidation 'Local Codex must record client-visible request enforcement and the remaining platform boundary'
    }
    if ($receipt.result -ne 'REQUEST_BOUND' -or $receipt.request_binding.match -ne $true) {
        Stop-RuntimeValidation 'Local Codex generation requires an exact request binding PASS'
    }
}
elseif ($environment -eq 'responses-api') {
    Stop-RuntimeValidation 'No approved Responses API visual orchestrator is implemented in this Repository'
}
else {
    Stop-RuntimeValidation "Unknown environment: $environment"
}

[pscustomobject]@{
    result = 'PASS'
    runtime_result = $receipt.result
    environment = $environment
    task_id = $receipt.task_id
    production_version = $receipt.production_version
    validated_request_sha256 = $validatedHash
} | ConvertTo-Json -Compress
