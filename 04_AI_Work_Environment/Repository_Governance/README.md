# Repository Governance Runtime

**Status:** Current / Operational v1.0
**Authority:** `REPOSITORY_RULES.md` / `AI_PRODUCTION_PIPELINE.md`

この領域は、Cloud WorkとLocal CodexのGit WRITE所有権およびLocal maintenance開始前のRepository同期を機械検証する。新しい承認者やGitHub権限を作らず、認証・接続・push許可は実行環境とHuman-in-the-loopの既存境界に従う。

## Write Ownership

`ownership-matrix.json`を唯一のmachine-readable matrixとする。Cloud Workは`07_Note_Production/02_Published/AIDAILY/<Article-ID>/`の新規Article ID領域だけをappend-onlyで作成できる。既存Article ID、共通Source、Repository-wide CHANGELOG、System Timeline、schema、validator、scriptおよび設定は変更できない。

Local Codexはmatrixの`local-codex` domainに属するSystem Sourceを保守する。CloudがSystem変更の必要性を検出した場合は`LOCAL_MAINTENANCE_REQUIRED`として別Taskへ渡し、Cloud commitへ混ぜない。未登録pathはdefault denyである。異なるownerのdomainが同一pathまたは包含関係を持つmatrixはvalidatorが拒否する。

Cloud WRITEは、開始時のbaseline remote HEADとWRITE直前のcurrent remote HEAD、Git tree inspection実行済みEvidenceを必要とする。対象がCloud-ownedの新規Article IDで、current remote treeにもlocal checkoutにも同一Article pathがない場合だけ許可する。remoteが進んでいても同一Article pathが存在しなければ正常な並行入荷として扱える。remote確認能力がない場合は`BLOCKED_PLATFORM_BOUNDARY`であり、成功扱いしない。

## Local Preflight Sync

Local CodexはSystem maintenance開始前に`Invoke-RepositoryPreflightSync.ps1`を実行し、`fetch → local/remote HEAD → working tree → divergence → safe sync → clean verification`を行う。

| Git state | Result |
|---|---|
| clean、ahead 0、behind 0 | `READY` |
| clean、ahead 0、behind > 0 | `AUTO_FAST_FORWARD`を実行し、再検証後`READY` |
| dirty | `STOP_DIRTY_WORKTREE`。remoteもaheadなら`STOP_DIRTY_REMOTE_AHEAD` |
| local ahead only | `LOCAL_AHEAD_REVIEW`。既存のpush許可を確認 |
| local／remote双方ahead | `STOP_DIVERGED` |
| fetchまたはGit state取得不能 | `BLOCKED_GIT_CAPABILITY` |

fast-forward以外のmerge、stash、reset、上書きは行わない。Cloudが前日に新規Articleを追加したためlocalがbehindになった状態は、cleanでlocal独自commitがなければ正常入荷である。

## Files

- `ownership-matrix.json`: single-owner WRITE domains
- `scripts/Test-RepositoryWriteOwnership.ps1`: schema／collision validation
- `scripts/Test-CloudWritePreflight.ps1`: Cloud append-only plan validation
- `scripts/Invoke-RepositoryPreflightSync.ps1`: Local fetch／classification／fast-forward entrypoint
- `tests/`: ownership、negative、sync classification、local Git integration tests
