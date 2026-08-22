# CHANGELOG

## Ver1.4｜2026-08-23

### 変更

- Professionalの承認済み教育設計8ファイルについて、正式Sourceとして不適切な会話文、作業工程上の状態説明およびChatGPT固有の無効な引用記号を除去した。
- `00_Professional_マスター教育設計_Ver0.2.md` から、ChatGPT内でのみ有効であった引用記号22件を除去した。
- 除去した旧ChatGPT引用22件に対応する正式なファイル・ページ・節参照の復旧は、別工程で実施する未完了事項として扱う。現時点では推測による参照追加を行わない。
- `01_Professional_全体教育設計_Ver0.1.md` から、Markdown保存・制作・CHANGELOG更新へ進んでいない旨の作業工程メタ情報を除去した。
- Session 1〜6の承認済み教育設計から、正式Source本文に含める必要のない会話上の導入文、作業停止情報および初稿状態表示を除去した。
- 修正後、各ファイルを修正前原文と照合し、承認対象となった不要要素以外に差分がないことを確認した。
- 教育内容、教育構造、判断基準、到達目標、知識深度、問い、ワーク、家庭実践、感情設計、Session責任および承認状態には変更を加えていない。

### 理由

ChatGPT上で作成・承認された教育設計の原文には、会話上の応答、当時の作業工程を示す一時的な状態説明およびRepository外では解決できないChatGPT固有の引用記号が含まれていた。

承認済み教育内容を変更せず、現行の正式SourceとしてAIと人間が誤解なく参照できる本文へ整えるため。

### 影響範囲

- `01_Education/01_Courses/Aコース/02_Professional/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/01/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/02/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/03/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/04/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/05/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions/06/00_Design`

CourseOS、主任講師AI Core、Primary Sources、教材制作基準および制作成果物には変更を加えていない。

### 承認状態

**🟢 正式Source本文整理・差分監査完了**

Professionalマスター教育設計、全体教育設計およびSession 1〜6の教育上の承認状態は変更しない。

---

## Ver1.3｜2026-08-22

### 変更

- 2026-08-12にChatGPT上で正式出力され、直後に承認された `Aコース Professional全6回 マスター教育設計書 Ver0.2` の原文をChatGPTデータアーカイブから回収した。
- 回収した原文を、内容を再構築・補完・修正せず、`00_Design/00_Professional_マスター教育設計_Ver0.2.md` として正式配置した。
- 既存の `00_Professional_全体教育設計_Ver0.1.md` は内容を変更せず、`01_Professional_全体教育設計_Ver0.1.md` へ名称変更した。
- `00_Design` 内の参照順序を、以下として明示した。
  - `00_Professional_マスター教育設計_Ver0.2.md`：各Session設計に先立つ、Professional全6回の上位骨格
  - `01_Professional_全体教育設計_Ver0.1.md`：マスター教育設計および承認済みSession 1〜6を統合した、制作・レビュー時の横断参照文書
- マスター教育設計、全体教育設計、Session 1〜6の責任は統合せず、既存の責任分離を維持した。

### 理由

ProfessionalのCHANGELOG、全体教育設計およびSession 1〜6は、承認済みのProfessionalマスター教育設計 Ver0.2を正式Sourceとして参照していたが、その実ファイルがRepository上に存在していなかった。

欠落していた正式Sourceの原文を回収して本来の責任位置へ配置し、AIおよび人間が、各Session設計に先立つマスター教育設計と、全Session完成後の全体教育設計を別責任の現行Sourceとして迷わず参照できる状態へ戻すため。

今回の変更は、既存の教育内容・教育判断・承認状態を変更するものではない。

### 影響範囲

- `01_Education/01_Courses/Aコース/02_Professional/00_Design`
- Professionalマスター教育設計 Ver0.2と全体教育設計 Ver0.1の正式配置および参照順序
- Professionalの制作・レビュー時に参照する現行Source構成

Session 1〜6の教育設計、CourseOS、主任講師AI Core、教材制作基準および制作成果物には変更を加えていない。

### 承認状態

**🟢 欠落Source回収・正式配置完了**

`00_Professional_マスター教育設計_Ver0.2.md` と `01_Professional_全体教育設計_Ver0.1.md` は、異なる責任を持つ現行の承認済み教育設計として扱う。

---

## Ver1.2｜2026-08-13

### 変更

- 承認済みのProfessional マスター教育設計 Ver0.2、Session 1〜6教育設計、およびProfessional全6回の最終横断監査結果を統合し、`Aコース Professional 全体教育設計 Ver0.1` を作成した。
- `Aコース Professional 全体教育設計 Ver0.1` は監査で正式承認され、追加修正不要と判定された。
- 承認済み版を `02_Professional/00_Design` 配下へ配置する正式な全体教育設計として確定した。
- 本文書は、Professional全体について以下を横断的に保持する教育設計書とした。
  - Professionalの教育上の位置づけ
  - 対象と教育範囲
  - Professional Mission
  - 3か月後の最終到達
  - Professionalで目指さないこと
  - 全6回を貫く教育原則
  - 「見る → 関わる → 支える → 翻訳する → 判断する → 続ける」の学習ストーリー
  - Session 1〜6の教育責任と接続
  - 知識と関係性の統合
  - 自己決定と養育責任
  - 発達に応じた知識の翻訳
  - 家庭実践と学習循環
  - 修復
  - 援助要請
  - 感情設計・心理的安全性
  - Primary Sourcesと根拠管理
  - Professional終了後への接続
  - 制作・レビュー時の非変更領域
