# REPOSITORY_RULES

## 1. このファイルの目的

このファイルは、`フェミニンウェルネス生涯教育事業`
リポジトリ全体に共通する、ディレクトリ構造・ファイル配置・仕様書・成果物・根拠資料・変更履歴の基本運用ルールを定義する。

ブランド、教育設計、各コース、AI組織、制作物など個別領域の内容そのものは、それぞれの責任ファイルで定義する。

本ファイルは、それらをどのように配置・管理・更新するかという**リポジトリ運用上の共通ルール**を扱う。

------------------------------------------------------------------------

## 2. 基本原則

### 2.1 現在有効な内容と履歴を分離する

各仕様書・基準書には、原則として**現在有効な内容のみ**を記載する。

過去のルール、旧仕様、修正前の文章、変更理由などを本文へ蓄積しない。

現在の判断に必要な情報と、過去の変更履歴を分離することで、AIと人間の双方が最新版を迷わず参照できる状態を維持する。

### 2.2 責任単位ごとに管理する

ファイルやディレクトリは、「何の資料か」だけではなく、**どの責任単位に属するか**を基準に配置する。

教育領域では、少なくとも以下を区別する。

-   全Course共通の教育設計基準
-   コース固有基準
-   個別講座・Sessionの教育設計
-   全Course共通の教材制作基準
-   制作成果物
-   制作後レビュー
-   教育根拠・参照資料
-   過去版

同じ内容を複数階層へ無制限に重複させない。

### 2.3 意味のある変更履歴はCHANGELOGへ集約する

独立して変更履歴を管理する必要がある単位には、原則としてその領域のルートに
`CHANGELOG.md` を配置する。

例：

-   `00_Brand/CHANGELOG.md`
-   `02_Voice_OS/CHANGELOG.md`
-   `01_Education/00_Core/CHANGELOG.md`
-   `01_Education/01_Courses/Aコース/00_CourseOS/CHANGELOG.md`
-   `01_Education/01_Courses/Aコース/01_Front/CHANGELOG.md`
-   `01_Education/01_Courses/Aコース/02_Professional/CHANGELOG.md`
-   `01_Education/02_Material_Production/CHANGELOG.md`

CHANGELOGの書式は可能な限り共通化し、記録対象のみを各責任領域に限定する。

### 2.4 軽微な変更はGitで管理する

以下のような変更は、原則として `CHANGELOG.md`
へ記録せず、Gitのコミット履歴で管理する。

-   誤字脱字の修正
-   表記ゆれの統一
-   Markdown整形
-   改行・見出し等の軽微な整理
-   意味や判断基準を変更しない文章調整

### 2.5 正式ファイル名は内容の識別に用いる

現行正式Sourceのファイル名は、原則として**そのファイルが何であるかを識別するためのcanonical filename**とする。

正式採用後のファイル名へ、作業工程・提出状態・一時的な識別のための文字列を残さない。

例：

-   `_更新版`
-   `_監査提出版`
-   `_監査再提出版`
-   `_ブランドOS同期版`
-   `_完成版`
-   `(2)`、`(9)` 等の自動付与番号
-   作業上のみ必要な日時文字列

これらは作業中の一時識別には使用できるが、Repositoryへ現行正式Sourceとして配置する際はcanonical filenameへ統一する。

ファイルの変更履歴はGitおよびCHANGELOGで管理し、承認状態・正式使用可否は当該領域の正式なQA・承認工程に従って判断する。

ファイル名だけを根拠として、最新版・承認済み・正式使用可能であると判断しない。

責任単位ごとのCurrent canonical Sourceは、原則としてcanonical filenameへ統合する。承認済み変更を`Current / Canonical Delta`、`差分正本`、version付き別filenameその他の並列Currentとして恒久運用しない。差分受領物は統合前の作業Inputとして扱い、正式採用時にcanonical Sourceへ統合し、変更理由と旧状態はGitおよびCHANGELOGで追跡する。Gitだけでは保持要件を満たさない過去の実物がある場合に限りArchiveへ移す。

Brand OSのように一つの責任単位を複数のCurrent canonical Sourceで構成する場合は、正式entry sourceがその構成ファイルを漏れなく列挙し、Source Routerがentry sourceから責任単位全体を解決できる状態を必須とする。固定pathを直接開いたことだけで責任単位のCurrent Sourceを解決済みと判定しない。

Source更新を後続Productionへ反映する責任は、ファイル名の記憶や過去Taskの読了状態ではなく、`AI_PRODUCTION_PIPELINE.md`の案件単位Source ResolutionとSource Manifestで担う。責任root／entry sourceの探索、Current候補の選択・除外、依存閉包、同一Taskでの実読、Versionまたはrevision、Repository full commit SHA、file SHA-256および適用範囲が揃わない場合、G2はPASSしない。

------------------------------------------------------------------------

### 2.6 Repository共通の運用Source

Repository全体に共通するAI組織・制作運用・横断監査は、責任ディレクトリを重複新設せず、Repositoryルートの現行正式Sourceとして管理する。

