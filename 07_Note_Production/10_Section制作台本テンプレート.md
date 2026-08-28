# Section制作台本テンプレート

**Status:** Current / Operational v1.3
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
| Status | Planning / Production / Review / Decision Pending / Revision Required / Approved / Scheduled / Published/Complete / Update Candidate |
| Next / Blocker |  |
| 対象読者・目的 |  |
| 公開構成Profile | 既定3記事 / Section固有Human Decision（本数、Story／Practiceの結合、別コンテンツを明記） |
| 公開範囲 |  |
| 価格仮説・承認状態 |  |
| 自己開示の候補・承認状態 |  |

## 2. Source Plan / Source QA

PipelineのSource PlanとSource Manifestを参照し、必読Source、現行性、実読、適用箇所、矛盾確認、G2結果を記録する。G0では、Draftを外部公開しない取扱範囲と最終承認者を記録する。未解決の必読SourceまたはG2 FAILはProductionへ持ち込まない。価格、自己開示範囲、最終的な公開範囲の未決はDraft ProductionとReviewを止めず、Publish前Human Decisionとして記録する。

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

Sectionは、全Sessionについて承認済み公開構成Profileの成果物がProduction・Output QAを通過した時点で `Review` とする。Reviewが完了し、本文、タイトル、公開範囲、自己開示、公開順、価格についてPublish前Human Decisionを待つ状態を `Decision Pending` とする。すべてのPublish前Human Decisionが承認され、必要な再ReviewがPASSした時だけ `Approved` とする。承認対象の公開確認と公開成果物記録の更新まで完了して `Published/Complete` とする。

Publish前Human Decisionで一部が差し戻された場合は `Revision Required` とする。差し戻し理由、修正対象、所有者、再開条件を§6へ記録し、未変更のDraft、Output QAおよびReview結果は有効なまま保持する。変更が必要な成果物だけを修正し、修正範囲だけを再Reviewして `Decision Pending` へ戻す。公開後の修正候補、反応、価格仮説の見直しは `Update Candidate` とし、既存正本を自動変更しない。

Section 1の全Sessionについて承認済み公開構成Profileの本文Draftが揃った後、各Sessionの価格を単独で固定せず、Section 1内の全本文を横並びにして、読者価値、深度、重複、無料／有料範囲、既存商品の導線との整合をキャリブレーションする。AI Organization Series Section 1ではStory＋Practiceのnote本編を比較対象とする。AIは価格を決定・変更・設定しない。

## 6. Production / QA / Approval

| Session ID | G2 Source QA | Profile成果物 / G4 Output QA | Review / Human Final Check | 価格 | 自己開示・公開範囲 | 差し戻し対象・修正範囲 | 再Review | Publish承認 | 次アクション |
|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  | Pending / Approved / Returned | Pending / Approved / Returned |  | Not Required / Pending / PASS |  |  |

## 7. 公開後・Feedback

公開済み最終稿、公開成果物記録、全体ロードマップのStatus更新、Timelineへ追加すべき新たな史実、Feedback Candidateを記録する。記事の反応を、根拠・AI推論・人間判断に分け、OS／SOPの変更候補は新規TaskとしてPipelineへ戻す。
