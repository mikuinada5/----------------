# Inbox・Personal Archive 受領・配属運用原則

## 1. 目的

本Sourceは、正式な配属先が確定していない受領物を `00_Inbox` で受け付け、内容把握、評価、分類、必要な人間判断、正式配属、検証およびInbox処理完了まで接続する共通運用を定義する。

あわせて、OneDrive上の `04_Personal_Archive` における `Original`、`Processed` および `Derived` の責任境界を定義する。

目的は、未整理資産を人間が毎回開いて分類し、保存先を探索し、AI間で運搬する工程を減らしながら、次を維持することである。

- 正式Sourceと未整理資産を混同しない
- 原本と加工物を混同しない
- センシティブ情報を不用意に検索・外部提供しない
- 配属後も原本まで追跡できるprovenanceを保持する
- 削除するべきかという意味判断、正式採用その他の人間判断をAIが代行しない
- Inboxに処理済み資産を永久滞留させない

本Sourceの正式配置は、`04_AI_Work_Environment/INBOX_AND_PERSONAL_ARCHIVE.md` とする。

本Sourceは、`04_AI_Work_Environment` が持つ作業環境と工程接続責任のうち、InboxおよびPersonal Archiveに関する専門領域を担う。

OneDrive上の `AI/00_Inbox` および `AI/04_Personal_Archive` は、AI Work Environmentが管理するRepository外の運用対象領域である。これらをRepository、正式Source置場または新しいトップレベル責任単位として扱わない。

Repository上の正式構造および変更記録は本Sourceで独自に定義せず、`REPOSITORY_RULES.md` を正とする。

---

## 2. 適用範囲

本Sourceは、主として次を対象とする。

- OneDrive上の `AI/00_Inbox`
- OneDrive上の `AI/04_Personal_Archive`
- Inboxへ投入されたファイル、フォルダおよびアーカイブ
- InboxからRepository、Personal Archiveその他の既存責任領域への配属工程
- OriginalからProcessed、ProcessedからDerivedへの加工・参照関係
- Inbox処理Ledger
- Inbox処理におけるローカル環境、OneDrive、Chat、Codexその他の工程接続

OneDrive上の対象領域は、作業環境と工程接続上の管理対象であり、Repository上の正式Source領域ではない。

本Sourceは、個別サービス固有のデータ仕様、個別媒体の制作方法、正式Sourceの内容、専門成果物の承認Status、RepositoryのGit運用、外部公開手順またはAI組織上の担当権限を新しく定義しない。

X、ChatGPTその他の個別サービスに固有の抽出仕様が必要な場合は、本Sourceの共通原則を維持したうえで、必要な実装または個別手順として扱う。

個別サービス固有のルールを恒久運用として採用する場合は、`AI_ORGANIZATION.md`、`REPOSITORY_RULES.md` および適用される専門Sourceに従い、その責任単位、保存位置、承認経路および変更管理を決定する。

一時的な抽出スクリプトまたは単発処理であることだけを理由として、新しい正式Sourceまたは責任単位を作らない。

---

## 3. 関連Sourceとの責任境界

### AI作業環境

Chat、Work、Codex、VS Code、Repository、Git、GitHub、外部AIその他の環境全体の役割と工程接続は、`04_AI_Work_Environment/AI_WORK_ENVIRONMENT.md` を正とする。

本Sourceは、そのうちInboxおよびPersonal Archiveを使用する受領・配属工程を具体化する。

### Human-in-the-loop

人間承認の要否、自動進行条件、停止条件、再承認条件、エスカレーション形式および完了判断の横断原則は、`03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` を正とする。

本Sourceは、これらを独自に再定義せず、Inbox処理上の現在状態、判断対象および再開地点を接続する。

### Repository

Repositoryの正式構造、正式配置、Archive、Git、CHANGELOGおよび変更管理は、`REPOSITORY_RULES.md` を正とする。

本Sourceは、未整理資産をRepositoryへ配属する場合も、正式Sourceとしての採用、承認、配置、変更記録またはGit運用を代替しない。

### AI組織・専門Source

AI組織上の担当、権限、差し戻し先および責任分離は、`AI_ORGANIZATION.md` と適用される専門Sourceを正とする。

本Sourceは、Inboxを独立したAI部署、専任AIまたは承認主体として扱わない。

実際のInbox処理主体は、当該タスクに割り当てられたAI、実行環境および責任主体について、`AI_ORGANIZATION.md`、`AI_WORK_ENVIRONMENT.md`、適用される専門Sourceおよび個別指示から決定する。

本Sourceは、誰がInbox処理担当AIであるかを独自に固定しない。

---

## 4. 用語

### 受領物

外部サービス、Chat、人間、他環境その他から取得され、責任領域または恒久保存先がまだ確定していないファイル、フォルダまたはデータ群。

### authoritative copy

当該資産の責任を持つ正規の保存先に存在し、今後の参照、加工または復旧の基準となるコピー。

バックアップまたは一時的な複製が存在する場合も、どのコピーがauthoritativeであるかを一意にする。

authoritative copyであることは、その資産がRepository上の正式Source、承認済み成果物または正式判断であることを意味しない。

### Original

外部から取得した未改変原本。内容の解釈、正規化または正式採用を行っていない状態。

### Processed

Originalから必要範囲を抽出、正規化または構造化した再利用可能データ。

### Derived

OriginalまたはProcessedを根拠として作成した索引、分類、分析、候補、履歴その他の二次資料。

### 通常検索

日常的なAI参照、note等の企画検索、テーマ探索、横断検索その他、個別のセンシティブ利用承認を毎回前提としない検索。

### provenance

Original、ProcessedおよびDerivedの間で、どの原本から、どの条件と方法で生成されたかを追跡できる情報。

### identity evidence

Verified時に確認したAsset、Inbox上のsourceおよびauthoritative copyが、現在も同一であることを確認するための運用証拠。

必要な範囲で、Asset ID、Verified Event ID、SHA algorithmおよびvalue、正規化した絶対パス、サイズ、更新日時、検証日時、同期証拠参照ならびに利用可能なファイル識別情報を含む。

サイズまたは更新日時の一致だけを、内容同一性の証明として扱わない。

### 通常ファイル

本Sourceの初期自動除去対象における通常ファイルとは、pathを通常解決した結果、symlink、junction、reparse pointその他の参照・転送構造を介さず、単独のファイル実体として安全に識別できるものをいう。

通常ファイルとして認識できることだけでは、Inbox上のsourceとauthoritative copyが相互に独立した実体であることを証明しない。hardlinkその他により同一実体を共有していないことは、§19の条件として別途確認する。

具体的なOS APIまたは検出方法は、本Sourceで固定しない。

### formal policy reference

自動処理へ適用した正式Sourceのrevisionと対象制度を一意に識別する運用参照。

