# Exact-version Pre-Human Review QA

**Status:** Current / Operational v1.0<br>
**Owner:** Existing Internal QA / Output QA<br>
**Authority:** `AI_PRODUCTION_PIPELINE.md` §8.5.1; style semantics remain in Current Writing Style OS

## Execution contract

This is G4 implementation, not another Writing OS. Production produces an unverified file. `Prepare` freezes its bytes and Source Manifest v2, calculates paragraph/boundary/structural findings, and creates an **unreviewed** checklist. It does not PASS the body. A subsequent Internal QA read of the whole finished file supplies the separate review. `Verify` recomputes everything; `Export` writes only the validated bytes with a computed PASS receipt. No overall PASS input is accepted.

Prerequisite: PowerShell 7.4+, Repository scripts, local filesystem. Use the Repository `pre-human-review-qa` Skill. Source Router must first discover/read responsibility roots and produce the same-task manifest, including Pipeline, Writing Style OS and all applicable media/Voice/Brand dependencies. The machine enforces the two common QA Sources; it does not infer the entire task-specific Source Plan.

```powershell
$qa = '04_AI_Work_Environment/Pre_Human_Review_QA/scripts/Invoke-PreHumanReview.ps1'
# Set all paths to the task's authorized private/durable location, not this directory.
& $qa -Mode Prepare -RepositoryRoot . -DraftPath $draft -ManifestPath $manifest -ProductionId $productionId -DraftId $draftId -ProductionVersion $version -RecordPath $record -ReviewPath $review
# Read the exact completed draft + inspection; complete review separately. Then:
& $qa -Mode Export -RepositoryRoot . -DraftPath $draft -ManifestPath $manifest -ProductionId $productionId -DraftId $draftId -ProductionVersion $version -RecordPath $record -ReviewPath $review -Runtime local-codex-file-bound -OutputDirectory $newOutputDirectory
# Immediately before presentation and again at downstream receipt:
& $qa -Mode Verify -RepositoryRoot . -DraftPath $draft -ManifestPath $manifest -ProductionId $productionId -DraftId $draftId -ProductionVersion $version -RecordPath $record -ReviewPath $review -Runtime local-codex-file-bound -PresentedPath $candidateFile
```

Present the validated file, not an AI-recreated inline body. Keep the record, completed review, exported file and receipt together; downstream Human Review/Marketing/G5 must rerun `Verify`, not trust the saved receipt alone. A candidate is valid only for its checked bytes and Sources at consumption. No receipt, failed validation or unknown runtime means FAIL, not a conditional Candidate.

## Separate semantic review

`Prepare` assigns P IDs to all blocks, B IDs to every neighboring boundary, and F IDs to flagged runs. Read actual text by those ordered IDs, including the tail; hashes/counts do not replace reading. Review every P/B/F with a concrete local reason and every checklist item with relevant IDs and findings. The review schema intentionally rejects unfinished templates. Set `reviewer` and an actual ISO timestamp after `frozen_at`.

- P: `NATURAL_PARAGRAPH`, or a justified `PUNCHLINE`, `SCENE_SHIFT`, `UNDERSTANDING_SHIFT`, `AFTERTASTE`, `STRONG_RETORT`, `INTENTIONAL_PAUSE`, `REQUIRED_STRUCTURE`. Paragraphs in flagged runs and structural candidates require a specific permitted reason, not a blanket PASS. An isolated single-sentence paragraph may be natural; sentence count alone does not forbid it.
- B: `NATURAL_BREAK` or one of those justified reasons; same-event/topic/emotion/retort+explanation splits needing connection are `MERGE_REQUIRED`.
- F: `FAIL` unless every involved paragraph has a permitted intentional role and the run as a whole has a concrete `JUSTIFIED_EXCEPTION`. A collection of fabricated punchline labels is not semantic QA.
- Each of eleven checks needs `PASS` plus actual findings and valid P/B/F references. Style checks are joined with existing G4 Purpose/Source, Voice/Brand, safety/accuracy and format/traceability; style-only success cannot bypass those checks.

The detector uses >=3 consecutive single-sentence blocks or <=80-character blocks as **triage**, not new stylistic prohibitions. It handles blank lines, Markdown hard breaks and HTML br; records soft line breaks for review. Headings/lists/code-shaped text are not automatic exemptions. Semantic-only splits with no machine flag still FAIL when boundary/checklist review detects them. Thresholds cannot prove literary quality; a truthful, full separate review is required. The tool validates evidence completeness and identity, not whether an AI's prose explanation is truthful.

For FAIL, retain the original record and failed review, fix only authorized content, use new paths plus `-PreviousRecordPath`, `-PreviousReviewPath` and `-RevisionNote`, re-resolve G2 for the new Production version, and repeat whole-body QA. The revision binds both previous QA files and the old body SHA. Never relabel the same old PASS or remove a finding. Even newline-only changes invalidate byte binding. Do not automatically rewrite the body or invalidate unrelated Header approvals.

## Boundary, privacy and tests

Verified adapter: Local Codex, `local-codex-file-bound`; receipt scope `exported-file-bytes-only`, `platform_enforced: false`. Chat/Work free-text sending cannot be intercepted here. Without validated script execution and byte-identical file delivery, return `BLOCKED_RUNTIME_BOUNDARY` and hand the exact draft to Local Codex. Repository protocol rejects bypassed drafts downstream; this is not universal platform enforcement or an adversarial signature system.

Unpublished bodies, paragraph reasons and reviews may contain private text. Keep them in the artifact's approved private location (existing Personal Archive Derived where applicable). Public tests are synthetic; do not commit incident transcripts. `Inspect` is read-only triage and always returns `UNREVIEWED`, never a QA PASS.

```powershell
Invoke-Pester 04_AI_Work_Environment/Pre_Human_Review_QA/tests/PreHumanReview.Tests.ps1
```

Negative assertions use explicit try/catch because bundled Pester 3.4's `Should Throw` is unreliable in this PowerShell runtime. Real incident provenance and local regression outcome are recorded in the existing CHANGELOG, not a parallel Source.
