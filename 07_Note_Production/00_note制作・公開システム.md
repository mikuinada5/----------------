# note制作・公開システム v2.3

**Status:** Current / Operational v2.3 / Visual Production Control compatible
**Scope:** note制作、Marketing Review、Header Production、Publication Dry Run、Publication Transaction、公開後記録、Session単位のSNS展開、Repositoryへの知見還元

## 1. 責任と非責任

本Sourceは、noteとSNSに固有の制作単位、公開準備、再開状態、公開済み最終稿の保持を定める。以下は既存Sourceを正とし、本Sourceは再実装しない。

- Source選択・実読・QA・Output QA・Repository Integration・Git：`AI_PRODUCTION_PIPELINE.md`
- 人間承認、停止、再承認、未定義の外部操作：`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- 役割・権限・受け渡し：`AI_ORGANIZATION.md`
- 配置、Archive、CHANGELOG、Git：`REPOSITORY_RULES.md`

Marketing Reviewは、本Source内のnote固有専門監査Gateとして扱う。新しいAI組織上の部署・役職・承認者は作らず、既存PipelineのQA、Production、PublisherおよびHuman Approvalを責任に応じて接続する。Marketing担当は、Human途中確認なしでPublication Decisionの推奨案を作成できるが、Human Final Approval、外部公開、価格・自己開示・公開範囲の最終採否を代行しない。認証・接続または正式投稿手段がないSNS投稿を、実施済みと表現してはならない。接続不能時は未実装／未投稿として公開成果物記録へ残す。

## 2. 制作モデル

制作の階層は次の順序で扱う。

```text
一次資料 → Timeline → 意味づけ → 企画 → 承認済み公開構成Profile（Section／SessionまたはSeries Article） → 成果物
```

- **Timeline**：GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から、実際に起きた出来事を抽出して時系列で保持する、唯一の史実Source。企画、現在地、制作状態、Next、Blockerは扱わない。一次資料の原本はTimelineへ全文複製せず、原本の保管先と参照位置を追跡できる状態にする。
- **意味づけ**：Timelineの確認済み史実を起点に、その史実が何を意味するか、どのSeriesで扱いうるか、どのような学びになるか、読者へどの順番で届けうるかを壁打ちするフェーズ。同一の史実から複数候補が並列に成立してよい。候補はその都度再生成する思考材料であり、Repositoryの永続成果物として保存しない。
- **企画**：意味づけ候補をもとに、今回採用する企画、既存Sectionへの追加、新SectionまたはHuman-approved Series Article、Session候補、Story／Practice／別コンテンツの役割、公開構成Profile、Human Decisionを整理するフェーズ。採用された企画だけを対応する制作記録へ渡し、採用しない候補は保存を要しない。意味づけ・企画はWork Charter、Source Router、Source QAまたはHuman Approvalを代替しない。
- **Section**：Section型企画の最上位制作単位。テーマ、対象、目的、Story Hub、Session構成、現在地、優先順位、承認状態を一つにまとめる。Section構成はAIが勝手に確定せず、壁打ちで確定する。
- **Session**：1回の制作・公開・展開単位。成果物の本数と結合方法は、Section制作台本に記録されたHuman承認済み公開構成Profileを正とする。
- **Series Article**：Human-approvedの既存Series ID／Article IDで管理し、Section／Sessionへ属さない単独記事Profile。Sectionを推測採番せず、Work Charter、Source QA、Production、Marketing、Header、G5、Publicationおよび記録Gateは省略しない。
- **Story**：読者が問題を自分事化し、実体験からSessionテーマへ入り、Practiceを読む理由を作る導入。単独記事またはPracticeと結合したnote本編の前半を担う。
- **Practice**：読者が実際に取り組める手順・テンプレート・確認点を担う。単独記事またはStoryと結合したnote本編の後半として扱う。
- **Session Archive / MS奮闘記**：生の声・壁打ち・失敗・感情・制作裏側を扱う別コンテンツ。Story／Practiceとの責任分離を維持し、公開範囲、Membershipでの扱い、自己開示はHuman Decisionを要する。

既定Profileは、Story、実践編、MS奮闘記を3記事として扱う従来構成とする。Section固有のHuman Decisionがある場合は、そのProfileをSection制作台本へ明記し、既定Profileを上書きできる。SNS投稿案は、承認済み公開構成ProfileのSession全体を入口にして制作する別成果物であり、本文または別コンテンツを代替しない。SNS実投稿の可否は別Gateで扱う。

### 2.1 AI Organization Series Section 1 公開構成Profile

- Section 1はS1-1〜S1-6の全6 Sessionで構成する。
- S1-1は、Story＋Practiceをこの順序で結合したnote本編1記事とし、Session Archiveを別コンテンツとして保持する。
- S1-2以降は、**Story、Practice、Session Archiveを独立した記事／成果物として扱う。** StoryとPracticeを自動的に再結合せず、Session Archiveをどちらにも混在させない。
- S1-2以降の各記事は、それぞれ固有のタイトル、Header Asset、Publication Decisionおよび公開状態を持てる。
- Session Archiveの具体的な公開範囲、Membershipでの扱い、自己開示範囲は別途Human Decisionとし、未決のまま自動公開しない。
- Story本文と確定タイトルはHuman Final Check完了済みFinal Candidateを起点とし、S1-1 Practiceの既存Statusは継続する。S1-2〜S1-6 Practiceの現行本文は`Human Review Draft / 再設計baseline / Redesign Required / Final未確定`として保持し、作業マニュアルへ再設計する。Session Archiveは同Final CandidateをHuman-approved baselineとし、後発仕様との不一致箇所だけを`Revision Required`とする。対象外の本文・タイトル・Human Review結果を変更しない。
- 価格、無料／有料境界、Membership範囲、公開日時、CTAおよび外部公開は別Gateとし、下書き保存または公開準備だけでは決定・実行しない。

### 2.2 「AIとの日常」Series Profile

「AIとの日常」は、AI活用、AI組織づくり、AIを使った仕事の仕組み化に関心があり、完成したノウハウだけでなく、実際にAIと仕事・事業・生活を進める途中の試行錯誤、失敗、会話、判断過程まで見たい読者をTarget Readerとする。

無料のAI組織Seriesが、AIとの仕事・組織づくりを整理・体系化したStory／Productionとして届けるのに対し、「AIとの日常」は、その裏側で実際に起きているAIとの会話、試行錯誤、失敗、エラー、感情、制作途中の出来事および生活との混在をPrimary Evidenceに基づいて見せるMembership contentである。完成後の成功談へ再構成せず、「現在進行形で何が起きていたか」を残す。

- 現行Membership：`稲田みく｜教育と仕事をAIとつくる のメンバーシップ`
- 対象プラン：`AIとの日常`
- 現行価格：月額1,500円
- 標準Magazine：`AIとの日常`
- AIDAILY Series Articleの標準Publication Profileは、**MembershipをONにして対象プラン`AIとの日常`へ登録すること**と、**Magazine`AIとの日常`へ登録すること**の双方を必須とする。Publication Decision生成時に二つを別項目として既定入力し、Humanが明示的にOverrideしない限り省略しない。
- Membership Planは特典記事状態、対象読者、価格および無料／Membership限定境界を制御する。Magazineは記事の収録・Series導線を制御する。両者は別設定であり、Membership Plan登録または境界設定をMagazine登録の代替確認にしない。
- 価格の正本は現行note管理画面上の実設定とし、旧価格案を自動適用しない。変更はHuman Decisionを要する。
- 本文内へ強い加入訴求を機械的に追加せず、note標準のMembership加入導線をPrimary CTAとする。
- 無料／Membership境界は記事ごとのPublication DecisionとHuman Approvalで確定し、編集用マーカーを公開本文へ残さない。
- 無料AI組織Seriesへの関連リンクは、実在する公開URLを正式Sourceから確認できる場合だけ使用し、未公開URLを捏造しない。

Target Reader、Series role、現行Membership plan、Header Templateおよびnote固有Publication Ruleのcanonical Sourceは本節とする。Human OS、Voice OS、Writing Style OS、Brand OSまたは一般Marketing Ruleへ同じ媒体固有仕様を重複配置しない。

#### AIDAILY-003 再Production Guard

AIDAILY-003は、2026-09-02のSource Resolution Incident後の再Production対象である。本文Productionは本Repository改修Taskでは実行せず、別のProduction開始時に次を必須Input／Gateとする。

- 記事中で「ナミさん」という実名表記を使用せず、文脈上自然な「事業をしている友人」等の匿名表現にする。
- Writing Style OSのCurrent canonical versionを責任rootから再解決し、同一Taskで実読する。
- 旧稿から改行だけを削除して完成扱いにせず、新しいSource ResolutionとProductionを通す。
- Human Reviewへ出す版は、その同一Production versionについて内部QAおよびPre-Human Review Style QAがPASS済みであること。

### 2.3 Section記事制作仕様

本節は、Story、PracticeおよびSession Archiveを制作・修正・監査する際の媒体固有仕様である。Voiceの横断判断は`02_Voice_OS/VOICE_OS.md`、公開文章の一般的な文体判断は`06_Writing_Style_OS/WRITING_STYLE_OS.md`を正とし、本節はその範囲内で成果物ごとの役割と実装条件を具体化する。

仕様を更新する場合は、**新しいHuman-approved仕様が対象とする箇所だけを上書きし、矛盾しない既存仕様・本文・承認結果を保持する。** 後発仕様を理由に、対象外の構成、史実、言い回し、公開範囲または商品設計を再設計しない。

#### 2.3.1 Story

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

#### 2.3.2 Practice

Practiceは、読者が記事を横に置いて実際に手を動かし、Session Goalの環境・成果物を完成させるための商品上の作業マニュアルである。StoryやSession Archiveのように会話へ崩しすぎず、初心者がその記事だけを見て完遂できる、整理された文章を優先する。価値は文字数、情報量または高度機能ではなく、初心者の完遂率で判定する。

基本構造は、**Goal → 最初に覚える言葉 → Step → AIへの依頼例 → 出力テンプレート → 完成例 → Completion Check**とする。実行結果や使用環境によって進み方が変わる場合は分岐を示し、つまずきが予想される箇所にはTroubleshootingを置く。

AIへの依頼例だけで終わらせず、各StepでAIが支援することと、人間が目的・採否・優先順位・公開範囲その他を決める箇所を区別する。Human Decisionが必要な箇所を、AIによる自動判断や推奨値で置き換えない。

専門用語は初出で、先に平易な日本語で意味と使う場面を説明し、必要な場合に括弧で正式語を示す。英語をカタカナへ置き換えただけでは説明済みと扱わない。Chat、Work、Codex、Sourceその他の作業環境・概念も、初学者が操作または判断に使える粒度で説明する。ファイルを作成・保存する実践では、正式ファイル名と保存先を一意に示す。

各Sessionの成果を使い捨てにせず、後続Sessionで再利用するSeed、Map、Logまたは同等の中間成果物を残し、何に再利用するかを明記する。順次積み上げるSectionでは、必要に応じて「ここまでにできているもの／今回作るもの／今回終わったらどうなるか／次に積み上げるもの」を示す。

Primary Evidenceは、初心者が実際に止まった地点を抽出するために使用する。各停止点を本文での先回り説明、FAQ、Troubleshooting、注意事項または今回対象外のいずれかへ分類する。正常状態と異常状態、失敗時の戻り先を明示し、画面操作が完遂条件に影響する場合はScreenshot Needed List、Human実機操作、実Screenshotおよび必要な注釈を制作工程に含める。

**Practice Acceptance Criteria**

- [ ] 初心者が記事単体で開始し、Session Goalまで実行できる。
- [ ] 読者が完成させる環境・成果物とCompletion Checkが具体的で、Human実機完遂Reviewを通過している。
- [ ] Goal、用語説明、Step、AIへの依頼例、出力テンプレート、完成例、Completion Checkがある。
- [ ] 必要な分岐とTroubleshootingがあり、失敗時の戻り先が分かる。
- [ ] 正常状態／異常状態、FAQ、注意事項、今回対象外の境界が必要な範囲で示されている。
- [ ] AIが行う支援と、人間が決める箇所が明確に分かれている。
- [ ] 専門用語の初出説明が平易な日本語から始まり、カタカナ化だけで終わっていない。
- [ ] ファイルを扱う場合、正式ファイル名と保存先が一意である。
- [ ] 後続Sessionで使うSeed、Map、Logまたは同等物が残り、再利用先が分かる。
- [ ] 価格を正当化するためだけの不要な高度機能、専門知識または文字数を追加していない。

#### 2.3.3 Session Archive

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

価格はSectionごとに仮説を置き、読者価値、深度、継続性、無料／有料の役割、既存商品の導線との整合を確認してキャリブレーションする。AI Organization Series Section 1では、各Sessionの第2稿をSection全体で横並びにして確認する。Marketingは推奨価格を作るが、Human Final Approval前に最終価格として決定・変更・設定しない。価格、自己開示範囲または公開範囲が未承認でもDraft Production、Human ReviewおよびMarketing Reviewは停止しない。これらが未承認なら、Publication E2Eへの引き渡しを `HUMAN DECISION REQUIRED` として止める。

### 2.4 Marketing Review

本機構はAI Organization Series、Section 1またはS01-02専用ではなく、今後追加されるSection／Sessionを含む**note制作全体の共通Marketing Review機構**とする。個別Section／Sessionは共通Gateと記録様式を再定義せず、Section制作台本へReview Runと、β検証中だけTest Case IDを記録して使用する。

Marketing Reviewの正式OutputはReview Record、Requirement、Publication DecisionおよびGate判定である。このPhaseでは画像生成Toolを起動せず、Review内容を説明するための画像やHeader Assetを生成しない。Header ProductionはMarketing Approvedと最終タイトル確定後に別Phaseとして開始し、`AI_PRODUCTION_PIPELINE.md` §7.6のPhase Tool Routingを通す。

Marketingの最上位目的は、**商品の実際の価値を変えず、必要とする読者にその価値が正しく伝わり、適切な購入または次の行動につながる状態をつくること**である。売上、CTR、購入率その他の指標は改善対象とするが、商品の事実、Purchase Promise、Target Reader、事業上位原則または既存商品設計を破って最大化しない。

煽り、不必要な不安喚起、根拠のない希少性・緊急性、`99％が知らない`、`知らないと損`その他のテンプレート訴求を安易に使用しない。一方、必要な読者へ価値と購入判断材料を明確に伝え、妥当な価格と具体的なCTAを推奨することまで放棄しない。

#### 2.4.1 入場条件と稿名称

Marketingは台本・初稿制作を主導せず、次の工程を通過した**第2稿**から初登場する。

```text
台本
→ note制作・Output QA
→ 初稿
→ Human Review（実内容確認、Practice実機完遂、壁打ち、実素材追加）
→ note制作部が反映
→ 第2稿（内容完成稿）
→ Marketing Review
→ Requirement差し戻し／note制作部修正／Marketing再監査
→ Marketing Approved＋Publication Decision
→ 第3稿
→ Header Production
→ Header QA
→ G5 Human Final Approval Package
→ 最終稿
→ Publication Draft E2E
→ Publication Dry Run（公開直前STOP）
→ Human Publication Approval
→ Publication Transaction
→ Post-Publication Verification
```

- **初稿**：note制作部がProductionと内部品質工程を通してHumanへ提出した最初の稿。
- **第2稿**：Human Review、Practice実機完遂、壁打ち、Screenshot等の実素材を反映し、内容として完成した稿。
- **第3稿**：Marketing Requirementの必要な修正とMarketing再監査を通過し、Publication Decisionまで確定した稿。
- **最終稿**：Humanが第3稿、Header Asset、境界、Publication Decisionおよび必要な自己開示をG5 Final Approvalした正式Publication Package。

第2稿、Human完遂Reviewまたは必要な実素材が不足している場合、Marketing本文監査を開始しない。`Marketing Input Pending`として不足Input、所有者および再開条件を記録し、既存の未完成稿を第2稿と読み替えない。

#### 2.4.2 Source参照

Marketing Inputは次の3段階で扱う。

1. **Fixed Input**：対象Sessionの第2稿、Target Reader、同SessionのStory／Practice／別コンテンツ、Series／Section内の役割、承認済み公開構成Profileおよび適用される既存Publication Ruleを毎回読む。
2. **Decision-specific Required Source**：価格には商品設計・価格履歴・販売Evidence・必要時の現在市場、CTAには次Session・Archive・Membership等、Reader Journeyには前後Session設計、Membershipには正式Membership設計というように、各Decisionに必要なSourceだけを読む。
3. **Additional Source**：上記で不足する場合に限り、読む対象と必要理由をReview Recordへ追加する。

古いDraft、Archive上の発言、未採用案または過去の市場情報を、現行Ruleとして扱わない。変動する市場、競合、価格帯またはnote仕様を外部調査した場合は、調査対象、調査日、Source URLまたは識別子、確認できた事実、Marketing上のInterpretationを分けて記録する。

#### 2.4.3 監査責任と差し戻し

Marketingは、Target Reader、Purchase Promise、商品価値、Story→Practice→次Session等のReader Journey、タイトル、導入、目次・構成、無料／有料境界、価格、CTA、Campaign／Discount、公開日時、SNS Distribution、Magazine／Membership等の既存Publication Rule、市場・競合、Success Metrics／Evaluation PlanおよびPublication Readyを監査・判断する。

Marketing担当は記事本文を直接書き換えない。問題がある場合はnote制作部へ、少なくとも`Requirement ID`、`Must Fix / Nice to Improve`、`問題とEvidence`、`達成すべき状態`、`影響するDecision`、`適用Source`、`再監査範囲`を含むRequirementとして返す。note制作部はVoice、内容、Storyその他の制作責任を守りながら実装し、別の実装方法で同じRequirementを満たせる場合はその根拠を返す。

単なる内容不足はHumanへ即Escalationせず、まずnote制作部へRequirementとして返す。既存Sourceを照合し、代替実装を試してもRequirementと制作責任が両立しない場合だけ、問題、Marketing要求、note制作側の懸念、試した解決策、解決不能理由およびHumanに決めてほしい選択肢を整理して`Human Decision Required`とする。

#### 2.4.4 Publication DecisionとConfidence

Marketing担当はHuman途中確認なしで、推奨価格、無料／有料境界、CTAと優先順位、Campaign実施／非実施、公開日時、SNS Distribution、Success Metricsその他の既存Rule内のPublication Decisionを作成できる。各Decisionには根拠、参照Sourceおよび`High / Medium / Low`のConfidenceを付ける。不明は`Unknown`とし、公開に仮決定が必要なら`検証用仮説 / Confidence Low`として明示する。

Marketing担当は、Target Reader、商品目的、商品の実際の内容・価値、事業上位原則、既存商品設計または既存Publication Ruleを変更しない。既存Ruleがある事項は再判断せず適用し、Ruleがない事項は根拠付き推奨案を作り、Rule変更が必要なら`Human Decision Required`とする。

Review Recordには、少なくとも`Hypothesis`、`Decision`、`Decision Reason`、`Confidence`、`Success Metrics`、`Evaluation Period`を保存する。公開後にHumanから実績値が提供された場合は`Actual Result`、`Interpretation`、`Learning`を追加し、FactとInterpretationを混ぜず、一度の結果だけで一般則化しない。β期間中、主要Marketing施策の変更は原則として一回につき一つとし、品質、事実性、安全性またはRule違反の修正はこの制約から除外する。複数施策を同時変更した場合、その結果を単一要因の効果と断定しない。

#### 2.4.5 Marketing GateとG5 Handoff

Marketing Gateは、`Marketing Input Pending`、`Marketing Revision Required`、`Marketing Approved`または`Human Decision Required`のいずれかを記録する。`Marketing Approved`の条件は「最大限売れそう」ではなく、Must Fixが解決し、Guardrailsに適合し、Publication Decisionと検証計画が揃い、**市場に出して検証できる品質**に達していることである。Nice to ImproveだけではPublicationを止めない。

第3稿完成後、Header Production／Header QAを行い、Humanには第3稿本文、Header Asset、無料／有料またはMembership境界、一画面の`Publication Decision Summary`および必要な自己開示を一つのG5 Approval Packageとして提示する。Summaryには、Price＋Confidence、Free/Paid Boundary＋Confidence、Campaign、Publication Date/Time、CTA、Magazine、Membership、Tags、SNS Distribution、Marketing Gate、unresolved issues、Low Confidence Decisionsおよび今回検証するHypothesisを含める。Humanは一括承認または特定DecisionだけをOverrideでき、Overrideは理由とともに記録する。

Humanが本文、タイトル、導入、無料ライン周辺その他のMarketing評価へ影響する変更を行った場合は、差分と影響範囲だけをMarketing再監査する。G5後のHeader差替えまたは意味が変わる修正は、Header QAまたは該当Reviewへ戻し、変更版をG5再承認する。

#### 2.4.6 Publication Decision Summaryの責任

Publication Decision Summaryは、Publication Transaction時にnote上のPublication Settingsを再構成するCanonical Inputである。本文、Header、境界そのものの正本を代替しない。Series Publication Profileに必須所属先がある場合、Decision生成時にそのProfileからMembershipとMagazineを別項目として継承する。必須項目の欠落またはProfileとの不一致は、Decisionとの機械的一致だけで許容せず、Human Decisionまたは`Pipeline Gap`として停止する。Summaryにない設定をUI上で発見した場合も、既存Ruleから一意に決められなければ停止する。

### 2.5 Header Production

note記事ではHeader Assetを本文と同じPublication Packageの構成要素として扱う。標準位置は、`Marketing Approved → 最終タイトル／第3稿確定 → Header Production → Header QA → G5 Human Final Approval`とする。

Header Productionは`AI_PRODUCTION_PIPELINE.md` §7.6のVisual Production Controlを必須とする。画像生成前に、本節の媒体固有Templateを`MUST`、`MUST_NOT`、`MAY`へ解決したGeneration Contractと実際のTool Requestを作り、Prompt Assembly QAをPASSさせる。生成直後の画像は`GENERATED_UNVERIFIED`であり、本節のHeader QAがPASSするまでHuman Review Candidate、Header Asset登録、`ASSET_READY`またはG5 Packageへ進めない。

Header Asset本体は、公開画像の責任に従って承認済みOneDrive AI Archive等の指定Archiveへ保持し、Public Repositoryへバイナリを重複配置しない。RepositoryにはAsset ID、承認対象、provenance locator、SHA-256、寸法、Header QA、G5 Approval Package ID、note上の公開asset URLおよび表示検証結果を記録する。G5後の差替えは新AssetとしてHeader QAとG5へ戻す。

note公式の現行記事見出し画像推奨サイズは1280×670 pxである（[noteヘルプセンター「登録画像の推奨サイズ一覧」](https://www.help-note.com/hc/ja/articles/360000231642-%E7%99%BB%E9%8C%B2%E7%94%BB%E5%83%8F%E3%81%AE%E6%8E%A8%E5%A5%A8%E3%82%B5%E3%82%A4%E3%82%BA%E4%B8%80%E8%A6%A7)、2026-07-10更新）。仕様は変動し得るため、制作時にはnote公式Helpの現行値を確認する。推奨値と異なる場合はトリミング表示を前提にせず、表示結果と安全領域をQAする。

#### 2.5.1 「AIとの日常」Header Template

**MUST（固定要素）**

- note記事用の横長Header
- 制作時に確認したnote公式の現行推奨寸法／比率。現行確認値は1280×670 px
- 左側にHuman、右側にケイ／AIを置く基本構図
- 漫画調
- 白〜生成りを基調とし、黒を主要色、ピンクをアクセントにする
- 記事タイトルを中央の最重要Visual Elementとして配置する

**MUST NOT（禁止要素）**

- マガジン名「AIとの日常」をHeaderへ入れない
- キャラクターの吹き出し／セリフは原則使用しない
- Primary Evidenceまたは本文にない未確認事実を追加しない
- 記事内容以上の成功、成果、煽りまたは断定を追加しない
- 説明ポスターまたはインフォグラフィックのような情報過多構成にしない
- 承認済み記事タイトルの意味または表記を変更しない

上記MUST／MUST NOTはCreative Directionより優先する。とくに承認済み記事タイトルの完全一致、タイトルを中央の最重要Visual Elementにすること、マガジン名「AIとの日常」を入れないこと、複数を含むキャラクター吹き出し／セリフを入れないことは、実際の画像生成Tool Requestに明記する。単なる内部メモや事後QAへの記載だけではPrompt Assembly QAをPASSしない。

**MAY（記事ごとの可変要素）**

- Human／ケイの表情、ポーズ、動き
- PC、紙、マグ、付箋等の作業小物
- 小物内の短い文字
- 記事内容に応じた軽微な演出

MAYはMUST／MUST NOTと競合しない範囲だけで使用する。小物文字はPrimary Evidenceおよび本文と矛盾させない。記事説明を増やすCreative Directionによって、承認済みタイトルの中心性、余白またはTemplateの識別性を弱めない。

#### 2.5.2 Header QA

- [ ] Generation Contractが対象記事・Header version・Current Source fingerprintと一致している
- [ ] 実際のTool Requestに全MUST／MUST NOT、approved exact title、寸法および禁止要素が含まれ、Prompt Assembly QAがPASSしている
- [ ] note公式の現行推奨サイズ／比率と容量要件を確認した
- [ ] 最終タイトルに誤字・脱字・意味改変がない
- [ ] タイトルが中央の主役として十分視認できる
- [ ] マガジン名「AIとの日常」が混入していない
- [ ] キャラクターの吹き出し／セリフが原則存在しない
- [ ] Human左／ケイ右の基本配置とSeries Visual Identityを維持している
- [ ] 小物文字がPrimary Evidence／本文と矛盾しない
- [ ] 記事内容以上の煽り、成功表現または誇張がない
- [ ] 説明ポスター／インフォグラフィックのような情報過多構成になっていない
- [ ] note下書きへの設定、crop後表示および公開後表示を確認した、または後続Gateの確認項目として記録した

Header QAは生成物の実物を確認して判定する。QA FAIL画像は正式Asset IDを付与せず、Header Asset記録、`ASSET_READY`、G5 Packageまたは通常のHuman Review Candidateへ接続しない。既存Contractから一意に修正可能で再試行上限内なら再生成し、上限到達、Source矛盾、新しいCreative Decisionまたは検査不能ではPipelineのSTOP条件へ戻す。AIが画像を検査できない場合のHuman提示は`HUMAN_ASSET_QA_REQUIRED`の検査依頼に限定し、承認候補の提示と混同しない。

#### 2.5.3 Section Header Visual Family

- **Story:** 読む。紺系のStory Templateを基本とし、レイアウト、ラベル位置、文字階層、余白およびSeriesとしての見た目を原則固定する。
- **Practice:** やる。緑系のPractice Templateを基本とし、同じくTemplate Familyを維持する。
- Story／Practiceで記事ごとに変更できる主対象は、S番号、承認済みタイトル／サブタイトルおよび小さな記事固有モチーフとする。毎回独立した別デザインへ作り直さない。
- **Session Archive:** 裏側を見る／生ログ。Story／Practiceへ視覚統一せず、手描き・生ログ・制作裏側の異物感を意図的に維持する第三のVisual Familyとする。
- Story＝読む、Practice＝やる、Archive＝裏側を見る、の役割差を一覧表示でも識別できることを優先する。Story／PracticeのTemplate Familyを大きく変更する場合はHuman Reviewを要する。

#### 2.5.4 Publication Asset Gate

Human-approved本文だけでは`READY_FOR_PUBLISH`としない。公開単位に必要なPublication Assetが揃い、本文との対応関係が確認できて初めて公開待機状態へ進める。

`HUMAN_APPROVED -> ASSET_READY -> READY_FOR_PUBLISH -> PUBLISHED`

各公開単位でHuman-approved本文、記事種別、必須Header Asset、正しいSection／Session／記事／versionとの紐付け、Header上のS番号・タイトル・記事種別と承認済みPublication Metadataの一致、Asset locatorを確認する。必要Assetが欠落、不一致または未承認の場合は`CONTENT_APPROVED / ASSET_PENDING`でSTOPし、欠落Assetの推測生成、別画像での代用または無断再設計を行わない。Asset制作または正本化の過程でHuman未承認の価格、CTA、公開日時または公開範囲を確定しない。

S1-2は本Profileの最初の適用対象とする。StoryはStory Template、PracticeはPractice Template、Session Archiveは既存の承認済みArchive imageを使用する。Story／PracticeのHeader Assetが未確定または未登録なら本文がHuman-approvedでも`ASSET_PENDING`でSTOPする。Story、Practice、Session ArchiveそれぞれのPublication Decisionが確定するまで、価格、公開範囲、公開日時その他を自動確定しない。

#### 2.5.5 AIDAILY-003 Header Incident Recovery

2026-09-02に生成・提示されたAIDAILY-003 HeaderはHuman Reject済みであり、`Header Unapproved / ReProduction Required`とする。Marketing Review中に生成されたReview画像およびHeader QA前に提示された違反画像を、Header Asset、Asset Ready、G5または承認Evidenceとして再利用しない。

AIDAILY-003の本文、第3稿識別、Marketing Approved、Publication Decisionおよび既存D3は本Incidentの変更対象外であり、その状態を維持する。再Production時はCurrent Sourceを再解決し、同じHeader Production versionについてGeneration Contract、Prompt Assembly QA、生成物実査、Header QA PASSの順に進める。Humanへ通常のHeader候補として提示できるのは、そのQA PASS済みAssetだけである。

### 2.6 Publication Draft E2E／Dry Run／Transaction

#### 2.6.1 G5 Approval Package

G5では、最終本文、Header Asset、無料／有料またはMembership境界、Publication Decision Summaryおよび必要な自己開示を一括してHumanへ提示する。G5はPublication Packageの採用承認であり、note上で外部公開を発生させる操作への承認ではない。

#### 2.6.2 Publication Draft E2E

G5後、承認済みタイトル、本文、Headerおよび境界をnote新規下書きへ反映し、下書き保存を確認する。Publication Settingsは下書きへ必ず永続化できるAssetと仮定しない。AIDAILY-001の実測では、記事タイプ、Magazine、Membership、対象プランおよびTagsは公開設定画面を離れると保持されず、本文、Headerおよび境界だけが下書き保存された。AIDAILY-002では、Dry Runの試し読み画面からキャンセルして設定画面へ戻り、再度試し読み画面へ入ると境界選択が未選択へ戻った一方、Transactionで再設定した境界は公開後Editorへ保存された。現行UIでは境界も画面遷移後の保持を仮定せず、Transaction時にCanonical Inputから最終再設定・再照合する。これらの挙動を公開失敗または承認不足と誤認しない。

#### 2.6.3 Publication Dry Run

Publication Decision Summaryから実際のnote公開設定画面へ、記事タイプ、無料／Membership境界、Magazine、Membership ON／OFF、対象プラン、価格、CTA、Tagsその他の必要設定を構成する。Publication Decisionだけでなく対象Series Publication Profileの必須所属先とも照合し、Magazine登録、Membership登録、対象プランおよび境界を別項目として確認する。設定可能性と承認内容との一致を確認し、**「投稿する」等の外部公開を発生させる最終操作の直前でSTOP**する。Dry Run完了は`Publication Prepared / Not Published`であり、G8 PASS、公開済みまたは公開承認とみなさない。

#### 2.6.4 Human Publication Approval

Dry Run結果として、対象Draft／Article ID、公開先、再構成したPublication Settings、差分、未解決Gapおよび最終操作をHumanへ提示する。対象下書きと外部公開操作を明示したHuman Publication Approval取得後のみPublication Transactionへ進む。G5だけを根拠に「投稿する」を実行しない。

#### 2.6.5 Publication Transaction

1. 承認済み下書きを開き、Draft ID／対象記事を照合する。
2. Publication Decision Summaryを読む。
3. 下書きへ永続化されないPublication SettingsをSummaryから再構成し、対象Series Profileの必須MagazineとMembership Planを別々に設定する。
4. タイトル、本文、Header、境界および全設定をG5 Package／Publication Decision／対象Series Publication Profileと照合する。Dry Run後の画面遷移で境界が保持されたと仮定せず、最終操作直前画面で選択ラインを再確認する。
5. Human Publication Approvalの対象、公開先および最終操作を照合する。
6. 公開を発生させる最終操作を一度だけ実行する。
7. 公開成功表示を確認し、公開URLと公開日時を取得する。

Publication Decisionとの差分、想定外UI、認証問題、対象Draft不一致その他の異常を検出した場合は、推測で回避、別方式へ変更または無承認修正せずSTOPする。

#### 2.6.6 Post-Publication Verification

公開成功表示だけをE2E成功条件にしない。実際の公開ページまたは管理画面で、最低限、公開URL、タイトル、Header、本文、無料／有料またはMembership境界、Membership特典記事状態、対象プラン、表示価格、加入導線、Magazine所属、Tagsおよび公開日時を確認する。Publication Decisionとの一致に加え、対象Series Publication Profileに定義された必須所属先との一致を照合する。Membership境界、Membership Plan登録およびMagazine所属は別項目として確認し、Decisionが必須Profileを欠落していた場合は機械的一致だけでPASSにしない。必要に応じて非ログイン／非対象ユーザー環境を使用し、限定範囲が実際に非表示であることを確認する。全項目一致で初めてPublication E2EをPASSとする。後続Human QAで必須所属先の漏れが判明した場合は、当初PASSの履歴を保持したままVerificationを再オープンし、Gapと現在の修正確認状態を記録する。

SNS Distributionは別成果物・別Gateであり、Publication E2Eへ自動包含しない。実行していないSNS共有を投稿済みと記録しない。

#### 2.6.7 E2E Evidence／Human QA Addendum｜AIDAILY-001

2026-09-01、`AIDAILY-001-D3`／`AIDAILY-001-H1`を対象に、Local PCの認証済みBrowser経路でDraft `n7cf6aee64f0d`を公開した。Automated／Post-Publication Verificationでは、公開URL、タイトル、Header、本文、無料範囲末尾、Membership境界、非ログイン環境での限定本文非表示、Membership Plan`AIとの日常`、月額1,500円、加入導線、4 Tagsおよび公開日時を照合し、当時のPublication Decisionとの一致によりPASSと判定した。

2026-09-02の追加Human QAで、Magazine`AIとの日常`への登録が未実施だったことを検出した。当初DecisionではMagazineを必須条件としていなかったため、これは単純な操作ミスと断定せず、上流のPublication Profile／Decision設計不足を主要改善候補とする。当初PASSの履歴を保持したまま総合Verificationを`Human QA Gap Detected / Reopened`とする。Membership Plan、価格、境界、限定本文非表示、加入導線および4 TagsのPASSは維持する。Humanがnote上でMagazine登録を既に修正済みかは未確認であり、現行状態の確認をHuman Actionとして残す。SNS外部共有は実行していない。詳細は当該Published Artifact Recordを正とする。

#### 2.6.8 Smartphone / Chat Publication Interface

Human ApprovalおよびPublication Pipelineの起動権限は端末種別では決まらない。認証済みHumanとのChat上で、対象、意図および公開範囲が一意に判断できる明示指示は、スマートフォンからでも既存Human Decisionとして受理できる。必要なSource、本文、Asset、Publication Decisionおよび各Gateが満たされている場合、HumanはスマートフォンChatから公開準備または公開Pipelineを開始できる。

ただし、スマートフォン経由を理由にHuman Approval Gateを省略しない。曖昧な「アップして」「出して」だけで対象記事、公開範囲、価格、Membershipまたは公開日時を推測せず、一意に解決できなければSTOPする。ChatはHuman InterfaceでありCanonical Repositoryの代替ではない。正式Source更新が必要なDecisionはRepository Integration後に後続工程が参照する。Repository Writer／Publisher／Browser Automationは既存の権限分離、QA、STOP条件、Publication TransactionおよびPost-Publication Verificationを維持する。正式SourceとGateが満たされる場合、HumanがGitHub UIやLocal file操作を手動で中継することを必須にしない。

## 3. 起動コマンドと現在地復元

### `noteやるよ`

1. GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の利用可能な一次資料に、Timelineへ未反映の史実があるかを確認する。原本の保管先と参照位置を確認し、会話全文や音声全文をTimelineへ複製しない。
2. 一次資料から必要最小限の史実を抽出し、`01_Timeline.md` を生成または更新する。各行で、一次資料識別子、参照位置、抽出日、確認状態を追跡できるようにする。
3. `01_Timeline.md`、`02_全体ロードマップ.md`、対象Sectionの制作台本、公開済み最終稿、公開成果物記録を照合し、Sectionの現在地、未完了Gate、未解決Decision、公開済み／未公開、SNS接続状態を要約する。
4. 確認済みかつ未使用のTimeline史実から意味づけを開始する。この段階では、一つの史実を一つのSeries、SectionまたはSessionへ固定せず、Series候補、学び、読者への順番を並列に壁打ちする。意味づけ候補はTimelineへ書き戻さず、永続保存を要しない。
5. 意味づけをもとに企画を整理する。今回採用する企画についてのみ、既存Sectionへの追加、新SectionまたはHuman-approved Series Article、Session候補、公開構成Profile、Story／Practice／別コンテンツの役割、必要なHuman Decisionを壁打ちで確定する。採用しない候補は削除してよく、将来必要になればTimelineから意味づけを再開する。
6. Section型企画はSection制作台本へ記録し、対応するSectionを全体ロードマップへ反映する。Series Article型企画はHuman-approved Series ID／Article IDとWork Charterを制作記録へ保持し、Sectionを推測採番しない。採用済み制作記録をPipelineのIntake、Source RouterおよびSource QAへ渡す。意味づけ・企画はPipelineのWork Charter、Source Router／Source QA、Human ApprovalまたはPublishの責任を代替しない。

Timelineが未生成または未更新であることは、史実が存在しないことを意味しない。AIは、時刻、会話の順番、Work稿の更新日だけから史実または現在地を推測せず、利用可能な一次資料から確認可能な事実だけをTimelineへ反映する。史実Timelineと公開成果物記録が矛盾する場合、または編集競合がある場合は復旧状態へ入り、統合せず停止する。

### `note記事書いて`

対象Sectionが壁打ちで確定し、G2 Source QAがPASSしている場合、AIはSection制作台本に従い、そのSection全体の全Sessionを一括Productionする。各Sessionで承認済み公開構成Profileの本文・別コンテンツDraft、Session全体を入口にしたSNS投稿案、Source Application Log、未解決Decisionを作る。PipelineのG0では、Draftを外部公開しない取扱範囲と最終承認者を確定する。価格、自己開示範囲または最終的な公開範囲が未決でも、Draftには未解決Decisionとして明示してProductionとReviewを進める。一括ProductionはHuman Approval、価格、自己開示、各Sessionの公開を一括承認しない。

対象Sectionが壁打ちで未確定、必読Source未読またはG2 Source QAがFAILの場合は制作を始めず、現在地と不足事項を示す。Timeline未登録だけを理由に事実の存在を推測しない。

Human-approved Series Articleを対象とする場合は、承認済みSeries ID／Article ID、Target Reader、Series role、公開構成ProfileおよびWork Charterを入力に同じGateを実行する。Section／Sessionへ属さないことを理由にSource QA、Marketing Review、Header QA、G5またはPublication Gateを省略しない。

### `noteに反映して`

これは**G5 Human Final Approval Gate**を起動する表現であり、AIによる公開実行指示ではない。AIは、第3稿、Header Asset、境界、Publication Decision Summary、必要な自己開示、Marketing Gate、未解決事項、低Confidence Decision、公開先の認証・接続状態を一つのApproval Packageとして提示し、明示承認を確認する。

G5明示承認後はPublication Draft E2EとDry Runまで進められるが、Human Publication Approvalなしに外部公開を発生させる最終操作を実行しない。手段または接続がなければ、AIは公開完了と偽らず、未実施状態と最小の再開条件を記録する。

## 4. 企画から公開後まで

1. **Timeline生成・意味づけ・企画／Profile設計**：Timelineの確認済み史実から意味づけを開始し、採用するSection型企画は`10_Section制作台本テンプレート.md`へ記録する。Human-approved Series Article型企画は既存Series ID／Article IDとWork Charterへ記録し、Sectionを推測採番しない。Timelineには実際に起きた出来事だけを記録する。
2. **Intake / Routing / Source QA**：採用済みSection制作台本またはSeries Article Work Charterを入力としてPipelineを実行し、note本文にはnote制作・公開SOP、SNS展開にはSNS展開基準を必読とする。G0ではDraftを外部公開しない取扱範囲と最終承認者を確定する。
3. **Production / Output QA → 初稿**：Sessionごとに承認済み公開構成Profileの本文・別コンテンツと、Session全体を入口にしたSNS投稿案を制作し、既存G4を通過した稿を初稿としてHumanへ渡す。
4. **Human Review → 第2稿**：Humanが実内容を確認し、Practiceでは実際に手順を完遂し、壁打ち、実Screenshotその他の実素材を追加する。note制作部が反映し、内容完成稿である第2稿を作る。
5. **Marketing Review → 第3稿**：第2稿だけを入力にMarketing Reviewを行う。Must FixはRequirementとしてnote制作部へ返し、必要な修正とMarketing再監査を経て`Marketing Approved`とPublication Decisionを確定し、第3稿を作る。Series Publication Profileに必須所属先がある場合はDecisionへ継承し、MembershipとMagazineを別項目として保持する。
6. **Header Production / Header QA**：Marketing Approved後の最終タイトルと第3稿を入力にHeaderを制作し、Asset ID、QA、provenanceおよび表示要件を確定する。
7. **G5 Human Final Approval → 最終Publication Package**：第3稿本文、Header Asset、境界、Publication Decision Summaryおよび必要な自己開示をHumanが一括承認またはDecision単位でOverrideする。影響差分があれば必要範囲だけ再監査し、G5 Approval Recordを確定する。
8. **Publication Draft E2E / Dry Run**：G5 Packageをnote下書きへ反映して本文系Assetの保存を確認し、Publication SettingsをSummaryから構成する。Decisionと対象Series Profileに対してMembership、対象プラン、境界およびMagazineを別項目で照合し、公開最終操作の直前でSTOPして`Publication Prepared / Not Published`とGapを記録する。
9. **Human Publication Approval / Publication Transaction**：対象Draft、公開先、設定および最終操作を明示して承認を得た後、Decisionと対象Series ProfileからSettingsを再構成・再照合して最終操作を実行する。
10. **Post-Publication Verification**：公開URL、表示、Header、本文、境界、Membership、対象プラン、価格、加入導線、Magazine、Tags、日時をDecisionと対象Series Profileに対して照合し、全項目一致でG9／Publication E2EをPASSとする。後続Human QAでGapが判明した場合は初回判定を保持したまま再オープンする。
11. **Record / Resume**：公開済み最終稿、Header Asset記録および公開成果物記録をcanonical pathへ配置する。未公開の第2稿・第3稿・最終稿候補や詳細Marketing EvidenceをPublic公開済み正本へ混入させず、制作台本には安全な状態・locator・再開条件だけを残す。
12. **Feedback / Repository還元**：反応、誤読、導線、制作上の発見をFeedback Candidateとして分類する。単発反応を自動でOSやSOPへ反映しない。SNS Distributionは別Gateで扱う。

### 4.1 AI Organization SeriesのExternal Audit

AI Organization Seriesでは、Human指摘反映、内部監査、自動修正、内部再監査PASSを完了した稿をFinal Candidateとし、`04_AI_Work_Environment/External_Audit_Pipeline/README.md` へ渡す。Session単位でStory、Practice、Session Archive、Candidate Title、必要なEvidence Note、Series方針、当該Session責任範囲、後続境界およびVoice / Archiveルールだけを抽出する。

外部監査のBLOCKERまたはHuman Decisionが必要なIssueは停止してChatへ戻す。MAJOR／MINORで既存Sourceから一意に修正できるIssueは内部制作側が採否を照合し、採用する場合だけ必要最小限に修正する。外部AIへ全文再設計、文体均質化、Historical Evidence補完または正式稿への直接WRITEをさせない。MAJOR修正後は原則としてExternal Re-Auditし、MINORだけなら内部再監査で完了できる。

Section 1では、Storyと確定タイトル、S1-1 Practiceの既存Statusを保持する。S1-1はStory＋Practiceのnote本編1記事を維持する。S1-2〜S1-6は、Practiceの再設計・Human完遂Review・Final化後もStory、Practice、Session Archiveを独立成果物として扱い、自動結合しない。Session Archiveは必要な改訂・再Reviewと具体的な公開範囲／MembershipのHuman Decisionが完了するまで、StoryまたはPracticeへ混入・公開しない。

## 5. 再開状態とエラー復旧

Sectionの現在地は、全体ロードマップまたはSection制作台本で `Planning`、`Production`、`Review`、`Decision Pending`、`Revision Required`、`Approved`、`Scheduled`、`Published/Complete`、`Update Candidate` のいずれかを記録する。Timelineは史実だけを扱い、状態を記録しない。

### 5.1 G5／Publicationの差し戻しと再開

Section Statusとは別に、Marketing Reviewのsubstatusを持つ。状態遷移は次のとおりとする。

```text
Production → 初稿 → Human Review → 第2稿
                                   ↓
                         Marketing Input Pending
                                   ↓ Input充足
                         Marketing Review
                           ↓             ↓
            Marketing Revision Required  Marketing Approved
                           ↓             ↓
                  note制作修正・再監査   第3稿＋Publication Decision
                           └─────────────┘
                                         ↓
                             Header Production / QA
                                         ↓
                          Human Final Approval / G5 Package
                                         ↓
                                  最終稿 / Approved
                                         ↓
                           Publication Draft E2E
                                         ↓
                  Publication Prepared / Not Published（Dry Run STOP）
                                         ↓
                          Human Publication Approval
                                         ↓
                        Publication Transaction / G8
                                         ↓
                     Post-Publication Verification / G9
                                         ↓
                              Published / Complete
