[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepositoryRoot,

    [string]$ManifestPath,

    [string]$ExpectedProductionVersion
)

$ErrorActionPreference = 'Stop'

function Get-RelativeRepositoryPath {
    param([string]$Root, [string]$Path)

    $rootUri = [Uri]((Resolve-Path -LiteralPath $Root).Path.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar)
    $pathUri = [Uri](Resolve-Path -LiteralPath $Path).Path
    return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace('\', '/')
}

function Get-CurrentMarkdownFiles {
    param([string]$Root)

    Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.md' | Where-Object {
        $relative = Get-RelativeRepositoryPath -Root $script:ResolvedRepositoryRoot -Path $_.FullName
        $segments = $relative -split '/'
        if ($segments -contains '.git' -or $segments -contains 'Archive' -or $segments -contains '03_Archive') {
            return $false
        }

        $head = ((Get-Content -LiteralPath $_.FullName -Encoding UTF8 -TotalCount 30) -join "`n").Replace('*', '')
        return $head -match '(?im)^\s*(?:>\s*)?(?:Status|ステータス)\s*:\s*.*\bCurrent\b'
    }
}

function Add-Failure {
    param([string]$Message)
    [void]$script:Failures.Add($Message)
}

function Test-RepositoryRelativePath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or [IO.Path]::IsPathRooted($Path)) { return $false }
    $normalized = $Path.Replace('\', '/')
    if (($normalized -split '/') -contains '..') { return $false }
    $candidate = [IO.Path]::GetFullPath((Join-Path $script:ResolvedRepositoryRoot $normalized))
    $rootPrefix = $script:ResolvedRepositoryRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    return $candidate.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)
}

$script:ResolvedRepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$script:Failures = [System.Collections.Generic.List[string]]::new()

$currentFiles = @(Get-CurrentMarkdownFiles -Root $script:ResolvedRepositoryRoot)
foreach ($file in $currentFiles) {
    $relative = Get-RelativeRepositoryPath -Root $script:ResolvedRepositoryRoot -Path $file.FullName
    $head = ((Get-Content -LiteralPath $file.FullName -Encoding UTF8 -TotalCount 30) -join "`n").Replace('*', '')
    if ($head -match '(?im)^\s*(?:>\s*)?(?:Status|ステータス)\s*:\s*.*Canonical\s+Delta') {
        Add-Failure "Current Canonical Delta is forbidden: $relative"
    }
    if ($file.Name -match '(?i)(差分|(?:^|[_\-. ])v\d+(?:\.\d+)*|_更新版|_完成版|\(\d+\))') {
        Add-Failure "Current Source uses a version/delta/work filename instead of a canonical filename: $relative"
    }
}