少なくとも、Repository相対path、対象節または制度識別子、およびGit commit、Git blob、content hashその他の不変なSource revision識別子を含む。

formal policy referenceは、実際にどの正式Source revisionを根拠として実行したかを追跡するために使用する。Helperとの実行互換性そのものは、Policy Contract Versionと、人間承認済みImplementation Contractおよび必要なimplementation identityによって判定する。

具体的な不変識別方式は、本Sourceで固定しない。

### Source revision

Git commit、Git blob、content hashその他の不変識別子によって識別される、正式Sourceそのもののrevision。

provenance、監査、変更履歴およびformal policy referenceに使用する。Source本文が正式変更されれば変化し得る。

Source revisionは、Helperとの実行互換性を示すPolicy Contract Versionではない。

### Policy Contract Version

自動除去Helperが満たす実行条件、安全条件、入出力責任およびfail-closed条件の互換性境界を識別する、本自動処理制度に限定した安定識別子。

Source revision、Repository全体のVersion、成果物Versionまたは新しい独立Version管理制度として扱わない。

実行互換性に影響する制度変更がある場合だけ更新する。誤字訂正、説明改善、CHANGELOG追記またはEnabledとDisabledの状態変更など、実行Contractを変えない変更だけを理由として更新しない。

変更が実行Contractへ影響するか一意に判断できない場合は、互換性を推定せず、人間判断またはfail-closedへ接続する。

### Implementation Contract

SkillまたはHelper実装が対応するPolicy Contract上の実装責任を識別する識別子。

実装側は対応するImplementation Contractを宣言できるが、その宣言だけでは実行資格または互換承認を得ない。

現在のPolicy Contractで使用できるImplementation Contractは、正式Source側の人間承認済み対応関係と一致する必要がある。Helper自身の自己申告だけを互換性の根拠として扱わない。

### implementation identity

有効化前QAを通過したSkillおよびHelper実装を一意に識別する不変識別情報。

SkillまたはHelper revision、content hash、Git commit、file hash setその他の同等方式を利用できる。具体方式は実装へ委譲する。

正式Source側の承認済みidentityまたは人間承認済みactivation recordへの不変参照と一致する場合だけ、承認済み実装の証拠として使用できる。Helper自身がidentityを書き換えるだけで承認済みにはならない。

---

## 5. Inboxの責任

`00_Inbox` は、

> 正式な配属先がまだ確定していない受領物を一時的に受け付け、評価し、適切な責任領域へ配属する工程接続地点

である。

Inbox自体を次として扱わない。

- 正式Source
- 正式な承認記録
- Personal Archive
- Repository上のArchive
- 長期保存場所
- 作業用Temp
- キャッシュ
- ゴミ箱
- 正式配属先の代替
- 下流制作タスクの恒久的な待機場所

Inboxへ存在することだけで、その受領物が承認済み、正式利用可能、長期保持対象または外部AI提供可能になったとは判断しない。

---

## 6. Inboxの対象と非対象

### 対象

次に該当する受領物は、Inboxを受付口として使用できる。

- 外部サービスから取得したアーカイブ
- Chat等から取得した未配属ファイル
- 責任領域または保存先が未確定の資料
- 内容確認後でなければ配属先を判断できないもの
- 原本、加工物および正式Sourceの区別が必要なもの
- 人間がまずAIへ内容把握または分類を委ねたいもの
- 複数の配属候補が考えられ、既存Sourceとの照合が必要なもの
- 第三者情報、非公開情報その他のセンシティブ性を確認する必要があるもの
- 長期保持予定であっても、配属先、センシティブ性またはOriginalとしての扱いが未確定のもの
- 内容確認前には秘密情報またはセンシティブ情報の混在有無を判断できない外部サービスのフルアーカイブ等

### 非対象

次に該当するものを機械的にInboxへ送らない。

- 保存先が正式Sourceまたは承認済み指示から一意に決まるCodex生成物
- 既知の正式保存先を持つ承認済み成果物
- 作業用Temp
- キャッシュ
- テスト出力
- 再生成可能で恒久保持を必要としない中間生成物
- 保存先がすでに確定しており、内容評価、分類または責任判断を必要としない長期保管資産
- 実行環境固有の一時ログ
- APIキーそのもの
- Tokenそのもの
- Cookieファイルそのもの
- パスワード
- 認証秘密情報のみを保持・移送することを目的とするファイル

作成目的、責任領域、保存先、WRITE権限、承認条件およびQA条件が確定している場合、Codex等はInboxを経由せず、定義済みの保存先へ直接WRITEできる。

秘密情報が混在する可能性のある外部アーカイブを受領対象とすることは、秘密情報そのものを意図的にInboxへ投入する権限を意味しない。

---

## 7. 作業開始時の原則

Inbox処理を開始するとき、AIは次を確認する。

- Inboxの実在場所
- 対象受領物
- ファイル、フォルダまたはアーカイブの種別
- READ可否
- OneDriveのローカル利用可能状態
- プレースホルダー、競合コピーまたは同期異常の有無
- サイズおよび更新状態の安定性
- 現在のRepositoryと作業ツリー
- 適用される正式Source
- 既存の配属候補
- 既存資産との重複または競合
- 当該タスクで許可された変更範囲と停止点

ファイル名、拡張子またはInboxへの投入事実だけを根拠として、責任領域、正式性、承認状態、センシティブ性または配属先を決定しない。

人間にファイルの再探索、再アップロード、内容の再説明または保存先の探索を求める前に、AIが利用可能な環境とSourceから必要情報を取得する。

---

## 8. 標準E2E

Inbox処理の標準工程は次のとおりとする。

```text
受領
→ 安定性確認
→ ファイル／フォルダ識別
→ SHA・重複確認
→ manifestまたは構造の先行解析
→ センシティブ判定
→ 責任・利用目的分類
→ 原本保持要否と配属候補確定
→ 必要時のみChat判断
→ 配属
→ 配属先検証
→ 必要な加工・索引
→ provenance確認
→ Inbox側処理
→ Ledger更新
→ Closed
```

人間判断が不要な工程では、工程が移行したことだけを理由に停止しない。

加工または索引は、当該受領目的の完了に必要な場合だけ作成する。加工が別の長期作業となる場合は、Inboxへ受領物を滞留させず、責任を持つ下流工程へ正式に引き渡す。

アーカイブまたはフォルダは、可能な限りmanifest、中央ディレクトリ、ファイル一覧、サイズその他の構造情報を先に確認し、必要性を確認せず全文展開しない。

### 8.1 現行実装と標準要件

本Sourceが正式採用されていることと、対応するSkill、Helperその他の実行手段が実装・有効化されていることを区別する。

本Sourceに自動処理条件が定義されていることだけを理由として、現在の実装がその条件を機械検証可能、自動実行可能または包括的な実行権限を持つと判断しない。