- `Aコース Professional 全体教育設計 Ver0.1` は、Professional マスター教育設計 Ver0.2またはSession 1〜6の詳細教育設計を置き換えるものではなく、確定済みProfessional全体を横断参照する統合文書として位置づけた。
- 各Sessionの90分構造、Block責任、問い、ワーク、ケース、家庭実践、個別Primary不足フラグ等の詳細仕様は、引き続き各Sessionの承認済み教育設計を正とする。
- Professionalの教育設計段階で必要なPrimaryは充足済みであるという既存判定を維持した。
- 制作段階で具体的な医学・医療情報、日本法制度、日本の相談・支援制度等を正式教材へ掲載する場合に追加Primaryを確認する既存方針を維持した。
- 今回の統合に伴い、Professional マスター教育設計 Ver0.2、Session 1〜6教育設計、CourseOSその他上位基準への変更は行っていない。

### 理由

Professional教育設計フェーズの正式完了後、マスター教育設計とSession 1〜6の承認済み詳細設計が個別ファイルとして確定している一方、制作・レビュー工程でProfessional全体のMission、学習線、家庭実践循環、非変更領域等を横断的に参照できる確定文書が必要となった。

そのため、新しい教育設計を追加するのではなく、すでに承認済みのマスターVer0.2、Session 1〜6、最終横断監査結果を統合し、**「確定したAコース Professionalが、一本の教育プログラムとして何であるか」**を保持する `Aコース Professional 全体教育設計 Ver0.1` を正式化した。

本統合は既存設計の再設計・上書きではなく、Professional全体の確定状態を横断参照可能にするための責任整理である。

### 影響範囲

- `01_Education/01_Courses/Aコース/02_Professional/00_Design`
- Aコース Professional 全体の制作・レビュー時に参照する横断教育設計
- Professional マスター教育設計 Ver0.2とSession 1〜6承認済み教育設計の参照関係

Aコースの教育思想・到達目標・知識基準・カリキュラム等を定める `00_CourseOS` の内容自体は変更していない。

Professional マスター教育設計 Ver0.2およびSession 1〜6の承認済み教育設計にも変更を加えていない。

ルートCHANGELOG、CourseOS CHANGELOG、Front CHANGELOG、各Session教育設計、制作物には変更を加えていない。

### 承認状態

**🟢 Aコース Professional 全体教育設計 Ver0.1 正式承認・配置確定**

`Aコース Professional 全体教育設計 Ver0.1` は、Professional全体の確定した教育プログラム像を横断的に保持する承認済み教育設計として扱う。

Professional教育設計フェーズは引き続き正式完了状態とし、次工程は制作フェーズとする。

---

## Ver1.1｜2026-08-13

### 変更

- Professional マスター教育設計 Ver0.2を承認済み版として確定した。
- Session 1〜6の教育設計をすべて承認済みとし、承認済み教育設計をProfessional配下へ配置した。
- Session単位の個別完成ではなく、Professional全6回の教育設計完成を一つの節目として確定した。
- 全6回完成後、Professional全体を一つの教育プログラムとして最終横断監査した。
- 最終横断監査では、以下を確認した。
  - ProfessionalマスターVer0.2との整合
  - Session 1〜6の責任分界
  - 重複・抜け
  - 知識深度・学習負荷
  - 家庭実践の循環
  - 感情設計
  - Primary Sources／不足フラグ
  - 「見る → 関わる → 支える → 翻訳する → 判断する → 続ける」の学習線
  - Professional最終到達との整合
- 最終横断監査の結果、**🟢 正式完了可能**と判定した。
- 以下について問題なしと判定した。
  - 上位基準との矛盾：なし
  - Session責任分界の破綻：なし
  - 重大な教育上の抜け：なし
  - 学習阻害となる不要な重複：なし
  - 家庭実践循環の断絶：なし
  - 重大な感情設計上の問題：なし
  - 教育設計確定を妨げるPrimary不足：なし
  - Professional最終到達を阻害する構造：なし
- 以上をもって、**Aコース Professional 教育設計フェーズ正式完了**とした。
- 承認済みマスターVer0.2およびSession 1〜6について、今回の最終横断監査を理由とする追加修正は行わない。
- 教育設計段階で必要なPrimaryは充足していることを確認した。
- 今後の制作段階で、以下の具体的内容を正式教材へ掲載する場合は、該当箇所について追加Primaryを確認する方針とした。
  - 具体的な医学・医療情報
  - 日本法制度
  - 日本の相談・支援制度
  - 性被害・虐待対応
  - 受診目安
  - 具体的相談先
