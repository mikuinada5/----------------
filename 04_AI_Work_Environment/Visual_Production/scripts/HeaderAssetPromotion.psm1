Set-StrictMode -Version Latest
Import-Module (Join-Path $PSScriptRoot 'NoteHeaderRouting.psm1') -Force

function Assert-HeaderPromotionSchema {
    param([Parameter(Mandatory)][string]$LiteralPath, [Parameter(Mandatory)][string]$SchemaName, [Parameter(Mandatory)][string]$Label)
    $schemaPath = Join-Path (Split-Path $PSScriptRoot -Parent) "schemas/$SchemaName"
    try { $valid = Test-Json -LiteralPath $LiteralPath -SchemaFile $schemaPath -ErrorAction Stop }
    catch { throw "$Label`_SCHEMA_FAIL: $($_.Exception.Message)" }
    if (-not $valid) { throw "$Label`_SCHEMA_FAIL" }
}

function Resolve-HeaderEvidencePath {
    param([Parameter(Mandatory)][string]$RecordDirectory, [Parameter(Mandatory)][string]$LocalPath)
    if ([IO.Path]::IsPathRooted($LocalPath)) { return [IO.Path]::GetFullPath($LocalPath) }
    [IO.Path]::GetFullPath((Join-Path $RecordDirectory $LocalPath))
}

function Get-HeaderFormalIdentity {
    param([Parameter(Mandatory)]$FormalAsset)
    $payload = [ordered]@{
        article_id = [string]$FormalAsset.article_id
        approved_header_title = [string]$FormalAsset.approved_header_title
        asset = [ordered]@{ file = [string]$FormalAsset.asset.file; sha256 = ([string]$FormalAsset.asset.sha256).ToLowerInvariant(); width = [int]$FormalAsset.asset.width; height = [int]$FormalAsset.asset.height; provenance = [string]$FormalAsset.asset.provenance }
        master_template = [ordered]@{ asset_id = [string]$FormalAsset.master_template.asset_id; version = [string]$FormalAsset.master_template.version; canonical_locator = [string]$FormalAsset.master_template.canonical_locator; expected_sha256 = ([string]$FormalAsset.master_template.expected_sha256).ToLowerInvariant(); actual_sha256 = ([string]$FormalAsset.master_template.actual_sha256).ToLowerInvariant(); width = [int]$FormalAsset.master_template.width; height = [int]$FormalAsset.master_template.height; provenance = [string]$FormalAsset.master_template.provenance }
        generation_contract = [ordered]@{ profile_id = [string]$FormalAsset.generation_contract.profile_id; production_version = [string]$FormalAsset.generation_contract.production_version; source_manifest_identity = ([string]$FormalAsset.generation_contract.source_manifest_identity).ToLowerInvariant(); visual_record_sha256 = ([string]$FormalAsset.generation_contract.visual_record_sha256).ToLowerInvariant(); actual_tool_request_sha256 = ([string]$FormalAsset.generation_contract.actual_tool_request_sha256).ToLowerInvariant(); request_identity_sha256 = ([string]$FormalAsset.generation_contract.request_identity_sha256).ToLowerInvariant() }
        route_evidence = [ordered]@{ implementation_id = [string]$FormalAsset.route_evidence.implementation_id; route = [string]$FormalAsset.route_evidence.route; runtime_receipt_sha256 = ([string]$FormalAsset.route_evidence.runtime_receipt_sha256).ToLowerInvariant(); result = [string]$FormalAsset.route_evidence.result }
        asset_qa = [ordered]@{ status = [string]$FormalAsset.asset_qa.status; visual_record_sha256 = ([string]$FormalAsset.asset_qa.visual_record_sha256).ToLowerInvariant() }
        human_approval = [ordered]@{ event_id = [string]$FormalAsset.human_approval.event_id; evidence_sha256 = ([string]$FormalAsset.human_approval.evidence_sha256).ToLowerInvariant() }
    }
    $sha = Get-NoteHeaderCanonicalJsonSha256 $payload
    $safe = ([string]$FormalAsset.article_id -replace '[^A-Za-z0-9._-]', '-').Trim('-')
    if (-not $safe) { throw 'HEADER_ARTICLE_ID_NOT_SAFE' }
    [pscustomobject]@{ formal_asset_id = "FHA-$safe-$sha"; identity_sha256 = $sha }
}

