# Repository外Archive provenance index

**Status:** Current / Operational v1.1<br>
**責任:** Repository外に保持する増分型一次資料について、原本識別子、Processed checkpoint、正式Sourceへの反映状態および再追跡経路をRepository側から確認できるようにする

## 1. 位置づけ

本Indexは、OneDrive上のPersonal Archive原本、ProcessedまたはDerivedの本文をRepositoryへ複製するものではない。Repository外に保持する資料について、Local AIが原本へ戻り、Cloud AIが取得・処理・反映状態を確認するための安全な運用メタデータだけを保持する。

責任境界は次のとおりとする。

| 対象 | authoritative copy / canonical Source | 通常参照 |
|---|---|---|
| 生ログ、サービスExport、個人一次資料 | OneDrive `AI/04_Personal_Archive/Original/` | 対象外。必要時にLocalで限定READ |
| 正規化・差分処理データ | OneDrive `AI/04_Personal_Archive/Processed/` | 対象外。次回差分処理の入力 |
| Work History、候補、分析等 | OneDrive `AI/04_Personal_Archive/Derived/` | 正式採用前は通常参照Sourceにしない |
| 加工・確認済みの史実 | `07_Note_Production/01_Timeline.md` | Local / Cloud共通の史実正本 |
| Human OSの判断原則とSupporting Evidence | `05_Human_OS/HUMAN_OS.md`、`05_Human_OS/HUMAN_OS_EVIDENCE_LOG.md` | Local / Cloud共通の現行正式Source |
| Voice、Writing Style、Brand、Educationその他の正式判断 | 各責任領域のcanonical Source | Local / Cloud共通の現行正式Source |

OneDriveの実在rootは現在のWindowsユーザーのOneDrive設定から発見し、ユーザー名を含む絶対パスを恒久識別子にしない。以下では `AI/04_Personal_Archive/` からの論理相対pathを用いる。

2026-08-28時点で、下記資産はローカルREAD可能であることを確認した。OneDriveクラウド側の同期完了はAPIその他の独立証拠で確認していないため、sync stateは`unknown`として扱う。

本Indexへ会話本文、DM本文、個人情報、秘密情報、credential、API key、Cookieまたはtokenを記録しない。本Indexに登録されたことだけで、資料が通常検索可能、外部AI提供可能、正式採用済みまたは公開可能になったとは扱わない。

## 2. 現行Archive registry

### 2.1 ChatGPT Original snapshot

| Dataset ID | Logical path | Export地点 | SHA-256 | Size | Baseline取込 |
|---|---|---|---|---:|---|
| `PA-CHATGPT-MAIN-20260820` | `Original/ChatGPT/f99452ea3d74230d87b910c7f680e6ebe155fa4695276f8df26630ed1191d8d9-2026-08-20-14-34-23-fad4debc74e44771b56296e9581f1063.zip` | 2026-08-20 14:34 JST | `15b168941ce777fe9fbadc15ea719535e7101e149f4a10b46c7fec30956ba7e3` | 266,547,916 bytes | 59 conversations / 7,446 visible messages |
| `PA-CHATGPT-OTHER-20260820` | `Original/ChatGPT/f00ed58903a1a45084fbedff6ce218002b265df50c9d794f8a1d9648364737bc-2026-08-20-14-29-33-19bb399e6ba14f51af378582470fe242.zip` | 2026-08-20 14:29 JST | `2c7602c30225ac6db23c482b96b4093f6a2140f2d088c2e4e97c278e8c8014d3` | 6,798,252 bytes | 12 conversations / 443 visible messages |

SHA、件数および取込状態は、`PA-PROCESSED-20260822` 内の `indexes/source_manifest.json` で確認した値である。

### 2.2 Gemini / Google AI Mode Original snapshot

| Dataset ID | Logical path | SHA-256 | Size | Baseline取込 |
|---|---|---|---:|---|
| `PA-GOOGLE-AI-MODE-WORK-01` | `Original/Google_AI_Mode/仕事相談１.pdf` | `51a34d98bb09d9e50b9fa32e26f1252ab3e790484e430fdbb5039c4e9e4fc791` | 55,396,081 bytes | 1 source record |
| `PA-GEMINI-WORK-02` | `Original/Gemini/仕事相談２.pdf` | `9f0c35241157da198ac76eb764a0ffb9f670aaa245fab242c0c895e453a4825f` | 451,162 bytes | 1 source record |
| `PA-GEMINI-NAGOMI-DAYS` | `Original/Gemini/なごみdays ビジネス設定と応援.pdf` | `6fba392681a1c69c3b5f3bac7fe4f9cbe248be83d2f9ba503cd518db1813c62f` | 2,048,020 bytes | 1 source record / 164 visible messages |
| `PA-GEMINI-FUNNEL-BLUEPRINT` | `Original/Gemini/high_ticket_funnel_blueprint.txt` | `308f6742987d6c2c23344a47a6423b04dd8f85694c17d5def635b599581b78d0` | 4,853 bytes | 1 source record |

