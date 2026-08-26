# 07_Note_Production CHANGELOG

このファイルは、note制作・公開・SNS展開責任領域における意味のある変更履歴を記録する。現在の運用判断は各現行Sourceを正とする。

---

## 2026-08-26｜Production・Review・Publishの状態遷移をv1.3へ更新

### 概要

価格、自己開示範囲、公開範囲の未決をDraft Productionの停止条件にせず、Publish前Human Decisionとし、一部差し戻し後の修正・再Review・再承認までの状態遷移を明確化した。

### 変更内容

- `Production → Review → Decision Pending → Approved → Scheduled / Publish` を基本遷移とし、差し戻し時は `Revision Required → 修正対象の特定 → 必要最小限の修正・再Review → Decision Pending` へ戻す状態遷移を追加した。
- 価格、自己開示範囲、公開範囲が未決でも、Section制作台本とG2 PASSを入力にDraft ProductionとReviewを進めるようにした。
- Publish前Human Decisionで差し戻された場合、未変更のDraft、Output QAおよびReview結果を有効なまま保持し、変更が必要な成果物だけを修正・再Reviewする方針を追加した。
- PipelineのG0ではDraftを外部公開しない取扱範囲と最終承認者を確定し、最終的な公開範囲をPublish前Human Decisionへ残す接続を追加した。
- Section制作台本、全体ロードマップ、公開成果物記録テンプレート、READMEのStatusと差し戻し後の再開記録を同期した。

### 責任境界

- ProductionはDraftの生成、ReviewはDraftと修正範囲の確認、Publish前Human Decisionは価格・自己開示範囲・公開範囲を含む公開可否の判断、Publishは承認版の外部公開を担う。
- 必読Sourceの未解決またはG2 FAILはProductionを停止する。価格、自己開示範囲、公開範囲の未決はPublishだけを停止する。

### Repository横断監査（I-03対象範囲）

- 確認Source：`AI_PRODUCTION_PIPELINE.md`、`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`、`REPOSITORY_RULES.md`、本領域のREADME・SOP・全体ロードマップ・Section制作台本・公開成果物記録・CHANGELOGおよびRepository CHANGELOG。
- 確認結果：PipelineのG0、G2、G4、G5、G8／G9およびHuman-in-the-loopの承認・再承認責任を再定義せず、G0の非公開Draft取扱範囲と最終公開範囲を区別したうえで、note固有のDraft、Review、Publish前Human Decision、差し戻し後の再開状態だけを具体化した。入口、状態定義、差し戻し記録および変更履歴は同期済み。
- Git自己監査：対象diff確認および`git diff --check`を実施。
- 統合確認：I-01からI-03までの変更済みSource、依存Source、責任境界、入口導線、Version／Status、CHANGELOGおよびGit準備を横断確認し、未解決の新規Issueは検出されなかった。

**判定：PASS（I-03対象範囲／I-01〜I-03統合Repository横断監査）**

### Status

**Current / Operational v1.3 / I-03 scope audit PASS**

---

## 2026-08-26｜意味づけ・企画フェーズをv1.2へ接続

### 概要

Timelineの史実からSection制作台本へ直接進めず、意味づけと企画を経由して、採用された企画だけをSection制作台本へ渡す責任構造を追加した。

### 変更内容

- note制作の階層を、`一次資料 → Timeline → 意味づけ → 企画 → Section制作台本 → Session → 3記事`へ更新した。
- 意味づけでSeries候補、学び、読者への順番を並列に壁打ちし、候補を一つへ固定しない原則を追加した。
- 意味づけ候補と非採用候補は永続保存せず、将来必要になればTimelineから再生成する方針を明確化した。
- 企画で採用した既存Section追加・新Section・Session・3記事の役割・Human DecisionだけをSection制作台本へ引き継ぐようにした。
- Section制作台本に、採用したTimeline史実、意味づけ／Series、読者への学びと順番、企画判断、Human Decisionの引き継ぎ欄を追加した。
- 全体ロードマップを、企画で採用されSection制作台本が作成されたSectionだけを扱う正本として明確化した。

### 責任境界

- Timelineは史実と一次資料参照を扱い、意味づけ・企画中の候補を保持しない。
- 意味づけ・企画は、PipelineのSource Router／Source QA、Human ApprovalまたはPublishの責任を代替しない。
- Production・Review・Publishの状態遷移に関する受入試験Issueは、本更新の対象外とした。

### Repository横断監査（I-02対象範囲）

