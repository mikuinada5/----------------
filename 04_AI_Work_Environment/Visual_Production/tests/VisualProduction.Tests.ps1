$scriptUnderTest = Join-Path $PSScriptRoot '../scripts/Test-VisualProduction.ps1'
Import-Module (Join-Path $PSScriptRoot '../scripts/NoteHeaderRouting.psm1') -Force

function New-TestSource {
    param([string]$Path)
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    @('# Visual Source', '', '**Status:** Current / Operational v1.0', '', 'rules') | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-VisualRecord {
    param(
        [string]$RepositoryRoot,
        [string]$Phase = 'Header Production',
        [string]$ArtifactType = 'note-header',
        [string]$ProfileId = 'aidaily-header-v1'
    )

    $sourcePath = if ($ArtifactType -eq 'education-visual') { '01_Education/02_Material_Production/10_PPT制作基準.md' } else { '07_Note_Production/00_note制作・公開システム.md' }
    New-TestSource -Path (Join-Path $RepositoryRoot $sourcePath)
    $sha = (Get-FileHash -LiteralPath (Join-Path $RepositoryRoot $sourcePath) -Algorithm SHA256).Hash.ToLowerInvariant()
    $masterLocator = '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png'
    $masterManifestLocator = '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.json'
    $masterPath = Join-Path $RepositoryRoot $masterLocator
    if ($ArtifactType -eq 'note-header') {
        New-Item -ItemType Directory -Path (Split-Path -Parent $masterPath) -Force | Out-Null
        [IO.File]::WriteAllBytes($masterPath, [Text.Encoding]::UTF8.GetBytes('approved-master-image'))
        '{}' | Set-Content -LiteralPath (Join-Path $RepositoryRoot $masterManifestLocator) -Encoding utf8 -NoNewline
    }
    $masterSha = if ($ArtifactType -eq 'note-header') { (Get-FileHash -LiteralPath $masterPath -Algorithm SHA256).Hash.ToLowerInvariant() } else { '' }
    $generatedPath = Join-Path $RepositoryRoot 'runtime-assets/generated.png'
    if ($ArtifactType -eq 'note-header') {
        New-Item -ItemType Directory -Path (Split-Path -Parent $generatedPath) -Force | Out-Null
        [IO.File]::WriteAllBytes($generatedPath, [byte[]](137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,5,0,0,0,2,158))
    }
    $generatedSha = if ($ArtifactType -eq 'note-header') { (Get-FileHash -LiteralPath $generatedPath -Algorithm SHA256).Hash.ToLowerInvariant() } else { ('c' * 64) }

    $requirements = if ($ArtifactType -eq 'note-header') {
        @(
            @{ id = 'master-reference'; level = 'MUST'; text = 'Use NOTE HEADER MASTER TEMPLATE v1.0 as the bound reference image'; source_path = $sourcePath },
            @{ id = 'note-horizontal'; level = 'MUST'; text = 'Use a horizontal note header'; source_path = $sourcePath },
            @{ id = 'current-dimensions'; level = 'MUST'; text = 'Use current recommended dimensions and aspect ratio'; source_path = $sourcePath },
            @{ id = 'human-left'; level = 'MUST'; text = 'Place Human on the left'; source_path = $sourcePath },
            @{ id = 'kei-right'; level = 'MUST'; text = 'Place Kei on the right'; source_path = $sourcePath },
            @{ id = 'comic-style'; level = 'MUST'; text = 'Use comic style'; source_path = $sourcePath },
            @{ id = 'white-background'; level = 'MUST'; text = 'Keep the background white'; source_path = $sourcePath },
            @{ id = 'black-pink-palette'; level = 'MUST'; text = 'Use black as main color and pink as accent'; source_path = $sourcePath },
            @{ id = 'master-title-replace'; level = 'MUST'; text = 'Replace the Master title'; source_path = $sourcePath },
            @{ id = 'title-exact'; level = 'MUST'; text = 'Use approved title verbatim'; source_path = $sourcePath },
            @{ id = 'title-central'; level = 'MUST'; text = 'Title is the central visual element'; source_path = $sourcePath },
            @{ id = 'no-series-label'; level = 'MUST_NOT'; text = 'Do not include AIとの日常'; source_path = $sourcePath },
            @{ id = 'no-speech-bubbles'; level = 'MUST_NOT'; text = 'Do not use speech bubbles'; source_path = $sourcePath },
            @{ id = 'no-explanation-copy'; level = 'MUST_NOT'; text = 'Do not add explanation copy'; source_path = $sourcePath },
            @{ id = 'no-checklists'; level = 'MUST_NOT'; text = 'Do not add checklists'; source_path = $sourcePath },
            @{ id = 'no-additional-catch-copy'; level = 'MUST_NOT'; text = 'Do not add catch copy'; source_path = $sourcePath },
            @{ id = 'no-background-recolor'; level = 'MUST_NOT'; text = 'Do not recolor the white background'; source_path = $sourcePath },
            @{ id = 'no-unverified-facts'; level = 'MUST_NOT'; text = 'Do not add unverified facts'; source_path = $sourcePath },
            @{ id = 'no-hype'; level = 'MUST_NOT'; text = 'Do not add success claims or hype beyond the article'; source_path = $sourcePath },
            @{ id = 'no-poster-layout'; level = 'MUST_NOT'; text = 'Do not turn the header into a poster or infographic'; source_path = $sourcePath },
            @{ id = 'no-title-change'; level = 'MUST_NOT'; text = 'Do not alter the approved title'; source_path = $sourcePath },
            @{ id = 'expressions'; level = 'MAY'; text = 'Expressions may vary'; source_path = $sourcePath },
            @{ id = 'poses'; level = 'MAY'; text = 'Poses may vary'; source_path = $sourcePath },
            @{ id = 'small-props'; level = 'MAY'; text = 'Small work props may be used'; source_path = $sourcePath },
            @{ id = 'minor-effects'; level = 'MAY'; text = 'Minor article-specific effects may be used'; source_path = $sourcePath }
        )
    }
    else {
        @(
            @{ id = 'approved-design'; level = 'MUST'; text = 'Follow approved education design'; source_path = $sourcePath },
            @{ id = 'no-unapproved-content'; level = 'MUST_NOT'; text = 'Do not add unapproved education content'; source_path = $sourcePath }
        )
    }

    $mandatory = @($requirements | Where-Object { $_.level -in @('MUST', 'MUST_NOT') } | ForEach-Object { $_.id })
    $mandatoryText = @($requirements | Where-Object { $_.level -in @('MUST', 'MUST_NOT') } | ForEach-Object { $_.text }) -join "`n"
    $masterPromptIdentity = if ($ArtifactType -eq 'note-header') { "`nNOTE-HEADER-MASTER-v1.0`nv1.0`n$masterLocator`n$masterSha" } else { '' }
    $qaChecks = @($mandatory | ForEach-Object { @{ requirement_id = $_; result = 'PASS' } }) + @(@{ requirement_id = 'dimensions'; result = 'PASS' })
    $title = 'AIに仕事を任せたら、私の仕事が増えた話'

    $record = @{
        schema_version = 'visual-production/v1'
        task_id = 'VISUAL-TEST-001'
        production_version = 'H1'
        phase = $Phase
        artifact_type = $ArtifactType
        source_manifest = @{
            task_id = 'VISUAL-TEST-001'
            production_version = 'H1'
            result = 'PASS'
            fingerprint_sha256 = ('b' * 64)
            sources = @(@{ path = $sourcePath; file_sha256 = $sha; applied_to = @('visual-template', 'asset-qa') })
        }
        resolved_requirements = $requirements
        generation_contract = @{
            article_id = 'AIDAILY-TEST'
            profile_id = $ProfileId
            source_fingerprint_sha256 = ('b' * 64)
            approved_text = @{ title = $title }
            dimensions = @{ width = 1280; height = 670 }
            reference_assets = if ($ArtifactType -eq 'note-header') { @(@{ asset_id = 'NOTE-HEADER-MASTER-v1.0'; version = 'v1.0'; logical_locator = $masterLocator; manifest_locator = $masterManifestLocator; sha256 = $masterSha; expected_sha256 = $masterSha; actual_sha256 = $masterSha; dimensions = @{ width = 1280; height = 670 }; provenance = 'repository-master-manifest:test' }) } else { @() }
            request_identity_sha256 = ''
            requirement_ids = $mandatory
            creative_direction = @(@{ id = 'warm-expression'; text = 'Warm expression'; conflicts_with = @(); resolution = 'kept' })
            inspection_capability = 'ai-visual-inspection'
            max_automatic_retries = 2
        }
        tool_route = @{ tool = 'image_gen.imagegen'; capability = 'image-generation'; allowed = $true; rationale = 'approved visual production phase' }
        tool_request = @{
            text_verbatim = $title
            prompt = "Create a header using the exact title: $title`n$mandatoryText$masterPromptIdentity"
            dimensions = @{ width = 1280; height = 670 }
            referenced_image_paths = if ($ArtifactType -eq 'note-header') { @($masterPath) } else { @() }
            included_requirement_ids = $mandatory
            negative_requirement_ids = @($requirements | Where-Object { $_.level -eq 'MUST_NOT' } | ForEach-Object { $_.id })
        }
        preflight = @{
            tool_route_check = $true
            contract_completeness_check = $true
            prompt_assembly_check = $true
            exact_text_check = $true
            negative_constraints_check = $true
            reference_asset_check = $true
            source_fingerprint_check = $true
            result = 'PASS'
        }
        asset = @{ status = 'QA_PASS'; retry_count = 0; provenance = 'test://asset/1'; file = 'archive://AIDAILY-TEST/header.png'; local_path = $generatedPath; sha256 = $generatedSha; width = 1280; height = 670 }
        asset_qa = @{ performed = $true; result = 'PASS'; checks = $qaChecks }
        transition = @{ requested_target = 'HUMAN_REVIEW_CANDIDATE'; stop_reason = '' }
    }
    $record.generation_contract.request_identity_sha256 = Get-NoteHeaderCanonicalJsonSha256 $record.tool_request
    return $record
}

function Invoke-Record {
    param($Record, [string]$RepositoryRoot, [string]$RecordPath)
    $Record | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $RecordPath -Encoding UTF8
    & $scriptUnderTest -RepositoryRoot $RepositoryRoot -RecordPath $RecordPath | Out-Null
}

function Test-RecordFails {
    param($Record, [string]$RepositoryRoot, [string]$RecordPath)
    try {
        Invoke-Record $Record $RepositoryRoot $RecordPath
        return $false
    }
    catch {
        return $true
    }
}

Describe 'Visual Production Control' {
    BeforeEach {
        $repo = Join-Path $TestDrive 'repo'
        $recordPath = Join-Path $TestDrive 'visual-record.json'
    }

    It '1. fails when Marketing Review invokes image generation' {
        $record = New-VisualRecord -RepositoryRoot $repo -Phase 'Marketing Review'
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '2. fails when the contract omits the no-series-label rule' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.generation_contract.requirement_ids = @($record.generation_contract.requirement_ids | Where-Object { $_ -ne 'no-series-label' })
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '3. fails when the actual request omits the speech-bubble prohibition' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.tool_request.included_requirement_ids = @($record.tool_request.included_requirement_ids | Where-Object { $_ -ne 'no-speech-bubbles' })
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '3b. fails when a requirement ID is present but its text is absent from the prompt' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.tool_request.prompt = $record.tool_request.prompt.Replace('Do not use speech bubbles', '')
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '3c. fails when a Master-bound contract omits the reference asset' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.generation_contract.reference_assets = @()
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '3d. fails when the actual request substitutes a different Master file' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $substitutePath = Join-Path $repo 'runtime-assets/substitute.png'
        [IO.File]::WriteAllBytes($substitutePath, [Text.Encoding]::UTF8.GetBytes('different-image'))
        $record.tool_request.referenced_image_paths = @($substitutePath)
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '4. fails when the approved title is modified in the tool request' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.tool_request.text_verbatim = '変更されたタイトル'
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '5. fails when Human Review is requested before Asset QA' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.asset.status = 'GENERATED_UNVERIFIED'
        $record.asset_qa.performed = $false
        $record.asset_qa.result = 'NOT_RUN'
        $record.asset_qa.checks = @()
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '6. fails when a QA-failed asset requests ASSET_READY' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.asset.status = 'QA_FAIL'
        $record.asset_qa.result = 'FAIL'
        $record.transition.requested_target = 'ASSET_READY'
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '7. passes when only a QA-passed asset is shown as Human Review Candidate' {
        $record = New-VisualRecord -RepositoryRoot $repo
        { Invoke-Record $record $repo $recordPath } | Should Not Throw
    }

    It '7b. requires note Header to use Formal Promotion instead of direct Asset Ready' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.transition.requested_target = 'ASSET_READY'
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '8. passes only after conflicting Creative Direction is dropped' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.generation_contract.creative_direction = @(@{ id = 'add-dialogue'; text = 'Add speech bubbles'; conflicts_with = @('no-speech-bubbles'); resolution = 'dropped' })
        { Invoke-Record $record $repo $recordPath } | Should Not Throw
    }

    It '8b. fails when Creative Direction overrides the template' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.generation_contract.creative_direction = @(@{ id = 'add-dialogue'; text = 'Add speech bubbles'; conflicts_with = @('no-speech-bubbles'); resolution = 'kept' })
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '9. fails when a resolved Source changes after contract assembly' {
        $record = New-VisualRecord -RepositoryRoot $repo
        Add-Content -LiteralPath (Join-Path $repo $record.source_manifest.sources[0].path) -Value 'changed' -Encoding UTF8
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }

    It '10. resolves a non-AIDAILY education visual contract from its responsibility Source' {
        $record = New-VisualRecord -RepositoryRoot $repo -Phase 'Educational Visual Production' -ArtifactType 'education-visual' -ProfileId 'education-visual-v1'
        { Invoke-Record $record $repo $recordPath } | Should Not Throw
    }

    It 'keeps an uninspectable asset outside normal Human Review' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.generation_contract.inspection_capability = 'human-required'
        $record.asset.status = 'QA_UNVERIFIED'
        $record.asset_qa.performed = $false
        $record.asset_qa.result = 'HUMAN_REQUIRED'
        $record.asset_qa.checks = @()
        $record.transition.requested_target = 'HUMAN_ASSET_QA'
        { Invoke-Record $record $repo $recordPath } | Should Not Throw
    }

    It 'fails closed when the automatic retry limit is reached' {
        $record = New-VisualRecord -RepositoryRoot $repo
        $record.asset.status = 'QA_FAIL'
        $record.asset.retry_count = 2
        $record.asset_qa.result = 'FAIL'
        $record.transition.requested_target = 'RETRY'
        (Test-RecordFails $record $repo $recordPath) | Should Be $true
    }
}