### 2.3 Processed checkpoint

| Dataset ID | Logical path | Generated | SHA-256 | 処理地点 | 差分状態 |
|---|---|---|---|---|---|
| `PA-PROCESSED-20260822` | `Processed/miku_personal_archive_baseline_20260822.zip` | 2026-08-22 11:12 JST | `9951087ba8519858bf32c7470b30fb2fea752b39d0562d6296db73c05ff6b56d` | 71 ChatGPT conversations、4 external records、7,912 primary visible messages | Baseline。`state/processing_state.json` が次回比較の前回処理地点、`state/diff_report.json` は `mode=baseline` |

本Processed packageはprivate archiveであり、Repositoryへ配置しない。内部の `state/processing_state.json` は会話ID、message IDおよび更新時刻を保持し、次回Exportの新規・変更判定に使用する。

### 2.4 Derived Work Historyと正式反映

| Dataset ID | Logical path | 状態 | Repository反映 |
|---|---|---|---|
| `PA-WORK-HISTORY-20260822` | `Derived/Work_History/` | 23 events。Human Review反映済み、QA PASS。`work_history_events.jsonl` SHA-256: `1a60d77bde61fafd3c23646968e79e4a6b63609ccc8cb10b56cf910fdee7fcaf` | `WH-001`〜`WH-023`を2026-08-28に `07_Note_Production/01_Timeline.md` へ反映済み |

Derived内の `WORK_HISTORY_BASELINE.md`、`work_history_events.jsonl`、`SOURCE_AND_METHOD.md`、`QA_REPORT.md` および `HUMAN_REVIEW.md` は、原本までの詳細な再追跡と再監査のためPersonal Archiveに保持する。通常業務で参照する史実はTimelineを正とし、Derivedを第二の史実正本にしない。

### 2.5 AIORG-S01選定一次資料のRepository反映

