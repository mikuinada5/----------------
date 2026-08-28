# Repository外参照資料レジストリ

**Status:** Current / Operational v1.1<br>
**責任:** Repository外に原本を保持する継続参照資料について、Repository正本から再追跡するための非機密メタデータと差分反映状態を管理する

## 1. 位置づけ

本レジストリは、サイズ、機密性、サービス依存性またはGit管理適性によりRepositoryへ原本を配置しない参照資料の追跡入口である。原本、Inbox Ledger、Personal Archive内のprovenance、Timeline、承認記録または専門Sourceを代替しない。

Repository内の正式OS、SOP、教育設計、Timeline、制作台本および公開済み成果物は、それぞれの既存canonical pathを正とし、本レジストリへ複製しない。Repository外資料から正式Sourceへ採用済みの内容はRepository正本を通常参照し、原本照合が必要な場合だけ本レジストリから遡る。

Personal Archive上の増分型一次資料について、Original snapshotのDataset ID、SHA、Processed checkpointおよびDerivedの詳細を照合するときは `ARCHIVE_PROVENANCE_INDEX.md` を正とする。本レジストリは継続参照資料をRegistry IDで横断追跡し、同Indexの詳細を重複管理しない。

原本の受領、Original／Processed／Derived、センシティブ情報、provenanceおよびLedgerは `INBOX_AND_PERSONAL_ARCHIVE.md` を正とする。外部共有、公開範囲および人間判断は `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` を正とする。

## 2. 登録・更新規則

各資産は、本文や秘密情報を記録せず、利用可能な範囲で次を保持する。

- 一意なRegistry IDと資料種別
- 取得元サービスまたは生成工程
- Repository外のauthoritative locationまたは再取得方法
- 原本識別子、SHAその他の不変識別情報
- 最終取得地点と取得状態
- 前回処理地点と、次回差分処理の開始点
- Timeline、Evidence、制作Sourceその他への反映状態
- Repository側の参照先
- センシティブ性、到達可否および未解決事項

不明な値は推測せず `未確認` とする。会話タイトルだけで一意性を保証できない場合は、export内conversation IDその他の永続IDを次回取得時に補う。個別受領イベントはInbox Ledger、詳細な変換条件はPersonal Archive側provenanceへ記録し、本レジストリには再追跡に必要な要約と参照だけを同期する。

増分取得時は、重複を避けるため原本IDと前回処理地点を照合し、Originalを改変せず、Processed／Derivedを更新してから、確認済みの事実だけをTimelineまたはEvidenceへ反映する。反映後に本レジストリの取得地点、処理地点、反映先および確認日を更新する。

## 3. 現行登録

### EXT-CODEX-AIORG-MAP — Codex Task「AI組織づくりの地図を制作」

