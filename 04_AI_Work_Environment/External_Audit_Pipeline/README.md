# External Audit Pipeline v1.1

**Status:** Local preparation operational / live send BLOCKED_APPROVAL_RUNTIME
**Runtime:** PowerShell 7.4以上
**Scope:** AI Organization Series Section 1〜6、および同じ監査契約を使用できる将来の成果物

## 1. 目的と責任境界

内部監査PASS後のFinal Candidateから、監査に必要な本文とSourceだけを抽出し、ClaudeまたはGeminiへExternal Audit APIで送信する。応答JSONをSchema検証し、Severityに基づく次工程を機械判定する。

外部AIは助言的なExternal Auditorであり、共同執筆者、承認者またはRepository Writerではない。外部AIの応答は原稿を変更しない。指摘のSource照合、採否、必要最小限の修正、再監査、Human Decisionへの接続は内部制作側が担う。

## 2. Pipeline

```text
Internal Audit PASS
→ Final Candidate
→ Request Manifest検証
→ 必要Sourceだけ抽出
→ External Sharing Gate
→ Provider API
→ Response Schema・意味整合検証
→ Severity Routing
   ├─ BLOCKER / human_decision_required → HUMAN_DECISION_REQUIRED
   ├─ MAJOR / MINOR → RETURN_TO_INTERNAL_AI
   └─ NOTEのみ / Issueなし → PASS_TO_FINALIZATION
→ 必要最小限の修正
→ Policyに該当する場合だけExternal Re-Audit
```

初期の再監査Policyは `after_major`。MAJOR修正後は再監査し、MINORだけなら内部再監査で完了できる。`after_any_revision` または `never` へ実行単位で変更できる。

## 3. 構成

| Path | 責任 |
|---|---|
| `prompts/external_audit_prompt.md` | 外部監査Prompt正本 |
| `schemas/audit_request.schema.json` | Request Manifest契約 |
| `schemas/audit_input.schema.json` | Providerへ渡す監査Input契約 |
| `schemas/audit_response.schema.json` | 外部AI応答契約 |
| `src/ExternalAudit.psm1` | Input Builder、Provider Adapter、Retry、検証、Routing |
| `scripts/Invoke-ExternalAudit.ps1` | CLI入口 |
| `tests/ExternalAudit.Tests.ps1` | APIを呼ばない回帰テスト |
| `examples/audit_request.example.json` | Request Manifest例 |

## 4. Input Builder

Request Manifestは、Series、Section、Session、記事タイトル、Story、Practice、Session Archive、Evidence Note、Series方針、Session責任範囲、後続境界、Voice / Archiveルールを指定する。

Source指定はRepository相対pathと、必要に応じて `start_marker` / `end_marker` を使用する。Builderは次をfail-closedで検証する。

- `internal_audit.status` が `PASS`
- Request / Input Schema適合
- Repository外へのpath traversalがない
- Sourceとmarkerが実在する
- 選択範囲が空でない
- `max_chars` を超えない
- 各責任Source群が1件以上ある

超過時に本文を黙って切り詰めない。Source選択範囲を狭めて再実行する。

## 5. 外部送信Gate

実API送信は停止中。既存の`external_sharing.approved`、`approval_ref`、CLIの`-ConfirmExternalSend`はHuman Approval Evidenceの真正性を証明しないため、指定しても送信できない。過去のClaude Live E2Eは接続の履歴であり、現行Approval GateのPASSではない。

`APPROVAL_REQUIRED → APPROVAL_REQUESTED → WAITING_FOR_HUMAN → APPROVAL_GRANTED`の検証契約は`src/ExternalApproval.psm1`と`schemas/human_approval.schema.json`を参照する。対象は実provider request全体のbytes SHA、destination、目的、request ID、質問とHuman responseの時刻。system prompt・Source・設定変更も別payloadである。質問受付の`accepted`、Agentのapproved自己申告、後着承認では成立しない。

offline verifierは署名されたHuman event statementを検証するが、callerが指定した公開鍵を本番の信頼根として採用しない。合成testsの署名鍵はメモリ内のみで破棄し、本番へ配置しない。offline PASSは`external_invocation_allowed: false`のまま。実送信はCLI、dispatch、Anthropic／Gemini leafすべてで無条件にfail-closedとする。

再開には、Agentが生成・差替えできないHuman-event ingressと信頼根、取消・Incident・invocationを保持する保護された履歴、時刻の意味を区別した順序検証、各retry直前の再検証とpayload固定、negative testおよびruntime E2Eの完了が必要。それまで再有効化を禁止する。今回のHuman承認はStyle QA・Incident記録・送信停止措置・offline Approval検証契約・関連Source接続の正式反映に限り、外部監査Pipelineの恒久運用完成または実送信再開を承認していない。既存の承認権限を実装へ接続する要件であり、新しい承認者は作らない。任意Tool全体またはapproval reviewerそのものをRepositoryから修正済みとは主張しない。

