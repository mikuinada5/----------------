# AI組織シリーズ Section 1 制作台本

**Status:** Redesign Required / Source Retrieval E2E PASS / Production Completion NOT READY<br>
**Section ID:** AIORG-S01<br>
**Section名称:** 第1章｜AIと仕事を始める前の下準備

## 0. 意味づけ・企画フェーズからの引き継ぎ

| Field | 記録 |
|---|---|
| 採用したTimeline史実・一次資料参照 | `01_Timeline.md`のうち利用状態が本Sectionの`制作済み`である7史実。Brand OSと教育設計の確立、AコースProfessional教育設計、教材制作基準の独立、Voice OS・Human-in-the-loop・作業環境の正式採用、Pipeline・note制作領域の正式運用、今回共有されたSeries／Section設計。 |
| 採用した意味づけ / Series | **AI組織シリーズ**。出発点は「AI組織を作る」ことではない。女性が生涯を通して学び続け、自ら選べる教育を届けるために、「これをやりたい。どうやる？」をAIと反復した史実を扱う。その結果として、目的・判断・制作・復旧を分担できるAI組織が立ち上がった。 |
| 読者に届ける学び・順番 | S1-1からS1-6の順に、AIへ任せたい仕事候補、AI仕事場、会話からのDecision抽出、MarkdownとRepository、Version／Status、Git履歴管理へ進む。各SessionはStoryで問題を自分事化し、Practiceで実行へ接続する。 |
| 企画上の採用判断 | Section 1は全6 Sessionとする。S1-1だけStory＋Practiceをこの順序で結合したnote本編1記事とし、S1-2以降はStory、Practice、Session Archiveを独立記事／成果物として扱う。Session ArchiveをStoryまたはPracticeへ混在させない。Storyと確定タイトルは保持する。S1-1 Practiceの既存Statusは継続し、S1-2〜S1-6 Practiceは順番に一つのAI仕事環境を完成させる作業マニュアルとして再設計する。Session Archiveは後発仕様との不一致箇所だけを修正・再監査する。 |
| 引き継ぐHuman Decision | Story本文と確定タイトルのHuman Final Checkは完了済み。S1-2〜S1-6 Practiceは`Human Review Draft / 再設計baseline / Redesign Required / Final未確定`であり、変更禁止を解除する。Session Archiveは、制作時のHuman Reviewから救出された後発仕様を反映するため`Revision Required`とする。具体的な公開範囲・Membershipでの扱い、最終価格、公開日時、note投入・公開は引き続き別途Human Decisionとする。 |

## 1. 識別と状態

| Field | 記録 |
|---|---|
| Section ID / 名称 | AIORG-S01 / 第1章｜AIと仕事を始める前の下準備 |
| Owner / 最終承認者 | 稲田美来（企画・自己開示・価格・公開範囲・Publishの最終判断） |
| Status | Redesign Required |
| Next / Blocker | Story本文と確定タイトル、S1-1 Practiceの既存Statusは保持する。S1-2〜S1-6 Practiceは§2.1の再設計フローでSessionごとに制作・Human完遂Reviewを行う。S1-1〜S1-6 Session Archiveは`00_note制作・公開システム.md` §2.3.3で限定修正・全文再監査する。S01-02 Marketing Review βはPractice第2稿未成立のため`Marketing Input Pending`を維持するが、独立したS1-2 Storyの公開をBLOCKしない。S1-2 StoryはStory単位のMarketing、Header、G5およびPublication Gateを満たした場合に公開でき、Practiceへの導線はTarget未公開中`Pending Link`として追跡する。 |
| 対象読者・目的 | AIを使いたいが、効率化だけでは自分の仕事・思想・品質を預けきれない人。特に、教育・専門性・長期事業のように「何を届けるか」が先にある読者へ、目的から仕組みを育てる見方と最初の実践を届ける。 |
| 公開構成Profile | 全6 Session。S1-1だけStory＋Practiceをnote本編1記事とし、Session Archiveを分離する。S1-2以降はStory、Practice、Session Archiveを独立記事／成果物として扱う。 |
| 公開範囲 | StoryのHuman Final Checkは完了。S1-2〜S1-6 PracticeとSession Archiveの必要改訂、note投入・公開は未実施。Session Archiveの具体的な公開範囲とMembershipでの扱いはPending / Human Decision Required。 |
| 価格仮説・承認状態 | Practice標準価格目標は1,480円前後 / Final未確定。価格のために不要な高度機能・専門知識・文字数を追加しない。 |
| 自己開示の候補・承認状態 | Story本文はHuman Final Check完了済み。S1-2〜S1-6 Practiceは再設計・Human完遂Review待ち。Session Archive本文はスタイル・構造修正後に再Reviewする。実際に公開する範囲とMembershipでの扱いは別途Human Decisionとする。 |

