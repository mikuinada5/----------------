Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Implementation = 'pre-human-review/v1'
$script:Checks = @('one_sentence_runs', 'same_event_topic_emotion', 'stacked_short_cards', 'smartphone_breaks', 'connectors_thought_flow', 'chat_statistics_not_layout', 'tail_and_whole_text', 'purpose_source_fidelity', 'voice_brand', 'accuracy_safety', 'format_traceability')

function Get-QASha([byte[]]$Bytes) {
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($Bytes)).ToLowerInvariant()
}
function Get-QAFileSha([string]$Path) { Get-QASha ([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Path))) }
function Get-QAObjectSha($Value) { Get-QASha ([Text.Encoding]::UTF8.GetBytes(($Value | ConvertTo-Json -Depth 80 -Compress))) }
function Write-QANewJson([string]$Path, $Value) {
    $bytes = [Text.Encoding]::UTF8.GetBytes(($Value | ConvertTo-Json -Depth 80))
    $stream = [IO.File]::Open([IO.Path]::GetFullPath($Path), 'CreateNew', 'Write', 'None')
    try { $stream.Write($bytes) } finally { $stream.Dispose() }
}
function Read-QAJson([string]$Path, [string]$Schema) {
    $json = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path))
    if ($Schema -and -not (Test-Json -Json $json -SchemaFile $Schema -ErrorAction Stop)) { throw 'QA_SCHEMA_FAIL' }
    $json | ConvertFrom-Json -AsHashtable
}

function Get-ParagraphInspection([string]$DraftPath) {
    # Analysis normalizes line endings only; identity and export always use original bytes.
    $bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $DraftPath))
    $text = [Text.UTF8Encoding]::new($false, $true).GetString($bytes).TrimStart([char]0xFEFF)
    if ([string]::IsNullOrWhiteSpace($text)) { throw 'EMPTY_DRAFT' }
    $text = $text.Replace("`r`n", "`n").Replace("`r", "`n")
    # Include hard breaks, not just empty lines; headings/quotes/lists never grant QA exemption.
    $blocks = @([regex]::Split($text, '(?:\n[\t ]*\n+| {2,}\n|\\\n|(?i:<br\s*/?>))') | Where-Object { $_.Trim() })
    $paragraphs = @(); $boundaries = @(); $flags = @(); $index = 0
    foreach ($block in $blocks) {
        $index++
        $plain = ($block -replace '[*`_]', '').Trim()
        $sentences = @([regex]::Split($plain, '[。！？!?]+[」』”"]*|\.(?:\s|$)') | Where-Object { $_.Trim() }).Count
        $structural = $plain -match '(?m)^\s*(#{1,6} |[-+*] |\d+[.)] |\|)|^```'
        $paragraphs += [ordered]@{ id = "P$index"; sha256 = (Get-QASha ([Text.Encoding]::UTF8.GetBytes($block))); chars = $plain.Length; sentences = $sentences; structural_candidate = $structural; short = ($plain.Length -le 80); one_sentence = ($sentences -le 1); soft_line_breaks = ([regex]::Matches($block, '\n').Count) }
        if ($index -gt 1) { $boundaries += [ordered]@{ id = "B$($index - 1)-$index"; left = "P$($index - 1)"; right = "P$index" } }
    }
    foreach ($kind in @('one_sentence', 'short')) {
        $run = @()
        foreach ($p in @($paragraphs) + @(@{ id = ''; structural_candidate = $true; one_sentence = $false; short = $false })) {
            if (-not $p.structural_candidate -and $p[$kind]) { $run += $p.id; continue }
            if ($run.Count -ge 3) { $flags += [ordered]@{ id = "F$($flags.Count + 1)"; kind = $kind; paragraphs = $run; tail = ([int]($run[-1].Substring(1)) -gt ($paragraphs.Count * 2 / 3)) } }
            $run = @()
        }
    }
    [ordered]@{ draft_sha256 = (Get-QASha $bytes); paragraphs = $paragraphs; boundaries = $boundaries; findings = $flags; result = 'UNREVIEWED' }
}

