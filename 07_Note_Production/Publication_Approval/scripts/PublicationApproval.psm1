Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'FinalReviewPackageCompiler.psm1') -Force

function Get-NoteFileSha256 {
    param([Parameter(Mandatory)][string]$LiteralPath)
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "FILE_NOT_FOUND: $LiteralPath" }
    (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Assert-NoteJsonSchema {
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][string]$SchemaPath,
        [Parameter(Mandatory)][string]$Label
    )
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "$Label`_NOT_FOUND: $LiteralPath" }
    if (-not (Test-Path -LiteralPath $SchemaPath -PathType Leaf)) { throw "SCHEMA_NOT_FOUND: $SchemaPath" }
    try {
        $valid = Test-Json -LiteralPath $LiteralPath -SchemaFile $SchemaPath -ErrorAction Stop
    } catch {
        throw "$Label`_SCHEMA_FAIL: $($_.Exception.Message)"
    }
    if (-not $valid) { throw "$Label`_SCHEMA_FAIL" }
}

function Test-NoteExplicitPublicationIntent {
    param(
        [Parameter(Mandatory)][string]$Statement,
        [Parameter(Mandatory)][string]$Stage
    )
    if ($Stage -ne 'FINAL_REVIEW_PACKAGE_PRESENTED') { return $false }
    $normalized = ($Statement.Trim() -replace '[\s　]+', ' ') -replace '[。.!！…]+$', ''
    $patterns = @(
        '^(?i:ok)$',
        '^これでいい$',
        '^投稿して$',
        '^公開して$',
        '^いけー$',
        '^これでお願いします$',
        '^この内容でお願いします$',
        '^このまま進めて$',
        '^進めて$'
    )
    foreach ($pattern in $patterns) { if ($normalized -match $pattern) { return $true } }
    return $false
}

function Test-NoteDestinationEquality {
    param($Left, $Right)
    $Left.service -ceq $Right.service -and
        $Left.account_id -ceq $Right.account_id -and
        $Left.publication_target -ceq $Right.publication_target
}

function Test-NoteG5Approval {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$HumanEventPath,
        [Parameter(Mandatory)][string]$ApprovalPath,
        [Parameter(Mandatory)][string]$ActualPackagePath,
        [Parameter(Mandatory)][string]$SourceManifestPath,
        [Parameter(Mandatory)][string]$D3BodyPath,
        [Parameter(Mandatory)][string]$HeaderPath
    )

    $root = Split-Path $PSScriptRoot -Parent
    $schemaRoot = Join-Path $root 'schemas'
    Assert-NoteJsonSchema $PackagePath (Join-Path $schemaRoot 'final_review_package.schema.json') 'PACKAGE'
    Assert-NoteJsonSchema $ActualPackagePath (Join-Path $schemaRoot 'final_review_package.schema.json') 'ACTUAL_PACKAGE'
    Assert-NoteJsonSchema $HumanEventPath (Join-Path $schemaRoot 'human_event.schema.json') 'HUMAN_EVENT'
    Assert-NoteJsonSchema $ApprovalPath (Join-Path $schemaRoot 'publication_approval.schema.json') 'APPROVAL'

    $package = Get-Content -LiteralPath $PackagePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $actual = Get-Content -LiteralPath $ActualPackagePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $event = Get-Content -LiteralPath $HumanEventPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $approval = Get-Content -LiteralPath $ApprovalPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $packageSha = Get-NoteFileSha256 $PackagePath
    $actualSha = Get-NoteFileSha256 $ActualPackagePath
    $eventSha = Get-NoteFileSha256 $HumanEventPath
    $sourceSha = Get-NoteFileSha256 $SourceManifestPath
    $bodySha = Get-NoteFileSha256 $D3BodyPath
    $headerSha = Get-NoteFileSha256 $HeaderPath

    $failures = [System.Collections.Generic.List[string]]::new()
    try { Test-NoteFinalReviewPackageIdentity $package | Out-Null } catch { $failures.Add('PACKAGE_IDENTITY_INVALID') }
    try { Test-NoteFinalReviewPackageIdentity $actual | Out-Null } catch { $failures.Add('ACTUAL_PACKAGE_IDENTITY_INVALID') }
    if ($actualSha -ne $packageSha) { $failures.Add('ACTUAL_PACKAGE_MISMATCH') }
    if ($approval.package_id -ne $package.package_id -or $event.context.package_id -ne $package.package_id) { $failures.Add('PACKAGE_ID_MISMATCH') }
    if ($approval.package_identity_sha256 -ne $package.identity_sha256 -or $event.context.package_identity_sha256 -ne $package.identity_sha256) { $failures.Add('PACKAGE_IDENTITY_MISMATCH') }
    if ($approval.package_sha256 -ne $packageSha -or $event.context.package_sha256 -ne $packageSha) { $failures.Add('PACKAGE_SHA_MISMATCH') }
    if ($approval.human_event_id -ne $event.event_id -or $approval.human_event_sha256 -ne $eventSha) { $failures.Add('HUMAN_EVENT_MISMATCH') }
    if (-not (Test-NoteDestinationEquality $approval.destination $package.destination) -or -not (Test-NoteDestinationEquality $event.context.destination $package.destination)) { $failures.Add('DESTINATION_MISMATCH') }
    if ($approval.purpose -ne $package.purpose -or $event.context.purpose -ne $package.purpose) { $failures.Add('PURPOSE_MISMATCH') }
    if ($package.source_manifest.sha256 -ne $sourceSha) { $failures.Add('SOURCE_MANIFEST_MISMATCH') }
    if ($actual.d3_body.sha256 -ne $bodySha) { $failures.Add('D3_BODY_MISMATCH') }
    if ($actual.header.sha256 -ne $headerSha) { $failures.Add('HEADER_MISMATCH') }
    if (-not (Test-NoteExplicitPublicationIntent -Statement $event.statement -Stage $event.context.stage)) { $failures.Add('EXPLICIT_PUBLICATION_INTENT_MISSING') }

    try {
        $presentedAt = [DateTimeOffset]::Parse($event.context.presented_at)
        $eventAt = [DateTimeOffset]::Parse($event.occurred_at)
        $approvedAt = [DateTimeOffset]::Parse($approval.approved_at)
        if ($eventAt -lt $presentedAt) { $failures.Add('HUMAN_EVENT_BEFORE_FINAL_PACKAGE') }
        if ($approvedAt -ne $eventAt) { $failures.Add('APPROVAL_TIME_NOT_BOUND_TO_EVENT') }
    } catch { $failures.Add('APPROVAL_TIME_INVALID') }

    if ($failures.Count -gt 0) { throw ('NOTE_G5_FAIL: ' + ($failures -join ', ')) }

    [pscustomobject]@{
        result = 'PASS'
        gate = 'G5_AUTOMATED_PACKAGE_VERIFICATION'
        package_id = $package.package_id
        package_sha256 = $packageSha
        approval_id = $approval.approval_id
        approval_scope = $approval.approval_scope
        next_step = 'NOTE_DRAFT_CREATE'
        requires_additional_human_approval = $false
    }
}