Verified済みInbox重複コピーの自動除去機能は、少なくとも次を完了するまで有効化しない。

1. 対応するSkillおよびHelperの本Sourceへの同期
2. 実データを変更しないshadow dry-run
3. 許可条件および禁止条件に対する否定テスト
4. 必要な内部QA
5. 本Sourceの全条件を機械的に検証できることの確認

未実装、未対応、判定不能またはCapability不足の条件を、完了または適合として扱わない。

Inbox自動処理を行う正式Helper runtimeは、PowerShell 7以上とする。Windows PowerShell 5.1は正式runtimeとして使用しない。

具体的な起動コマンド、Version check、fail-fast、文字コード、JSONL入出力その他の実装方法は、対応するSkillおよびHelperの責任とする。

具体的な検索エンジン、解析ライブラリ、ハッシュ実装その他の実装方式は、本Sourceで固定しない。

### 8.2 自動除去制度状態

本SourceにおけるVerified済みInbox重複コピー自動除去制度のauthoritativeな制度情報は、次とする。

`automatic_removal_policy_state: Disabled`

`automatic_removal_policy_contract: inbox-auto-removal-v1`

`automatic_removal_approved_implementation_contract: chat-artifact-inbox-auto-removal-v1`

`automatic_removal_approved_implementation_identity: sha256:75a688846e24b29ed475053d47a89f518be4cdb607864a26fa434adbcbe6bf00`

制度状態はDisabledとEnabledを区別し、初期状態はDisabledとする。`none`は、現時点で自動除去を実行できるImplementation Contractまたはimplementation identityが人間承認されていないことを示す。

`inbox-auto-removal-v1`は、本節で定める条件付き自動除去制度の初期Policy Contract Versionである。

どのImplementation Contractおよびimplementation identityを現在のPolicy Contractで使用可能とするかを許可する権限は、正式Source側の人間承認に属する。

SkillまたはHelperが自ら対応Contractまたはidentityを宣言したことだけでは、互換性も実行資格も成立しない。正式Source上の人間承認済み対応関係と一致する必要がある。

必要なimplementation identityは、正式Sourceに不変識別子を直接保持するか、人間承認済みactivation recordへの不変参照として保持できる。LedgerまたはHelper configだけを承認主体または互換性の正にしない。

activation recordを使用する場合も、正式Source側がその不変参照を保持する。activation recordはQAと人間承認の証拠であり、正式Sourceに代わる制度状態または独立した承認主体にはしない。

Enabledへの変更には、次を順にすべて必要とする。

1. 本Sourceの正式採用
2. Policy Contract Versionの確定
3. 対応するSkillおよびHelperの実装
4. implementation identityの確定
5. 実データを変更しないshadow dry-run
6. 許可条件および禁止条件に対する否定テスト
7. 必要なQAの合格
8. 人間による当該implementationとPolicy Contractの互換性承認
9. 人間による自動除去Enabledの明示承認
10. 承認済みImplementation Contract、必要なimplementation identityおよびEnabled状態の正式Sourceへの反映
11. 実行時のSource state、Policy Contract、承認済みImplementation Contractおよびimplementation identityの確認
12. §19の全条件成立

技術条件を満たしたことだけを理由として、AI、Skill、Helperまたは実行環境が制度状態を変更してはならない。

Ledger、SkillまたはHelper configは制度状態、Contractおよびidentityを参照・反映できるが、正式な承認主体、authoritativeな制度状態または互換性の正にはしない。

正式SourceのSource revisionがEnabled反映によって変化しても、実行Contractが変わっていなければPolicy Contract Versionは変更しない。このSource revision変更だけを理由として、QA済み実装へ同じQAを再要求する循環を作らない。

実行互換性に影響する制度変更ではPolicy Contract Versionを更新する。旧Implementation Contractが新しいPolicy Contractに対して人間により明示的に互換承認されていない場合は実行不可とし、新しい実装または同期、shadow dry-run、否定テスト、QAおよび人間承認を経る。

Helperが独自に新しいPolicy Contractとの互換性を判断して実行してはならない。明示的な人間承認済み対応関係がない場合はfail-closedとする。

正式Source上の制度状態、Policy Contract Version、承認済みImplementation Contract、必要なimplementation identity、human overrideまたはemergency stop、現在のformal policy referenceのいずれかを一意に確認できない場合は、自動除去を行わずDisabled相当として扱う。

人間はいつでも、自動除去を停止する明示指示を行うことができる。停止指示は`HUMAN_IN_THE_LOOP.md`に基づき直ちに優先し、SourceがEnabledであっても、有効なhuman overrideまたはemergency stopが存在する間は自動除去しない。

`automatic_removal_policy_state`は正式な制度状態の正であり、human overrideまたはemergency stopは実行可否へ直ちに作用する運用上の停止証拠である。停止証拠を第二のauthoritativeな制度状態として扱わない。

緊急停止後は、正式Sourceの制度状態をDisabledへ反映する。Source更新までの時間差では、human overrideまたはemergency stopをSource上のEnabledより優先する。

AI、SkillまたはHelperは停止を解除してはならない。再度Enabledへ変更する場合は、本節の有効化条件と人間承認を改めて満たす。

自動除去を実行できるのは、正式Source上の制度状態と実装側auto modeが双方とも有効で、Policy Contract、承認済みImplementation Contract、必要なimplementation identity、human overrideおよび§19の全条件を確認できる場合に限る。

---

## 9. processing_stage

Inbox処理の現在状態は、Inbox Ledger上の `processing_stage` として次を使用する。

これらは専門成果物の `Draft`、`Review`、`Approved`、`Deprecated` その他の承認Statusではなく、Inbox受領物の工程上の所在を示す運用状態である。

### `Received`

次を満たした状態。

- Inbox上の受領物を一意に認識できる
- 受領物がREAD可能
- サイズまたは更新状態が安定している
- 処理不能なプレースホルダーまたは競合状態ではない
- 受領時点の基本メタデータを取得できる

### `Assessed`

次を満たした状態。

- ファイル、フォルダまたはアーカイブの構造を把握した
- 必要なSHAまたは識別情報を取得した
- 重複・競合候補を確認した
- センシティブ性を判定した
- Original保持要否を評価した
- 責任領域と配属候補を整理した
- 必要な加工・索引の有無を評価した
- AIだけで進められる事項と人間判断事項を分離した

### `AwaitingDecision`

`HUMAN_IN_THE_LOOP.md` に基づく人間判断が必要で、配属またはInbox側処理を進められない状態。

少なくとも次を記録する。

- 判断対象
- 現在状態
- 関係する正式Source
- 推奨案と理由
- 他案がある場合の影響
- 判断後の再開地点

この段階は、すべての受領物が必ず通過する段階ではない。

必要な人間判断を待ってこの状態に留まることは正常な停止であり、処理異常を意味しない。

### `Placed`

次を満たした状態。