| 項目 | 現在値 |
|---|---|
| 資料種別 | Codex Task会話原本／後日回顧の一次資料 |
| 取得元 | Codex Task。thread `01a0317f-f4e8-76c0-9bdd-143d02aa03d3` |
| Repository外原本 | Codexサービス側Task。turn `01a03180-2578-7f63-92c9-ac3f082f1f6a`、user message `01a03180-27a1-72a2-a5d4-3797d8a78857` |
| 最終取得地点 | 2026-08-24の上記user messageにある回顧発言4件まで参照済み |
| 前回処理地点 | Section台本のHC-01〜HC-04、SC-01〜SC-02およびS01-01 Primary Evidenceへ反映済み |
| 反映状態 | AIORG-S01制作台本へEvidence／Human Confirmation、Primary Evidence Packageへ識別子付き抜粋として反映済み。初期PPT依頼の発生日、当時のAI回答、採否、成果物状態は未確認。Timelineへの独立行は未反映 |
| Repository参照先 | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md`、同Sectionの`01_Primary_Evidence/S01-01.md` |
| 次回処理 | 同Taskの新規turnを取得した場合は上記user message以後を差分確認し、初期PPT依頼のOriginalが別途取得できた場合は回顧と分けて登録する |
| 取扱い | 個人会話・第三者情報を含む可能性があるため原本はRepositoryへ配置しない。通常検索・外部提供へ自動混入させない |

### EXT-CODEX-AIORG-WORK — Codex Work「AI組織シリーズ制作｜正式運用開始」

| 項目 | 現在値 |
|---|---|
| 資料種別 | Codex Work会話原本 |
| 取得元 | Codex Work。永続Work IDとexport方法は現Repositoryから未確認 |
| Repository外原本 | サービス側会話。Personal Archiveへの取得状態、authoritative path、SHAは未確認 |
| 最終取得地点 | 2026-08-26のユーザー指示「今回壁打ちで新たに判明した設計」「AI組織シリーズの基本思想」まで参照済み |
| 前回処理地点 | 上記指示から確認したSection設計の史実1件をTimelineへ反映済み |
| 反映状態 | Timelineの2026-08-26行へ制作済みとして反映済み |
| Repository参照先 | `07_Note_Production/01_Timeline.md`、対象Section制作台本 |
| 次回処理 | 取得可能になった時点で永続Work ID、export識別子、原本SHAまたは同等識別情報を確定し、上記参照位置以後を差分確認する |
| 取扱い | 会話原本は公開範囲とセンシティブ性を確認できないためRepositoryへ配置しない |

### EXT-CODEX-AIORG-PUBLISH — Codex Task「AI Organization Series Section 1 公開準備工程」

| 項目 | 現在値 |
|---|---|
| 資料種別 | Codex Task会話原本 |
| 取得元 | Codex Task。永続Task IDとexport方法は現Repositoryから未確認 |
| Repository外原本 | サービス側会話。Personal Archiveへの取得状態、authoritative path、SHAは未確認 |
| 最終取得地点 | 2026-08-28のユーザー指示「公開準備工程の整合性修正へ進んでください」内 `Human Decision` 1〜6まで参照済み |
| 前回処理地点 | 全6 Sessionの公開構成とHuman DecisionをTimeline、note SOP、ロードマップおよびSection制作台本へ反映済み |
| 反映状態 | Timelineの2026-08-28行およびAIORG-S01の現行制作Sourceへ反映済み |
| Repository参照先 | `07_Note_Production/01_Timeline.md`、`07_Note_Production/02_全体ロードマップ.md`、対象Section制作台本 |
| 次回処理 | 取得可能になった時点で永続Task ID、export識別子、原本SHAまたは同等識別情報を確定し、Human Decision 1〜6以後を差分確認する |
| 取扱い | 会話原本は公開範囲とセンシティブ性を確認できないためRepositoryへ配置しない |

### EXT-PA-AIORG-S01 — AI Organization Series Section 1制作パッケージ

| 項目 | 現在値 |
|---|---|
| 資料種別 | Personal Archive Derived／制作候補・監査照合記録 |
| 取得元 | AI Organization Series Section 1のProductionおよびExternal Audit工程 |
| Repository外原本 | `AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_Final_Candidate.md`、`AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_External_Audit_Reconciliation.md` |
| 識別情報 | Final Candidate SHA-256 `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2`。External Audit Reconciliation SHA-256 `FC3C79B46C276F14F109EB1AC440FC8E17691EAF5D90EA30E4E4EAE238D9A5F6` |
| 最終取得地点 | S1-1〜S1-6の確定タイトル、Story、Practice、Session ArchiveおよびExternal Audit MINOR照合まで既存工程で参照済み |
| 前回処理地点 | Story／Practice本文と確定タイトルのHuman Final Check完了。Session Archiveは後発仕様に対する `Revision Required` |
| 反映状態 | 制作状態、Source／Audit QA、限定修正範囲をSection制作台本とロードマップへ反映済み。本文自体は未公開でRepository正本へ未昇格 |
| Repository参照先 | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md`、同Sectionの`01_Primary_Evidence/README.md`、`07_Note_Production/02_全体ロードマップ.md` |
| 次回処理 | Session Archive限定修正、全文再監査、Human Review後、承認済み公開構成に従って公開済み最終稿だけを `07_Note_Production/README.md` で定義されたcanonical pathへ昇格する |
| 取扱い | Derived候補と監査記録は承認済み公開成果物の正本ではない。公開範囲未決の本文をCloud参照目的だけでRepositoryへ複製しない |

## 4. Repository内で継続参照する正本

比較的固定的でAIが通常業務から直接参照するOS、SOP、運用基準、Timeline、Evidence Log、Section制作台本および承認済み教育設計は、すでに各責任領域のcanonical pathでGit管理されている。これらはRepository正本をLocal／Cloud共通Sourceとし、Personal Archiveへ参照用複製を作らない。

Section固有の一次資料をCloud制作へ渡す必要がある場合は、会話全体を複製せず、当該Sectionの`01_Primary_Evidence/`へ必要最小限の原文抜粋、永続ID、区分、文脈、未取得事項を配置する。史実はTimeline、企画・状態はSection制作台本、原本checkpointは`ARCHIVE_PROVENANCE_INDEX.md`、Human-approved本文は承認済み成果物の責任をそれぞれ維持する。

新しい固定資料を正式採用する場合は、内容責任を持つ既存領域へ配置し、入口README、依存Source、CHANGELOGおよびGitを更新する。本レジストリは、新しい正式Source置場または汎用資料ディレクトリとして使用しない。

## 5. 到達不能時

Repository外原本へ到達できない環境では、Repository側の反映済み正式Sourceだけを使用できる。原文照合、未処理差分または新しい事実の抽出が必要なTaskは、到達不能をSource QAへ記録し、既存の要約から原文、永続ID、SHA、取得日時または未確認事項を推測しない。
