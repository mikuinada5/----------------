---
name: visual-production-bridge
description: Run governed Repository visual or image generation, including note headers, AIDAILY headers, SNS images, educational visuals, or any request that must follow Visual Production Control. Do not use for casual image generation outside this Repository or for read-only visual review.
---

# Visual Production Bridge

Use this Skill only in Local Codex with Repository filesystem access, PowerShell execution, an image generation tool, and an image inspection tool available in the current session. This Skill is a request-bound Repository bridge, not platform-wide interception of ChatGPT image generation.

1. Resolve and read Current canonical Sources under `AI_PRODUCTION_PIPELINE.md` and `04_AI_Work_Environment/Source_Resolution/`. Create a task/version-specific Source Manifest v2 and run `Test-SourceResolution.ps1`. Stop on any FAIL.
2. For a registered machine-readable profile, run `04_AI_Work_Environment/Visual_Production/scripts/New-VisualGenerationRecord.ps1`. Do not manually recreate or paraphrase canonical MUST/MUST_NOT requirements. For AIDAILY headers use profile `aidaily-header-v1` from `07_Note_Production/00_note制作・公開システム.md`, discover the configured OneDrive AI root without hard-coding a Windows username, and pass the profile's exact `NOTE-HEADER-MASTER-v1.0` file through `-MasterAssetPath`. Stop if the Master is unreachable, ambiguous, or fails its canonical SHA-256.
3. Export only the generated record's `tool_request` object to the actual-request JSON. Do not edit its prompt, title, dimensions, referenced image paths, included IDs, or negative IDs.
4. Run `New-VisualRuntimeReceipt.ps1` with environment `local-codex`, the exact actual-request JSON, and evidence that the current session exposes both image generation and asset inspection. It must return `REQUEST_BOUND` and `Test-VisualRuntimeReceipt.ps1` must PASS.
5. Pass the exact validated `tool_request.prompt` and every exact `tool_request.referenced_image_paths` entry to the image generation tool. Do not add surrounding creative instructions or substitute a visually similar image at invocation time. If the tool API cannot preserve that request and its Master reference, stop with `REQUEST_MISMATCH` before generation.
6. Record the returned locator/provenance and set the asset state to `GENERATED_UNVERIFIED`. Inspect the actual generated image with the available image inspection tool.
7. Complete every mandatory requirement check and dimensions check in the Visual Production Record. On QA FAIL, keep the output Rejected / non-asset and follow the bounded retry rule. Never present it as a normal Human Review Candidate.
8. Run `Test-VisualProduction.ps1` again. Only an Asset QA PASS record may transition to `HUMAN_REVIEW_CANDIDATE`.

If the current environment is Chat or Work using built-in image generation, or if Repository scripts/request binding/inspection are unavailable, run or report the `BLOCKED_PLATFORM_BOUNDARY` capability result. Do not claim the Repository directly intercepted the platform tool. Hand the Production Intent to Local Codex instead.

Keep runtime records and generated binaries outside the Public Repository unless an existing responsibility Source explicitly assigns a durable destination. Never commit rejected images, private source text, credentials, or conversation transcripts.
