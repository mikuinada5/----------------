# AI組織シリーズ Section 1 制作台本

**Status:** Revision Required<br>
**Section ID:** AIORG-S01<br>
**Section名称:** 第1章｜AIと仕事を始める前の下準備

## 0. 意味づけ・企画フェーズからの引き継ぎ

| Field | 記録 |
|---|---|
| 採用したTimeline史実・一次資料参照 | `01_Timeline.md`のうち利用状態が本Sectionの`制作済み`である7史実。Brand OSと教育設計の確立、AコースProfessional教育設計、教材制作基準の独立、Voice OS・Human-in-the-loop・作業環境の正式採用、Pipeline・note制作領域の正式運用、今回共有されたSeries／Section設計。 |
| 採用した意味づけ / Series | **AI組織シリーズ**。出発点は「AI組織を作る」ことではない。女性が生涯を通して学び続け、自ら選べる教育を届けるために、「これをやりたい。どうやる？」をAIと反復した史実を扱う。その結果として、目的・判断・制作・復旧を分担できるAI組織が立ち上がった。 |
| 読者に届ける学び・順番 | S1-1からS1-6の順に、AIへ任せたい仕事候補、AI仕事場、会話からのDecision抽出、MarkdownとRepository、Version／Status、Git履歴管理へ進む。各SessionはStoryで問題を自分事化し、Practiceで実行へ接続する。 |
| 企画上の採用判断 | Section 1は全6 Sessionとする。各Sessionのnote本編はStory＋Practiceをこの順序で結合した1記事とし、Session Archiveは本編から分離した別コンテンツとして保持する。Story、Practiceおよび確定タイトルは保持し、後発のHuman-approved仕様と不一致が確認されたSession Archiveだけを修正・再監査する。 |
| 引き継ぐHuman Decision | Story／Practice本文と確定タイトルのHuman Final Checkは完了済み。Session Archiveは、制作時のHuman Reviewから救出された後発仕様を反映するため`Revision Required`とする。具体的な公開範囲・Membershipでの扱い、価格、公開日時、note投入・公開は引き続き別途Human Decisionとする。 |

## 1. 識別と状態

| Field | 記録 |
|---|---|
| Section ID / 名称 | AIORG-S01 / 第1章｜AIと仕事を始める前の下準備 |
| Owner / 最終承認者 | 稲田美来（企画・自己開示・価格・公開範囲・Publishの最終判断） |
| Status | Revision Required |
| Next / Blocker | Story／Practice本文と確定タイトルは保持する。S1-1〜S1-6のSession Archiveだけを、`00_note制作・公開システム.md` §2.2.3のAcceptance Criteriaで監査し、必要最小限に修正した後、各Archive全文を再監査する。Archive修正完了後にStory＋Practiceを6本のnote本編へ分割し、ヘッダー画像と照合する。note投入・価格設定・公開は行わない。 |
| 対象読者・目的 | AIを使いたいが、効率化だけでは自分の仕事・思想・品質を預けきれない人。特に、教育・専門性・長期事業のように「何を届けるか」が先にある読者へ、目的から仕組みを育てる見方と最初の実践を届ける。 |
| 公開構成Profile | 全6 Session。各SessionのStory＋Practiceをnote本編1記事とし、Session Archiveは別コンテンツとして分離する。 |
| 公開範囲 | note本編のHuman Final Checkは完了。note投入・公開は未実施。Session Archiveの具体的な公開範囲とMembershipでの扱いはPending / Human Decision Required。 |
| 価格仮説・承認状態 | 未設定 / Pending。今回の整合性修正では決定しない。 |
| 自己開示の候補・承認状態 | Story／Practice本文はHuman Final Check完了済み。Session Archive本文はスタイル・構造修正後に再Reviewする。実際に公開する範囲とMembershipでの扱いは別途Human Decisionとする。 |

## 2. Source Plan / Source QA

本文Production時のSource Planに加え、Human Review、Internal Audit、Claude External Audit、有効なMINOR反映、Internal Re-Audit、Human Final Checkおよび2026-08-28に救出・再確認されたHuman-approved制作仕様を、現在の修正・公開準備Inputとして扱う。