- `AI_ORGANIZATION.md`：AI組織の役割、権限、責任分離および標準受け渡し
- `AI_PRODUCTION_PIPELINE.md`：既存Sourceを案件ごとに選択・実読・適用し、制作からRepository Integrationまでを接続する共通SOP
- `REPOSITORY_CROSS_AUDIT_STANDARD.md`：Repository全体へ影響する正式Source変更の構造・責任・Source・運用・Git準備を横断確認する基準
- `REPOSITORY_RULES.md`：Repository構造、現行／Archive、GitおよびCHANGELOGの具体運用
- `CHANGELOG.md`：上記を含むRepository全体の意味ある変更履歴

これらはそれぞれの専門責任を代替しない。個別のBrand、Voice、Human-in-the-loop、Education、教材制作、公開その他の判断は、該当する責任Sourceを正とする。

Repository全体へ影響する正式Sourceを新規追加・更新・移動・廃止する場合は、`REPOSITORY_CROSS_AUDIT_STANDARD.md` を適用し、必要な導線・CHANGELOG・Git自己監査まで完了させる。

------------------------------------------------------------------------

### 2.7 Public / Private Source Repositoryの責任分離

会社Sourceは、公開可能な現Repositoryと、Human-approved非公開制作Sourceを保持するPrivate Repository `mikuinada5/feminine-wellness-private-sources`を責任に応じて併用する。

- 現Public RepositoryはOS、Rules、SOP、Pipeline、公開可能なEvidence、Timeline、制作台本、locator、provenance metadata、SHA、StatusおよびCloud Readinessの正本を保持する。未公開・有料予定・公開範囲未確定の本文はCloud参照だけのために配置しない。
- Private Repositoryは、格納基準を満たすHuman-approved未公開本文、有料予定本文、公開範囲未確定本文およびCloud制作で正式参照が必要な非公開制作Sourceの正本を保持する。具体規則は同Repositoryの`PRIVATE_SOURCE_RULES.md`を正とする。
- 同一本文を両RepositoryでCurrentな正本として重複保持しない。Public側はPrivate側のrepository locator、canonical path、artifact ID、full commit SHA、file SHA、provenance、Version／StatusおよびCloud Readinessだけを保持する。
- Privateであることは、credential、顧客情報、機微な個人情報、生会話、GPT Archive Original、外部サービスOriginal、大容量Archiveまたは端末固有設定の格納を許可しない。
- Private側の更新・QA・commit・pushはLocalで行い、Work Cloudはread用途とする。実機Source Discovery成功前にCloud Readinessを`READY`にしない。

------------------------------------------------------------------------

## 3. Brand領域の基本構造

Brand領域は、単一の巨大な仕様書ではなく、責任本籍ごとに分割したBrand OSとして管理する。

基本構造は以下とする。

``` text
00_Brand/
├── 00_ブランドOS概要・参照ガイド.md
├── 01_ブランドCore.md
├── 02_教育ブランド哲学.md
├── 03_ブランド世界観・美意識.md
├── 04_ブランド言語・表現原則.md
├── 05_ビジュアル表現原則.md
├── 06_商品・サービス設計原則.md
├── 07_ブランド体験原則.md
├── 08_ブランドガバナンス・品質原則.md
├── 09_AI共創原則.md
└── CHANGELOG.md
```

`00_ブランドOS概要・参照ガイド.md` は、Brand OS全体の入口・責任案内を担う。

Brand OSを参照する際は、単一ファイルを一律に読むことを前提とせず、まず `00_ブランドOS概要・参照ガイド.md` に基づいて、当該タスクに必要な責任ファイルを選択する。

Brand OSが適用されることと、Brand OSがその領域の具体的な設計・運用責任を持つことは同義ではない。

教育の具体設計、教材制作、AI組織、Repository運用、講師育成・評価・認定、マーケティング、運営等について正式な専門Sourceが存在する場合は、Brand OSの該当原則と専門Sourceの双方を責任に応じて参照する。

旧単一 `ブランドOS.md` は現行判断Sourceとして扱わず、保持する場合はArchiveへ配置する。

Brand OS独自のMajor／Minor／Patch分類は使用しない。変更の事実と差分はGit、意味のある変更の要約と経緯は `00_Brand/CHANGELOG.md` で管理する。

------------------------------------------------------------------------

## 3.1 Voice OS領域の基本構造

