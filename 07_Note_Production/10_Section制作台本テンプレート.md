# Section制作台本テンプレート

**Status:** Current / Operational v2.3 / Formal Header Asset Promotion compatible
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

PipelineのSource PlanとSource Manifestを参照し、責任root／entry source、列挙したCurrent候補と選択・除外理由、解決・実読したcanonical Source、Version／revision、Repository full commit SHA、file SHA-256、同一Taskの実読、依存閉包、適用箇所、Production version、矛盾確認およびG2結果を記録する。Production開始前とPre-Human Reviewで同じManifestを再検証し、Source fingerprintまたはProduction versionが変わった場合はG2から再実行する。G0では、Draftを外部公開しない取扱範囲と最終承認者を記録する。未解決の必読SourceまたはG2 FAILはProductionへ持ち込まない。価格、自己開示範囲、最終的な公開範囲の未決はDraft Production、Human ReviewおよびMarketing Reviewを止めず、Publication DecisionとHuman Final Approvalへ記録する。

各本文の初稿／改訂稿をHumanへ提示する前に、Pipeline §8.5.1のPre-Human Review QA記録を参照する。Production ID／Draft ID、exact本文SHA、QA record／review／export receipt locator、検証日時と結果を制作記録へ保持し、G2の読了証跡やVersion名だけでG4 PASSにしない。未公開本文・QA詳細はPublic台本へ複製しない。

## 3. Story Hub

| Story ID | 事実 / 一次Evidence | 使用候補Session | 自己開示の可否 | 重複・未使用 | 注記 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

Story Candidateは公開許可ではない。本人以外の個人情報、未確認の事実、センシティブな自己開示はHuman Decisionへ戻す。

## 4. Session設計と公開構成Profile

| Session ID | Story（無料Hub） | 実践編（単品有料・無料部の詳細目次） | MS奮闘記（メンバーシップ限定） | Session全体を入口にしたSNS投稿案 | 状態 | 未解決Decision |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |

この表は既定3記事Profile用である。Section固有のHuman承認済み公開構成Profileがある場合は、列をそのProfileの本文・別コンテンツへ読み替え、結合順序と分離境界を明記する。AI Organization Series Section 1では、S1-1だけStory＋Practiceをnote本編1記事とし、S1-2以降はStory、Practice、Session Archiveを独立成果物として扱う。Session Archiveの公開範囲とMembershipでの扱いは別途Human Decisionとし、未決のままStoryまたはPracticeへ混入・公開しない。SNS投稿案はSession全体を入口にした別成果物として制作し、実投稿は `03_SNS展開基準.md` の媒体別Gateに従う。

### 4.1 記事間循環導線

| Link Record ID | Source Article ID | Target Article ID | Placement | Link Type / Card Type | Status | Target URL | 注記 |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  | Pending / Target Published / Backfill Prepared / Backfill Failed / Recovery Required / Resolved |  |  |

未公開TargetへのHuman承認済み接続予定は`Pending`として記録し、Target URLは空欄にする。Pending LinkはHumanがSource Article公開時の必須条件にした場合だけ公開をBLOCKする。Target公開後のBackfill、Human Publication Approval、再PPVおよび`Resolved`への移行は`00_note制作・公開システム.md` §2.6.8に従い、公開後の現在状態は公開成果物記録へ引き継ぐ。未公開URL、仮URLまたは推測URLを置かない。

## 5. Section完成条件と価格キャリブレーション

Sectionは、全Sessionについて承認済み公開構成Profileの成果物がProduction・Output QAを通過した時点で `Review` とする。Human Review、Practiceの実機完遂、壁打ちおよび実素材をnote制作部が反映した内容完成稿を第2稿とし、同稿だけをMarketing Reviewへ渡す。このHuman ReviewはFinal Approvalではない。Marketing Requirementの必要な修正・再監査を通過し、無料／Membership境界、Membership、Magazine、price、tagsその他のPublication Conditionsが揃った`Marketing Approved`稿を第3稿とする。最終タイトル／第3稿確定後にHeader Production／QAを行い、本文、Header、Publication Conditionsおよび必要な自己開示をFinal Review PackageとしてHumanへ渡す。Package-bound Human Final Approval / Publication Approval後、sealed Publication Bundleを生成し、Phase 1ではHumanが単一ZIPを公開Workへ一度渡す。Workの`HANDOFF_VERIFIED`とG5自動検証PASS後のPackageを最終稿／`Approved`とし、再承認なしのTransactionとPost-Publication Verification、公開成果物記録の更新まで完了して `Published/Complete` とする。

Human Final Reviewで本文、HeaderまたはDecisionの一部が差し戻された場合は `Revision Required` とする。差し戻し理由、修正対象、所有者、再開条件を§6へ記録し、未変更の第3稿、Output QA、Human Review、Marketing Review結果およびHeader QAは有効なまま保持する。変更が必要な成果物と影響Decisionだけを修正・再監査して `Decision Pending` へ戻す。Final Approval後の承認Package変更はApprovalを失効させる。公開後の修正候補、反応、価格仮説の見直しは `Update Candidate` とし、既存正本を自動変更しない。

