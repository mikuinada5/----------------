# note制作・公開システム v2.2 差分正本

**Status:** Current / Canonical Delta / Operational
**Effective date:** 2026-09-02
**Base Source:** `07_Note_Production/00_note制作・公開システム.md` v2.1

## 0. 適用ルール

本Sourceは、v2.1を全面置換するものではなく、2026-09-02までのHuman Decisionで確定した差分だけを正本化する。

- 本Sourceとv2.1が矛盾する場合、**本Sourceが対象差分について優先する**。
- 本Sourceで変更していないv2.1の規則、Gate、責任分離、QA、Publication Decision、Human Approval、記録仕様はそのまま有効とする。
- 本Sourceの差分を理由に、対象外の本文、価格、公開日、CTA、自己開示範囲、Membership設定その他を推測変更しない。

---

## 1. AI Organization Series Section 1 公開構成Profileの差分

v2.1の「各Sessionのnote本編はStory＋Practiceを結合した1記事とする」というSection 1共通既定は、以下のHuman Decisionで上書きする。

### S1-1

- 従来どおり、Story＋Practiceを結合した公開構成を維持する。
- Session Archiveは別コンテンツとして扱う。

### S1-2以降

- **Story、Practice、Session Archiveを独立した記事／成果物として扱う。**
- StoryとPracticeを自動的に再結合しない。
- Session ArchiveをStoryまたはPracticeへ混在させない。
- 各記事は、それぞれ固有のタイトル、Header Asset、Publication Decision、公開状態を持てる。
- 価格、無料／有料境界、Membership範囲、公開日時、CTAその他の商用・公開判断は、既存のHuman Approval Gateを継続し、AIが補完しない。

### 役割

- **Story:** 読む。問題の自分事化、実体験、意味づけ、Sessionテーマへの導入。
- **Practice:** やる。読者が実行できる手順、確認点、成果物取得。
- **Session Archive:** 裏側を見る。実際の会話、失敗、混乱、感情、判断過程、生ログ。

この差分はS1-2以降のPublication Profileに適用し、S1-1の既存公開構成を遡及変更しない。

---

## 2. Publication Asset Gate

Human-approved本文だけでは `READY_FOR_PUBLISH` としない。公開単位に必要なPublication Assetが揃い、本文との対応関係が確認できて初めて公開待機状態へ進める。

標準状態遷移は以下とする。

`HUMAN_APPROVED -> ASSET_READY -> READY_FOR_PUBLISH -> PUBLISHED`

必要Assetが欠落、不一致、未承認の場合は `CONTENT_APPROVED / ASSET_PENDING` でSTOPする。Repository Writer、Publisherその他のAIは、欠落Assetを推測生成、別画像で代用、無断再設計してはならない。

### 必須確認

各公開単位について、少なくとも以下を確認する。

- Human-approved本文が存在する。
- Story / Practice / Session Archiveの種別が明示されている。
- 必須Header Assetが存在する。
- Header Assetが正しいSection／Session／記事／versionへ紐づいている。
- Header上のS番号、タイトル、記事種別が承認済みPublication Metadataと整合している。
- Assetの保存先または参照先が一意に追跡できる。
- Human未承認の価格、CTA、公開日時、公開範囲をAsset制作や正本化の過程で確定しない。

### Section Story Header Template

- Storyの役割は「読む」。
- 基本デザインは**紺系**のStoryテンプレートを維持する。
- レイアウト、ラベル位置、文字階層、余白、シリーズとしての見た目を原則固定する。
- 各記事で変更してよい主対象はS番号、承認済みタイトル／サブタイトル、小さな記事固有モチーフとする。
- 毎回独立した別デザインへ作り直さない。

### Section Practice Header Template

- Practiceの役割は「やる」。
- 基本デザインは**緑系**のPracticeテンプレートを維持する。
- レイアウト、ラベル位置、文字階層、余白、シリーズとしての見た目を原則固定する。
- 各記事で変更してよい主対象はS番号、承認済みタイトル／サブタイトル、小さな実践モチーフとする。
- 毎回独立した別デザインへ作り直さない。

### Session Archive Header Family

- Archiveの役割は「裏側を見る／生ログ」。
- Story／Practiceへ視覚統一せず、**手描き・生ログ・制作裏側の異物感を意図的に維持する第三のVisual Family**とする。
- Story＝読む、Practice＝やる、Archive＝裏側を見る、の役割差を一覧表示でも識別できることを優先する。

Story／PracticeのTemplate Familyを大きく変更する場合はHuman Reviewを要する。

---

## 3. Smartphone / Chat Publication Interface Rule

Human ApprovalおよびPublication Pipelineの起動権限は、PCかスマートフォンかという端末種別では決まらない。**認証済みのHumanとのChat上で、対象、意図、公開範囲が一意に判断できる明示指示は、スマートフォンからでも既存Human Decisionとして受理できる。**

したがって、必要なSource、本文、Asset、Publication Decisionおよび各Gateがすべて満たされている場合、HumanはスマートフォンのChatから公開準備または公開Pipelineを開始できる。

ただし以下を維持する。

- スマートフォン経由であることを理由にHuman Approval Gateを省略しない。
- 曖昧な「アップして」「出して」だけで対象記事、公開範囲、価格、Membership、公開日時等を推測しない。正式Sourceおよび直近のHuman Decisionから一意に解決できない場合はSTOPする。
- ChatはHuman Interfaceであり、Canonical Repositoryの代替にはしない。
- Chat上の決定で正式Source更新が必要な場合は、Repository Integrationを通して正本化してから後続工程が参照する。
- スマートフォンからの指示でも、Repository Writer / Publisher / Browser Automationは既存の権限分離、QA、STOP条件、Publication Transaction、Post-Publication Verificationをそのまま適用する。
- 正式SourceとPublication Gateがすべて満たされている場合、HumanがGitHub UIやローカルファイル操作を手動で経由することを必須条件にしない。

---

## 4. S1-2への適用

S1-2は本差分正本の最初の適用対象とする。

- Story：独立記事。Story Header Templateを使用。
- Practice：独立記事。Practice Header Templateを使用。
- Session Archive：独立記事。既存のArchive imageを使用。
- Story／Practice Header Assetが未確定または未登録の場合、本文がHuman-approvedでも `ASSET_PENDING` でSTOPする。
- 3記事それぞれのPublication Decisionが確定するまで、価格、公開範囲、公開日時その他を自動確定しない。
- 必要条件が揃った後は、スマートフォンChatからの明示指示を起点として既存E2E Publication Pipelineへ接続できる。

---

## 5. 正本関係

本Sourceが優先上書きする対象は以下のみ。

1. Section 1のS1-2以降におけるStory＋Practice結合既定。
2. Section記事のPublication Asset GateとHeader Visual Family。
3. スマートフォンChatをHuman Interfaceとして利用する場合のPublication起動規則。

上記以外は `00_note制作・公開システム.md` v2.1を継続して正とする。