- 承認済みまたは既存Sourceから一意に決まる配属先へ配置した
- 配置処理がエラーなく終了した
- 配属先とauthoritative copy候補を特定できる

`Placed`は、正式Sourceとしての承認、専門成果物のApproved、SHA検証完了またはInbox処理完了を意味しない。

### `Verified`

次を満たした状態。

- 配属先でREAD可能
- 必要なSHAまたは内容同一性を確認済み
- authoritative copyを一意に確定済み
- 必要なOneDriveその他の同期状態を確認済み
- 必要なProcessedまたはDerivedが作成・検証済み、または下流工程への正式な引き渡しが完了
- provenanceを確認済み
- センシティブ情報の利用範囲と外部提供範囲を確認済み
- Closed前に必要な未解決事項を特定済み

Verifiedは、Inbox側重複コピーの自動除去適格性を単独で証明するものではない。

自動除去には、§19の制度、Capability、対象範囲、identity evidence、同期、human overrideおよび実行安全条件をすべて満たす必要がある。

deletion intentおよびInbox-side action resultは、新しいprocessing_stageを追加するものではない。これらのイベントを追記している間、processing_stageはVerifiedを維持し、Inbox側処理およびClosed条件の確認後にClosedへ移行する。

VerifiedからInbox-side actionの記録を経ずに直接Closedへ移行しない。

複数の過去Verified Eventが履歴として存在すること自体はエラーとしない。既存履歴を上書きまたは削除しない。

自動除去判断の根拠には、最新の有効なVerified Eventを使用する。

当該Verified Event以後に、identity、path、authoritative copy、conflict、hold、human override、同期証拠、provenanceその他の再評価を必要とする変更またはイベントが存在する場合、そのVerified Eventを自動除去の根拠として使用しない。

必要な再検証を行い、新しいVerified証拠を確立してから自動除去適格性を再評価する。

### `Closed`

本SourceのClosed条件をすべて満たし、Inbox側処理とLedger記録まで完了した状態。

Closed後に誤り、競合または追加処理が判明した場合は、既存履歴を消さず、理由と再開状態を新しいLedgerイベントとして記録する。

---

## 10. 人間判断と自動進行

人間判断、自動進行、停止、再承認およびエスカレーションの横断条件は、`HUMAN_IN_THE_LOOP.md` を正とする。

Inbox処理では、既存Sourceから配属先、保持要否、加工範囲および利用範囲を一意に決定できる場合、承認済み範囲内で連続進行できる。

Inbox固有の判断対象には、次のような事項を含む。

- 配属先が複数あり一意に決まらない
- 新しい恒久ディレクトリまたは責任単位が必要
- 未承認資産を正式Sourceとして採用する必要がある
- 既存の正式Sourceを置換または上書きする必要がある
- 原本を保持するか判断できない
- 削除、移動その他の不可逆性が新しく発生する
- センシティブ情報の利用範囲を拡張する必要がある
- 外部AIまたは外部サービスへの未承認提供が必要
- 同名異内容その他の競合がある
- authoritative copyを確定できない

これらの事項における停止、提示、承認および再開条件は、`HUMAN_IN_THE_LOOP.md` を正とする。

§19の条件付き恒久自動除去制度が正式採用され、対応機能が有効化された後、§19の全条件を機械確認できる完全重複コピーの除去は、承認済みの目的、意味および影響範囲内の定型工程として扱う。

この場合、Assetごとの追加削除承認を必須としない。

これは、保持要否、不保持判断、競合解消、配属先決定その他の意味判断をAIへ移管するものではない。

人間が個別の停止、保持または別処理を指定した場合の扱いは、`HUMAN_IN_THE_LOOP.md` を正とする。

---

## 11. 配属・重複・競合

配属判断は、ファイル形式ではなく、責任、正式性、将来利用、保持要否、センシティブ性およびVersion管理要否に基づいて行う。

各受領物には、原則として一つのprimary landing classを定める。

複製が必要な場合も、どのコピーがauthoritativeであり、他のコピーが何のために存在するかを明示する。

同じ配属先に同名ファイルが存在する場合は、内容同一性を確認する。

- 同一SHAの場合：重複として扱い、不要な複製を作らない
- 異なるSHAの場合：競合として扱い、自動上書きしない
- SHAだけでは同一性を判断できないデータ群：適用される識別方法と構造比較を使用する

新しい恒久ディレクトリを、将来使う可能性だけを理由として先行作成しない。

---

## 12. Personal Archiveの位置づけ

OneDrive上の `04_Personal_Archive` は、正式Sourceではない個人一次資料、加工データおよび二次資料を保持するRepository外の領域である。

これは、`REPOSITORY_RULES.md` が定義する「現行ではない旧版ファイルを保持するRepository Archive」とは別の責任である。

Personal Archiveを、Repository上の正式Source、正式なVersion管理、承認記録またはCHANGELOGの代替として使用しない。

Personal Archiveへ存在することだけで、当該資産が正式Source、承認済み判断または外部利用可能になったとはみなさない。

### 12.1 Original

`Original` は、外部から取得した未改変原本を保持する。

原則は次のとおりとする。

- ファイル本文またはアーカイブ内部を改変しない
- SHAその他の方法で識別可能にする
- 取得日時その他の利用可能な取得情報を保持する
- ProcessedおよびDerivedから追跡可能にする
- 通常検索対象にしない
- センシティブ情報を含む可能性を前提とする
- 正式Sourceと混同しない
- 同一原本を目的なく重複保持しない

ファイルシステム上の配置日時または同期メタデータが変わる場合も、原本本文の同一性をSHA等で確認する。

### 12.2 Processed

`Processed` は、Originalから利用目的上必要な範囲を抽出、正規化または構造化した再利用可能データを保持する。

少なくとも次を保持する。

- 原本識別情報
- 原本SHAまたは同等の識別情報
- 加工日時
- 抽出対象
- 除外対象
- 変換方法
- 元データへ戻るためのIDまたは参照
- センシティブ情報の除外または取扱条件
- 必要に応じて処理Versionまたは処理状態

Processedは、解釈、因果関係、正式判断、公開判断または正式Source採用を確定する場所ではない。

再生成可能な処理パッケージは、その主たる責任が正規化データと差分更新状態の保持にある場合、内部に機械生成の候補キュー、索引または処理状態を含むことができる。

ただし、恒久的に参照する解釈・分析成果物は、Processed内の自動候補のまま正式確定せず、必要に応じてDerivedへ分離する。

### 12.3 Derived

`Derived` は、OriginalまたはProcessedを根拠として作成した二次資料を保持する。

対象例は次のとおりとする。

- INDEX
- 日付索引
- テーマ分類
- 検索用索引
- 分析
- Work History
- note候補
- Voice候補
- レビュー用候補
- その他の解釈・整理成果物

Derivedは、元データへ戻れるprovenanceを保持する。

