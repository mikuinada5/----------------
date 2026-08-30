# note制作・公開システム v1.8

**Status:** Current / Operational v1.8 / Marketing Review β
**Scope:** note制作、Marketing Review、公開準備、公開後記録、Session単位のSNS展開、Repositoryへの知見還元

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
- Story本文と確定タイトルはHuman Final Check完了済みFinal Candidateを起点とし、S1-1 Practiceの既存Statusは継続する。S1-2〜S1-6 Practiceの現行本文は`Human Review Draft / 再設計baseline / Redesign Required / Final未確定`として保持し、作業マニュアルへ再設計する。Session Archiveは同Final CandidateをHuman-approved baselineとし、後発仕様との不一致箇所だけを`Revision Required`とする。対象外の本文・タイトル・Human Review結果を変更しない。
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

価格はSectionごとに仮説を置き、読者価値、深度、継続性、無料／有料の役割、既存商品の導線との整合を確認してキャリブレーションする。AI Organization Series Section 1では、各Sessionの第2稿をSection全体で横並びにして確認する。Marketingは推奨価格を作るが、Human Final Approval前に最終価格として決定・変更・設定しない。価格、自己開示範囲または公開範囲が未承認でもDraft Production、Human ReviewおよびMarketing Reviewは停止しない。これらが未承認なら、Publication E2Eへの引き渡しを `HUMAN DECISION REQUIRED` として止める。

### 2.3 Marketing Review β

本機構はAI Organization Series、Section 1またはS01-02専用ではなく、今後追加されるSection／Sessionを含む**note制作全体の共通Marketing Review機構**とする。個別Section／Sessionは共通Gateと記録様式を再定義せず、Section制作台本へReview Runと、β検証中だけTest Case IDを記録して使用する。

Marketingの最上位目的は、**商品の実際の価値を変えず、必要とする読者にその価値が正しく伝わり、適切な購入または次の行動につながる状態をつくること**である。売上、CTR、購入率その他の指標は改善対象とするが、商品の事実、Purchase Promise、Target Reader、事業上位原則または既存商品設計を破って最大化しない。

煽り、不必要な不安喚起、根拠のない希少性・緊急性、`99％が知らない`、`知らないと損`その他のテンプレート訴求を安易に使用しない。一方、必要な読者へ価値と購入判断材料を明確に伝え、妥当な価格と具体的なCTAを推奨することまで放棄しない。

