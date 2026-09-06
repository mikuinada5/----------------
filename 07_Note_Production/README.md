# 07_Note_Production

**Status:** Current / Operational v1.21 / Repository Master Asset compatible
**責任:** noteの企画・制作・Marketing Review・Header Production・公開準備・Publication Transaction・公開後記録およびSession単位のSNS展開を、既存AI Production Pipelineへ接続する媒体別運用

## この領域の入口

`07_Note_Production/` は、noteの本文とSNS展開に固有の制作・公開運用を担うトップレベル責任領域である。人間承認、Source Router／Source QA、Output QA、Repository横断監査、Gitの判断を複製せず、それぞれの現行Sourceを呼び出す。

常設Cloud WorkからGitHubへWRITEできるのは、原則として`02_Published/AIDAILY/<Article-ID>/`の新規Article ID領域だけである。既存Articleの上書き、Timeline、領域／Repository CHANGELOG、SOP、Publication Approval実装その他の共通Source更新はLocal Codexへ分離する。具体的なownerとpreflightは`04_AI_Work_Environment/Repository_Governance/`を正とする。

| 正本 | 用途 |
|---|---|
| `00_note制作・公開システム.md` | noteの制作、Marketing Review、Header Production、Final Review、G5自動検証、Publication Transaction、公開後検証、再開、復旧を接続するSOP |
| `01_Timeline.md` | **唯一のTimeline正本**。一次資料から抽出した実際の出来事と参照情報を時系列で保持。Repository外Archiveのdataset / checkpointは `04_AI_Work_Environment/ARCHIVE_PROVENANCE_INDEX.md` から再追跡 |
| `02_全体ロードマップ.md` | **全体ロードマップ正本**。採用済みSectionの優先順位・現在地を管理 |
| `03_SNS展開基準.md` | Session単位のSNS制作・投稿承認・接続状態 |
| `10_Section制作台本テンプレート.md` | 意味づけ・企画で採用されたSectionの制作台本、稿状態、Marketing Review／Header／Publication Decision記録テンプレート |
| `11_公開成果物記録テンプレート.md` | Final Review Package、Human Final / Publication Approval、Publication Bundle handoff、G5、Transaction、公開済み最終稿・Header・公開事実の記録テンプレート |
| `Publication_Approval/` | note専用Final Review Package Compiler、Publication Bundle Builder／Work受取validator、Package／Approval Schema、G5 identity validator、無停止Publication E2E検証 |
| `CHANGELOG.md` | 本領域の意味ある変更履歴 |

AIDAILY HeaderのCurrent Visual Sourceは`00_note制作・公開システム.md`内の`NOTE HEADER MASTER TEMPLATE v1.0`とmachine-readable profile `aidaily-header-v1`である。Master binaryとmanifestは`04_AI_Work_Environment/Visual_Production/assets/`のGitHub Current Sourceから自己完結して解決する。OneDrive版は由来保存でありProduction依存ではない。`NOTE_HEADER_REQUIRED`はLocal Codex `visual-production-bridge`へrouteし、Master／Contract／actual request／Bridge receipt／Asset QA／Human Approval／Article ID／exact display titleが全一致した`FORMAL_HEADER_ASSET`だけをFinal Review Packageへ渡す。Chat／Work built-in direct画像は`UNVERIFIED_NON_ASSET`であり、Human OKでも遡及昇格しない。

## 現行・Archive・実データ

このディレクトリ直下の上記ファイルが現行の運用正本であり、`Current/` は作らない。旧版が実際に生じ、保持する必要がある場合だけ `03_Archive/` を作成し、通常参照対象から除く。CHANGELOGは過去の実物を保存しない。

新規Sectionまたは公開記事の実データ用ディレクトリは、実データが生じるまで作らない。作成時のcanonical pathと命名は次のとおりとする。