Derivedへ存在することだけで、当該内容が事実として確定、公開承認済み、専門Sourceへ採用済みまたは正式Sourceになったとはみなさない。

Derivedを正式Sourceへ採用する場合は、責任を持つ正式Sourceが要求する承認、監査、配置、CHANGELOGおよびGit工程を別途通す。

---

## 13. センシティブ情報

Inbox投入物には、次が含まれる可能性を前提とする。

- DM
- 第三者情報
- 連絡先
- 電話番号
- メールアドレス
- IP履歴
- 端末情報
- 認証情報
- APIキー
- Cookieまたはトークン
- 非公開投稿
- 公開範囲が不明な情報
- 削除済み情報
- 個人的な会話
- 外部共有が許可されていない資料

AIは、内容把握と配属判断に必要な最小範囲で構造とデータ種別を確認する。

センシティブ情報または公開範囲が不明な情報を、通常検索用Processed、通常検索用Derived、外部AI監査パッケージまたは外部公開用成果物へ自動混入させない。

外部アーカイブ等から秘密情報またはセンシティブ情報を検出した場合は、少なくとも次を行う。

- 通常検索対象から除外する
- ProcessedおよびDerivedへの自動混入を防止する
- Ledgerへ秘密情報本文を記録しない
- 外部AIまたは外部サービスへ提供しない
- 必要な隔離、除外、保持または削除判断へ接続する

Originalまたはセンシティブ情報を通常検索対象から除外できることを現在の実装で保証できない場合は、自動的に検索対象へ含めない。

その場合は、除外を保証できないことを現在状態として記録し、必要に応じて人間判断または実装修正へ接続する。

通常検索へ使用する場合は、対象範囲、除外範囲および利用目的を明示する。

外部AIまたは外部サービスへ提供する場合は、`AI_WORK_ENVIRONMENT.md` と `HUMAN_IN_THE_LOOP.md` を正とし、目的に必要な最小範囲へ限定する。

認証情報、APIキー、Cookie、トークンその他の秘密情報は、Personal Archiveの通常データセットまたはLedgerへ保存しない。

---

## 14. provenance

OriginalからProcessedまたはDerivedを生成するときは、利用目的と再追跡に必要な範囲で次を保持する。

- 原本識別情報
- 原本ファイル名またはデータセットID
- 原本SHAまたは同等の識別情報
- 取得日時
- 加工日時
- 抽出対象
- 除外対象
- 変換方法
- 使用した処理Versionまたは手順
- 元データID
- 元アーカイブ内のエントリ参照
- Processed識別情報
- Derived生成元
- 必要な人間判断または承認への参照

DerivedからProcessed、ProcessedからOriginalへ戻れる参照を維持する。

同じ原本から複数のProcessedまたはDerivedを生成した場合は、それぞれの利用目的、変換条件およびauthoritativeな位置づけを区別する。

加工物だけを見ても原本を識別できず、変換条件も確認できない状態を完了としない。

Repository外に保持する増分型一次資料について、Local / Cloud双方から最終取得地点、前回処理地点、正式Sourceへの反映状態および原本への再追跡経路を確認する必要がある場合は、`04_AI_Work_Environment/ARCHIVE_PROVENANCE_INDEX.md` へ必要最小限の運用メタデータを記録する。同Indexへ原本本文、個人情報または秘密情報を複製せず、Personal Archive内のprovenance、Inbox Ledger、Timelineまたは専門Sourceの代替にしない。

---

## 15. Inbox Ledger

Inbox Ledgerは、Inbox処理ライフサイクルを記録する運用メタデータである。

本運用におけるauthoritativeなInbox Ledger位置は、`AI/00_Inbox/.codex-inbox/ledger.jsonl` とする。

バックアップまたは検証用コピーを作成する場合も、複数のLedgerを同時にauthoritativeとして扱わない。

Ledger自体は正式Source、専門成果物、正式承認記録またはRepository CHANGELOGではない。

Ledgerでは、少なくとも必要な範囲で次を追跡できるようにする。

- 受領物識別子
- イベント日時
- `processing_stage`
- 原ファイル名または受領物識別情報
- サイズ
- SHAまたは同等の識別情報
- 受領物種別
- センシティブ判定
- 配属候補
- 最終配属先
- authoritative copy
- 配属先検証結果
- 重複または競合結果
- 人間判断要否
- 人間判断への参照
- provenance確認結果
- Inbox側処理結果
- Closed日時
- エラーまたは例外
- 実行mode
- formal policy reference
- Policy Contract Version
- Implementation Contract
- implementation identityまたは承認済みactivation record参照
- Policy ContractとImplementation Contractの人間承認済み対応関係の参照
- 根拠としたVerified Event
- identity evidence
- 同期証拠参照
- deletion holdまたは個別停止状態
- Inbox-side action intent
- Inbox-side action result
- action後の検証結果
- 根拠とした最新の有効なVerified Event
- human override状態の同期結果および証拠参照
- active holdまたは個別停止状態
- 正式Source上の自動除去制度状態の参照結果
- Policy Contract、承認済みImplementation Contractおよびimplementation identityの照合結果
- 実装側auto modeの確認結果
- human overrideまたはemergency stopの同期結果

Ledgerはイベントを追記する方式を原則とし、段階更新によって過去の判断、失敗、競合、配属、再開またはClosed履歴を上書き・削除しない。

Closed後も、配属、判断、競合、例外および再開に必要な履歴を保持する。

Ledgerへ受領物本文、DM本文、秘密情報または不要な個人情報を記録しない。

`.codex-inbox` はInbox制御情報の領域として、通常の受領物走査、配属候補および再帰処理の対象から除外する。

Ledgerの消失を正式Sourceの消失と同一視しない。ただし、処理履歴またはprovenanceの追跡性を確認できなくなった場合は、残存する資産、SHA、配属先記録その他から復旧可能性を確認し、確認不能な状態を完了済みとして扱わない。

具体的な保持年限、バックアップ、ローテーション、保存媒体、ファイル分割および実装方式は、本Sourceでは固定しない。

自動Inbox-side actionでは、実行前のintent、実行結果およびClosedを区別して追記する。

formal policy referenceは、適用した正式SourceのRepository相対path、対象節または制度識別子および不変なrevision識別子を示す参照であり、Ledger自体を正式承認記録、承認主体または制度状態の正にするものではない。

Ledgerへ記録するhuman override状態は、人間指示の意味または承認そのものではなく、自動処理が参照するために現在のAssetへ同期された運用証拠である。

Ledgerのschema Version、排他制御、flush、文字コード、field構造その他の実装方式は、対応するHelperが管理する。

schema非互換、Ledger書込不能または既存履歴との接続不能な状態では、自動除去を行わない。

---

## 16. LedgerとCHANGELOGの責任分離

