$compilerModule = Join-Path $PSScriptRoot '../scripts/FinalReviewPackageCompiler.psm1'
$approvalModule = Join-Path $PSScriptRoot '../scripts/PublicationApproval.psm1'
$bundleModule = Join-Path $PSScriptRoot '../scripts/PublicationBundle.psm1'
Import-Module $bundleModule -Force
Import-Module $compilerModule -Force
Import-Module $approvalModule -Force

function Save-BundleTestJson([string]$Path, $Value) {
    $Value | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $Path -Encoding utf8 -NoNewline
}

function Test-BundleThrows([scriptblock]$Action, [string]$Expected = '') {
    try { & $Action | Out-Null; return $false }
    catch { return (-not $Expected -or $_.Exception.Message.Contains($Expected)) }
}

function New-BundleFixture([string]$Root) {
    New-Item -ItemType Directory -Path $Root | Out-Null
    $bodyPath = Join-Path $Root 'D3.md'
    $headerPath = Join-Path $Root 'header.png'
    $marketingPath = Join-Path $Root 'marketing-review.json'
    $headerQaPath = Join-Path $Root 'header-qa.json'
    $sourcePath = Join-Path $Root 'source-manifest.json'
    'Final D3 body full text.' | Set-Content -LiteralPath $bodyPath -Encoding utf8 -NoNewline
    [IO.File]::WriteAllBytes($headerPath, [byte[]](1, 2, 3, 4))
    '{"status":"PASS","identity":"MR-TEST-v3"}' | Set-Content -LiteralPath $marketingPath -Encoding utf8 -NoNewline
    '{"status":"PASS","asset_id":"AIDAILY-TEST-H1"}' | Set-Content -LiteralPath $headerQaPath -Encoding utf8 -NoNewline
    '{"schema_version":"source-manifest/v2","result":"PASS"}' | Set-Content -LiteralPath $sourcePath -Encoding utf8 -NoNewline
    $input = [ordered]@{
        schema_version = 'note-final-review-package-input/v1'
        workflow_state = 'MARKETING_APPROVED'
        article_id = 'AIDAILY-TEST'
        title = 'Final title'
        d3_body = [ordered]@{ artifact_id = 'AIDAILY-TEST-D3'; file = 'private://AIDAILY-TEST/D3.md'; local_path = 'D3.md'; sha256 = Get-NoteCompilerFileSha256 $bodyPath }
        marketing_review = [ordered]@{
            status = 'PASS'; identity = 'MR-AIDAILY-TEST-v3'; version = 'v3'
            evidence = [ordered]@{ artifact_id = 'MR-AIDAILY-TEST-v3-EVIDENCE'; file = 'private://AIDAILY-TEST/marketing-review.json'; local_path = 'marketing-review.json'; sha256 = Get-NoteCompilerFileSha256 $marketingPath }
        }
        header = [ordered]@{
            asset_id = 'AIDAILY-TEST-H1'; file = 'archive://AIDAILY-TEST/header.png'; local_path = 'header.png'; sha256 = Get-NoteCompilerFileSha256 $headerPath
            asset_qa = [ordered]@{ status = 'PASS'; evidence = [ordered]@{ artifact_id = 'AIDAILY-TEST-H1-QA'; file = 'archive://AIDAILY-TEST/header-qa.json'; local_path = 'header-qa.json'; sha256 = Get-NoteCompilerFileSha256 $headerQaPath } }
        }
        publication_conditions = [ordered]@{
            access_boundary = [ordered]@{ mode = 'MEMBERSHIP'; free_end_marker = 'free ends here'; membership_start_marker = 'membership starts here' }
            membership = [ordered]@{ enabled = $true; name = 'AIとの日常'; plan = 'AIとの日常' }
            magazine = [ordered]@{ enabled = $true; name = 'AIとの日常' }
            price = [ordered]@{ currency = 'JPY'; amount = 1500 }
            tags = @('AI活用', 'note', '働き方', 'AIとの日常')
            other_conditions = @('standard-membership-cta')
        }
        destination = [ordered]@{ service = 'note'; account_id = 'miku_inada'; publication_target = 'article/AIDAILY-TEST' }
        purpose = 'NOTE_PUBLICATION'
        source_manifest = [ordered]@{ manifest_id = 'SM-AIDAILY-TEST-D3'; file = 'private://AIDAILY-TEST/source-manifest.json'; local_path = 'source-manifest.json'; sha256 = Get-NoteCompilerFileSha256 $sourcePath }
    }
    $inputPath = Join-Path $Root 'compiler-input.json'
    Save-BundleTestJson $inputPath $input
    $compiled = New-NoteFinalReviewPackage -InputPath $inputPath -OutputDirectory (Join-Path $Root 'compiled')
    $eventPath = Join-Path $Root 'human-event.json'
    $event = [ordered]@{
        schema_version = 'note-human-event/v2'; event_id = 'HE-AIDAILY-TEST-FINAL'; actor_type = 'human'; evidence_origin = 'human-response-event'
        occurred_at = '2026-09-06T01:01:00+09:00'; statement = '投稿して'
        context = [ordered]@{
            stage = 'FINAL_REVIEW_PACKAGE_PRESENTED'; presented_at = '2026-09-06T01:00:00+09:00'
            package_id = $compiled.package_id; package_identity_sha256 = $compiled.package_identity_sha256; package_sha256 = $compiled.package_sha256
            destination = $input.destination; purpose = 'NOTE_PUBLICATION'
        }
    }
    Save-BundleTestJson $eventPath $event
    $approvalPath = Join-Path $Root 'approval.json'
    $approval = [ordered]@{
        schema_version = 'note-publication-approval/v2'; approval_id = 'PA-AIDAILY-TEST-FINAL'; approval_scope = 'NOTE_PUBLICATION'
        approval_type = 'FINAL_AND_PUBLICATION'; decision = 'APPROVED'; package_id = $compiled.package_id
        package_identity_sha256 = $compiled.package_identity_sha256; package_sha256 = $compiled.package_sha256
        human_event_id = $event.event_id; human_event_sha256 = Get-NoteFileSha256 $eventPath
        destination = $input.destination; purpose = 'NOTE_PUBLICATION'; approved_at = $event.occurred_at
    }
    Save-BundleTestJson $approvalPath $approval
    $builderArgs = @{
        PackagePath = $compiled.package_path; HumanEventPath = $eventPath; ApprovalPath = $approvalPath
        SourceManifestPath = $sourcePath; D3BodyPath = $bodyPath; HeaderPath = $headerPath; OutputDirectory = (Join-Path $Root 'bundles')
    }
    [pscustomobject]@{
        root = $Root; body_path = $bodyPath; header_path = $headerPath; source_path = $sourcePath
        package_path = $compiled.package_path; package_id = $compiled.package_id; event_path = $eventPath; approval_path = $approvalPath
        builder_args = $builderArgs; compiled = $compiled
    }
}