## 2. Source Plan / Source QA

本文Production時のSource Planに加え、Human Review、Internal Audit、Claude External Audit、有効なMINOR反映、Internal Re-Audit、Human Final Checkおよび2026-08-28に救出・再確認されたHuman-approved制作仕様を、現在の修正・公開準備Inputとして扱う。

| Source | 用途 | 現行性・実読 | G2での確認 |
|---|---|---|---|
| Evidence：Codex Task「AI組織づくりの地図を制作」2026-08-24（Registry ID `EXT-CODEX-AIORG-MAP`） | S01-01の初期PPT依頼に関する回顧発言 | 実読済み / 一次資料 | 元会話との区別、引用範囲、発生日不明の明記 |
| Human Confirmation：企画・壁打ちチャット「AI組織づくりの地図を制作」2026-08-24 | S01-01の初期目的、順番、PPT作成依頼の事実、AIが教える内容を知らないという問題の本人確認 | 実読済み / 本人確認済み | Evidenceと矛盾しないこと、未確認のAI回答・採否・感情を補完しないことを確認 |
| Repository Source：`07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md` | S01-01の正式な企画・Source・未解決Decisionの管理 | Current / 更新対象 | 本Session詳細と本文Production時の参照箇所を確認 |
| Repository Source：`07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/01_Primary_Evidence/README.md` | S01-01〜S01-06の選定一次資料、永続ID、原文抜粋、未取得SourceおよびCloud readiness | Current / Source QA PASS | Session IDから該当Evidenceへ到達し、原文・回顧・AI proposal・Git event・未確認事項を区別 |
| Repository Source：`07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/02_Human_Approved_Source_Inventory.md` | S01-01〜S01-06のStory／Practice／Session Archive計18本文の同一性、Status、provenanceおよびCloud参照経路 | Current / Source QA PASS / Source Retrieval E2E PASS | Private repository、artifact、commit、Final Candidate SHA＋見出しlocator、本文種別ごとのStatusを確認 |
| Private Source：`mikuinada5/feminine-wellness-private-sources` / `PSR-AIORG-S01-FC` | S01-01〜S01-06の正式baseline本文18件 | Source commit `0531e32239237b7bd5f011bca62d65f5d9d4317e` / Repository HEAD `4c2ea252fa7a78d99ab22c27fe9b8ac0e7975ffa` / file SHA `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2` | Storyは無改変取得、S1-1 Practiceは既存Status、S1-2〜S1-6 Practiceは再設計baseline、ArchiveはHuman-approved baselineから限定修正工程へ進む |
| `07_Note_Production/01_Timeline.md` | 記事に使える確認済み史実と一次資料参照 | Current / 実読済み | Storyの史実・参照位置をSessionごとに照合 |
| `07_Note_Production/00_note制作・公開システム.md` | Section固有公開構成Profile、記事制作仕様、Marketing Review β、公開Gate、Pending Link／Backfill Lifecycle | Current / v2.5実読済み | S1-1のStory＋Practice結合、S1-2以降の独立成果物、成果物別Acceptance Criteria、第2稿入場条件、Marketing責任および記事間循環導線を確認 |
| `AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_Final_Candidate.md` | Private本文正本の取得元provenance | Provenance origin / SHA-256 `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2` | Private exact copyとの同一性照合に使用し、Cloud制作時の別Current正本として編集しない |
| `AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_External_Audit_Reconciliation.md` | External Audit結果とMINOR採否の取得元provenance | Internal Re-Audit PASS / Private exact copy済み | BLOCKER／Human Decision 0件、Final Candidate SHA一致を確認 |
| `05_Human_OS/HUMAN_OS.md` | 目的、影響、回復可能性、判断境界 | Current / 実読済み | 本人の判断をAI推論で代替していないか確認 |
| `02_Voice_OS/VOICE_OS.md` | 稲田美来本人のVoice判断 | Current / Production前に再実読 | 本人Voiceを担う箇所の適用確認 |
| `06_Writing_Style_OS/WRITING_STYLE_OS.md` | 思考のライブ感と媒体別の文体強度 | Current / 実読済み | 会話ログの表面模倣になっていないか確認 |
| `00_Brand/01_ブランドCore.md`、`04_ブランド言語・表現原則.md`、`09_AI共創原則.md` | 目的、表現、AIとの共創思想 | Current / 実読済み | 教育ブランドの目的・表現と矛盾しないか確認 |
| `AI_ORGANIZATION.md` | 役割・権限・受け渡し | Current / 実読済み | AI組織を技術・人事の物語にすり替えていないか確認 |
| 本台本 | 企画・Session構成・未解決Decision | Current / 作成済み | 各Draftが本台本の役割に沿うか確認 |

