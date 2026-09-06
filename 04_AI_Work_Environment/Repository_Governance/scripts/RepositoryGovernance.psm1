Set-StrictMode -Version Latest

function ConvertTo-RepositoryPath {
    param([Parameter(Mandatory)][string]$Path)
    $value = $Path.Replace('\\','/')
    while ($value.StartsWith('./',[StringComparison]::Ordinal)) { $value=$value.Substring(2) }
    $value=$value.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($value) -or [IO.Path]::IsPathRooted($value) -or $value -match '(^|/)\.\.(/|$)') { throw "REPOSITORY_PATH_INVALID: $Path" }
    $value
}

function Test-RepositoryDomainMatch {
    param([Parameter(Mandatory)]$Domain, [Parameter(Mandatory)][string]$Path)
    $candidate = ConvertTo-RepositoryPath $Path
    if ($null -ne $Domain.PSObject.Properties['path_prefix']) {
        return $candidate.StartsWith([string]$Domain.path_prefix, [StringComparison]::Ordinal)
    }
    return @($Domain.exact_paths) -ccontains $candidate
}

function Test-RepositoryOwnershipMatrix {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$MatrixPath)
    try { $matrix = Get-Content -LiteralPath $MatrixPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30 }
    catch { throw "OWNERSHIP_MATRIX_INVALID_JSON: $($_.Exception.Message)" }
    if ($matrix.schema_version -cne 'repository-write-ownership/v1' -or $matrix.default_policy -cne 'DENY') { throw 'OWNERSHIP_MATRIX_CONTRACT_INVALID' }
    $ids = @{}
    $claims = [Collections.Generic.List[object]]::new()
    foreach ($domain in @($matrix.domains)) {
        if ($ids.ContainsKey([string]$domain.id)) { throw "OWNERSHIP_MATRIX_DUPLICATE_ID: $($domain.id)" }
        $ids[[string]$domain.id] = $true
        if ([string]$domain.owner -notin @('cloud-work','local-codex')) { throw "OWNERSHIP_MATRIX_OWNER_INVALID: $($domain.id)" }
        if ($null -ne $domain.PSObject.Properties['path_prefix']) {
            $prefix = ConvertTo-RepositoryPath ([string]$domain.path_prefix)
            if (-not $prefix.EndsWith('/')) { throw "OWNERSHIP_MATRIX_PREFIX_INVALID: $prefix" }
            $claims.Add([pscustomobject]@{ kind='prefix'; path=$prefix; owner=[string]$domain.owner; id=[string]$domain.id })
        } else {
            foreach ($path in @($domain.exact_paths)) { $claims.Add([pscustomobject]@{ kind='exact'; path=(ConvertTo-RepositoryPath ([string]$path)); owner=[string]$domain.owner; id=[string]$domain.id }) }
        }
    }
    for ($i=0; $i -lt $claims.Count; $i++) {
        for ($j=$i+1; $j -lt $claims.Count; $j++) {
            $a=$claims[$i]; $b=$claims[$j]
            if ($a.owner -ceq $b.owner) { continue }
            $overlap = if ($a.kind -eq 'exact' -and $b.kind -eq 'exact') { $a.path -ceq $b.path }
                elseif ($a.kind -eq 'prefix' -and $b.kind -eq 'prefix') { $a.path.StartsWith($b.path,[StringComparison]::Ordinal) -or $b.path.StartsWith($a.path,[StringComparison]::Ordinal) }
                elseif ($a.kind -eq 'prefix') { $b.path.StartsWith($a.path,[StringComparison]::Ordinal) }
                else { $a.path.StartsWith($b.path,[StringComparison]::Ordinal) }
            if ($overlap) { throw "OWNERSHIP_COLLISION: $($a.id) <-> $($b.id)" }
        }
    }
    [pscustomobject]@{ result='PASS'; schema_version=$matrix.schema_version; matrix_version=$matrix.matrix_version; domain_count=@($matrix.domains).Count; collision_count=0 }
}

function Get-RepositoryPathOwner {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$MatrixPath, [Parameter(Mandatory)][string]$Path)
    Test-RepositoryOwnershipMatrix $MatrixPath | Out-Null
    $matrix = Get-Content -LiteralPath $MatrixPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30
    $matches = @($matrix.domains | Where-Object { Test-RepositoryDomainMatch $_ $Path })
    if ($matches.Count -eq 0) { return [pscustomobject]@{ result='DENY'; owner='none'; mode='none'; domain_id=''; path=(ConvertTo-RepositoryPath $Path) } }
    if ($matches.Count -ne 1) { throw "OWNERSHIP_PATH_AMBIGUOUS: $Path" }
    [pscustomobject]@{ result='PASS'; owner=[string]$matches[0].owner; mode=[string]$matches[0].mode; domain_id=[string]$matches[0].id; path=(ConvertTo-RepositoryPath $Path) }
}

