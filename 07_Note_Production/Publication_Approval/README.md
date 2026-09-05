# note Publication Approval Gate

**Status:** Current / Operational v1.0
**Responsibility:** note Final Review PackageへのHuman Final Approval / Publication Approvalを、実際の公開対象へbindingし、G5からPPVまでの継続可否を機械検証する。

## Contract

通常のnote制作E2EでHumanを呼ぶ標準地点は二つである。

1. Productionと内部QA後の`HUMAN_REVIEW`。本文内容のReviewであり、Marketing前のためFinal ApprovalまたはPublication Approvalではない。
2. Marketing ApprovedのD3、QA済みHeader、Marketingが確定したPublication Conditionsをまとめた`FINAL_REVIEW_PACKAGE_PRESENTED`。このPackageに対するHumanの明示的な進行意思を`FINAL_AND_PUBLICATION`として記録する。

Final Review Packageは、D3本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他の公開条件、noteの公開先および必要Source Manifestを含む。Human eventは、Human actor、event ID、発言、時刻、提示済みPackage ID／SHA、destination、purposeを保持する。Approval recordは同Human eventと同Packageへbindingする。

G5は新しい承認を依頼しない。`Test-NoteG5Approval`が次をすべて検証してPASSした場合、同一Packageのまま`NOTE_DRAFT_CREATE → BODY_APPLY → HEADER_APPLY → PUBLICATION_CONDITIONS_APPLY → SETTINGS_VERIFY → PUBLISH → PPV`を継続できる。

- 三つのJSONが各Schemaへ適合する。
- Human eventがFinal Review Package提示後に発生し、文脈上そのPackageへの明示的な進行意思である。
- Package ID／SHA、D3本文bytes、Header bytes、destination、purpose、Source Manifest SHAが、Approval Evidenceと実際の公開対象で一致する。
- Approval scopeが`NOTE_PUBLICATION`である。

D3、Header、承認対象Publication Conditions、必要SourceまたはHuman判断が必要な新規条件が変わればApprovalは失効する。内部処理、同一bytesの再読、同一Packageの下書き反映や設定再構成だけでは失効しない。各公開工程で`Assert-NotePublicationStep`を再実行し、差分または新規Human Decisionを検出した場合だけHumanへ戻す。

Publication ApprovalはExternal Audit、OneDrive保存、Git通信、credentialまたは他サービス送信のApprovalに使用できない。逆方向の流用も拒否する。本実装はnote Publication専用であり、External Audit Pipelineを変更または再有効化しない。

## Files

- `schemas/final_review_package.schema.json`: 承認対象Package
- `schemas/human_event.schema.json`: Package提示後のHuman response event
- `schemas/publication_approval.schema.json`: Final / Publication Approval record
- `scripts/PublicationApproval.psm1`: Schema、identity、時系列、intent、scope、継続工程のvalidator
- `scripts/Test-PublicationApproval.ps1`: G5／工程検証entrypoint
- `tests/PublicationApproval.Tests.ps1`: Approval semantics negative / regression tests
