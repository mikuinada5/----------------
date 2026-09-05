param(
    [Parameter(Mandatory)][string]$PackagePath,
    [Parameter(Mandatory)][string]$HumanEventPath,
    [Parameter(Mandatory)][string]$ApprovalPath,
    [Parameter(Mandatory)][string]$ActualPackagePath,
    [Parameter(Mandatory)][string]$SourceManifestPath,
    [Parameter(Mandatory)][string]$D3BodyPath,
    [Parameter(Mandatory)][string]$HeaderPath,
    [ValidateSet('G5','E2E')][string]$Mode = 'G5'
)

Import-Module (Join-Path $PSScriptRoot 'PublicationApproval.psm1') -Force

[void]$PSBoundParameters.Remove('Mode')
if ($Mode -eq 'E2E') {
    Test-NotePublicationE2EPlan @PSBoundParameters | Select-Object -Property result, steps, stopped_for_human
} else {
    Test-NoteG5Approval @PSBoundParameters
}