Inbox Ledgerは、個々の受領、評価、配属、検証およびClosedを記録する。

Repository CHANGELOGは、正式Source、責任構造、Repository構造、判断基準その他の意味のある変更を記録する。

個々のInbox処理を、機械的にRepository CHANGELOGへ記録しない。

次の場合は、`REPOSITORY_RULES.md` に従ってCHANGELOG要否を判断する。

- 新しい正式Sourceを採用した
- 既存の正式Sourceを変更した
- Repository構造または正式配置を変更した
- AIまたは人間の判断・運用を変える恒久ルールを導入した
- 新しい責任単位または参照関係を正式採用した

InboxからRepositoryへ正式Source候補を配属する場合も、Ledger記録だけでCHANGELOG、承認、監査またはGit工程を代替しない。

本Sourceの正式採用時に必要なRepository構造およびCHANGELOG更新は、`REPOSITORY_RULES.md` に従って後続のRepository反映工程で行う。

---

## 17. フォルダ・大容量アーカイブ

### フォルダ投入

フォルダを一つの受領単位として扱う場合は、次を確認する。

- 相対パス
- ファイル数
- 合計サイズ
- 必要なファイル識別情報
- 重複または競合
- フォルダ内のセンシティブ情報
- 配属単位
- フォルダ全体と個別ファイルの責任関係

再帰走査では、reparse point、シンボリックリンク、循環参照、制御用ディレクトリおよび意図しない外部パスを無条件にたどらない。

フォルダの一部だけを配属する場合は、抽出対象と除外対象をprovenanceへ記録する。

### 大容量アーカイブ

大容量ZIPその他のアーカイブでは、次を確認する。

- 原本サイズ
- 展開時推定サイズ
- エントリ数
- manifestまたは中央ディレクトリ
- 部分アーカイブか完全アーカイブか
- 破損または暗号化の有無
- 配属先と一時処理領域の空き容量
- コピー中に必要な一時容量
- OneDriveのローカル利用可能状態
- 同期状態
- 安定性

内容把握だけを目的として、大容量アーカイブを無条件に全文展開・複製しない。

原則として構造を先に把握し、必要なファイルまたはデータだけを選択的にREADまたは抽出する。

具体的なHelper、解析ライブラリ、ハッシュ計算方法、安定性確認時間または同期確認方法は、本Sourceで固定しない。

---

## 18. 配属と配属先検証

外部取得原本を保持する場合は、原則として次の安全順序を使用する。

1. 配属先とauthoritative copy候補を確定する
2. 既存ファイルとの競合を確認する
3. 必要な空き容量を確認する
4. 一時名または安全なコピー方式で配属先へコピーする
5. Inbox原本と配属先コピーのSHAまたは内容同一性を確認する
6. 配属先の最終名称を確定する
7. 配属先でREAD可能であることを確認する
8. 必要なOneDriveその他の同期状態を確認する
9. authoritative copyを確定する
10. 必要な加工・索引およびprovenanceを確認する

配属先へファイルが存在することだけで、VerifiedまたはClosedとしない。

OneDriveをPC交換後も保持される恒久保存先として使用する場合は、ローカル配置とクラウド同期確認を区別する。

同期確認方法を実装できない場合は、同期未確認であることを記録し、必要な保持要件を満たすまでClosedとしない。

Verified時に取得したSHAまたは内容同一性証拠は、現在のAsset、Inbox上のsourceおよびauthoritative copyがVerified時と同一であることをidentity evidenceから確認できる場合に限り、後続のInbox-side actionで再利用できる。

identity evidenceの有効性を確認できない場合は、必要なSHAまたは内容同一性を再確認する。

ファイルが大容量であることだけを理由として、必要なSHAまたは内容同一性確認を省略しない。

Verified時のSHA、内容同一性または同期証拠は、Verified時から現在まで、証拠再利用に必要なAsset、両path、内容識別、identity evidenceおよび根拠となるVerified Eventとの対応関係が不変であることを積極的に確認できる場合に限り再利用できる。

単に新しい変更または競合を観測していないことを、不変性確認として扱わない。

積極的な不変性確認ができない場合は、証拠をunknownとして扱うか、必要な内容同一性または同期状態の再検証へ戻す。

unknownのまま自動除去しない。

---

## 19. Inbox側原本の処理

### 19.1 基本責任

Inbox側処理は、保持、配属、同一性、同期、provenanceその他の必要な判断および検証が完了した後、Inboxに残った重複コピーを処理する工程である。

本Sourceは、

> Verified済みで、安全なauthoritative copyがInbox外へ一意に確立された完全重複コピーについて、必要な条件をすべて機械的に確認できる場合に限り、Assetごとの追加削除承認なしでInbox側重複コピーを自動除去できる

ものとする。

自動化対象は、削除するべきかという意味判断ではなく、すでに保持対象とauthoritative copyが確定した後の機械的な重複除去に限定する。

### 19.2 初期適用範囲

初期Versionの自動除去対象は、Inbox直下に存在する単一の通常ファイルに限定する。

次は自動除去対象外とする。

- フォルダ
- 再帰削除
- `.codex-inbox`
- Temp
- partial
- 制御領域
- Inbox外の資産
- Original
- Processed
- Derived
- Repository上の資産
- 旧Versionその他の保持要否判断が必要な資産
- 不保持判断そのものが未確定の資産

フォルダまたは再帰削除の自動化は、別途必要なE2E、監査および正式判断を完了するまで導入しない。

### 19.3 自動除去の必須条件

次の条件をすべて満たす場合に限り、自動除去できる。

#### 制度およびCapability

- 正式Source上の`automatic_removal_policy_state`がEnabled
- 実装側のauto modeが明示的に有効
- 正式Source上のPolicy Contract Versionを一意に確認できる
- 人間承認済みImplementation Contractが`none`ではない
- 実装が宣言するImplementation Contractと、正式Source側で人間承認済みのImplementation Contractとの対応が一致する
- implementation identityが必要な場合、承認済みidentityが`none`ではなく、正式Sourceまたは人間承認済みactivation recordから参照されるidentityと一致する
- Helper自身の自己申告だけを互換性または実行資格の根拠としていない
- 対応するSkillおよびHelperが本Sourceへ同期済み
- 正式runtime要件を満たしている
- Ledger schemaが互換
- 適用したformal policy referenceを記録できる
- formal policy referenceがRepository相対path、対象節または制度識別子および不変なSource revision識別子を含む
- formal policy referenceが現在実行へ適用するSource revisionと対象制度を一意に識別する
- 本節の条件をHelperが機械的に検証できる

#### Asset

