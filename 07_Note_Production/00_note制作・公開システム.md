# note制作・公開システム v1.4

**Status:** Current / Operational v1.4
**Scope:** note制作、公開準備、公開後記録、Session単位のSNS展開、Repositoryへの知見還元

## 1. 責任と非責任

本Sourceは、noteとSNSに固有の制作単位、公開準備、再開状態、公開済み最終稿の保持を定める。以下は既存Sourceを正とし、本Sourceは再実装しない。

- Source選択・実読・QA・Output QA・Repository Integration・Git：`AI_PRODUCTION_PIPELINE.md`
- 人間承認、停止、再承認、未定義の外部操作：`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- 役割・権限・受け渡し：`AI_ORGANIZATION.md`
- 配置、Archive、CHANGELOG、Git：`REPOSITORY_RULES.md`

AIはHuman Approval、外部公開、価格、自己開示の採否を代行しない。認証・接続または正式投稿手段がないSNS投稿を、実施済みと表現してはならない。接続不能時は未実装／未投稿として公開成果物記録へ残す。

## 2. 制作モデル

制作の階層は次の順序で扱う。

```text
一次資料 → Timeline → 意味づけ → 企画 → Section制作台本 → Session → Story / 実践編 / MS
```

- **Timeline**：GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から、実際に起きた出来事を抽出して時系列で保持する、唯一の史実Source。企画、現在地、制作状態、Next、Blockerは扱わない。一次資料の原本はTimelineへ全文複製せず、原本の保管先と参照位置を追跡できる状態にする。
- **意味づけ**：Timelineの確認済み史実を起点に、その史実が何を意味するか、どのSeriesで扱いうるか、どのような学びになるか、読者へどの順番で届けうるかを壁打ちするフェーズ。同一の史実から複数候補が並列に成立してよい。候補はその都度再生成する思考材料であり、Repositoryの永続成果物として保存しない。
- **企画**：意味づけ候補をもとに、今回採用する企画、既存Sectionへの追加または新Section、Session候補、Story／実践編／MSの役割、Human Decisionを整理するフェーズ。採用された企画だけをSection制作台本へ渡し、採用しない候補は保存を要しない。意味づけ・企画はWork Charter、Source Router、Source QAまたはHuman Approvalを代替しない。
- **Section**：最上位の制作単位。テーマ、対象、目的、Story Hub、Session構成、現在地、優先順位、承認状態を一つにまとめる。Section構成はAIが勝手に確定せず、壁打ちで確定する。
- **Session**：1回の制作・公開・展開単位。**1 Session = Story（無料Hub）・実践編（単品有料）・MS奮闘記（メンバーシップ限定）の3記事**とし、同一Session内の3記事を同時に配布する。
- **Story**：Sessionの無料Hub。出来事と変化を読者が入れる文脈として届け、実践編とMS奮闘記への全体の入口を担う。
- **実践編**：無料部分に詳細目次を掲示する単品有料記事。読者が実際に取り組める具体的な実践を担う。
- **MS奮闘記**：生の声・壁打ち・失敗・感情・制作裏側を扱うメンバーシップ限定記事。公開範囲と自己開示は人間承認を要する。

SNS投稿案は、上記3記事で構成するSession全体を入口にして制作する別成果物であり、3記事のいずれかを代替しない。SNS実投稿の可否は別Gateで扱う。

Story HubはSection制作台本内で、Story Candidate、一次Evidence、使用Session、重複・未使用、自己開示の人間判断状態を追跡する。Story Candidateがあることは公開許可ではない。

価格はSectionごとに仮説を置き、読者価値、深度、継続性、無料／有料の役割、既存商品の導線との整合を確認してキャリブレーションする。Section 1では、各Sessionの実践編価格をSection全体で横並びにして確認する。AIは価格を決定・変更・設定しない。価格、自己開示範囲または公開範囲が未承認でもDraft ProductionとReviewは停止しない。これらが未承認なら、Publishだけを `HUMAN DECISION REQUIRED` として止める。

## 3. 起動コマンドと現在地復元

### `noteやるよ`

1. GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の利用可能な一次資料に、Timelineへ未反映の史実があるかを確認する。原本の保管先と参照位置を確認し、会話全文や音声全文をTimelineへ複製しない。
2. 一次資料から必要最小限の史実を抽出し、`01_Timeline.md` を生成または更新する。各行で、一次資料識別子、参照位置、抽出日、確認状態を追跡できるようにする。
3. `01_Timeline.md`、`02_全体ロードマップ.md`、対象Sectionの制作台本、公開済み最終稿、公開成果物記録を照合し、Sectionの現在地、未完了Gate、未解決Decision、公開済み／未公開、SNS接続状態を要約する。
4. 確認済みかつ未使用のTimeline史実から意味づけを開始する。この段階では、一つの史実を一つのSeries、SectionまたはSessionへ固定せず、Series候補、学び、読者への順番を並列に壁打ちする。意味づけ候補はTimelineへ書き戻さず、永続保存を要しない。
5. 意味づけをもとに企画を整理する。今回採用する企画についてのみ、既存Sectionへの追加または新Section、Session候補、Story／実践編／MSの役割、必要なHuman Decisionを壁打ちで確定する。採用しない候補は削除してよく、将来必要になればTimelineから意味づけを再開する。
6. 採用された企画だけをSection制作台本へ記録し、対応するSectionを全体ロードマップへ反映する。Section構成はAIが勝手に確定せず、壁打ちで確定する。採用済みSection制作台本を、PipelineのIntake、Source RouterおよびSource QAへ渡す。意味づけ・企画はPipelineのWork Charter、Source Router／Source QA、Human ApprovalまたはPublishの責任を代替しない。

Timelineが未生成または未更新であることは、史実が存在しないことを意味しない。AIは、時刻、会話の順番、Work稿の更新日だけから史実または現在地を推測せず、利用可能な一次資料から確認可能な事実だけをTimelineへ反映する。史実Timelineと公開成果物記録が矛盾する場合、または編集競合がある場合は復旧状態へ入り、統合せず停止する。

### `note記事書いて`

対象Sectionが壁打ちで確定し、G2 Source QAがPASSしている場合、AIはSection制作台本に従い、そのSection全体の全Sessionを一括Productionする。各SessionでStory・実践編・MS奮闘記の3記事Draft、Session全体を入口にしたSNS投稿案、Source Application Log、未解決Decisionを作る。各Session内の3記事は同時配布の一組として扱う。PipelineのG0では、Draftを外部公開しない取扱範囲と最終承認者を確定する。価格、自己開示範囲または最終的な公開範囲が未決でも、Draftには未解決Decisionとして明示してProductionとReviewを進める。一括ProductionはHuman Approval、価格、自己開示、各Sessionの公開を一括承認しない。

対象Sectionが壁打ちで未確定、必読Source未読またはG2 Source QAがFAILの場合は制作を始めず、現在地と不足事項を示す。Timeline未登録だけを理由に事実の存在を推測しない。

### `noteに反映して`

これは外部公開の**Human Approval Gate**を起動する表現であり、AIによる公開実行指示ではない。AIは、対象の公開済み最終稿候補、タイトル、価格、公開範囲、自己開示、SNS展開、公開先の認証・接続状態を提示し、明示承認を確認する。

明示承認後も、対象媒体の利用可能な正式操作手段と権限を確認する。手段または接続がなければ、AIは公開完了と偽らず、ユーザーが実行できる公開パッケージと未実施状態を記録する。

## 4. Sectionから公開後まで

1. **Timeline生成・意味づけ・企画／Section設計**：Timelineの確認済み史実から意味づけを開始し、採用する企画だけを`10_Section制作台本テンプレート.md`へ記録する。Section制作台本に基づき、Story Hub、Session、価格仮説、公開条件を壁打ちで設計する。Timelineには実際に起きた出来事だけを記録する。
2. **Intake / Routing / Source QA**：採用済みSection制作台本を入力としてPipelineを実行し、note本文にはnote制作・公開SOP、SNS展開にはSNS展開基準を必読とする。G0ではDraftを外部公開しない取扱範囲と最終承認者を確定し、最終的な公開範囲、価格、自己開示範囲はPublish前Human Decisionへ残せる。
3. **Production / Output QA**：SessionごとにStory・実践編・MS奮闘記の3記事と、Session全体を入口にしたSNS投稿案をDraftとして制作し、既存のOutput QAへ渡す。価格、自己開示範囲または公開範囲の未決は、DraftとReviewを止めず未解決Decisionとして保持する。
4. **Publish前Human Decision**：Reviewを通過したDraftについて、本文、タイトル、価格、公開範囲、自己開示、公開対象を人間が承認する。未承認ならPublishだけを停止する。差し戻し時は、修正対象を特定して必要最小限の修正・再Reviewへ戻す。
5. **Publish / Verification**：すべてのPublish前Human Decisionが承認された版だけを公開し、承認版との一致、URL、表示、リンク、価格、公開範囲、日時を既存PipelineのG8／G9で確認する。
6. **Record / Resume**：3記事の公開済み最終稿と公開成果物記録をcanonical pathへ配置し、ロードマップまたは制作台本の状態と次アクションを更新する。公開されなかった場合も理由と再開地点を残す。
7. **Feedback / Repository還元**：反応、誤読、導線、制作上の発見をFeedback Candidateとして分類する。単発反応を自動でOSやSOPへ反映しない。

### 4.1 AI Organization SeriesのExternal Audit

AI Organization Seriesでは、Human指摘反映、内部監査、自動修正、内部再監査PASSを完了した稿をFinal Candidateとし、`04_AI_Work_Environment/External_Audit_Pipeline/README.md` へ渡す。Session単位でStory、Practice、Session Archive、Candidate Title、必要なEvidence Note、Series方針、当該Session責任範囲、後続境界およびVoice / Archiveルールだけを抽出する。

外部監査のBLOCKERまたはHuman Decisionが必要なIssueは停止してChatへ戻す。MAJOR／MINORで既存Sourceから一意に修正できるIssueは内部制作側が採否を照合し、採用する場合だけ必要最小限に修正する。外部AIへ全文再設計、文体均質化、Historical Evidence補完または正式稿への直接WRITEをさせない。MAJOR修正後は原則としてExternal Re-Auditし、MINORだけなら内部再監査で完了できる。

## 5. 再開状態とエラー復旧

Sectionの現在地は、全体ロードマップまたはSection制作台本で `Planning`、`Production`、`Review`、`Decision Pending`、`Revision Required`、`Approved`、`Scheduled`、`Published/Complete`、`Update Candidate` のいずれかを記録する。Timelineは史実だけを扱い、状態を記録しない。

### 5.1 Publish前Human Decisionの差し戻しと再開

状態遷移は次のとおりとする。

```text
Production → Review → Decision Pending → Approved → Scheduled / Publish
                              ↓
                     Revision Required
                              ↓
          修正対象の特定 → 必要最小限の修正 → 必要最小限の再Review
                              ↓
                       Decision Pending
