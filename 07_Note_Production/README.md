# 07_Note_Production

**Status:** Current / Operational v1.8
**責任:** noteの企画・制作・公開準備・公開後記録およびSession単位のSNS展開を、既存AI Production Pipelineへ接続する媒体別運用

## この領域の入口

`07_Note_Production/` は、noteの本文とSNS展開に固有の制作・公開運用を担うトップレベル責任領域である。人間承認、Source Router／Source QA、Output QA、Repository横断監査、Gitの判断を複製せず、それぞれの現行Sourceを呼び出す。

| 正本 | 用途 |
|---|---|
| `00_note制作・公開システム.md` | noteの制作・公開・再開・復旧を接続するSOP |
| `01_Timeline.md` | **唯一のTimeline正本**。一次資料から抽出した実際の出来事と参照情報を時系列で保持。Repository外Archiveのdataset / checkpointは `04_AI_Work_Environment/ARCHIVE_PROVENANCE_INDEX.md` から再追跡 |
| `02_全体ロードマップ.md` | **全体ロードマップ正本**。採用済みSectionの優先順位・現在地を管理 |
| `03_SNS展開基準.md` | Session単位のSNS制作・投稿承認・接続状態 |
| `10_Section制作台本テンプレート.md` | 意味づけ・企画で採用されたSectionの制作台本テンプレート |
| `11_公開成果物記録テンプレート.md` | 公開済み最終稿と公開事実の記録テンプレート |
| `CHANGELOG.md` | 本領域の意味ある変更履歴 |

## 現行・Archive・実データ

このディレクトリ直下の上記ファイルが現行の運用正本であり、`Current/` は作らない。旧版が実際に生じ、保持する必要がある場合だけ `03_Archive/` を作成し、通常参照対象から除く。CHANGELOGは過去の実物を保存しない。

新規Sectionまたは公開記事の実データ用ディレクトリは、実データが生じるまで作らない。作成時のcanonical pathと命名は次のとおりとする。

- Section制作記録：`07_Note_Production/01_Sections/<Section-ID>_<短い識別名>/00_Section制作台本.md`
- Section固有Primary Evidence：`07_Note_Production/01_Sections/<Section-ID>_<短い識別名>/01_Primary_Evidence/README.md`とSession別Evidence。Repository外の会話全体を複製せず、Cloud制作に必要な最小抜粋、永続ID、文脈、未取得事項を保持する場合だけ作成する
- Section固有Human-approved Source Inventory：未公開本文をPublic Repositoryへ配置できない場合、同Section配下の既存責任内で本文を含まないInventoryを置き、Human approval、Private repository／artifact／commit／file SHA、本文locator、provenance、Cloud可読性および正式参照経路を管理する。AIORG-S01の正本は`01_Sections/AIORG-S01_AI基礎工事/02_Human_Approved_Source_Inventory.md`
- SessionのStory公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/01_Story無料Hub_最終稿.md`
- Sessionの実践編公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/02_実践編単品有料_最終稿.md`
- SessionのMS奮闘記公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/03_MS奮闘記メンバーシップ限定_最終稿.md`
- 同Sessionの公開成果物記録：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/04_公開成果物記録.md`

上記3記事構成は既定Profileである。Section制作台本にHuman承認済みの公開構成Profileがある場合は、そのProfileを正とする。AI Organization Series Section 1では、S1-1〜S1-6それぞれについてStory＋Practiceを1本のnote本編 `01_note本編_最終稿.md` とし、Session Archiveはnote本編から分離する。Session Archiveは公開範囲とMembershipでの扱いがHuman承認された場合だけ `02_Session_Archive_最終稿.md` として配置する。

`<Section-ID>` は全体ロードマップで採番する `S01` 形式、`<Session-ID>` は同Section内の `S01-01` 形式とする。日本語の識別名は内容が分かる短いcanonical nameとし、日付・`完成版`・`更新版`・連番をファイル名へ付けない。制作中の稿、未承認の公開情報、認証情報はこれらの正本領域へ保存しない。

Statusは、Section制作台本と全体ロードマップで `Planning`／`Production`／`Review`／`Decision Pending`／`Revision Required`／`Approved`／`Scheduled`／`Published/Complete`／`Update Candidate` を記録する。`Decision Pending`と`Revision Required`はPublish前の状態であり、外部公開を意味しない。完成判定は固定の3記事数ではなく、当該Sectionの承認済み公開構成Profileに基づく。公開済み最終稿では `Published`、公開停止または置換済みでは `Superseded` と記録する。`Published` は公開事実であり、上位Sourceの承認を代替しない。公開済み最終稿だけが将来の参照・SNS再展開・Repository還元に用いる記事本文の正本であり、Work稿や下書きを代替正本にしない。

実データの作成・更新はProduction／Repository Integrationが担い、公開可否・価格・自己開示はHuman Owner／Approverが担う。配置、Archive、CHANGELOG、Gitは `REPOSITORY_RULES.md` に従う。

Primary Evidence Packageは、記事本文、唯一のTimeline正本、Section制作台本、Human-approved成果物またはPersonal Archiveを代替しない。Packageの`READY`と、Repositoryだけで既存承認済み本文を保持して制作・QAを完了できる`Cloud completion READY`は分けて判定する。

Public Repositoryでは、Human-approvedであっても未公開・有料予定・公開範囲未決の本文をCloud参照だけのために配置しない。格納基準を満たす本文は全社共通Private Source Repositoryへexact copyで昇格し、Public側Inventoryと外部参照Registryへrepository identifier、path、artifact ID、commit SHA、file SHA、provenance、StatusおよびE2E結果だけを同期する。Private配置だけでCloud Readinessを`READY`にしない。

## 必ず戻る既存Source

- 共通工程：`AI_PRODUCTION_PIPELINE.md`
- 承認・停止・外部操作：`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- AIの役割・受け渡し：`AI_ORGANIZATION.md`
- 構造・履歴・Git：`REPOSITORY_RULES.md`
- Repository横断変更：`REPOSITORY_CROSS_AUDIT_STANDARD.md`
- Repository外原本の取得・差分反映地点：`04_AI_Work_Environment/EXTERNAL_REFERENCE_REGISTRY.md`