- latest processing_stageがVerified
- Asset IDが一意
- Inbox上のsource絶対パスが一意
- 現在の自動除去判断の根拠となる最新の有効なVerified Eventが一意
- Asset ID、source pathおよび当該Verified Eventの対応が一意
- 当該Verified Event以後に、その有効性を失わせる変更またはイベントが存在しない
- 複数の古いVerified Eventが履歴として存在すること自体を競合またはエラーとして扱わない
- Inbox直下の単一通常ファイル
- path正規化後も承認済みInbox内部
- `.codex-inbox`、Temp、partialまたは制御領域ではない

#### authoritative copy

- Inbox外に一意に存在する
- 最終配属先が確定している
- READ可能
- 安定している
- partialまたはtemporary copyではない
- conflictがない
- Inboxだけが唯一の安全なコピーではない
- Inbox上のsourceとauthoritative copyが、path解決後も相互に独立したファイル実体である
- symlink、junction、reparse point、hardlink、path replacementその他、両pathが同一実体または依存した実体を指す構成を安全に否定できる
- 利用可能なFile ID、Volume IDその他のfile identity情報を使用できるが、具体的なOS APIまたは検出方式を本Sourceでは固定しない

#### 内容同一性

- Verified EventにSHA-256その他の適用された内容同一性証拠がある
- Inbox上のsourceとauthoritative copyの内容同一性を確認済み
- 証拠がAsset ID、両pathおよびVerified Eventへ一意に接続している
- Verified時から現在まで、証拠再利用に必要な対応関係およびidentity evidenceが不変であることを積極的に確認できる
- 単に変更を観測していないことを、不変性確認として扱っていない
- 証拠を再利用できない場合は、必要な内容同一性を再確認済み

#### 同期および保持

- 必要なOneDriveその他の同期確認が完了している
- sync stateがunknownではない
- 同期証拠がAsset、authoritative pathおよび内容識別へ接続している
- authoritative copyが必要な恒久保持条件を満たす

#### provenanceおよび下流工程

- provenanceがcomplete
- Originalまたは最終配属先へ追跡可能
- 必要な下流工程がcomplete、not_requiredまたは正式にhanded_off
- 未解決の人間判断がない

#### Human override

- 現在のAssetに影響するhuman override状態が、機械判定可能な運用状態へ同期済み
- override状態の同期結果および証拠参照を積極的に確認できる
- emergency stop状態が同期済みで、activeではないことを積極的に確認できる
- activeなdeletion holdがない
- 削除しない、Inboxへ残す、Verifiedで停止する、別処理へ回すその他の個別停止指示がない
- hold記録が見つからないことだけを、holdまたは個別指示が存在しないことの証明として扱っていない

#### 実行安全

- dry-runが合格している
- Ledgerへ安全に追記可能
- 削除直前に全条件を再確認している
- 削除対象が厳密な単一絶対パスへ限定されている
- 削除直前にpathとfile identityを再確認し、path replacementその他のTOCTOUによる対象変化を否定できる
- 他のInbox資産を処理対象としていない
- action後の対象不存在とauthoritative copyの健全性を確認できる

### 19.4 自動除去禁止条件

§19.3の条件を一つでも満たさない場合、または条件を判定できない場合は、fail-closedとし、自動除去しない。

少なくとも次の場合は自動除去を禁止する。

- processing_stageがVerified未満
- Ledgerと実際のファイル状態が一致しない
- formal policyが未採用または無効
- 正式Source上の`automatic_removal_policy_state`がDisabledまたは判定不能
- Policy Contract Versionが不明、未対応または互換性を確認できない
- 人間承認済みImplementation Contractが`none`
- 人間承認済みImplementation Contractとの対応を確認できない
- implementation identityが必要なのに承認済みidentityが`none`、確認不能または実装identityと不一致
- Helper自身の自己申告以外に互換承認の根拠がない
- current formal policy referenceを一意に確認または記録できない
- 実装側auto modeが無効または判定不能
- 正式runtime要件を満たさない
- HelperまたはLedger schemaが未対応
- Asset ID、source pathまたは最新の有効なVerified Eventの対応が曖昧
- 根拠とするVerified Event以後に無効化事由があり、新しいVerified証拠を確立していない
- authoritative copyが不明、複数、READ不能または不安定
- sourceとauthoritative copyの独立したファイル実体を確認できない
- link、hardlink、reparse、path replacementその他の参照・同一実体構成を安全に否定できない
- SHAその他の内容同一性証拠がない
- 内容同一性が一致しない
- Verified後の変更を否定できず、再確認も完了していない
- sync stateがunknown
- conflictがある
- partialまたはtemporary copyがある
- 人間判断待ちがある
- human override状態が現在のAssetへ同期済みであることを積極確認できない
- emergency stop状態を積極確認できない、またはactiveである
- deletion holdまたは個別停止指示がある
- Ledgerへ安全に記録できない
- 削除対象がInbox外
- 削除対象が`.codex-inbox`または制御領域
- 削除対象がフォルダまたは再帰処理を必要とする
- Helperが安全条件を機械検証できない
- action後の検証ができない

停止理由が人間判断を必要とする場合は、`AwaitingDecision`へ接続する。

一時的なCapability不足、同期未確認または検証不足の場合は、未確認事項を完了済みとせず、Verifiedその他の実際の状態を維持して再開地点を記録する。

### 19.5 証拠再利用

Verified時に取得したSHAおよび同期証拠は、§18に従い、Verified時から現在まで必要な対応関係およびidentity evidenceが不変であることを積極的に確認できる場合に限り再利用できる。

証拠再利用の根拠は、大容量であること、再計算に時間がかかること、人間負担を減らしたいことまたは単に変更を観測していないことではなく、Verified時と現在の対象および証拠関係が不変であることを積極的に確認できることとする。

証拠再利用条件を満たさない場合は、必要な内容同一性または同期状態を再確認する。

再確認により不一致、競合または新しい人間判断が判明した場合は、自動除去しない。

### 19.6 実行と履歴

自動Inbox-side actionは、次の順序で実行する。

1. 現在状態と最新Ledgerイベントを再取得する
2. §19.3の全条件をdry-runで確認する
3. formal policy reference、Policy Contract、承認済みImplementation Contract、必要なimplementation identity、execution mode、根拠となるVerified Eventおよびevidence referenceを確定する
4. Ledgerへdeletion intentを追記する
5. 削除直前に対象、path、独立したfile identity、identity evidenceの不変性、同期、conflict、同期済みhuman override状態およびemergency stop状態を再確認する
6. 厳密な単一絶対パスのInbox重複コピーだけを処理する
7. Inbox側対象が存在しないことを確認する
8. authoritative copyが存在し、READ可能で、必要な識別情報が維持されていることを確認する
9. LedgerへInbox-side action resultを追記する
10. §20のClosed条件を再評価する
11. 条件を満たす場合に限り、LedgerへClosedを追記する

deletion intentおよびInbox-side action resultを省略し、Verifiedから直接Closedへ移行しない。

deletion intent後、action前に条件が変化した場合は処理を中止し、削除せず、中止または失敗結果を追記する。

