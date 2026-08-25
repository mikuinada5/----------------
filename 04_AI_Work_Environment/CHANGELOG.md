# AI作業環境 CHANGELOG

このファイルは、`04_AI_Work_Environment/` が担う、Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境と工程接続に関する意味のある変更履歴を記録する。

現在有効な判断基準は `AI_WORK_ENVIRONMENT.md` を参照し、本ファイルを現行ルールの正本として使用しない。

------------------------------------------------------------------------

## 2026-08-25｜Inbox自動除去Implementation互換性承認の正式反映

### 概要

Policy Contract `inbox-auto-removal-v1` に対応するQA済みSkill・Helper実装について、人間による互換性承認を正式Sourceへ反映した。

### 承認済みImplementation

- Implementation Contract：`chat-artifact-inbox-auto-removal-v1`
- implementation identity：`sha256:75a688846e24b29ed475053d47a89f518be4cdb607864a26fa434adbcbe6bf00`
- identity方式：`sha256-canonical-file-manifest-v1`
- 旧identity `sha256:fc4f8cc6faacaf6bbf6664d694d2c63a36ada045cf2bd23cceed24f9cc9d5caf` の承認は継承しない。

### QAおよび有効化状態

- Global Emergency StopをAsset overrideから分離し、全Assetへの優先適用、generic clearからの解除禁止、process再起動後の保持およびfail-closedを隔離E2Eで確認した。
- Inbox回帰31件、auto-removal専用72件およびGlobal Emergency Stop E2E 9件の合格を確認した。
- `automatic_removal_policy_state` は `Disabled` のまま維持する。
- Skill runtimeも`Disabled`であり、本承認はEnabled承認、automatic execution permissionまたは実データ削除開始を意味しない。

### 承認状態

**🟢 Implementation互換性承認済み。ただし自動除去制度状態はDisabled**

## 2026-08-25｜Verified済みInbox重複コピー自動除去制度の正式採用

### 概要

初回Inbox E2Eの実測を踏まえ、Verified済みで安全なauthoritative copyがInbox外へ確立された完全重複コピーについて、全条件を機械確認できる場合だけInbox側コピーを自動除去できる恒久制度を正式採用した。

### 正式化した主な内容

- 自動化対象を、Inbox直下にある単一通常ファイルのVerified済み完全重複コピーに限定し、保持、不保持、配属、競合解消その他の意味判断を人間責任として維持した。
- folder、recursive delete、Original、Processed、DerivedおよびRepository資産を対象外とした。
- sourceとauthoritative copyの独立実体、link・hardlink・reparse等の否定、最新の有効なVerified Event、identity evidenceの不変性、同期状態およびhuman overrideの積極確認を必須化した。
- `Verified → deletion intent → Inbox-side action result → Closed` の追記型履歴と、判定不能・`sync=unknown`・Ledger書込不能その他のfail-closed条件を定義した。
- 正式runtimeをPowerShell 7以上とし、Source正式採用とSkill・Helper実装およびauto mode Enabledを分離した。
- Source revisionを監査・provenance用、Policy Contract Versionを実行互換性用として分離し、初期Contractを `inbox-auto-removal-v1` とした。
- Helperの自己互換宣言だけでは実行資格を認めず、人間承認済みImplementation Contractおよび必要なimplementation identityとの一致を必須化した。
- human overrideおよびemergency stopをSource上のEnabledより優先し、AI、SkillまたはHelperによる停止解除を禁止した。

### 正式採用時の状態

- `automatic_removal_policy_state: Disabled`
- `automatic_removal_policy_contract: inbox-auto-removal-v1`
- `automatic_removal_approved_implementation_contract: none`
- `automatic_removal_approved_implementation_identity: none`

Source正式採用だけでは自動除去を有効化しない。Skill・Helper同期、implementation identity確定、shadow dry-run、否定テスト、QA、互換性の人間承認およびEnabledの人間承認は後続工程とする。

### 監査