**G0:** Draftは外部公開しない。最終承認者は稲田美来。<br>
**Source / Audit QA record:** 既存Final CandidateのHuman Review、Internal Audit、Claude External Audit、Internal Re-AuditおよびHuman Final Checkの履歴はprovenanceとして保持する。ただし2026-08-29の最新Human Decisionは、S1-2〜S1-6 PracticeをHuman-approved Finalではなく`Human Review Draft / Redesign Required`と確定した。旧監査履歴を削除・遡及変更せず、最新Statusが優先する。Storyと確定タイトル、S1-1 Practiceの既存Statusは変更しない。Session Archiveは`Revision Required`を維持する。旧工程の独立したG2受付記録は本台本に残っていないため、G2完了を遡及して推測しない。公開構成Profile、最終価格、Session Archive公開範囲、note投入およびPublishは別Gateとして残す。

**Primary Evidence / Human-approved Source / Readiness:** 2026-08-28に全6 Sessionの必要最小限の一次資料PackageをSection配下へ配置し、Source QAはPASSとした。2026-08-29に18本文を含むFinal CandidateとAudit Reconciliationのexact copyを全社共通Private Source Repositoryへ配置し、source commitとfile SHAへ固定した。本文はPublic Repositoryへ複製していない。同日のスマホWork Cloud実測で、Public制作台本→Inventory→Private Repository→Section README／Index→artifact→S1-2 Story／Practice／Session ArchiveのSource Retrieval E2Eは`PASS`した。Humanによるファイル・pathの手渡し、Source欠落、推測補完はなかった。

**Readiness分離:** Source Retrieval Readinessは`PASS`。Production Completion Readinessは全6 Session `NOT READY`である。StoryはREADY、S1-1 Practiceは既存Statusを継続、S1-2〜S1-6 Practiceは`Redesign Required`、Session Archiveは`Revision Required`である。S01-03、S01-05、S01-06の一次ログまたは画像本体の不足もPrimary Evidence Packageの制限として維持する。

本文探索順は `本台本` → `02_Human_Approved_Source_Inventory.md` → `EXT-PSR-AIORG-S01` → Private Section README → `PSR-AIORG-S01-FC` → `source commit＋file SHA＋本文locator` とする。Local-only OneDrive path、downstream抽出または記憶から本文を補完しない。この経路はスマホWork Cloudで実探索済みである。

### 2.1 Practice再設計方針（今回は制作未着手）

S1-2〜S1-6 Practiceは、読者が記事を横に置いて一緒に作業し、自分の環境・成果物を完成できる作業マニュアルとして再設計する。価値基準は文字数や高度機能ではなく初心者の完遂率とする。各Sessionで「ここまでにできているもの／今回作るもの／終わった時の状態／次に積み上げるもの」を示し、Section 1終了時に一つのAI仕事環境が完成する構造にする。

| Session | 完成責任 |
|---|---|
| S01-01 | 「私はAIと何をしたいのか」を定める根幹・起点。最新Decisionの再設計対象外。 |
| S01-02 | 考える場所、作る場所、必要ファイル、保存先、AIのアクセス可否、Human運搬要否を判断した`Workplace Map`を完成する。 |
| S01-03 | Discussion → Candidate → Human Decision → Formal Source Candidateを判断した`Decision Pickup Sheet`を完成する。 |
| S01-04 | 最初のMarkdown Source、保存場所、Source of Truth、AIからの参照確認を完成する。成熟したRepositoryを初心者の完成状態として押しつけない。 |
| S01-05 | HumanとAIが正式Sourceを誤認しない最低限のSource Governanceを完成する。 |
| S01-06 | Git管理開始、status、初回記録、Source変更、diff、Human確認、2回目commit、history、復元概念までを扱い、正式SourceをGitで履歴管理できる状態を完成する。AI操作を主経路、VS Code GUI／Terminalを必要時の代替経路とする。 |