事故で使用された個人Claude runnerも、SHAを限定した`Block-LegacyClaudeRunner.ps1`で実送信を停止した。Repositoryに保存するのは適用手順・identityと安全なIncident記録だけで、credentialや端末設定は保持しない。詳細は`INCIDENT_REVIEW.md`。個人skillの再インストール／runner更新で停止guardが失われた場合も、実送信を再開せずidentityと停止を再検証する。

`-PrepareOnly` はPackageを構築・検証するが送信しない。APIキー、認証情報、Repository全文、無関係なSource、個人情報または外部共有未承認資料をManifestへ含めない。

## 6. API KeyとModel

API Keyはファイル、Markdown、引数、監査結果へ保存しない。Clientは次の環境変数をProcess → User → Machineの順で読む。

- Anthropic: `ANTHROPIC_API_KEY`
- Gemini: `GEMINI_API_KEY`

Modelは更新可能性があるためコードへ固定せず、実行時に明示する。承認済みの現行Model IDをProvider公式資料で確認する。Anthropic Adapterは新しいModelとの互換性のためsampling parameterを送らない。外部監査の初期値は `AnthropicThinkingMode=disabled` とし、生成時間を監査Timeout内へ制御する。必要な環境では `default` を明示できる。

PowerShellの現在のProcessだけへ一時設定する例：

```powershell
$env:ANTHROPIC_API_KEY = '<API key>'
```

値をshell履歴へ残したくない場合は、安全な秘密管理手段からProcess環境へ注入する。実値をREADME、Manifest、commit、コマンド出力へ貼らない。

Windows User環境へ非表示入力で設定する場合は、次の補助スクリプトを対話実行できる。スクリプトはkey形式を確認し、key本文を出力またはRepositoryへ保存しない。

```powershell
pwsh -NoProfile -File "04_AI_Work_Environment/External_Audit_Pipeline/scripts/Set-AnthropicApiKey.ps1"
```

## 7. 実行

APIを呼ばない事前検証：

```powershell
pwsh -NoProfile -File "04_AI_Work_Environment/External_Audit_Pipeline/scripts/Invoke-ExternalAudit.ps1" `
  -ManifestPath "path/to/audit_request.json" `
  -OutputPath "path/to/prepared_package.json" `
  -Provider anthropic `
  -Model "approved-claude-model-id" `
  -PrepareOnly
```

旧CLI互換性の停止確認（現行では必ず送信前にFAIL）：

```powershell
pwsh -NoProfile -File "04_AI_Work_Environment/External_Audit_Pipeline/scripts/Invoke-ExternalAudit.ps1" `
  -ManifestPath "path/to/audit_request.json" `
  -OutputPath "path/to/audit_result.json" `
  -RoutingOutputPath "path/to/audit_result.routing.json" `
  -Provider anthropic `
  -Model "approved-claude-model-id" `
  -ConfirmExternalSend
```

監査結果JSONは外部AIのSchema準拠出力だけを保持する。Routing JSONはProvider、Model、request ID、本文を含まないInput hash、Severity集計、次Actionを分離して保持する。APIエラー本文と送信本文はログへ出さない。

## 8. 応答検証と停止条件

JSON Schemaに加え、次を意味検証する。

- Issue IDが重複しない
- BLOCKERは `human_decision_required = true`
- BLOCKERまたはHuman Decisionあり → `HUMAN_DECISION_REQUIRED`
- MAJORあり → `REVISE`
- MINORのみ → `PASS_WITH_MINOR`
- NOTEのみまたはIssueなし → `PASS`

不整合な応答は監査結果として採用せず、Provider response errorとして扱う。CLIは通常成功で `0`、実行エラーで `1`、Human Decisionへの停止で `20` を返す。

## 9. Retry / Timeout

408、409、425、429、5xxおよびNetwork / TimeoutだけをRetryする。4xxの恒久エラーはRetryしない。初期値はTimeout 120秒、Retry 2回、指数Backoff 2秒→4秒。API Keyやresponse本文をエラーメッセージへ含めない。

## 10. Test

```powershell
pwsh -NoProfile -File "04_AI_Work_Environment/External_Audit_Pipeline/tests/ExternalAudit.Tests.ps1"
```

テストはTemp fixtureだけを使用し、外部APIを呼ばない。

Approval Gateの追加回帰は`Invoke-Pester ./04_AI_Work_Environment/External_Audit_Pipeline/tests/ExternalApproval.Tests.ps1`。A–Fはoffline契約の検証であり、FのPASSを本番Human-event ingress／外部送信の成功と扱わない。
