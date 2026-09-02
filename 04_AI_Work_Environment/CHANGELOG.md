# AI作業環境 CHANGELOG

このファイルは、`04_AI_Work_Environment/` が担う、Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境と工程接続に関する意味のある変更履歴を記録する。

現在有効な判断基準は `AI_WORK_ENVIRONMENT.md` を参照し、本ファイルを現行ルールの正本として使用しない。

------------------------------------------------------------------------

## 2026-09-03｜Visual Runtime Bridgeを実装

### Incident / Root Cause

Visual Production Record validatorはRepository内のContract、RequestおよびAsset状態を検証できたが、標準Chat／Workのbuilt-in image generation requestを直接interceptするruntime接続は存在しなかった。Source実読とTool Request拘束を分離しておらず、Repository Controlを迂回した生成を事前BLOCKまたは明示検出できなかった。

### 変更内容

- `Visual_Production/`をv1.1へ更新し、AIDAILY等のcanonical profileからGeneration Recordを機械生成するbuilderを追加した。
- Runtime Capability／Request Binding ReceiptのSchema、builderおよびfail-closed validatorを追加した。
- Local CodexではSource Resolution、script実行、image generation、asset inspectionおよびclient-visible request bindingの実測Evidenceを要求する。actual requestがvalidated requestと1 byte相当のcanonical JSON hashで一致しなければFAILする。
- Chat／Work built-in direct routeと未実装Responses API orchestratorを明示BLOCKし、Repository境界を`platform_enforced`と偽装するReceiptをFAILにした。
- Repository Skill `visual-production-bridge`で、生成前binding、`GENERATED_UNVERIFIED`、実物inspection、Asset QAおよびHuman Review Candidate遷移を一つのLocal Codex workflowへ接続した。

### QA

Visual Production 14件と新規Runtime Bridge 11件、合計25件の回帰テストを実行対象とした。既存Controlへ「要件IDだけ存在してprompt本文が欠落する」negative testを追加し、新規Bridge testはContractなし、Source未解決、Contract／Prompt QA未PASS、actual request不一致、QA前昇格、偽装Platform PASS、AIDAILY禁止事項、approved exact titleおよび環境Capability記録を含む。

上記25件、Source Resolution 8件、Repository Source QA、Schema JSON parse、PowerShell syntax、Skill structureおよび`git diff --check`をPASSした。標準Chat built-in image generationのplatform interceptionは未実装として明示的に残し、PASSへ偽装していない。

------------------------------------------------------------------------

## 2026-09-03｜Visual Production Controlを実装

### 概要

画像生成Toolが不適切なPhaseで起動すること、正式Sourceの制約が実Tool Requestで欠落すること、およびQA未確認AssetがHumanへ承認候補として提示されることをfail-closedにする共通実装を追加した。

### 変更内容

- `Visual_Production/`へGeneration Record Schema、validatorおよび13件の回帰テストを追加した。
- Phase Tool Routing、MUST／MUST NOT／MAY、approved exact text、Source fingerprint、Prompt Assembly QA、Asset QA、retry／STOPおよびHuman Asset QA専用状態を検証する。
- note Header、SNS画像、教育Visual等の媒体固有要件は各専門Sourceへ残し、本実装は解決済み要件と実Tool Request／QA状態の一致だけを担う。
- AIが画像を検査できない場合、`HUMAN_ASSET_QA`以外の通常Human Review／Asset Ready／G5遷移を許可しない。

### QA

必須10ケースを含むPester test 13件、Schema JSON parseおよびPowerShell syntax checkをPASSした。画像生成Toolそのものは本改修Taskで起動していない。

------------------------------------------------------------------------

## 2026-09-02｜Source Resolution QAを実装

### 概要

Production AIが既知の固定pathだけを読んでCurrent Source解決済みと誤認する経路を塞ぐため、既存Source Router／Source QAを機械検証する`Source_Resolution/`を追加した。

### 変更内容

