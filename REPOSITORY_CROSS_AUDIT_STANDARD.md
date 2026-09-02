# Repository横断監査基準 v1.1

**Document type:** Repository Governance Standard<br>
**Status:** Current / Operational v1.1<br>
**Scope:** Repository全体へ影響する正式Sourceの新規追加・更新・移動・廃止<br>
**Purpose:** 正式Sourceを「置いただけ」にせず、既存責任・参照構造・運用・履歴へ一貫して接続する

---

## 1. 目的と責任境界

本基準は、Repository全体へ影響する正式Sourceの変更について、構造、責任、Source、運用接続、変更波及およびGit反映を横断確認する。

本基準は、個別Sourceの内容上の妥当性、教育成果物の品質、Source実読、公開可否または人間承認を代替しない。これらはそれぞれの責任Sourceを正とする。

| 事項 | 正とするSource | 本基準の確認責任 |
|---|---|---|
| 人間承認・停止・再承認・完了 | `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md` | 必要な承認記録と停止条件が接続されているか |
| AI組織の役割・権限・受け渡し | `AI_ORGANIZATION.md` | 役割の重複・侵食・未接続がないか |
| Repository構造・Archive・Git・CHANGELOG | `REPOSITORY_RULES.md` | 配置・命名・現行正本・履歴・Git準備が適合するか |
| Brand、Voice、Education、制作・品質 | 各専門Source | 既存責任を重複・上書き・空白化していないか |
| Source Router・Source QA・Production工程 | `AI_PRODUCTION_PIPELINE.md` | 当該変更が必要なSourceと運用へ接続されているか |

本基準は新しいAI組織上の役職、承認者、品質基準またはSource階層を創設しない。監査でそれらが必要と判明した場合は、**HUMAN DECISION REQUIRED** とする。

---

## 2. 適用開始条件

次のいずれかを行う場合、Repository Integration前およびGit Gate前に本監査を実施する。

- Repository全体または複数の責任領域へ影響する正式Sourceを新規追加する
- AI Organization、Human-in-the-loop、Repository Rules、Brand OS、Voice OS、Education Core、共通制作基準、共通SOPを変更する
- canonical path、参照入口、責任境界、Version／Status、ArchiveまたはCHANGELOGの関係を変更する
- 複数Sourceの必読関係、Source QA、Output QAまたは変更波及の運用を変更する

単一の成果物だけに閉じ、既存基準が要求するレビューで十分に保証される軽微変更には、本監査を追加しない。

---

## 3. 監査Inputと記録

監査者は、少なくとも次を確認する。

- 変更対象と目的、Approval Record、対象branch・commit範囲
- 変更前後の現行Source、依存Source、INDEX／README／参照ガイド
- `git status`、`git diff`、必要に応じて `git diff --cached`
- 関連するCHANGELOG、Version／Status evidence、Archiveの有無

監査結果は、対象のIntegration Manifestまたは同等のQA記録に、対象、確認Source、判定、Issue、修正、残存リスク、監査日時、監査者を記録する。記録形式を増やすこと自体は目的としない。

---

## 4. 監査領域

### 4.1 Repository Structure

- [ ] 保存先が責任本籍と既存構造に合う
- [ ] canonical filenameであり、作業名・提出状態・重複番号を残していない
- [ ] 新しい恒久フォルダを、既存構造で解決できるのに追加していない
- [ ] `REPOSITORY_RULES.md`、現行／Archive分離、CHANGELOG運用に適合する
- [ ] 同じ責任を持つ現行正本が複数存在しない
- [ ] Current Canonical Delta、差分正本またはversion付き並列Currentが現行領域に残っていない
- [ ] Archive、旧版、作業コピーを通常参照対象としていない
- [ ] INDEX、READMEまたは責任上の入口から現行正本へ到達できる
- [ ] Productionが固定pathだけでCurrent解決済みと判定できず、責任root／entry sourceの候補探索を要求される

### 4.2 Responsibility Architecture

- [ ] Human-in-the-loop、Voice、Writing Style、Brand、AI Organization、Education Core、Course OS、Production Pipeline、制作・運用基準との責任を分離した
- [ ] 既存Sourceとの重複、矛盾、責任空白、責任侵食がない
- [ ] 新Sourceが既存専門Sourceを上書き・再定義していない
- [ ] 判断不能な意味変更、上位基準変更、新責任単位の追加をHuman Decisionへ返した

### 4.3 Source Architecture

- [ ] Source階層、必読Source、Source Router、Source QAと整合する
- [ ] 案件Manifestがresolved canonical Source、Version／revision、Repository full commit SHA、file SHA-256、依存閉包、同一Taskの実読および適用範囲を記録できる
- [ ] G2後のSource変更、前Taskの読了証跡、未列挙Current候補およびProduction version不一致をFAILにできる
- [ ] dependencyを確認し、必須Source漏れがない
- [ ] obsolete、Draft、duplicate、Archive Sourceを現行正本として参照していない
- [ ] canonical path、Status、VersionまたはGit evidenceにより現行性を説明できる
- [ ] 必要なSourceから対象Sourceへ到達でき、対象Sourceから必要な責任Sourceへ戻れる