各Sessionは次の順で制作する。S01-02はMarketing Review βのPreflightだけを実行し、本文制作は第1工程から再開する。

1. Human Review Draft監査
2. 現在の強い部分を特定
3. 説明不足を特定
4. Primary Evidenceから初心者停止点を抽出
5. 必要な公式一次情報を確認
6. 作業マニュアルとして手順再設計
7. コピペ可能なAIプロンプト設計
8. 正常状態／異常状態設計
9. FAQ / Troubleshooting設計
10. Screenshot Needed List作成
11. Human実機操作
12. 実Screenshot取得
13. 必要な注釈加工
14. 本文とScreenshot統合
15. Human完遂Review
16. Human Reviewと実素材を反映した第2稿化
17. Marketing Review（競合比較、価格、無料／有料境界、CTAその他のPublication Decisionを含む）
18. Marketing Requirementをnote制作側が反映
19. Marketing再監査
20. Marketing Approved＋Publication Decision確定／第3稿化
21. Human Final Approval
22. 最終稿化

Primary EvidenceはPracticeを読み物化するためではなく、初心者が止まった地点を発見するために使う。各停止点を本文での先回り説明、FAQ、Troubleshooting、注意事項、今回対象外のいずれかへ分類し、Session Archiveの責任と混同しない。Section 2はSection 1の環境を使ってAIとの壁打ち・質問・一仕事の完遂を順に学ぶ。Section 3以降は必要なものを選択する構造を基本とする。

## 3. Story Hub

| Story ID | Final Candidateの確定Story | 使用Session | Human Final Check | note本編での役割 | 注記 |
|---|---|---|---|---|---|
| SH-01 | 最初に考えるのは「どのAIを使うか」じゃなかった | S01-01 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |
| SH-02 | 同じAIなのに、できることが違うのなんで？ | S01-02 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |
| SH-03 | Chatで話したことって、全部AIが覚えてるルールじゃないの？ | S01-03 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |
| SH-04 | 決まったことをファイルにして、正本の場所を決める | S01-04 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |
| SH-05 | 「最新」「最終」「最終2」って、結局どれが正式なの？ | S01-05 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |
| SH-06 | Gitって、コードを書く人のものだと思ってた | S01-06 | 完了 | Practiceを読む理由を作る導入 | 本文はFinal Candidateから変更しない。 |

## 4. Session設計と公開構成Profile

| Session ID | Story確定note記事タイトル | Story | Practice | 別コンテンツ：Session Archive | 状態 | 未解決Decision |
|---|---|---|---|---|---|---|
| S01-01 | 最初に考えるのは「どのAIを使うか」じゃなかった | 同名Storyをnote本編前半へ使用 | AIにやってほしいことを全部出してみる | 「PowerPoint作ってくれないかな」から始まった | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-02 | 同じAIなのに、できることが違うのなんで？ | 同名Storyを独立Story記事として使用 | 独立Practice記事「自分のAI仕事場マップを作る」 | 独立Session Archive記事「同じAIなのに、なんでここではできないの？？？」 | Redesign Required（Practice）/ Revision Required（Archive） | Practice再設計・Human完遂Review、Archive全文再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-03 | Chatで話したことって、全部AIが覚えてるルールじゃないの？ | 同名Storyを独立Story記事として使用 | 独立Practice記事「壁打ちが終わったら『何が決まったか』だけ拾う」 | 独立Session Archive記事「『前に話したじゃん』が通じない」 | Redesign Required（Practice）/ Revision Required（Archive） | Practice再設計・Human完遂Review、Archive全文再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-04 | 決まったことをファイルにして、正本の場所を決める | 同名Storyを独立Story記事として使用 | 独立Practice記事「Chatで決めたことをMarkdownにしてRepositoryへ置く」 | 独立Session Archive記事「で、このMarkdownどこに置くの？？？」 | Redesign Required（Practice）/ Revision Required（Archive） | Practice再設計・Human完遂Review、Archive全文再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-05 | 「最新」「最終」「最終2」って、結局どれが正式なの？ | 同名Storyを独立Story記事として使用 | 独立Practice記事「MarkdownにVersionとStatusを持たせる」 | 独立Session Archive記事「最終、修正版、最終2、本当の最終」 | Redesign Required（Practice）/ Revision Required（Archive） | Practice再設計・Human完遂Review、Archive全文再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-06 | Gitって、コードを書く人のものだと思ってた | 同名Storyを独立Story記事として使用 | 独立Practice記事「RepositoryをGitで履歴管理する」 | 独立Session Archive記事「Gitって何？？？？？から始まった」 | Redesign Required（Practice）/ Revision Required（Archive） | Practice再設計・Human完遂Review、Archive全文再監査、価格、公開日時、Session Archiveの公開範囲・Membership |

