# Section制作台本テンプレート

**Status:** Current / Operational v1.0
**使用先:** 実データ発生後、`01_Sections/<Section-ID>_<短い識別名>/00_Section制作台本.md` として複製して使用する。

## 1. 識別と状態

| Field | 記録 |
|---|---|
| Section ID / 名称 |  |
| Owner / 最終承認者 |  |
| Status | Planning / Production / Review / Approved / Scheduled / Published/Complete / Update Candidate |
| Next / Blocker |  |
| 対象読者・目的 |  |
| 公開範囲 |  |
| 価格仮説・承認状態 |  |
| 自己開示の候補・承認状態 |  |

## 2. Source Plan / Source QA

PipelineのSource PlanとSource Manifestを参照し、必読Source、現行性、実読、適用箇所、矛盾確認、G2結果を記録する。未解決のSource・価格・自己開示・公開範囲はProductionまたはPublishへ持ち込まない。

## 3. Story Hub

| Story ID | 事実 / 一次Evidence | 使用候補Session | 自己開示の可否 | 重複・未使用 | 注記 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Story Candidateは公開許可ではない。本人以外の個人情報、未確認の事実、センシティブな自己開示はHuman Decisionへ戻す。

## 4. Session設計と同時配布

| Session ID | Story（無料Hub） | 実践編（単品有料・無料部の詳細目次） | MS奮闘記（メンバーシップ限定） | Session全体を入口にしたSNS投稿案 | 状態 | 未解決Decision |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

各Sessionでは、Story・実践編・MS奮闘記の3記事を同時にProductionし、同一Session内の3記事を同時配布する。StoryはSessionの無料Hub、実践編は無料部分に詳細目次を掲示する単品有料記事、MS奮闘記は生の声・壁打ち・失敗・感情・制作裏側を扱うメンバーシップ限定記事とする。SNS投稿案はSession全体を入口にした別成果物として制作し、実投稿は `03_SNS展開基準.md` の媒体別Gateに従う。

## 5. Section完成条件と価格キャリブレーション

Sectionは、全Sessionの3記事がProduction・Output QAを通過し、タイトル、公開範囲、自己開示、公開順、各実践編の価格が人間承認できる状態で `Review` とする。3記事の公開確認と公開成果物記録の更新まで完了して `Published/Complete` とする。公開後の修正候補、反応、価格仮説の見直しは `Update Candidate` とし、既存正本を自動変更しない。

Section 1の全Sessionの実践編Draftが揃った後、各Sessionの実践編価格を単独で固定せず、Section 1内の全実践編を横並びにして、読者価値、深度、重複、無料Hubとの役割、既存商品の導線との整合をキャリブレーションする。AIは価格を決定・変更・設定しない。

## 6. Production / QA / Approval

| Session ID | G2 Source QA | 3記事のG4 Output QA | 本文・タイトル承認 | 実践編価格承認 | 自己開示承認 | 3記事公開承認 | 次アクション |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |  |

## 7. 公開後・Feedback

公開済み最終稿、公開成果物記録、全体ロードマップのStatus更新、Timelineへ追加すべき新たな史実、Feedback Candidateを記録する。記事の反応を、根拠・AI推論・人間判断に分け、OS／SOPの変更候補は新規TaskとしてPipelineへ戻す。
