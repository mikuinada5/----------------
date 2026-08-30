# Section制作台本テンプレート

**Status:** Current / Operational v1.4 / Marketing Review β
**使用先:** 実データ発生後、`01_Sections/<Section-ID>_<短い識別名>/00_Section制作台本.md` として複製して使用する。

## 0. 意味づけ・企画フェーズからの引き継ぎ

このSection制作台本は、Timelineの史実を起点にした意味づけ・企画フェーズで採用された企画の成果物である。意味づけ候補や非採用候補を永続保存する場所ではない。Timelineへ解釈を戻さず、この台本には採用した企画だけを記録する。

| Field | 記録 |
|---|---|
| 採用したTimeline史実・一次資料参照 |  |
| 採用した意味づけ / Series |  |
| 読者に届ける学び・順番 |  |
| 企画上の採用判断 |  |
| 引き継ぐHuman Decision |  |

## 1. 識別と状態

| Field | 記録 |
|---|---|
| Section ID / 名称 |  |
| Owner / 最終承認者 |  |
| Status | Planning / Production / Review / Decision Pending / Redesign Required / Revision Required / Approved / Scheduled / Published/Complete / Update Candidate |
| Next / Blocker |  |
| 対象読者・目的 |  |
| 公開構成Profile | 既定3記事 / Section固有Human Decision（本数、Story／Practiceの結合、別コンテンツを明記） |
| 公開範囲 |  |
| 価格仮説・承認状態 |  |
| 自己開示の候補・承認状態 |  |

## 2. Source Plan / Source QA

PipelineのSource PlanとSource Manifestを参照し、必読Source、現行性、実読、適用箇所、矛盾確認、G2結果を記録する。G0では、Draftを外部公開しない取扱範囲と最終承認者を記録する。未解決の必読SourceまたはG2 FAILはProductionへ持ち込まない。価格、自己開示範囲、最終的な公開範囲の未決はDraft Production、Human ReviewおよびMarketing Reviewを止めず、Publication DecisionとHuman Final Approvalへ記録する。

## 3. Story Hub

| Story ID | 事実 / 一次Evidence | 使用候補Session | 自己開示の可否 | 重複・未使用 | 注記 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Story Candidateは公開許可ではない。本人以外の個人情報、未確認の事実、センシティブな自己開示はHuman Decisionへ戻す。

## 4. Session設計と公開構成Profile

| Session ID | Story（無料Hub） | 実践編（単品有料・無料部の詳細目次） | MS奮闘記（メンバーシップ限定） | Session全体を入口にしたSNS投稿案 | 状態 | 未解決Decision |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

この表は既定3記事Profile用である。Section固有のHuman承認済み公開構成Profileがある場合は、列をそのProfileの本文・別コンテンツへ読み替え、結合順序と分離境界を明記する。AI Organization Series Section 1では、Story＋Practiceをnote本編1記事とし、Session Archiveを別コンテンツとして分離する。Session Archiveの公開範囲とMembershipでの扱いは別途Human Decisionとし、未決のまま本文へ混入・公開しない。SNS投稿案はSession全体を入口にした別成果物として制作し、実投稿は `03_SNS展開基準.md` の媒体別Gateに従う。

## 5. Section完成条件と価格キャリブレーション

Sectionは、全Sessionについて承認済み公開構成Profileの成果物がProduction・Output QAを通過した時点で `Review` とする。Human Review、Practiceの実機完遂、壁打ちおよび実素材をnote制作部が反映した内容完成稿を第2稿とし、同稿だけをMarketing Reviewへ渡す。Marketing Requirementの必要な修正・再監査を通過し、`Marketing Approved`とPublication Decisionが揃った稿を第3稿とする。Human Final Approvalを待つ状態を `Decision Pending`、G5承認済みの第3稿を最終稿／`Approved`とする。承認対象の公開確認と公開成果物記録の更新まで完了して `Published/Complete` とする。β期間中の公開ボタン直前停止は`Publication Prepared / Not Published`であり、`Published/Complete`にしない。

Human Final Approvalで一部が差し戻された場合は `Revision Required` とする。差し戻し理由、修正対象、所有者、再開条件を§6へ記録し、未変更の第3稿、Output QA、Human ReviewおよびMarketing Review結果は有効なまま保持する。変更が必要な成果物と影響Decisionだけを修正・再監査して `Decision Pending` へ戻す。公開後の修正候補、反応、価格仮説の見直しは `Update Candidate` とし、既存正本を自動変更しない。