| Source checkpoint | 選定範囲 | Repository反映 | 原本保持 |
|---|---|---|---|
| `PA-PROCESSED-20260822` | S01-01〜S01-06に必要なChatGPT message 12件と、S01-06添付5件のasset pointer / size | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/01_Primary_Evidence/`へ原文の必要最小限、conversation / message ID、日時、用途、未取得事項を2026-08-28に反映 | 会話全体、添付画像本体、無関係な私的会話はOneDrive Personal Archive外へ移さず、Repositoryへ複製しない |

この反映は新しいProcessed checkpointを生成していない。元snapshotと処理地点は`PA-PROCESSED-20260822`のままであり、本PackageはSection固有Supporting Sourceである。Timeline、Human-approved成果物またはOriginal / Processed packageの代替にしない。

### 2.6 AIORG-S01 Human-approved制作baseline

| Dataset ID | Logical path | SHA-256 / 状態 | Repository反映 |
|---|---|---|---|
| `EXT-PA-AIORG-S01-FC` | `Derived/AI_Organization_Series_Section1_Final_Candidate.md` | `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2` / Story 6、Practice 6はHuman Final Check完了。Archive 6はHuman-approved baselineかつ後発仕様に対し`Revision Required` | 本文はPublic Repositoryへ複製せず、18本文のlocator、approval、Cloud readinessを`07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/02_Human_Approved_Source_Inventory.md`へ反映 |
| `EXT-PA-AIORG-S01-AUDIT` | `Derived/AI_Organization_Series_Section1_External_Audit_Reconciliation.md` | `FC3C79B46C276F14F109EB1AC440FC8E17691EAF5D90EA30E4E4EAE238D9A5F6` / Internal Re-Audit PASS、Final Candidate SHA一致 | Registry ID `EXT-PA-AIORG-S01`と上記Inventoryから再追跡 |

Final Candidate内のSession Archive 6件を現行のHuman-approved baselineとする。note投入用一覧、Session別抽出またはAudit Routingはdownstream／provenanceであり、本文正本として採用しない。Cloud可読なprivate Sourceへの昇格はHuman Decision後に行い、その時点でcanonical SourceとOneDrive provenanceの責任を更新する。

### 2.7 その他のPersonal Archive

- `Original/X/` のX Archiveは約9.54GBの増分型個人一次資料であり、Repositoryへ置かない。Voice OS等へ採用済みの判断だけを各正式Sourceから参照する。
- `Voice/` は本運用Source策定前から存在する既存例外であり、`INBOX_AND_PERSONAL_ARCHIVE.md` §22に従い、別監査なしに移動・再分類しない。
- `Derived/note_source_idea_bank_*` は候補・分析であり、Timeline、Section制作台本または公開済み最終稿の代替正本にしない。
- Claude監査原本とRouting結果は、監査provenanceとしてPersonal Archiveに保持する。正式Sourceまたは承認主体として扱わない。

## 3. GPT Archiveの増分取得・差分反映経路

次回以降のChatGPT Exportは、次の経路で処理する。

1. 新しいExportをOneDrive `AI/00_Inbox` で受領する。
2. `INBOX_AND_PERSONAL_ARCHIVE.md` に従い、安定性、archive manifest、SHA、センシティブ性、重複および取得アカウントを確認する。
3. 未改変Exportを `AI/04_Personal_Archive/Original/ChatGPT/` へcopy-onlyで配置し、Inbox copyとSHAを照合してauthoritative copyを確定する。同一SHAを重複保持せず、異なるSHAを上書きしない。
4. 直前のProcessed snapshot内 `state/processing_state.json` を前回処理地点として使用し、`account + conversation_id + message_id` と更新時刻を比較する。新規・変更分だけを候補queueへ渡し、削除・非表示・分岐の差異を推測で補完しない。
5. 新しいProcessed snapshotは旧snapshotを上書きせず、生成日を識別できるimmutable packageとして `Processed/` へ配置する。処理方法、処理Version、元OriginalのSHA、差分件数および次回用checkpointをpackage内に保持する。
6. 本IndexのOriginal registry、最終取得地点、Processed checkpointおよび差分件数を更新する。生ログ本文またはセンシティブ内容は記録しない。
7. Work History候補は一次メッセージへ戻って確認し、事実と推論、同時点Evidenceと後日回顧を分け、必要なHuman ReviewとQAを通す。
8. 確認済みの史実だけを `07_Note_Production/01_Timeline.md` へ追加し、本Indexの反映範囲を更新する。Voice、Human OS、Brand、Educationその他の正式判断へ反映する場合は、各責任SourceのProduction、QA、Approval、CHANGELOGおよびGit工程を別途通す。
9. Inbox側処理とClosedは `INBOX_AND_PERSONAL_ARCHIVE.md` を正とする。自動除去制度がDisabledの間は自動除去しない。

現時点の最終取得地点は2026-08-20 Export、前回処理地点は `PA-PROCESSED-20260822`、Timeline反映地点は `PA-WORK-HISTORY-20260822` の `WH-023`、AIORG-S01選定一次資料のRepository反映地点は同Sectionの`01_Primary_Evidence/`、Human-approved本文メタデータの反映地点は同Sectionの`02_Human_Approved_Source_Inventory.md`までである。

## 4. 更新規則

- OriginalまたはProcessedの追加、checkpoint更新、正式Sourceへの反映範囲変更時に本Indexを更新する。
- 原本の同一性はSHAまたは同等の内容識別で確認し、ファイル名、サイズまたは更新日時だけで同一としない。
- Repositoryへ原本を移さない判断を、原本不要または削除可能という判断へ読み替えない。
- Personal Archiveのローカル存在とOneDriveクラウド同期完了を区別する。同期を確認できない場合は未確認と記録する。
- 本Indexの変更は `04_AI_Work_Environment/CHANGELOG.md`、Repository全体の参照構造へ影響する変更はルート `CHANGELOG.md` へ記録する。

## 5. 関連Source

- `04_AI_Work_Environment/EXTERNAL_REFERENCE_REGISTRY.md`
- `04_AI_Work_Environment/INBOX_AND_PERSONAL_ARCHIVE.md`
- `04_AI_Work_Environment/AI_WORK_ENVIRONMENT.md`
- `07_Note_Production/01_Timeline.md`
- `07_Note_Production/README.md`
- `REPOSITORY_RULES.md`
- `AI_PRODUCTION_PIPELINE.md`