- Section制作記録：`07_Note_Production/01_Sections/<Section-ID>_<短い識別名>/00_Section制作台本.md`
- Section固有Primary Evidence：`07_Note_Production/01_Sections/<Section-ID>_<短い識別名>/01_Primary_Evidence/README.md`とSession別Evidence。Repository外の会話全体を複製せず、Cloud制作に必要な最小抜粋、永続ID、文脈、未取得事項を保持する場合だけ作成する
- Section固有Formal Baseline Source Inventory：未公開本文をPublic Repositoryへ配置できない場合、同Section配下の既存責任内で本文を含まないInventoryを置き、Human approvalまたは正式baseline指定、Private repository／artifact／commit／file SHA、本文locator、provenance、Cloud可読性および正式参照経路を管理する。AIORG-S01の正本は`01_Sections/AIORG-S01_AI基礎工事/02_Human_Approved_Source_Inventory.md`
- SessionのStory公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/01_Story無料Hub_最終稿.md`
- Sessionの実践編公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/02_実践編単品有料_最終稿.md`
- SessionのMS奮闘記公開済み最終稿：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/03_MS奮闘記メンバーシップ限定_最終稿.md`
- 同Sessionの公開成果物記録：`07_Note_Production/02_Published/<Section-ID>/<Session-ID>/04_公開成果物記録.md`
- Section／Session外で正式採用されたSeries articleの公開済み最終稿：`07_Note_Production/02_Published/<Series-ID>/<Article-ID>/01_記事最終稿.md`
- 同Series articleのHeader Asset記録：`07_Note_Production/02_Published/<Series-ID>/<Article-ID>/02_Header Asset記録.md`
- 同Series articleの公開成果物記録：`07_Note_Production/02_Published/<Series-ID>/<Article-ID>/03_公開成果物記録.md`

上記3記事構成は既定Profileである。Section制作台本にHuman承認済みの公開構成Profileがある場合は、そのProfileを正とする。AI Organization Series Section 1では、S1-1だけStory＋Practiceを1本のnote本編`01_note本編_最終稿.md`として維持し、Session ArchiveはHuman承認時だけ`02_Session_Archive_最終稿.md`として分離する。S1-2以降はStory、Practice、Session Archiveを独立記事／成果物として扱い、既定3記事pathを使用するか、Section制作台本にHuman-approvedのcanonical path対応を明記する。公開範囲とMembershipでの扱いが未承認のSession Archiveは配置・公開しない。

`<Section-ID>` は全体ロードマップで採番する `S01` 形式、`<Session-ID>` は同Section内の `S01-01` 形式とする。`<Series-ID>`と`<Article-ID>`はHuman-approvedの既存識別子を使用し、AIが新しいSeriesまたは採番規則を推測で作らない。日本語の識別名は内容が分かる短いcanonical nameとし、日付・`完成版`・`更新版`・連番をファイル名へ付けない。制作中の稿、未承認の公開情報、認証情報はこれらの正本領域へ保存しない。

Statusは、Section制作台本と全体ロードマップで `Planning`／`Production`／`Review`／`Decision Pending`／`Redesign Required`／`Revision Required`／`Approved`／`Scheduled`／`Published/Complete`／`Update Candidate` を記録する。`Redesign Required`は現行baselineを保持して構成・完了条件から再設計する状態、`Revision Required`は現行baselineの限定修正が必要な状態であり、どちらもPublish前で外部公開を意味しない。完成判定は固定の3記事数ではなく、当該Sectionの承認済み公開構成Profileに基づく。公開済み最終稿では `Published`、公開停止または置換済みでは `Superseded` と記録する。`Published` は公開事実であり、上位Sourceの承認を代替しない。公開済み最終稿だけが将来の参照・SNS再展開・Repository還元に用いる記事本文の正本であり、Work稿や下書きを代替正本にしない。

Marketing ReviewはSection Statusを増やさず、`Marketing Input Pending`／`Marketing Revision Required`／`Marketing Approved`／`Human Decision Required`のsubstatusとしてSection制作台本へ記録する。Marketingは内容完成稿である第2稿から開始し、本文を直接修正せずRequirementを返し、無料／Membership境界、Membership、Magazine、price、tagsその他の必要条件を含むPublication Decisionを確定する。Marketing Approved後にHeader Productionを別Phaseで開始し、共通Visual Production ControlのGeneration Contract、Prompt Assembly QA、Runtime Request Binding、生成後Header QAを通す。現行ではLocal CodexのRepository Skill request-bound経路だけをgoverned生成として使用し、Chat／Work built-in direct生成はPlatform BoundaryでBLOCKする。QA PASS候補へのHuman Approval後にFormal Promotion Gateを通したHeader、D3全文、Marketing PASS Evidence、Publication Conditions、Source Manifestおよび公開先を`Publication_Approval/`の決定論的Compilerへ渡し、Schema／実file SHA／Formal Header provenance／identity／Human提示8区分を検証した`READY_FOR_FINAL_REVIEW / PENDING`のPackageだけをHumanへ一括提示する。PackageへのHumanの明示的進行意思を別ArtifactのFinal Approval / Publication Approvalとしてbindingし、承認後はsealed Publication Bundleと単一ZIPを自動生成する。HumanはZIPを常設note公開Workへ一度渡し、WorkはBundleとPackage IDを再検証して`HANDOFF_VERIFIED`後にG5へ進む。同一ならnote反映からpublish、PPVまで再承認なしで継続する。完全自動Chat→Work Transportは未実装である。

未公開本文を含む詳細Marketing Review、Requirementおよび第2稿・第3稿は、本文と同じ承認範囲のWork、Private Sourceまたは指定Archiveに保持する。Public側のSection制作台本には安全なRun ID、status、locator、Decision要約、Gateおよび再開条件だけを置き、公開済み最終稿領域へ先行配置しない。

実データの作成・更新はProduction／Repository Integrationが担い、Final Review PackageへのHuman Final Approval / Publication Approvalと、未解決の価格・自己開示その他のHuman DecisionはHuman Owner／Approverが担う。G5は新しい承認を取りに行かず、`HANDOFF_VERIFIED`のBundle内Evidenceと実際の公開対象を検証する。Bundle内Publication ConditionsはTransaction時のPublication Settings再構成に使うCanonical Inputであり、設定が下書きへ永続化されることを前提にしない。配置、Archive、CHANGELOG、Gitは `REPOSITORY_RULES.md` に従う。

Primary Evidence Packageは、記事本文、唯一のTimeline正本、Section制作台本、Human-approved成果物またはPersonal Archiveを代替しない。Packageの`READY`、Cloud AIがHumanの資料運搬なしで正式Sourceへ到達できる`Source Retrieval Readiness`、SourceのStatusと必要Gateを含め最終成果物まで進められる`Production Completion Readiness`は分けて判定する。

Public Repositoryでは、Human-approvedであっても未公開・有料予定・公開範囲未決の本文をCloud参照だけのために配置しない。格納基準を満たす本文は全社共通Private Source Repositoryへexact copyで昇格し、Public側Inventoryと外部参照Registryへrepository identifier、path、artifact ID、commit SHA、file SHA、provenance、StatusおよびE2E結果だけを同期する。Private配置だけでSource Retrievalを`PASS`にせず、実機探索で確認する。Source Retrieval `PASS`だけでHuman approvalまたはProduction Completionを`READY`にしない。

## 必ず戻る既存Source

- 共通工程：`AI_PRODUCTION_PIPELINE.md`
- 承認・停止・外部操作：`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- AIの役割・受け渡し：`AI_ORGANIZATION.md`
- 構造・履歴・Git：`REPOSITORY_RULES.md`
- Repository横断変更：`REPOSITORY_CROSS_AUDIT_STANDARD.md`
- Repository外原本の取得・差分反映地点：`04_AI_Work_Environment/EXTERNAL_REFERENCE_REGISTRY.md`
