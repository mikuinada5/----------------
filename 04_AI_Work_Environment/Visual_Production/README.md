# Visual Production Control

**Status:** Current / Operational v1.6 / Post-generation Normalization<br>
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
→ Human Approval
→ Formal Asset Promotion
```

本ディレクトリは、新しいVisual専門Source、媒体Template、AI組織上の役割または承認者を作らない。共通Gateの規範は`AI_PRODUCTION_PIPELINE.md`、媒体・成果物固有の要件はnote、SNS、Brand、Education／Material Productionその他の責任Sourceを正とする。ここにはSchema、contract／request builder、fail-closed validatorおよび回帰テストだけを置く。

AIDAILY note HeaderのCanonical Master binaryとmanifestは`assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png`および同名JSONに置く。ResolverはRepository rootからこの実体を解決し、manifest、Asset ID、Version、SHA-256、1280×670、provenanceおよびVisual specificationを照合する。OneDriveの既存copyは由来Evidenceであり、Production prerequisiteではない。Repository外の同一bytesを`-MasterAssetPath`で渡しても正式Masterとして受理しない。

## Runtime contract

1. Work Charterの`phase`と`artifact_type`から、画像生成Toolを使用できるProductionか判定する。Marketing Review、Source QA、通常の文章QA、Human Review、G5およびPublishでは画像生成を起動しない。
2. G2 PASS済みSource Manifestから、媒体・成果物固有のVisual要件を`MUST`、`MUST_NOT`、`MAY`へ分け、Generation Contractへ固定する。
3. canonical profileがMaster／reference Assetを要求する場合、profile内のAsset ID、Version、Repository／manifest locatorおよびSHA-256と、Repository内の実在file・manifestを照合する。未到達、SHA不一致、Repository外binaryまたはactual requestへのreference欠落はFAILとし、OneDriveやreferenceなし生成へfallbackしない。
4. Creative Directionは`MAY`の範囲だけで使用する。`MUST`または`MUST_NOT`と競合する指示は削除し、競合を残したContractを生成へ渡さない。
5. 実際に画像生成Toolへ渡すRequestに、承認済み文字列、全`MUST`、全`MUST_NOT`、必須reference、寸法および禁止要素が含まれることをPrompt Assembly QAで確認する。
6. Source file SHA-256、Production versionまたは承認済み文字列が変わったContractはstaleとして破棄し、Source Resolutionから再構築する。
7. native生成物は改変しないRaw Assetとして`RAW_GENERATED_UNVERIFIED`で受け取り、locator、SHA、実測寸法およびTool eventへbindingする。Raw寸法が1280×670でないことだけでは生成Request不一致としない。
8. AIが画像を検査できない場合は`HUMAN_ASSET_QA`へ限定して渡す。これは通常のHuman Review Candidateではなく、QA未確認Assetの検査依頼であり、承認・G5・Asset Readyを意味しない。
9. QA FAILで既存Sourceから一意に修正でき、Contractの上限内なら再生成する。既定は初回後2回まで。上限到達、Source矛盾、新しい価値判断またはTool不適合ではSTOPする。
10. 画像生成直前にRuntime Receiptを作り、環境Capability、Bridge implementationおよびvalidated request／actual request SHA-256完全一致を検証する。
11. 許可するRuntimeはLocal CodexのRepository Skill経路と、Repository checkout、Node.js、組み込み`image_gen.imagegen`、画像検査Toolを同一Taskで利用できる`cloud-work`経路である。通常Chat／Workのdirect生成、Tool eventを取得できないCloud環境および未実装Responses API orchestratorは`BLOCKED_PLATFORM_BOUNDARY`とする。
12. `cloud-work`は`source-resolution.mjs`と`cloud-work-header-bridge.mjs`でSource、Master、Contract、exact Tool arguments、current-task Tool eventおよびRaw Asset bytesを照合する。環境を`local-codex`と記録せず、implementation IDを`repo-skill:visual-production-bridge/cloud-work-v2`へ固定する。
13. Raw Assetは`repository-node-png-normalizer` v1.0.0で、center-crop cover、固定小数点bilinear、RGBA8／filter-none／zlib-fixedの決定論的方式により1280×670の別PNGへ変換する。Rawを上書きせず、input／output SHA・寸法、crop、tool／version／method、upstream Tool event SHA、実行event／timestampを`header-asset-normalization/v1`へ記録する。
14. `view_image`等のAsset QA、Human Review CandidateおよびHuman ApprovalはNormalized Assetへbindingし、同時にRaw SHAとNormalization identityを保持する。Cloudの`promote`は全chainを再検証し、全一致時だけ`FORMAL_HEADER_ASSET`とする。Raw Asset、任意のresize結果または旧Approvalを直接昇格しない。

## Runtime boundary

この実装が拘束するのは、同一Task内で組み立てたclient-visible requestと、Cloud Workのcurrent-task native Tool eventへ記録された実引数である。Repositoryはplatform-wideのtool routingをinterceptせず、署名付きPlatform receiptも主張しない。`platform_enforced: true`、`agent-self-report`、Tool event欠落、別Task eventまたは実引数不一致はFAILする。

安全な現行経路は次のとおりとする。

```text
Cloud Work Production Intent
→ Repository checkout / source-resolution.mjs
→ Source Manifest v2 PASS
→ canonical profileからGeneration Record生成
→ exact imagegen-arguments.json export
→ image_gen.imagegenへexact prompt＋Repository Masterを渡す
→ current-task Tool event＋Runtime Receipt REQUEST_BOUND
→ RAW_GENERATED_UNVERIFIED
→ deterministic Post-generation Normalization
→ NORMALIZED_UNVERIFIED
→ Normalized Assetをview_image等でcurrent-task visual inspection / Asset QA
→ Visual Production validator PASS
→ Human Review Candidate
→ Human Approval Evidence
→ Formal Header Asset Promotion PASS
→ cross-platform Final Review Package Compiler
```

Local Codexの既存`repository-skill-request-bound`経路も引き続き有効である。通常Chat、Repository shellのないWork、event evidenceを保存できない組み込み生成およびBridge外の直接生成は`UNVERIFIED_NON_ASSET`のままFormal Promotionへ進めない。

## Command

```powershell
pwsh -File 04_AI_Work_Environment/Visual_Production/scripts/New-VisualGenerationRecord.ps1 `
  -RepositoryRoot . `
  -SourceManifestPath <source-manifest.json> `
  -ProfileSourcePath <canonical-profile-source.md> `
  -ProfileId <profile-id> `
  -TaskId <task-id> -ArticleId <article-id> -ProductionVersion <version> `
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