function Assert-HeaderApprovalIntent {
    param([Parameter(Mandatory)][string]$Statement)
    if ($Statement.Trim() -notmatch '^(?i:ok|approved?|これでいい|これでok|承認|採用|この画像でいい|このheaderでいい)[!！。\s]*$') {
        throw 'HEADER_HUMAN_APPROVAL_NOT_EXPLICIT'
    }
}

function Test-NoteFormalHeaderAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$FormalAssetPath,
        [string]$ExpectedArticleId,
        [string]$ExpectedHeaderTitle,
        [string]$ExpectedHeaderPath,
        [switch]$RecordOnly
    )
    Assert-HeaderPromotionSchema $FormalAssetPath 'formal_header_asset.schema.json' 'FORMAL_HEADER_ASSET'
    $formal = Get-Content -LiteralPath $FormalAssetPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
    $identity = Get-HeaderFormalIdentity $formal
    if ($formal.formal_asset_id -cne $identity.formal_asset_id -or $formal.identity_sha256 -cne $identity.identity_sha256) { throw 'FORMAL_HEADER_ASSET_IDENTITY_MISMATCH' }
    if ($ExpectedArticleId -and $formal.article_id -cne $ExpectedArticleId) { throw 'FORMAL_HEADER_ARTICLE_ID_MISMATCH' }
    if ($ExpectedHeaderTitle -and $formal.approved_header_title -cne $ExpectedHeaderTitle) { throw 'FORMAL_HEADER_TITLE_MISMATCH' }

    $recordDirectory = Split-Path ([IO.Path]::GetFullPath($FormalAssetPath)) -Parent
    $headerPath = if ($ExpectedHeaderPath) { [IO.Path]::GetFullPath($ExpectedHeaderPath) } else { Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.asset.local_path) }
    $visualPath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.generation_contract.visual_record_local_path)
    $requestPath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.generation_contract.actual_tool_request_local_path)
    $profilePath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.generation_contract.profile_source_local_path)
    $masterPath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.generation_contract.master_asset_local_path)
    $receiptPath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.route_evidence.runtime_receipt_local_path)
    $approvalPath = Resolve-HeaderEvidencePath $recordDirectory ([string]$formal.human_approval.evidence_local_path)

    foreach ($item in @($headerPath,$visualPath,$requestPath,$profilePath,$masterPath,$receiptPath,$approvalPath)) {
        if (-not (Test-Path -LiteralPath $item -PathType Leaf)) { throw "FORMAL_HEADER_EVIDENCE_NOT_FOUND: $item" }
    }
    if ((Get-NoteHeaderFileSha256 $headerPath) -ne [string]$formal.asset.sha256) { throw 'FORMAL_HEADER_BYTES_MISMATCH' }
    if ((Get-NoteHeaderFileSha256 $visualPath) -ne [string]$formal.generation_contract.visual_record_sha256) { throw 'FORMAL_HEADER_VISUAL_RECORD_SHA_MISMATCH' }
    if ((Get-NoteHeaderFileSha256 $receiptPath) -ne [string]$formal.route_evidence.runtime_receipt_sha256) { throw 'FORMAL_HEADER_RUNTIME_RECEIPT_SHA_MISMATCH' }
    if ((Get-NoteHeaderFileSha256 $approvalPath) -ne [string]$formal.human_approval.evidence_sha256) { throw 'FORMAL_HEADER_HUMAN_APPROVAL_SHA_MISMATCH' }
    $dimensions = Get-NoteHeaderPngDimensions $headerPath
    if ($dimensions.width -ne 1280 -or $dimensions.height -ne 670) { throw 'FORMAL_HEADER_DIMENSIONS_MISMATCH' }
    if ($RecordOnly) {
        return [pscustomobject]@{ result = 'PASS'; state = 'FORMAL_HEADER_ASSET'; formal_asset_id = $formal.formal_asset_id; identity_sha256 = $formal.identity_sha256; header_sha256 = $formal.asset.sha256; evidence_revalidation = 'SEALED_RECORD' }
    }

    & (Join-Path $PSScriptRoot 'Test-VisualProduction.ps1') -RepositoryRoot $RepositoryRoot -RecordPath $visualPath | Out-Null
    & (Join-Path $PSScriptRoot 'Test-VisualRuntimeReceipt.ps1') -RepositoryRoot $RepositoryRoot -RecordPath $visualPath -ReceiptPath $receiptPath -ActualToolRequestPath $requestPath | Out-Null
    $record = Get-Content -LiteralPath $visualPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
    $receipt = Get-Content -LiteralPath $receiptPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30
    $approval = Get-Content -LiteralPath $approvalPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30
    Assert-HeaderPromotionSchema $approvalPath 'header_human_approval.schema.json' 'HEADER_HUMAN_APPROVAL'
    Assert-HeaderApprovalIntent ([string]$approval.statement)
    $master = Resolve-NoteHeaderMaster -ProfileSourcePath $profilePath -ProfileId 'aidaily-header-v1' -MasterAssetPath $masterPath
    $request = Get-Content -LiteralPath $requestPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
    $requestIdentity = Get-NoteHeaderCanonicalJsonSha256 $request

    if ($record.artifact_type -ne 'note-header' -or $record.transition.requested_target -ne 'HUMAN_REVIEW_CANDIDATE' -or $record.asset_qa.result -ne 'PASS' -or $record.asset.status -ne 'QA_PASS') { throw 'FORMAL_HEADER_ASSET_QA_NOT_PASS' }
    if ($record.generation_contract.article_id -cne $formal.article_id -or $record.generation_contract.approved_text.title -cne $formal.approved_header_title) { throw 'FORMAL_HEADER_CONTRACT_BINDING_MISMATCH' }
    if ($record.asset.sha256 -ne $formal.asset.sha256 -or $record.asset.file -cne $formal.asset.file) { throw 'FORMAL_HEADER_ASSET_BINDING_MISMATCH' }
    if ($record.asset.width -ne 1280 -or $record.asset.height -ne 670) { throw 'FORMAL_HEADER_ASSET_DIMENSIONS_MISMATCH' }
    if ($requestIdentity -ne $formal.generation_contract.actual_tool_request_sha256 -or $requestIdentity -ne $formal.generation_contract.request_identity_sha256) { throw 'FORMAL_HEADER_REQUEST_BINDING_MISMATCH' }
    if ($receipt.environment -ne 'local-codex' -or $receipt.route -ne 'repository-skill-request-bound' -or $receipt.implementation_id -ne 'repo-skill:visual-production-bridge/v1' -or $receipt.result -ne 'REQUEST_BOUND') { throw 'FORMAL_HEADER_BRIDGE_ROUTE_MISSING' }
    if ($master.asset_id -ne $formal.master_template.asset_id -or $master.actual_sha256 -ne $formal.master_template.actual_sha256 -or $master.canonical_locator -ne $formal.master_template.canonical_locator) { throw 'FORMAL_HEADER_MASTER_BINDING_MISMATCH' }
    if ([DateTimeOffset]$approval.occurred_at -lt [DateTimeOffset]$approval.context.presented_at) { throw 'HEADER_HUMAN_APPROVAL_BEFORE_PRESENTATION' }
    foreach ($binding in @(
        @([string]$approval.context.article_id,[string]$formal.article_id,'ARTICLE'),
        @([string]$approval.context.approved_header_title,[string]$formal.approved_header_title,'TITLE'),
        @([string]$approval.context.generated_asset_sha256,[string]$formal.asset.sha256,'ASSET_SHA'),
        @([string]$approval.context.visual_record_sha256,[string]$formal.generation_contract.visual_record_sha256,'VISUAL_RECORD_SHA'),
        @([string]$approval.context.runtime_receipt_sha256,[string]$formal.route_evidence.runtime_receipt_sha256,'RUNTIME_RECEIPT_SHA'),
        @([string]$approval.context.actual_tool_request_sha256,[string]$formal.generation_contract.actual_tool_request_sha256,'REQUEST_SHA')
    )) { if ($binding[0] -cne $binding[1]) { throw "HEADER_HUMAN_APPROVAL_$($binding[2])_MISMATCH" } }
    [pscustomobject]@{ result = 'PASS'; state = 'FORMAL_HEADER_ASSET'; formal_asset_id = $formal.formal_asset_id; identity_sha256 = $formal.identity_sha256; header_sha256 = $formal.asset.sha256 }
}

