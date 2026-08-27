[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pipelineRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Import-Module (Join-Path $pipelineRoot 'src\ExternalAudit.psm1') -Force

$script:passed = 0
$script:failed = 0

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Throws {
    param([scriptblock]$Operation, [string]$Message)
    try {
        & $Operation
    }
    catch {
        return
    }
    throw $Message
}

function Invoke-TestCase {
    param([string]$Name, [scriptblock]$Test)
    try {
        & $Test
        $script:passed++
        Write-Host "PASS $Name"
    }
    catch {
        $script:failed++
        Write-Host "FAIL $Name :: $($_.Exception.Message)"
    }
}

$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ("external-audit-tests-" + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($fixtureRoot) | Out-Null

try {
    $sourcePath = Join-Path $fixtureRoot 'source.md'
    [IO.File]::WriteAllText($sourcePath, "# Story`nSTORY_BODY`n# Practice`nPRACTICE_BODY`n# Archive`nARCHIVE_BODY`n# End`n", [Text.UTF8Encoding]::new($false))
    $manifest = [ordered]@{
        series_name = 'Test Series'
        section_number = 'S01'
        session_number = 'S01-01'
        article_title = 'Test title'
        internal_audit = [ordered]@{ status = 'PASS'; report_ref = 'test:internal-pass' }
        external_sharing = [ordered]@{ approved = $true; approval_ref = 'test:user-approval' }
        content = [ordered]@{
            story = [ordered]@{ path = 'source.md'; start_marker = '# Story'; end_marker = '# Practice'; max_chars = 1000 }
            practice = [ordered]@{ path = 'source.md'; start_marker = '# Practice'; end_marker = '# Archive'; max_chars = 1000 }
            session_archive = [ordered]@{ path = 'source.md'; start_marker = '# Archive'; end_marker = '# End'; max_chars = 1000 }
        }
        sources = [ordered]@{}
        reaudit_context = $null
    }
    foreach ($group in @('evidence_notes','series_policy','session_scope','downstream_boundary','voice_archive_rules')) {
        $manifest.sources[$group] = @([ordered]@{ label = $group; path = 'source.md'; start_marker = '# Story'; end_marker = '# Practice'; max_chars = 1000 })
    }
    $manifestPath = Join-Path $fixtureRoot 'manifest.json'
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 100), [Text.UTF8Encoding]::new($false))

    Invoke-TestCase 'builds selective audit input after internal PASS' {
        $input = New-ExternalAuditInput `
            -ManifestPath $manifestPath `
            -RepositoryRoot $fixtureRoot `
            -RequestSchemaPath (Join-Path $pipelineRoot 'schemas\audit_request.schema.json') `
            -InputSchemaPath (Join-Path $pipelineRoot 'schemas\audit_input.schema.json')
        Assert-True ($input.story -match 'STORY_BODY') 'Story was not extracted.'
        Assert-True ($input.story -notmatch 'PRACTICE_BODY') 'Story selector crossed its boundary.'
        Assert-True ($input.evidence_notes.Count -eq 1) 'Evidence notes were not built.'
    }

    Invoke-TestCase 'rejects repository path traversal' {
        Assert-Throws { Resolve-ExternalAuditSourcePath -RepositoryRoot $fixtureRoot -RelativePath '..\outside.md' } 'Path traversal was accepted.'
    }

    Invoke-TestCase 'requires explicit external sharing approval' {
        $unapproved = $manifest | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100
        $unapproved.external_sharing.approved = $false
        Assert-Throws { Assert-ExternalAuditSharingApproval -Manifest $unapproved } 'Unapproved send was accepted.'
    }

    $responseSchema = Join-Path $pipelineRoot 'schemas\audit_response.schema.json'
    Invoke-TestCase 'validates a consistent PASS response' {
        $json = [ordered]@{
            audit_status = 'PASS'
            summary = '問題なし'
            issues = @()
            strengths = @('接続が明確')
            do_not_change = @('会話温度')
        } | ConvertTo-Json -Depth 20
        $result = ConvertFrom-ExternalAuditModelResponse -Text $json -ResponseSchemaPath $responseSchema
        Assert-True ($result.audit_status -eq 'PASS') 'PASS was not returned.'
    }

    Invoke-TestCase 'rejects status and severity inconsistency' {
        $json = [ordered]@{
            audit_status = 'PASS'
            summary = 'Minorあり'
            issues = @([ordered]@{
                id = 'EXT-001'; severity = 'MINOR'; category = 'Terminology'; location = 'Practice';
                problem = '不足'; reason = '初心者が迷う'; suggested_fix = '一語補う'; human_decision_required = $false
            })
            strengths = @()
            do_not_change = @()
        } | ConvertTo-Json -Depth 20
        Assert-Throws { ConvertFrom-ExternalAuditModelResponse -Text $json -ResponseSchemaPath $responseSchema } 'Inconsistent status was accepted.'
    }

    Invoke-TestCase 'routes MINOR to internal AI without mandatory re-audit' {
        $result = [pscustomobject]@{
            audit_status = 'PASS_WITH_MINOR'
            issues = @([pscustomobject]@{ id = 'EXT-001'; severity = 'MINOR'; human_decision_required = $false })
        }
        $routing = Get-ExternalAuditRouting -AuditResult $result
        Assert-True ($routing.action -eq 'RETURN_TO_INTERNAL_AI') 'MINOR did not return to internal AI.'
        Assert-True (-not $routing.external_reaudit_required) 'MINOR unexpectedly required re-audit.'
    }

    Invoke-TestCase 'retries a transient failure once' {
        $state = [pscustomobject]@{ attempt = 0 }
        $value = Invoke-WithExternalAuditRetry -RetryCount 1 -InitialDelaySeconds 1 -Operation {
            param($n)
            $state.attempt++
            if ($state.attempt -eq 1) { throw 'transient network failure' }
            return 'ok'
        }.GetNewClosure()
        Assert-True ($value -eq 'ok' -and $state.attempt -eq 2) 'Retry did not recover.'
    }
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) {
        Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
    }
}

Write-Host "RESULT passed=$script:passed failed=$script:failed"
if ($script:failed -gt 0) { exit 1 }
exit 0