`02_Voice_OS/` は、稲田みく本人固有のVoice／コミュニケーション判断を担う正式Sourceを管理する、独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
02_Voice_OS/
├── VOICE_OS.md
└── CHANGELOG.md
```

`VOICE_OS.md` のMissionは、稲田みく本人として文章生成・会話応答を行う際に、本人または相手が実際に到達している思考・感情・情報の地点を越えず、目的・関係性・媒体に応じて、言うこと、言わないこと、質問すること、待つこと、終えること、および表現方法を判断するための横断基準を提供することである。

本Sourceは、稲田みく本人のVoiceを担う文章・会話・発信・教育・QA・業務応答等の箇所に適用する。成果物の形式だけを理由として一律適用せず、当該箇所が誰のVoiceを担うかを確認する。

Brand OSは、ブランド理念、ブランド共通の人格・言語・許容表現・品質等の上位基盤を担う。Voice OSは、その範囲内で稲田みく本人固有のコミュニケーション判断を具体化する専門Sourceであり、Brand OSを上書きしない。両者に矛盾がある場合はBrand OSを優先し、Voice OS側の適用を止めて適切な判断へ戻す。

教育領域では、主任講師AI Core、各CourseOS、承認済み教育設計および適用される教材制作基準が、教育内容、到達目標、問い、ワーク、知識深度、感情設計、講師トーン、成果物Mission等を担う。Voice OSは、これらを上書きせず、稲田みく本人のVoiceで届けることに意味がある箇所の表現判断に限って適用する。Education Sourceと矛盾する場合はEducation Sourceを優先する。

note、SNS、LP、メール、講演台本その他の媒体別・成果物別Sourceは、構成、文字数、書式、CTA、販売導線、制作手順、成果物固有の品質等を担う。Voice OSは媒体固有仕様を決定せず、媒体を横断する本人固有のVoice／コミュニケーション判断を担う。下位Sourceは、上位基準を維持したうえでVoice OSを実装する。

Voice OSは、他講師・認定講師・他人物の固有Voiceへ自動適用しない。教育品質またはブランド品質の統一を理由として、他者のキャラクター・文体・話し方を稲田みく本人のVoiceへ統一しない。

`VOICE_OS.md` は共通Sourceとして `02_Voice_OS/` に集約し、Course、講座、媒体、成果物、個別AI等の下位責任単位へ複製して個別管理しない。必要なタスクから正式配置の現行Sourceを参照する。

Voice OSに関する意味のある変更は `02_Voice_OS/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。軽微な変更、現行Source、過去版およびGitの扱いは、本ファイルの共通ルールに従う。

------------------------------------------------------------------------

## 3.2 Human-in-the-loop領域の基本構造

`03_Human_in_the_Loop/` は、人間とAIの協働における承認境界と停止・進行の横断運用を担う正式Sourceを管理する、独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
03_Human_in_the_Loop/
├── HUMAN_IN_THE_LOOP.md
└── CHANGELOG.md
```

`HUMAN_IN_THE_LOOP.md` のMissionは、人間とAIの協働において、承認の有効範囲、自動進行条件、停止条件、再承認条件、エスカレーション、AI間衝突、自己復旧、スコープ管理および完了判断を横断的に定義することである。

本Sourceは、Brand OS、`AI_ORGANIZATION.md`、Repository運用、Education Source、Voice OSその他の専門Sourceが持つ責任を移管または重複定義しない。個別事項は、その事項の責任本籍を持つ正式Sourceを正とし、本Sourceはその範囲内で人間とAIの停止・進行を接続する。

Brand OSはブランドレベルのAI共創思想および人間の最終責任を担い、`AI_ORGANIZATION.md` はAI組織上の役割・権限・責任分離・受け渡しを担う。本ファイルはRepositoryの構造・Git・CHANGELOGの具体運用を担い、Education Sourceは教育内容・設計・制作・品質・承認を担い、Voice OSは稲田みく本人固有のVoice／コミュニケーション判断を担う。Human-in-the-loop Sourceはこれらを上書きしない。

Human-in-the-loop領域に関する意味のある変更は `03_Human_in_the_Loop/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。軽微な変更、現行Source、過去版およびGitの扱いは、本ファイルの共通ルールに従う。

------------------------------------------------------------------------

## 3.3 AI作業環境領域の基本構造