| Source | 用途 | 現行性・実読 | G2での確認 |
|---|---|---|---|
| Evidence：GPT Archive「AI組織づくりの地図を制作」2026-08-24（Registry ID `EXT-GPT-AIORG-MAP`） | S01-01の初期PPT依頼に関する回顧発言 | 実読済み / 一次資料 | 元会話との区別、引用範囲、発生日不明の明記 |
| Human Confirmation：企画・壁打ちチャット「AI組織づくりの地図を制作」2026-08-24 | S01-01の初期目的、順番、PPT作成依頼の事実、AIが教える内容を知らないという問題の本人確認 | 実読済み / 本人確認済み | Evidenceと矛盾しないこと、未確認のAI回答・採否・感情を補完しないことを確認 |
| Repository Source：`07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md` | S01-01の正式な企画・Source・未解決Decisionの管理 | Current / 更新対象 | 本Session詳細と本文Production時の参照箇所を確認 |
| `07_Note_Production/01_Timeline.md` | 記事に使える確認済み史実と一次資料参照 | Current / 実読済み | Storyの史実・参照位置をSessionごとに照合 |
| `07_Note_Production/00_note制作・公開システム.md` | Section固有公開構成Profile、記事制作仕様、公開Gate | Current / v1.6実読済み | Story＋Practice本編とSession Archive分離、および§2.2の成果物別Acceptance Criteriaを確認 |
| `AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_Final_Candidate.md` | S1-1〜S1-6の確定タイトル・Story・Practice・Session Archive本文 | 既存候補 / SHA-256 `7E8DDF4E4F7CEC755A99EB123024A12D04883CCD353FF88F8C7A278790185CB2` | Story／Practice本文と確定タイトルは保持する。Session Archiveは後発Human-approved仕様との不一致箇所だけを修正し、全文Acceptance Criteria再監査後に再Reviewする |
| `AI/04_Personal_Archive/Derived/AI_Organization_Series_Section1_External_Audit_Reconciliation.md` | External Audit結果とMINOR採否 | Internal Re-Audit PASS | BLOCKER／Human Decision 0件、Final Candidate SHA一致を確認 |
| `05_Human_OS/HUMAN_OS.md` | 目的、影響、回復可能性、判断境界 | Current / 実読済み | 本人の判断をAI推論で代替していないか確認 |
| `02_Voice_OS/VOICE_OS.md` | 稲田美来本人のVoice判断 | Current / Production前に再実読 | 本人Voiceを担う箇所の適用確認 |
| `06_Writing_Style_OS/WRITING_STYLE_OS.md` | 思考のライブ感と媒体別の文体強度 | Current / 実読済み | 会話ログの表面模倣になっていないか確認 |
| `00_Brand/01_ブランドCore.md`、`04_ブランド言語・表現原則.md`、`09_AI共創原則.md` | 目的、表現、AIとの共創思想 | Current / 実読済み | 教育ブランドの目的・表現と矛盾しないか確認 |
| `AI_ORGANIZATION.md` | 役割・権限・受け渡し | Current / 実読済み | AI組織を技術・人事の物語にすり替えていないか確認 |
| 本台本 | 企画・Session構成・未解決Decision | Current / 作成済み | 各Draftが本台本の役割に沿うか確認 |

**G0:** Draftは外部公開しない。最終承認者は稲田美来。<br>
**Source / Audit QA record:** 既存Final Candidateは、Human Review、Internal Audit、Claude External Audit、Internal Re-AuditおよびHuman Final Checkを通過した履歴を保持する。その後、制作時のHuman ReviewからStory／Practice／Session Archiveの詳細仕様が救出され、現行Sourceには役割概念のみで具体的Acceptance Criteriaが不足していたこと、Final CandidateのSession Archiveに後発仕様との不一致があることを確認した。既存監査履歴を削除または遡及変更せず、Story／Practice本文と確定タイトルは保持し、Session Archiveだけを`Revision Required`へ戻す。旧工程の独立したG2受付記録は本台本に残っていないため、G2完了を遡及して推測しない。公開構成Profile、価格、Session Archive公開範囲、note投入およびPublishは別Gateとして残す。

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

| Session ID | 確定note記事タイトル | Story | Practice | 別コンテンツ：Session Archive | 状態 | 未解決Decision |
|---|---|---|---|---|---|---|
| S01-01 | 最初に考えるのは「どのAIを使うか」じゃなかった | 同名Storyをnote本編前半へ使用 | AIにやってほしいことを全部出してみる | 「PowerPoint作ってくれないかな」から始まった | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-02 | 同じAIなのに、できることが違うのなんで？ | 同名Storyをnote本編前半へ使用 | 自分のAI仕事場マップを作る | 同じAIなのに、なんでここではできないの？？？ | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-03 | Chatで話したことって、全部AIが覚えてるルールじゃないの？ | 同名Storyをnote本編前半へ使用 | 壁打ちが終わったら「何が決まったか」だけ拾う | 「前に話したじゃん」が通じない | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-04 | 決まったことをファイルにして、正本の場所を決める | 同名Storyをnote本編前半へ使用 | Chatで決めたことをMarkdownにしてRepositoryへ置く | で、このMarkdownどこに置くの？？？ | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-05 | 「最新」「最終」「最終2」って、結局どれが正式なの？ | 同名Storyをnote本編前半へ使用 | MarkdownにVersionとStatusを持たせる | 最終、修正版、最終2、本当の最終 | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |
| S01-06 | Gitって、コードを書く人のものだと思ってた | 同名Storyをnote本編前半へ使用 | RepositoryをGitで履歴管理する | Gitって何？？？？？から始まった | Revision Required（Archive） | Archive全文Acceptance Criteria再監査、価格、公開日時、Session Archiveの公開範囲・Membership |

