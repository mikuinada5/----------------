# AIORG-S01 Primary Evidence Package

**Status:** Current / Source QA PASS / Source Retrieval E2E PASS / Production Completion NOT READY<br>
**Section ID:** AIORG-S01<br>
**QA date:** 2026-08-29<br>
**責任:** S01-01〜S01-06の制作・照合に必要な一次資料のうち、Repositoryへ安全に置ける必要最小限の抜粋、識別子、文脈およびprovenanceを保持する

## 1. 位置づけ

本Packageは記事本文、Timeline、Section制作台本、Human-approved成果物またはPersonal Archiveの代替ではない。PC内Archiveへ到達できないCloud Codexが、Session IDから一次資料へ辿り、確認済み事実と未確認事項を区別するためのSection固有Supporting Sourceである。

参照順は次のとおりとする。

`Session ID` → `../00_Section制作台本.md` → `../02_Human_Approved_Source_Inventory.md` → `../../../01_Timeline.md` → 本Packageの該当Session → `../../../00_note制作・公開システム.md`

Repository外原本へ遡る場合は、`../../../../04_AI_Work_Environment/EXTERNAL_REFERENCE_REGISTRY.md` と `../../../../04_AI_Work_Environment/ARCHIVE_PROVENANCE_INDEX.md` を使用する。

## 2. Source境界

| 区分 | 識別情報 | 取扱い |
|---|---|---|
| ChatGPT Original / Processed | `PA-CHATGPT-MAIN-20260820` / `PA-PROCESSED-20260822`、Processed SHA-256 `9951087ba8519858bf32c7470b30fb2fea752b39d0562d6296db73c05ff6b56d` | 選定した本人・AI発言の原文だけを転記。会話全体と添付画像はRepository外 |
| Codex Task Original | Registry ID `EXT-CODEX-AIORG-MAP`、thread `01a0317f-f4e8-76c0-9bdd-143d02aa03d3` | S01-01の後日回顧。元出来事と回顧日時を区別 |
| Repository Git history | 各Sessionファイル記載のfull commit SHA | Repository内Original eventとしてGit objectから再確認可能 |
| Formal baseline output | `../02_Human_Approved_Source_Inventory.md`、Registry ID `EXT-PSR-AIORG-S01`、Private artifact `PSR-AIORG-S01-FC`、source commit `0531e32239237b7bd5f011bca62d65f5d9d4317e`、Final Candidate SHA-256 `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2` | 本Packageへ本文を複製しない。StoryはHuman Final Check完了、S1-1 Practiceは既存Status継続、S1-2〜S1-6 PracticeはHuman Review Draft／`Redesign Required`、Session ArchiveはHuman-approved baseline／`Revision Required` |

抜粋は原文を意味変更せず転記し、無関係な前後発言だけを省略した。各一次資料項目自体はHuman-approved成果物ではない。記事への採否、自己開示、価格、公開範囲およびPublishは既存Human Gateに従う。

## 3. Session readiness

| Session | Evidence file | Primary Evidence Package | Source Retrieval | Production Completion / 不足・Blocker |
|---|---|---|---|---|
| S01-01（S1-1） | `S01-01.md` | READY | PASS | NOT READY / Session Archive再監査待ち |
| S01-02（S1-2） | `S01-02.md` | READY | PASS | NOT READY / Practice再設計、Session Archive再監査待ち |
| S01-03（S1-3） | `S01-03.md` | READY（制限付き） | PASS | NOT READY / Practice再設計、Archive再監査。「前に話したじゃん」の一致する一次ログを未取得 |
| S01-04（S1-4） | `S01-04.md` | READY | PASS | NOT READY / Practice再設計、Session Archive再監査待ち |
| S01-05（S1-5） | `S01-05.md` | READY（制限付き） | PASS | NOT READY / Practice再設計、Archive再監査。「最新／最終／最終2」に一致する本人一次発言を未取得 |
| S01-06（S1-6） | `S01-06.md` | READY（制限付き） | PASS | NOT READY / Practice再設計、Archive再監査。一部画像本体と4表現のmessage IDを未取得 |

`Primary Evidence Package READY`は、記載EvidenceをCloudから確認・再追跡できる状態を表す。2026-08-29のスマホWork Cloud実測によりPrivate本文を含むSource Retrieval E2Eは`PASS`した。これはPractice／Archiveの改訂状態やProduction Completionを`READY`にするものではない。

## 4. Human-approved成果物との照合

確認できた一次資料と、制作台本に保持されたタイトル・Story・Practice・Session Archiveの役割に重大な意味矛盾は見つからなかった。18本文の同一性、本文種別ごとのStatusおよびArchive baselineは`../02_Human_Approved_Source_Inventory.md`を正とする。既存本文は変更していない。Primary EvidenceのHuman本人一次ログは、Practiceの初心者停止点を抽出し、本文での先回り説明、FAQ、Troubleshooting、注意事項または対象外へ分類するために用いる。PracticeとSession Archiveの責任を混同しない。S01-03、S01-05、S01-06の上表記載表現は、一次ログの一致を独立確認できていないため、本Packageから原文引用として使用してはならない。

## 5. Privacy / QA

- 会話全体、不要な私的会話、第三者情報、credential、secret、tokenは収録しない。
- 添付画像はasset pointerとsizeだけを保持し、画像本体はRepositoryへ複製しない。
- 原本の論理path、Dataset ID、conversation / thread / message ID、日時を組み合わせて再追跡する。
- 原文未取得箇所は、既存記事や記憶から再生成しない。
- 新しいArchive差分を取得した場合は、`ARCHIVE_PROVENANCE_INDEX.md` のcheckpoint更新後に該当Sessionと本Indexを再QAする。
