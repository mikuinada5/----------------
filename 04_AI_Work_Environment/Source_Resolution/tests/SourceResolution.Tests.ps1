$scriptUnderTest = Join-Path $PSScriptRoot '../scripts/Test-SourceResolution.ps1'

function New-TestSource {
    param([string]$Path, [string]$Title = 'Canonical')
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    @("# $Title", '', '**Status:** Current / Operational v1.0', '', 'body') | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-TestManifest {
    param(
        [string]$RepositoryRoot,
        [string[]]$Candidates = @('06_Writing_Style_OS/WRITING_STYLE_OS.md'),
        [string]$ReadTaskId = 'TEST-001',
        [string]$FileSha
    )

    $sourcePath = '06_Writing_Style_OS/WRITING_STYLE_OS.md'
    if (-not $FileSha) {
        $FileSha = (Get-FileHash -LiteralPath (Join-Path $RepositoryRoot $sourcePath) -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    $candidateObjects = @($Candidates | ForEach-Object { @{ path = $_; decision = 'selected' } })
    return @{
        schema_version = 'source-manifest/v2'
        task_id = 'TEST-001'
        production_version = 'D1'
        repository = @{ resolved_commit_sha = ('a' * 40); resolved_at = '2026-09-02T00:00:00Z' }
        resolution = @{
            method = 'responsibility-root-discovery'
            responsibility_roots = @('06_Writing_Style_OS')
            discovered_candidates = $candidateObjects
        }
        sources = @(@{
            path = $sourcePath
            responsibility = 'Writing Style'
            required = 'required'
            status = 'Current / Operational v1.0'
            version_or_revision = 'v1.0'
            file_sha256 = $FileSha
            read_by = 'test-runner'
            read_at = '2026-09-02T00:01:00Z'
            read_task_id = $ReadTaskId
            read_scope = 'full'
            applied_to = @('style')
            dependencies = @()
            dependency_check = 'PASS'
            conflict_check = 'PASS'
        })
        g2 = @{
            resolution_complete = $true
            current_canonical_unique = $true
            dependency_closure_complete = $true
            same_task_read_complete = $true
            source_fingerprint_frozen = $true
            result = 'PASS'
            passed_at = '2026-09-02T00:02:00Z'
        }
    }
}

Describe 'Source Resolution QA' {
    BeforeEach {
        $repo = Join-Path $TestDrive 'repo'
        New-TestSource -Path (Join-Path $repo '06_Writing_Style_OS/WRITING_STYLE_OS.md')
        $manifestPath = Join-Path $TestDrive 'manifest.json'
    }

    It 'passes a fully resolved same-task manifest' {
        New-TestManifest -RepositoryRoot $repo | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath } | Should Not Throw
    }

    It 'fails when a Current Canonical Delta is present' {
        $delta = Join-Path $repo '06_Writing_Style_OS/WRITING_STYLE_OS_v1.1_差分.md'
        New-TestSource -Path $delta -Title 'Delta'
        (Get-Content -LiteralPath $delta -Encoding UTF8) -replace 'Current / Operational', 'Current / Canonical Delta / Operational' | Set-Content -LiteralPath $delta -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails when responsibility-root discovery omits a Current sibling' {
        New-TestSource -Path (Join-Path $repo '06_Writing_Style_OS/RELATED.md') -Title 'Related'
        New-TestManifest -RepositoryRoot $repo | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails when read evidence belongs to a previous task' {
        New-TestManifest -RepositoryRoot $repo -ReadTaskId 'OLD-TASK' | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails when a Source changes after G2 fingerprinting' {
        New-TestManifest -RepositoryRoot $repo -FileSha ('0' * 64) | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails when a dependency is outside the resolved closure' {
        $manifest = New-TestManifest -RepositoryRoot $repo
        $manifest.sources[0].dependencies = @('02_Voice_OS/VOICE_OS.md')
        $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails when the Human Review artifact version differs from the Manifest' {
        New-TestManifest -RepositoryRoot $repo | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath -ExpectedProductionVersion 'D2' | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }

    It 'fails closed when a manifest path escapes the Repository' {
        $manifest = New-TestManifest -RepositoryRoot $repo
        $manifest.resolution.responsibility_roots = @('..')
        $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
        $threw = $false
        try { & $scriptUnderTest -RepositoryRoot $repo -ManifestPath $manifestPath | Out-Null } catch { $threw = $true }
        $threw | Should Be $true
    }
}
