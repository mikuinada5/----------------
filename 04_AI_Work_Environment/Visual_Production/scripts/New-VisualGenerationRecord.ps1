[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$RepositoryRoot,
    [Parameter(Mandatory = $true)] [string]$SourceManifestPath,
    [Parameter(Mandatory = $true)] [string]$ProfileSourcePath,
    [Parameter(Mandatory = $true)] [string]$ProfileId,
    [Parameter(Mandatory = $true)] [string]$TaskId,
    [string]$ArticleId,
    [Parameter(Mandatory = $true)] [string]$ProductionVersion,
    [Parameter(Mandatory = $true)] [string]$Phase,
    [Parameter(Mandatory = $true)] [string]$ArtifactType,
    [Parameter(Mandatory = $true)] [string]$ApprovedTitle,
    [Parameter(Mandatory = $true)] [int]$Width,
    [Parameter(Mandatory = $true)] [int]$Height,
    [string]$MasterAssetPath,
    [Parameter(Mandatory = $true)] [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'NoteHeaderRouting.psm1') -Force

function Get-RelativeRepositoryPath {
    param([string]$Root, [string]$Path)
    $rootPath = (Resolve-Path -LiteralPath $Root).Path.TrimEnd([IO.Path]::DirectorySeparatorChar)
    $pathValue = (Resolve-Path -LiteralPath $Path).Path
    $rootUri = [Uri]($rootPath + [IO.Path]::DirectorySeparatorChar)
    return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri([Uri]$pathValue).ToString()).Replace('\', '/')
}

function Get-TextHash {
    param([string]$Text)
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Text)))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

$sourceValidator = Join-Path $PSScriptRoot '../../Source_Resolution/scripts/Test-SourceResolution.ps1'
& $sourceValidator -RepositoryRoot $RepositoryRoot -ManifestPath $SourceManifestPath -ExpectedProductionVersion $ProductionVersion | Out-Null
$manifest = Get-Content -Raw -LiteralPath $SourceManifestPath -Encoding UTF8 | ConvertFrom-Json
if ($manifest.task_id -ne $TaskId) { throw 'VISUAL_CONTRACT_BUILD FAIL: Source Manifest task_id mismatch' }