各Sessionのnote本編はStory＋Practiceをこの順序で1記事にする。Session Archiveはnote本編へ混ぜず、別コンテンツとして保持する。Story／Practice本文と確定タイトルはFinal Candidateから変更しない。Session Archiveは、Human-approvedの内容・一次ログ・順序・表現を保持したまま、段落・改行・終わり方を含む後発仕様との不一致箇所だけを必要最小限に修正し、全文を再監査する。Session Archiveの具体的な公開範囲とMembershipでの扱いは別途Human Decisionとし、未決のまま公開しない。

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
| SC-01 | ChatGPTへ詳細を指示してPPT作成を依頼しており、その後、短い依頼でBコース3回目のPPTを任せたいと考えていた。 | GPT Archive「AI組織づくりの地図を制作」2026-08-24の回顧発言。 | HC-02、HC-03 | 元会話の日付・Chat名・AI回答・採用または却下・成果物の状態。 |
| SC-02 | PowerPointを任せようとした際、AIが本人の教えたい内容を知らないという問題が出た。 | GPT Archive「AI組織づくりの地図を制作」2026-08-24の回顧発言。 | HC-04 | 当時のAI回答、その後の依頼・決定、作成物、問題への対応。 |

#### Source区分

| Source区分 | Source | 用途 | 取扱い |
|---|---|---|---|
| Evidence | GPT Archive「AI組織づくりの地図を制作」2026-08-24 | 初期PPT依頼に関する回顧発言 | 元会話との区別、引用範囲、発生日不明を明記する。 |
| Human Confirmation | 企画・壁打ちチャット「AI組織づくりの地図を制作」2026-08-24 | 初期目的、順番、PPT作成依頼の事実、AIが教える内容を知らないという問題の本人確認 | Evidenceと矛盾しない範囲で使用する。未確認のAI回答・採否・感情は補完しない。 |
| Repository Source | `07_Note_Production/01_Sections/AIORG-S01_AI基礎工事/00_Section制作台本.md` | S01-01の正式な企画・Source・未解決Decisionの管理 | 本Section制作台本を現行の管理Sourceとする。 |

### 役割分担

- **Story:** 読者が問題を自分事化し、実体験からSessionテーマへ入り、Practiceを読む理由を作る。note本編の前半を担う。
- **Practice:** Storyで生まれた問いを、読者が自分の仕事で試せる手順・テンプレート・確認点に変える。note本編の後半を担う。
- **Session Archive:** Storyでは圧縮する壁打ち、迷い、修正、失敗、感情、制作裏側を扱う別コンテンツ。note本編へ混ぜず、具体的な公開範囲とMembershipでの扱いは別途Human Decisionとする。
- **SNS投稿案:** 承認済みの公開対象を入口にし、note本編またはSession Archiveを代替しない。実投稿は別Gateで扱う。
- **AI:** Timelineからの事実抽出、Source Routing、Draft、QA、記録を担う。シリーズの思想・自己開示・価格・公開の決定は担わない。
- **人間（稲田美来）:** 企画の最終判断、史実の文脈確認、自己開示、価格、公開範囲、最終Publishを担う。

## 5. Section完成条件と価格キャリブレーション

- 全6 SessionにStory、Practice、Session Archiveが各1件存在する。Story／Practice本文と確定タイトルのHuman Final Checkは完了している。
- note本編は各SessionのStory＋Practiceを無改変で1記事へ分割する。Session Archiveは別コンテンツとして分離し、`00_note制作・公開システム.md` §2.2.3のAcceptance Criteriaに適合させる。
- 各Session Archiveは、後発Human-approved仕様と不一致の箇所だけを修正し、追記・修正・統合後に全文をAcceptance Criteriaで再監査する。
- note下書き保存前に、6本の本文抽出、ヘッダー画像との対応、Archive非混入を確認する。
- Story／Practice本文・確定タイトルのHuman Final Check、Session Archiveの修正後再Review、価格、公開範囲、公開日時、Publish承認を分離する。現在Statusは`Revision Required`とする。
- Session Archiveの公開範囲とMembershipでの扱い、各note本編の価格はHumanのみが決定する。
- 承認・公開・公開後記録までの状態遷移は`07_Note_Production/00_note制作・公開システム.md`に従う。

## 6. Production / QA / Approval

| Session ID | Source / Audit QA | Final Candidate / Output QA | Human Final Check | 価格 | Session Archive公開範囲 | 差し戻し対象・修正範囲 | 再Review | Publish承認 | 次アクション |
|---|---|---|---|---|---|---|---|---|---|
| S01-01 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-02 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-03 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-04 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-05 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |
| S01-06 | 既存Internal / Claude External Audit完了。新仕様Source QA完了 | 既存PASS履歴を保持 / Archive Revision Required | Story／Practice・タイトル完了。Archive再Review待ち | Pending | Pending / Human Decision Required | Session Archiveの後発仕様不一致（段落・改行・末尾を含む） | Pending | 未承認 | Archive限定修正後、全文Acceptance Criteria再監査 |

## 7. 公開後・Feedback

未着手。公開後に、各SessionについてHuman承認済み公開構成Profileの公開済み最終稿、公開成果物記録、ロードマップのStatus、Timelineへ追加する新たな史実、Feedback Candidateを記録する。未公開のSession Archiveを公開済みとして記録しない。