- Source Manifest v2 Schemaへ、責任root探索、Current候補の選択・除外、canonical Source、Version／revision、Repository full commit SHA、file SHA-256、同一Task実読、依存閉包、適用範囲およびProduction versionを定義した。
- Repository／Manifest QAで、Current Canonical Delta、version付き並列Current、候補未列挙、前Taskの読了証跡、依存漏れおよびstale fingerprintをFAILにした。
- G2前とPre-Human Reviewで同じManifestを再検証し、Source変更時はG2を失効させる運用へ接続した。
- 実装は既存Pipelineの検証手段であり、新しいAI組織上の役割、承認者または専門Source責任を追加していない。

------------------------------------------------------------------------

## 2026-09-02｜Local Personal Archive Reader v1をCloudへ接続

### 概要

GPT Archive原本をRepositoryへ複製せず、Private Cloud Workflowから既存Windows self-hosted Runnerを経由してOneDrive Personal Archiveを限定READする経路を実装し、S1-2 E2Eを完了した。

### 変更内容

- `EXTERNAL_REFERENCE_REGISTRY.md`をv1.5、`ARCHIVE_PROVENANCE_INDEX.md`をv1.4へ更新した。
- Processed優先、exact conversation、JST期間、検索語、件数上限、必要時だけのOriginal SHA照合およびfail-closedを運用へ接続した。
- Private implementation commit `9fa254bf483a6294effe95b2dd325a2f829161b3`、Workflow run `33619111677`でCloud→self-hosted Runner→OneDrive E2E `PASS`を確認した。
- Runner専用Windows service SIDへ対象ArchiveのREAD／executeだけを付与し、`NETWORK SERVICE`全体、Repository WRITE、Actions artifact保存および会話全体返却を許可していない。
- 取得成功をSource採用、Human approvalまたはProduction Completionへ読み替えない。

------------------------------------------------------------------------

## 2026-08-29｜Source RetrievalとProduction Completionを分離

### 概要

AIORG-S01のスマホWork Cloud Source Retrieval E2E `PASS`を正式記録し、Sourceへ到達できる状態と成果物を最終完成できる状態を別判定にした。

### 変更内容

- `EXTERNAL_REFERENCE_REGISTRY.md`をv1.4、`ARCHIVE_PROVENANCE_INDEX.md`をv1.3へ更新した。
- 最新Human Decisionと実機結果の原本をRegistry ID `EXT-CODEX-AIORG-PRACTICE-E2E`で追跡可能にした。
- Private Repository最終HEAD `4c2ea252fa7a78d99ab22c27fe9b8ac0e7975ffa`と、S1-2〜S1-6 Practiceの`Redesign Required`を同期した。
- `AI_WORK_ENVIRONMENT.md`へSource Retrieval ReadinessとProduction Completion Readinessの責任境界を追加した。
- PublicへPrivate本文、credential、生ログまたは機微情報を追加していない。

------------------------------------------------------------------------

## 2026-08-29｜Private SourceとWork Cloudの接続責任を追加

### 概要

全社共通Private Source Repositoryを非公開制作本文の正式Sourceとして接続し、Public locator、OneDrive provenance、Local write、Cloud readおよび実機Readiness Gateを分離した。

### 変更内容

- `EXTERNAL_REFERENCE_REGISTRY.md`をv1.3、`ARCHIVE_PROVENANCE_INDEX.md`をv1.2へ更新した。
- AIORG-S01のPrivate repository、artifact ID、canonical path、source commit、file SHA、Version／Statusおよびprovenanceを登録した。
- GPT Archive Retrieval Connectorを別Local開発Backlogとして登録し、OriginalはOneDrive保持・Private Repository非格納を維持した。
- Private visibility、remote pushおよび現在のGitHub接続からのreadを確認した。スマホWork Cloud実機探索が完了するまでCloud Readinessを`NOT READY`とした。

------------------------------------------------------------------------

## 2026-08-28｜AIORG-S01完成本文のprovenanceとCloud経路候補を登録