function Copy-BundleZipForMutation($Fixture, [string]$Name) {
    $built = Invoke-BundleBuild $Fixture
    $expanded = Join-Path $Fixture.root ("expanded-$Name")
    Expand-Archive -LiteralPath $built.zip_path -DestinationPath $expanded
    [pscustomobject]@{
        built = $built
        expanded = $expanded
        bundle = (Join-Path $expanded 'PublicationBundle')
        zip = (Join-Path $Fixture.root ("$Name.zip"))
    }
}

function Invoke-BundleBuild($Fixture) {
    $arguments = $Fixture.builder_args
    PublicationBundle\New-NotePublicationBundle @arguments
}

function Save-MutatedBundleZip($Mutation) {
    Compress-Archive -LiteralPath $Mutation.bundle -DestinationPath $Mutation.zip -CompressionLevel Optimal
    $Mutation.zip
}

function Repair-BundleManifest([string]$BundleDirectory) {
    $manifestPath = Join-Path $BundleDirectory 'manifest.json'
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -AsHashtable -Depth 50
    $manifest.body.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'body.md')
    $manifest.header.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'header.png')
    $manifest.publication_conditions.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'publication-conditions.json')
    $conditions = Get-Content -LiteralPath (Join-Path $BundleDirectory 'publication-conditions.json') -Raw | ConvertFrom-Json -Depth 50
    $manifest.publication_conditions.identity_sha256 = (PublicationBundle\Get-NotePublicationConditionsIdentity $conditions.conditions).identity_sha256
    $manifest.approval_evidence.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'approval-evidence.json')
    $manifest.human_event.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'human-event.json')
    $manifest.source_manifest.sha256 = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $BundleDirectory 'source-manifest.json')
    $identity = PublicationBundle\Get-NotePublicationBundleIdentity $manifest
    $manifest.bundle_id = $identity.bundle_id
    $manifest.identity_sha256 = $identity.identity_sha256
    Save-BundleTestJson $manifestPath $manifest
}

