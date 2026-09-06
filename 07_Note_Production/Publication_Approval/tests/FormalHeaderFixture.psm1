Import-Module (Join-Path $PSScriptRoot '../../../04_AI_Work_Environment/Visual_Production/scripts/HeaderAssetPromotion.psm1') -Force

function Write-TestHeaderPng {
    param([Parameter(Mandatory)][string]$Path, [int]$Width = 1280, [int]$Height = 670)
    $bytes = [byte[]](137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,
        (($Width -shr 24) -band 255),(($Width -shr 16) -band 255),(($Width -shr 8) -band 255),($Width -band 255),
        (($Height -shr 24) -band 255),(($Height -shr 16) -band 255),(($Height -shr 8) -band 255),($Height -band 255))
    [IO.File]::WriteAllBytes($Path, $bytes)
}

function New-TestFormalHeaderRecord {
    param(
        [Parameter(Mandatory)][string]$Root,
        [Parameter(Mandatory)][string]$HeaderPath,
        [Parameter(Mandatory)][string]$HeaderQaPath,
        [Parameter(Mandatory)][string]$ArticleId,
        [Parameter(Mandatory)][string]$DisplayTitle,
        [Parameter(Mandatory)][string]$CanonicalPointer
    )
    $support = @{}
    foreach ($name in @('actual-request.json','profile.md','master.png','runtime-receipt.json','header-human-approval.json')) {
        $path = Join-Path $Root $name
        if (-not (Test-Path -LiteralPath $path)) { "test evidence $name" | Set-Content -LiteralPath $path -Encoding utf8 -NoNewline }
        $support[$name] = $path
    }
    $fileSha = { param($p) (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() }
    $headerSha = & $fileSha $HeaderPath
    $qaSha = & $fileSha $HeaderQaPath
    $masterSha = & $fileSha $support['master.png']
    $requestIdentity = & $fileSha $support['actual-request.json']
    $runtimeSha = & $fileSha $support['runtime-receipt.json']
    $approvalSha = & $fileSha $support['header-human-approval.json']
    $formal = [ordered]@{
        schema_version = 'note-formal-header-asset/v1'; promotion_version = 'note-header-promotion/v1'; state = 'FORMAL_HEADER_ASSET'; formal_asset_id = ''; identity_sha256 = ''
        article_id = $ArticleId; approved_header_title = $DisplayTitle
        asset = [ordered]@{ file = $CanonicalPointer; local_path = $HeaderPath; sha256 = $headerSha; width = 1280; height = 670; provenance = 'test://visual-production-bridge' }
        master_template = [ordered]@{ asset_id = 'NOTE-HEADER-MASTER-v1.0'; version = 'v1.0'; canonical_locator = 'AI/04_Personal_Archive/Original/ChatGPT/NOTE_HEADER_MASTER_TEMPLATE_v1.0.png'; expected_sha256 = $masterSha; actual_sha256 = $masterSha; width = 1280; height = 670; provenance = 'canonical-profile:aidaily-header-v1@test' }
        generation_contract = [ordered]@{ profile_id = 'aidaily-header-v1'; production_version = 'H1'; source_manifest_identity = ('a' * 64); visual_record_sha256 = $qaSha; visual_record_local_path = $HeaderQaPath; actual_tool_request_sha256 = $requestIdentity; actual_tool_request_local_path = $support['actual-request.json']; request_identity_sha256 = $requestIdentity; profile_source_local_path = $support['profile.md']; master_asset_local_path = $support['master.png'] }
        route_evidence = [ordered]@{ implementation_id = 'repo-skill:visual-production-bridge/v1'; route = 'repository-skill-request-bound'; runtime_receipt_sha256 = $runtimeSha; runtime_receipt_local_path = $support['runtime-receipt.json']; result = 'REQUEST_BOUND' }
        asset_qa = [ordered]@{ status = 'PASS'; visual_record_sha256 = $qaSha }
        human_approval = [ordered]@{ event_id = 'HE-HEADER-TEST'; evidence_sha256 = $approvalSha; evidence_local_path = $support['header-human-approval.json'] }
        eligibility = [ordered]@{ final_review_package = $true; direct_generation_retroactive_promotion = $false }
    }
    $identity = Get-HeaderFormalIdentity $formal
    $formal.formal_asset_id = $identity.formal_asset_id; $formal.identity_sha256 = $identity.identity_sha256
    $path = Join-Path $Root 'formal-header-asset.json'
    $formal | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $path -Encoding utf8 -NoNewline
    [pscustomobject]@{ record = $formal; path = $path; sha256 = (& $fileSha $path) }
}

Export-ModuleMember -Function New-TestFormalHeaderRecord, Write-TestHeaderPng