- 確認Source：`REPOSITORY_RULES.md`、`AI_PRODUCTION_PIPELINE.md`、`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`、本領域のREADME・Timeline・全体ロードマップ・Section制作台本・SOP・CHANGELOGおよびRepository CHANGELOG。
- 確認結果：意味づけ・企画は、一次資料の原本、Timeline、PipelineのWork Charter／Source Router／Source QA、Human ApprovalおよびPublishの責任を侵食しない。採用済み企画だけをSection制作台本と全体ロードマップへ渡す導線、入口および変更履歴は同期済み。
- 非変更確認：Production・Review・Publishの状態遷移（I-03）は更新していない。
- Git自己監査：対象diff確認および`git diff --check`を実施。

**判定：PASS（I-02対象範囲）**

### Status

**Current / Operational v1.2 / I-02 scope audit PASS**

---

## 2026-08-26｜Timelineの一次資料生成・現在地復元をv1.1へ更新

### 概要

Timelineを、人間が手入力する管理表ではなく、GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から、必要最小限の史実と参照情報を抽出して生成・更新する、note制作における史実正本として明確化した。

### 変更内容

- Timelineの最小記録項目を、発生日または時期、抽出した史実、一次資料識別子、一次資料参照位置、抽出日、確認状態、利用状態、実際の使用先および最終更新日に更新した。
- 原本は原本の保管先に保持し、会話全文・音声全文その他の原文をTimelineへ複製しない方針を明確化した。
- `noteやるよ`の開始手順を、一次資料の未反映確認、Timelineの生成・更新、既存のロードマップ・Section・公開成果物との照合から始める手順へ更新した。
- Timeline未生成・未更新を、史実が存在しないことと扱わない原則を追加した。

### 責任境界

- Timelineは史実と一次資料参照を扱い、公開判断、自己開示判断、Series候補、保留その他の解釈・企画状態は扱わない。
- 意味づけ・企画フェーズ、およびProduction・Review・Publishの状態遷移に関する受入試験Issueは、本更新の対象外とした。

### Repository横断監査（I-01対象範囲）

- 確認Source：`REPOSITORY_RULES.md`、`AI_PRODUCTION_PIPELINE.md`、`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`、`04_AI_Work_Environment/INBOX_AND_PERSONAL_ARCHIVE.md`、本領域のREADME・Timeline・SOP・CHANGELOGおよびRepository CHANGELOG。
- 確認結果：原本はRepositoryの正式Sourceとして複製せず、既存の原本保管・provenance運用と矛盾しない。Timelineの責任、README導線、Repository Rules、変更履歴および`noteやるよ`の開始順序は同期済み。
- 非変更確認：意味づけ・企画フェーズ（I-02）とProduction・Review・Publishの状態遷移（I-03）は更新していない。
- Git自己監査：対象diff確認および`git diff --check`を実施。

**判定：PASS（I-01対象範囲）**

### Status

**Current / Operational v1.1 / I-01 scope audit PASS**

---

## 2026-08-26｜note Production責任領域の正式採用・Pipeline接続

### 概要

note制作・公開・SNS展開を既存AI Production Pipelineへ接続する独立した責任領域として `07_Note_Production/` を新設した。

### 追加した現行Source

- note制作・公開システム、実際に起きた出来事を時系列で保持する唯一のTimeline正本、全体ロードマップ正本、SNS展開基準、Section制作台本テンプレート、公開成果物記録テンプレート、入口READMEを追加した。
- Sectionを最上位制作単位とし、1 SessionをStory（無料Hub）・実践編（無料部分に詳細目次を掲示する単品有料）・MS奮闘記（生の声・壁打ち・失敗・感情・制作裏側を扱うメンバーシップ限定）の3記事として同時配布するモデルを定義した。SNS投稿案はSession全体を入口にする別成果物とした。
- Timelineは史実だけを扱い、Section／Sessionの現在地・制作状態・Next・Blockerは全体ロードマップ、Section制作台本、公開成果物記録を正とした。`noteやるよ`の現在地復元、`note記事書いて`のSection一括Production、Section完成条件、Section 1後の実践編価格横並びキャリブレーション、3記事の公開済み最終稿pathを接続した。

### 責任境界

- Source Router／Source QA／Output QA、Human Approval、Repository横断監査、Gitを複製せず、既存正式Sourceを呼び出す。
- AIは外部公開、価格、自己開示、Human Approvalを代行しない。
- Instagramは正式投稿または予約手段が利用可能な場合だけ自動化し、X／Threadsは投稿案の生成までとし、実投稿はユーザーの「投稿お願い」Gateを必要とする。

### Status

**Current / Operational v1.0**
