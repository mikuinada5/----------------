[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [Parameter(Mandatory)][string]$ArticleId,
    [Parameter(Mandatory)][string[]]$Paths,
    [Parameter(Mandatory)][string]$BaselineRemoteHead,
    [Parameter(Mandatory)][string]$CurrentRemoteHead,
    [Parameter(Mandatory)][bool]$RemoteCheckPerformed,
    [string]$MatrixPath=(Join-Path $PSScriptRoot '../ownership-matrix.json')
)
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSScriptRoot 'RepositoryGovernance.psm1') -Force
$result=Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $MatrixPath -Paths $Paths -ArticleId $ArticleId -RepositoryRoot $RepositoryRoot -BaselineRemoteHead $BaselineRemoteHead -CurrentRemoteHead $CurrentRemoteHead -RemoteCheckPerformed $RemoteCheckPerformed
$result | ConvertTo-Json -Depth 10
if ($result.result -ne 'PASS') { exit 2 }
