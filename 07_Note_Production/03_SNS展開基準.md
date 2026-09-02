# SNS展開基準 v1.2

**Status:** Current / Operational v1.2
**Scope:** noteの承認済み記事を起点とするSession単位のSNS展開

## 1. 原則

SNS展開はSession単位で行う。既定の同時配布単位はStory（無料Hub）・実践編（単品有料）・MS奮闘記（メンバーシップ限定）の3記事とするが、Section制作台本にHuman承認済み公開構成Profileがある場合は、そのProfileを正とする。SNS投稿案は承認済み公開構成ProfileのSession全体を入口にして制作する**別成果物**であり、本文・別コンテンツ・投稿案を相互に代替しない。SNS投稿案は実投稿を意味しない。

AI Organization Series Section 1では、S1-1はStory＋Practiceのnote本編1記事、S1-2以降は独立したStory／Practice記事のうち公開承認された記事をSNS導線候補とする。Session Archiveは公開範囲とMembershipでの扱いが別途Human承認されるまで、SNSで公開済み・配布対象として扱わない。

本文・SNS案・公開範囲・自己開示・価格の承認は既存のHuman Approval Gateを正とする。SNSは既存のOutput QA、公開済み最終稿、媒体仕様に従う。公開済みでない本文をSNSの参照正本にしない。

## 2. 媒体別の実行境界

| 媒体 | AIが制作できる範囲 | 実投稿の条件 | 接続不可／仕様未登録時 |
|---|---|---|---|
| Instagram | 投稿案、キャプション、必要な投稿パッケージ。利用可能な正式投稿または予約手段が確認できる場合のみ、その承認範囲で実行 | 人間承認、対象アカウント・投稿内容・日時・正式手段・権限の確認 | `HUMAN DECISION REQUIRED` または `Not Implemented` と記録し、投稿案だけを渡す |
| X | 投稿案の生成まで | ユーザーの明示した「投稿お願い」Gate、および利用可能な正式手段・権限 | 実投稿しない。`Not Posted — connection unavailable` を記録 |
| Threads | 投稿案の生成まで | ユーザーの明示した「投稿お願い」Gate、および利用可能な正式手段・権限 | 実投稿しない。`Not Posted — connection unavailable` を記録 |
| その他 | 媒体仕様が正式登録されるまで制作・実投稿を開始しない | Human Decisionと媒体別仕様・接続設計 | `HUMAN DECISION REQUIRED` |

Instagramの「自動化」は、正式な投稿／予約手段、認証、アカウント権限、投稿対象、承認範囲、エラー時の復旧が利用可能で確認できる場合に限る。存在しない接続を推定せず、予約済み・投稿済みと偽らない。

## 3. Session配布パッケージ

各Sessionで次を揃える。

1. 当該Sectionの承認済み公開構成Profileに基づく、公開承認済みまたは公開前の承認候補成果物
2. SNS投稿案（必要な本数、各案の目的、媒体候補、CTA、注意点）
3. 媒体別の実行状態（Draft / Awaiting Approval / Scheduled / Posted / Not Posted / Not Implemented）
4. 実投稿があればURL・日時・確認結果、なければ未実施理由

SNS案は、医療・法律・金融等の正確性や安全性を、短文化・拡散性・トレンドより優先する。不安、恐怖、罪悪感を不適切に利用して販売へ誘導しない。

## 4. 実投稿Gateと記録

X／Threadsは、ユーザーが「投稿お願い」と明示するまで実投稿しない。Instagramでも、正式手段があってもHuman Approvalに含まれない対象・日時・内容は投稿しない。

実投稿後は、`11_公開成果物記録テンプレート.md` に基づき、媒体、投稿URL、日時、投稿状態、接続状態、検証結果、失敗時の復旧先を記録する。投稿失敗・重複投稿・表示異常は、外部操作の結果として公開成果物記録を `Recovery Required` とし、全体ロードマップまたはSection制作台本のNext／Blockerを更新して、人間判断または既存Pipelineの復旧工程へ戻す。