- 内部監査、一意修正および再監査を完了した。
- Claude OpusによるF-01〜F-06、N-01〜N-03の差分監査を経て、最終判定「🟢 正式採用可能」、必須修正なしを確認した。

### 既存責任への影響

- 人間判断、停止、再承認および個別指示は引き続き `HUMAN_IN_THE_LOOP.md` を正とする。
- Ledgerを承認主体または制度状態の正としない。
- Repository、GitおよびCHANGELOGの責任、ならびにAI組織上の役割・権限を変更しない。

### 承認状態

**🟢 現行正式Sourceとして採用。ただし自動除去制度状態はDisabled**

## 2026-08-25｜Inbox・Personal Archive受領・配属運用原則の正式採用

### 概要

未配属受領物をOneDrive上のInboxで受領し、評価、分類、必要な人間判断、正式配属、検証およびClosedまで接続する共通運用と、Personal ArchiveにおけるOriginal、ProcessedおよびDerivedの責任境界を、専門Sourceとして正式採用した。

### 正式化した主な内容

- `04_AI_Work_Environment/INBOX_AND_PERSONAL_ARCHIVE.md` を現行正式Sourceとして配置した。
- OneDrive上の `AI/00_Inbox` および `AI/04_Personal_Archive` を、AI作業環境領域が管理するRepository外の運用対象として位置づけた。
- Inboxを正式Source、Archive、Temp、長期保存場所または独立したAI部署・承認主体として扱わない責任境界を明確化した。
- Inbox処理の `Received`、`Assessed`、`AwaitingDecision`、`Placed`、`Verified`、`Closed` を、専門成果物の承認Statusとは異なる運用状態として定義した。
- Personal ArchiveのOriginal、ProcessedおよびDerivedを分離し、センシティブ情報の通常検索・外部提供への自動混入防止とprovenance要件を定義した。
- Inbox LedgerとRepository CHANGELOGを分離し、初回E2EではVerified済みInbox重複コピーの恒久自動除去権限を導入しないことを確定した。
- 現行Skill・Helperの実装状態とSource上の標準要件を分離し、初回Closed E2E前の同期確認結果を新しい承認ゲートとせずChatへ報告する運用を追加した。

### 関連Sourceへの影響

- `AI_WORK_ENVIRONMENT.md` の適用範囲と関連Sourceへ、OneDrive上のInbox・Personal Archiveおよび本専門Sourceとの接続を追加した。
- `REPOSITORY_RULES.md` のAI作業環境領域の正式構造と責任説明を更新した。
- Human-in-the-loop、AI組織、Brand、EducationおよびVoiceの既存責任は変更していない。

### 承認状態

**🟢 現行正式Sourceとして採用**

## 2026-08-23｜AI作業環境・工程接続原則の初回正式採用

### 概要

Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境を、AI組織上の責任を維持したまま適切な工程へ接続する横断運用原則を、正式Sourceとして初回採用した。

### 正式化した主な内容

- 作業環境とAI組織上の役割を分離し、案件に応じて必要な環境だけを選択する原則
- Chatを意思決定、WorkをRepository反映前の継続作業、CodexをRepository参照・実装・反映・検証の実行環境とする責任境界
- Repository、Git、GitHub、VS Codeおよび正式Source・作業中データ・承認状態の区別
- Chat → CodexとChat → Work → Codexを含む、必須直列工程を前提としない環境間受け渡し
- 外部AIを原則として助言的監査役とし、既存QA・HITL・正式承認を代替させない権限境界
- 人間判断を維持しながら不要な人間操作を減らすE2Eの目標状態と、現行実装状態との区別

### 既存責任への影響

- `AI_ORGANIZATION.md` が担うAI組織構造、役割、権限および責任分離に変更はない。
- `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` が担う承認、停止、自己復旧、エスカレーション、個別指示および完了判断に変更はない。
- `REPOSITORY_RULES.md` が担うRepository構造、GitおよびCHANGELOGの具体運用に変更はない。
- Brand、EducationおよびVoiceの各専門Sourceが担う責任に変更はない。

### 承認状態

**🟢 現行正式Sourceとして採用**