#### 2.3.1 入場条件と稿名称

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
→ Human Final Approval
→ 最終稿
→ note Publication E2E
→ β期間中は公開ボタンを押す直前でSTOP
```

- **初稿**：note制作部がProductionと内部品質工程を通してHumanへ提出した最初の稿。
- **第2稿**：Human Review、Practice実機完遂、壁打ち、Screenshot等の実素材を反映し、内容として完成した稿。
- **第3稿**：Marketing Requirementの必要な修正とMarketing再監査を通過し、Publication Decisionまで確定した稿。
- **最終稿**：Humanが第3稿とPublication DecisionをFinal Approvalした正式稿。

第2稿、Human完遂Reviewまたは必要な実素材が不足している場合、Marketing本文監査を開始しない。`Marketing Input Pending`として不足Input、所有者および再開条件を記録し、既存の未完成稿を第2稿と読み替えない。

#### 2.3.2 Source参照

Marketing Inputは次の3段階で扱う。

1. **Fixed Input**：対象Sessionの第2稿、Target Reader、同SessionのStory／Practice／別コンテンツ、Series／Section内の役割、承認済み公開構成Profileおよび適用される既存Publication Ruleを毎回読む。
2. **Decision-specific Required Source**：価格には商品設計・価格履歴・販売Evidence・必要時の現在市場、CTAには次Session・Archive・Membership等、Reader Journeyには前後Session設計、Membershipには正式Membership設計というように、各Decisionに必要なSourceだけを読む。
3. **Additional Source**：上記で不足する場合に限り、読む対象と必要理由をReview Recordへ追加する。

古いDraft、Archive上の発言、未採用案または過去の市場情報を、現行Ruleとして扱わない。変動する市場、競合、価格帯またはnote仕様を外部調査した場合は、調査対象、調査日、Source URLまたは識別子、確認できた事実、Marketing上のInterpretationを分けて記録する。

#### 2.3.3 監査責任と差し戻し

Marketingは、Target Reader、Purchase Promise、商品価値、Story→Practice→次Session等のReader Journey、タイトル、導入、目次・構成、無料／有料境界、価格、CTA、Campaign／Discount、公開日時、SNS Distribution、Magazine／Membership等の既存Publication Rule、市場・競合、Success Metrics／Evaluation PlanおよびPublication Readyを監査・判断する。

Marketing担当は記事本文を直接書き換えない。問題がある場合はnote制作部へ、少なくとも`Requirement ID`、`Must Fix / Nice to Improve`、`問題とEvidence`、`達成すべき状態`、`影響するDecision`、`適用Source`、`再監査範囲`を含むRequirementとして返す。note制作部はVoice、内容、Storyその他の制作責任を守りながら実装し、別の実装方法で同じRequirementを満たせる場合はその根拠を返す。

単なる内容不足はHumanへ即Escalationせず、まずnote制作部へRequirementとして返す。既存Sourceを照合し、代替実装を試してもRequirementと制作責任が両立しない場合だけ、問題、Marketing要求、note制作側の懸念、試した解決策、解決不能理由およびHumanに決めてほしい選択肢を整理して`Human Decision Required`とする。

#### 2.3.4 Publication DecisionとConfidence

Marketing担当はHuman途中確認なしで、推奨価格、無料／有料境界、CTAと優先順位、Campaign実施／非実施、公開日時、SNS Distribution、Success Metricsその他の既存Rule内のPublication Decisionを作成できる。各Decisionには根拠、参照Sourceおよび`High / Medium / Low`のConfidenceを付ける。不明は`Unknown`とし、公開に仮決定が必要なら`検証用仮説 / Confidence Low`として明示する。

Marketing担当は、Target Reader、商品目的、商品の実際の内容・価値、事業上位原則、既存商品設計または既存Publication Ruleを変更しない。既存Ruleがある事項は再判断せず適用し、Ruleがない事項は根拠付き推奨案を作り、Rule変更が必要なら`Human Decision Required`とする。

Review Recordには、少なくとも`Hypothesis`、`Decision`、`Decision Reason`、`Confidence`、`Success Metrics`、`Evaluation Period`を保存する。公開後にHumanから実績値が提供された場合は`Actual Result`、`Interpretation`、`Learning`を追加し、FactとInterpretationを混ぜず、一度の結果だけで一般則化しない。β期間中、主要Marketing施策の変更は原則として一回につき一つとし、品質、事実性、安全性またはRule違反の修正はこの制約から除外する。複数施策を同時変更した場合、その結果を単一要因の効果と断定しない。

#### 2.3.5 Marketing GateとHuman Final Approval

Marketing Gateは、`Marketing Input Pending`、`Marketing Revision Required`、`Marketing Approved`または`Human Decision Required`のいずれかを記録する。`Marketing Approved`の条件は「最大限売れそう」ではなく、Must Fixが解決し、Guardrailsに適合し、Publication Decisionと検証計画が揃い、**市場に出して検証できる品質**に達していることである。Nice to ImproveだけではPublicationを止めない。

第3稿完成時、Humanには第3稿本文と一画面の`Publication Decision Summary`を提示する。Summaryには、Price＋Confidence、Free/Paid Boundary＋Confidence、Campaign、Publication Date/Time、CTA、Magazine、Membership、SNS Distribution、Marketing Gate、unresolved issues、Low Confidence Decisionsおよび今回検証するHypothesisを含める。Humanは一括承認または特定DecisionだけをOverrideでき、Overrideは理由とともに記録する。

Humanが本文、タイトル、導入、無料ライン周辺その他のMarketing評価へ影響する変更を行った場合は、差分と影響範囲だけをMarketing再監査する。

#### 2.3.6 Publication E2E β

Human Final Approval後、最終稿とApproved Publication Decisionを既存PipelineのPublisherへ引き渡す。β期間中は、利用可能な正式操作手段でnote下書きへ設定可能な本文、タイトル、画像、無料／有料境界、価格、CTA、Magazine／Membershipその他の設定を反映し、承認版との一致を確認して、**公開ボタンを押せば公開される最終確認画面の直前でSTOP**する。この状態は`Publication Prepared / Not Published`であり、`Published`またはG8 PASSとして扱わない。

Marketing Decisionにあるが現在のE2Eで設定できない項目、note側にあるがMarketing Decisionにない項目、接続・認証不足、予約投稿その他の利用不能機能は`Pipeline Gap`として記録する。予約投稿を実行できなくても推奨公開日時は決定し、Publication Scheduleへ渡せる形式で保持する。公開操作は、β終了後に別途明示された承認範囲が成立するまで実行しない。

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

これは**Human Final Approval Gate**を起動する表現であり、AIによる公開実行指示ではない。AIは、第3稿、Publication Decision Summary、Marketing Gate、未解決事項、低Confidence Decision、公開先の認証・接続状態を提示し、明示承認を確認する。

明示承認後も、対象媒体の利用可能な正式操作手段と権限を確認する。手段または接続がなければ、AIは公開完了と偽らず、ユーザーが実行できる公開パッケージと未実施状態を記録する。

## 4. Sectionから公開後まで

1. **Timeline生成・意味づけ・企画／Section設計**：Timelineの確認済み史実から意味づけを開始し、採用する企画だけを`10_Section制作台本テンプレート.md`へ記録する。Section制作台本に基づき、Story Hub、Session、価格仮説、公開条件を壁打ちで設計する。Timelineには実際に起きた出来事だけを記録する。
2. **Intake / Routing / Source QA**：採用済みSection制作台本を入力としてPipelineを実行し、note本文にはnote制作・公開SOP、SNS展開にはSNS展開基準を必読とする。G0ではDraftを外部公開しない取扱範囲と最終承認者を確定する。
3. **Production / Output QA → 初稿**：Sessionごとに承認済み公開構成Profileの本文・別コンテンツと、Session全体を入口にしたSNS投稿案を制作し、既存G4を通過した稿を初稿としてHumanへ渡す。
4. **Human Review → 第2稿**：Humanが実内容を確認し、Practiceでは実際に手順を完遂し、壁打ち、実Screenshotその他の実素材を追加する。note制作部が反映し、内容完成稿である第2稿を作る。
5. **Marketing Review → 第3稿**：第2稿だけを入力にMarketing Reviewを行う。Must FixはRequirementとしてnote制作部へ返し、必要な修正とMarketing再監査を経て`Marketing Approved`とPublication Decisionを確定し、第3稿を作る。
6. **Human Final Approval → 最終稿**：第3稿本文とPublication Decision SummaryをHumanが一括承認またはDecision単位でOverrideする。影響差分があれば必要範囲だけMarketing再監査し、G5 Approval Recordと最終稿を確定する。
7. **Publication E2E β**：最終稿とApproved Publication Decisionをnote下書きへ反映し、承認版との一致と設定可能項目を確認する。β期間中は公開ボタン直前でSTOPし、`Publication Prepared / Not Published`とPipeline Gapを記録する。
8. **Publish / Verification**：β終了後に別途承認された場合だけ公開し、承認版との一致、URL、表示、リンク、価格、公開範囲、日時を既存PipelineのG8／G9で確認する。
9. **Record / Resume**：公開済み最終稿と公開成果物記録をcanonical pathへ配置する。未公開の第2稿・第3稿・最終稿候補や詳細Marketing EvidenceをPublic公開済み正本へ混入させず、Section制作台本には安全な状態・locator・再開条件だけを残す。
10. **Feedback / Repository還元**：反応、誤読、導線、制作上の発見をFeedback Candidateとして分類する。単発反応を自動でOSやSOPへ反映しない。

### 4.1 AI Organization SeriesのExternal Audit

AI Organization Seriesでは、Human指摘反映、内部監査、自動修正、内部再監査PASSを完了した稿をFinal Candidateとし、`04_AI_Work_Environment/External_Audit_Pipeline/README.md` へ渡す。Session単位でStory、Practice、Session Archive、Candidate Title、必要なEvidence Note、Series方針、当該Session責任範囲、後続境界およびVoice / Archiveルールだけを抽出する。

外部監査のBLOCKERまたはHuman Decisionが必要なIssueは停止してChatへ戻す。MAJOR／MINORで既存Sourceから一意に修正できるIssueは内部制作側が採否を照合し、採用する場合だけ必要最小限に修正する。外部AIへ全文再設計、文体均質化、Historical Evidence補完または正式稿への直接WRITEをさせない。MAJOR修正後は原則としてExternal Re-Auditし、MINORだけなら内部再監査で完了できる。

Section 1では、Storyと確定タイトル、S1-1 Practiceの既存Statusを保持する。S1-2〜S1-6 Practiceは再設計・Human完遂Review・Final化後の承認済み本文をStoryと結合してnote本編1記事とする。Session Archiveは別コンテンツとして分離し、必要な改訂・再Reviewと具体的な公開範囲／MembershipのHuman Decisionが完了するまで、note本編へ混入・公開しない。

## 5. 再開状態とエラー復旧

Sectionの現在地は、全体ロードマップまたはSection制作台本で `Planning`、`Production`、`Review`、`Decision Pending`、`Revision Required`、`Approved`、`Scheduled`、`Published/Complete`、`Update Candidate` のいずれかを記録する。Timelineは史実だけを扱い、状態を記録しない。

### 5.1 Human Final Approvalの差し戻しと再開

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
                          Human Final Approval / G5
                                         ↓
                                  最終稿 / Approved
                                         ↓
                  Publication Prepared / Not Published（β STOP）
```