pwsh -File 04_AI_Work_Environment/Visual_Production/scripts/New-FormalHeaderAsset.ps1 `
  -RepositoryRoot . `
  -VisualRecordPath <visual-production-record.json> `
  -RuntimeReceiptPath <visual-runtime-receipt.json> `
  -ActualToolRequestPath <actual-tool-request.json> `
  -GeneratedAssetPath <header.png> `
  -AssetCanonicalPointer <archive-or-private-pointer> `
  -HumanApprovalPath <header-human-approval.json> `
  -ProfileSourcePath <canonical-profile-source.md> `
  -OutputPath <formal-header-asset.json>
```

PASSしたGeneration RecordだけをHuman Review Candidateへ提示できる。note Final Review Packageへ接続できるのは、さらにHuman ApprovalとFormal PromotionをPASSした`FORMAL_HEADER_ASSET`だけである。direct built-in生成は`UNVERIFIED_NON_ASSET`であり、Human OKでも遡及昇格しない。

Cloud Workの標準入口は次である。各commandはNode.js標準libraryだけを使用し、PowerShellやPC上のAssetを要求しない。

```bash
node 04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs prepare ...
node 04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs bind-runtime ...
node 04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs normalize ...
node 04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs complete-qa ...
node 04_AI_Work_Environment/Visual_Production/scripts/cloud-work-header-bridge.mjs promote ...
node 07_Note_Production/Publication_Approval/scripts/final-review-package-compiler.mjs compile ...
```

## Privacy and storage

RecordにはSource locator、hash、要件ID、Tool Request、QA結果およびAsset provenanceだけを記録する。非公開本文、不要な個人情報、会話全文、生成画像binaryまたはcredentialをPublic Repositoryへ自動保存しない。Asset本体の着地点は媒体別Sourceと承認済みArchive規則を正とする。
