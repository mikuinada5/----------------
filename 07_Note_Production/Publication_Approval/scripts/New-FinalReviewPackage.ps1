param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputDirectory
)

Import-Module (Join-Path $PSScriptRoot 'FinalReviewPackageCompiler.psm1') -Force
New-NoteFinalReviewPackage -InputPath $InputPath -OutputDirectory $OutputDirectory
