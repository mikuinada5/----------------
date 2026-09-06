Set-StrictMode -Version Latest

function Get-NoteHeaderFileSha256 {
    param([Parameter(Mandatory)][string]$LiteralPath)
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "HEADER_FILE_NOT_FOUND: $LiteralPath" }
    (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-NoteHeaderCanonicalJsonSha256 {
    param([Parameter(Mandatory)]$Value)
    $json = $Value | ConvertTo-Json -Depth 50 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Get-NoteHeaderPngDimensions {
    param([Parameter(Mandatory)][string]$LiteralPath)
    $bytes = [IO.File]::ReadAllBytes($LiteralPath)
    $signature = [byte[]](137,80,78,71,13,10,26,10)
    if ($bytes.Length -lt 24) { throw 'HEADER_IMAGE_NOT_READABLE_PNG' }
    for ($i = 0; $i -lt 8; $i++) {
        if ($bytes[$i] -ne $signature[$i]) { throw 'HEADER_IMAGE_NOT_READABLE_PNG' }
    }
    if ([Text.Encoding]::ASCII.GetString($bytes, 12, 4) -ne 'IHDR') { throw 'HEADER_IMAGE_IHDR_MISSING' }
    $width = ([int64]$bytes[16] -shl 24) -bor ([int64]$bytes[17] -shl 16) -bor ([int64]$bytes[18] -shl 8) -bor [int64]$bytes[19]
    $height = ([int64]$bytes[20] -shl 24) -bor ([int64]$bytes[21] -shl 16) -bor ([int64]$bytes[22] -shl 8) -bor [int64]$bytes[23]
    if ($width -le 0 -or $height -le 0) { throw 'HEADER_IMAGE_DIMENSIONS_INVALID' }
    [pscustomobject]@{ width = [int]$width; height = [int]$height }
}

function Get-NoteHeaderRepositoryRoot {
    param([Parameter(Mandatory)][string]$StartPath)
    $item = Get-Item -LiteralPath $StartPath -ErrorAction Stop
    $directory = if ($item.PSIsContainer) { $item.FullName } else { $item.DirectoryName }
    while ($directory) {
        if (Test-Path -LiteralPath (Join-Path $directory 'REPOSITORY_RULES.md') -PathType Leaf) { return $directory }
        $parent = [IO.Directory]::GetParent($directory)
        if ($null -eq $parent) { break }
        $directory = $parent.FullName
    }
    throw 'HEADER_MASTER_REPOSITORY_ROOT_UNRESOLVED'
}

function Get-NoteHeaderRepositoryPath {
    param([Parameter(Mandatory)][string]$RepositoryRoot, [Parameter(Mandatory)][string]$RelativePath)
    if ([IO.Path]::IsPathRooted($RelativePath) -or $RelativePath -match '(^|/)\.\.(/|$)' -or $RelativePath -match '\\') { throw 'HEADER_MASTER_LOCATOR_INVALID' }
    $root = [IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $full = [IO.Path]::GetFullPath((Join-Path $root $RelativePath))
    if (-not $full.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'HEADER_MASTER_LOCATOR_INVALID' }
    $full
}

function Resolve-NoteHeaderMaster {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ProfileSourcePath,
        [Parameter(Mandatory)][string]$ProfileId,
        [string]$MasterAssetPath
    )
    if (-not (Test-Path -LiteralPath $ProfileSourcePath -PathType Leaf)) { throw 'HEADER_MASTER_PROFILE_SOURCE_UNRESOLVED' }
    $profileText = Get-Content -LiteralPath $ProfileSourcePath -Raw -Encoding UTF8
    $escaped = [Regex]::Escape($ProfileId)
    $block = [Regex]::Match($profileText, "(?s)<!--\s*VISUAL_PROFILE_BEGIN:$escaped\s*-->(.*?)<!--\s*VISUAL_PROFILE_END:$escaped\s*-->")
    if (-not $block.Success) { throw 'HEADER_MASTER_PROFILE_IDENTITY_MISMATCH' }
    $metaMatch = [Regex]::Match($block.Groups[1].Value, '(?s)<!--\s*VISUAL_PROFILE_META:(\{.*?\})\s*-->')
    if (-not $metaMatch.Success) { throw 'HEADER_MASTER_METADATA_MISSING' }
    try { $meta = $metaMatch.Groups[1].Value | ConvertFrom-Json }
    catch { throw "HEADER_MASTER_METADATA_INVALID: $($_.Exception.Message)" }
    foreach ($field in @('width','height','master_asset_id','master_asset_version','master_asset_locator','master_asset_manifest','master_asset_sha256')) {
        if ($null -eq $meta.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace([string]$meta.$field)) { throw "HEADER_MASTER_METADATA_INCOMPLETE: $field" }
    }
    if ([string]$meta.master_asset_sha256 -notmatch '^[0-9a-fA-F]{64}$') { throw 'HEADER_MASTER_EXPECTED_SHA_INVALID' }
    if ([string]$meta.master_asset_locator -notmatch '^04_AI_Work_Environment/Visual_Production/assets/[^/]+\.png$') { throw 'HEADER_MASTER_LOCATOR_INVALID' }
    if ([string]$meta.master_asset_manifest -notmatch '^04_AI_Work_Environment/Visual_Production/assets/[^/]+\.json$') { throw 'HEADER_MASTER_MANIFEST_LOCATOR_INVALID' }
    $repositoryRoot = Get-NoteHeaderRepositoryRoot $ProfileSourcePath
    $canonicalMasterPath = Get-NoteHeaderRepositoryPath $repositoryRoot ([string]$meta.master_asset_locator)
    $manifestPath = Get-NoteHeaderRepositoryPath $repositoryRoot ([string]$meta.master_asset_manifest)
    if (-not (Test-Path -LiteralPath $canonicalMasterPath -PathType Leaf)) { throw 'HEADER_MASTER_UNRESOLVED' }
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'HEADER_MASTER_MANIFEST_UNRESOLVED' }
    if ($MasterAssetPath) {
        $providedPath = [IO.Path]::GetFullPath($MasterAssetPath)
        if ($providedPath -cne [IO.Path]::GetFullPath($canonicalMasterPath)) { throw 'HEADER_MASTER_NOT_REPOSITORY_CANONICAL' }
    }
    $manifestSchemaPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'schemas/note_header_master_asset.schema.json'
    try { if (-not (Test-Json -LiteralPath $manifestPath -SchemaFile $manifestSchemaPath -ErrorAction Stop)) { throw 'schema mismatch' } }
    catch { throw "HEADER_MASTER_MANIFEST_SCHEMA_FAIL: $($_.Exception.Message)" }
    try { $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch { throw "HEADER_MASTER_MANIFEST_INVALID: $($_.Exception.Message)" }
    foreach ($field in @('schema_version','asset_id','version','file','repository_locator','sha256','dimensions','provenance','visual_specification')) {
        if ($null -eq $manifest.PSObject.Properties[$field]) { throw "HEADER_MASTER_MANIFEST_INCOMPLETE: $field" }
    }
    if ($manifest.schema_version -cne 'note-header-master-asset/v1' -or $manifest.asset_id -cne [string]$meta.master_asset_id -or $manifest.version -cne [string]$meta.master_asset_version) { throw 'HEADER_MASTER_MANIFEST_IDENTITY_MISMATCH' }
    if ($manifest.repository_locator -cne [string]$meta.master_asset_locator -or $manifest.sha256 -cne ([string]$meta.master_asset_sha256).ToLowerInvariant()) { throw 'HEADER_MASTER_MANIFEST_BINDING_MISMATCH' }
    if ($manifest.file -cne [IO.Path]::GetFileName($canonicalMasterPath)) { throw 'HEADER_MASTER_MANIFEST_FILE_MISMATCH' }
    if ([int]$manifest.dimensions.width -ne [int]$meta.width -or [int]$manifest.dimensions.height -ne [int]$meta.height) { throw 'HEADER_MASTER_MANIFEST_DIMENSIONS_MISMATCH' }
    if ($manifest.visual_specification.profile_id -cne $ProfileId -or [string]::IsNullOrWhiteSpace([string]$manifest.visual_specification.role)) { throw 'HEADER_MASTER_VISUAL_SPECIFICATION_MISMATCH' }
    if ($manifest.provenance.repository_copy_relationship -cne 'byte-identical' -or [string]::IsNullOrWhiteSpace([string]$manifest.provenance.original_archive_locator)) { throw 'HEADER_MASTER_PROVENANCE_INVALID' }
    $actualSha = Get-NoteHeaderFileSha256 $canonicalMasterPath
    if ($actualSha -ne ([string]$meta.master_asset_sha256).ToLowerInvariant()) { throw 'HEADER_MASTER_SHA_MISMATCH' }
    $dimensions = Get-NoteHeaderPngDimensions $canonicalMasterPath
    if ($dimensions.width -ne [int]$meta.width -or $dimensions.height -ne [int]$meta.height) { throw 'HEADER_MASTER_DIMENSIONS_MISMATCH' }
    [pscustomobject]@{
        asset_id = [string]$meta.master_asset_id
        version = [string]$meta.master_asset_version
        canonical_locator = [string]$meta.master_asset_locator
        expected_sha256 = ([string]$meta.master_asset_sha256).ToLowerInvariant()
        actual_sha256 = $actualSha
        width = $dimensions.width
        height = $dimensions.height
        manifest_locator = [string]$meta.master_asset_manifest
        provenance = "repository-master-manifest:$([string]$meta.master_asset_manifest)"
        original_archive_locator = [string]$manifest.provenance.original_archive_locator
        actual_path = [IO.Path]::GetFullPath($canonicalMasterPath)
        manifest_path = [IO.Path]::GetFullPath($manifestPath)
    }
}

function Resolve-NoteHeaderProductionRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('local-codex','chat','work','responses-api')][string]$Environment,
        [bool]$BridgeAvailable = $true
    )
    if ($Environment -eq 'local-codex' -and $BridgeAvailable) {
        return [pscustomobject]@{ result = 'PASS'; state = 'NOTE_HEADER_REQUIRED'; route = 'visual-production-bridge'; next_state = 'CURRENT_VISUAL_SOURCE_RESOLUTION'; formal_asset_eligible = $true }
    }
    if ($Environment -in @('chat','work')) {
        return [pscustomobject]@{ result = 'FAIL'; state = 'UNVERIFIED_NON_ASSET'; route = 'builtin-direct'; next_state = 'BLOCKED_PLATFORM_BOUNDARY'; formal_asset_eligible = $false }
    }
    [pscustomobject]@{ result = 'FAIL'; state = 'BLOCKED_PLATFORM_BOUNDARY'; route = 'unavailable'; next_state = 'STOP'; formal_asset_eligible = $false }
}

Export-ModuleMember -Function Get-NoteHeaderFileSha256, Get-NoteHeaderCanonicalJsonSha256, Get-NoteHeaderPngDimensions, Get-NoteHeaderRepositoryRoot, Resolve-NoteHeaderMaster, Resolve-NoteHeaderProductionRoute
