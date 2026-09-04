$module = Join-Path $PSScriptRoot '../scripts/PreHumanReview.psm1'
$entry = Join-Path $PSScriptRoot '../scripts/Invoke-PreHumanReview.ps1'
Import-Module $module -Force

function Save-TestJson($path, $value) { $value | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $path -Encoding utf8 -NoNewline }
function Complete-TestReview {
    $record = Get-Content $recordPath -Raw | ConvertFrom-Json -AsHashtable
    $review = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
    $review.reviewer = 'synthetic-test-reviewer'
    $review.reviewed_at = [DateTimeOffset]::UtcNow.ToString('o')
    foreach ($item in $review.items) {
        $item.decision = if ($item.id.StartsWith('P')) { 'NATURAL_PARAGRAPH' } elseif ($item.id.StartsWith('B')) { 'NATURAL_BREAK' } else { 'FAIL' }
        $item.reason = "Synthetic evidence for $($item.id): same event stays together; next topic begins at its boundary."
    }
    foreach ($c in $review.checklist) { $c.result = 'PASS'; $c.evidence_ids = @('P1'); $c.finding = "Synthetic $($c.id): fully read test content, no unresolved issue in P1." }
    Save-TestJson $reviewPath $review
}
function Test-QAThrows([scriptblock]$Action, [string]$Expected = '') {
    try { & $Action | Out-Null; return $false } catch { return (-not $Expected -or $_.Exception.Message.Contains($Expected)) }
}
function Prepare-TestDraft {
    New-PreHumanReview @qaArgs | Out-Null
}
function Verify-TestDraft {
    Test-PreHumanReview @qaArgs -PresentedPath $draftPath -Runtime 'local-codex-file-bound'
}