`04_AI_Work_Environment/` は、Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境を、どの責任段階で使用し、どのように工程接続するかを担う正式Sourceを管理する、独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
04_AI_Work_Environment/
├── AI_WORK_ENVIRONMENT.md
├── INBOX_AND_PERSONAL_ARCHIVE.md
├── ARCHIVE_PROVENANCE_INDEX.md
├── EXTERNAL_REFERENCE_REGISTRY.md
├── Source_Resolution/
│   ├── README.md
│   ├── schemas/
│   ├── scripts/
│   └── tests/
├── Visual_Production/
│   ├── README.md
│   ├── schemas/
│   ├── scripts/
│   └── tests/
├── Pre_Human_Review_QA/
│   ├── README.md
│   ├── schemas/
│   ├── scripts/
│   └── tests/
├── External_Audit_Pipeline/
│   ├── README.md
│   ├── prompts/
│   ├── schemas/
│   ├── src/
│   ├── scripts/
│   ├── tests/
│   └── examples/
└── CHANGELOG.md
```

`AI_WORK_ENVIRONMENT.md` のMissionは、AI組織上の責任を維持したまま、判断、制作、監査、修正、Repository反映および変更管理を適切な作業環境へ接続するための横断原則を定義することである。

`INBOX_AND_PERSONAL_ARCHIVE.md` は、未配属受領物をInboxで受領し、評価、分類、必要な人間判断、正式配属、検証およびClosedまで接続する共通運用と、OneDrive上のPersonal ArchiveにおけるOriginal、ProcessedおよびDerivedの責任境界を定義する専門Sourceである。

`ARCHIVE_PROVENANCE_INDEX.md` は、Repository外に保持する増分型一次資料について、原本識別子、Processed checkpoint、正式Sourceへの反映状態および再追跡経路をRepository側から確認するための運用メタデータ正本である。生ログ、個人資料またはProcessed本文をRepositoryへ複製せず、Personal Archiveそのもの、Inbox Ledger、Timelineまたは各専門Sourceを代替しない。

`EXTERNAL_REFERENCE_REGISTRY.md` は、原本をRepository外に保持する継続参照資料について、取得元、最終取得地点、前回処理地点、正式Sourceへの反映状態および再追跡用識別情報を、秘密情報や原文を含めずRepository側から確認するための管理Sourceである。Inbox Ledger、Personal Archive側provenance、Timelineまたは専門Sourceを代替しない。

両Sourceは競合する正本ではない。継続参照資料の横断的なRegistry IDと反映先は `EXTERNAL_REFERENCE_REGISTRY.md`、Personal Archive上の増分型一次資料に関するDataset ID、SHAおよびProcessed checkpointの詳細は `ARCHIVE_PROVENANCE_INDEX.md` を正とする。

`External_Audit_Pipeline/` は、内部監査PASS後のFinal Candidateから必要最小限の監査Inputを構築し、助言的外部AIへAPI送信し、応答Schema検証とSeverity Routingを行う再利用可能な自動化実装である。外部AIへ制作、承認またはRepository WRITE責任を付与しない。

`Source_Resolution/` は、`AI_PRODUCTION_PIPELINE.md`が定めるSource Router／Source QA／Source Manifestを機械検証する実装である。新しいSource責任または承認者を作らず、Current Canonical Delta、責任root内のCurrent候補未列挙、前Taskの読了証跡、依存漏れおよびSource fingerprint変更をG2またはPre-Human ReviewでFAILさせる。

`Pre_Human_Review_QA/`とRepository Skill `.agents/skills/pre-human-review-qa/`は、同Pipeline §8.5.1の長文本文QA／提示file bindingを実行する実装である。新しい文体Source・役職・承認者を作らず、Writing Style OS、Source Resolutionおよび既存G4へ接続する。Public Repositoryには実装・安全な合成tests・最小provenanceだけを置き、未公開事故稿・QA詳細・提示本文は当該成果物の公開範囲を維持する。

`Visual_Production/` は、同Pipelineが定めるPhase Tool Routing、Generation Contract、Prompt Assembly QA、生成後Asset QAおよび状態遷移を機械検証する実装である。媒体固有のVisual Template、禁止事項、教育内容または承認責任を保持せず、各責任Sourceから解決した要件と実際のTool Request／Asset QAの一致だけを検証する。

Repository rootの`.agents/skills/visual-production-bridge/`は、`Visual_Production/`の既存ControlをLocal Codexの実Tool起動へ接続するRepository Skillである。新しいVisual専門Source、Template正本、AI部署または承認者ではなく、規範は`AI_PRODUCTION_PIPELINE.md`、媒体要件は各専門Source、実装は`04_AI_Work_Environment/Visual_Production/`を参照する。Skill内へ媒体要件本文を複製せず、canonical profileから機械生成する。Chat／Workへ同Skillを配布・配置したと推測せず、環境ごとのRuntime Capability Receiptを必須とする。

OneDrive上の `AI/00_Inbox` および `AI/04_Personal_Archive` は、AI作業環境領域が管理するRepository外の運用対象であり、Repositoryまたは正式Source置場として扱わない。詳細は `INBOX_AND_PERSONAL_ARCHIVE.md` を正とする。

本Sourceは、AI組織上の役割・権限、Human-in-the-loopの承認・停止、Repository・Git・CHANGELOGの具体運用、Brand、EducationおよびVoiceの専門責任を移管または重複定義しない。各事項は、その責任本籍を持つ正式Sourceを正とする。

AI作業環境領域に関する意味のある変更は `04_AI_Work_Environment/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。軽微な変更、現行Source、過去版およびGitの扱いは、本ファイルの共通ルールに従う。

------------------------------------------------------------------------

## 3.4 Human OS領域の基本構造

`05_Human_OS/` は、稲田みく本人の判断原則、保留条件、未知ケースにおける推論境界およびそのEvidence / provenanceを担う独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
05_Human_OS/
├── HUMAN_OS.md
├── HUMAN_OS_EVIDENCE_LOG.md
└── CHANGELOG.md
```

`HUMAN_OS.md` はCurrent Human OSのcanonical Sourceとする。`HUMAN_OS_EVIDENCE_LOG.md` は、本文の判断原則を一次Evidenceへ再追跡するSupporting Evidence / provenance Sourceであり、Human OS本体と同じ責任のcanonical OSとして扱わない。

Human OSは、人間による承認、停止、再承認、エスカレーションおよび完了判断を定める `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` を置き換えない。また、Voice、Writing Style、Brand、Education、AI組織、Repositoryの専門判断を再定義しない。

Human OSに関する意味のある変更は `05_Human_OS/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。

------------------------------------------------------------------------

## 3.5 Writing Style OS領域の基本構造