### 概要

S1-1〜S1-6のStory、Practice、Session Archive計18本文について、Public Repositoryへ本文を複製せず、Human approval、Final Candidate SHA、Archive baseline、Cloud可読性および安全な経路候補を正式追跡へ追加した。

### 変更内容

- `EXTERNAL_REFERENCE_REGISTRY.md`をv1.2、`ARCHIVE_PROVENANCE_INDEX.md`をv1.1へ更新した。
- Final CandidateとExternal Audit ReconciliationのSHA、18本文の所在、Local／Cloud到達性およびprivate Source昇格後に必要な識別情報を接続した。
- Archiveのdownstream抽出をSource of Truthにせず、Final Candidate内の6 ArchiveをHuman-approved baselineかつ`Revision Required`として固定した。
- 現Public Repositoryへ未公開本文を追加せず、別private repositoryを推奨案、実装をHuman Decision Gateとした。

------------------------------------------------------------------------

## 2026-08-28｜AIORG-S01選定一次資料のCloud接続

### 概要

Personal Archive全体をRepositoryへ複製せず、AIORG-S01制作に必要な選定一次資料だけをSection固有Primary Evidence Packageへ接続した。

### 変更内容

- `ARCHIVE_PROVENANCE_INDEX.md`へ`PA-PROCESSED-20260822`からの選定範囲、Repository反映先および原本保持境界を追加した。
- `EXTERNAL_REFERENCE_REGISTRY.md`で「AI組織づくりの地図を制作」をCodex Taskとして訂正し、thread / turn / message IDを確定した。
- 会話全体、添付画像本体、未公開Human-approved本文はRepository外を維持した。

### 現在状態

**Primary Evidence PackageはSource QA PASS。Human-approved本文と一部未取得原ログがRepository外のため、Cloud completionは全6 SessionともNOT READY。**

------------------------------------------------------------------------

## 2026-08-28｜Repository外参照資料レジストリの正式採用

### 概要

GPT Archive、Codex Work／TaskおよびPersonal Archive Derived等、原本をRepository外に保持する継続参照資料について、Local／Cloudの双方から取得・処理・反映地点を追跡する管理Sourceを正式採用した。

### 変更内容

- `EXTERNAL_REFERENCE_REGISTRY.md` を既存のAI作業環境責任領域へ配置し、新しいトップレベル領域は作成しなかった。
- 取得元、原本識別情報、最終取得地点、前回処理地点、Timeline／Evidence／制作Sourceへの反映状態および次回差分処理を登録した。
- 会話原本、Personal Archiveの生ログ、公開範囲未決の制作候補はRepositoryへ複製せず、非機密メタデータだけをRepository正本から追跡可能にした。
- Inbox Ledger、Personal Archive側provenance、Timeline、専門Sourceおよび承認記録との責任分離を維持した。

### 現在状態

既存Repositoryから確認できない永続conversation／Work／Task ID、原本取得日時、authoritative pathおよび一部SHAは `未確認` とし、次回取得時の確定対象として残した。

------------------------------------------------------------------------

## 2026-08-28｜Repository外Archive provenance indexを正式採用

### 概要

Personal Archiveの生ログをRepositoryへ複製せず、Local / Cloud双方が最終取得地点、前回処理地点、正式Sourceへの反映状態および原本への再追跡経路を確認できる運用メタデータ正本を追加した。

### 変更内容

- `ARCHIVE_PROVENANCE_INDEX.md` にChatGPT Original snapshot、Gemini / Google AI Mode資料、Processed baselineおよびDerived Work HistoryのDataset ID、SHA、件数、checkpointと反映状態を登録した。
- GPT Archiveの増分取得を、Inbox、Original、Processed、Derived review、Timeline、専門Sourceの順に接続した。
- `AI_WORK_ENVIRONMENT.md` と `INBOX_AND_PERSONAL_ARCHIVE.md` から同Indexへ到達できる導線を追加した。
- Original、Processed、Derived、Inbox Ledger、Timelineおよび各専門Sourceの既存責任は変更していない。

