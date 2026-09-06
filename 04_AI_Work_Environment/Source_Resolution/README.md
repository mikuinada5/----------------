# Source Resolution QA

**Status:** Current / Operational v1.1 / Cross-platform<br>
**Owner:** Repository Integration / Source Auditor<br>
**Authority:** `AI_PRODUCTION_PIPELINE.md` Phase 1–2 and `REPOSITORY_RULES.md`

## Purpose

Production AIが既知の固定pathだけを読んでCurrent Sourceを解決済みと誤認する経路を、G2前のRepository探索と再検証で閉じる。

本ディレクトリは新しいSource責任を作らない。Source Router／Source QA／Source Manifestの規範は`AI_PRODUCTION_PIPELINE.md`を正とし、ここにはその機械検証実装とSchemaだけを置く。

## Runtime contract

1. Source Planの責任本籍ごとに、canonical fileを直接開く前に責任root／正式entry sourceを確定する。
2. 各責任rootを探索し、Currentを名乗る候補、README／INDEX／参照ガイド、canonical指定、依存Sourceを列挙する。
3. `source_manifest.schema.json`に従い、選択・除外理由、実読、適用範囲、依存閉包、file SHA-256、Repository full commit SHAを案件単位で記録する。
4. Local Codexでは`Test-SourceResolution.ps1`、Cloud WorkではNode.js標準機能だけで動く`source-resolution.mjs`をG2判定前に実行する。両validatorはCurrent Canonical Delta、Currentなversion付き差分filename、候補の未列挙、前Taskの読了証跡、依存漏れ、SHA不一致をFAILにする。
5. Human Reviewへ出す版の内部QA前にも、同じManifestを再検証する。Sourceまたは依存SourceがG2後に変わっていればSHA不一致でFAILし、Source Routerから再開する。

「ファイルが存在する」「AIが名前を知っている」「以前読んだ」「canonical pathを直接読んだ」だけではG2 PASSにしない。

## Commands

Cloud Workで案件Manifestを生成・検証する。`--required`は同一Taskで実読したCurrent Sourceだけを列挙し、必要な責任rootを`--root`で指定する。

```bash
node 04_AI_Work_Environment/Source_Resolution/scripts/source-resolution.mjs resolve \
  --repository-root . --task-id <task-id> --production-version <version> \
  --root 04_AI_Work_Environment/Source_Resolution \
  --root 04_AI_Work_Environment/Visual_Production \
  --root 07_Note_Production \
  --required <canonical-source> --output <source-manifest.json>

node 04_AI_Work_Environment/Source_Resolution/scripts/source-resolution.mjs validate \
  --repository-root . --manifest <source-manifest.json> --production-version <version>
```

Repository構造だけを監査する。

```powershell
pwsh -File 04_AI_Work_Environment/Source_Resolution/scripts/Test-SourceResolution.ps1 -RepositoryRoot .
```

案件Manifestを含めてG2またはPre-Human Reviewを監査する。

```powershell
pwsh -File 04_AI_Work_Environment/Source_Resolution/scripts/Test-SourceResolution.ps1 -RepositoryRoot . -ManifestPath <manifest.json> -ExpectedProductionVersion <version>
```

## Privacy and storage

ManifestにはSourceのlocator、Version／SHA、実読・適用記録だけを置く。非公開本文、生ログ、credential、会話全文またはRepository外Personal Archiveの絶対pathを複製しない。未公開案件のManifestは当該成果物と同じ公開範囲に置き、Public Repositoryへ自動保存しない。