### 4.4 Version / Status

- [ ] 本文のVersion／Statusとファイルの実態・Approval Recordが矛盾しない
- [ ] 既存canonical Sourceと競合しない
- [ ] 意味のある変更を該当CHANGELOGとRepository CHANGELOGへ記録した
- [ ] Repository配置、commit、pushを専門的な承認Statusと混同していない

### 4.5 Operational Integration

- [ ] 新Sourceの開始条件、入力、出力、Gate、戻り先が明確である
- [ ] 必要なProduction Pipeline、Source Profile、Source QA、INDEX／README、AI Organization、Repository Rulesへ接続した
- [ ] 既存のQAや承認を重複追加せず、足りなかった責任だけを補った
- [ ] SourceがRepositoryに存在するだけでは運用完了と扱わない

### 4.6 Change Propagation

- [ ] 変更対象以外の影響Sourceを探索した
- [ ] 更新、更新不要、Human Decision Requiredのいずれかを対象ごとに説明できる
- [ ] 参照先・名称・Status・CHANGELOG・導線の同期漏れがない

### 4.7 Git Readiness

- [ ] 意図しない変更・不要ファイルを含めない
- [ ] `git diff --check` を通過し、対象diffを読んだ
- [ ] Version／Status／CHANGELOG／INDEXの整合を確認した
- [ ] Source Resolution変更では、Current Delta、固定path取りこぼし、前Task読了流用およびstale fingerprintのnegative testを実行した
- [ ] commitが意味のある単位で、branch・remote・push対象が正しい
- [ ] push後にlocal HEADとremoteの一致を確認する計画がある

---

## 5. 判定Gate

| 判定 | 条件 | 次工程 | 戻り先 |
|---|---|---|---|
| PASS | 必須項目が満たされ、Critical／Major Issueが解消し、残存リスクがない | Repository Integration／Git Gateへ進む | — |
| CONDITIONAL PASS | 変更の安全性・現行運用は成立するが、明示した非阻害の後続確認がある | 条件・所有者・期限を記録して進む | 該当する運用・改善Task |
| FAIL | canonical Source、必須依存、責任分離、Status、導線、CHANGELOGまたはGit準備に未解決の欠陥がある | 変更を正式反映しない | Source Router、対象Source、Repository IntegrationまたはGit自己監査 |
| HUMAN DECISION REQUIRED | 既存Evidenceだけでcanonical Source、責任構造、意味変更、削除、複数の妥当案を一意に選べない | Human Ownerへ判断を依頼する | 承認後に該当Gateから再開 |

CONDITIONAL PASSは、未承認Sourceの代替や高リスクの意味変更を許可しない。これらはFAILまたはHUMAN DECISION REQUIREDとする。

---

## 6. FAIL時の最低限の戻し先

| 問題 | 戻り先 |
|---|---|
| 保存先・命名・Archive・CHANGELOG | Repository Integration／`REPOSITORY_RULES.md` |
| 責任重複・権限・受け渡し | `AI_ORGANIZATION.md` または該当専門Source |
| 人間承認・停止・再承認 | `HUMAN_IN_THE_LOOP.md` |
| 必読Source漏れ・正本不明・Draft混入 | Source Router／Source QA |
| 教育内容・制作・成果物間品質 | Education／Material Productionの該当Source |
| Brand・Voice・Writingの意味判断 | 該当専門SourceまたはHuman Owner |
| 意図しないdiff・push不能 | Git自己監査／Repository Integration |

---

## 7. 完了条件

Repository横断監査の完了は、文書の作成または監査表の記入だけでは成立しない。以下すべてを満たすことを確認する。

- 監査対象のcanonical Sourceと責任本籍が一意である
- 必要な波及更新・導線・CHANGELOGが反映されている
- 監査判定がPASSまたは許容範囲のCONDITIONAL PASSである
- Git自己監査、commit、push、remote反映確認まで完了している
- 未解決の意味判断を解決済みと誤認せず、必要時はHuman Decision Requiredとして残している

---

## 8. 関連Source

- `REPOSITORY_RULES.md`
- `AI_ORGANIZATION.md`
- `AI_PRODUCTION_PIPELINE.md`
- `03_Human_in_the_Loop/HUMAN_IN_THE_LOOP.md`
- `04_AI_Work_Environment/AI_WORK_ENVIRONMENT.md`
- `00_Brand/00_ブランドOS概要・参照ガイド.md`
- `02_Voice_OS/VOICE_OS.md`
- `01_Education/` 配下の適用される正式Source