$profileFullPath = (Resolve-Path -LiteralPath $ProfileSourcePath).Path
$profileRelativePath = Get-RelativeRepositoryPath -Root $RepositoryRoot -Path $profileFullPath
$manifestSource = @($manifest.sources | Where-Object { ([string]$_.path).Replace('\','/') -eq $profileRelativePath })
if ($manifestSource.Count -ne 1) { throw "VISUAL_CONTRACT_BUILD FAIL: Profile Source is not uniquely resolved in the G2 Manifest: $profileRelativePath" }

$profileText = Get-Content -Raw -LiteralPath $profileFullPath -Encoding UTF8
$escapedProfile = [Regex]::Escape($ProfileId)
$match = [Regex]::Match($profileText, "(?s)<!--\s*VISUAL_PROFILE_BEGIN:$escapedProfile\s*-->(.*?)<!--\s*VISUAL_PROFILE_END:$escapedProfile\s*-->")
if (-not $match.Success) { throw "VISUAL_CONTRACT_BUILD FAIL: canonical profile marker not found: $ProfileId" }
$metadataMatch = [Regex]::Match($match.Groups[1].Value, '(?s)<!--\s*VISUAL_PROFILE_META:(\{.*?\})\s*-->')
if (-not $metadataMatch.Success) { throw "VISUAL_CONTRACT_BUILD FAIL: canonical profile metadata not found: $ProfileId" }
try { $profileMetadata = $metadataMatch.Groups[1].Value | ConvertFrom-Json }
catch { throw "VISUAL_CONTRACT_BUILD FAIL: canonical profile metadata is invalid JSON: $ProfileId" }
if ([int]$profileMetadata.width -ne $Width -or [int]$profileMetadata.height -ne $Height) {
    throw "VISUAL_CONTRACT_BUILD FAIL: requested dimensions do not match canonical profile metadata: $($profileMetadata.width)x$($profileMetadata.height)"
}

$referenceAssets = @()
$referencedImagePaths = @()
$masterMetadataFields = @('master_asset_id', 'master_asset_version', 'master_asset_locator', 'master_asset_manifest', 'master_asset_sha256')
$masterMetadataValues = @($masterMetadataFields | ForEach-Object { [string]$profileMetadata.PSObject.Properties[$_].Value })
$hasAnyMasterMetadata = @($masterMetadataValues | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count -gt 0
if ($hasAnyMasterMetadata) {
    foreach ($field in $masterMetadataFields) {
        if ([string]::IsNullOrWhiteSpace([string]$profileMetadata.$field)) {
            throw "VISUAL_CONTRACT_BUILD FAIL: canonical profile master metadata is incomplete: $field"
        }
    }
    $resolveMasterArgs = @{ ProfileSourcePath = $profileFullPath; ProfileId = $ProfileId }
    if (-not [string]::IsNullOrWhiteSpace($MasterAssetPath)) { $resolveMasterArgs.MasterAssetPath = $MasterAssetPath }
    try { $resolvedMaster = Resolve-NoteHeaderMaster @resolveMasterArgs }
    catch { throw "VISUAL_CONTRACT_BUILD FAIL: $($_.Exception.Message)" }
    $masterFullPath = $resolvedMaster.actual_path
    $masterHash = $resolvedMaster.actual_sha256
    $referenceAssets = @([ordered]@{
        asset_id = $resolvedMaster.asset_id
        version = $resolvedMaster.version
        logical_locator = $resolvedMaster.canonical_locator
        manifest_locator = $resolvedMaster.manifest_locator
        sha256 = $masterHash
        expected_sha256 = $resolvedMaster.expected_sha256
        actual_sha256 = $resolvedMaster.actual_sha256
        dimensions = [ordered]@{ width = $resolvedMaster.width; height = $resolvedMaster.height }
        provenance = $resolvedMaster.provenance
    })
    $referencedImagePaths = @($masterFullPath)
}

$requirements = [System.Collections.Generic.List[object]]::new()
foreach ($line in ($match.Groups[1].Value -split "`r?`n")) {
    if ($line -notmatch '^\|') { continue }
    $columns = @($line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
    if ($columns.Count -lt 3 -or $columns[0] -in @('ID','---')) { continue }
    if ($columns[1] -notin @('MUST','MUST_NOT','MAY')) { continue }
    if ([string]::IsNullOrWhiteSpace($columns[0]) -or [string]::IsNullOrWhiteSpace($columns[2])) { throw 'VISUAL_CONTRACT_BUILD FAIL: profile requirement is incomplete' }
    $requirements.Add([ordered]@{ id = $columns[0]; level = $columns[1]; text = $columns[2]; source_path = $profileRelativePath })
}
if ($requirements.Count -eq 0) { throw "VISUAL_CONTRACT_BUILD FAIL: profile has no machine-readable requirements: $ProfileId" }

$sourceRows = @($manifest.sources | Sort-Object path | ForEach-Object { "$($_.path.Replace('\','/'))|$($_.file_sha256.ToLowerInvariant())" })
$fingerprint = Get-TextHash ($sourceRows -join "`n")
$mandatoryIds = @($requirements | Where-Object { $_.level -in @('MUST','MUST_NOT') } | ForEach-Object { $_.id })
$negativeIds = @($requirements | Where-Object { $_.level -eq 'MUST_NOT' } | ForEach-Object { $_.id })

$mustLines = @($requirements | Where-Object { $_.level -eq 'MUST' } | ForEach-Object { "- [$($_.id)] $($_.text)" })
$mustNotLines = @($requirements | Where-Object { $_.level -eq 'MUST_NOT' } | ForEach-Object { "- [$($_.id)] $($_.text)" })
$mayLines = @($requirements | Where-Object { $_.level -eq 'MAY' } | ForEach-Object { "- [$($_.id)] $($_.text)" })
$prompt = @(
    'Create exactly one visual asset under the following validated contract.',
    "Render this approved title verbatim: $ApprovedTitle",
    "Canvas: ${Width}x${Height}px (canonical profile dimensions).",
    $(if ($referenceAssets.Count -eq 1) { "Use the required Master reference image exactly as bound: $($referenceAssets[0].asset_id) $($referenceAssets[0].version), logical locator $($referenceAssets[0].logical_locator), SHA-256 $($referenceAssets[0].sha256)." }),
    'MUST:',
    ($mustLines -join "`n"),
    'MUST NOT:',
    ($mustNotLines -join "`n"),
    'MAY only when it does not conflict with MUST or MUST NOT:',
    ($mayLines -join "`n"),
    'Do not add any text other than the approved title unless a canonical MUST explicitly requires it.'
) -join "`n"

if ([string]::IsNullOrWhiteSpace($ArticleId)) { $ArticleId = $TaskId }
$toolRequest = [ordered]@{
    text_verbatim = $ApprovedTitle
    prompt = $prompt
    dimensions = [ordered]@{ width = $Width; height = $Height }
    referenced_image_paths = $referencedImagePaths
    included_requirement_ids = $mandatoryIds
    negative_requirement_ids = $negativeIds
}
$requestIdentitySha256 = Get-NoteHeaderCanonicalJsonSha256 $toolRequest

$record = [ordered]@{
    schema_version = 'visual-production/v1'
    task_id = $TaskId
    production_version = $ProductionVersion
    phase = $Phase
    artifact_type = $ArtifactType
    source_manifest = [ordered]@{
        task_id = $manifest.task_id
        production_version = $manifest.production_version
        result = $manifest.g2.result
        fingerprint_sha256 = $fingerprint
        sources = @($manifest.sources | ForEach-Object { [ordered]@{ path = $_.path; file_sha256 = $_.file_sha256; applied_to = @($_.applied_to) } })
    }
    resolved_requirements = @($requirements)
    generation_contract = [ordered]@{
        article_id = $ArticleId
        profile_id = $ProfileId
        source_fingerprint_sha256 = $fingerprint
        approved_text = [ordered]@{ title = $ApprovedTitle }
        dimensions = [ordered]@{ width = $Width; height = $Height }
        reference_assets = $referenceAssets
        request_identity_sha256 = $requestIdentitySha256
        requirement_ids = $mandatoryIds
        creative_direction = @()
        inspection_capability = 'ai-visual-inspection'
        max_automatic_retries = 2
    }
    tool_route = [ordered]@{ tool = 'image_gen.imagegen'; capability = 'image-generation'; allowed = $true; rationale = 'validated visual production phase' }
    tool_request = $toolRequest
    preflight = [ordered]@{
        tool_route_check = $true
        contract_completeness_check = $true
        prompt_assembly_check = $true
        exact_text_check = $true
        negative_constraints_check = $true
        reference_asset_check = (-not $hasAnyMasterMetadata) -or ($referenceAssets.Count -eq 1)
        source_fingerprint_check = $true
        result = 'PASS'
    }
    asset = [ordered]@{ status = 'NOT_GENERATED'; retry_count = 0; provenance = '' }
    asset_qa = [ordered]@{ performed = $false; result = 'NOT_RUN'; checks = @() }
    transition = [ordered]@{ requested_target = 'TOOL_INVOCATION_PENDING'; stop_reason = '' }
}

$record | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$visualValidator = Join-Path $PSScriptRoot 'Test-VisualProduction.ps1'
& $visualValidator -RepositoryRoot $RepositoryRoot -RecordPath $OutputPath | Out-Null
$record.tool_request | ConvertTo-Json -Depth 20
