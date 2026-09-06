[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryRoot,

    [Parameter(Mandatory = $true)]
    [string]$RecordPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'NoteHeaderRouting.psm1') -Force
function Stop-VisualProductionValidation {
    param([string]$Message)
    throw "VISUAL_PRODUCTION_QA FAIL`n- $Message"
}

function Get-Values {
    param($Value)
    if ($null -eq $Value) { return @() }
    return @($Value)
}

function Resolve-RepositoryPath {
    param([string]$RelativePath)
    if ([string]::IsNullOrWhiteSpace($RelativePath) -or [System.IO.Path]::IsPathRooted($RelativePath)) {
        Stop-VisualProductionValidation "Source path must be Repository-relative: $RelativePath"
        return $null
    }

    $root = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $root $RelativePath))
    if (-not $candidate.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        Stop-VisualProductionValidation "Source path escapes Repository: $RelativePath"
        return $null
    }
    return $candidate
}

if (-not (Test-Path -LiteralPath $RecordPath -PathType Leaf)) {
    throw "Visual Production Record not found: $RecordPath"
}

try {
    $record = Get-Content -Raw -LiteralPath $RecordPath -Encoding UTF8 | ConvertFrom-Json
}
catch {
    throw "Visual Production Record is not valid JSON: $($_.Exception.Message)"
}

$requiredTopLevel = @(
    'schema_version', 'task_id', 'production_version', 'phase', 'artifact_type',
    'source_manifest', 'resolved_requirements', 'generation_contract', 'tool_route',
    'tool_request', 'preflight', 'asset', 'asset_qa', 'transition'
)
foreach ($name in $requiredTopLevel) {
    if ($null -eq $record.PSObject.Properties[$name]) { Stop-VisualProductionValidation "Missing field: $name" }
}

if ($record.schema_version -ne 'visual-production/v1') { Stop-VisualProductionValidation 'schema_version must be visual-production/v1' }

$imagePhases = @('Header Production', 'SNS Visual Production', 'Educational Visual Production', 'Visual Production')
$toolName = [string]$record.tool_route.tool
$isImageGeneration = [string]$record.tool_route.capability -eq 'image-generation'

if ($record.phase -eq 'Marketing Review' -and $isImageGeneration) {
    Stop-VisualProductionValidation 'Marketing Review must not invoke an image-generation tool'
}
if ($isImageGeneration -and -not ($imagePhases -contains [string]$record.phase)) {
    Stop-VisualProductionValidation "Image-generation tool is not allowed in phase: $($record.phase)"
}
if ($isImageGeneration -and $record.tool_route.allowed -ne $true) {
    Stop-VisualProductionValidation 'Image-generation tool route is not explicitly allowed'
}
if ([string]::IsNullOrWhiteSpace($toolName) -or -not $isImageGeneration) {
    Stop-VisualProductionValidation 'Visual Generation Record must identify an image-generation capability and concrete tool'
}

if ($record.source_manifest.result -ne 'PASS') { Stop-VisualProductionValidation 'Source Manifest must be PASS' }
if ($record.source_manifest.task_id -ne $record.task_id) { Stop-VisualProductionValidation 'Source Manifest task_id mismatch' }
if ($record.source_manifest.production_version -ne $record.production_version) { Stop-VisualProductionValidation 'Source Manifest production_version mismatch' }

$fingerprint = [string]$record.source_manifest.fingerprint_sha256
if ($fingerprint -notmatch '^[0-9a-fA-F]{64}$') { Stop-VisualProductionValidation 'Source Manifest fingerprint is missing or invalid' }
if ([string]$record.generation_contract.source_fingerprint_sha256 -ne $fingerprint) {
    Stop-VisualProductionValidation 'Generation Contract uses a stale or different Source fingerprint'
}
if ([string]::IsNullOrWhiteSpace([string]$record.generation_contract.article_id)) {
    Stop-VisualProductionValidation 'Generation Contract Article ID is missing'
}
$actualRequestIdentity = Get-NoteHeaderCanonicalJsonSha256 $record.tool_request
if ([string]$record.generation_contract.request_identity_sha256 -ne $actualRequestIdentity) {
    Stop-VisualProductionValidation 'Generation Contract request identity does not match the actual Tool Request'
}

$sourcePaths = @{}
foreach ($source in Get-Values $record.source_manifest.sources) {
    $relative = [string]$source.path
    $fullPath = Resolve-RepositoryPath $relative
    if ($null -eq $fullPath) { continue }
    $sourcePaths[$relative] = $true
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Stop-VisualProductionValidation "Resolved Source is not reachable: $relative"
        continue
    }
    $actualHash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne ([string]$source.file_sha256).ToLowerInvariant()) {
        Stop-VisualProductionValidation "Resolved Source changed after contract assembly: $relative"
    }
    if ((Get-Values $source.applied_to).Count -eq 0) { Stop-VisualProductionValidation "Source applied_to is missing: $relative" }
}
if ($sourcePaths.Count -eq 0) { Stop-VisualProductionValidation 'No resolved Visual Source was recorded' }

