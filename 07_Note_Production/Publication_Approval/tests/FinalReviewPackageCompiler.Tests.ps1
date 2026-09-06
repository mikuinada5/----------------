$compilerModule = Join-Path $PSScriptRoot '../scripts/FinalReviewPackageCompiler.psm1'
$approvalModule = Join-Path $PSScriptRoot '../scripts/PublicationApproval.psm1'
Import-Module $compilerModule -Force
Import-Module $approvalModule -Force
Import-Module (Join-Path $PSScriptRoot 'FormalHeaderFixture.psm1') -Force

function Save-CompilerJson([string]$Path, $Value) {
    $Value | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $Path -Encoding utf8 -NoNewline
}

function Copy-CompilerValue($Value) {
    $Value | ConvertTo-Json -Depth 40 | ConvertFrom-Json -AsHashtable -Depth 40
}

function Test-CompilerThrows([scriptblock]$Action, [string]$Expected = '') {
    try { & $Action | Out-Null; return $false }
    catch { return (-not $Expected -or $_.Exception.Message.Contains($Expected)) }
}

function New-CompilerFixture([string]$Root) {
    New-Item -ItemType Directory -Path $Root | Out-Null
    $bodyPath = Join-Path $Root 'D3.md'
    $headerPath = Join-Path $Root 'header.png'
    $marketingPath = Join-Path $Root 'marketing-review.json'
    $headerQaPath = Join-Path $Root 'header-qa.json'
    $sourcePath = Join-Path $Root 'source-manifest.json'
    'Final D3 body full text.' | Set-Content -LiteralPath $bodyPath -Encoding utf8 -NoNewline
    Write-TestHeaderPng $headerPath
    '{"status":"PASS","identity":"MR-TEST-v3"}' | Set-Content -LiteralPath $marketingPath -Encoding utf8 -NoNewline
    '{"status":"PASS","asset_id":"AIDAILY-TEST-H1"}' | Set-Content -LiteralPath $headerQaPath -Encoding utf8 -NoNewline
    '{"schema_version":"source-manifest/v2","result":"PASS"}' | Set-Content -LiteralPath $sourcePath -Encoding utf8 -NoNewline
    $formalHeader = New-TestFormalHeaderRecord -Root $Root -HeaderPath $headerPath -HeaderQaPath $headerQaPath -ArticleId 'AIDAILY-TEST' -DisplayTitle 'Final title' -CanonicalPointer 'archive://AIDAILY-TEST/header.png'
    $input = [ordered]@{
        schema_version = 'note-final-review-package-input/v2'
        workflow_state = 'MARKETING_APPROVED'
        article_id = 'AIDAILY-TEST'
        title = 'Final title'
        d3_body = [ordered]@{
            artifact_id = 'AIDAILY-TEST-D3'
            file = 'private://AIDAILY-TEST/D3.md'
            local_path = 'D3.md'
            sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $bodyPath
        }
        marketing_review = [ordered]@{
            status = 'PASS'
            identity = 'MR-AIDAILY-TEST-v3'
            version = 'v3'
            evidence = [ordered]@{
                artifact_id = 'MR-AIDAILY-TEST-v3-EVIDENCE'
                file = 'private://AIDAILY-TEST/marketing-review.json'
                local_path = 'marketing-review.json'
                sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $marketingPath
            }
        }
        header = [ordered]@{
            asset_id = $formalHeader.record.formal_asset_id
            display_title = 'Final title'
            file = 'archive://AIDAILY-TEST/header.png'
            local_path = 'header.png'
            sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $headerPath
            formal_asset = [ordered]@{ artifact_id = $formalHeader.record.formal_asset_id; file = 'private://AIDAILY-TEST/formal-header-asset.json'; local_path = 'formal-header-asset.json'; sha256 = $formalHeader.sha256 }
            asset_qa = [ordered]@{
                status = 'PASS'
                evidence = [ordered]@{
                    artifact_id = 'AIDAILY-TEST-H1-QA'
                    file = 'archive://AIDAILY-TEST/header-qa.json'
                    local_path = 'header-qa.json'
                    sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $headerQaPath
                }
            }
        }
        publication_conditions = [ordered]@{
            access_boundary = [ordered]@{
                mode = 'MEMBERSHIP'
                free_end_marker = 'free ends here'
                membership_start_marker = 'membership starts here'
            }
            membership = [ordered]@{ enabled = $true; name = 'AIとの日常'; plan = 'AIとの日常' }
            magazine = [ordered]@{ enabled = $true; name = 'AIとの日常' }
            price = [ordered]@{ currency = 'JPY'; amount = 1500 }
            tags = @('AI活用', 'note', '働き方', 'AIとの日常')
            other_conditions = @('standard-membership-cta')
        }
        destination = [ordered]@{ service = 'note'; account_id = 'miku_inada'; publication_target = 'article/AIDAILY-TEST' }
        purpose = 'NOTE_PUBLICATION'
        source_manifest = [ordered]@{
            manifest_id = 'SM-AIDAILY-TEST-D3'
            file = 'private://AIDAILY-TEST/source-manifest.json'
            local_path = 'source-manifest.json'
            sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $sourcePath
        }
    }
    [pscustomobject]@{
        root = $Root
        input = $input
        input_path = (Join-Path $Root 'compiler-input.json')
        output = (Join-Path $Root 'output')
        body_path = $bodyPath
        header_path = $headerPath
        marketing_path = $marketingPath
        header_qa_path = $headerQaPath
        source_path = $sourcePath
    }
}