function New-NoteFormalHeaderAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$VisualRecordPath,
        [Parameter(Mandatory)][string]$RuntimeReceiptPath,
        [Parameter(Mandatory)][string]$ActualToolRequestPath,
        [Parameter(Mandatory)][string]$GeneratedAssetPath,
        [Parameter(Mandatory)][string]$AssetCanonicalPointer,
        [Parameter(Mandatory)][string]$HumanApprovalPath,
        [Parameter(Mandatory)][string]$ProfileSourcePath,
        [string]$MasterAssetPath,
        [Parameter(Mandatory)][string]$OutputPath
    )
    & (Join-Path $PSScriptRoot 'Test-VisualProduction.ps1') -RepositoryRoot $RepositoryRoot -RecordPath $VisualRecordPath | Out-Null
    & (Join-Path $PSScriptRoot 'Test-VisualRuntimeReceipt.ps1') -RepositoryRoot $RepositoryRoot -RecordPath $VisualRecordPath -ReceiptPath $RuntimeReceiptPath -ActualToolRequestPath $ActualToolRequestPath | Out-Null
    Assert-HeaderPromotionSchema $HumanApprovalPath 'header_human_approval.schema.json' 'HEADER_HUMAN_APPROVAL'
    $record = Get-Content -LiteralPath $VisualRecordPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
    $receipt = Get-Content -LiteralPath $RuntimeReceiptPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30
    $approval = Get-Content -LiteralPath $HumanApprovalPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 30
    Assert-HeaderApprovalIntent ([string]$approval.statement)
    if ($record.artifact_type -ne 'note-header' -or $record.generation_contract.profile_id -ne 'aidaily-header-v1') { throw 'FORMAL_HEADER_WRONG_PROFILE' }
    if ($record.transition.requested_target -ne 'HUMAN_REVIEW_CANDIDATE' -or $record.asset_qa.result -ne 'PASS' -or $record.asset.status -ne 'QA_PASS') { throw 'FORMAL_HEADER_ASSET_QA_NOT_PASS' }
    if ($receipt.environment -ne 'local-codex' -or $receipt.route -ne 'repository-skill-request-bound' -or $receipt.implementation_id -ne 'repo-skill:visual-production-bridge/v1' -or $receipt.result -ne 'REQUEST_BOUND') { throw 'FORMAL_HEADER_BRIDGE_ROUTE_MISSING' }
    $resolveMasterArgs = @{ ProfileSourcePath = $ProfileSourcePath; ProfileId = 'aidaily-header-v1' }
    if (-not [string]::IsNullOrWhiteSpace($MasterAssetPath)) { $resolveMasterArgs.MasterAssetPath = $MasterAssetPath }
    $master = Resolve-NoteHeaderMaster @resolveMasterArgs
    $dimensions = Get-NoteHeaderPngDimensions $GeneratedAssetPath
    if ($dimensions.width -ne 1280 -or $dimensions.height -ne 670) { throw 'FORMAL_HEADER_DIMENSIONS_MISMATCH' }
    $assetSha = Get-NoteHeaderFileSha256 $GeneratedAssetPath
    $visualSha = Get-NoteHeaderFileSha256 $VisualRecordPath
    $receiptSha = Get-NoteHeaderFileSha256 $RuntimeReceiptPath
    $approvalSha = Get-NoteHeaderFileSha256 $HumanApprovalPath
    $request = Get-Content -LiteralPath $ActualToolRequestPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
    $requestIdentity = Get-NoteHeaderCanonicalJsonSha256 $request
    if ($record.asset.sha256 -ne $assetSha -or $record.asset.file -cne $AssetCanonicalPointer -or $record.asset.width -ne 1280 -or $record.asset.height -ne 670) { throw 'FORMAL_HEADER_GENERATED_ASSET_MISMATCH' }
    foreach ($binding in @(
        @([string]$approval.context.article_id,[string]$record.generation_contract.article_id,'ARTICLE'),
        @([string]$approval.context.approved_header_title,[string]$record.generation_contract.approved_text.title,'TITLE'),
        @([string]$approval.context.generated_asset_sha256,$assetSha,'ASSET_SHA'),
        @([string]$approval.context.visual_record_sha256,$visualSha,'VISUAL_RECORD_SHA'),
        @([string]$approval.context.runtime_receipt_sha256,$receiptSha,'RUNTIME_RECEIPT_SHA'),
        @([string]$approval.context.actual_tool_request_sha256,$requestIdentity,'REQUEST_SHA')
    )) { if ($binding[0] -cne $binding[1]) { throw "HEADER_HUMAN_APPROVAL_$($binding[2])_MISMATCH" } }
    if ([DateTimeOffset]$approval.occurred_at -lt [DateTimeOffset]$approval.context.presented_at) { throw 'HEADER_HUMAN_APPROVAL_BEFORE_PRESENTATION' }
    $formal = [ordered]@{
        schema_version = 'note-formal-header-asset/v1'; promotion_version = 'note-header-promotion/v1'; state = 'FORMAL_HEADER_ASSET'; formal_asset_id = ''; identity_sha256 = ''
        article_id = [string]$record.generation_contract.article_id; approved_header_title = [string]$record.generation_contract.approved_text.title
        asset = [ordered]@{ file = $AssetCanonicalPointer; local_path = [IO.Path]::GetFullPath($GeneratedAssetPath); sha256 = $assetSha; width = 1280; height = 670; provenance = [string]$record.asset.provenance }
        master_template = [ordered]@{ asset_id = $master.asset_id; version = $master.version; canonical_locator = $master.canonical_locator; expected_sha256 = $master.expected_sha256; actual_sha256 = $master.actual_sha256; width = $master.width; height = $master.height; provenance = $master.provenance }
        generation_contract = [ordered]@{ profile_id = 'aidaily-header-v1'; production_version = [string]$record.production_version; source_manifest_identity = [string]$record.source_manifest.fingerprint_sha256; visual_record_sha256 = $visualSha; visual_record_local_path = [IO.Path]::GetFullPath($VisualRecordPath); actual_tool_request_sha256 = $requestIdentity; actual_tool_request_local_path = [IO.Path]::GetFullPath($ActualToolRequestPath); request_identity_sha256 = [string]$record.generation_contract.request_identity_sha256; profile_source_local_path = [IO.Path]::GetFullPath($ProfileSourcePath); master_asset_local_path = $master.actual_path }
        route_evidence = [ordered]@{ implementation_id = [string]$receipt.implementation_id; route = [string]$receipt.route; runtime_receipt_sha256 = $receiptSha; runtime_receipt_local_path = [IO.Path]::GetFullPath($RuntimeReceiptPath); result = [string]$receipt.result }
        asset_qa = [ordered]@{ status = 'PASS'; visual_record_sha256 = $visualSha }
        human_approval = [ordered]@{ event_id = [string]$approval.event_id; evidence_sha256 = $approvalSha; evidence_local_path = [IO.Path]::GetFullPath($HumanApprovalPath) }
        eligibility = [ordered]@{ final_review_package = $true; direct_generation_retroactive_promotion = $false }
    }
    $identity = Get-HeaderFormalIdentity $formal
    $formal.formal_asset_id = $identity.formal_asset_id; $formal.identity_sha256 = $identity.identity_sha256
    $json = $formal | ConvertTo-Json -Depth 50
    if (Test-Path -LiteralPath $OutputPath) {
        if ((Get-Content -LiteralPath $OutputPath -Raw -Encoding UTF8) -cne $json) { throw 'FORMAL_HEADER_ASSET_IMMUTABLE_CONFLICT' }
    } else { Set-Content -LiteralPath $OutputPath -Value $json -Encoding utf8 -NoNewline }
    Test-NoteFormalHeaderAsset -RepositoryRoot $RepositoryRoot -FormalAssetPath $OutputPath -ExpectedArticleId $formal.article_id -ExpectedHeaderTitle $formal.approved_header_title -ExpectedHeaderPath $GeneratedAssetPath
}

Export-ModuleMember -Function Get-HeaderFormalIdentity, Test-NoteFormalHeaderAsset, New-NoteFormalHeaderAsset