function Assert-NotePublicationStep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('NOTE_DRAFT_CREATE','BODY_APPLY','HEADER_APPLY','PUBLICATION_CONDITIONS_APPLY','SETTINGS_VERIFY','PUBLISH','PPV')][string]$Step,
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$HumanEventPath,
        [Parameter(Mandatory)][string]$ApprovalPath,
        [Parameter(Mandatory)][string]$ActualPackagePath,
        [Parameter(Mandatory)][string]$SourceManifestPath,
        [Parameter(Mandatory)][string]$D3BodyPath,
        [Parameter(Mandatory)][string]$HeaderPath,
        [switch]$AdditionalHumanApprovalRequested,
        [switch]$NewHumanDecisionRequired
    )
    if ($AdditionalHumanApprovalRequested) { throw "REDUNDANT_PUBLICATION_APPROVAL_REQUEST: $Step" }
    if ($NewHumanDecisionRequired) { throw "APPROVAL_INVALIDATED_NEW_HUMAN_DECISION: $Step" }
    $g5 = Test-NoteG5Approval -PackagePath $PackagePath -HumanEventPath $HumanEventPath -ApprovalPath $ApprovalPath -ActualPackagePath $ActualPackagePath -SourceManifestPath $SourceManifestPath -D3BodyPath $D3BodyPath -HeaderPath $HeaderPath
    [pscustomobject]@{
        result = 'PASS'
        step = $Step
        package_sha256 = $g5.package_sha256
        requires_additional_human_approval = $false
    }
}

function Test-NotePublicationE2EPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$HumanEventPath,
        [Parameter(Mandatory)][string]$ApprovalPath,
        [Parameter(Mandatory)][string]$ActualPackagePath,
        [Parameter(Mandatory)][string]$SourceManifestPath,
        [Parameter(Mandatory)][string]$D3BodyPath,
        [Parameter(Mandatory)][string]$HeaderPath
    )
    $steps = @('NOTE_DRAFT_CREATE','BODY_APPLY','HEADER_APPLY','PUBLICATION_CONDITIONS_APPLY','SETTINGS_VERIFY','PUBLISH','PPV')
    $results = foreach ($step in $steps) {
        Assert-NotePublicationStep -Step $step -PackagePath $PackagePath -HumanEventPath $HumanEventPath -ApprovalPath $ApprovalPath -ActualPackagePath $ActualPackagePath -SourceManifestPath $SourceManifestPath -D3BodyPath $D3BodyPath -HeaderPath $HeaderPath
    }
    [pscustomobject]@{ result = 'PASS'; steps = @($results); stopped_for_human = $false }
}

Export-ModuleMember -Function Get-NoteFileSha256, Test-NoteExplicitPublicationIntent, Test-NoteG5Approval, Assert-NotePublicationStep, Test-NotePublicationE2EPlan
