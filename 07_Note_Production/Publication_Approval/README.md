# note Publication Approval Gate

**Status:** Current / Operational v1.5 / Cloud Work Header Bridge compatible
**Responsibility:** note Final Review PackageへのHuman Final Approval / Publication Approvalを実際の公開対象へbindingし、承認後のsealed Publication Bundle、Phase 1 Work handoff、G5からPPVまでの継続可否を機械検証する。

## Contract

通常のnote制作E2EでHumanを呼ぶ標準地点は二つである。

1. Productionと内部QA後の`HUMAN_REVIEW`。本文内容のReviewであり、Marketing前のためFinal ApprovalまたはPublication Approvalではない。
2. Marketing ApprovedのD3、QA済みHeader、Marketingが確定したPublication Conditionsをまとめた`FINAL_REVIEW_PACKAGE_PRESENTED`。このPackageに対するHumanの明示的な進行意思を`FINAL_AND_PUBLICATION`として記録する。

Final Review Packageは、D3本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他の公開条件、noteの公開先および必要Source Manifestを含む。Human eventは、Human actor、event ID、発言、時刻、提示済みPackage ID／SHA、destination、purposeを保持する。Approval recordは同Human eventと同Packageへbindingする。

## Deterministic Compiler

`MARKETING_APPROVED`からHuman Final Reviewへ進む前に、Local Codexでは`New-FinalReviewPackage.ps1`、Cloud Workでは`final-review-package-compiler.mjs`を必ず実行する。CompilerはLLMによる自由生成ではなく、D3本文file、Marketing Review PASS evidence、`FORMAL_HEADER_ASSET` record、Header実体、Publication Conditions、Source Manifest、destinationおよびpurposeをSchemaと実file SHAで検証し、一つのimmutable Package JSONとHuman提示用Markdownを決定論的に生成する。 Formal Header recordのID／identity、Article ID、approved display title、Header SHA／canonical pointer、Master identity／SHA、Asset QA、Bridge route receiptおよびHeader Human Approvalを再照合し、単なるPNGまたはHuman OKだけを拒否する。

Cloud Workでは同じCompiler identity contractを`final-review-package-compiler.mjs`で実行する。PowerShell版とcross-platform版は同じInput／Package Schema、Formal Header再検証、identity payload、immutable出力および8区分提示を使用する。Cloud Bridge経路の`implementation_id`と`route`をそのままPackageへ保持し、Local経路へ偽装しない。

```text
MARKETING_APPROVED
  → required inputs verification
  → FINAL_REVIEW_PACKAGE_BUILDING
  → compile / schema / identity / presentation validation
  → READY_FOR_FINAL_REVIEW / approval=PENDING

required input missing or mismatch
  → BLOCKED_FINAL_PACKAGE_INCOMPLETE
```

Package identityは、Article ID、title、D3 artifact ID／canonical pointer／file SHA、Marketing Review status／identity／version／Evidence SHA、Formal Header Asset ID／identity／display title／canonical pointer／file SHA、Master identity／SHA、Bridge route Evidence、Asset QA Evidence／Header Human Approval Evidence、正規化したPublication Conditions、destination、purposeおよびSource Manifest identity／pointer／SHAのcanonical JSONをUTF-8でSHA-256化する。`package_id`は`FRP-<safe article id>-<identity SHA-256>`とする。local path、生成時刻、Human eventまたはApproval Evidenceはidentityへ混入しない。

同一入力は同一Package identityと同一bytesを生成する。D3、title、Header、境界、Membership、Magazine、price、tags、その他条件、Marketing Evidence、destinationまたはSource Manifestが変われば新しいidentityと別filenameを生成する。既存Package fileを上書きせず、同じpathに異なるbytesがある場合は`IMMUTABLE_PACKAGE_CONFLICT`で停止する。旧PackageのApprovalは新PackageのID／identity／file SHAと一致しないためG5で拒否される。

Package本体はHuman提示前に`READY_FOR_FINAL_REVIEW`、`approval.status=PENDING`として完成する。Human eventとApproval Evidenceは別Artifactであり、Packageへ追記しない。Human提示用Markdownは、最終本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他Publication Conditionsの8区分を一括生成し、本文だけの提示をvalidatorが拒否する。未公開本文を含むPackageと提示用Artifactは、D3と同じ公開範囲のWork、Private Sourceまたは指定Archiveへ保存し、Public Repositoryの公開済み領域へ先行配置しない。

## Publication Bundle / Work Handoff Phase 1

Human Final Approval / Publication Approval成立後、`New-PublicationBundle.ps1`を実行する。BuilderはG5と共通のpure binding validatorで承認済みFinal Review Packageと実fileを再検証し、G5自体を先行実行せず、次のflat構造を`PublicationBundle/`へ生成する。Final Review PackageとHuman eventは、既存Approval semanticsをWork側で再検証するための追加必須fileである。

```text
PublicationBundle/
├─ manifest.json
├─ body.md
├─ header.png
├─ publication-conditions.json
├─ approval-evidence.json
├─ source-manifest.json
├─ human-event.json
└─ final-review-package.json
```

Bundle identityはArticle ID、Final Review Package ID／identity／file SHA、body SHA、Header SHA、Publication Conditions identity／file SHA、Source Manifest ID／SHA、Approval ID／file SHA、Human event ID／SHA、destination=`note`およびpurpose=`publish`のcanonical JSONをUTF-8でSHA-256化する。`bundle_id`は`PB-<safe article id>-<identity SHA-256>`とする。ZIP bytes、ZIP SHA、local path、生成時刻または展開先はidentityへ含めない。