Section 1の全Sessionについて第2稿が揃った後、Marketingは各Sessionの価格を単独で固定せず、Section 1内の全本文を横並びにして、読者価値、深度、重複、無料／有料範囲、既存商品の導線との整合をキャリブレーションする。AI Organization Series Section 1では、S1-1のStory＋Practice結合本編と、S1-2以降の独立Story／Practice記事を比較対象とする。Marketingは根拠とConfidenceを付けた推奨価格を作成するが、Human Final Approval前に最終価格として決定・設定しない。

## 6. Production / Content Review / QA / Approval

| Session ID | G2 Source QA | 初稿 / G4 | Human Review・実機完遂 | 第2稿 | Marketing substatus / Conditions | 第3稿 | Header Contract / Prompt QA / Asset QA | Final Review Package / Human Event | Publication Bundle / Handoff | G5 Automated Verification | Transaction / G8 | Verification / G9 | 次アクション |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|  |  |  |  | Not Ready / Ready | Input Pending / Review / Revision Required / Approved / Human Decision Required | Not Ready / Ready | Pending / PASS / Returned | Pending / Approved / Returned | Not Started / Sealed / Pending / Verified / Failed | Not Started / PASS / FAIL | Not Started / Published / Failed | Not Started / PASS / FAIL |  |

## 7. Marketing Review / Header / Publication Decision

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
| Header Contract / Prompt Assembly QA / Asset QA | Contract ID、Production version、Source fingerprint、実Tool Request識別、Prompt QA、Asset provenance、Header QA結果、Human Review Candidate化。QA未確認／FAILはAsset ID・G5へ進めない |
| Formal Header Asset Promotion | Formal Asset ID／identity、Article ID、approved display title、Master expected／actual SHA、Bridge receipt、generated Asset SHA／寸法、Asset QA、Header Human Approval Evidence。direct built-in画像やEvidence欠落は`UNVERIFIED_NON_ASSET`／`BLOCKED_FINAL_PACKAGE_INCOMPLETE` |
| Final Review Package Compiler | Input locator、D3／Header／Marketing／Source Manifest SHA検証、Compiler version、Package ID／identity SHA／file SHA、`READY_FOR_FINAL_REVIEW`、8区分提示Artifact locator。不足時は`BLOCKED_FINAL_PACKAGE_INCOMPLETE` |
| Human Event / Approval Evidence | 提示済みPackage ID／identity SHA／file SHA、提示時刻、Human event ID／時刻／statement、公開先、目的。Package本体とは別Artifact |
| Publication Bundle / Work Handoff | Bundle ID／identity SHA、Builder version、sealed directory／ZIP locator、Package ID、`BUNDLE_SEALED / HANDOFF_PENDING`、Humanによる単一ZIP受け渡し、Work側`HANDOFF_VERIFIED`。ZIP SHAをBundle identityにしない |
| G5 Automated Verification | Approval Evidence、実Package、destination、purpose、Source Manifestの照合結果。G5で新しい承認を求めない |
| Publication Transaction / Verification | Not Started / Published / PASS / FAIL |
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
| Tags |  |  | High / Medium / Low |  |  |
| SNS Distribution |  |  | High / Medium / Low |  |  |
| Success Metrics / Evaluation Period |  |  | High / Medium / Low |  |  |

### 7.4 Learning Record

| Hypothesis | Decision | Decision Reason | Confidence | Success Metrics | Evaluation Period | Actual Result | Interpretation | Learning |
|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  | Human提供後に記録 | Factと分離 | 一度の結果で一般則化しない |

Human Final Review時は、第3稿全文、Marketing PASS Evidence、Header Asset／QA Evidence、必要な自己開示、Publication Decision Summary、公開先およびSource Manifestを決定論的Compilerへ渡す。本文、Header、無料／Membership境界、Membership、Magazine、price、tags、その他Publication Conditionsの8区分を含む`READY_FOR_FINAL_REVIEW / PENDING`のPackageと提示Artifactが検証済みの場合だけ一括提示する。Package IDはArticle ID、本文／Header SHA、Publication Conditions、Marketing identity、destinationおよびSource Manifestへbindingし、変更時は上書きせず新identityを生成する。提示後の明示的進行意思を別ArtifactのHuman Final Approval / Publication ApprovalとしてPackage identityへbindingする。承認後はBuilderがPackage全体をimmutable Publication BundleへSealする。公開WorkはBundle ZIPとPackage IDだけを受領し、全fileを再検証して`HANDOFF_VERIFIED`後にG5へ進む。同一BundleならTransaction／PPVまで再承認を要求しない。

## 8. 公開後・Feedback

公開済み最終稿、公開成果物記録、全体ロードマップのStatus更新、Timelineへ追加すべき新たな史実、Feedback Candidateを記録する。記事の反応を、根拠・AI推論・人間判断に分け、OS／SOPの変更候補は新規TaskとしてPipelineへ戻す。