Describe 'Exact-version Pre-Human Review Gate' {
    BeforeEach {
        $caseRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $caseRoot | Out-Null
        $repo = Join-Path $caseRoot 'repo'
        $sourceDir = Join-Path $repo '04_AI_Work_Environment/Source_Resolution'
        New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
        Copy-Item -Path (Join-Path $PSScriptRoot '../../Source_Resolution/*') -Destination $sourceDir -Recurse -Force
        New-Item -ItemType Directory -Path (Join-Path $repo '06_Writing_Style_OS') -Force | Out-Null
        $paths = @('AI_PRODUCTION_PIPELINE.md', '06_Writing_Style_OS/WRITING_STYLE_OS.md')
        foreach ($path in $paths) { "# Test Source`n`n> Status: Current / Operational v1.1`n> Version: v1.1`n`nSynthetic source." | Set-Content -LiteralPath (Join-Path $repo $path) -Encoding utf8 }
        $manifestPath = Join-Path $caseRoot 'manifest.json'
        $manifest = @{
            schema_version = 'source-manifest/v2'; task_id = 'TEST'; production_version = 'D1'
            repository = @{ resolved_commit_sha = ('a' * 40); resolved_at = '2026-09-04T00:00:00Z' }
            resolution = @{ method = 'responsibility-root-discovery'; responsibility_roots = @('06_Writing_Style_OS'); discovered_candidates = @($paths | ForEach-Object { @{ path = $_; decision = 'selected' } }) }
            sources = @($paths | ForEach-Object { @{ path = $_; responsibility = 'Test'; required = 'required'; status = 'Current'; version_or_revision = 'v1.1'; file_sha256 = (Get-QAFileSha (Join-Path $repo $_)); read_by = 'test'; read_at = '2026-09-04T00:01:00Z'; read_task_id = 'TEST'; read_scope = 'full'; applied_to = @('test'); dependencies = @(); dependency_check = 'PASS'; conflict_check = 'PASS' } })
            g2 = @{ resolution_complete = $true; current_canonical_unique = $true; dependency_closure_complete = $true; same_task_read_complete = $true; source_fingerprint_frozen = $true; result = 'PASS'; passed_at = '2026-09-04T00:02:00Z' }
        }
        Save-TestJson $manifestPath $manifest
        $draftPath = Join-Path $caseRoot 'draft.md'
        # Synthetic, not an unpublished AIDAILY body. Content preserved across A/B.
        $sentences = @('朝は机で道具の配置を確かめながら今日の作業を始めた。', 'だから最初に必要なものをそろえて使う順番も一緒に確認した。', 'そんで実際に試してみると作業が続けやすくなった。', '同じ場所で一連の確認を終えて次の予定に移ることにした。')
        ($sentences -join '') | Set-Content -LiteralPath $draftPath -Encoding utf8 -NoNewline
        $recordPath = Join-Path $caseRoot 'record.json'; $reviewPath = Join-Path $caseRoot 'review.json'
        $qaArgs = @{ RepositoryRoot = $repo; DraftPath = $draftPath; ManifestPath = $manifestPath; ProductionId = 'TEST'; DraftId = 'BODY'; ProductionVersion = 'D1'; RecordPath = $recordPath; ReviewPath = $reviewPath }
    }
    It 'A: stacked same-event short paragraphs cannot pass without resolving findings' {
        ($sentences -join "`n`n") | Set-Content $draftPath -NoNewline
        Prepare-TestDraft; Complete-TestReview
        @( (Get-ParagraphInspection $draftPath).findings ).Count | Should Be 2
        (Test-QAThrows { Verify-TestDraft } 'SHORT_OR_STRUCTURAL_PARAGRAPH_NEEDS_REASON') | Should Be $true
    }
    It 'B: identical sentences joined into a natural paragraph can PASS separate QA' {
        Prepare-TestDraft; Complete-TestReview
        (Verify-TestDraft).final_qa | Should Be 'PASS'
    }
    It 'C: editing bytes after PASS invalidates evidence even with same version label' {
        Prepare-TestDraft; Complete-TestReview; Verify-TestDraft | Out-Null
        Add-Content $draftPath '追記。'
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'D: Production alone cannot create a Human Review Candidate' {
        Prepare-TestDraft
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'E: presented body mismatch fails' {
        Prepare-TestDraft; Complete-TestReview
        $other = Join-Path $caseRoot 'other.md'; '別の本文。' | Set-Content $other
        (Test-QAThrows { Test-PreHumanReview @qaArgs -PresentedPath $other -Runtime 'local-codex-file-bound' }) | Should Be $true
    }
    It 'requires a presented file, not a version label' {
        Prepare-TestDraft; Complete-TestReview
        (Test-QAThrows { Test-PreHumanReview @qaArgs -Runtime 'local-codex-file-bound' }) | Should Be $true
    }
    It 'fails stale canonical source' {
        Prepare-TestDraft; Complete-TestReview
        Add-Content (Join-Path $repo $paths[1]) 'Changed Source'
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'fails Current writing version identity mismatch' {
        $manifest.sources[1].version_or_revision = 'v1.0'; Save-TestJson $manifestPath $manifest
        (Test-QAThrows { Prepare-TestDraft }) | Should Be $true
    }
    It 'fails missing G2 instead of treating Source read as output QA' {
        $manifest.g2.result = 'FAIL'; Save-TestJson $manifestPath $manifest
        (Test-QAThrows { Prepare-TestDraft }) | Should Be $true
    }
    It 'fails omitted checklist and duplicate checklist entries' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        $r.checklist[1] = $r.checklist[0]; Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'fails semantic merge-required even without structural run detection' {
        ($sentences[0..1] -join '') + "`n`n" + ($sentences[2..3] -join '') | Set-Content $draftPath -NoNewline
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        ($r.items | Where-Object id -eq 'B1-2').decision = 'MERGE_REQUIRED'; Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'fails missing paragraph/boundary review and blanket PASS' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        $r.items = @(); Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'detects hard breaks and tail card stacking' {
        ($sentences -join "  `n") | Set-Content $draftPath -NoNewline
        $a = Get-ParagraphInspection $draftPath
        $a.paragraphs.Count | Should Be 4
        $a.findings[0].tail | Should Be $true
    }
    It 'allows a deliberately evidenced final punchline' {
        Add-Content $draftPath "`n`nところが、道具箱だけがなかった。"
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        foreach ($i in $r.items | Where-Object { $_.id -in @('P2', 'B1-2') }) { $i.decision = 'PUNCHLINE'; $i.reason = 'P1で準備完了と思わせたあと、P2で道具箱不在へ反転する一回のオチ。' }
        Save-TestJson $reviewPath $r
        (Verify-TestDraft).final_qa | Should Be 'PASS'
    }
    It 'allows evidence-backed safety checklist structure, not automatic exemption' {
        '- 手順の前に電源を切る。' + "`n`n" + '- 安全を確認してから触る。' | Set-Content $draftPath -NoNewline
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        foreach ($i in $r.items) { $i.decision = 'REQUIRED_STRUCTURE'; $i.reason = "安全確認手順を独立に確認するリストで、$($i.id)は見落とし防止に必要。" }
        Save-TestJson $reviewPath $r
        (Verify-TestDraft).final_qa | Should Be 'PASS'
    }
    It 'does not accept unmeasured Chat or Work platform enforcement' {
        Prepare-TestDraft; Complete-TestReview
        foreach ($runtime in @('unknown', 'chat', 'work', 'platform-enforced')) { (Test-QAThrows { Test-PreHumanReview @qaArgs -PresentedPath $draftPath -Runtime $runtime }) | Should Be $true }
    }
    It 'rejects self-declared overall PASS field' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        $r.final_qa = 'PASS'; Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'requires QA timestamp after frozen output' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        $r.reviewed_at = '2000-01-01T00:00:00Z'; Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft }) | Should Be $true
    }
    It 'revision starts unverified and preserves previous draft provenance' {
        Prepare-TestDraft; Complete-TestReview
        $oldSha = Get-QAFileSha $draftPath
        Add-Content $draftPath 'さらに道具箱を確認した。'
        $next = $qaArgs.Clone(); $next.RecordPath = Join-Path $caseRoot 'r2.json'; $next.ReviewPath = Join-Path $caseRoot 'q2.json'
        $r2 = New-PreHumanReview @next -PreviousRecordPath $recordPath -PreviousReviewPath $reviewPath -RevisionNote 'Added tool-box check; whole exact body requires fresh QA.'
        $r2.revision.draft_sha256 | Should Be $oldSha
        $r2.revision.review_sha256 | Should Be (Get-QAFileSha $reviewPath)
        (Test-QAThrows { Test-PreHumanReview @next -PresentedPath $draftPath -Runtime 'local-codex-file-bound' }) | Should Be $true
    }
    It 'exports byte-identical candidate only after PASS; never overwrites it' {
        Prepare-TestDraft; Complete-TestReview
        $out = Join-Path $caseRoot 'candidate'
        & $entry -Mode Export @qaArgs -OutputDirectory $out -Runtime 'local-codex-file-bound' | Out-Null
        (Get-QAFileSha (Join-Path $out 'candidate.md')) | Should Be (Get-QAFileSha $draftPath)
        (Get-Content (Join-Path $out 'receipt.json') -Raw | ConvertFrom-Json).platform_enforced | Should Be $false
        (Test-QAThrows { & $entry -Mode Export @qaArgs -OutputDirectory $out -Runtime 'local-codex-file-bound' }) | Should Be $true
    }
    It 'cannot export an unreviewed body even when Production is complete' {
        Prepare-TestDraft
        $out = Join-Path $caseRoot 'must-not-exist'
        (Test-QAThrows { & $entry -Mode Export @qaArgs -OutputDirectory $out -Runtime 'local-codex-file-bound' }) | Should Be $true
        (Test-Path $out) | Should Be $false
    }
    It 'cannot erase findings from a frozen record' {
        ($sentences -join "`n`n") | Set-Content $draftPath -NoNewline
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $recordPath -Raw | ConvertFrom-Json -AsHashtable
        $r.analysis.findings = @(); Save-TestJson $recordPath $r
        (Test-QAThrows { Verify-TestDraft } 'DRAFT_OR_FINDINGS_CHANGED_REQA_REQUIRED') | Should Be $true
    }
    It 'fails wrong production identity independently of body equality' {
        Prepare-TestDraft; Complete-TestReview
        $qaArgs.DraftId = 'OTHER'
        (Test-QAThrows { Verify-TestDraft } 'PRODUCTION_IDENTITY_MISMATCH') | Should Be $true
    }
    It 'fails forged Production-to-Candidate state' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $recordPath -Raw | ConvertFrom-Json -AsHashtable
        $r.state = 'HUMAN_REVIEW_CANDIDATE'; Save-TestJson $recordPath $r
        (Test-QAThrows { Verify-TestDraft } 'PRODUCTION_IS_NOT_QA') | Should Be $true
    }
    It 'fails review linked to another frozen record' {
        Prepare-TestDraft; Complete-TestReview
        $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
        $r.record_sha256 = '0' * 64; Save-TestJson $reviewPath $r
        (Test-QAThrows { Verify-TestDraft } 'QA_EVIDENCE_VERSION_MISMATCH') | Should Be $true
    }
    It 'allows an evidenced scene shift, understanding shift or aftertaste' {
        Add-Content $draftPath "`n`n夕方になった。"
        Prepare-TestDraft; Complete-TestReview
        foreach ($role in @('SCENE_SHIFT','UNDERSTANDING_SHIFT','AFTERTASTE')) {
            $r = Get-Content $reviewPath -Raw | ConvertFrom-Json -AsHashtable
            foreach ($i in $r.items | Where-Object { $_.id -in @('P2','B1-2') }) { $i.decision=$role; $i.reason="Synthetic $role at P2 after P1; tests permitted enum routing, not a real semantic finding." }
            Save-TestJson $reviewPath $r
            (Verify-TestDraft).final_qa | Should Be 'PASS'
        }
    }
    It 'handles HTML hard breaks without granting zero-finding PASS' {
        ($sentences -join '<br>') | Set-Content $draftPath -NoNewline
        (Get-ParagraphInspection $draftPath).findings.Count | Should Be 2
    }
    It 'does not ban an isolated natural one-sentence paragraph' {
        '朝の作業を終えてから道具を元の位置に戻した。' | Set-Content $draftPath -NoNewline
        Prepare-TestDraft; Complete-TestReview
        (Verify-TestDraft).final_qa | Should Be 'PASS'
    }
}