- 上記の追加Primary確認は教育設計上の未完了事項ではなく、制作段階における根拠管理として扱う。
- Professional教育設計フェーズ完了後は制作フェーズへ移行する。
- 制作フェーズでは、まずSession 1について以下の成果物を制作し、制作後レビューを行う。
  - PPT
  - 講師台本
  - ワークシート
  - 受講者配布資料
  - その他、承認済み教育設計に基づく必要成果物
- Session 1で制作・レビュー・必要修正を経て制作パターンを確定した後、Session 2〜6へ展開する。
- 今回のCHANGELOG更新時点では、今後の制作物を完成済みとは扱わない。

### 理由

Professional全6回の教育設計が揃い、各Session単体の承認だけでなく、全6回を一つの教育プログラムとして最終横断監査した結果、マスター教育設計、Session間の責任分界、学習順序、知識深度、家庭実践、感情設計、Primary Sourcesの扱い、最終到達まで一貫して成立していることが確認された。

そのため、Session 1〜6を個別の変更履歴として6件に分けるのではなく、**「Professional全6回の教育設計確定・最終横断監査完了・教育設計フェーズ正式完了」**をProfessional全体として意味のある一つの節目として記録する。

また、今後の制作段階で必要となる可能性がある医学・法制度・支援制度等の追加Primary確認は、教育設計上の不足ではなく、具体的教材文言を確定する際の根拠管理として区別する。

### 影響範囲

- `01_Education/01_Courses/Aコース/02_Professional/00_Design`
- `01_Education/01_Courses/Aコース/02_Professional/01_Sessions`
- AコースProfessional 全6回の承認済み教育設計
- Professional教育設計フェーズから制作フェーズへの工程移行

Aコースの教育思想・到達目標・知識基準・カリキュラム等を定める `00_CourseOS` の内容自体は変更していない。

ルートCHANGELOG、CourseOS CHANGELOG、Front CHANGELOG、各Session教育設計、制作物には変更を加えていない。

### 承認状態

**🟢 Aコース Professional 教育設計フェーズ正式完了**

Professional マスター教育設計 Ver0.2およびSession 1〜6の教育設計はすべて承認済みであり、今回の最終横断監査を理由とする追加修正は行わない。

次工程は制作フェーズとし、まずSession 1の制作・制作後レビューから開始する。

---

## Ver1.0｜2026-08-11

### 変更

- Aコース専門講座を、全6回で一つの教育プログラムとして管理する `02_Professional` を新設した。
- 専門講座全体を以下の責任単位に整理した。
  - `00_Design`：全6回を横断する承認済み教育設計
  - `01_Sessions`：第1回〜第6回の各実施単位
  - `02_Review`：全6回を横断する制作後レビュー・品質監査
  - `03_Archive`：現行ではない旧版成果物
- `01_Sessions` 配下に第1回〜第6回の管理単位を作成した。
- 各Sessionを以下の共通構造で管理する方針とした。
  - `00_Design`：当該Sessionの教育設計
  - `01_Outputs`：当該Sessionで実際に使用する成果物
  - `02_Review`：当該Sessionの制作後レビュー・承認記録
- 各Session単位のCHANGELOGは現時点では設置せず、専門講座に関する変更履歴を本CHANGELOGへ集約する方針とした。

### 理由

Aコース専門講座は、各Sessionが独立した実施単位である一方、全6回を通して一つの到達状態を目指す教育プログラムである。

そのため、

- 各Sessionが自身の教育設計に準拠して成立しているか
- 全6回を通した学習順序・重複・抜け・知識深度・感情設計・最終到達目標への接続が成立しているか

を別の階層で設計・監査できる構造とした。

また、各Sessionに個別CHANGELOGを設置すると管理が過度に細分化されるため、現時点では専門講座全体のCHANGELOGへ履歴を集約する。

### 影響範囲

- `01_Education/01_Courses/Aコース/02_Professional`
- Aコース専門講座 全6回の設計・制作・レビュー運用

Aコースの教育思想・到達目標・知識基準・カリキュラム等を定める `00_CourseOS` の内容自体は変更していない。

### 承認状態

**🟢 現行構造として採用**

現時点では専門講座の管理構造を確定した段階であり、全6回のマスター教育設計および各Sessionの教育設計・成果物・レビュー記録は今後制作・配置する。

---

## 運用ルール

- 本CHANGELOGは、Aコース専門講座全体および各Sessionに関する変更履歴を記録する。
- Aコース全体の教育思想・基準等の変更は `00_CourseOS/CHANGELOG.md` に記録する。
- フロント講座の変更は `01_Front/CHANGELOG.md` に記録する。
- Session単体の変更も、当面は本CHANGELOGに対象Sessionを明記して記録する。
- Sessionごとの変更履歴が増え、本CHANGELOGでの追跡が困難になった場合に限り、Session別CHANGELOGへの分離を検討する。
- 現行ではない旧版ファイルは `03_Archive` へ移動する。
- CHANGELOGは旧版ファイルの保管場所ではなく、「何を・なぜ変更したか」を追跡するための記録として扱う。
