param(
    [Parameter(Mandatory)][string]$PackagePath,
    [Parameter(Mandatory)][string]$HumanEventPath,
    [Parameter(Mandatory)][string]$ApprovalPath,
    [Parameter(Mandatory)][string]$SourceManifestPath,
    [Parameter(Mandatory)][string]$D3BodyPath,
    [Parameter(Mandatory)][string]$HeaderPath,
    [Parameter(Mandatory)][string]$OutputDirectory
)

Import-Module (Join-Path $PSScriptRoot 'PublicationBundle.psm1') -Force
New-NotePublicationBundle @PSBoundParameters