S1-1だけStory＋Practiceをこの順序でnote本編1記事にする。S1-2以降はStory、Practice、Session Archiveを独立記事／成果物として扱い、自動結合しない。Story本文・確定タイトルとS1-1 Practiceの既存Statusは変更しない。S1-2〜S1-6 Practiceの現行本文は再設計baselineとして保持し、§2.1に従って新たなFinal CandidateとHuman approvalを得る。Session Archiveは、Human-approvedの内容・一次ログ・順序・表現を保持したまま、段落・改行・終わり方を含む後発仕様との不一致箇所だけを必要最小限に修正し、全文を再監査する。Session Archiveの具体的な公開範囲とMembershipでの扱いは別途Human Decisionとし、未決のまま公開しない。

### 4.1 記事間循環導線

| Link Record ID | Source Article ID | Target Article ID | Placement | Link Type / Card Type | Status | Target URL | 注記 |
|---|---|---|---|---|---|---|---|
| `AIORG-S01-LINK-001` | `S01-02-STORY` | `S01-02-PRACTICE` | Story末尾（既存Human-approved配置を維持） | noteリンクカード | Pending |  | S1-2 StoryはTarget未公開でも公開可能。Practiceの実在URL取得後にBackfill、再PPV PASS後だけResolved。 |
| `AIORG-S01-LINK-002` | `S01-02-PRACTICE` | `S01-03-STORY` | Practice末尾 | noteリンクカード | Pending |  | S1-3 Storyの実在URL取得後にBackfill、再PPV PASS後だけResolved。 |

Target未公開中はTarget URLを空欄とし、未公開URL、仮URLまたは推測URLを置かない。状態遷移、BackfillのHuman Publication Approval、利用可能なPublisher経路および再PPVは`00_note制作・公開システム.md` §2.6.7、公開後の現在状態は`11_公開成果物記録テンプレート.md`の記事間リンク記録に従う。Timelineは実際に発生した公開・Backfill事実だけを扱い、現在のリンク状態を管理しない。

### S01-01 制作台本詳細

以下はS01-01のEvidence provenanceとして保持する。Story／Practice本文、確定タイトルおよび公開構成はFinal Candidateと§4を正とし、本節の旧Planning記録で上書きしない。Session Archiveは§4の限定修正・全文再監査を適用する。

| Field | 記録 |
|---|---|
| Human Goal | Human Confirmation：最初から「AI組織を作りたい」と考えていたのではない。すでにChatGPTへ詳細を指示してPPT作成を依頼しており、その後、「Bコース3回目のPowerPoint作って」くらいの短い依頼で、自作時とほぼ変わらない品質の成果物を出してほしかった。 |
| Human Emotion | 確認できず。 |
| AI Proposal | 初期PPT依頼時のAI回答は確認できず。 |
| Human Decision | 初期PPT依頼時の採用・却下は確認できず。ただしHuman Confirmationとして、ChatGPTへ内容・構成・雰囲気を指示してPowerPointを作ってもらっていたことを記録する。 |
| Result | Human Confirmationとして、PowerPointを任せようとした際に「そもそもAIは、私が何を教えたいのか知らない」という問題が出たことを記録する。元の成果物の状態は確認できず。 |
| 未解決Decision | Session Archiveを実際に公開する範囲、Membershipでの扱い、価格、公開日時。 |

#### Human Confirmation

