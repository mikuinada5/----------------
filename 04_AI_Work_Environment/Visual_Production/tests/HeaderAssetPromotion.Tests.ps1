$builder = Join-Path $PSScriptRoot '../scripts/New-VisualGenerationRecord.ps1'
$newReceipt = Join-Path $PSScriptRoot '../scripts/New-VisualRuntimeReceipt.ps1'
$promotionModule = Join-Path $PSScriptRoot '../scripts/HeaderAssetPromotion.psm1'
$routingModule = Join-Path $PSScriptRoot '../scripts/NoteHeaderRouting.psm1'
Import-Module $promotionModule -Force
Import-Module $routingModule -Force

function Save-HeaderJson([string]$Path, $Value) { $Value | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $Path -Encoding utf8 -NoNewline }
function Write-HeaderPng([string]$Path, [int]$Width = 1280, [int]$Height = 670, [byte]$Tail = 0) {
    $bytes = [byte[]](137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,
        (($Width -shr 24) -band 255),(($Width -shr 16) -band 255),(($Width -shr 8) -band 255),($Width -band 255),
        (($Height -shr 24) -band 255),(($Height -shr 16) -band 255),(($Height -shr 8) -band 255),($Height -band 255),$Tail)
    [IO.File]::WriteAllBytes($Path, $bytes)
}
function Header-Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Header-Throws([scriptblock]$Action, [string]$Expected = '') { try { & $Action | Out-Null; $false } catch { (-not $Expected -or $_.Exception.Message.Contains($Expected)) } }

