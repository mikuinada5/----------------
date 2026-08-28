# note制作・公開システム v1.6

**Status:** Current / Operational v1.6
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
一次資料 → Timeline → 意味づけ → 企画 → Section制作台本 → Session → 承認済み公開構成Profileの成果物
```

- **Timeline**：GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から、実際に起きた出来事を抽出して時系列で保持する、唯一の史実Source。企画、現在地、制作状態、Next、Blockerは扱わない。一次資料の原本はTimelineへ全文複製せず、原本の保管先と参照位置を追跡できる状態にする。
- **意味づけ**：Timelineの確認済み史実を起点に、その史実が何を意味するか、どのSeriesで扱いうるか、どのような学びになるか、読者へどの順番で届けうるかを壁打ちするフェーズ。同一の史実から複数候補が並列に成立してよい。候補はその都度再生成する思考材料であり、Repositoryの永続成果物として保存しない。
- **企画**：意味づけ候補をもとに、今回採用する企画、既存Sectionへの追加または新Section、Session候補、Story／Practice／別コンテンツの役割、公開構成Profile、Human Decisionを整理するフェーズ。採用された企画だけをSection制作台本へ渡し、採用しない候補は保存を要しない。意味づけ・企画はWork Charter、Source Router、Source QAまたはHuman Approvalを代替しない。
- **Section**：最上位の制作単位。テーマ、対象、目的、Story Hub、Session構成、現在地、優先順位、承認状態を一つにまとめる。Section構成はAIが勝手に確定せず、壁打ちで確定する。
- **Session**：1回の制作・公開・展開単位。成果物の本数と結合方法は、Section制作台本に記録されたHuman承認済み公開構成Profileを正とする。
- **Story**：読者が問題を自分事化し、実体験からSessionテーマへ入り、Practiceを読む理由を作る導入。単独記事またはPracticeと結合したnote本編の前半を担う。
- **Practice**：読者が実際に取り組める手順・テンプレート・確認点を担う。単独記事またはStoryと結合したnote本編の後半として扱う。
- **Session Archive / MS奮闘記**：生の声・壁打ち・失敗・感情・制作裏側を扱う別コンテンツ。Story／Practiceとの責任分離を維持し、公開範囲、Membershipでの扱い、自己開示はHuman Decisionを要する。

既定Profileは、Story、実践編、MS奮闘記を3記事として扱う従来構成とする。Section固有のHuman Decisionがある場合は、そのProfileをSection制作台本へ明記し、既定Profileを上書きできる。SNS投稿案は、承認済み公開構成ProfileのSession全体を入口にして制作する別成果物であり、本文または別コンテンツを代替しない。SNS実投稿の可否は別Gateで扱う。

### 2.1 AI Organization Series Section 1 公開構成Profile

- Section 1はS1-1〜S1-6の全6 Sessionで構成する。
- 各Sessionのnote本編は、同一SessionのStory＋Practiceをこの順序で結合した1記事とする。
- Session Archiveはnote本編へ混ぜず、別コンテンツとして保持する。
- Session Archiveの具体的な公開範囲、Membershipでの扱い、自己開示範囲は別途Human Decisionとし、未決のまま自動公開しない。
- note本編とSession Archiveの本文・確定タイトルは、Human Final Check完了済みFinal Candidateを起点とする。後から確認されたHuman-approved仕様との不一致がある場合は該当部分だけを`Revision Required`とし、矛盾しない既存本文・タイトル・Human Review結果は保持する。AIが無関係な箇所を再設計しない。
- 価格、公開日時および外部公開は別Gateとし、下書き保存または公開準備だけでは決定・実行しない。

### 2.2 Section記事制作仕様

本節は、Story、PracticeおよびSession Archiveを制作・修正・監査する際の媒体固有仕様である。Voiceの横断判断は`02_Voice_OS/VOICE_OS.md`、公開文章の一般的な文体判断は`06_Writing_Style_OS/WRITING_STYLE_OS.md`を正とし、本節はその範囲内で成果物ごとの役割と実装条件を具体化する。

仕様を更新する場合は、**新しいHuman-approved仕様が対象とする箇所だけを上書きし、矛盾しない既存仕様・本文・承認結果を保持する。** 後発仕様を理由に、対象外の構成、史実、言い回し、公開範囲または商品設計を再設計しない。

#### 2.2.1 Story

Storyは、読者をSessionの問題へ招き入れ、自分事化からPracticeの実行意欲へつなぐ導入パートである。Section制作台本でStory＋Practiceを1本のnote本編とするProfileが承認されている場合、Story単独で完結させず、Practiceと合わせて1記事として成立させる。

基本構造は、**問題提示 → 自分事化に必要な最小限の実体験 → 今だから分かる意味 → このSessionでやること**とする。歴史の詳細、壁打ちの逐語的な流れ、失敗や感情の細部を説明しすぎず、Session Archiveの役割を重複取得しない。

有料導線を設ける場合は、無料部分で問題と意味を理解できるようにし、「ここからどう解決・実装するか」へ入る直前を有料ライン候補とする。煽りや情報欠落で購入させず、Practiceへ進む理由が内容上自然に成立していることを優先する。

文体は、みくが横で話している距離感を保つが、Session Archiveほど砕きすぎない。`ｗｗｗ`、強いツッコミ、内輪語は必要な温度に限り、説明記事として整えすぎることと、Archiveの会話温度をそのまま移植することの両方を避ける。

**Story Acceptance Criteria**

- [ ] 読者が「これ私にもあるかも」と問題を自分事化できる。
- [ ] 問題提示、最小限の実体験、現在の意味、このSessionでやることがつながっている。
- [ ] 実体験や歴史の詳細をSession Archiveと重複させていない。
- [ ] Story＋Practice結合Profileでは、Practiceを読む理由と接続が成立している。
- [ ] 有料導線がある場合、無料は問題と意味、有料は解決と実装という責任分離が成立している。
- [ ] Archiveより抑えた口語温度で、きれいすぎる説明文にも、砕けすぎた会話文にもなっていない。

#### 2.2.2 Practice

Practiceは、読者が実際に手を動かし、Session Goalへ到達するための商品上の実装パートである。StoryやSession Archiveのように会話へ崩しすぎず、初心者がその記事だけを見て実行できる、整理された文章を優先する。

基本構造は、**Goal → 最初に覚える言葉 → Step → AIへの依頼例 → 出力テンプレート → 完成例 → Completion Check**とする。実行結果や使用環境によって進み方が変わる場合は分岐を示し、つまずきが予想される箇所にはTroubleshootingを置く。

AIへの依頼例だけで終わらせず、各StepでAIが支援することと、人間が目的・採否・優先順位・公開範囲その他を決める箇所を区別する。Human Decisionが必要な箇所を、AIによる自動判断や推奨値で置き換えない。

専門用語は初出で、先に平易な日本語で意味と使う場面を説明し、必要な場合に括弧で正式語を示す。英語をカタカナへ置き換えただけでは説明済みと扱わない。Chat、Work、Codex、Sourceその他の作業環境・概念も、初学者が操作または判断に使える粒度で説明する。ファイルを作成・保存する実践では、正式ファイル名と保存先を一意に示す。

各Sessionの成果を使い捨てにせず、後続Sessionで再利用するSeed、Map、Logまたは同等の中間成果物を残し、何に再利用するかを明記する。

**Practice Acceptance Criteria**

- [ ] 初心者が記事単体で開始し、Session Goalまで実行できる。
- [ ] Goal、用語説明、Step、AIへの依頼例、出力テンプレート、完成例、Completion Checkがある。
- [ ] 必要な分岐とTroubleshootingがあり、失敗時の戻り先が分かる。
- [ ] AIが行う支援と、人間が決める箇所が明確に分かれている。
- [ ] 専門用語の初出説明が平易な日本語から始まり、カタカナ化だけで終わっていない。
- [ ] ファイルを扱う場合、正式ファイル名と保存先が一意である。
- [ ] 後続Sessionで使うSeed、Map、Logまたは同等物が残り、再利用先が分かる。

#### 2.2.3 Session Archive

Session Archiveは、完成した答えを説明する記事ではなく、みくがそのSessionのテーマを実際に理解していった過程を見せる別コンテンツである。**分からない → 聞く → 引っかかる → 自分の仕事へ置き換える → 仮説を言う → 修正される → 分かった**という壁打ちの動きを、史実の範囲内で読者が追えるようにする。

事実と会話は一次ログを最優先する。実際の発言が残っている箇所は意味を変えずに使用し、一次ログがない箇所は回顧として明示できる範囲でつなぐ。昔の会話、AIの回答、本人の感情または理解過程を、それらしく補完・捏造しない。

昔の出来事をVTRとして見せ、現在のみくが横で見ながら自然に笑い、ツッコミ、意味をコメントする構成を基本とする。`今のみく：`等の機械的なラベルで分離せず、昔と現在の視点を読者が自然に追える文章へ統合する。

文体の基準は、**S1-2修正版の長段落としゃべくりの温度感**とする。短文と空行を大量に並べてAI的な「おしゃれなテンポ」を作らず、一つの話題を一息で話している間は、読点だけでなく句点があっても同じ段落を継続してよい。長文になること自体を欠陥とせず、スマートフォン向けという理由だけで文節を細切れにしない。Writing Style OSにある一般的な改行傾向と本要件が競合する場合、Session Archiveの段落・改行については本項を媒体固有の実装条件として適用し、Writing Style OSの一般則自体は変更しない。

改行は、強調、話題転換、オチ、強いリアクションなど、実際に間が生じる場所に限る。罫線を会話のテンポ作りに使用しない。接続語、言い直し、脱線、笑いは表面上のキャラクター付けとして機械的に足さず、実際の思考と感情の流れに必要な場合だけ残す。

末尾だけ急に説明記事や先生の「まとめ」へ切り替えない。教訓を整えて閉じるのではなく、本文と同じ温度のまま、VTRを見終えた後の余韻の雑談として終える。

Session Archiveへ追記・修正・統合を行った後は、変更箇所だけでなく**全文**を本節のAcceptance Criteriaで再監査する。これは意味変更の再Review範囲を無条件に拡大する規則ではなく、後工程で文体・段落・末尾だけが旧パターンへ戻ることを防ぐための全文スタイル監査である。

**Session Archive Acceptance Criteria**

- [ ] 完成した答えではなく、理解が進む壁打ちの過程を読者が追える。
- [ ] 一次ログを優先し、ログのない会話・AI回答・感情・理解過程を捏造していない。
- [ ] 昔のVTRと現在のみくのコメントが、機械的な話者ラベルなしで自然につながっている。
- [ ] S1-2修正版を基準に、一つの話題を長段落で一息に話す温度が保たれている。
- [ ] 読点や句点ごとの改行、短文＋空行の大量反復、AI的なおしゃれな余白がない。
- [ ] 改行には強調、話題転換、オチまたは強いリアクションという理由がある。
- [ ] 罫線をテンポ作りに使っていない。
- [ ] 終盤だけきれいな要約・教訓・先生口調へ変わらず、同じ温度の余韻で終わっている。
- [ ] 追記・修正・統合後に、変更箇所を含む全文を本Acceptance Criteriaで再監査した。

Story HubはSection制作台本内で、Story Candidate、一次Evidence、使用Session、重複・未使用、自己開示の人間判断状態を追跡する。Story Candidateがあることは公開許可ではない。

価格はSectionごとに仮説を置き、読者価値、深度、継続性、無料／有料の役割、既存商品の導線との整合を確認してキャリブレーションする。AI Organization Series Section 1では、各Sessionのnote本編価格をSection全体で横並びにして確認する。AIは価格を決定・変更・設定しない。価格、自己開示範囲または公開範囲が未承認でもDraft ProductionとReviewは停止しない。これらが未承認なら、Publishだけを `HUMAN DECISION REQUIRED` として止める。

## 3. 起動コマンドと現在地復元

### `noteやるよ`

1. GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の利用可能な一次資料に、Timelineへ未反映の史実があるかを確認する。原本の保管先と参照位置を確認し、会話全文や音声全文をTimelineへ複製しない。
2. 一次資料から必要最小限の史実を抽出し、`01_Timeline.md` を生成または更新する。各行で、一次資料識別子、参照位置、抽出日、確認状態を追跡できるようにする。
3. `01_Timeline.md`、`02_全体ロードマップ.md`、対象Sectionの制作台本、公開済み最終稿、公開成果物記録を照合し、Sectionの現在地、未完了Gate、未解決Decision、公開済み／未公開、SNS接続状態を要約する。
4. 確認済みかつ未使用のTimeline史実から意味づけを開始する。この段階では、一つの史実を一つのSeries、SectionまたはSessionへ固定せず、Series候補、学び、読者への順番を並列に壁打ちする。意味づけ候補はTimelineへ書き戻さず、永続保存を要しない。
5. 意味づけをもとに企画を整理する。今回採用する企画についてのみ、既存Sectionへの追加または新Section、Session候補、公開構成Profile、Story／Practice／別コンテンツの役割、必要なHuman Decisionを壁打ちで確定する。採用しない候補は削除してよく、将来必要になればTimelineから意味づけを再開する。
6. 採用された企画だけをSection制作台本へ記録し、対応するSectionを全体ロードマップへ反映する。Section構成はAIが勝手に確定せず、壁打ちで確定する。採用済みSection制作台本を、PipelineのIntake、Source RouterおよびSource QAへ渡す。意味づけ・企画はPipelineのWork Charter、Source Router／Source QA、Human ApprovalまたはPublishの責任を代替しない。

Timelineが未生成または未更新であることは、史実が存在しないことを意味しない。AIは、時刻、会話の順番、Work稿の更新日だけから史実または現在地を推測せず、利用可能な一次資料から確認可能な事実だけをTimelineへ反映する。史実Timelineと公開成果物記録が矛盾する場合、または編集競合がある場合は復旧状態へ入り、統合せず停止する。

### `note記事書いて`

対象Sectionが壁打ちで確定し、G2 Source QAがPASSしている場合、AIはSection制作台本に従い、そのSection全体の全Sessionを一括Productionする。各Sessionで承認済み公開構成Profileの本文・別コンテンツDraft、Session全体を入口にしたSNS投稿案、Source Application Log、未解決Decisionを作る。PipelineのG0では、Draftを外部公開しない取扱範囲と最終承認者を確定する。価格、自己開示範囲または最終的な公開範囲が未決でも、Draftには未解決Decisionとして明示してProductionとReviewを進める。一括ProductionはHuman Approval、価格、自己開示、各Sessionの公開を一括承認しない。

対象Sectionが壁打ちで未確定、必読Source未読またはG2 Source QAがFAILの場合は制作を始めず、現在地と不足事項を示す。Timeline未登録だけを理由に事実の存在を推測しない。

### `noteに反映して`

これは外部公開の**Human Approval Gate**を起動する表現であり、AIによる公開実行指示ではない。AIは、対象の公開済み最終稿候補、タイトル、価格、公開範囲、自己開示、SNS展開、公開先の認証・接続状態を提示し、明示承認を確認する。

明示承認後も、対象媒体の利用可能な正式操作手段と権限を確認する。手段または接続がなければ、AIは公開完了と偽らず、ユーザーが実行できる公開パッケージと未実施状態を記録する。

## 4. Sectionから公開後まで

1. **Timeline生成・意味づけ・企画／Section設計**：Timelineの確認済み史実から意味づけを開始し、採用する企画だけを`10_Section制作台本テンプレート.md`へ記録する。Section制作台本に基づき、Story Hub、Session、価格仮説、公開条件を壁打ちで設計する。Timelineには実際に起きた出来事だけを記録する。
2. **Intake / Routing / Source QA**：採用済みSection制作台本を入力としてPipelineを実行し、note本文にはnote制作・公開SOP、SNS展開にはSNS展開基準を必読とする。G0ではDraftを外部公開しない取扱範囲と最終承認者を確定し、最終的な公開範囲、価格、自己開示範囲はPublish前Human Decisionへ残せる。
3. **Production / Output QA**：Sessionごとに承認済み公開構成Profileの本文・別コンテンツと、Session全体を入口にしたSNS投稿案をDraftとして制作し、既存のOutput QAへ渡す。価格、自己開示範囲または公開範囲の未決は、DraftとReviewを止めず未解決Decisionとして保持する。
4. **Publish前Human Decision**：Reviewを通過したDraftについて、本文、タイトル、価格、公開範囲、自己開示、公開対象を人間が承認する。未承認ならPublishだけを停止する。差し戻し時は、修正対象を特定して必要最小限の修正・再Reviewへ戻す。
5. **Publish / Verification**：すべてのPublish前Human Decisionが承認された版だけを公開し、承認版との一致、URL、表示、リンク、価格、公開範囲、日時を既存PipelineのG8／G9で確認する。
6. **Record / Resume**：承認済み公開構成Profileの公開済み最終稿と公開成果物記録をcanonical pathへ配置し、ロードマップまたは制作台本の状態と次アクションを更新する。公開されなかった場合も理由と再開地点を残す。
7. **Feedback / Repository還元**：反応、誤読、導線、制作上の発見をFeedback Candidateとして分類する。単発反応を自動でOSやSOPへ反映しない。

### 4.1 AI Organization SeriesのExternal Audit

AI Organization Seriesでは、Human指摘反映、内部監査、自動修正、内部再監査PASSを完了した稿をFinal Candidateとし、`04_AI_Work_Environment/External_Audit_Pipeline/README.md` へ渡す。Session単位でStory、Practice、Session Archive、Candidate Title、必要なEvidence Note、Series方針、当該Session責任範囲、後続境界およびVoice / Archiveルールだけを抽出する。

外部監査のBLOCKERまたはHuman Decisionが必要なIssueは停止してChatへ戻す。MAJOR／MINORで既存Sourceから一意に修正できるIssueは内部制作側が採否を照合し、採用する場合だけ必要最小限に修正する。外部AIへ全文再設計、文体均質化、Historical Evidence補完または正式稿への直接WRITEをさせない。MAJOR修正後は原則としてExternal Re-Auditし、MINORだけなら内部再監査で完了できる。

Section 1では、External Auditと有効なMINOR反映後のHuman Final Check済みFinal Candidateから、各SessionのStory＋Practiceだけをnote本編1記事として無改変で抽出する。Session Archiveは別コンテンツとして分離し、具体的な公開範囲とMembershipでの扱いがHuman Decisionで確定するまで、note本編へ混入・公開しない。

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

- `Production`では、Section制作台本とG2 PASSを入力に、承認済み公開構成ProfileのDraftを作る。価格、自己開示範囲、公開範囲の未決はDraft内の未解決Decisionとして扱い、Productionを止めない。
- `Review`では、Draftと修正範囲を確認する。Reviewが完了し、Publish前Human Decisionを待つ状態を`Decision Pending`とする。
- `Decision Pending`で価格、自己開示範囲、公開範囲、本文、タイトルまたは公開対象の一部が差し戻された場合、`Revision Required`へ戻す。差し戻し理由、修正対象、所有者、再開条件をSection制作台本に記録する。
- `Revision Required`では、未変更のDraft、Output QAおよびReview結果を有効なまま保持する。本文・表示・公開対象の修正が必要な成果物だけを修正し、修正範囲だけを再Reviewする。価格だけ等、本文を変更しない差し戻しでも、価格表示その他の影響範囲を確認してから`Decision Pending`へ戻す。
- すべてのPublish前Human Decisionが承認され、必要な再ReviewがPASSした場合だけ`Approved`へ進む。`Approved`前のDraft、Review、Decision PendingまたはRevision Requiredを、公開済み・予約済みとして扱わない。

次のいずれかでは、制作台本または公開成果物記録を `Recovery Required` として扱う：公開URLと記録の不一致、承認版と公開候補の不一致、接続／認証失敗、公開直後の表示・リンク・価格異常、Work稿とRepository正本の競合、公開停止を要する安全上の懸念。

復旧では、公開済み最終稿、Approval Record、公開成果物記録、Timeline、媒体上の実際の状態を照合する。安全に一意に戻せる修正だけを行い、それ以外はHuman Ownerへエスカレーションする。削除、価格変更、訂正公開、再投稿、自己開示の変更は新たな対外結果として人間判断を要する。

## 6. 正本の扱い

公開後に将来参照する記事本文の正本は、Section制作台本の承認済み公開構成Profileに従う公開済み最終稿だけである。既定Profileでは `01_Story無料Hub_最終稿.md`、`02_実践編単品有料_最終稿.md`、`03_MS奮闘記メンバーシップ限定_最終稿.md` を使用する。AI Organization Series Section 1では、note本編を `01_note本編_最終稿.md` とし、Session Archiveは公開がHuman承認された場合だけ `02_Session_Archive_最終稿.md` として配置する。note上の表示URLと公開成果物記録を紐付け、Work稿、SNS用短縮稿、旧版、下書き、画面コピーを正本として参照しない。置換や非公開化が生じた場合、旧正本は実データがある場合に限りArchiveへ移し、現行性は公開成果物記録とロードマップで明示する。
