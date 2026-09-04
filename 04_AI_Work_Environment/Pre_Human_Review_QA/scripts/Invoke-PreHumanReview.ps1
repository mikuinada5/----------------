[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Inspect', 'Prepare', 'Verify', 'Export')][string]$Mode,
    [Parameter(Mandatory)][string]$DraftPath,
    [string]$RepositoryRoot, [string]$ManifestPath, [string]$ProductionId,
    [string]$DraftId, [string]$ProductionVersion, [string]$RecordPath, [string]$ReviewPath,
    [string]$PreviousRecordPath, [string]$PreviousReviewPath, [string]$RevisionNote, [string]$PresentedPath,
    [string]$Runtime = 'unknown', [string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'PreHumanReview.psm1') -Force
if ($Mode -eq 'Inspect') { Get-ParagraphInspection $DraftPath | ConvertTo-Json -Depth 60; return }
$common = @{ RepositoryRoot = $RepositoryRoot; DraftPath = $DraftPath; ManifestPath = $ManifestPath; ProductionId = $ProductionId; DraftId = $DraftId; ProductionVersion = $ProductionVersion; RecordPath = $RecordPath; ReviewPath = $ReviewPath }
if ($Mode -eq 'Prepare') {
    New-PreHumanReview @common -PreviousRecordPath $PreviousRecordPath -PreviousReviewPath $PreviousReviewPath -RevisionNote $RevisionNote | ConvertTo-Json -Depth 60
    return
}
if ($Mode -eq 'Verify') {
    Test-PreHumanReview @common -PresentedPath $PresentedPath -Runtime $Runtime | ConvertTo-Json -Depth 60
    return
}
# Validate before creating a candidate. New directory only: stale candidates are never overwritten.
$null = Test-PreHumanReview @common -PresentedPath $DraftPath -Runtime $Runtime
if ([string]::IsNullOrWhiteSpace($OutputDirectory) -or (Test-Path -LiteralPath $OutputDirectory)) { throw 'NEW_OUTPUT_DIRECTORY_REQUIRED' }
$null = New-Item -ItemType Directory -Path $OutputDirectory
$candidate = Join-Path $OutputDirectory 'candidate.md'
Copy-Item -LiteralPath $DraftPath -Destination $candidate
# Revalidate source/draft/review after copy. Failure leaves no PASS receipt; file is not a candidate.
$receipt = Test-PreHumanReview @common -PresentedPath $candidate -Runtime $Runtime
Write-QANewJson (Join-Path $OutputDirectory 'receipt.json') $receipt
$receipt | ConvertTo-Json -Depth 60
