$root = Resolve-Path (Join-Path $PSScriptRoot '../../..')
$matrix = Join-Path $PSScriptRoot '../ownership-matrix.json'
$schema = Join-Path $PSScriptRoot '../schemas/repository_write_ownership.schema.json'
$syncSchema = Join-Path $PSScriptRoot '../schemas/repository_sync_result.schema.json'
Import-Module (Join-Path $PSScriptRoot '../scripts/RepositoryGovernance.psm1') -Force
Import-Module (Join-Path $PSScriptRoot '../scripts/RepositorySync.psm1') -Force

Describe 'Repository write ownership' {
    It 'validates the canonical matrix schema and has no owner collision' {
        Test-Json -LiteralPath $matrix -SchemaFile $schema | Should Be $true
        $result=Test-RepositoryOwnershipMatrix -MatrixPath $matrix
        $result.result | Should Be 'PASS'
        $result.collision_count | Should Be 0
    }

    It 'allows Cloud to add a new Article ID path after a verified remote check' {
        $head=(& git -C $root rev-parse HEAD).Trim()
        $result=Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $matrix -Paths @('07_Note_Production/02_Published/AIDAILY/AIDAILY-999/01_記事最終稿.md','07_Note_Production/02_Published/AIDAILY/AIDAILY-999/manifest.json') -ArticleId 'AIDAILY-999' -RepositoryRoot $root -BaselineRemoteHead $head -CurrentRemoteHead $head -RemoteCheckPerformed $true
        $result.result | Should Be 'PASS'
        $result.state | Should Be 'WRITE_ALLOWED'
    }

    It 'allows a remote advance when it is linear and the new Article path remains absent' {
        $head=(& git -C $root rev-parse HEAD).Trim(); $baseline=(& git -C $root rev-parse HEAD~1).Trim()
        $result=Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $matrix -Paths @('07_Note_Production/02_Published/AIDAILY/AIDAILY-999/manifest.json') -ArticleId 'AIDAILY-999' -RepositoryRoot $root -BaselineRemoteHead $baseline -CurrentRemoteHead $head -RemoteCheckPerformed $true
        $result.result | Should Be 'PASS'
        $result.reason | Should Be 'REMOTE_ADVANCED_NO_ARTICLE_COLLISION'
    }

    It 'rejects Cloud writes to Pipeline and Repository-wide CHANGELOG' {
        foreach($path in @('AI_PRODUCTION_PIPELINE.md','CHANGELOG.md')) {
            (Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $matrix -Paths @($path) -ArticleId 'AIDAILY-999').result | Should Be 'FAIL'
        }
    }

    It 'allows Local Codex to maintain System Sources' {
        $result=Test-RepositoryWritePlan -Environment local-codex -MatrixPath $matrix -Paths @('AI_PRODUCTION_PIPELINE.md','04_AI_Work_Environment/Visual_Production/scripts/NoteHeaderRouting.psm1')
        $result.result | Should Be 'PASS'
    }

    It 'rejects an ownership matrix that gives the same path to Cloud and Local' {
        $copy=Get-Content -LiteralPath $matrix -Raw | ConvertFrom-Json -Depth 30
        $copy.domains += [pscustomobject]@{ id='invalid-cloud-system'; owner='cloud-work'; mode='append-only-new-article'; path_prefix='04_AI_Work_Environment/' }
        $path=Join-Path $TestDrive 'collision.json'; $copy | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $path -Encoding utf8
        $threw=$false; try { Test-RepositoryOwnershipMatrix -MatrixPath $path | Out-Null } catch { $threw=$true }
        $threw | Should Be $true
    }

    It 'rejects Cloud overwrite of an existing Published Article' {
        $head=(& git -C $root rev-parse HEAD).Trim()
        $result=Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $matrix -Paths @('07_Note_Production/02_Published/AIDAILY/AIDAILY-004/01_記事最終稿.md') -ArticleId 'AIDAILY-004' -RepositoryRoot $root -BaselineRemoteHead $head -CurrentRemoteHead $head -RemoteCheckPerformed $true
        $result.result | Should Be 'FAIL'
        $result.reason | Should Be 'CLOUD_EXISTING_ARTICLE_OVERWRITE_FORBIDDEN'
    }

    It 'blocks Cloud when the current remote check is unavailable' {
        $result=Test-RepositoryWritePlan -Environment cloud-work -MatrixPath $matrix -Paths @('07_Note_Production/02_Published/AIDAILY/AIDAILY-999/manifest.json') -ArticleId 'AIDAILY-999'
        $result.state | Should Be 'BLOCKED_PLATFORM_BOUNDARY'
    }
}

Describe 'Repository sync classification' {
    $cases=@(
        @{name='clean and equal is READY'; ahead=0; behind=0; clean=$true; expected='READY'; action='NONE'; ready=$true},
        @{name='clean and remote-only ahead is AUTO_FAST_FORWARD'; ahead=0; behind=2; clean=$true; expected='AUTO_FAST_FORWARD'; action='FAST_FORWARD'; ready=$false},
        @{name='a Cloud article arriving remotely is normal remote-only sync'; ahead=0; behind=1; clean=$true; expected='AUTO_FAST_FORWARD'; action='FAST_FORWARD'; ready=$false},
        @{name='dirty plus remote ahead stops'; ahead=0; behind=1; clean=$false; expected='STOP_DIRTY_REMOTE_AHEAD'; action='STOP'; ready=$false},
        @{name='local ahead is classified for push policy review'; ahead=1; behind=0; clean=$true; expected='LOCAL_AHEAD_REVIEW'; action='PUSH_POLICY_REVIEW'; ready=$false},
        @{name='true divergence stops'; ahead=1; behind=1; clean=$true; expected='STOP_DIVERGED'; action='STOP'; ready=$false}
    )
    foreach($case in $cases) {
        It $case.name {
            $result=Get-RepositorySyncClassification -LocalAhead $case.ahead -RemoteAhead $case.behind -WorkingTreeClean $case.clean
            $result.classification | Should Be $case.expected
            $result.action | Should Be $case.action
            $result.ready | Should Be $case.ready
            $path=Join-Path $TestDrive (($case.expected)+'.json'); $result | ConvertTo-Json | Set-Content -LiteralPath $path -Encoding utf8
            Test-Json -LiteralPath $path -SchemaFile $syncSchema | Should Be $true
        }
    }
}
