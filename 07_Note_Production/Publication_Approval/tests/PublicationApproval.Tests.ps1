$module = Join-Path $PSScriptRoot '../scripts/PublicationApproval.psm1'
Import-Module $module -Force

function Save-TestJson([string]$Path, $Value) {
    $Value | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $Path -Encoding utf8 -NoNewline
}

function Test-Throws([scriptblock]$Action, [string]$Expected = '') {
    try { & $Action | Out-Null; return $false }
    catch { return (-not $Expected -or $_.Exception.Message.Contains($Expected)) }
}

Describe 'note Final Approval semantics and G5 orchestration' {
    BeforeEach {
        $caseRoot = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $caseRoot | Out-Null
        $sourcePath = Join-Path $caseRoot 'source-manifest.json'
        '{"schema_version":"source-manifest/v2","result":"PASS"}' | Set-Content -LiteralPath $sourcePath -Encoding utf8 -NoNewline
        $sourceSha = Get-NoteFileSha256 $sourcePath
        $bodyPath = Join-Path $caseRoot 'D3.md'
        $headerPath = Join-Path $caseRoot 'header.png'
        'Final D3 body bytes' | Set-Content -LiteralPath $bodyPath -Encoding utf8 -NoNewline
        [IO.File]::WriteAllBytes($headerPath, [byte[]](1, 2, 3, 4))
        $packagePath = Join-Path $caseRoot 'package.json'
        $actualPath = Join-Path $caseRoot 'actual-package.json'
        $eventPath = Join-Path $caseRoot 'human-event.json'
        $approvalPath = Join-Path $caseRoot 'approval.json'
        $destination = [ordered]@{ service = 'note'; account_id = 'miku_inada'; publication_target = 'article/AIDAILY-TEST' }
        $package = [ordered]@{
            schema_version = 'note-final-review-package/v1'
            package_id = 'FRP-AIDAILY-TEST-D3-H1'
            article_id = 'AIDAILY-TEST'
            d3_body = [ordered]@{ artifact_id = 'AIDAILY-TEST-D3'; sha256 = (Get-NoteFileSha256 $bodyPath) }
            header = [ordered]@{ artifact_id = 'AIDAILY-TEST-H1'; sha256 = (Get-NoteFileSha256 $headerPath) }
            publication_conditions = [ordered]@{
                access_boundary = [ordered]@{ mode = 'MEMBERSHIP'; locator = 'after-paragraph-4' }
                membership = [ordered]@{ enabled = $true; name = '稲田みく'; plan = 'AIとの日常' }
                magazine = [ordered]@{ enabled = $true; name = 'AIとの日常' }
                price = [ordered]@{ currency = 'JPY'; amount = 1500 }
                tags = @('AI', '仕事', '日常', '学び')
                other_conditions = @('standard-membership-cta')
            }
            destination = $destination
            purpose = 'NOTE_PUBLICATION'
            source_manifest = [ordered]@{ manifest_id = 'SM-TEST-D3'; sha256 = $sourceSha }
            presented_at = '2026-09-05T01:00:00+09:00'
        }
        Save-TestJson $packagePath $package
        Copy-Item -LiteralPath $packagePath -Destination $actualPath
        $packageSha = Get-NoteFileSha256 $packagePath
        $event = [ordered]@{
            schema_version = 'note-human-event/v1'
            event_id = 'HE-TEST-001'
            actor_type = 'human'
            evidence_origin = 'human-response-event'
            occurred_at = '2026-09-05T01:01:00+09:00'
            statement = '投稿して'
            context = [ordered]@{
                stage = 'FINAL_REVIEW_PACKAGE_PRESENTED'
                package_id = $package.package_id
                package_sha256 = $packageSha
                destination = $destination
                purpose = 'NOTE_PUBLICATION'
            }
        }
        Save-TestJson $eventPath $event
        $eventSha = Get-NoteFileSha256 $eventPath
        $approval = [ordered]@{
            schema_version = 'note-publication-approval/v1'
            approval_id = 'PA-TEST-001'
            approval_scope = 'NOTE_PUBLICATION'
            approval_type = 'FINAL_AND_PUBLICATION'
            decision = 'APPROVED'
            package_id = $package.package_id
            package_sha256 = $packageSha
            human_event_id = $event.event_id
            human_event_sha256 = $eventSha
            destination = $destination
            purpose = 'NOTE_PUBLICATION'
            approved_at = $event.occurred_at
        }
        Save-TestJson $approvalPath $approval
        $gateArgs = @{ PackagePath = $packagePath; HumanEventPath = $eventPath; ApprovalPath = $approvalPath; ActualPackagePath = $actualPath; SourceManifestPath = $sourcePath; D3BodyPath = $bodyPath; HeaderPath = $headerPath }
    }

    It 'A: Human Review only cannot advance to publish' {
        $event.context.stage = 'HUMAN_REVIEW'
        Save-TestJson $eventPath $event
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'HUMAN_EVENT_SCHEMA_FAIL') | Should Be $true
    }

    It 'B: a Human Review before Marketing cannot approve the Marketing-modified body' {
        $event.context.stage = 'HUMAN_REVIEW'
        $event.statement = 'これでいい'
        Save-TestJson $eventPath $event
        $package.d3_body.sha256 = ('3' * 64)
        Save-TestJson $actualPath $package
        (Test-Throws { Test-NoteG5Approval @gateArgs }) | Should Be $true
    }

    It 'C: Final Approval for D3, Header and Publication Conditions can pass G5 automatically' {
        $result = Test-NoteG5Approval @gateArgs
        $result.result | Should Be 'PASS'
        $result.requires_additional_human_approval | Should Be $false
    }

    It 'D: G5 must fail an additional Human approval request for an unchanged approved Package' {
        (Test-Throws { Assert-NotePublicationStep -Step SETTINGS_VERIFY @gateArgs -AdditionalHumanApprovalRequested } 'REDUNDANT_PUBLICATION_APPROVAL_REQUEST') | Should Be $true
    }

    It 'E: draft creation and publish must fail additional approval requests when no decision changed' {
        foreach ($step in @('NOTE_DRAFT_CREATE', 'PUBLISH')) {
            (Test-Throws { Assert-NotePublicationStep -Step $step @gateArgs -AdditionalHumanApprovalRequested } 'REDUNDANT_PUBLICATION_APPROVAL_REQUEST') | Should Be $true
        }
    }

    It 'F: a body change after Final Approval invalidates approval' {
        'Changed D3 body bytes' | Set-Content -LiteralPath $bodyPath -Encoding utf8 -NoNewline
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'D3_BODY_MISMATCH') | Should Be $true
    }

    It 'G: a free or Membership boundary change after Final Approval invalidates approval' {
        $package.publication_conditions.access_boundary.locator = 'after-paragraph-5'
        Save-TestJson $actualPath $package
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'ACTUAL_PACKAGE_MISMATCH') | Should Be $true
    }

    It 'H: a Header change after Final Approval invalidates approval' {
        [IO.File]::WriteAllBytes($headerPath, [byte[]](5, 6, 7, 8))
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'HEADER_MISMATCH') | Should Be $true
    }

    It 'I: an identical approved Package can continue from G5 through publish and PPV without stopping' {
        $result = Test-NotePublicationE2EPlan @gateArgs
        $result.result | Should Be 'PASS'
        $result.stopped_for_human | Should Be $false
        @($result.steps).Count | Should Be 7
        @($result.steps | Where-Object requires_additional_human_approval).Count | Should Be 0
    }

    It 'runs the checked E2E plan through the repository entrypoint' {
        $entry = Join-Path $PSScriptRoot '../scripts/Test-PublicationApproval.ps1'
        $result = & $entry @gateArgs -Mode E2E
        $result.result | Should Be 'PASS'
        $result.stopped_for_human | Should Be $false
    }

    It 'J: explicit proceed statements after Final Package presentation are Publication Approval intent' {
        foreach ($statement in @('OK', 'これでいい', '投稿して', '公開して', 'いけー')) {
            (Test-NoteExplicitPublicationIntent -Statement $statement -Stage 'FINAL_REVIEW_PACKAGE_PRESENTED') | Should Be $true
        }
    }

    It 'K: the same statement at Human Review is not Final or Publication Approval' {
        (Test-NoteExplicitPublicationIntent -Statement 'これでいい' -Stage 'HUMAN_REVIEW') | Should Be $false
    }

    It 'L: Publication Approval cannot be reused for external audit, OneDrive or Git approval' {
        foreach ($scope in @('EXTERNAL_AUDIT', 'ONEDRIVE_SAVE', 'GIT_PUSH')) {
            $changed = $approval | ConvertTo-Json -Depth 40 | ConvertFrom-Json -AsHashtable
            $changed.approval_scope = $scope
            Save-TestJson $approvalPath $changed
            (Test-Throws { Test-NoteG5Approval @gateArgs } 'APPROVAL_SCHEMA_FAIL') | Should Be $true
        }
    }

    It 'rejects a Human event that precedes Final Package presentation' {
        $event.occurred_at = '2026-09-05T00:59:59+09:00'
        Save-TestJson $eventPath $event
        $approval.human_event_sha256 = Get-NoteFileSha256 $eventPath
        $approval.approved_at = $event.occurred_at
        Save-TestJson $approvalPath $approval
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'HUMAN_EVENT_BEFORE_FINAL_PACKAGE') | Should Be $true
    }

    It 'rejects destination and source mismatches' {
        $event.context.destination.publication_target = 'article/OTHER'
        Save-TestJson $eventPath $event
        $approval.human_event_sha256 = Get-NoteFileSha256 $eventPath
        Save-TestJson $approvalPath $approval
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'DESTINATION_MISMATCH') | Should Be $true

        $event.context.destination.publication_target = 'article/AIDAILY-TEST'
        Save-TestJson $eventPath $event
        $approval.human_event_sha256 = Get-NoteFileSha256 $eventPath
        Save-TestJson $approvalPath $approval
        'changed source' | Set-Content -LiteralPath $sourcePath -Encoding utf8 -NoNewline
        (Test-Throws { Test-NoteG5Approval @gateArgs } 'SOURCE_MANIFEST_MISMATCH') | Should Be $true
    }

    It 'requires Human review again only when a new Human decision is introduced' {
        (Test-Throws { Assert-NotePublicationStep -Step PUBLISH @gateArgs -NewHumanDecisionRequired } 'APPROVAL_INVALIDATED_NEW_HUMAN_DECISION') | Should Be $true
    }

    It 'invalidates price, Membership, Magazine, tags and other approved condition changes' {
        $mutations = @(
            { param($p) $p.publication_conditions.price.amount = 1200 },
            { param($p) $p.publication_conditions.membership.plan = 'OTHER PLAN' },
            { param($p) $p.publication_conditions.magazine.name = 'OTHER MAGAZINE' },
            { param($p) $p.publication_conditions.tags[0] = 'OTHER TAG' },
            { param($p) $p.publication_conditions.other_conditions[0] = 'new-human-decision' }
        )
        foreach ($mutation in $mutations) {
            $changed = $package | ConvertTo-Json -Depth 40 | ConvertFrom-Json
            & $mutation $changed
            Save-TestJson $actualPath $changed
            (Test-Throws { Test-NoteG5Approval @gateArgs } 'ACTUAL_PACKAGE_MISMATCH') | Should Be $true
        }
    }
}