| Confirmation ID | Source | 本人確認済み内容 | 反映先 | 注意事項 |
|---|---|---|---|---|
| HC-01 | 企画・壁打ちチャット「AI組織づくりの地図を制作」2026-08-24 | 「私が最初から『AI組織を作りたい』と考えていたように書かないでください。」 | Story、Human Goal | 初期PPT依頼の発生日は確認できず。 |
| HC-02 | 同上 | 「私はすでにChatGPTを使っており、こういう内容を入れて、こんな構成にして、こういう雰囲気で、など、ある程度プロンプトで指示を出しながらPowerPointを作ってもらうことはできていました。」 | Human Goal、Human Decision | 当時のAI回答は確認できず。 |
| HC-03 | 同上 | 「最終的には、『Bコース3回目のPowerPoint作って』くらいの短い依頼だけで、私が自分で作ったときとほぼ変わらないクオリティの成果物を出してほしかった。最初の願いは、ただそれだけでした。」 | Story、Human Goal、SC-01 | 実際にその品質へ到達したかは確認できず。 |
| HC-04 | 同上 | 「PowerPointを本当に任せようとしたことで、『そもそもAIは、私が何を教えたいのか知らない』という問題が出てきました。」 | Story、Result、SC-02 | 当時のAI回答と、その後の対応は確認できず。 |

#### Evidence確認済みScene

| Scene ID | 扱う出来事 | 使用Evidence | Human Confirmation | 未確認事項 |
|---|---|---|---|---|
| SC-01 | ChatGPTへ詳細を指示してPPT作成を依頼しており、その後、短い依頼でBコース3回目のPPTを任せたいと考えていた。 | Codex Task「AI組織づくりの地図を制作」2026-08-24の回顧発言。 | HC-02、HC-03 | 元会話の日付・Chat名・AI回答・採用または却下・成果物の状態。 |
| SC-02 | PowerPointを任せようとした際、AIが本人の教えたい内容を知らないという問題が出た。 | Codex Task「AI組織づくりの地図を制作」2026-08-24の回顧発言。 | HC-04 | 当時のAI回答、その後の依頼・決定、作成物、問題への対応。 |

#### Source区分

| Source区分 | Source | 用途 | 取扱い |
|---|---|---|---|
| Evidence | Codex Task「AI組織づくりの地図を制作」2026-08-24 / `EXT-CODEX-AIORG-MAP` | 初期PPT依頼に関する回顧発言 | 元会話との区別、引用範囲、発生日不明を明記する。 |
| Human Confirmation | 企画・壁打ちチャット「AI組織づくりの地図を制作」2026-08-24 | 初期目的、順番、PPT作成依頼の事実、AIが教える内容を知らないという問題の本人確認 | Evidenceと矛盾しない範囲で使用する。未確認のAI回答・採否・感情は補完しない。 |
| Repository Source | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md` | S01-01の正式な企画・Source・未解決Decisionの管理 | 本Section制作台本を現行の管理Sourceとする。 |
| Repository Supporting Source | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/01_Primary_Evidence/S01-01.md` | 原文抜粋、永続ID、Timeline接続および未取得Source | 記事本文・Timeline・Human-approved成果物の代替にしない。 |

### 役割分担

- **Story:** 読者が問題を自分事化し、実体験からSessionテーマへ入り、Practiceを読む理由を作る。S1-1ではnote本編の前半、S1-2以降は独立Story記事を担う。
- **Practice:** Storyで生まれた問いを、読者が自分の仕事で試せる手順・テンプレート・確認点に変える。S1-1ではnote本編の後半、S1-2以降は独立Practice記事を担う。
- **Session Archive:** Storyでは圧縮する壁打ち、迷い、修正、失敗、感情、制作裏側を扱う別コンテンツ。note本編へ混ぜず、具体的な公開範囲とMembershipでの扱いは別途Human Decisionとする。
- **SNS投稿案:** 承認済みの公開対象を入口にし、note本編またはSession Archiveを代替しない。実投稿は別Gateで扱う。
- **note制作担当:** Timelineからの事実抽出、Source Routing、Draft、QA、Human Review反映およびMarketing Requirementの文章実装を担う。
- **Marketing担当:** 第2稿から監査し、本文を直接書き換えずRequirementと根拠付きPublication Decision推奨案を作る。シリーズの思想、Target Reader、商品価値、自己開示または既存商品設計を変更しない。
- **人間（稲田美来）:** 企画の最終判断、史実の文脈確認、自己開示、価格、公開範囲、最終Publishを担う。