function Test-QASources([string]$RepositoryRoot, [string]$ManifestPath, [string]$ProductionVersion) {
    $base = Join-Path $RepositoryRoot '04_AI_Work_Environment/Source_Resolution'
    $m = Read-QAJson $ManifestPath (Join-Path $base 'schemas/source_manifest.schema.json')
    & (Join-Path $base 'scripts/Test-SourceResolution.ps1') -RepositoryRoot $RepositoryRoot -ManifestPath $ManifestPath -ExpectedProductionVersion $ProductionVersion | Out-Null
    foreach ($path in @('AI_PRODUCTION_PIPELINE.md', '06_Writing_Style_OS/WRITING_STYLE_OS.md')) {
        $selected = @($m.sources | Where-Object { $_.path -ceq $path })
        if ($selected.Count -ne 1) { throw "REQUIRED_QA_SOURCE_MISSING: $path" }
    }
    $style = @($m.sources | Where-Object { $_.path -ceq '06_Writing_Style_OS/WRITING_STYLE_OS.md' })[0]
    $head = Get-Content -LiteralPath (Join-Path $RepositoryRoot $style.path) -TotalCount 30
    if ((($head -join "`n").Replace('*','')) -notmatch '(?im)^\s*(?:>\s*)?Status:\s*.*\bCurrent\b') { throw 'WRITING_SOURCE_NOT_CURRENT' }
    $actualVersion = [regex]::Match(($head -join "`n"), '(?im)^.*Version:\s*(v\d+(?:\.\d+)*)').Groups[1].Value
    if (-not $actualVersion -or $actualVersion -cne $style.version_or_revision) { throw 'WRITING_SOURCE_VERSION_MISMATCH' }
    [ordered]@{ task_id = $m.task_id; manifest_sha256 = (Get-QAFileSha $ManifestPath); writing_source = [ordered]@{ path = $style.path; version = $actualVersion; sha256 = $style.file_sha256 } }
}

function New-PreHumanReview {
    param([string]$RepositoryRoot, [string]$DraftPath, [string]$ManifestPath, [string]$ProductionId, [string]$DraftId, [string]$ProductionVersion, [string]$RecordPath, [string]$ReviewPath, [string]$PreviousRecordPath, [string]$PreviousReviewPath, [string]$RevisionNote)
    foreach ($v in @($ProductionId, $DraftId, $ProductionVersion)) { if ([string]::IsNullOrWhiteSpace($v)) { throw 'IDENTITY_REQUIRED' } }
    if ((Test-Path -LiteralPath $RecordPath) -or (Test-Path -LiteralPath $ReviewPath)) { throw 'QA_RECORD_EXISTS_USE_NEW_REVISION' }
    $sources = Test-QASources $RepositoryRoot $ManifestPath $ProductionVersion
    $analysis = Get-ParagraphInspection $DraftPath
    $previous = $null
    if ($PreviousRecordPath) {
        $old = Read-QAJson $PreviousRecordPath ''
        if ($old.production_id -cne $ProductionId -or [string]::IsNullOrWhiteSpace($RevisionNote) -or [string]::IsNullOrWhiteSpace($PreviousReviewPath)) { throw 'REVISION_HISTORY_REQUIRED' }
        $oldReview = Read-QAJson $PreviousReviewPath ''
        if ($oldReview.record_sha256 -cne (Get-QAFileSha $PreviousRecordPath) -or $oldReview.draft_sha256 -cne $old.analysis.draft_sha256) { throw 'PREVIOUS_QA_EVIDENCE_MISMATCH' }
        if ($old.analysis.draft_sha256 -ceq $analysis.draft_sha256) { throw 'REVISION_MUST_IDENTIFY_CHANGED_BYTES' }
        $previous = [ordered]@{ record_sha256 = (Get-QAFileSha $PreviousRecordPath); review_sha256 = (Get-QAFileSha $PreviousReviewPath); draft_sha256 = $old.analysis.draft_sha256; note = $RevisionNote }
    } elseif ($RevisionNote -or $PreviousReviewPath) { throw 'PREVIOUS_RECORD_REQUIRED' }
    $record = [ordered]@{ schema_version = $script:Implementation; state = 'PRE_HUMAN_REVIEW_QA'; previous_state = 'PRODUCED_UNVERIFIED'; production_id = $ProductionId; draft_id = $DraftId; production_version = $ProductionVersion; frozen_at = [DateTimeOffset]::UtcNow.ToString('o'); source_resolution = $sources; implementation_sha256 = (Get-QAFileSha $PSCommandPath); analysis = $analysis; revision = $previous }
    Write-QANewJson $RecordPath $record
    $items = @()
    foreach ($p in $analysis.paragraphs) { $items += [ordered]@{ id = $p.id; decision = 'UNREVIEWED'; reason = '' } }
    foreach ($b in $analysis.boundaries) { $items += [ordered]@{ id = $b.id; decision = 'UNREVIEWED'; reason = '' } }
    foreach ($f in $analysis.findings) { $items += [ordered]@{ id = $f.id; decision = 'UNREVIEWED'; reason = '' } }
    $review = [ordered]@{ schema_version = $script:Implementation; record_sha256 = (Get-QAFileSha $RecordPath); draft_sha256 = $analysis.draft_sha256; reviewer = ''; reviewed_at = ''; phase = 'PRE_HUMAN_REVIEW_QA'; items = $items; checklist = @($script:Checks | ForEach-Object { [ordered]@{ id = $_; result = 'UNREVIEWED'; evidence_ids = @(); finding = '' } }) }
    Write-QANewJson $ReviewPath $review
    $record
}

