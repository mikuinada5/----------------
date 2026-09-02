# Visual Production Control

**Status:** Current / Operational v1.1 / Runtime Bridge<br>
**Owner:** Production / Internal QA<br>
**Authority:** `AI_PRODUCTION_PIPELINE.md` Visual Production Control

## Purpose

画像生成を、依頼文や会話の勢いだけで起動する単発操作ではなく、次の順序を持つ検証可能なProductionとして扱う。

```text
Phase Tool Routing
→ Resolved Visual Sources
→ Generation Contract
→ Machine-built Actual Tool Request
→ Prompt Assembly QA
→ Runtime Capability / Request Binding
→ Generated Asset（QA未確認）
→ Asset QA
→ Human Review Candidate
```

本ディレクトリは、新しいVisual専門Source、媒体Template、AI組織上の役割または承認者を作らない。共通Gateの規範は`AI_PRODUCTION_PIPELINE.md`、媒体・成果物固有の要件はnote、SNS、Brand、Education／Material Productionその他の責任Sourceを正とする。ここにはSchema、contract／request builder、fail-closed validatorおよび回帰テストだけを置く。

## Runtime contract

1. Work Charterの`phase`と`artifact_type`から、画像生成Toolを使用できるProductionか判定する。Marketing Review、Source QA、通常の文章QA、Human Review、G5およびPublishでは画像生成を起動しない。
2. G2 PASS済みSource Manifestから、媒体・成果物固有のVisual要件を`MUST`、`MUST_NOT`、`MAY`へ分け、Generation Contractへ固定する。
3. Creative Directionは`MAY`の範囲だけで使用する。`MUST`または`MUST_NOT`と競合する指示は削除し、競合を残したContractを生成へ渡さない。
4. 実際に画像生成Toolへ渡すRequestに、承認済み文字列、全`MUST`、全`MUST_NOT`、寸法および禁止要素が含まれることをPrompt Assembly QAで確認する。
5. Source file SHA-256、Production versionまたは承認済み文字列が変わったContractはstaleとして破棄し、Source Resolutionから再構築する。
6. 生成物は`GENERATED_UNVERIFIED`で受け取り、Asset QAがPASSするまでHuman Review Candidate、Asset Ready、G5 Packageまたは公開候補へ昇格しない。
7. AIが画像を検査できない場合は`HUMAN_ASSET_QA`へ限定して渡す。これは通常のHuman Review Candidateではなく、QA未確認Assetの検査依頼であり、承認・G5・Asset Readyを意味しない。
8. QA FAILで既存Sourceから一意に修正でき、Contractの上限内なら再生成する。既定は初回後2回まで。上限到達、Source矛盾、新しい価値判断またはTool不適合ではSTOPする。
9. 画像生成直前にRuntime Receiptを作り、環境Capability、Bridge implementationおよびvalidated request／actual request SHA-256完全一致を検証する。
10. 現行で許可するRuntimeはLocal CodexのRepository Skill request-bound経路だけである。Chat／Work built-in directおよび未実装Responses API orchestratorは`BLOCKED_PLATFORM_BOUNDARY`とする。

## Runtime boundary

この実装が直接拘束できるのは、Local Codex Skillが同一Task内で組み立て、照合し、実Toolへ渡すclient-visible requestである。標準Chat／Workのbuilt-in image generationへのRepository側interception、tool availabilityの無効化またはplatform-wide enforcementは実装していない。その境界を`platform_enforced: true`として記録するとvalidatorがFAILする。

安全な現行経路は次のとおりとする。

```text
Chat / Work Production Intent
→ Local Codex $visual-production-bridge
→ Source Manifest v2 PASS
→ canonical profileからGeneration Record生成
→ actual request export
→ Runtime Receipt REQUEST_BOUND
→ image generation
→ GENERATED_UNVERIFIED
→ visual inspection / Asset QA
→ Visual Production validator PASS
→ Human Review Candidate
```

## Command

```powershell
pwsh -File 04_AI_Work_Environment/Visual_Production/scripts/New-VisualGenerationRecord.ps1 `
  -RepositoryRoot . `
  -SourceManifestPath <source-manifest.json> `
  -ProfileSourcePath <canonical-profile-source.md> `
  -ProfileId <profile-id> `
  -TaskId <task-id> -ProductionVersion <version> `
  -Phase 'Header Production' -ArtifactType <type> `
  -ApprovedTitle <exact-title> -Width 1280 -Height 670 `
  -OutputPath <visual-production-record.json>

pwsh -File 04_AI_Work_Environment/Visual_Production/scripts/Test-VisualProduction.ps1 `
  -RepositoryRoot . `
  -RecordPath <visual-production-record.json>

pwsh -File 04_AI_Work_Environment/Visual_Production/scripts/New-VisualRuntimeReceipt.ps1 `
  -RepositoryRoot . `
  -RecordPath <visual-production-record.json> `
  -Environment local-codex `
  -ActualToolRequestPath <actual-tool-request.json> `
  -ImageGenerationToolEvidence <current-session-evidence> `
  -AssetInspectionEvidence <current-session-evidence> `
  -OutputPath <visual-runtime-receipt.json>
```

PASSしたRecordだけをHuman Review Candidate、Asset ReadyまたはG5へ接続できる。

## Privacy and storage

RecordにはSource locator、hash、要件ID、Tool Request、QA結果およびAsset provenanceだけを記録する。非公開本文、不要な個人情報、会話全文、生成画像binaryまたはcredentialをPublic Repositoryへ自動保存しない。Asset本体の着地点は媒体別Sourceと承認済みArchive規則を正とする。
