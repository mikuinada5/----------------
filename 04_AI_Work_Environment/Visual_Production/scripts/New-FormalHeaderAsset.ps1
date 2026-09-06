[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RepositoryRoot,
    [Parameter(Mandatory)][string]$VisualRecordPath,
    [Parameter(Mandatory)][string]$RuntimeReceiptPath,
    [Parameter(Mandatory)][string]$ActualToolRequestPath,
    [Parameter(Mandatory)][string]$GeneratedAssetPath,
    [Parameter(Mandatory)][string]$AssetCanonicalPointer,
    [Parameter(Mandatory)][string]$HumanApprovalPath,
    [Parameter(Mandatory)][string]$ProfileSourcePath,
    [string]$MasterAssetPath,
    [Parameter(Mandatory)][string]$OutputPath
)
Import-Module (Join-Path $PSScriptRoot 'HeaderAssetPromotion.psm1') -Force
New-NoteFormalHeaderAsset @PSBoundParameters