```

- `Production`では、Section制作台本とG2 PASSを入力に、承認済み公開構成ProfileのDraftを作る。価格、自己開示範囲、公開範囲の未決はDraft内の未解決Decisionとして扱い、Productionを止めない。
- `Review`では初稿の実内容、Practice完遂、実素材および修正範囲をHumanが確認する。note制作部の反映が完了した稿だけを第2稿とする。
- Marketing Inputが不足する場合は`Marketing Input Pending`とし、Marketing担当が未完成稿を直接修正しない。Must Fixがある場合は`Marketing Revision Required`とし、Requirement、所有者および再開条件を記録する。
- `Marketing Approved`後に第3稿とPublication Decision Summaryを作り、Header Production／QAを完了してG5を待つ状態をSection Statusの`Decision Pending`とする。
- G5で本文、HeaderまたはDecisionが差し戻された場合は、未変更の第3稿、Marketing Review結果およびDecisionを有効なまま保持する。影響範囲だけを修正・再監査して`Decision Pending`へ戻す。
- G5がPASSした場合だけ最終Publication Packageを`Approved`とする。`Publication Prepared / Not Published`はDry Runの停止状態であり、`Published`、予約済み、Human Publication Approval済みまたはG8 PASSとして扱わない。
- Human Publication Approval後に差分または異常を検出した場合、Approvalを利用して設定を推測変更せずSTOPし、必要なReview／Approvalへ戻す。

次のいずれかでは、制作台本または公開成果物記録を `Recovery Required` として扱う：公開URLと記録の不一致、承認版と公開候補の不一致、接続／認証失敗、公開直後の表示・リンク・価格異常、Work稿とRepository正本の競合、公開停止を要する安全上の懸念。

復旧では、公開済み最終稿、Approval Record、公開成果物記録、Timeline、媒体上の実際の状態を照合する。安全に一意に戻せる修正だけを行い、それ以外はHuman Ownerへエスカレーションする。削除、価格変更、訂正公開、再投稿、自己開示の変更は新たな対外結果として人間判断を要する。

## 6. 正本の扱い

公開後に将来参照する記事本文の正本は、承認済み公開構成Profileに従い公開版と照合された公開済み最終稿だけである。既定Profileでは `01_Story無料Hub_最終稿.md`、`02_実践編単品有料_最終稿.md`、`03_MS奮闘記メンバーシップ限定_最終稿.md` を使用する。AI Organization Series Section 1のS1-1ではnote本編を`01_note本編_最終稿.md`、公開がHuman承認されたSession Archiveを`02_Session_Archive_最終稿.md`として配置する。S1-2以降はStory、Practice、Session Archiveそれぞれの独立記事pathを、Section制作台本とREADMEに記録したHuman-approved Profileから一意に決める。「AIとの日常」等のSeries articleはREADMEのSeries／Article pathを使用する。note上の表示URLとHeader Asset記録・公開成果物記録を紐付け、Work稿、SNS用短縮稿、旧版、下書き、画面コピーを正本として参照しない。置換や非公開化が生じた場合、旧正本は実データがある場合に限りArchiveへ移し、現行性は公開成果物記録とロードマップで明示する。