```

- `Production`では、Section制作台本とG2 PASSを入力に3記事Draftを作る。価格、自己開示範囲、公開範囲の未決はDraft内の未解決Decisionとして扱い、Productionを止めない。
- `Review`では、Draftと修正範囲を確認する。Reviewが完了し、Publish前Human Decisionを待つ状態を`Decision Pending`とする。
- `Decision Pending`で価格、自己開示範囲、公開範囲、本文、タイトルまたは公開対象の一部が差し戻された場合、`Revision Required`へ戻す。差し戻し理由、修正対象、所有者、再開条件をSection制作台本に記録する。
- `Revision Required`では、未変更のDraft、Output QAおよびReview結果を有効なまま保持する。本文・表示・公開対象の修正が必要な成果物だけを修正し、修正範囲だけを再Reviewする。価格だけ等、本文を変更しない差し戻しでも、価格表示その他の影響範囲を確認してから`Decision Pending`へ戻す。
- すべてのPublish前Human Decisionが承認され、必要な再ReviewがPASSした場合だけ`Approved`へ進む。`Approved`前のDraft、Review、Decision PendingまたはRevision Requiredを、公開済み・予約済みとして扱わない。

次のいずれかでは、制作台本または公開成果物記録を `Recovery Required` として扱う：公開URLと記録の不一致、承認版と公開候補の不一致、接続／認証失敗、公開直後の表示・リンク・価格異常、Work稿とRepository正本の競合、公開停止を要する安全上の懸念。

復旧では、公開済み最終稿、Approval Record、公開成果物記録、Timeline、媒体上の実際の状態を照合する。安全に一意に戻せる修正だけを行い、それ以外はHuman Ownerへエスカレーションする。削除、価格変更、訂正公開、再投稿、自己開示の変更は新たな対外結果として人間判断を要する。

## 6. 正本の扱い

公開後に将来参照する記事本文の正本は、Sessionごとの `01_Story無料Hub_最終稿.md`、`02_実践編単品有料_最終稿.md`、`03_MS奮闘記メンバーシップ限定_最終稿.md` の3ファイルだけである。note上の表示URLと公開成果物記録を紐付ける。Work稿、SNS用短縮稿、旧版、下書き、画面コピーを正本として参照しない。置換や非公開化が生じた場合、旧正本は実データがある場合に限りArchiveへ移し、現行性は公開成果物記録とロードマップで明示する。