$requirements = Get-Values $record.resolved_requirements
$requirementById = @{}
foreach ($requirement in $requirements) {
    $id = [string]$requirement.id
    if ([string]::IsNullOrWhiteSpace($id)) { Stop-VisualProductionValidation 'Resolved requirement id is missing'; continue }
    if ($requirementById.ContainsKey($id)) { Stop-VisualProductionValidation "Duplicate requirement id: $id" }
    $requirementById[$id] = $requirement
    if (@('MUST', 'MUST_NOT', 'MAY') -notcontains [string]$requirement.level) {
        Stop-VisualProductionValidation "Invalid requirement level: $id"
    }
    if (-not $sourcePaths.ContainsKey([string]$requirement.source_path)) {
        Stop-VisualProductionValidation "Requirement is not traceable to a resolved Source: $id"
    }
}

$mandatoryIds = @($requirements | Where-Object { $_.level -in @('MUST', 'MUST_NOT') } | ForEach-Object { [string]$_.id })
if ($mandatoryIds.Count -eq 0) { Stop-VisualProductionValidation 'Generation Contract has no MUST or MUST_NOT requirement' }

$contractIds = @(Get-Values $record.generation_contract.requirement_ids | ForEach-Object { [string]$_ })
$requestIds = @(Get-Values $record.tool_request.included_requirement_ids | ForEach-Object { [string]$_ })
$negativeRequestIds = @(Get-Values $record.tool_request.negative_requirement_ids | ForEach-Object { [string]$_ })
foreach ($id in $mandatoryIds) {
    if ($contractIds -notcontains $id) { Stop-VisualProductionValidation "Generation Contract omitted required constraint: $id" }
    if ($requestIds -notcontains $id) { Stop-VisualProductionValidation "Actual tool request omitted required constraint: $id" }
    $requirementText = [string]$requirementById[$id].text
    if ([string]::IsNullOrWhiteSpace($requirementText) -or -not ([string]$record.tool_request.prompt).Contains($requirementText)) {
        Stop-VisualProductionValidation "Actual tool request prompt omitted required constraint text: $id"
    }
}
foreach ($id in @($requirements | Where-Object { $_.level -eq 'MUST_NOT' } | ForEach-Object { [string]$_.id })) {
    if ($negativeRequestIds -notcontains $id) { Stop-VisualProductionValidation "Actual tool request omitted negative constraint: $id" }
}
foreach ($id in $contractIds) {
    if (-not $requirementById.ContainsKey($id)) { Stop-VisualProductionValidation "Generation Contract contains unresolved requirement: $id" }
}

if ([string]$record.artifact_type -eq 'note-header') {
    $canonicalIds = @(
        'master-reference','note-horizontal','current-dimensions','human-left','kei-right','comic-style','white-background','black-pink-palette',
        'master-title-replace','title-exact','title-central','no-series-label','no-speech-bubbles','no-explanation-copy','no-checklists',
        'no-additional-catch-copy','no-background-recolor','no-unverified-facts','no-hype','no-poster-layout','no-title-change'
    )
    foreach ($id in $canonicalIds) {
        if (-not $requirementById.ContainsKey($id)) { Stop-VisualProductionValidation "Canonical note Header requirement is missing: $id" }
    }
    if ([int]$record.generation_contract.dimensions.width -ne 1280 -or [int]$record.generation_contract.dimensions.height -ne 670) {
        Stop-VisualProductionValidation 'Canonical note Header dimensions must be 1280x670'
    }
}