`06_Writing_Style_OS/` は、稲田みく本人の公開文章・会話文体における構成、リズム、思考の見え方および媒体別強度を担う独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
06_Writing_Style_OS/
├── WRITING_STYLE_OS.md
└── CHANGELOG.md
```

`WRITING_STYLE_OS.md` はCurrent Writing Style OSのcanonical Sourceとする。Human OSが担う判断原則、Voice OSが担う個人固有の対話・表出判断、Brand OSが担うブランド共通表現、媒体別SOPが担う制作・公開手順を代替しない。

Writing Style OSに関する意味のある変更は `06_Writing_Style_OS/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。

------------------------------------------------------------------------

## 3.6 Note Production領域の基本構造

`07_Note_Production/` は、noteの企画・制作・公開準備・公開後記録およびSession単位のSNS展開を、既存AI Production Pipelineへ接続する独立したトップレベル責任単位である。

基本構造は以下とする。

``` text
07_Note_Production/
├── README.md
├── 00_note制作・公開システム.md
├── 01_Timeline.md
├── 02_全体ロードマップ.md
├── 03_SNS展開基準.md
├── 10_Section制作台本テンプレート.md
├── 11_公開成果物記録テンプレート.md
├── Publication_Approval/
│   ├── schemas/
│   ├── scripts/
│   └── tests/
└── CHANGELOG.md
```

`01_Timeline.md` は、GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から抽出した実際の出来事と参照情報を時系列で保持する、note制作における唯一の史実Sourceとする。一次資料の原本をTimelineへ全文複製せず、原本と該当箇所へ戻れる参照を保持する。Timelineの史実は、媒体別SOPで定める意味づけ・企画フェーズを経て、採用された企画だけをSection制作台本へ渡す。意味づけ候補・非採用候補はRepositoryの永続成果物とせず、必要時にTimelineから再生成する。`02_全体ロードマップ.md` は、採用済みSectionの優先順位・現在地を扱う全体ロードマップ正本とする。`00_note制作・公開システム.md` は媒体固有の制作・公開・再開・復旧を定め、Source Router／Source QA／Output QA、Human Approval、Repository横断監査、Gitを再定義せず、該当する既存正式Sourceを呼び出す。`Publication_Approval/`は同SOPが定めるFinal Review Package、Human event、Approval EvidenceおよびG5同一性検証を実行するnote専用実装であり、新しい承認者または他目的へのApproval権限を作らない。

新規Sectionや公開記事の実データ用ディレクトリは、実データが生じるまで作らない。実データが生じた場合のcanonical path、命名、Status、現行／Archiveの扱いは `07_Note_Production/README.md` を正とする。既定の1 SessionはStory（無料Hub）・実践編（単品有料）・MS奮闘記（メンバーシップ限定）の3記事とするが、Section制作台本にHuman承認済み公開構成Profileがある場合はそのProfileを正とする。AI Organization Series Section 1では、S1-1だけStory＋Practiceをnote本編1記事として維持し、S1-2以降はStory、Practice、Session Archiveを独立記事／成果物として扱う。Session Archiveの公開範囲とMembershipでの扱いは別途Human Decisionとし、未決のままStoryまたはPracticeへ混入・公開しない。将来参照する記事本文の正本は、当該Profileに従い公開版と照合された公開済み最終稿だけとし、Work稿、下書き、SNS短縮稿を代替正本にしない。

Section固有の一次資料をCloud制作へ渡す必要があり、会話全体・個人Archive全体をRepositoryへ置かない場合は、当該Sectionの`01_Primary_Evidence/`をcanonical supporting pathとする。配置するのは制作・検証に必要な最小原文、永続ID、日時、Original / Processed / Derived区分、文脈、用途および未取得事項に限定する。同PackageはTimeline、Section制作台本、Human-approved成果物、Archive原本または原本checkpointを代替せず、Package readinessとCloudでの制作完了readinessを分けて記録する。

AIは、人間承認、外部公開、価格、自己開示を代行しない。SNSの接続・認証または正式投稿手段がない場合は、投稿済みと扱わず、未実施状態を記録する。媒体別の制作・実投稿Gateは `03_SNS展開基準.md` を正とする。

Note Production領域に関する意味のある変更は `07_Note_Production/CHANGELOG.md` に記録する。リポジトリ全体の責任構造・配置・参照関係に影響する変更は、あわせてルートの `CHANGELOG.md` に記録する。軽微な変更、現行Source、ArchiveおよびGitの扱いは、本ファイルの共通ルールに従う。

------------------------------------------------------------------------

## 4. 教育領域の基本構造

教育領域は、全Course共通の教育設計基準、Course固有の教育責任、全Course共通の教材制作責任を分離する。

基本構造は以下とする。

``` text
01_Education/
├── 00_Core/
├── 01_Courses/
│   ├── Aコース/
│   ├── Bコース/
│   └── Cコース/
└── 02_Material_Production/
```

`00_Core` は、複数Courseへ共通する教育設計上の原則・基準を担う。

`01_Courses` は、各Course固有の教育思想・到達目標・知識基準・カリキュラム・個別教育設計・根拠資料等を管理する。

`02_Material_Production` は、承認済み教育設計を、教育内容を独自に変更せず、実際に使用可能な教材・講師用成果物へ実装するための全Course共通教材制作システムを管理する。

