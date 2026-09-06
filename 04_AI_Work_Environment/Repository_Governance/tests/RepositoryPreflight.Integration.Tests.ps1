$preflight = Join-Path $PSScriptRoot '../scripts/Invoke-RepositoryPreflightSync.ps1'

function Invoke-TestGit {
    param([string]$Directory,[Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments)
    & git -C $Directory @Arguments | Out-Null
    if($LASTEXITCODE -ne 0){ throw "git failed: $($Arguments -join ' ')" }
}

function New-TestRepositoryPair {
    param([string]$Base)
    $remote=Join-Path $Base 'remote.git'; $seed=Join-Path $Base 'seed'; $local=Join-Path $Base 'local'
    New-Item -ItemType Directory -Path $seed -Force | Out-Null
    & git init --bare $remote | Out-Null
    Invoke-TestGit $seed init -b main
    Invoke-TestGit $seed config user.email 'qa@example.invalid'
    Invoke-TestGit $seed config user.name 'Repository QA'
    'initial' | Set-Content -LiteralPath (Join-Path $seed 'README.md') -Encoding utf8
    Invoke-TestGit $seed add README.md
    Invoke-TestGit $seed commit -m initial
    Invoke-TestGit $seed remote add origin $remote
    Invoke-TestGit $seed push -u origin main
    & git --git-dir=$remote symbolic-ref HEAD refs/heads/main
    & git clone -q $remote $local
    [pscustomobject]@{remote=$remote;seed=$seed;local=$local}
}

Describe 'Local repository preflight integration' {
    It 'returns READY when clean and equal' {
        $pair=New-TestRepositoryPair (Join-Path $TestDrive 'equal')
        & $preflight -RepositoryRoot $pair.local | Out-Null
        $LASTEXITCODE | Should Be 0
        @(& git -C $pair.local status --porcelain).Count | Should Be 0
    }

    It 'fast-forwards a clean remote-only Article arrival and becomes READY' {
        $pair=New-TestRepositoryPair (Join-Path $TestDrive 'behind')
        $article=Join-Path $pair.seed '07_Note_Production/02_Published/AIDAILY/AIDAILY-999'
        New-Item -ItemType Directory -Path $article -Force | Out-Null
        'published' | Set-Content -LiteralPath (Join-Path $article 'manifest.json') -Encoding utf8
        Invoke-TestGit $pair.seed add 07_Note_Production/02_Published/AIDAILY/AIDAILY-999/manifest.json
        Invoke-TestGit $pair.seed commit -m article
        Invoke-TestGit $pair.seed push origin main
        & $preflight -RepositoryRoot $pair.local | Out-Null
        $LASTEXITCODE | Should Be 0
        (& git -C $pair.local rev-parse HEAD).Trim() | Should Be ((& git -C $pair.seed rev-parse HEAD).Trim())
        Test-Path -LiteralPath (Join-Path $pair.local '07_Note_Production/02_Published/AIDAILY/AIDAILY-999/manifest.json') | Should Be $true
    }
}
