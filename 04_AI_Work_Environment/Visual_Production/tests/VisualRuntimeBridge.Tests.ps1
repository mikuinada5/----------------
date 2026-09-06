$builder = Join-Path $PSScriptRoot '../scripts/New-VisualGenerationRecord.ps1'
$newReceipt = Join-Path $PSScriptRoot '../scripts/New-VisualRuntimeReceipt.ps1'
$testReceipt = Join-Path $PSScriptRoot '../scripts/Test-VisualRuntimeReceipt.ps1'
$testVisual = Join-Path $PSScriptRoot '../scripts/Test-VisualProduction.ps1'

function Write-TestPngHeader([string]$Path, [int]$Width = 1280, [int]$Height = 670) {
    $bytes = [byte[]](137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,
        (($Width -shr 24) -band 255),(($Width -shr 16) -band 255),(($Width -shr 8) -band 255),($Width -band 255),
        (($Height -shr 24) -band 255),(($Height -shr 16) -band 255),(($Height -shr 8) -band 255),($Height -band 255))
    [IO.File]::WriteAllBytes($Path, $bytes)
}

function New-RuntimeFixture {
    param([string]$Root)
    $noteRoot = Join-Path $Root '07_Note_Production'
    New-Item -ItemType Directory -Path $noteRoot -Force | Out-Null
    $masterPath = Join-Path $Root 'runtime-assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png'
    New-Item -ItemType Directory -Path (Split-Path -Parent $masterPath) -Force | Out-Null
    Write-TestPngHeader $masterPath
    $masterSha = (Get-FileHash -LiteralPath $masterPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $profilePath = Join-Path $noteRoot '00_note制作・公開システム.md'
    $profileText = @'
# note system
**Status:** Current / Operational v2.4
<!-- VISUAL_PROFILE_BEGIN:aidaily-header-v1 -->
<!-- VISUAL_PROFILE_META:{"width":1280,"height":670,"master_asset_id":"NOTE-HEADER-MASTER-v1.0","master_asset_version":"v1.0","master_asset_locator":"AI/04_Personal_Archive/Original/ChatGPT/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png","master_asset_sha256":"__MASTER_SHA__"} -->
| ID | Level | Requirement |
|---|---|---|
| master-reference | MUST | use the approved Master image |
| note-horizontal | MUST | horizontal note header |
| current-dimensions | MUST | use current dimensions |
| human-left | MUST | place Human on the left |
| kei-right | MUST | place Kei on the right |
| comic-style | MUST | use manga style |
| white-background | MUST | keep a white background |
| black-pink-palette | MUST | use black and pink |
| master-title-replace | MUST | replace the Master title |
| title-exact | MUST | approved title verbatim |
| title-central | MUST | approved title is central |
| no-series-label | MUST_NOT | do not add series or magazine label |
| no-speech-bubbles | MUST_NOT | do not add speech bubbles |
| no-explanation-copy | MUST_NOT | do not add explanation copy |
| no-checklists | MUST_NOT | do not add checklists |
| no-additional-catch-copy | MUST_NOT | do not add catch copy |
| no-background-recolor | MUST_NOT | keep the background white |
| no-unverified-facts | MUST_NOT | do not add unverified facts |
| no-hype | MUST_NOT | do not add hype |
| no-poster-layout | MUST_NOT | do not create a poster or infographic |
| no-title-change | MUST_NOT | do not change the approved title |
| expressions | MAY | expressions may vary |
<!-- VISUAL_PROFILE_END:aidaily-header-v1 -->
'@
    $profileText.Replace('__MASTER_SHA__', $masterSha) | Set-Content -LiteralPath $profilePath -Encoding UTF8

    $sha = (Get-FileHash -LiteralPath $profilePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $now = [DateTimeOffset]::Now.ToString('o')
    $relative = '07_Note_Production/00_note制作・公開システム.md'
    $manifest = @{
        schema_version = 'source-manifest/v2'
        task_id = 'AIDAILY-003-HEADER'
        production_version = 'H2'
        repository = @{ resolved_commit_sha = ('a' * 40); resolved_at = $now }
        resolution = @{
            method = 'responsibility-root-discovery'
            responsibility_roots = @('07_Note_Production')
            discovered_candidates = @(@{ path = $relative; status = 'Current / Operational v2.4'; version = 'v2.4'; decision = 'selected'; reason = 'canonical note SOP' })
        }
        sources = @(@{
            path = $relative; responsibility = 'note Header'; required = 'required'; status = 'Current / Operational v2.4'
            version_or_revision = 'v2.4'; file_sha256 = $sha; read_by = 'runtime-test'; read_at = $now
            read_task_id = 'AIDAILY-003-HEADER'; read_scope = 'Header profile'; applied_to = @('visual-template','asset-qa')
            dependencies = @(); dependency_check = 'PASS'; conflict_check = 'PASS'
        })
        g2 = @{
            resolution_complete = $true; current_canonical_unique = $true; dependency_closure_complete = $true
            same_task_read_complete = $true; source_fingerprint_frozen = $true; result = 'PASS'; passed_at = $now
        }
    }
    $manifestPath = Join-Path $Root 'source-manifest.json'
    $manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    return @{ ProfilePath = $profilePath; ManifestPath = $manifestPath; MasterPath = $masterPath }
}

function New-ValidRecord {
    param([string]$Root, [string]$RecordPath)
    $fixture = New-RuntimeFixture -Root $Root
    & $builder -RepositoryRoot $Root -SourceManifestPath $fixture.ManifestPath -ProfileSourcePath $fixture.ProfilePath `
        -ProfileId 'aidaily-header-v1' -TaskId 'AIDAILY-003-HEADER' -ProductionVersion 'H2' `
        -Phase 'Header Production' -ArtifactType 'note-header' -ApprovedTitle 'AIに仕事を任せたら、私の仕事が増えた話' `
        -Width 1280 -Height 670 -MasterAssetPath $fixture.MasterPath -OutputPath $RecordPath | Out-Null
    return Get-Content -Raw -LiteralPath $RecordPath -Encoding UTF8 | ConvertFrom-Json
}

function Save-Json {
    param($Value, [string]$Path)
    $Value | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-Throws {
    param([scriptblock]$Action)
    try { & $Action; return $false } catch { return $true }
}

Describe 'Visual Runtime Bridge' {
    BeforeEach {
        $repo = Join-Path $TestDrive 'repo'
        $recordPath = Join-Path $TestDrive 'record.json'
        $requestPath = Join-Path $TestDrive 'request.json'
        $receiptPath = Join-Path $TestDrive 'receipt.json'
    }

    It '1. blocks Chat intent when no Generation Contract exists' {
        (Test-Throws { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment chat -OutputPath $receiptPath }) | Should Be $true
    }

    It '2. fails when Current Source Resolution is not PASS' {
        $fixture = New-RuntimeFixture -Root $repo
        $manifest = Get-Content -Raw -LiteralPath $fixture.ManifestPath -Encoding UTF8 | ConvertFrom-Json
        $manifest.g2.resolution_complete = $false
        Save-Json $manifest $fixture.ManifestPath
        (Test-Throws { & $builder -RepositoryRoot $repo -SourceManifestPath $fixture.ManifestPath -ProfileSourcePath $fixture.ProfilePath -ProfileId 'aidaily-header-v1' -TaskId 'AIDAILY-003-HEADER' -ProductionVersion 'H2' -Phase 'Header Production' -ArtifactType 'note-header' -ApprovedTitle 'approved title' -Width 1280 -Height 670 -MasterAssetPath $fixture.MasterPath -OutputPath $recordPath }) | Should Be $true
    }

    It '3. fails when the Generation Contract is not validated' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $record.preflight.contract_completeness_check = $false
        Save-Json $record $recordPath
        Save-Json $record.tool_request $requestPath
        (Test-Throws { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image tool listed' -AssetInspectionEvidence 'image viewer listed' }) | Should Be $true
    }

    It '4. fails when Prompt Assembly QA is not PASS' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $record.preflight.prompt_assembly_check = $false
        $record.preflight.result = 'FAIL'
        Save-Json $record $recordPath
        Save-Json $record.tool_request $requestPath
        (Test-Throws { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image tool listed' -AssetInspectionEvidence 'image viewer listed' }) | Should Be $true
    }

    It '5. detects a mismatch between validated and actual Tool Request' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $actual = $record.tool_request
        $actual.prompt = $actual.prompt + "`nAdd a magazine label"
        Save-Json $actual $requestPath
        (Test-Throws { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image tool listed' -AssetInspectionEvidence 'image viewer listed' }) | Should Be $true
    }

    It '6. fails if an unverified generated asset is promoted to Human Review' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $record.asset.status = 'GENERATED_UNVERIFIED'
        $record.transition.requested_target = 'HUMAN_REVIEW_CANDIDATE'
        Save-Json $record $recordPath
        (Test-Throws { & $testVisual -RepositoryRoot $repo -RecordPath $recordPath }) | Should Be $true
    }

    It '7. rejects a forged Platform-enforced PASS' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        Save-Json $record.tool_request $requestPath
        & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image tool listed' -AssetInspectionEvidence 'image viewer listed' | Out-Null
        $receipt = Get-Content -Raw -LiteralPath $receiptPath -Encoding UTF8 | ConvertFrom-Json
        $receipt.environment = 'responses-api'
        $receipt.route = 'platform-tool-choice'
        $receipt.capabilities.platform_tool_choice_control = 'VERIFIED'
        $receipt.boundary.repository_enforcement_scope = 'platform-tool-choice'
        $receipt.boundary.platform_enforced = $true
        Save-Json $receipt $receiptPath
        (Test-Throws { & $testReceipt -RepositoryRoot $repo -RecordPath $recordPath -ReceiptPath $receiptPath -ActualToolRequestPath $requestPath }) | Should Be $true
    }

    It '8. places every AIDAILY MUST_NOT in the validated request' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $expected = @('no-series-label','no-speech-bubbles','no-explanation-copy','no-checklists','no-additional-catch-copy','no-background-recolor','no-unverified-facts','no-hype','no-poster-layout','no-title-change')
        foreach ($id in $expected) {
            ($record.tool_request.negative_requirement_ids -contains $id) | Should Be $true
            $record.tool_request.prompt | Should Match ([Regex]::Escape("[$id]"))
        }
    }

    It '9. preserves the approved title exactly' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $record.tool_request.text_verbatim | Should Be 'AIに仕事を任せたら、私の仕事が増えた話'
        $record.generation_contract.approved_text.title | Should Be $record.tool_request.text_verbatim
    }

    It '10. records and validates the Local Codex capability profile' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        Save-Json $record.tool_request $requestPath
        { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image_gen.imagegen present in current tool inventory' -AssetInspectionEvidence 'view_image present in current tool inventory' | Out-Null } | Should Not Throw
        $receipt = Get-Content -Raw -LiteralPath $receiptPath -Encoding UTF8 | ConvertFrom-Json
        $receipt.result | Should Be 'REQUEST_BOUND'
        $receipt.boundary.platform_enforced | Should Be $false
        $receipt.capabilities.client_visible_request_binding | Should Be 'VERIFIED'
    }

    It '10b. binds the approved Master identity and runtime path into the actual request' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        $record.generation_contract.reference_assets.Count | Should Be 1
        $record.generation_contract.reference_assets[0].asset_id | Should Be 'NOTE-HEADER-MASTER-v1.0'
        $record.tool_request.referenced_image_paths.Count | Should Be 1
        (Test-Path -LiteralPath $record.tool_request.referenced_image_paths[0] -PathType Leaf) | Should Be $true
    }

    It '10c. fails before generation when the supplied Master SHA does not match the canonical profile' {
        $fixture = New-RuntimeFixture -Root $repo
        $wrongMaster = Join-Path $repo 'runtime-assets/wrong-master.png'
        [IO.File]::WriteAllBytes($wrongMaster, [Text.Encoding]::UTF8.GetBytes('wrong-master-image'))
        (Test-Throws { & $builder -RepositoryRoot $repo -SourceManifestPath $fixture.ManifestPath -ProfileSourcePath $fixture.ProfilePath -ProfileId 'aidaily-header-v1' -TaskId 'AIDAILY-003-HEADER' -ProductionVersion 'H2' -Phase 'Header Production' -ArtifactType 'note-header' -ApprovedTitle 'approved title' -Width 1280 -Height 670 -MasterAssetPath $wrongMaster -OutputPath $recordPath }) | Should Be $true
    }

    It '10d. fails before generation when a Master-bound profile has no runtime Master path' {
        $fixture = New-RuntimeFixture -Root $repo
        (Test-Throws { & $builder -RepositoryRoot $repo -SourceManifestPath $fixture.ManifestPath -ProfileSourcePath $fixture.ProfilePath -ProfileId 'aidaily-header-v1' -TaskId 'AIDAILY-003-HEADER' -ProductionVersion 'H2' -Phase 'Header Production' -ArtifactType 'note-header' -ApprovedTitle 'approved title' -Width 1280 -Height 670 -OutputPath $recordPath }) | Should Be $true
    }

    It '11. records Chat direct generation as a Platform-boundary block' {
        $record = New-ValidRecord -Root $repo -RecordPath $recordPath
        (Test-Throws { & $newReceipt -RepositoryRoot $repo -RecordPath $recordPath -Environment chat -OutputPath $receiptPath }) | Should Be $true
        $receipt = Get-Content -Raw -LiteralPath $receiptPath -Encoding UTF8 | ConvertFrom-Json
        $receipt.result | Should Be 'BLOCKED_PLATFORM_BOUNDARY'
        $receipt.boundary.platform_enforced | Should Be $false
    }
}