function Test-RepositoryWritePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('cloud-work','local-codex')][string]$Environment,
        [Parameter(Mandatory)][string]$MatrixPath,
        [Parameter(Mandatory)][string[]]$Paths,
        [string]$ArticleId,
        [string]$RepositoryRoot,
        [string]$BaselineRemoteHead,
        [string]$CurrentRemoteHead,
        [bool]$RemoteCheckPerformed = $false
    )
    if ($Paths.Count -eq 0) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason='WRITE_PLAN_EMPTY' } }
    Test-RepositoryOwnershipMatrix $MatrixPath | Out-Null
    foreach ($path in $Paths) {
        $claim = Get-RepositoryPathOwner -MatrixPath $MatrixPath -Path $path
        if ($claim.result -ne 'PASS' -or $claim.owner -cne $Environment) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason="WRITE_OWNER_MISMATCH: $path" } }
    }
    if ($Environment -eq 'local-codex') { return [pscustomobject]@{ result='PASS'; state='WRITE_ALLOWED'; reason='LOCAL_SYSTEM_SOURCE_OWNER' } }
    if ($ArticleId -notmatch '^AIDAILY-[0-9]{3,}$') { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason='CLOUD_ARTICLE_ID_INVALID' } }
    if (-not $RemoteCheckPerformed -or $BaselineRemoteHead -notmatch '^[0-9a-fA-F]{40}$' -or $CurrentRemoteHead -notmatch '^[0-9a-fA-F]{40}$' -or [string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        return [pscustomobject]@{ result='FAIL'; state='BLOCKED_PLATFORM_BOUNDARY'; reason='CLOUD_REMOTE_PREFLIGHT_NOT_VERIFIED' }
    }
    $articleRoot = "07_Note_Production/02_Published/AIDAILY/$ArticleId/"
    foreach ($path in $Paths) { if (-not (ConvertTo-RepositoryPath $path).StartsWith($articleRoot,[StringComparison]::Ordinal)) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason="CLOUD_ARTICLE_SCOPE_MISMATCH: $path" } } }
    if ($BaselineRemoteHead -cne $CurrentRemoteHead) {
        & git -C $RepositoryRoot merge-base --is-ancestor $BaselineRemoteHead $CurrentRemoteHead 2>$null
        if ($LASTEXITCODE -eq 1) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason='CLOUD_REMOTE_HISTORY_DIVERGED' } }
        if ($LASTEXITCODE -ne 0) { return [pscustomobject]@{ result='FAIL'; state='BLOCKED_PLATFORM_BOUNDARY'; reason='CLOUD_REMOTE_ANCESTRY_UNAVAILABLE' } }
    }
    $existing = @(& git -C $RepositoryRoot ls-tree -r --name-only $CurrentRemoteHead -- $articleRoot 2>$null)
    if ($LASTEXITCODE -ne 0) { return [pscustomobject]@{ result='FAIL'; state='BLOCKED_PLATFORM_BOUNDARY'; reason='CLOUD_CURRENT_REMOTE_TREE_UNAVAILABLE' } }
    if ($existing.Count -gt 0) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason='CLOUD_EXISTING_ARTICLE_OVERWRITE_FORBIDDEN' } }
    $localArticlePath = Join-Path $RepositoryRoot $articleRoot
    if (Test-Path -LiteralPath $localArticlePath) { return [pscustomobject]@{ result='FAIL'; state='STOP'; reason='CLOUD_ARTICLE_PATH_ALREADY_EXISTS' } }
    $reason = if ($BaselineRemoteHead -cne $CurrentRemoteHead) { 'REMOTE_ADVANCED_NO_ARTICLE_COLLISION' } else { 'REMOTE_UNCHANGED_NEW_ARTICLE' }
    [pscustomobject]@{ result='PASS'; state='WRITE_ALLOWED'; reason=$reason }
}

Export-ModuleMember -Function ConvertTo-RepositoryPath, Test-RepositoryOwnershipMatrix, Get-RepositoryPathOwner, Test-RepositoryWritePlan