if ($ManifestPath) {
    $resolvedManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
    $manifest = Get-Content -LiteralPath $resolvedManifestPath -Encoding UTF8 -Raw | ConvertFrom-Json

    if ($manifest.schema_version -ne 'source-manifest/v2') { Add-Failure 'schema_version must be source-manifest/v2.' }
    if ([string]::IsNullOrWhiteSpace($manifest.task_id)) { Add-Failure 'task_id is required.' }
    if ([string]::IsNullOrWhiteSpace($manifest.production_version)) { Add-Failure 'production_version is required.' }
    $resolvedAt = [datetimeoffset]::MinValue
    if (-not [datetimeoffset]::TryParse([string]$manifest.repository.resolved_at, [ref]$resolvedAt)) { Add-Failure 'repository.resolved_at must be an ISO-8601 timestamp.' }
    if ($ExpectedProductionVersion -and $manifest.production_version -ne $ExpectedProductionVersion) {
        Add-Failure "Manifest Production version does not match the artifact under review: expected $ExpectedProductionVersion, found $($manifest.production_version)"
    }
    if ($manifest.repository.resolved_commit_sha -notmatch '^[0-9a-fA-F]{40}$') { Add-Failure 'A full 40-character repository commit SHA is required.' }
    $gitMetadata = Join-Path $script:ResolvedRepositoryRoot '.git'
    if (Test-Path -LiteralPath $gitMetadata) {
        $currentHead = (& git -c "safe.directory=$script:ResolvedRepositoryRoot" -C $script:ResolvedRepositoryRoot rev-parse HEAD).Trim()
        if ($LASTEXITCODE -ne 0 -or $currentHead -notmatch '^[0-9a-fA-F]{40}$') {
            Add-Failure 'Current Repository HEAD could not be resolved.'
        } elseif ($manifest.repository.resolved_commit_sha -ne $currentHead) {
            Add-Failure "Repository HEAD changed after Source Resolution: expected $($manifest.repository.resolved_commit_sha), found $currentHead"
        }
    }
    if ($manifest.resolution.method -ne 'responsibility-root-discovery') { Add-Failure 'Resolution must use responsibility-root-discovery.' }

    $roots = @($manifest.resolution.responsibility_roots)
    if ($roots.Count -eq 0) { Add-Failure 'At least one responsibility root is required.' }

    $candidateByPath = @{}
    $manifestCandidates = @($manifest.resolution.discovered_candidates)
    if ($manifestCandidates.Count -eq 0) { Add-Failure 'At least one discovered candidate is required.' }
    foreach ($candidate in $manifestCandidates) {
        $candidatePath = ([string]$candidate.path).Replace('\', '/')
        if (-not (Test-RepositoryRelativePath -Path $candidatePath)) {
            Add-Failure "Discovered candidate path escapes the Repository: $candidatePath"
            continue
        }
        if ($candidateByPath.ContainsKey($candidatePath)) { Add-Failure "Duplicate discovered candidate: $candidatePath" }
        $candidateByPath[$candidatePath] = $candidate
        if ($candidate.decision -notin @('selected', 'excluded')) { Add-Failure "Candidate decision must be selected or excluded: $candidatePath" }
        if ($candidate.decision -eq 'excluded' -and [string]::IsNullOrWhiteSpace($candidate.reason)) {
            Add-Failure "Excluded candidate requires a reason: $candidatePath"
        }
    }

    foreach ($root in $roots) {
        if (-not (Test-RepositoryRelativePath -Path ([string]$root))) {
            Add-Failure "Responsibility root escapes the Repository: $root"
            continue
        }
        $rootPath = Join-Path $script:ResolvedRepositoryRoot ([string]$root)
        if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
            Add-Failure "Responsibility root is missing or is not a directory: $root"
            continue
        }
        foreach ($discovered in @(Get-CurrentMarkdownFiles -Root $rootPath)) {
            $relative = Get-RelativeRepositoryPath -Root $script:ResolvedRepositoryRoot -Path $discovered.FullName
            if (-not $candidateByPath.ContainsKey($relative)) {
                Add-Failure "Current candidate was not enumerated from responsibility root: $relative"
            }
        }
    }

    $sourceByPath = @{}
    $manifestSources = @($manifest.sources)
    if ($manifestSources.Count -eq 0) { Add-Failure 'At least one resolved Source is required.' }
    foreach ($source in $manifestSources) {
        $sourcePath = ([string]$source.path).Replace('\', '/')
        if (-not (Test-RepositoryRelativePath -Path $sourcePath)) {
            Add-Failure "Resolved Source path escapes the Repository: $sourcePath"
            continue
        }
        if ($sourceByPath.ContainsKey($sourcePath)) { Add-Failure "Duplicate resolved Source: $sourcePath" }
        $sourceByPath[$sourcePath] = $source

        if (-not $candidateByPath.ContainsKey($sourcePath) -or $candidateByPath[$sourcePath].decision -ne 'selected') {
            Add-Failure "Resolved Source must be a selected discovered candidate: $sourcePath"
        }
        $fullPath = Join-Path $script:ResolvedRepositoryRoot $sourcePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            Add-Failure "Resolved Source is missing: $sourcePath"
            continue
        }
        if ($source.status -notmatch 'Current') { Add-Failure "Resolved Source is not Current: $sourcePath" }
        if ($source.required -notin @('required', 'conditional')) { Add-Failure "Source required value is invalid: $sourcePath" }
        if ([string]::IsNullOrWhiteSpace($source.version_or_revision)) { Add-Failure "Version or revision is missing: $sourcePath" }
        if ($source.read_task_id -ne $manifest.task_id) { Add-Failure "Read evidence is not from this task: $sourcePath" }
        if ([string]::IsNullOrWhiteSpace($source.read_by) -or [string]::IsNullOrWhiteSpace($source.read_at) -or [string]::IsNullOrWhiteSpace($source.read_scope)) {
            Add-Failure "Read evidence is incomplete: $sourcePath"
        }
        if (@($source.applied_to).Count -eq 0) { Add-Failure "Applied-to scope is missing: $sourcePath" }
        if ($source.dependency_check -ne 'PASS') { Add-Failure "Dependency check is not PASS: $sourcePath" }
        if ($source.conflict_check -ne 'PASS') { Add-Failure "Conflict check is not PASS: $sourcePath" }

        $actualSha = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualSha -ne ([string]$source.file_sha256).ToLowerInvariant()) {
            Add-Failure "Source fingerprint changed or is invalid: $sourcePath"
        }
    }

    foreach ($source in @($manifest.sources)) {
        foreach ($dependency in @($source.dependencies)) {
            $dependencyPath = ([string]$dependency).Replace('\', '/')
            if (-not (Test-RepositoryRelativePath -Path $dependencyPath)) {
                Add-Failure "Dependency path escapes the Repository: $($source.path) -> $dependencyPath"
                continue
            }
            if (-not $sourceByPath.ContainsKey($dependencyPath)) {
                Add-Failure "Dependency is outside the resolved Source closure: $($source.path) -> $dependencyPath"
            }
        }
    }

    foreach ($requiredFlag in @('resolution_complete', 'current_canonical_unique', 'dependency_closure_complete', 'same_task_read_complete', 'source_fingerprint_frozen')) {
        if ($manifest.g2.$requiredFlag -ne $true) { Add-Failure "G2 flag must be true: $requiredFlag" }
    }
    if ($manifest.g2.result -ne 'PASS') { Add-Failure 'G2 result must be PASS.' }
    $passedAt = [datetimeoffset]::MinValue
    if (-not [datetimeoffset]::TryParse([string]$manifest.g2.passed_at, [ref]$passedAt)) { Add-Failure 'g2.passed_at must be an ISO-8601 timestamp.' }
}

if ($script:Failures.Count -gt 0) {
    throw ("SOURCE_RESOLUTION_QA_FAIL`n- " + ($script:Failures -join "`n- "))
}

[pscustomobject]@{
    Result = 'PASS'
    CurrentSourceCount = $currentFiles.Count
    ManifestChecked = [bool]$ManifestPath
}