function Test-PreHumanReview {
    param([string]$RepositoryRoot, [string]$DraftPath, [string]$ManifestPath, [string]$RecordPath, [string]$ReviewPath, [string]$PresentedPath, [string]$ProductionId, [string]$DraftId, [string]$ProductionVersion, [string]$Runtime = 'unknown')
    if ($Runtime -cne 'local-codex-file-bound') { throw 'BLOCKED_RUNTIME_BOUNDARY: unverified delivery adapter' }
    foreach ($v in @($ProductionId, $DraftId, $ProductionVersion)) { if ([string]::IsNullOrWhiteSpace($v)) { throw 'IDENTITY_REQUIRED' } }
    $record = Read-QAJson $RecordPath ''
    $review = Read-QAJson $ReviewPath (Join-Path $PSScriptRoot '../schemas/pre_human_review.schema.json')
    if ($record.schema_version -cne $script:Implementation -or $record.state -cne 'PRE_HUMAN_REVIEW_QA' -or $record.previous_state -cne 'PRODUCED_UNVERIFIED') { throw 'PRODUCTION_IS_NOT_QA' }
    if ($record.production_id -cne $ProductionId -or $record.draft_id -cne $DraftId -or $record.production_version -cne $ProductionVersion) { throw 'PRODUCTION_IDENTITY_MISMATCH' }
    if ($record.implementation_sha256 -cne (Get-QAFileSha $PSCommandPath)) { throw 'STALE_QA_IMPLEMENTATION' }
    $sources = Test-QASources $RepositoryRoot $ManifestPath $ProductionVersion
    if ((Get-QAObjectSha $record.source_resolution) -cne (Get-QAObjectSha $sources)) { throw 'STALE_SOURCE_RESOLUTION' }
    $analysis = Get-ParagraphInspection $DraftPath
    if ((Get-QAObjectSha $record.analysis) -cne (Get-QAObjectSha $analysis)) { throw 'DRAFT_OR_FINDINGS_CHANGED_REQA_REQUIRED' }
    if ($review.record_sha256 -cne (Get-QAFileSha $RecordPath) -or $review.draft_sha256 -cne $analysis.draft_sha256) { throw 'QA_EVIDENCE_VERSION_MISMATCH' }
    if ([string]::IsNullOrWhiteSpace($PresentedPath) -or (Get-QAFileSha $PresentedPath) -cne $analysis.draft_sha256) { throw 'PRESENTED_VERSION_MISMATCH' }
    if ([DateTimeOffset]::Parse($review.reviewed_at) -lt [DateTimeOffset]::Parse($record.frozen_at) -or [DateTimeOffset]::Parse($review.reviewed_at) -gt [DateTimeOffset]::UtcNow.AddMinutes(1)) { throw 'QA_MUST_FOLLOW_FREEZE' }
    if ([string]::IsNullOrWhiteSpace($review.reviewer)) { throw 'REVIEWER_REQUIRED' }
    $expected = @($analysis.paragraphs.id) + @($analysis.boundaries | ForEach-Object { $_.id }) + @($analysis.findings | ForEach-Object { $_.id })
    $ids = @($review.items | ForEach-Object { $_.id })
    if ($ids.Count -ne $expected.Count -or @($ids | Select-Object -Unique).Count -ne $expected.Count -or @($expected | Where-Object { $_ -cnotin $ids }).Count) { throw 'INCOMPLETE_PARAGRAPH_BOUNDARY_OR_FINDING_REVIEW' }
    $allowed = @('PUNCHLINE', 'SCENE_SHIFT', 'UNDERSTANDING_SHIFT', 'AFTERTASTE', 'STRONG_RETORT', 'INTENTIONAL_PAUSE', 'REQUIRED_STRUCTURE')
    foreach ($item in $review.items) {
        if ($item.decision -in @('UNREVIEWED', 'FAIL', 'MERGE_REQUIRED') -or $item.reason.Trim().Length -lt 12) { throw "STYLE_QA_FAIL: $($item.id)" }
        if ($item.id.StartsWith('P')) {
            $p = @($analysis.paragraphs | Where-Object { $_.id -ceq $item.id })[0]
            $inFlaggedRun = @($analysis.findings | Where-Object { $item.id -cin $_.paragraphs }).Count -gt 0
            if (($inFlaggedRun -or $p.structural_candidate) -and $item.decision -cnotin $allowed) { throw "SHORT_OR_STRUCTURAL_PARAGRAPH_NEEDS_REASON: $($item.id)" }
            if ($item.decision -cnotin (@('NATURAL_PARAGRAPH') + $allowed)) { throw 'INVALID_PARAGRAPH_DECISION' }
        } elseif ($item.id.StartsWith('B')) {
            if ($item.decision -cnotin (@('NATURAL_BREAK') + $allowed)) { throw 'INVALID_BOUNDARY_DECISION' }
        } else {
            if ($item.decision -cne 'JUSTIFIED_EXCEPTION') { throw "UNRESOLVED_STRUCTURAL_FINDING: $($item.id)" }
            $f = @($analysis.findings | Where-Object { $_.id -ceq $item.id })[0]
            foreach ($pid in $f.paragraphs) {
                if (@($review.items | Where-Object { $_.id -ceq $pid })[0].decision -cnotin $allowed) { throw 'RUN_EXCEPTION_WITHOUT_PARAGRAPH_EVIDENCE' }
            }
        }
    }
    $checkIds = @($review.checklist | ForEach-Object { $_.id })
    if ($checkIds.Count -ne $script:Checks.Count -or @($checkIds | Select-Object -Unique).Count -ne $script:Checks.Count -or @($script:Checks | Where-Object { $_ -cnotin $checkIds }).Count) { throw 'CHECKLIST_INCOMPLETE' }
    foreach ($check in $review.checklist) {
        if ($check.result -cne 'PASS' -or $check.finding.Trim().Length -lt 12 -or $check.evidence_ids.Count -lt 1 -or @($check.evidence_ids | Where-Object { $_ -cnotin $expected }).Count) { throw "CHECKLIST_FAIL: $($check.id)" }
    }
    [ordered]@{ schema_version = $script:Implementation; state = 'HUMAN_REVIEW_CANDIDATE'; final_qa = 'PASS'; production_id = $ProductionId; draft_id = $DraftId; production_version = $ProductionVersion; draft_sha256 = $analysis.draft_sha256; presented_sha256 = (Get-QAFileSha $PresentedPath); record_sha256 = (Get-QAFileSha $RecordPath); review_sha256 = (Get-QAFileSha $ReviewPath); source_resolution = $sources; runtime = $Runtime; control_scope = 'exported-file-bytes-only'; platform_enforced = $false; checked_at = [DateTimeOffset]::UtcNow.ToString('o') }
}

Export-ModuleMember -Function Get-ParagraphInspection, New-PreHumanReview, Test-PreHumanReview, Write-QANewJson, Get-QAFileSha