## 5. Section完成条件と価格キャリブレーション

- 全6 SessionにStory、Practice、Session Archiveが各1件存在する。Story本文と確定タイトルのHuman Final Checkは完了している。S1-2〜S1-6 Practiceは現行本文を再設計baselineとして保持する。
- S1-2〜S1-6 Practiceは§2.1の完成責任・制作フローと`00_note制作・公開システム.md` §2.3.2に適合し、初心者が実機で成果物を完成できることをHuman完遂Reviewで確認する。Session Archiveは別コンテンツとして分離し、同仕様§2.3.3に適合させる。
- 各Session Archiveは、後発Human-approved仕様と不一致の箇所だけを修正し、追記・修正・統合後に全文をAcceptance Criteriaで再監査する。
- note下書き保存前に、S1-1の結合本編とS1-2以降の独立Story／Practiceについて、承認済み公開構成Profileどおりの本文抽出、ヘッダー画像との対応、Archive非混入、第2稿、Marketing Approved、第3稿およびHuman Final Approval済み最終稿を確認する。
- Story本文・確定タイトルのHuman Final Check、Practice再設計後のHuman完遂Review、第2稿、Session Archiveの修正後再Review、Marketing Review、第3稿、Human Final Approval、Publication E2EおよびPublishを分離する。Sectionの現在Statusは`Redesign Required / Production Completion NOT READY`、Archive単位は`Revision Required`、S01-02 Marketing substatusは`Marketing Input Pending`とする。
- Marketingは価格、無料／有料境界、CTAその他の推奨Decisionを根拠とConfidence付きで作成する。Session Archiveの公開範囲とMembershipでの扱い、各note本編の最終価格およびPublishはHuman Final Approvalで確定する。
- 承認・公開・公開後記録までの状態遷移は`07_Note_Production/00_note制作・公開システム.md`に従う。

## 6. Production / QA / Approval

| Session ID | Source / Audit QA | Final Candidate / Output QA | Human Final Check | 価格 | Session Archive公開範囲 | 差し戻し対象・修正範囲 | 再Review | Publish承認 | 次アクション |
|---|---|---|---|---|---|---|---|---|---|
| S01-01 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story／Practice既存PASS / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-02 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story READY / Practice Redesign Required / Archive Revision Required | Story・タイトル完了。Practice Final未確定。Archive再Review待ち | Pending | Pending / Human Decision Required | Practice作業マニュアル再設計、Session Archive後発仕様不一致。Marketing βはPractice第2稿未成立でInput Pending | Pending | 未承認 | Storyは独立記事としてArticle単位のMarketing／Header／G5／Publication Gateへ進められる。Practiceは§2.1工程→Human完遂Review→第2稿化後にArticle単位のMarketing Reviewを開始 |
| S01-03 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story READY / Practice Redesign Required / Archive Revision Required | Story・タイトル完了。Practice Final未確定。Archive再Review待ち | Pending | Pending / Human Decision Required | Practice作業マニュアル再設計、Session Archive後発仕様不一致、一次ログ制限 | Pending | 未承認 | Practice §2.1工程開始。その後Archive限定修正・再監査 |
| S01-04 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story READY / Practice Redesign Required / Archive Revision Required | Story・タイトル完了。Practice Final未確定。Archive再Review待ち | Pending | Pending / Human Decision Required | Practice作業マニュアル再設計、Session Archive後発仕様不一致 | Pending | 未承認 | Practice §2.1工程開始。その後Archive限定修正・再監査 |
| S01-05 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story READY / Practice Redesign Required / Archive Revision Required | Story・タイトル完了。Practice Final未確定。Archive再Review待ち | Pending | Pending / Human Decision Required | Practice作業マニュアル再設計、Session Archive後発仕様不一致、一次ログ制限 | Pending | 未承認 | Practice §2.1工程開始。その後Archive限定修正・再監査 |
| S01-06 | Source QA / Retrieval E2E PASS。既存監査履歴を保持 | Story READY / Practice Redesign Required / Archive Revision Required | Story・タイトル完了。Practice Final未確定。Archive再Review待ち | Pending | Pending / Human Decision Required | Practice作業マニュアル再設計、Session Archive後発仕様不一致、一次資料制限 | Pending | 未承認 | Practice §2.1工程開始。その後Archive限定修正・再監査 |

