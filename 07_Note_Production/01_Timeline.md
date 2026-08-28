# note Production Timeline

**Status:** Current / Operational v1.1
**Role:** 一次資料から抽出した実際の出来事を時系列で保持する、note制作における唯一の史実Source

## 運用規則

このファイルは、GPTログ、Codexログ、音声、壁打ち、Git履歴、CHANGELOGその他の一次資料から抽出した実際の出来事と、その参照情報を時系列で保持する。Timelineは、一次資料そのものではなく、note制作における史実の正本である。原本は原本の保管先に保持し、会話全文・音声全文その他の原文をTimelineへ複製しない。

企画上の予定、Section／Sessionの現在地、制作状態、優先順位、Next、Blocker、公開判断、自己開示判断、Series候補その他の解釈は扱わない。これらは `02_全体ロードマップ.md`、Section制作台本、公開成果物記録またはそれぞれの責任Sourceを正とする。本文、公開URL、詳細な承認記録、SNS本文はそれぞれの実データ正本へ置く。

| 発生日 / 時期 | 抽出した史実 | 一次資料識別子 | 一次資料参照位置 | 抽出日 | 確認状態 | 利用状態 | 使用先Section / Session | 最終更新日 |
|---|---|---|---|---|---|---|---|---|
| 2026-08-07 | ブランドOS初版が完成した。 | Git commit `4f12008` | commit subject: `Ver1.0 ブランドOS初版完成` | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / Story Hub | 2026-08-26 |
| 2026-08-07 | 主任講師AIの教育思想、教育設計原則、感情設計、問い設計が確立された。 | Git commit `b5bf181` | commit subject: `主任講師AIの教育思想を確立（概要・教育設計原則・感情設計・問い設計）` | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / S01-01 | 2026-08-26 |
| 2026-08-12〜13 | AコースProfessional Session 1の承認済み教育設計が追加され、Professional教育設計完了が更新ログに記録された。 | Git commits `9ce5dea`, `d11243d` | respective commit subjects | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / S01-02 | 2026-08-26 |
| 2026-08-20 | 全コース共通教材制作基準が、独立した責任単位へ配置された。 | Git commit `f85657e` | commit subject: `refactor: 全コース共通教材制作基準を独立責任単位へ配置` | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / S01-02 | 2026-08-26 |
| 2026-08-22〜23 | 分割Brand OS、Voice OS、Human-in-the-loop運用原則、AI作業環境・工程接続原則が正式採用された。 | Git commits `3035621`, `4c70f1e`, `6f121d1`, `88546d8` | respective commit subjects | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / S01-03 | 2026-08-26 |
| 2026-08-26 | AI Production PipelineとRepository横断監査、Human OSとWriting Style OSの正式運用接続、note制作・公開・SNS展開の正式運用領域が順に追加された。 | Git commits `22ebeb6`, `c629759`, `88136c0`, `080a572` | respective commit subjects | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / S01-04、S01-05 | 2026-08-26 |
| 2026-08-26 | AI組織シリーズのSectionは技術分類ではなく「実現したい仕組み（プロジェクト）」であり、AI組織シリーズは「これをやりたい」からAIとの反復を経て結果としてAI組織になった物語として扱う、という設計が共有された。 | Codex Work `AI組織シリーズ制作｜正式運用開始` | 本Workのユーザー指示「今回壁打ちで新たに判明した設計」「AI組織シリーズの基本思想」 | 2026-08-26 | 確認済み | 制作済み | AIORG-S01 / Section設計 | 2026-08-26 |
| 2026-08-28 | AI Organization Series Section 1は全6 Sessionとし、各SessionのStory＋Practiceをnote本編1記事、Session Archiveを別コンテンツとして扱う方針がHuman Decisionとして確定した。Human Final Checkは完了し、Session Archiveの具体的な公開範囲とMembershipでの扱いは別途Human Decisionとされた。 | Codex Task `AI Organization Series Section 1 公開準備工程` | ユーザー指示「公開準備工程の整合性修正へ進んでください」内 `Human Decision` 1〜6 | 2026-08-28 | 確認済み | 制作済み | AIORG-S01 / S01-01〜S01-06 / 公開準備 | 2026-08-28 |

### 記録規則

- 事実と推論を分ける。一次資料から確認できる出来事だけを「抽出した史実」に記録し、制作案、意味づけ、予定を混在させない。
- `一次資料識別子`は原本を一意に特定し、`一次資料参照位置`は会話日・スレッド・発言範囲・録音位置・コミットまたはCHANGELOG節など、原本内の該当箇所へ戻れる情報を記録する。
- `確認状態`は、少なくとも`確認済み`または`要確認`を記録する。`要確認`の行を、確認済みの史実または制作入力として扱わない。
- `利用状態`は、`未使用`または公開済み／制作済み成果物へ実際に用いた事実を記録する。候補化だけでは使用済みにしない。保留、公開判断、自己開示、Series候補その他の企画・解釈上の状態は記録しない。
- Timelineが未生成または未更新であることを、史実が存在しない根拠にしない。利用可能な一次資料を確認してから、生成・更新の可否を判断する。
