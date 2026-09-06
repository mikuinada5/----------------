param(
    [Parameter(Mandatory)][string]$BundleZipPath,
    [Parameter(Mandatory)][string]$ExpectedPackageId,
    [Parameter(Mandatory)][string]$ExtractionDirectory,
    [ValidateSet('Handoff','E2E')][string]$Mode = 'Handoff'
)

Import-Module (Join-Path $PSScriptRoot 'PublicationBundle.psm1') -Force
if ($Mode -eq 'E2E') {
    Test-NotePublicationBundleE2EPlan -BundleZipPath $BundleZipPath -ExpectedPackageId $ExpectedPackageId -ExtractionDirectory $ExtractionDirectory
} else {
    Test-NotePublicationBundleHandoff -BundleZipPath $BundleZipPath -ExpectedPackageId $ExpectedPackageId -ExtractionDirectory $ExtractionDirectory
}