- `Production`では、Section制作台本とG2 PASSを入力に、承認済み公開構成ProfileのDraftを作る。価格、自己開示範囲、公開範囲の未決はDraft内の未解決Decisionとして扱い、Productionを止めない。
- `Review`では初稿の実内容、Practice完遂、実素材および修正範囲をHumanが確認する。note制作部の反映が完了した稿だけを第2稿とする。
- Marketing Inputが不足する場合は`Marketing Input Pending`とし、Marketing担当が未完成稿を直接修正しない。Must Fixがある場合は`Marketing Revision Required`とし、Requirement、所有者および再開条件を記録する。
- `Marketing Approved`後に第3稿とPublication Decision Summaryを作り、Human Final Approvalを待つ状態をSection Statusの`Decision Pending`とする。
- Human Final Approvalで本文またはDecisionが差し戻された場合は、未変更の第3稿、Marketing Review結果およびDecisionを有効なまま保持する。影響範囲だけを修正・再監査して`Decision Pending`へ戻す。
- G5がPASSした場合だけ最終稿を`Approved`とする。β期間中の`Publication Prepared / Not Published`を`Published`、予約済みまたはG8 PASSとして扱わない。

次のいずれかでは、制作台本または公開成果物記録を `Recovery Required` として扱う：公開URLと記録の不一致、承認版と公開候補の不一致、接続／認証失敗、公開直後の表示・リンク・価格異常、Work稿とRepository正本の競合、公開停止を要する安全上の懸念。

復旧では、公開済み最終稿、Approval Record、公開成果物記録、Timeline、媒体上の実際の状態を照合する。安全に一意に戻せる修正だけを行い、それ以外はHuman Ownerへエスカレーションする。削除、価格変更、訂正公開、再投稿、自己開示の変更は新たな対外結果として人間判断を要する。

## 6. 正本の扱い

公開後に将来参照する記事本文の正本は、Section制作台本の承認済み公開構成Profileに従う公開済み最終稿だけである。既定Profileでは `01_Story無料Hub_最終稿.md`、`02_実践編単品有料_最終稿.md`、`03_MS奮闘記メンバーシップ限定_最終稿.md` を使用する。AI Organization Series Section 1では、note本編を `01_note本編_最終稿.md` とし、Session Archiveは公開がHuman承認された場合だけ `02_Session_Archive_最終稿.md` として配置する。note上の表示URLと公開成果物記録を紐付け、Work稿、SNS用短縮稿、旧版、下書き、画面コピーを正本として参照しない。置換や非公開化が生じた場合、旧正本は実データがある場合に限りArchiveへ移し、現行性は公開成果物記録とロードマップで明示する。