### 現在状態

**Current / Operational v1.0。生ログ本文と個人一次資料はRepository外を維持。**

------------------------------------------------------------------------

## 2026-08-28｜Immediate Execution Ruleの環境接続

### 概要

Chat、Work、Codex等で現在のAIが実行可能な後続作業を予告だけで終えないよう、Human-in-the-loopのImmediate Execution RuleをE2E自動進行へ接続した。

### 変更内容

- 実行可能な成果物生成、Tool実行、修正またはRepository反映は、同一応答・工程内で実行することを明示した。
- 実行不能時の停止、Human Decisionおよび人間に求める最小操作は `HUMAN_IN_THE_LOOP.md` を正とし、作業環境Source側で重複定義しない責任境界を維持した。

### 既存責任への影響

Human Gate、AI組織上の権限、Repository・Git・CHANGELOG、Brand、EducationおよびVoiceの既存責任は変更していない。

------------------------------------------------------------------------

## 2026-08-28｜External Audit API Pipeline v1.0実装

### 概要

内部監査PASS後のFinal CandidateをClaude等の助言的外部AIへAPI接続し、監査結果を構造化して内部制作側へ戻す再利用可能な実装を追加した。

### 変更内容

- Provider Adapter、Model明示、Timeout、Retry、API Errorの本文非ログ化を実装した。
- Promptをコードから分離し、Request / Input / Response SchemaとSeverity意味整合を検証するようにした。
- Repository外Source path、Source範囲超過、内部監査未PASS、外部共有未承認または実行時確認なしをfail-closedとした。
- BLOCKERまたはHuman Decisionは停止し、MAJOR／MINORは内部制作側へ戻し、初期再監査PolicyをMAJOR修正後とした。
- PowerShell回帰テスト7件、Section 1 S1-1〜S1-6 PrepareOnly E2EおよびClaude Live E2EをPASSした。
- 長文監査では接続待ちも明示Timeoutへ統一し、AnthropicのThinking無効化と構造化JSONの最大出力を実行時指定できるようにした。

### 現在状態

**Operational / PrepareOnly E2E PASS / Claude Live E2E PASS（S1-1〜S1-6、BLOCKER・Human Decision 0件）**

------------------------------------------------------------------------

## 2026-08-26｜Human OS・Writing Style OSの正式Source接続

### 概要

Inboxから正式Repositoryへ配属したHuman OS、Supporting Evidence SourceおよびWriting Style OSを、AI作業環境における関連Sourceへ接続した。

### 変更内容

- `05_Human_OS/HUMAN_OS.md`、`05_Human_OS/HUMAN_OS_EVIDENCE_LOG.md`、`06_Writing_Style_OS/WRITING_STYLE_OS.md` を関連Sourceへ追加した。
- Inbox受領・配属工程が正式Source採用、Repository配置、CHANGELOGまたはGitを代替しない既存責任境界を維持した。

### 承認状態

**🟢 現行参照構造として採用**

------------------------------------------------------------------------

## 2026-08-26｜AI Production Pipeline・Repository横断監査への環境接続

### 概要

Repository共通のAI Production PipelineおよびRepository横断監査基準の正式採用に伴い、作業環境と工程接続の責任境界を参照接続した。

### 変更内容

- `AI_PRODUCTION_PIPELINE.md` を、案件ごとのSource選択、Source QA、Production、Repository IntegrationおよびGitまでを接続する共通SOPとして関連Sourceへ追加した。
- `REPOSITORY_CROSS_AUDIT_STANDARD.md` を、Repository全体へ影響する正式Source変更時の横断確認基準として関連Sourceへ追加した。
- AI作業環境Sourceが担うのは各工程の環境接続であり、Source選択基準、監査基準、人間承認またはRepository配置の具体規則を重複定義しないことを明確化した。

### 既存責任への影響