$referenceAssets = @(Get-Values $record.generation_contract.reference_assets)
$referencedImagePaths = @(Get-Values $record.tool_request.referenced_image_paths | ForEach-Object { [string]$_ })
if ($mandatoryIds -contains 'master-reference') {
    if ($referenceAssets.Count -ne 1) { Stop-VisualProductionValidation 'Master-bound profile requires exactly one contract reference asset' }
    if ($referencedImagePaths.Count -ne 1) { Stop-VisualProductionValidation 'Master-bound profile requires exactly one actual referenced image path' }
}
if ($referenceAssets.Count -ne $referencedImagePaths.Count) {
    Stop-VisualProductionValidation 'Contract reference assets and actual referenced image paths do not match'
}
for ($i = 0; $i -lt $referenceAssets.Count; $i++) {
    $reference = $referenceAssets[$i]
    foreach ($field in @('asset_id', 'version', 'logical_locator', 'sha256')) {
        if ([string]::IsNullOrWhiteSpace([string]$reference.$field)) {
            Stop-VisualProductionValidation "Reference asset field is missing: $field"
        }
    }
    if ([string]$record.artifact_type -eq 'note-header') {
        foreach ($field in @('expected_sha256','actual_sha256','dimensions','provenance')) {
            if ($null -eq $reference.PSObject.Properties[$field]) { Stop-VisualProductionValidation "Master resolution field is missing: $field" }
        }
        if ([string]$reference.expected_sha256 -ne [string]$reference.sha256 -or [string]$reference.actual_sha256 -ne [string]$reference.sha256) {
            Stop-VisualProductionValidation 'Master expected, actual and contract SHA-256 values do not match'
        }
        if ([int]$reference.dimensions.width -ne 1280 -or [int]$reference.dimensions.height -ne 670) {
            Stop-VisualProductionValidation 'Master dimensions must be 1280x670'
        }
        if ([string]::IsNullOrWhiteSpace([string]$reference.provenance)) { Stop-VisualProductionValidation 'Master provenance is missing' }
    }
    if ([string]$reference.logical_locator -notmatch '^AI/(?!.*(?:^|/)\.\.(?:/|$))[^\\]+$') {
        Stop-VisualProductionValidation 'Reference asset logical locator must be AI-root-relative and must not contain a machine-specific path'
    }
    if ([string]$reference.sha256 -notmatch '^[0-9a-fA-F]{64}$') {
        Stop-VisualProductionValidation 'Reference asset SHA-256 is invalid'
    }
    $actualReferencePath = $referencedImagePaths[$i]
    if ([string]::IsNullOrWhiteSpace($actualReferencePath) -or -not [IO.Path]::IsPathRooted($actualReferencePath)) {
        Stop-VisualProductionValidation 'Actual referenced image path must be an absolute runtime path'
    }
    if (-not (Test-Path -LiteralPath $actualReferencePath -PathType Leaf)) {
        Stop-VisualProductionValidation "Actual referenced image is not reachable: $actualReferencePath"
    }
    $actualReferenceHash = (Get-FileHash -LiteralPath $actualReferencePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualReferenceHash -ne ([string]$reference.sha256).ToLowerInvariant()) {
        Stop-VisualProductionValidation "Actual referenced image does not match the approved Master SHA-256: $($reference.asset_id)"
    }
    foreach ($value in @([string]$reference.asset_id, [string]$reference.version, [string]$reference.logical_locator, [string]$reference.sha256)) {
        if (-not ([string]$record.tool_request.prompt).Contains($value)) {
            Stop-VisualProductionValidation "Actual tool request prompt omitted Master reference identity: $value"
        }
    }
}

$approvedTitle = [string]$record.generation_contract.approved_text.title
if ([string]::IsNullOrWhiteSpace($approvedTitle)) { Stop-VisualProductionValidation 'Approved title is missing from Generation Contract' }
if ([string]$record.tool_request.text_verbatim -cne $approvedTitle) { Stop-VisualProductionValidation 'Approved title was modified in the actual tool request' }
if (-not ([string]$record.tool_request.prompt).Contains($approvedTitle)) { Stop-VisualProductionValidation 'Actual tool request prompt does not contain the approved title verbatim' }
if ($record.tool_request.dimensions.width -ne $record.generation_contract.dimensions.width -or $record.tool_request.dimensions.height -ne $record.generation_contract.dimensions.height) {
    Stop-VisualProductionValidation 'Actual tool request dimensions do not match the Generation Contract'
}

if ($record.generation_contract.dimensions.width -le 0 -or $record.generation_contract.dimensions.height -le 0) {
    Stop-VisualProductionValidation 'Generation Contract dimensions are invalid'
}
if ($record.generation_contract.max_automatic_retries -lt 0 -or $record.generation_contract.max_automatic_retries -gt 2) {
    Stop-VisualProductionValidation 'max_automatic_retries must be between 0 and 2'
}

foreach ($direction in Get-Values $record.generation_contract.creative_direction) {
    $conflicts = @(Get-Values $direction.conflicts_with | Where-Object { $mandatoryIds -contains [string]$_ })
    if ($conflicts.Count -gt 0 -and [string]$direction.resolution -ne 'dropped') {
        Stop-VisualProductionValidation "Creative Direction overrides a canonical constraint: $($direction.id)"
    }
}

$preflightChecks = @('tool_route_check', 'contract_completeness_check', 'prompt_assembly_check', 'exact_text_check', 'negative_constraints_check', 'reference_asset_check', 'source_fingerprint_check')
foreach ($check in $preflightChecks) {
    if ($record.preflight.$check -ne $true) { Stop-VisualProductionValidation "Prompt Assembly QA did not pass: $check" }
}
if ($record.preflight.result -ne 'PASS') { Stop-VisualProductionValidation 'Prompt Assembly QA result must be PASS before generation' }