Section 1の全Sessionについて第2稿が揃った後、Marketingは各Sessionの価格を単独で固定せず、Section 1内の全本文を横並びにして、読者価値、深度、重複、無料／有料範囲、既存商品の導線との整合をキャリブレーションする。AI Organization Series Section 1ではStory＋Practiceのnote本編を比較対象とする。Marketingは根拠とConfidenceを付けた推奨価格を作成するが、Human Final Approval前に最終価格として決定・設定しない。

## 6. Production / Content Review / QA / Approval

| Session ID | G2 Source QA | 初稿 / G4 | Human Review・実機完遂 | 第2稿 | Marketing substatus | 第3稿 | Human Final Approval / 最終稿 | Publication E2E | 次アクション |
|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  | Not Ready / Ready | Input Pending / Review / Revision Required / Approved / Human Decision Required | Not Ready / Ready | Pending / Approved / Returned | Not Started / Prepared Not Published / Published |  |

## 7. Marketing Review β / Publication Decision

Marketingは第2稿から開始し、本文を直接書き換えず、RequirementとPublication Decisionを作る。第2稿、Human完遂Reviewまたは必要な実素材が不足する場合は`Marketing Input Pending`で停止し、不足Input、所有者および再開条件を記録する。

詳細Reviewが未公開本文、販売前の内容または公開範囲未決情報を含む場合は、本文と同じ承認範囲のWork／Private Source／指定Archiveに保持する。Public Section制作台本には、安全なstatus、Run ID、locator、Decision要約、Gateおよび再開条件だけを記録し、未公開本文・長い引用・秘密情報を複製しない。

### 7.1 Review Run

| Field | 記録 |
|---|---|
| Review Run ID / Session ID |  |
| β Test Case ID | β検証対象の場合だけ記録。通常運用ではN/A |
| Marketing Input / 第2稿識別 |  |
| Fixed Input実読 | 対象第2稿、Target Reader、Story／Practice／別コンテンツ、Section内役割、公開構成Profile、既存Publication Rule |
| Decision-specific Required Source |  |
| Additional Source / 必要理由 |  |
| External Research | 対象、調査日、Source、Fact、Interpretation。未実施なら理由 |
| Requirement locator / 件数 | Must Fix / Nice to Improve / Human Decision Required |
| Marketing Gate | Marketing Input Pending / Marketing Revision Required / Marketing Approved / Human Decision Required |
| 第3稿識別 / 差分範囲 |  |
| Human Final Approval Record | 一括承認 / Decision Override＋理由 / Returned |
| Publication E2E | Not Started / Publication Prepared・Not Published / Published |
| Pipeline Gap / 再開条件 |  |

### 7.2 Requirement

| Requirement ID | 分類 | 問題とEvidence | 達成すべき状態 | 影響Decision | 適用Source | note制作側の実装・懸念 | 再監査範囲 | 状態 |
|---|---|---|---|---|---|---|---|---|
|  | Must Fix / Nice to Improve |  |  |  |  |  |  | Open / Resolved / Accepted Risk |

### 7.3 Publication Decision

| Decision | 推奨内容 | Decision Reason / Evidence | Confidence | Rule / Source | Human Override＋理由 |
|---|---|---|---|---|---|
| Price |  |  | High / Medium / Low |  |  |
| Free/Paid Boundary |  |  | High / Medium / Low |  |  |
| Campaign / Discount |  |  | High / Medium / Low |  |  |
| Publication Date/Time |  |  | High / Medium / Low |  |  |
| CTA / Priority |  |  | High / Medium / Low |  |  |
| Magazine |  |  | High / Medium / Low |  |  |
| Membership |  |  | High / Medium / Low |  |  |
| SNS Distribution |  |  | High / Medium / Low |  |  |
| Success Metrics / Evaluation Period |  |  | High / Medium / Low |  |  |

### 7.4 Learning Record

| Hypothesis | Decision | Decision Reason | Confidence | Success Metrics | Evaluation Period | Actual Result | Interpretation | Learning |
|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  | Human提供後に記録 | Factと分離 | 一度の結果で一般則化しない |

Human Final Approval時は、第3稿本文と一画面のPublication Decision Summaryを提示する。SummaryにはPrice＋Confidence、Free/Paid Boundary＋Confidence、Campaign、Publication Date/Time、CTA、Magazine、Membership、SNS Distribution、Marketing Gate、unresolved issues、Low Confidence Decisionsおよび今回検証するHypothesisを含める。

## 8. 公開後・Feedback

公開済み最終稿、公開成果物記録、全体ロードマップのStatus更新、Timelineへ追加すべき新たな史実、Feedback Candidateを記録する。記事の反応を、根拠・AI推論・人間判断に分け、OS／SOPの変更候補は新規TaskとしてPipelineへ戻す。