Course固有の内容を、共通性が確認されていない段階でCoreまたは全Course共通教材制作基準へ昇格させない。

教材制作基準を各Courseへ複製して個別管理せず、全Course共通の正式Sourceを `02_Material_Production` に集約する。

### 4.1 `02_Material_Production`

`02_Material_Production` は、全Course共通の教材制作責任を管理する独立した責任単位である。

基本構造は以下とする。

``` text
02_Material_Production/
├── 00_教材制作システム概要・共通原則.md
├── 01_制作AI_判断・裁量基準.md
├── 02_教材制作・品質保証フロー.md
├── 10_PPT制作基準.md
├── 11_受講者配布資料制作基準.md
├── 12_ワークシート制作基準.md
├── 13_講師進行表制作基準.md
├── 14_講師実施設計制作基準.md
├── 15_講師セルフチェック制作基準.md
├── 20_成果物間整合・情報配置基準.md
├── 21_出典・教材識別・Version管理基準.md
└── CHANGELOG.md
```

本ディレクトリは、以下を担う。

-   教材制作システム全体の共通原則
-   制作AIの判断・裁量範囲
-   教材制作・品質保証フロー
-   成果物種類ごとの制作基準
-   成果物間の情報配置・整合
-   教材識別・Version・Status・出典等の管理基準
-   教材制作責任領域における意味のある変更履歴

本ディレクトリは、Course固有の教育思想・到達目標・知識内容・カリキュラム・個別講座やSessionの教育内容を独自に決定しない。

教育内容の変更が必要な場合は、該当するCore、CourseOSまたは承認済み教育設計へ判断を戻す。

`03`〜`09` および `16`〜`19` の番号が存在しないことのみを理由として欠落と判断しない。現在の番号構成は、責任群を識別するための意図的な構成として扱う。

------------------------------------------------------------------------

## 5. コースの基本構造

各コースは、必要に応じて以下の責任単位を基本形とする。

``` text
コース/
├── 00_CourseOS/
├── 01_Front/
├── 02_Professional/
└── 03_Sources/
```

### 5.1 `00_CourseOS`

コース固有の教育思想・到達目標・知識基準・関係性設計・講師判断・カリキュラム等を管理する。

**「このコースで、誰に、何を、なぜ、どこまで教えるか」**を規定する上位基準であり、個別講座の成果物置き場にはしない。

### 5.2 `01_Front`

フロント講座を独立した教育商品・実施単位として管理する。

現時点の基本構造は以下とする。

``` text
01_Front/
├── 00_Design/
├── 01_Outputs/
├── 02_Review/
├── 03_Archive/
└── CHANGELOG.md
```

-   `00_Design`：承認済み教育設計
-   `01_Outputs`：現行の実施用成果物
-   `02_Review`：制作後レビュー・承認記録
-   `03_Archive`：現行ではない旧版ファイル
-   `CHANGELOG.md`：フロント講座に関する意味のある変更履歴

### 5.3 `02_Professional`

専門講座は、全Sessionを通して一つの教育プログラムとして管理する。

基本構造は以下とする。

``` text
02_Professional/
├── 00_Design/
├── 01_Sessions/
├── 02_Review/
├── 03_Archive/
└── CHANGELOG.md
```

-   `00_Design`：専門講座全体を横断する教育設計
-   `01_Sessions`：各Sessionの設計・成果物・レビュー
-   `02_Review`：専門講座全体を横断するレビュー
-   `03_Archive`：現行ではない旧版ファイル
-   `CHANGELOG.md`：専門講座全体および各Sessionに関する意味のある変更履歴

各Sessionは、原則として以下の構造を使用する。

``` text
Session/
├── 00_Design/
├── 01_Outputs/
└── 02_Review/
```

-   `00_Design`：当該Sessionの教育設計
-   `01_Outputs`：当該Sessionの現行成果物
-   `02_Review`：当該Sessionの制作後レビュー・承認記録

Sessionごとの `CHANGELOG.md` は現時点では設置しない。

Session単位の変更も `02_Professional/CHANGELOG.md`
に対象Sessionを明記して記録する。

将来、Sessionごとの変更履歴が増え、Professional全体のCHANGELOGでの追跡が困難になった場合に限り、分離を検討する。

### 5.4 `03_Sources`

コースの教育設計・制作・レビューにおいて参照する、正式な根拠資料および承認済み内部整理資料を管理する。

基本構造は以下とする。

``` text
03_Sources/
├── 00_Primary/
├── 01_Internal/
└── README.md
```

-   `00_Primary`：外部の原典・一次資料・正式な基準資料
-   `01_Internal`：原典を当該コースで適用するための承認済み内部整理資料
-   `README.md`：当該Sources固有の参照・運用ルール

Sourcesは単なる参考資料倉庫にしない。

調査中の資料、未確認のWeb情報、AIが作成した未承認要約等を、取得しただけで正式な教育根拠として扱わない。

------------------------------------------------------------------------

## 6. Design・Outputs・Reviewの責任分離

個別講座・Sessionでは、原則として以下の制作フローを維持する。

