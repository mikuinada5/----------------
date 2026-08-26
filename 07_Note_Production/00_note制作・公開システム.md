# note制作・公開システム v1.0

**Status:** Current / Operational v1.0
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
Timeline → Section → Session → Story / 実践編 / MS
```

- **Timeline**：実際に起きた出来事を時系列で保持する唯一の史実Source。企画、現在地、制作状態、Next、Blockerは扱わない。
- **Section**：最上位の制作単位。テーマ、対象、目的、Story Hub、Session構成、現在地、優先順位、承認状態を一つにまとめる。Section構成はAIが勝手に確定せず、壁打ちで確定する。
- **Session**：1回の制作・公開・展開単位。**1 Session = Story（無料Hub）・実践編（単品有料）・MS奮闘記（メンバーシップ限定）の3記事**とし、同一Session内の3記事を同時に配布する。
- **Story**：Sessionの無料Hub。出来事と変化を読者が入れる文脈として届け、実践編とMS奮闘記への全体の入口を担う。
- **実践編**：無料部分に詳細目次を掲示する単品有料記事。読者が実際に取り組める具体的な実践を担う。
- **MS奮闘記**：生の声・壁打ち・失敗・感情・制作裏側を扱うメンバーシップ限定記事。公開範囲と自己開示は人間承認を要する。

SNS投稿案は、上記3記事で構成するSession全体を入口にして制作する別成果物であり、3記事のいずれかを代替しない。SNS実投稿の可否は別Gateで扱う。

Story HubはSection制作台本内で、Story Candidate、一次Evidence、使用Session、重複・未使用、自己開示の人間判断状態を追跡する。Story Candidateがあることは公開許可ではない。

価格はSectionごとに仮説を置き、読者価値、深度、継続性、無料／有料の役割、既存商品の導線との整合を確認してキャリブレーションする。Section 1では、各Sessionの実践編価格をSection全体で横並びにして確認する。AIは価格を決定・変更・設定しない。価格が未承認なら、公開準備を `HUMAN DECISION REQUIRED` として止める。

## 3. 起動コマンドと現在地復元

### `noteやるよ`

1. `01_Timeline.md`、`02_全体ロードマップ.md`、対象Sectionの制作台本、公開済み最終稿、公開成果物記録を確認する。
2. 未使用Timelineネタと、既存Section／Session／公開記事との関係を確認する。
3. Sectionの現在地、未完了Gate、未解決Decision、公開済み／未公開、SNS接続状態を要約する。
4. 未使用Timelineネタごとに、既存Sectionへの追記、新Session、新Section、保留のいずれかを提案する。Section構成はAIが勝手に確定せず、壁打ちで確定する。価格、自己開示、公開範囲、Story使用可否が未決ならHuman Decisionへ戻す。

AIは、時刻、会話の順番、Work稿の更新日だけから現在地を推測しない。史実Timelineと公開成果物記録が矛盾する場合、または編集競合がある場合は復旧状態へ入り、統合せず停止する。

### `note記事書いて`

対象Sectionが壁打ちで確定し、G2 Source QAがPASSしている場合、AIはSection制作台本に従い、そのSection全体の全Sessionを一括Productionする。各SessionでStory・実践編・MS奮闘記の3記事Draft、Session全体を入口にしたSNS投稿案、Source Application Log、未解決Decisionを作る。各Session内の3記事は同時配布の一組として扱う。一括ProductionはHuman Approval、価格、自己開示、各Sessionの公開を一括承認しない。

対象Sectionが壁打ちで未確定、必読Source未読、Story／自己開示の可否未決の場合は制作を始めず、現在地と不足事項を示す。Timeline未登録だけを理由に事実の存在を推測しない。

### `noteに反映して`

これは外部公開の**Human Approval Gate**を起動する表現であり、AIによる公開実行指示ではない。AIは、対象の公開済み最終稿候補、タイトル、価格、公開範囲、自己開示、SNS展開、公開先の認証・接続状態を提示し、明示承認を確認する。

明示承認後も、対象媒体の利用可能な正式操作手段と権限を確認する。手段または接続がなければ、AIは公開完了と偽らず、ユーザーが実行できる公開パッケージと未実施状態を記録する。

## 4. Sectionから公開後まで

1. **Intake / Routing / Source QA**：Pipelineを実行し、note本文にはnote制作・公開SOP、SNS展開にはSNS展開基準を必読とする。
2. **Section設計**：ロードマップと`10_Section制作台本テンプレート.md` に基づき、Story Hub、Session、価格仮説、公開条件を壁打ちで設計する。Timelineには実際に起きた出来事だけを記録する。
3. **Production / Output QA**：SessionごとにStory・実践編・MS奮闘記の3記事と、Session全体を入口にしたSNS投稿案を制作し、既存のOutput QAへ渡す。
4. **Human Approval**：本文、タイトル、価格、公開範囲、自己開示、公開対象を人間が承認する。未承認なら外部公開しない。
5. **Publish / Verification**：承認版との一致、URL、表示、リンク、価格、公開範囲、日時を既存PipelineのG8／G9で確認する。
6. **Record / Resume**：3記事の公開済み最終稿と公開成果物記録をcanonical pathへ配置し、ロードマップまたは制作台本の状態と次アクションを更新する。公開されなかった場合も理由と再開地点を残す。
7. **Feedback / Repository還元**：反応、誤読、導線、制作上の発見をFeedback Candidateとして分類する。単発反応を自動でOSやSOPへ反映しない。

## 5. 再開状態とエラー復旧

Sectionの現在地は、全体ロードマップまたはSection制作台本で `Planning`、`Production`、`Review`、`Approved`、`Scheduled`、`Published/Complete`、`Update Candidate` のいずれかを記録する。Timelineは史実だけを扱い、状態を記録しない。

次のいずれかでは、制作台本または公開成果物記録を `Recovery Required` として扱う：公開URLと記録の不一致、承認版と公開候補の不一致、接続／認証失敗、公開直後の表示・リンク・価格異常、Work稿とRepository正本の競合、公開停止を要する安全上の懸念。

復旧では、公開済み最終稿、Approval Record、公開成果物記録、Timeline、媒体上の実際の状態を照合する。安全に一意に戻せる修正だけを行い、それ以外はHuman Ownerへエスカレーションする。削除、価格変更、訂正公開、再投稿、自己開示の変更は新たな対外結果として人間判断を要する。

## 6. 正本の扱い

公開後に将来参照する記事本文の正本は、Sessionごとの `01_Story無料Hub_最終稿.md`、`02_実践編単品有料_最終稿.md`、`03_MS奮闘記メンバーシップ限定_最終稿.md` の3ファイルだけである。note上の表示URLと公開成果物記録を紐付ける。Work稿、SNS用短縮稿、旧版、下書き、画面コピーを正本として参照しない。置換や非公開化が生じた場合、旧正本は実データがある場合に限りArchiveへ移し、現行性は公開成果物記録とロードマップで明示する。