function Invoke-CompilerFixture($Fixture, $InputValue, [string]$Output = '') {
    Save-CompilerJson $Fixture.input_path $InputValue
    if (-not $Output) { $Output = $Fixture.output }
    FinalReviewPackageCompiler\New-NoteFinalReviewPackage -InputPath $Fixture.input_path -OutputDirectory $Output
}

Describe 'note Final Review Package Compiler' {
    BeforeEach {
        Import-Module $compilerModule -Force -Global
        $fixture = New-CompilerFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString()))
    }

    It 'A: fails when the D3 body input is missing' {
        $input = Copy-CompilerValue $fixture.input
        [void]$input.Remove('d3_body')
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'B: fails without Marketing Review PASS evidence' {
        $input = Copy-CompilerValue $fixture.input
        $input.marketing_review.status = 'FAIL'
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'C: fails when the Header Asset input is missing' {
        $input = Copy-CompilerValue $fixture.input
        [void]$input.Remove('header')
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'D: fails without Header Asset QA PASS evidence' {
        $input = Copy-CompilerValue $fixture.input
        $input.header.asset_qa.status = 'FAIL'
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'M0: rejects a PNG that has no Formal Header Asset record' {
        $input = Copy-CompilerValue $fixture.input
        [void]$input.header.Remove('formal_asset')
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'E: fails when either free or Membership boundary marker is missing' {
        foreach ($field in @('free_end_marker', 'membership_start_marker')) {
            $input = Copy-CompilerValue $fixture.input
            [void]$input.publication_conditions.access_boundary.Remove($field)
            (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root $field) } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
        }
    }

    It 'F: fails when a required Publication Condition is missing' {
        foreach ($field in @('membership', 'magazine', 'price', 'tags')) {
            $input = Copy-CompilerValue $fixture.input
            [void]$input.publication_conditions.Remove($field)
            (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root $field) } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
        }
    }

    It 'G: fails when the D3 body SHA does not match the file bytes' {
        $input = Copy-CompilerValue $fixture.input
        $input.d3_body.sha256 = (('0' * 64) -join '')
        $message = ''
        try { Invoke-CompilerFixture $fixture $input | Out-Null } catch { $message = $_.Exception.Message }
        $message.Contains('D3_BODY_SHA_MISMATCH') | Should Be $true
    }

    It 'H: fails when the Header SHA does not match the file bytes' {
        $input = Copy-CompilerValue $fixture.input
        $input.header.sha256 = (('0' * 64) -join '')
        $message = ''
        try { Invoke-CompilerFixture $fixture $input | Out-Null } catch { $message = $_.Exception.Message }
        $message.Contains('HEADER_SHA_MISMATCH') | Should Be $true
    }

    It 'I: fails when the required Source Manifest is missing' {
        $input = Copy-CompilerValue $fixture.input
        [void]$input.Remove('source_manifest')
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $input } 'BLOCKED_FINAL_PACKAGE_INCOMPLETE') | Should Be $true
    }

    It 'J: compiles complete matching inputs into a ready Package' {
        $result = Invoke-CompilerFixture $fixture $fixture.input
        $package = Get-Content -LiteralPath $result.package_path -Raw | ConvertFrom-Json -Depth 40
        $result.result | Should Be 'PASS'
        $result.state | Should Be 'READY_FOR_FINAL_REVIEW'
        $package.approval.status | Should Be 'PENDING'
        $package.marketing_review.status | Should Be 'PASS'
        $package.header.asset_qa.status | Should Be 'PASS'
    }

    It 'K: gives identical inputs the same Package identity and bytes' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'one')
        $second = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'two')
        $first.package_id | Should Be $second.package_id
        $first.package_identity_sha256 | Should Be $second.package_identity_sha256
        $first.package_sha256 | Should Be $second.package_sha256
    }

    It 'refuses to overwrite an existing Package path with different bytes' {
        $first = Invoke-CompilerFixture $fixture $fixture.input
        'tampered package bytes' | Set-Content -LiteralPath $first.package_path -Encoding utf8 -NoNewline
        (Test-CompilerThrows { Invoke-CompilerFixture $fixture $fixture.input } 'IMMUTABLE_PACKAGE_CONFLICT') | Should Be $true
    }

    It 'L: gives changed body bytes a new Package identity' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'one')
        'Changed D3 body full text.' | Set-Content -LiteralPath $fixture.body_path -Encoding utf8 -NoNewline
        $input = Copy-CompilerValue $fixture.input
        $input.d3_body.sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $fixture.body_path
        $second = Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root 'two')
        $first.package_id -eq $second.package_id | Should Be $false
    }

    It 'M: gives changed Header bytes a new Package identity' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'one')
        $bytes = @([IO.File]::ReadAllBytes($fixture.header_path)) + [byte]1
        [IO.File]::WriteAllBytes($fixture.header_path, [byte[]]$bytes)
        $formalHeader = New-TestFormalHeaderRecord -Root $fixture.root -HeaderPath $fixture.header_path -HeaderQaPath $fixture.header_qa_path -ArticleId 'AIDAILY-TEST' -DisplayTitle 'Final title' -CanonicalPointer 'archive://AIDAILY-TEST/header.png'
        $input = Copy-CompilerValue $fixture.input
        $input.header.sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $fixture.header_path
        $input.header.asset_id = $formalHeader.record.formal_asset_id
        $input.header.formal_asset.artifact_id = $formalHeader.record.formal_asset_id
        $input.header.formal_asset.sha256 = $formalHeader.sha256
        $second = Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root 'two')
        $first.package_id -eq $second.package_id | Should Be $false
    }

    It 'N: gives a changed free boundary a new Package identity' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'one')
        $input = Copy-CompilerValue $fixture.input
        $input.publication_conditions.access_boundary.free_end_marker = 'new free end'
        $second = Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root 'two')
        $first.package_id -eq $second.package_id | Should Be $false
    }

    It 'O: gives changed price, Membership, Magazine or tags a new Package identity' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'base')
        $mutations = @(
            { param($p) $p.publication_conditions.price.amount = 1200 },
            { param($p) $p.publication_conditions.membership.plan = 'OTHER' },
            { param($p) $p.publication_conditions.magazine.name = 'OTHER' },
            { param($p) $p.publication_conditions.tags[0] = 'OTHER' }
        )
        $index = 0
        foreach ($mutation in $mutations) {
            $input = Copy-CompilerValue $fixture.input
            & $mutation $input
            $changed = Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root "changed-$index")
            $first.package_id -eq $changed.package_id | Should Be $false
            $index++
        }
    }

    It 'P: rejects Approval Evidence bound to an earlier Package identity' {
        $first = Invoke-CompilerFixture $fixture $fixture.input (Join-Path $fixture.root 'one')
        $input = Copy-CompilerValue $fixture.input
        $input.publication_conditions.price.amount = 1200
        $second = Invoke-CompilerFixture $fixture $input (Join-Path $fixture.root 'two')
        $destination = $fixture.input.destination
        $eventPath = Join-Path $fixture.root 'human-event.json'
        $approvalPath = Join-Path $fixture.root 'approval.json'
        $event = [ordered]@{
            schema_version = 'note-human-event/v2'
            event_id = 'HE-OLD-PACKAGE'
            actor_type = 'human'
            evidence_origin = 'human-response-event'
            occurred_at = '2026-09-06T01:01:00+09:00'
            statement = '投稿して'
            context = [ordered]@{
                stage = 'FINAL_REVIEW_PACKAGE_PRESENTED'
                presented_at = '2026-09-06T01:00:00+09:00'
                package_id = $first.package_id
                package_identity_sha256 = $first.package_identity_sha256
                package_sha256 = $first.package_sha256
                destination = $destination
                purpose = 'NOTE_PUBLICATION'
            }
        }
        Save-CompilerJson $eventPath $event
        $approval = [ordered]@{
            schema_version = 'note-publication-approval/v2'
            approval_id = 'PA-OLD-PACKAGE'
            approval_scope = 'NOTE_PUBLICATION'
            approval_type = 'FINAL_AND_PUBLICATION'
            decision = 'APPROVED'
            package_id = $first.package_id
            package_identity_sha256 = $first.package_identity_sha256
            package_sha256 = $first.package_sha256
            human_event_id = $event.event_id
            human_event_sha256 = FinalReviewPackageCompiler\Get-NoteCompilerFileSha256 $eventPath
            destination = $destination
            purpose = 'NOTE_PUBLICATION'
            approved_at = $event.occurred_at
        }
        Save-CompilerJson $approvalPath $approval
        $args = @{ PackagePath = $second.package_path; HumanEventPath = $eventPath; ApprovalPath = $approvalPath; ActualPackagePath = $second.package_path; SourceManifestPath = $fixture.source_path; D3BodyPath = $fixture.body_path; HeaderPath = $fixture.header_path }
        $message = ''
        try { Test-NoteG5Approval @args | Out-Null } catch { $message = $_.Exception.Message }
        ($message -match 'PACKAGE_(ID|IDENTITY|SHA)_MISMATCH') | Should Be $true
    }

    It 'Q: rejects a Human presentation containing only the body' {
        $result = Invoke-CompilerFixture $fixture $fixture.input
        $bodyOnly = Join-Path $fixture.root 'body-only.md'
        'Final D3 body full text.' | Set-Content -LiteralPath $bodyOnly -Encoding utf8 -NoNewline
        (Test-CompilerThrows { FinalReviewPackageCompiler\Assert-NoteFinalReviewPresentation -PackagePath $result.package_path -PresentationPath $bodyOnly } 'FINAL_REVIEW_PRESENTATION_INCOMPLETE') | Should Be $true
    }

    It 'R: produces one presentation with body, Header and all Publication Conditions' {
        $result = Invoke-CompilerFixture $fixture $fixture.input
        $check = FinalReviewPackageCompiler\Assert-NoteFinalReviewPresentation -PackagePath $result.package_path -PresentationPath $result.presentation_path
        $check.result | Should Be 'PASS'
        $check.required_section_count | Should Be 8
    }
}
