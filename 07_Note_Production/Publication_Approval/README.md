# note Publication Approval Gate

**Status:** Current / Operational v1.1
**Responsibility:** note Final Review PackageへのHuman Final Approval / Publication Approvalを、実際の公開対象へbindingし、G5からPPVまでの継続可否を機械検証する。

## Contract

通常のnote制作E2EでHumanを呼ぶ標準地点は二つである。

1. Productionと内部QA後の`HUMAN_REVIEW`。本文内容のReviewであり、Marketing前のためFinal ApprovalまたはPublication Approvalではない。
2. Marketing ApprovedのD3、QA済みHeader、Marketingが確定したPublication Conditionsをまとめた`FINAL_REVIEW_PACKAGE_PRESENTED`。このPackageに対するHumanの明示的な進行意思を`FINAL_AND_PUBLICATION`として記録する。

Final Review Packageは、D3本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他の公開条件、noteの公開先および必要Source Manifestを含む。Human eventは、Human actor、event ID、発言、時刻、提示済みPackage ID／SHA、destination、purposeを保持する。Approval recordは同Human eventと同Packageへbindingする。

## Deterministic Compiler

`MARKETING_APPROVED`からHuman Final Reviewへ進む前に、`New-FinalReviewPackage.ps1`を必ず実行する。CompilerはLLMによる自由生成ではなく、D3本文file、Marketing Review PASS evidence、QA PASS済みHeader Asset、Publication Conditions、Source Manifest、destinationおよびpurposeをSchemaと実file SHAで検証し、一つのimmutable Package JSONとHuman提示用Markdownを決定論的に生成する。

```text
MARKETING_APPROVED
  → required inputs verification
  → FINAL_REVIEW_PACKAGE_BUILDING
  → compile / schema / identity / presentation validation
  → READY_FOR_FINAL_REVIEW / approval=PENDING

required input missing or mismatch
  → BLOCKED_FINAL_PACKAGE_INCOMPLETE
```

Package identityは、Article ID、title、D3 artifact ID／canonical pointer／file SHA、Marketing Review status／identity／version／Evidence SHA、Header Asset ID／canonical pointer／file SHA／Asset QA Evidence SHA、正規化したPublication Conditions、destination、purposeおよびSource Manifest identity／pointer／SHAのcanonical JSONをUTF-8でSHA-256化する。`package_id`は`FRP-<safe article id>-<identity SHA-256>`とする。local path、生成時刻、Human eventまたはApproval Evidenceはidentityへ混入しない。

同一入力は同一Package identityと同一bytesを生成する。D3、title、Header、境界、Membership、Magazine、price、tags、その他条件、Marketing Evidence、destinationまたはSource Manifestが変われば新しいidentityと別filenameを生成する。既存Package fileを上書きせず、同じpathに異なるbytesがある場合は`IMMUTABLE_PACKAGE_CONFLICT`で停止する。旧PackageのApprovalは新PackageのID／identity／file SHAと一致しないためG5で拒否される。

Package本体はHuman提示前に`READY_FOR_FINAL_REVIEW`、`approval.status=PENDING`として完成する。Human eventとApproval Evidenceは別Artifactであり、Packageへ追記しない。Human提示用Markdownは、最終本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他Publication Conditionsの8区分を一括生成し、本文だけの提示をvalidatorが拒否する。未公開本文を含むPackageと提示用Artifactは、D3と同じ公開範囲のWork、Private Sourceまたは指定Archiveへ保存し、Public Repositoryの公開済み領域へ先行配置しない。

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
- `schemas/human_event.schema.json`: Package提示時刻とPackage identityへbindingするHuman response event
- `schemas/publication_approval.schema.json`: Package identityへbindingするFinal / Publication Approval record
- `scripts/FinalReviewPackageCompiler.psm1`: 必須Input／SHA検証、identity計算、immutable出力、Human提示検証
- `scripts/New-FinalReviewPackage.ps1`: Compiler entrypoint
- `scripts/PublicationApproval.psm1`: Schema、identity、時系列、intent、scope、継続工程のvalidator
- `scripts/Test-PublicationApproval.ps1`: G5／工程検証entrypoint
- `tests/FinalReviewPackageCompiler.Tests.ps1`: Compiler negative／identity／presentation tests
- `tests/PublicationApproval.Tests.ps1`: Approval semantics negative / regression tests