function New-PromotionFixture([string]$Root) {
    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    'test repository' | Set-Content -LiteralPath (Join-Path $Root 'REPOSITORY_RULES.md') -Encoding utf8
    $noteRoot = Join-Path $Root '07_Note_Production'; New-Item -ItemType Directory -Path $noteRoot -Force | Out-Null
    $masterLocator = '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png'
    $masterManifestLocator = '04_AI_Work_Environment/Visual_Production/assets/NOTE_HEADER_MASTER_TEMPLATE_v1.0.json'
    $masterPath = Join-Path $Root $masterLocator; New-Item -ItemType Directory -Path (Split-Path $masterPath -Parent) -Force | Out-Null; Write-HeaderPng $masterPath
    $masterSha = Header-Sha $masterPath
    $masterManifest=[ordered]@{schema_version='note-header-master-asset/v1';asset_id='NOTE-HEADER-MASTER-v1.0';version='v1.0';file='NOTE_HEADER_MASTER_TEMPLATE_v1.0.png';repository_locator=$masterLocator;sha256=$masterSha;dimensions=@{width=1280;height=670};provenance=@{human_approved_origin='test';repository_copy_relationship='byte-identical';original_archive_locator='AI/test/master.png';origin_locator='AI/test/origin.png';repository_verified_on='2026-09-06'};visual_specification=@{canonical_source='07_Note_Production/00_note制作・公開システム.md';profile_id='aidaily-header-v1';role='test role';title_reuse='replace title'}}
    Save-HeaderJson (Join-Path $Root $masterManifestLocator) $masterManifest
    $profilePath = Join-Path $noteRoot '00_note制作・公開システム.md'
    $rules = @(
        @('master-reference','MUST','use the approved Master image'),@('note-horizontal','MUST','use a horizontal note header'),
        @('current-dimensions','MUST','use 1280x670'),@('human-left','MUST','place Human on the left'),@('kei-right','MUST','place Kei on the right'),
        @('comic-style','MUST','use manga style'),@('white-background','MUST','keep the background white'),@('black-pink-palette','MUST','use black and pink'),
        @('master-title-replace','MUST','replace the Master title'),@('title-exact','MUST','use the approved title verbatim'),@('title-central','MUST','make the title central'),
        @('no-series-label','MUST_NOT','do not add AIとの日常'),@('no-speech-bubbles','MUST_NOT','do not add speech bubbles'),
        @('no-explanation-copy','MUST_NOT','do not add explanatory copy'),@('no-checklists','MUST_NOT','do not add checklists'),
        @('no-additional-catch-copy','MUST_NOT','do not add catch copy'),@('no-background-recolor','MUST_NOT','do not recolor the background'),
        @('no-unverified-facts','MUST_NOT','do not add unverified facts'),@('no-hype','MUST_NOT','do not add hype'),
        @('no-poster-layout','MUST_NOT','do not create an infographic'),@('no-title-change','MUST_NOT','do not alter the title'),
        @('expressions','MAY','expressions may vary'),@('poses','MAY','poses may vary'),@('small-props','MAY','small props may be used'),@('minor-effects','MAY','minor effects may be used')
    )
    $table = @($rules | ForEach-Object { "| $($_[0]) | $($_[1]) | $($_[2]) |" }) -join "`n"
    @"
# note system
**Status:** Current / Operational v2.11
<!-- VISUAL_PROFILE_BEGIN:aidaily-header-v1 -->
<!-- VISUAL_PROFILE_META:{"width":1280,"height":670,"master_asset_id":"NOTE-HEADER-MASTER-v1.0","master_asset_version":"v1.0","master_asset_locator":"$masterLocator","master_asset_manifest":"$masterManifestLocator","master_asset_sha256":"$masterSha"} -->
| ID | Level | Requirement |
|---|---|---|
$table
<!-- VISUAL_PROFILE_END:aidaily-header-v1 -->
"@ | Set-Content -LiteralPath $profilePath -Encoding utf8 -NoNewline
    $relative = '07_Note_Production/00_note制作・公開システム.md'; $profileSha = Header-Sha $profilePath; $now = '2026-09-06T10:00:00+09:00'
    $manifest = [ordered]@{ schema_version='source-manifest/v2'; task_id='AIDAILY-TEST'; production_version='H1'; repository=@{resolved_commit_sha=('a'*40);resolved_at=$now}; resolution=@{method='responsibility-root-discovery';responsibility_roots=@('07_Note_Production');discovered_candidates=@(@{path=$relative;status='Current / Operational v2.11';version='v2.11';decision='selected';reason='canonical note SOP'})}; sources=@(@{path=$relative;responsibility='note Header';required='required';status='Current / Operational v2.11';version_or_revision='v2.11';file_sha256=$profileSha;read_by='promotion-test';read_at=$now;read_task_id='AIDAILY-TEST';read_scope='Header profile';applied_to=@('visual-template','asset-qa');dependencies=@();dependency_check='PASS';conflict_check='PASS'}); g2=@{resolution_complete=$true;current_canonical_unique=$true;dependency_closure_complete=$true;same_task_read_complete=$true;source_fingerprint_frozen=$true;result='PASS';passed_at=$now} }
    $manifestPath = Join-Path $Root 'source-manifest.json'; Save-HeaderJson $manifestPath $manifest
    $recordPath = Join-Path $Root 'visual-record.json'
    & $builder -RepositoryRoot $Root -SourceManifestPath $manifestPath -ProfileSourcePath $profilePath -ProfileId 'aidaily-header-v1' -TaskId 'AIDAILY-TEST' -ArticleId 'AIDAILY-TEST' -ProductionVersion 'H1' -Phase 'Header Production' -ArtifactType 'note-header' -ApprovedTitle 'Final title' -Width 1280 -Height 670 -MasterAssetPath $masterPath -OutputPath $recordPath | Out-Null
    $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json -AsHashtable -Depth 50
    $assetPath = Join-Path $Root 'header.png'; Write-HeaderPng $assetPath -Tail 1; $assetSha = Header-Sha $assetPath
    $record.asset = @{status='QA_PASS';retry_count=0;provenance='image_gen.imagegen:generated-output';file='archive://AIDAILY-TEST/header.png';local_path=$assetPath;sha256=$assetSha;width=1280;height=670}
    $record.asset_qa = @{performed=$true;result='PASS';checks=@($record.generation_contract.requirement_ids | ForEach-Object {@{requirement_id=$_;result='PASS'}})+@(@{requirement_id='dimensions';result='PASS'})}
    $record.transition = @{requested_target='HUMAN_REVIEW_CANDIDATE';stop_reason=''}; Save-HeaderJson $recordPath $record
    $requestPath = Join-Path $Root 'actual-request.json'; Save-HeaderJson $requestPath $record.tool_request
    $receiptPath = Join-Path $Root 'runtime-receipt.json'; & $newReceipt -RepositoryRoot $Root -RecordPath $recordPath -Environment local-codex -OutputPath $receiptPath -ActualToolRequestPath $requestPath -ImageGenerationToolEvidence 'image_gen.imagegen current capability' -AssetInspectionEvidence 'view_image current capability' | Out-Null
    $approvalPath = Join-Path $Root 'header-human-approval.json'
    $approval = [ordered]@{schema_version='note-header-human-approval/v1';event_id='HE-HEADER-TEST';actor_type='human';evidence_origin='human-response-event';occurred_at='2026-09-06T10:02:00+09:00';statement='これでOK';context=[ordered]@{stage='HEADER_ASSET_CANDIDATE_PRESENTED';presented_at='2026-09-06T10:01:00+09:00';article_id='AIDAILY-TEST';approved_header_title='Final title';generated_asset_sha256=$assetSha;visual_record_sha256=(Header-Sha $recordPath);runtime_receipt_sha256=(Header-Sha $receiptPath);actual_tool_request_sha256=(Get-NoteHeaderCanonicalJsonSha256 $record.tool_request);destination='NOTE_FINAL_REVIEW_PACKAGE';purpose='NOTE_HEADER_ASSET_PROMOTION'}}
    Save-HeaderJson $approvalPath $approval
    [pscustomobject]@{root=$Root;profile=$profilePath;master=$masterPath;manifest=$manifestPath;record=$recordPath;request=$requestPath;receipt=$receiptPath;asset=$assetPath;approval=$approvalPath;output=(Join-Path $Root 'formal-header.json')}
}