**Design\
↓\
Outputs\
↓\
Review**

### Design

承認済みの教育内容を、後工程が推測・補完せず制作できる状態まで具体化する。

### Outputs

Designに基づいて制作された、実際の講座・教育活動で使用する成果物を管理する。

例：

-   PPT
-   受講者配布資料
-   ワークシート
-   講師進行表
-   講師実施設計
-   講師セルフチェック
-   その他、承認済み教育設計および適用される教材制作基準に基づき必要とされる成果物

成果物の種類は講座ごとに必要なものを採用し、不要な形式を機械的に作らない。

教材制作時は、承認済みDesignと `01_Education/02_Material_Production/` のうち当該成果物に必要な正式基準を参照する。

教材制作基準はDesignを上書きせず、Designで確定した教育を成果物へ実装するために使用する。

### Review

成果物が承認済みDesignおよび上位基準に準拠しているかを確認した制作後レビュー・承認記録を管理する。

Reviewは教育設計そのものを勝手に変更する工程ではない。

制作物の修正で解決できない問題が確認された場合は、適切な上位設計へ判断を戻す。

------------------------------------------------------------------------

## 7. 現行SourceとArchiveの位置づけ

現行正式Sourceを保持する責任ディレクトリでは、通常の参照対象となる場所に現行ファイルを配置する。

現行ファイルを示すためだけの `Current/` ディレクトリは、原則として追加しない。

AIおよび人間は、通常参照時にArchiveを現行Sourceとして使用しない。

`Archive`
は、**現在は使用しないが保持する必要がある過去ファイルそのもの**を保管する場所である。

CHANGELOGとは役割が異なる。

**Archive = 過去の実物**

**CHANGELOG = 何が・なぜ変わったかの履歴**

現行正本と旧版を同じOutputsやDesign等の現行領域へ並置し、どれが有効か分からない状態にしない。

ただし、Git履歴だけで十分な作業途中ファイルや一時生成物まで、すべてArchiveへ保存する必要はない。

作業途中のコピー、監査提出用の一時名称、再提出用コピー等は、正式採用後に現行Sourceとして重複保持しない。

------------------------------------------------------------------------

## 8. CHANGELOGへ記録する変更

以下のような変更は、意味のある変更として `CHANGELOG.md` へ記録する。

-   理念・教育思想・判断基準の追加、変更、削除
-   AIの責任範囲や役割の変更
-   到達目標・教育内容・カリキュラム原則の変更
-   禁止事項・安全基準・境界条件の変更
-   ファイル構成や責任領域の大きな変更
-   旧仕様から新仕様への移行
-   AIの出力判断に影響する変更
-   Versionを更新する変更
-   講座・専門講座の承認状態に影響する変更

迷った場合は、

**「この変更によって、AIまたは人間の判断・設計・制作・運用が変わるか」**

を基準にする。

変わる場合は、原則としてCHANGELOGへ記録する。

------------------------------------------------------------------------

## 9. CHANGELOGの位置づけ

`CHANGELOG.md` は履歴資料であり、現在の判断基準そのものではない。

AIおよび人間が現在の仕様を判断するときは、各領域の最新版の仕様書・基準書・承認済みDesignを参照する。

過去の記述と現在の仕様が異なる場合は、現在有効な資料を優先する。

### 9.1 CHANGELOG更新時の必須手順

`CHANGELOG.md`
を更新・出力する場合は、既存履歴の消失を防ぐため、以下の手順を必須とする。

1.  対象階層に既存の `CHANGELOG.md` が存在するか確認する。
2.  既存CHANGELOGが存在する場合は、更新前に必ずその内容を確認する。
3.  既存の過去履歴は、原則として削除・要約・改変しない。
4.  新しい変更履歴は、原則として既存履歴の先頭へ追記する。
5.  更新後、過去履歴が保持されていることを確認する。
6.  既存CHANGELOGが存在しない場合に限り、新規作成する。

AIがCHANGELOGを生成する場合も同様とする。

**「CHANGELOGを作成する」という指示を、既存CHANGELOGの上書き指示として解釈してはならない。**

既存CHANGELOGを確認できない状態では、過去履歴を推測して自己完結版を生成し、既存ファイルへ置き換えることをしない。

必要に応じて既存CHANGELOGの提示・検索・確認を行ったうえで、過去履歴を保持した統合版を作成する。

------------------------------------------------------------------------

## 10. ファイルの責任領域

情報を追加するときは、

1.  その情報はどの階層のルールか
2.  どのファイル・ディレクトリが責任を持つべきか
3.  上位資料ですでに定義されていないか
4.  他ファイルから参照できないか
5.  正式基準・設計・成果物・根拠・履歴のどれに該当するか

を確認する。

具体例や補足を追加する場合も、AIまたは人間の判断に必要かを確認し、不要な重複を避ける。

------------------------------------------------------------------------

## 11. 上位資料との整合

下位資料は、上位の基準資料と矛盾してはならない。

教育内容を決定する基本的な参照関係は以下とする。

**Brand OS（00〜09のうち当該責任に必要なファイル）\
↓\
主任講師AI Core\
↓\
各コース CourseOS\
↓\
講座・専門講座・Sessionの承認済み教育設計**

