---
name: pre-human-review-qa
description: Run separate exact-version Pre-Human Review QA before presenting Repository-governed longform drafts such as note, Story, Practice, Session Archive or AIDAILY bodies. Applies to new and revised Human Review candidates, not ordinary chat replies or visual assets.
---

# Pre-Human Review QA

Resolve Current Sources by responsibility root under `AI_PRODUCTION_PIPELINE.md`, including §8.5.1, the applicable media SOP, Writing Style OS and required dependencies. Read `04_AI_Work_Environment/Pre_Human_Review_QA/README.md` fully for the execution contract. Do not treat Source read or Production completion as QA.

1. Finish the exact body into a file in its authorized private artifact location. It is `PRODUCED_UNVERIFIED`, not a Human Review Candidate. Run the existing Source Manifest v2 validator for this task/version.
2. Run `Invoke-PreHumanReview.ps1 -Mode Prepare` to freeze that completed file and create unreviewed inspection/review records. Then separately reread the whole body against Current Writing Style OS and the media/G4 criteria. Inspect every P/B/F, especially tail pacing and same-topic splits; fill specific reasons, relevant checklist references and actual reviewer/timestamp. Do not mass-fill PASS or fabricate exception labels.
3. If any check fails, preserve the failed record, fix only authorized differences, use new record/review paths with the previous record and revision reason, resolve the new version's manifest, and rerun whole-body QA. Never edit a PASS to match changed body bytes.
4. Run `Export`, then `Verify` against the actual exported file immediately before presenting. Present that file link plus its Production/Draft ID and SHA, not a regenerated inline body. Only a successful computed receipt permits `HUMAN_REVIEW_CANDIDATE`. Downstream handoffs must rerun Verify on received bytes; saved status alone is insufficient.

If script execution or exact-file delivery is unavailable, report `BLOCKED_RUNTIME_BOUNDARY`, keep the draft unverified and hand it to Local Codex. This Skill cannot intercept arbitrary Chat output. Do not claim platform-wide enforcement. Do not modify Visual controls, Header approvals, Marketing or Publication Decisions while performing body QA. Keep private drafts/reviews out of Public Git.
