# 07_Note_Production CHANGELOG

このファイルは、note制作・公開・SNS展開責任領域における意味のある変更履歴を記録する。現在の運用判断は各現行Sourceを正とする。

---

## 2026-08-26｜note Production責任領域の正式採用・Pipeline接続

### 概要

note制作・公開・SNS展開を既存AI Production Pipelineへ接続する独立した責任領域として `07_Note_Production/` を新設した。

### 追加した現行Source

- note制作・公開システム、実際に起きた出来事を時系列で保持する唯一のTimeline正本、全体ロードマップ正本、SNS展開基準、Section制作台本テンプレート、公開成果物記録テンプレート、入口READMEを追加した。
- Sectionを最上位制作単位とし、1 SessionをStory（無料Hub）・実践編（無料部分に詳細目次を掲示する単品有料）・MS奮闘記（生の声・壁打ち・失敗・感情・制作裏側を扱うメンバーシップ限定）の3記事として同時配布するモデルを定義した。SNS投稿案はSession全体を入口にする別成果物とした。
- Timelineは史実だけを扱い、Section／Sessionの現在地・制作状態・Next・Blockerは全体ロードマップ、Section制作台本、公開成果物記録を正とした。`noteやるよ`の現在地復元、`note記事書いて`のSection一括Production、Section完成条件、Section 1後の実践編価格横並びキャリブレーション、3記事の公開済み最終稿pathを接続した。

### 責任境界

- Source Router／Source QA／Output QA、Human Approval、Repository横断監査、Gitを複製せず、既存正式Sourceを呼び出す。
- AIは外部公開、価格、自己開示、Human Approvalを代行しない。
- Instagramは正式投稿または予約手段が利用可能な場合だけ自動化し、X／Threadsは投稿案の生成までとし、実投稿はユーザーの「投稿お願い」Gateを必要とする。

### Status

**Current / Operational v1.0**