Builderは`HUMAN_APPROVED → BUNDLE_SEALED → HANDOFF_PENDING`を返し、logical BundleをBundle IDごとのdirectoryへ固定する。Seal後にbody、Header、境界、Membership、Magazine、price、tags、その他Conditions、Source Manifest、destinationまたはpurposeが変わった場合、既存Bundleを上書きしない。変更後のFinal Review Package、Approval Evidenceおよび新Bundleを生成する。同一承認入力は同一Bundle IDと同じlogical contentsを生成し、運搬ZIP名は`<Article ID>_PublicationBundle.zip`とする。

Phase 1ではHumanがこのZIP一つを常設note公開Workへ一度渡す。公開Workが信用する正式入力はPublication BundleとExpected Package IDだけである。Chat履歴、「このChatを正本」という参照文、本文／Header／設定の個別手渡しは正式入力ではない。`Test-PublicationBundleHandoff.ps1`はpath escapeを拒否してZIPを展開し、Manifest Schema、構成fileの完全性、各SHA、Package identity、Publication Conditions、Approval Evidence／Human eventのPackage binding、destination、purposeおよびSource Manifestを再検証する。全一致時だけ`HANDOFF_VERIFIED`を返し、G5へ進める。

Chat→Workの完全自動file転送は現行Platformで保証しない。Phase 1で残るHuman HITLは`HANDOFF_PENDING → HANDOFF_VERIFIED`間の単一ZIP受け渡し一回である。将来の自動化はTransport Adapterを交換して実装し、本Builder、Bundle Manifest、ApprovalまたはG5の契約へ特定Platformの会話状態を埋め込まない。

標準状態は`HUMAN_APPROVED → BUNDLE_SEALED → HANDOFF_PENDING → HANDOFF_VERIFIED → G5_PASS → PUBLISHED → PPV_PASS`とする。

G5は新しい承認を依頼しない。`Test-NoteG5Approval`が次をすべて検証してPASSした場合、同一Packageのまま`NOTE_DRAFT_CREATE → BODY_APPLY → HEADER_APPLY → PUBLICATION_CONDITIONS_APPLY → SETTINGS_VERIFY → PUBLISH → PPV`を継続できる。

- 三つのJSONが各Schemaへ適合する。
- Human eventがFinal Review Package提示後に発生し、文脈上そのPackageへの明示的な進行意思である。
- Package ID／SHA、D3本文bytes、Header bytes、destination、purpose、Source Manifest SHAが、Approval Evidenceと実際の公開対象で一致する。
- Approval scopeが`NOTE_PUBLICATION`である。

D3、Header、承認対象Publication Conditions、必要SourceまたはHuman判断が必要な新規条件が変わればApprovalは失効する。内部処理、同一bytesの再読、同一Packageの下書き反映や設定再構成だけでは失効しない。各公開工程で`Assert-NotePublicationStep`を再実行し、差分または新規Human Decisionを検出した場合だけHumanへ戻す。

Publication ApprovalはExternal Audit、OneDrive保存、Git通信、credentialまたは他サービス送信のApprovalに使用できない。逆方向の流用も拒否する。本実装はnote Publication専用であり、External Audit Pipelineを変更または再有効化しない。

## Files

- `schemas/final_review_package_input.schema.json`: Compiler必須Inputとlocal read path
- `schemas/final_review_package.schema.json`: `READY_FOR_FINAL_REVIEW`のimmutable承認対象Package
- `../../04_AI_Work_Environment/Visual_Production/schemas/formal_header_asset.schema.json`: Compilerが受け取るFormal Header Asset record
- `schemas/human_event.schema.json`: Package提示時刻とPackage identityへbindingするHuman response event
- `schemas/publication_approval.schema.json`: Package identityへbindingするFinal / Publication Approval record
- `schemas/publication_bundle_manifest.schema.json`: sealed Bundle identity、構成file、Package／Approval／destination binding
- `schemas/publication_conditions.schema.json`: Bundle内の正規化Publication Conditions
- `scripts/FinalReviewPackageCompiler.psm1`: 必須Input／SHA検証、identity計算、immutable出力、Human提示検証
- `scripts/final-review-package-compiler.mjs`: Cloud Work用の同一identity contractを持つcross-platform Compiler
- `scripts/New-FinalReviewPackage.ps1`: Compiler entrypoint
- `scripts/PublicationApproval.psm1`: Schema、identity、時系列、intent、scope、継続工程のvalidator
- `scripts/Test-PublicationApproval.ps1`: G5／工程検証entrypoint
- `scripts/PublicationBundle.psm1`: Bundle Builder／Sealer、identity、secure ZIP受取、Work検証、G5接続
- `scripts/New-PublicationBundle.ps1`: Human Approval後のBundle生成entrypoint
- `scripts/Test-PublicationBundleHandoff.ps1`: Phase 1 Work受取／E2E検証entrypoint
- `tests/FinalReviewPackageCompiler.Tests.ps1`: Compiler negative／identity／presentation tests
- `tests/PublicationApproval.Tests.ps1`: Approval semantics negative / regression tests
- `tests/PublicationBundle.Tests.ps1`: Bundle欠落／改変／Seal／handoff／G5接続negative and regression tests
- `../../04_AI_Work_Environment/Visual_Production/tests/CloudWorkHeaderBridge.Tests.mjs`: Cloud HeaderからCompilerまでのPowerShell非依存E2E