Describe 'note Publication Bundle / Work Handoff Phase 1' {
    BeforeEach {
        Import-Module $bundleModule -Force -Global
        Import-Module $approvalModule -Force -Global
        Import-Module $compilerModule -Force -Global
        $fixture = New-BundleFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString()))
    }

    It 'A: rejects a Bundle with no body' {
        $mutation = Copy-BundleZipForMutation $fixture 'missing-body'
        Remove-Item -LiteralPath (Join-Path $mutation.bundle 'body.md')
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-a') } 'BUNDLE_FILE_MISSING') | Should Be $true
    }

    It 'B: rejects a Bundle with no Header' {
        $mutation = Copy-BundleZipForMutation $fixture 'missing-header'
        Remove-Item -LiteralPath (Join-Path $mutation.bundle 'header.png')
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-b') } 'BUNDLE_FILE_MISSING') | Should Be $true
    }

    It 'C: rejects a ZIP containing only the manifest' {
        $mutation = Copy-BundleZipForMutation $fixture 'manifest-only'
        Get-ChildItem -LiteralPath $mutation.bundle -File | Where-Object Name -ne 'manifest.json' | Remove-Item
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-c') } 'BUNDLE_FILE_MISSING') | Should Be $true
    }

    It 'D: rejects a body SHA mismatch' {
        $mutation = Copy-BundleZipForMutation $fixture 'body-sha'
        'tampered body' | Set-Content -LiteralPath (Join-Path $mutation.bundle 'body.md') -Encoding utf8 -NoNewline
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-d') } 'BODY_SHA_MISMATCH') | Should Be $true
    }

    It 'E: rejects a Header SHA mismatch' {
        $mutation = Copy-BundleZipForMutation $fixture 'header-sha'
        [IO.File]::WriteAllBytes((Join-Path $mutation.bundle 'header.png'), [byte[]](9, 9, 9))
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-e') } 'HEADER_SHA_MISMATCH') | Should Be $true
    }

    It 'F: rejects Approval Evidence bound to another Package ID' {
        $mutation = Copy-BundleZipForMutation $fixture 'approval-package'
        $approvalPath = Join-Path $mutation.bundle 'approval-evidence.json'
        $approval = Get-Content -LiteralPath $approvalPath -Raw | ConvertFrom-Json -AsHashtable -Depth 50
        $approval.package_id = 'FRP-OTHER-' + ('0' * 64)
        Save-BundleTestJson $approvalPath $approval
        Repair-BundleManifest $mutation.bundle
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-f') } 'APPROVAL_PACKAGE_ID_MISMATCH') | Should Be $true
    }

    It 'G: rejects destination or purpose mismatches' {
        foreach ($field in @('destination','purpose')) {
            $mutation = Copy-BundleZipForMutation $fixture ("mismatch-$field")
            $manifestPath = Join-Path $mutation.bundle 'manifest.json'
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -AsHashtable -Depth 50
            if ($field -eq 'destination') { $manifest.destination.account_id = 'other-account' } else { $manifest.purpose = 'archive' }
            $identity = PublicationBundle\Get-NotePublicationBundleIdentity $manifest
            $manifest.bundle_id = $identity.bundle_id
            $manifest.identity_sha256 = $identity.identity_sha256
            Save-BundleTestJson $manifestPath $manifest
            $zip = Save-MutatedBundleZip $mutation
            (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root "receive-g-$field") }) | Should Be $true
        }
    }

    It 'H: rejects Publication Conditions inconsistent with the approved Package' {
        $mutation = Copy-BundleZipForMutation $fixture 'conditions'
        $conditionsPath = Join-Path $mutation.bundle 'publication-conditions.json'
        $conditions = Get-Content -LiteralPath $conditionsPath -Raw | ConvertFrom-Json -AsHashtable -Depth 50
        $conditions.conditions.price.amount = 1200
        $conditions.identity_sha256 = (PublicationBundle\Get-NotePublicationConditionsIdentity $conditions.conditions).identity_sha256
        Save-BundleTestJson $conditionsPath $conditions
        Repair-BundleManifest $mutation.bundle
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-h') } 'PUBLICATION_CONDITIONS_PACKAGE_MISMATCH') | Should Be $true
    }

    It 'I: rejects a Source Manifest inconsistent with the approved Package' {
        $mutation = Copy-BundleZipForMutation $fixture 'source'
        '{"schema_version":"source-manifest/v2","result":"CHANGED"}' | Set-Content -LiteralPath (Join-Path $mutation.bundle 'source-manifest.json') -Encoding utf8 -NoNewline
        Repair-BundleManifest $mutation.bundle
        $zip = Save-MutatedBundleZip $mutation
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $zip -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-i') } 'SOURCE_MANIFEST_PACKAGE_MISMATCH') | Should Be $true
    }

    It 'J: rejects post-seal content changes with the old Approval' {
        $built = Invoke-BundleBuild $fixture
        $sealedManifestSha = PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $built.bundle_directory 'manifest.json')
        'changed after seal' | Set-Content -LiteralPath $fixture.body_path -Encoding utf8 -NoNewline
        (Test-BundleThrows { Invoke-BundleBuild $fixture } 'D3_BODY_MISMATCH') | Should Be $true
        (PublicationBundle\Get-NoteBundleFileSha256 (Join-Path $built.bundle_directory 'manifest.json')) | Should Be $sealedManifestSha
    }

    It 'K: rejects a chat-reference statement as the publication input' {
        $chatReference = Join-Path $fixture.root 'chat-reference.txt'
        'このChatを正本' | Set-Content -LiteralPath $chatReference -Encoding utf8 -NoNewline
        (Test-BundleThrows { PublicationBundle\Test-NotePublicationBundleHandoff -BundleZipPath $chatReference -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-k') } 'BUNDLE_ZIP_REQUIRED') | Should Be $true
    }

    It 'L: verifies a fully matching sealed Bundle directory' {
        $built = Invoke-BundleBuild $fixture
        $result = PublicationBundle\Test-NotePublicationBundleDirectory -BundleDirectory $built.bundle_directory -ExpectedPackageId $fixture.package_id
        $result.result | Should Be 'PASS'
        $result.state | Should Be 'HANDOFF_VERIFIED'
        $result.next_gate | Should Be 'G5'
    }

    It 'M: accepts one ZIP as the complete Work handoff' {
        $built = Invoke-BundleBuild $fixture
        $entry = Join-Path $PSScriptRoot '../scripts/Test-PublicationBundleHandoff.ps1'
        $result = & $entry -BundleZipPath $built.zip_path -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-m') -Mode Handoff
        $result.result | Should Be 'PASS'
        $result.transport | Should Be 'single_zip'
        $result.state | Should Be 'HANDOFF_VERIFIED'
    }

    It 'N: continues from an unchanged Bundle through G5 and PPV without another approval' {
        $built = Invoke-BundleBuild $fixture
        $result = PublicationBundle\Test-NotePublicationBundleE2EPlan -BundleZipPath $built.zip_path -ExpectedPackageId $fixture.package_id -ExtractionDirectory (Join-Path $fixture.root 'receive-n')
        $result.result | Should Be 'PASS'
        $result.requires_additional_human_approval | Should Be $false
        $result.stopped_for_human | Should Be $false
        @($result.states) -contains 'G5_PASS' | Should Be $true
        @($result.states) -contains 'PPV_PASS' | Should Be $true
    }

    It 'O: preserves the Step 1 Package and Approval contract' {
        $built = Invoke-BundleBuild $fixture
        $package = Get-Content -LiteralPath $fixture.package_path -Raw | ConvertFrom-Json -Depth 50
        $package.state | Should Be 'READY_FOR_FINAL_REVIEW'
        $package.approval.status | Should Be 'PENDING'
        $g5 = Test-NoteG5Approval -PackagePath $fixture.package_path -HumanEventPath $fixture.event_path -ApprovalPath $fixture.approval_path -ActualPackagePath $fixture.package_path -SourceManifestPath $fixture.source_path -D3BodyPath $fixture.body_path -HeaderPath $fixture.header_path
        $g5.result | Should Be 'PASS'
        $built.state | Should Be 'BUNDLE_SEALED'
        $built.handoff_state | Should Be 'HANDOFF_PENDING'
    }

    It 'gives identical approved inputs the same logical Bundle identity and transport name' {
        $first = Invoke-BundleBuild $fixture
        $secondArgs = @{} + $fixture.builder_args
        $secondArgs.OutputDirectory = Join-Path $fixture.root 'bundles-two'
        $second = PublicationBundle\New-NotePublicationBundle @secondArgs
        $first.bundle_id | Should Be $second.bundle_id
        $first.bundle_identity_sha256 | Should Be $second.bundle_identity_sha256
        (Split-Path $first.zip_path -Leaf) | Should Be 'AIDAILY-TEST_PublicationBundle.zip'
        (Split-Path $second.zip_path -Leaf) | Should Be 'AIDAILY-TEST_PublicationBundle.zip'
    }
}