- AI組織上の役割・権限、Human-in-the-loopの承認境界、Repository Rulesの具体運用、Brand、EducationおよびVoiceの専門責任は変更しない。

### 承認状態

**🟢 現行参照構造として採用**

------------------------------------------------------------------------

## 2026-08-25｜Inbox自動除去Implementation互換性承認の正式反映

### 概要

Policy Contract `inbox-auto-removal-v1` に対応するQA済みSkill・Helper実装について、人間による互換性承認を正式Sourceへ反映した。

### 承認済みImplementation

- Implementation Contract：`chat-artifact-inbox-auto-removal-v1`
- implementation identity：`sha256:75a688846e24b29ed475053d47a89f518be4cdb607864a26fa434adbcbe6bf00`
- identity方式：`sha256-canonical-file-manifest-v1`
- 旧identity `sha256:fc4f8cc6faacaf6bbf6664d694d2c63a36ada045cf2bd23cceed24f9cc9d5caf` の承認は継承しない。

### QAおよび有効化状態

- Global Emergency StopをAsset overrideから分離し、全Assetへの優先適用、generic clearからの解除禁止、process再起動後の保持およびfail-closedを隔離E2Eで確認した。
- Inbox回帰31件、auto-removal専用72件およびGlobal Emergency Stop E2E 9件の合格を確認した。
- `automatic_removal_policy_state` は `Disabled` のまま維持する。
- Skill runtimeも`Disabled`であり、本承認はEnabled承認、automatic execution permissionまたは実データ削除開始を意味しない。

### 承認状態

**🟢 Implementation互換性承認済み。ただし自動除去制度状態はDisabled**

## 2026-08-25｜Verified済みInbox重複コピー自動除去制度の正式採用

### 概要

初回Inbox E2Eの実測を踏まえ、Verified済みで安全なauthoritative copyがInbox外へ確立された完全重複コピーについて、全条件を機械確認できる場合だけInbox側コピーを自動除去できる恒久制度を正式採用した。

### 正式化した主な内容

- 自動化対象を、Inbox直下にある単一通常ファイルのVerified済み完全重複コピーに限定し、保持、不保持、配属、競合解消その他の意味判断を人間責任として維持した。
- folder、recursive delete、Original、Processed、DerivedおよびRepository資産を対象外とした。
- sourceとauthoritative copyの独立実体、link・hardlink・reparse等の否定、最新の有効なVerified Event、identity evidenceの不変性、同期状態およびhuman overrideの積極確認を必須化した。
- `Verified → deletion intent → Inbox-side action result → Closed` の追記型履歴と、判定不能・`sync=unknown`・Ledger書込不能その他のfail-closed条件を定義した。
- 正式runtimeをPowerShell 7以上とし、Source正式採用とSkill・Helper実装およびauto mode Enabledを分離した。
- Source revisionを監査・provenance用、Policy Contract Versionを実行互換性用として分離し、初期Contractを `inbox-auto-removal-v1` とした。
- Helperの自己互換宣言だけでは実行資格を認めず、人間承認済みImplementation Contractおよび必要なimplementation identityとの一致を必須化した。
- human overrideおよびemergency stopをSource上のEnabledより優先し、AI、SkillまたはHelperによる停止解除を禁止した。

### 正式採用時の状態

- `automatic_removal_policy_state: Disabled`
- `automatic_removal_policy_contract: inbox-auto-removal-v1`
- `automatic_removal_approved_implementation_contract: none`
- `automatic_removal_approved_implementation_identity: none`

Source正式採用だけでは自動除去を有効化しない。Skill・Helper同期、implementation identity確定、shadow dry-run、否定テスト、QA、互換性の人間承認およびEnabledの人間承認は後続工程とする。

### 監査

- 内部監査、一意修正および再監査を完了した。
- Claude OpusによるF-01〜F-06、N-01〜N-03の差分監査を経て、最終判定「🟢 正式採用可能」、必須修正なしを確認した。

### 既存責任への影響