教材制作では、上記で確定した教育に対して、全Course共通教材制作基準を適用する。

``` text
承認済み教育設計
        +
01_Education/02_Material_Production/
        ↓
制作成果物
        ↓
制作後レビュー
```

Brand OSの入口および責任ファイルの選択は、`00_Brand/00_ブランドOS概要・参照ガイド.md` に従う。

Sourcesは、この教育責任階層に対して教育上の判断を直接上書きするものではなく、知識・根拠を支える参照層として扱う。

教材制作基準も、Core・CourseOS・承認済み教育設計を上書きするものではなく、確定済み教育を成果物へ実装する制作責任層として扱う。

下位資料を更新する際に上位資料との矛盾が生じる場合は、勝手に解釈して進めず、上位資料を確認し、必要に応じて適切な設計判断へ戻す。

------------------------------------------------------------------------

## 12. Sourcesと教育設計の関係

新しい原典・論文・資料をSourcesへ追加しただけで、CourseOS・教育設計・既存成果物が自動的に変更されたものとは扱わない。

教育内容へ反映する場合は、

**根拠の確認\
→ 適用判断\
→ 必要な上位基準または教育設計の更新\
→ 制作\
→ レビュー**

という適切な工程を経る。

情報収集と教育上の正式採用を分離する。

------------------------------------------------------------------------

## 13. 新しいモジュール・コースを追加するとき

新しいコース、AI、ブランド関連モジュールなどを追加するときは、既存構造を無条件にコピーしない。

そのモジュールに必要な責任領域を確認し、不要な空階層を先回りして増やさない。

ただし、同じ責任構造を持つことが確認できる場合は、既存の基本構造をテンプレートとして利用してよい。

B・Cコース等の新しいCourseを追加する場合、Course固有の `00_CourseOS`、`01_Front`、`02_Professional`、`03_Sources` 等は必要性に応じて設計する。

一方、Brand OS、主任講師AI Core、全Course共通教材制作基準等の共通SourceをCourse配下へ複製して管理しない。

少なくとも以下を確認する。

-   入口となる概要・責任定義があるか
-   各ファイル・ディレクトリの責任領域が明確か
-   上位資料との参照関係が明確か
-   現在有効な仕様と過去の履歴が混在していないか
-   独立した変更管理が必要な単位に `CHANGELOG.md` があるか
-   根拠資料と調査中資料が混在していないか
-   成果物と設計資料が混在していないか
-   共通Sourceを不要に複製していないか

------------------------------------------------------------------------

## 14. Git運用との関係

Gitは、ファイルの変更そのものを記録する。

`CHANGELOG.md`
は、その中から**後から意味を理解する必要がある変更**を要約して残す。

したがって、

**Git = 変更の事実と差分**

**CHANGELOG = 意味のある変更の要約と経緯**

として使い分ける。

バイナリ形式の成果物（例：`.pptx`、`.docx`）もGitで管理できるが、テキストファイルのような差分比較は行いにくい。

そのため、現行版・旧版・承認状態がディレクトリ構造およびReview・CHANGELOGから判断できる状態を維持する。

### 14.1 コミットメッセージ規約

コミットメッセージは、変更内容を後から履歴だけで把握できるよう、原則として以下の形式を使用する。

``` text
<type>: <日本語で簡潔な変更内容>
```

`type` は、変更の主目的に応じて以下を使用する。

-   `feat`：新しい機能・仕様・正式資産・教育設計・成果物等を追加する変更
-   `fix`：誤り、不具合、内容上の問題を修正する変更
-   `docs`：仕様や教育判断そのものを変更せず、文書・説明・記録のみを追加または更新する変更
-   `refactor`：内容・責任・意味を変更せず、構造・配置・ファイル分割等を整理する変更
-   `chore`：上記に該当しない、運用・管理・環境整備等の変更

例：

``` text
feat: AコースProfessionalのPrimary SourcesにUNESCO資料を追加
feat: AコースProfessional Session 1の承認済み教育設計Ver0.2を追加
fix: Session 1教育設計の表記誤りを修正
docs: ProfessionalのCHANGELOGを更新
refactor: ブランドOSを責任単位ごとに分割
refactor: 全コース共通教材制作基準を独立責任単位へ配置
chore: 不要な一時ファイルを削除
```

複数種類の変更を一つのコミットへ無理にまとめず、意味のある単位でコミットを分ける。

コミットの種類に迷う場合は、**「このコミットで最も主要な変更は何か」**を基準に
`type` を選ぶ。

コミットメッセージは変更の事実を簡潔に示すものとし、変更理由や設計判断の詳細を長文で記録する場所にはしない。後から意味を理解する必要がある変更理由・経緯は、必要に応じて該当領域の
`CHANGELOG.md` に記録する。

------------------------------------------------------------------------

## 15. このルール自体の更新

本ファイルも固定ではなく、リポジトリの成長に応じて更新してよい。

ただし、リポジトリ全体の運用へ影響する変更であるため、重要な変更はルートの
`CHANGELOG.md` に記録する。

本ファイルには過去の更新履歴を蓄積しない。