## 7. Marketing Review β / Publication Decision

### 7.1 S01-02 β試運転Preflight（Test Case #001）

| Field | 記録 |
|---|---|
| Review Run ID / Session ID | `MRB-S01-02-001` / S01-02 |
| β Test Case ID | `Test Case #001`。共通Marketing Review機構の最初のβ検証対象であり、S01-02専用機構を意味しない。 |
| 実行日 | 2026-08-30 |
| Marketing Input / 第2稿識別 | **不足**。S01-02 Storyと確定タイトルはREADYだが、Practiceは`Human Review Draft / Redesign Required / Final未確定`、Human完遂Review・実Screenshot・第2稿化は未実施。 |
| Fixed Input実読 | Target Reader、Section内のS01-02役割、Story／Practice／Session ArchiveのStatus、公開構成Profile、Section制作台本、note制作SOP v1.8を確認。Private本文は今回のMarketing本文監査Inputとして使用していない。 |
| Decision-specific Required Source | **未開始**。価格、市場・競合、CTA、Membership、公開日時その他は、第2稿成立後にDecision単位で選定する。 |
| Additional Source / External Research | **未実施**。第2稿の実価値と購入前Promiseを確認できず、現時点の市場比較はDecisionの先行固定になるため。 |
| Requirement | Marketing Requirementなし。上流の既存Production RequirementであるPractice再設計、Human完遂Review、実素材反映および第2稿化を維持する。 |
| Marketing Gate | `Marketing Input Pending`。Marketing本文監査・Publication Decision・第3稿化は未実施。 |
| Human Decision Required | なし。既存Sourceから再開条件を一意に判断できる。 |
| 再開条件 | 本Runは旧結合Profile下で行ったPreflight履歴として保持し、独立Storyの公開条件またはMarketing承認として流用しない。Practiceは§2.1の第1〜16工程を完了し、再設計Practiceの第2稿識別、Human完遂Review結果、Screenshot／実素材状態をArticle単位の新しいMarketing Reviewへ接続する。 |

### 7.2 βで確認したPipeline Gap

| Gap ID | 発見事項 | 影響 | β対応 / 次の検証 |
|---|---|---|---|
| `MRB-GAP-001` | 既存Section記録は初稿・第2稿・第3稿・最終稿およびMarketing substatusを区別していなかった。 | 未完成稿がMarketing Inputまたは公開候補へ進む恐れ。 | note SOP v1.8とSectionテンプレートv1.4で稿名称、入場条件、substatus、戻り先を追加。S01-02でInput Pendingが機能することを確認。 |
| `MRB-GAP-002` | 詳細Marketing ReviewとRequirementの未公開本文をPublic Repositoryへ安全に保存する既存単一pathはない。 | Public／Private境界違反またはReview evidence消失の恐れ。 | Public台本には安全なRun metadataだけを置く。第2稿成立時、詳細記録は本文と同じ承認範囲のWork／Private Source／指定Archiveへ置き、locatorを本Runへ接続する。 |
| `MRB-GAP-003` | Repository上のPublication E2EはG8／G9の要件を定義するが、現行note編集画面の各設定と自動操作手段の実測対応表はない。 | Marketing Decisionの設定可否とnote側の未定義項目を事前に断定できない。 | Human Final Approval後の実note下書きで項目対応、接続・認証、利用不能機能を実測し、公開ボタン直前でSTOPしてGapを追記する。 |

`MRB-S01-02-001`は正しい入力Gateで停止しており、Marketing Approved、第3稿、Human Final Approval、最終稿またはPublication Preparedには到達していない。既存のPractice baselineを第2稿と読み替えず、本RunのPublication Decisionはすべて`Unknown / Not Evaluated`とする。本Runの未完了は、独立したS1-2 Storyが記事単位の各Gateを通過して公開されることをBLOCKしない。

## 8. 公開後・Feedback

未着手。公開後に、各SessionについてHuman承認済み公開構成Profileの公開済み最終稿、公開成果物記録、ロードマップのStatus、Timelineへ追加する新たな史実、Feedback Candidateを記録する。未公開のSession Archiveを公開済みとして記録しない。