$target = [string]$record.transition.requested_target
$protectedTargets = @('HUMAN_REVIEW_CANDIDATE', 'ASSET_READY', 'G5_PACKAGE', 'READY_FOR_PUBLISH')
$formalHeaderTargets = @('ASSET_READY', 'G5_PACKAGE', 'READY_FOR_PUBLISH')
if ([string]$record.artifact_type -eq 'note-header' -and $formalHeaderTargets -contains $target) {
    Stop-VisualProductionValidation 'note Header must stop at HUMAN_REVIEW_CANDIDATE and use the Formal Header Asset Promotion Gate'
}
$qaResult = [string]$record.asset_qa.result
$qaChecks = @{}
foreach ($check in Get-Values $record.asset_qa.checks) {
    $qaChecks[[string]$check.requirement_id] = [string]$check.result
}

if ($protectedTargets -contains $target) {
    if ($record.asset_qa.performed -ne $true -or $qaResult -ne 'PASS') {
        Stop-VisualProductionValidation "$target requires completed Asset QA PASS"
    }
    if ([string]$record.asset.status -ne 'QA_PASS') { Stop-VisualProductionValidation "$target requires asset status QA_PASS" }
    foreach ($id in $mandatoryIds) {
        if (-not $qaChecks.ContainsKey($id) -or $qaChecks[$id] -ne 'PASS') {
            Stop-VisualProductionValidation "Asset QA did not verify required constraint: $id"
        }
    }
    if (-not $qaChecks.ContainsKey('dimensions') -or $qaChecks['dimensions'] -ne 'PASS') {
        Stop-VisualProductionValidation 'Asset QA did not verify dimensions'
    }
    if ([string]$record.artifact_type -eq 'note-header') {
        foreach ($field in @('file','local_path','sha256','width','height','provenance')) {
            if ($null -eq $record.asset.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace([string]$record.asset.$field)) {
                Stop-VisualProductionValidation "Header asset evidence is missing: $field"
            }
        }
        if ([string]$record.asset.sha256 -notmatch '^[0-9a-fA-F]{64}$') { Stop-VisualProductionValidation 'Header asset SHA-256 is invalid' }
        if ([int]$record.asset.width -ne 1280 -or [int]$record.asset.height -ne 670) { Stop-VisualProductionValidation 'Header asset dimensions must be 1280x670' }
        if (-not [IO.Path]::IsPathRooted([string]$record.asset.local_path) -or -not (Test-Path -LiteralPath $record.asset.local_path -PathType Leaf)) { Stop-VisualProductionValidation 'Header asset local file is not reachable' }
        if ((Get-NoteHeaderFileSha256 $record.asset.local_path) -ne ([string]$record.asset.sha256).ToLowerInvariant()) { Stop-VisualProductionValidation 'Header asset bytes do not match the recorded SHA-256' }
        try { $assetDimensions = Get-NoteHeaderPngDimensions $record.asset.local_path } catch { Stop-VisualProductionValidation $_.Exception.Message }
        if ($assetDimensions.width -ne 1280 -or $assetDimensions.height -ne 670) { Stop-VisualProductionValidation 'Header asset actual dimensions must be 1280x670' }
    }
}

if ($qaResult -eq 'FAIL' -and $protectedTargets -contains $target) {
    Stop-VisualProductionValidation 'QA FAIL asset cannot transition to a publish or Human Review state'
}

$retryCount = [int]$record.asset.retry_count
$maxRetries = [int]$record.generation_contract.max_automatic_retries
if ($target -eq 'RETRY' -and $retryCount -ge $maxRetries) {
    Stop-VisualProductionValidation 'Automatic retry limit has been reached; transition must be STOP'
}
if ($target -eq 'STOP' -and $qaResult -eq 'FAIL' -and $retryCount -lt $maxRetries -and $record.transition.stop_reason -eq 'retry-limit') {
    Stop-VisualProductionValidation 'retry-limit STOP is invalid while safe retries remain'
}

if ($record.generation_contract.inspection_capability -eq 'human-required' -and $qaResult -ne 'PASS') {
    if ($target -ne 'HUMAN_ASSET_QA') {
        Stop-VisualProductionValidation 'Uninspectable asset may only transition to HUMAN_ASSET_QA'
    }
    if ([string]$record.asset.status -ne 'QA_UNVERIFIED') {
        Stop-VisualProductionValidation 'Uninspectable asset must remain QA_UNVERIFIED'
    }
}

[pscustomobject]@{
    result = 'PASS'
    task_id = $record.task_id
    production_version = $record.production_version
    phase = $record.phase
    artifact_type = $record.artifact_type
    transition = $target
} | ConvertTo-Json -Compress