action後に結果記録またはClosed記録へ失敗した場合は、削除を未実施と推測して繰り返さず、§21に従って実ファイル状態とLedgerを照合して再開する。

### 19.7 Human override

恒久自動除去制度が有効な場合も、人間は個別作業について、削除しない、Inboxへ残す、別処理へ回す、Verifiedで停止するその他の指示を行うことができる。

個別指示の優先関係、有効範囲、解除および作業終了後の通常運転への復帰は、`HUMAN_IN_THE_LOOP.md` を正とする。

人間による自動除去の停止指示またはemergency stopは、正式Source上のEnabledより優先する。AI、SkillまたはHelperは、その停止を解除してはならない。

自動処理が参照するhuman override状態は、人間指示そのものではなく、現在のAssetへ同期された運用証拠として扱う。Chatその他の人間指示を運用証拠へ接続する方法は、Skill、Helperまたはorchestrationの実装責任とする。

override状態の同期確認のために、§19.3の全条件を満たすAssetごとの追加人間承認を要求しない。

本節を、包括的な削除権限、保持判断権限、不保持判断権限または競合解消権限として解釈しない。

### 19.8 有効化と将来留保

本節が正式採用されたことだけで、自動除去機能が実装済みまたは有効化済みになったとは扱わない。

正式Source上の制度状態と変更条件は§8.2を正とする。制度状態がDisabledである間は、Skill、Helperまたは実装側設定にかかわらず自動除去しない。

有効化前条件は§8.1および§8.2を満たす必要がある。

現時点では、次を将来留保とする。

- フォルダ自動除去
- 再帰削除
- OneDrive同期確認の完全自動化
- Original、ProcessedまたはDerivedの自動削除
- Repository資産の自動削除
- conflictの自動解消
- 不保持判断の自動化

---

## 20. Closed条件

Inbox処理は、少なくとも次を満たしたときClosedとする。

- 最終配属または正式な不保持判断が確定している
- 保持対象について、Inbox外の責任ある保存先にauthoritative copyが一意に確立されている
- 保持対象について、Inboxだけが唯一の安全なコピーとなっていない
- 配属先でREAD可能
- 必要なSHAまたは内容同一性を確認済み
- 必要なprovenanceを確認済み
- 必要なOneDriveその他の同期状態を確認済み
- 必要なProcessedまたはDerivedが完成・検証済み、または責任を持つ下流工程へ正式に引き渡し済み
- センシティブ情報の利用範囲が確定している
- 外部提供範囲が必要な場合は確定している
- 人間判断待ちがない
- Inboxに未処理の重複コピーを残していない
- Inbox側処理条件を満たしている
- LedgerへClosedを記録済み
- エラー、競合または未解決事項を完了と誤認していない

正式Sourceとしての採用判断が必要な受領物は、採用または不採用が確定する前にClosedとしない。

保持不要と正式に判断された受領物は、必要な削除判断、処理および記録が完了した場合に限りClosedにできる。

人間判断待ちにより `Verified` または `AwaitingDecision` に留まることは正常であり、Closed不能を処理異常として扱わない。

ファイルのコピー、Processed生成またはLedger更新の一つだけをもってClosedとしない。

自動Inbox-side actionが成功した場合も、それだけでClosedとしない。

deletion intent、Inbox-side action resultおよびaction後検証を追跡でき、かつ本節の全条件を満たした場合に限りClosedを記録する。

---

## 21. エラー・中断・再開

停止条件、自動復旧、再承認および再開可否の横断原則は、`HUMAN_IN_THE_LOOP.md` を正とする。

Inbox処理では、再開時に少なくとも次の状態を識別できるようにする。

- Inbox原本
- 配属先の一時コピー
- 配属先の最終コピー
- 検証済みコピー
- 未検証コピー
- Processed
- Derived
- Ledger上の最後に記録された状態
- 実際に確認できた現在状態

一時コピー、部分コピー、SHA不一致またはREAD不能なコピーをauthoritative copyとして扱わない。

Ledger上の状態と実際のファイル状態が異なる場合は、差異を記録し、現在状態を確認せず履歴だけから再開しない。

どの段階から再開するか、不可逆操作を実行できるか、または人間判断が必要かは、`HUMAN_IN_THE_LOOP.md` と適用されるSourceに従う。

deletion intentが存在し、Inbox-side action resultまたはClosedが存在しない場合は、actionを未実施と推測して再実行しない。

Inbox上のsource、authoritative copy、最新Ledgerイベントおよび実際の処理結果を確認し、未実施、中断、実施済み未記録その他の現在状態を一意に確定してから再開する。

---

## 22. 既存資産と移行時の扱い

本Sourceは、採用後に新しく受領・生成する資産へ適用する標準モデルである。

本Source策定前に作成されたPersonal Archive資産について、新しい配置原則だけを理由として遡及的な移動、分割、再分類または削除を行わない。

特に、既存の `04_Personal_Archive/Voice/` は、ProcessedおよびDerivedが混在し得る既存例外として今回変更しない。

Voice既存資産は、必要な場合に別タスクで実物を監査し、少なくとも次を確認する。

- Repository上の `02_Voice_OS/` 正式Sourceの不適切な複製ではないか
- Originalまたは一次資料に該当するか
- Processedに該当するか
- Derivedに該当するか
- 正式Voice OS作成または検証の根拠資料に該当するか
- 不要な二重管理になっていないか

実物を監査する前に、Voice既存資産の責任配置を確定しない。

既存Processedパッケージ内に、再生成可能な自動候補、索引または処理状態が含まれることだけを理由として、直ちにルートDerivedへ移動しない。パッケージの主たる責任と現在の参照関係を確認する。

`Processed/X` および `Derived/X` は、公開投稿ProcessedデータまたはDerived索引を実際に生成する段階で必要性を確認する。

将来利用の可能性だけを理由として、空ディレクトリを先行作成しない。

既存例外の存在を、新規受領物の責任境界を曖昧にする根拠として使用しない。

---

## 23. 関連Source

本Sourceを使用するときは、作業内容に応じて次を参照する。

- `04_AI_Work_Environment/AI_WORK_ENVIRONMENT.md`
- `04_AI_Work_Environment/ARCHIVE_PROVENANCE_INDEX.md`
- `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- `REPOSITORY_RULES.md`
- `AI_ORGANIZATION.md`
- 配属候補を管理する各専門Source
- Personal Archive内の適用されるREADME、処理説明、provenanceまたはINDEX

本Sourceだけを参照して、正式Sourceの内容、専門成果物の承認、外部公開、AI組織上の担当またはRepositoryのGit運用を決定しない。

本Sourceの正式採用時には、承認済み方針に従い、`REPOSITORY_RULES.md` の正式構造、`04_AI_Work_Environment/CHANGELOG.md` およびルート `CHANGELOG.md` へ必要な変更を反映する。