- 人間判断、停止、再承認および個別指示は引き続き `HUMAN_IN_THE_LOOP.md` を正とする。
- Ledgerを承認主体または制度状態の正としない。
- Repository、GitおよびCHANGELOGの責任、ならびにAI組織上の役割・権限を変更しない。

### 承認状態

**🟢 現行正式Sourceとして採用。ただし自動除去制度状態はDisabled**

## 2026-08-25｜Inbox・Personal Archive受領・配属運用原則の正式採用

### 概要

未配属受領物をOneDrive上のInboxで受領し、評価、分類、必要な人間判断、正式配属、検証およびClosedまで接続する共通運用と、Personal ArchiveにおけるOriginal、ProcessedおよびDerivedの責任境界を、専門Sourceとして正式採用した。

### 正式化した主な内容

- `04_AI_Work_Environment/INBOX_AND_PERSONAL_ARCHIVE.md` を現行正式Sourceとして配置した。
- OneDrive上の `AI/00_Inbox` および `AI/04_Personal_Archive` を、AI作業環境領域が管理するRepository外の運用対象として位置づけた。
- Inboxを正式Source、Archive、Temp、長期保存場所または独立したAI部署・承認主体として扱わない責任境界を明確化した。
- Inbox処理の `Received`、`Assessed`、`AwaitingDecision`、`Placed`、`Verified`、`Closed` を、専門成果物の承認Statusとは異なる運用状態として定義した。
- Personal ArchiveのOriginal、ProcessedおよびDerivedを分離し、センシティブ情報の通常検索・外部提供への自動混入防止とprovenance要件を定義した。
- Inbox LedgerとRepository CHANGELOGを分離し、初回E2EではVerified済みInbox重複コピーの恒久自動除去権限を導入しないことを確定した。
- 現行Skill・Helperの実装状態とSource上の標準要件を分離し、初回Closed E2E前の同期確認結果を新しい承認ゲートとせずChatへ報告する運用を追加した。

### 関連Sourceへの影響

- `AI_WORK_ENVIRONMENT.md` の適用範囲と関連Sourceへ、OneDrive上のInbox・Personal Archiveおよび本専門Sourceとの接続を追加した。
- `REPOSITORY_RULES.md` のAI作業環境領域の正式構造と責任説明を更新した。
- Human-in-the-loop、AI組織、Brand、EducationおよびVoiceの既存責任は変更していない。

### 承認状態

**🟢 現行正式Sourceとして採用**

## 2026-08-23｜AI作業環境・工程接続原則の初回正式採用

### 概要

Chat、Work、Codex、VS Code、Repository、Git、GitHubおよび外部AI等の作業環境を、AI組織上の責任を維持したまま適切な工程へ接続する横断運用原則を、正式Sourceとして初回採用した。

### 正式化した主な内容

- 作業環境とAI組織上の役割を分離し、案件に応じて必要な環境だけを選択する原則
- Chatを意思決定、WorkをRepository反映前の継続作業、CodexをRepository参照・実装・反映・検証の実行環境とする責任境界
- Repository、Git、GitHub、VS Codeおよび正式Source・作業中データ・承認状態の区別
- Chat → CodexとChat → Work → Codexを含む、必須直列工程を前提としない環境間受け渡し
- 外部AIを原則として助言的監査役とし、既存QA・HITL・正式承認を代替させない権限境界
- 人間判断を維持しながら不要な人間操作を減らすE2Eの目標状態と、現行実装状態との区別

### 既存責任への影響

- `AI_ORGANIZATION.md` が担うAI組織構造、役割、権限および責任分離に変更はない。
- `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` が担う承認、停止、自己復旧、エスカレーション、個別指示および完了判断に変更はない。
- `REPOSITORY_RULES.md` が担うRepository構造、GitおよびCHANGELOGの具体運用に変更はない。
- Brand、EducationおよびVoiceの各専門Sourceが担う責任に変更はない。

### 承認状態

**🟢 現行正式Sourceとして採用**