function Promote-Header($f) { New-NoteFormalHeaderAsset -RepositoryRoot $f.root -VisualRecordPath $f.record -RuntimeReceiptPath $f.receipt -ActualToolRequestPath $f.request -GeneratedAssetPath $f.asset -AssetCanonicalPointer 'archive://AIDAILY-TEST/header.png' -HumanApprovalPath $f.approval -ProfileSourcePath $f.profile -MasterAssetPath $f.master -OutputPath $f.output }

Describe 'note Header routing and Formal Asset Promotion Gate' {
    BeforeEach { $fixture = New-PromotionFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString())) }
    It 'A: rejects an unresolved Master Template' { Remove-Item $fixture.master; (Header-Throws { Resolve-NoteHeaderMaster -ProfileSourcePath $fixture.profile -ProfileId 'aidaily-header-v1' -MasterAssetPath $fixture.master } 'HEADER_MASTER_UNRESOLVED') | Should Be $true }
    It 'B: rejects a Master SHA mismatch' { Write-HeaderPng $fixture.master -Tail 9; (Header-Throws { Resolve-NoteHeaderMaster -ProfileSourcePath $fixture.profile -ProfileId 'aidaily-header-v1' -MasterAssetPath $fixture.master } 'HEADER_MASTER_SHA_MISMATCH') | Should Be $true }
    It 'C: rejects an Asset QA title mismatch' { $r=Get-Content $fixture.record -Raw|ConvertFrom-Json -AsHashtable -Depth 50; ($r.asset_qa.checks|Where-Object requirement_id -eq 'title-exact').result='FAIL'; Save-HeaderJson $fixture.record $r; (Header-Throws { Promote-Header $fixture }) | Should Be $true }
    It 'D-G: rejects series labels, speech bubbles, explanatory infographic content and recolored backgrounds' { foreach($id in @('no-series-label','no-speech-bubbles','no-explanation-copy','no-poster-layout','no-background-recolor')) { $f=New-PromotionFixture (Join-Path $TestDrive ([guid]::NewGuid().ToString())); $r=Get-Content $f.record -Raw|ConvertFrom-Json -AsHashtable -Depth 50; ($r.asset_qa.checks|Where-Object requirement_id -eq $id).result='FAIL'; Save-HeaderJson $f.record $r; (Header-Throws { Promote-Header $f }) | Should Be $true } }
    It 'H: rejects dimensions other than 1280x670' { Write-HeaderPng $fixture.asset -Width 1200; (Header-Throws { Promote-Header $fixture }) | Should Be $true }
    It 'I: routes Standard Chat direct generation to UNVERIFIED_NON_ASSET' { $route=Resolve-NoteHeaderProductionRoute -Environment chat; $route.formal_asset_eligible | Should Be $false; $route.state | Should Be 'UNVERIFIED_NON_ASSET' }
    It 'J: does not retroactively promote a direct image after Human OK' { $receipt=Get-Content $fixture.receipt -Raw|ConvertFrom-Json -AsHashtable -Depth 30; $receipt.environment='chat';$receipt.route='builtin-direct';$receipt.implementation_id='repository-boundary-audit/v1';$receipt.result='BLOCKED_PLATFORM_BOUNDARY';$receipt.boundary.repository_enforcement_scope='detect-only'; Save-HeaderJson $fixture.receipt $receipt; (Header-Throws { Promote-Header $fixture }) | Should Be $true }
    It 'K: rejects promotion with no Bridge route evidence' { $receipt=Get-Content $fixture.receipt -Raw|ConvertFrom-Json -AsHashtable -Depth 30; [void]$receipt.Remove('route'); Save-HeaderJson $fixture.receipt $receipt; (Header-Throws { Promote-Header $fixture }) | Should Be $true }
    It 'L: rejects Human Review Candidate before Asset QA' { $r=Get-Content $fixture.record -Raw|ConvertFrom-Json -AsHashtable -Depth 50;$r.asset.status='GENERATED_UNVERIFIED';$r.asset_qa.performed=$false;$r.asset_qa.result='NOT_RUN';$r.asset_qa.checks=@();Save-HeaderJson $fixture.record $r;(Header-Throws { Promote-Header $fixture }) | Should Be $true }
    It 'N: promotes only the fully matching Master, Contract, Bridge, QA and Human Approval set' { $result=Promote-Header $fixture; $result.result | Should Be 'PASS';$result.state | Should Be 'FORMAL_HEADER_ASSET';(Get-Content $fixture.output -Raw|ConvertFrom-Json).eligibility.final_review_package | Should Be $true }
    It 'stops at the Platform Boundary when the Bridge is unavailable' { $route=Resolve-NoteHeaderProductionRoute -Environment local-codex -BridgeAvailable:$false; $route.state | Should Be 'BLOCKED_PLATFORM_BOUNDARY';$route.formal_asset_eligible | Should Be $false }
}
