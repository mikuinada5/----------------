[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [string]$Remote='origin',
    [string]$Branch='main'
)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'RepositorySync.psm1') -Force

& git -C $RepositoryRoot rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'REPOSITORY_PREFLIGHT_FAIL: Git work tree unavailable' }
& git -C $RepositoryRoot fetch $Remote $Branch
if ($LASTEXITCODE -ne 0) { throw 'REPOSITORY_PREFLIGHT_FAIL: fetch failed' }
$remoteRef="refs/remotes/$Remote/$Branch"
$counts=@(& git -C $RepositoryRoot rev-list --left-right --count "HEAD...$remoteRef")
if ($LASTEXITCODE -ne 0 -or $counts.Count -ne 1) { throw 'REPOSITORY_PREFLIGHT_FAIL: divergence unavailable' }
$parts=@($counts[0] -split '\s+')
$dirty=@(& git -C $RepositoryRoot status --porcelain=v1 --untracked-files=all)
$result=Get-RepositorySyncClassification -LocalAhead ([int]$parts[0]) -RemoteAhead ([int]$parts[1]) -WorkingTreeClean ($dirty.Count -eq 0)
if ($result.classification -eq 'AUTO_FAST_FORWARD') {
    & git -C $RepositoryRoot merge --ff-only $remoteRef
    if ($LASTEXITCODE -ne 0) { throw 'REPOSITORY_PREFLIGHT_FAIL: fast-forward failed' }
    $afterDirty=@(& git -C $RepositoryRoot status --porcelain=v1 --untracked-files=all)
    $afterCounts=@((& git -C $RepositoryRoot rev-list --left-right --count "HEAD...$remoteRef") -split '\s+')
    if ($afterDirty.Count -ne 0 -or [int]$afterCounts[0] -ne 0 -or [int]$afterCounts[1] -ne 0) { throw 'REPOSITORY_PREFLIGHT_FAIL: post-sync verification failed' }
    $result=[pscustomobject]@{ schema_version='repository-sync-result/v1'; classification='READY'; action='FAST_FORWARD'; ready=$true; local_ahead=0; remote_ahead=0; working_tree_clean=$true; reason='remote-only commits were fast-forwarded and verified' }
}
$result | ConvertTo-Json -Depth 10
if (-not $result.ready) { exit 2 }
