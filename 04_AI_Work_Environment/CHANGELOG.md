# AI作業環境 CHANGELOG

このファイルは、`04_AI_Work_Environment/` が担う、Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境と工程接続に関する意味のある変更履歴を記録する。

現在有効な判断基準は `AI_WORK_ENVIRONMENT.md` を参照し、本ファイルを現行ルールの正本として使用しない。

------------------------------------------------------------------------

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
