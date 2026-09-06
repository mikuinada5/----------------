Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'FinalReviewPackageCompiler.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'PublicationApproval.psm1') -Force

function Get-NoteBundleFileSha256 {
    param([Parameter(Mandatory)][string]$LiteralPath)
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "BUNDLE_FILE_NOT_FOUND: $LiteralPath" }
    (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-NoteBundleTextSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Assert-NoteBundleJsonSchema {
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][string]$SchemaPath,
        [Parameter(Mandatory)][string]$Label
    )
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "$Label`_NOT_FOUND: $LiteralPath" }
    try { $valid = Test-Json -LiteralPath $LiteralPath -SchemaFile $SchemaPath -ErrorAction Stop }
    catch { throw "$Label`_SCHEMA_FAIL: $($_.Exception.Message)" }
    if (-not $valid) { throw "$Label`_SCHEMA_FAIL" }
}

function ConvertTo-NoteBundleConditions {
    param([Parameter(Mandatory)]$Conditions)
    [ordered]@{
        access_boundary = [ordered]@{
            mode = [string]$Conditions.access_boundary.mode
            free_end_marker = [string]$Conditions.access_boundary.free_end_marker
            membership_start_marker = [string]$Conditions.access_boundary.membership_start_marker
        }
        membership = [ordered]@{
            enabled = [bool]$Conditions.membership.enabled
            name = [string]$Conditions.membership.name
            plan = [string]$Conditions.membership.plan
        }
        magazine = [ordered]@{
            enabled = [bool]$Conditions.magazine.enabled
            name = [string]$Conditions.magazine.name
        }
        price = [ordered]@{
            currency = [string]$Conditions.price.currency
            amount = [int]$Conditions.price.amount
        }
        tags = @($Conditions.tags | Sort-Object -CaseSensitive)
        other_conditions = @($Conditions.other_conditions | Sort-Object -CaseSensitive)
    }
}

function Get-NotePublicationConditionsIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Conditions)
    $normalized = ConvertTo-NoteBundleConditions $Conditions
    $canonical = $normalized | ConvertTo-Json -Depth 30 -Compress
    [pscustomobject]@{
        identity_sha256 = Get-NoteBundleTextSha256 $canonical
        canonical_json = $canonical
        normalized = $normalized
    }
}

function Get-NotePublicationBundleIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Manifest)
    $payload = [ordered]@{
        article_id = [string]$Manifest.article_id
        package = [ordered]@{
            package_id = [string]$Manifest.package.package_id
            identity_sha256 = ([string]$Manifest.package.identity_sha256).ToLowerInvariant()
            sha256 = ([string]$Manifest.package.sha256).ToLowerInvariant()
        }
        body_sha256 = ([string]$Manifest.body.sha256).ToLowerInvariant()
        header_sha256 = ([string]$Manifest.header.sha256).ToLowerInvariant()
        publication_conditions = [ordered]@{
            identity_sha256 = ([string]$Manifest.publication_conditions.identity_sha256).ToLowerInvariant()
            sha256 = ([string]$Manifest.publication_conditions.sha256).ToLowerInvariant()
        }
        source_manifest = [ordered]@{
            manifest_id = [string]$Manifest.source_manifest.manifest_id
            sha256 = ([string]$Manifest.source_manifest.sha256).ToLowerInvariant()
        }
        approval = [ordered]@{
            approval_id = [string]$Manifest.approval_evidence.approval_id
            sha256 = ([string]$Manifest.approval_evidence.sha256).ToLowerInvariant()
            human_event_id = [string]$Manifest.human_event.event_id
            human_event_sha256 = ([string]$Manifest.human_event.sha256).ToLowerInvariant()
        }
        destination = [ordered]@{
            service = [string]$Manifest.destination.service
            account_id = [string]$Manifest.destination.account_id
            publication_target = [string]$Manifest.destination.publication_target
        }
        purpose = [string]$Manifest.purpose
    }
    $canonical = $payload | ConvertTo-Json -Depth 30 -Compress
    $identity = Get-NoteBundleTextSha256 $canonical
    $safeArticle = ([string]$Manifest.article_id -replace '[^A-Za-z0-9._-]', '-').Trim('-')
    if (-not $safeArticle) { throw 'BUNDLE_ARTICLE_ID_NOT_FILESYSTEM_SAFE' }
    [pscustomobject]@{
        bundle_id = "PB-$safeArticle-$identity"
        identity_sha256 = $identity
        canonical_identity_json = $canonical
        safe_article_id = $safeArticle
    }
}

function Test-NotePublicationBundleIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Manifest)
    $expected = Get-NotePublicationBundleIdentity $Manifest
    if ($Manifest.bundle_id -cne $expected.bundle_id) { throw 'BUNDLE_IDENTITY_MISMATCH' }
    if ($Manifest.identity_sha256 -cne $expected.identity_sha256) { throw 'BUNDLE_IDENTITY_SHA_MISMATCH' }
    [pscustomobject]@{ result = 'PASS'; bundle_id = $expected.bundle_id; identity_sha256 = $expected.identity_sha256 }
}

function Test-NoteBundleDestinationEquality {
    param($Left, $Right)
    $Left.service -ceq $Right.service -and
        $Left.account_id -ceq $Right.account_id -and
        $Left.publication_target -ceq $Right.publication_target
}

function Get-NoteBundlePaths {
    param([Parameter(Mandatory)][string]$BundleDirectory)
    [ordered]@{
        manifest = Join-Path $BundleDirectory 'manifest.json'
        body = Join-Path $BundleDirectory 'body.md'
        header = Join-Path $BundleDirectory 'header.png'
        publication_conditions = Join-Path $BundleDirectory 'publication-conditions.json'
        approval = Join-Path $BundleDirectory 'approval-evidence.json'
        human_event = Join-Path $BundleDirectory 'human-event.json'
        source_manifest = Join-Path $BundleDirectory 'source-manifest.json'
        package = Join-Path $BundleDirectory 'final-review-package.json'
    }
}

function Test-NotePublicationBundleDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BundleDirectory,
        [Parameter(Mandatory)][string]$ExpectedPackageId
    )
    try {
        if (-not (Test-Path -LiteralPath $BundleDirectory -PathType Container)) { throw 'PUBLICATION_BUNDLE_DIRECTORY_NOT_FOUND' }
        $paths = Get-NoteBundlePaths $BundleDirectory
        $expectedNames = @('manifest.json','body.md','header.png','publication-conditions.json','approval-evidence.json','human-event.json','source-manifest.json','final-review-package.json')
        $actualNames = @(Get-ChildItem -LiteralPath $BundleDirectory -File | ForEach-Object Name)
        if (@(Get-ChildItem -LiteralPath $BundleDirectory -Directory).Count) { throw 'BUNDLE_UNEXPECTED_DIRECTORY' }
        foreach ($name in $expectedNames) {
            if ($actualNames -cnotcontains $name) { throw "BUNDLE_FILE_MISSING: $name" }
        }
        $unexpected = @($actualNames | Where-Object { $expectedNames -cnotcontains $_ })
        if ($unexpected.Count) { throw ('BUNDLE_UNEXPECTED_FILE: ' + ($unexpected -join ', ')) }

        $schemaRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'schemas'
        Assert-NoteBundleJsonSchema $paths.manifest (Join-Path $schemaRoot 'publication_bundle_manifest.schema.json') 'BUNDLE_MANIFEST'
        Assert-NoteBundleJsonSchema $paths.publication_conditions (Join-Path $schemaRoot 'publication_conditions.schema.json') 'PUBLICATION_CONDITIONS'
        Assert-NoteBundleJsonSchema $paths.package (Join-Path $schemaRoot 'final_review_package.schema.json') 'PACKAGE'
        Assert-NoteBundleJsonSchema $paths.approval (Join-Path $schemaRoot 'publication_approval.schema.json') 'APPROVAL'
        Assert-NoteBundleJsonSchema $paths.human_event (Join-Path $schemaRoot 'human_event.schema.json') 'HUMAN_EVENT'

        $manifest = Get-Content -LiteralPath $paths.manifest -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $package = Get-Content -LiteralPath $paths.package -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $conditionsDocument = Get-Content -LiteralPath $paths.publication_conditions -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $approval = Get-Content -LiteralPath $paths.approval -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $event = Get-Content -LiteralPath $paths.human_event -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50

        Test-NotePublicationBundleIdentity $manifest | Out-Null
        Test-NoteFinalReviewPackageIdentity $package | Out-Null
        if ($manifest.body.path -cne 'body.md' -or $manifest.header.path -cne 'header.png') { throw 'BUNDLE_FILE_PATH_BINDING_MISMATCH' }
        if ($manifest.package.package_id -cne $ExpectedPackageId -or $package.package_id -cne $ExpectedPackageId) { throw 'BUNDLE_PACKAGE_ID_MISMATCH' }

        $fileBindings = @(
            @{ Name='BODY'; Path=$paths.body; Expected=$manifest.body.sha256 },
            @{ Name='HEADER'; Path=$paths.header; Expected=$manifest.header.sha256 },
            @{ Name='PUBLICATION_CONDITIONS'; Path=$paths.publication_conditions; Expected=$manifest.publication_conditions.sha256 },
            @{ Name='APPROVAL_EVIDENCE'; Path=$paths.approval; Expected=$manifest.approval_evidence.sha256 },
            @{ Name='HUMAN_EVENT'; Path=$paths.human_event; Expected=$manifest.human_event.sha256 },
            @{ Name='SOURCE_MANIFEST'; Path=$paths.source_manifest; Expected=$manifest.source_manifest.sha256 },
            @{ Name='FINAL_REVIEW_PACKAGE'; Path=$paths.package; Expected=$manifest.package.sha256 }
        )
        foreach ($binding in $fileBindings) {
            $actualSha = Get-NoteBundleFileSha256 $binding.Path
            if ($actualSha -cne [string]$binding.Expected) { throw "$($binding.Name)_SHA_MISMATCH" }
        }

        $conditionIdentity = Get-NotePublicationConditionsIdentity $conditionsDocument.conditions
        if ($conditionsDocument.identity_sha256 -cne $conditionIdentity.identity_sha256 -or $manifest.publication_conditions.identity_sha256 -cne $conditionIdentity.identity_sha256) { throw 'PUBLICATION_CONDITIONS_IDENTITY_MISMATCH' }
        $packageConditions = Get-NotePublicationConditionsIdentity $package.publication_conditions
        if ($packageConditions.canonical_json -cne $conditionIdentity.canonical_json) { throw 'PUBLICATION_CONDITIONS_PACKAGE_MISMATCH' }
        if ($package.d3_body.sha256 -cne $manifest.body.sha256) { throw 'BODY_PACKAGE_MISMATCH' }
        if ($package.header.sha256 -cne $manifest.header.sha256) { throw 'HEADER_PACKAGE_MISMATCH' }
        if ($package.source_manifest.manifest_id -cne $manifest.source_manifest.manifest_id -or $package.source_manifest.sha256 -cne $manifest.source_manifest.sha256) { throw 'SOURCE_MANIFEST_PACKAGE_MISMATCH' }
        if ($package.identity_sha256 -cne $manifest.package.identity_sha256) { throw 'FINAL_REVIEW_PACKAGE_IDENTITY_MISMATCH' }

        if ($approval.package_id -cne $package.package_id -or $event.context.package_id -cne $package.package_id) { throw 'APPROVAL_PACKAGE_ID_MISMATCH' }
        if ($approval.package_identity_sha256 -cne $package.identity_sha256 -or $event.context.package_identity_sha256 -cne $package.identity_sha256) { throw 'APPROVAL_PACKAGE_IDENTITY_MISMATCH' }
        if ($approval.package_sha256 -cne $manifest.package.sha256 -or $event.context.package_sha256 -cne $manifest.package.sha256) { throw 'APPROVAL_PACKAGE_SHA_MISMATCH' }
        if ($approval.approval_id -cne $manifest.approval_evidence.approval_id) { throw 'APPROVAL_ID_MISMATCH' }
        if ($approval.human_event_id -cne $event.event_id -or $approval.human_event_sha256 -cne $manifest.human_event.sha256) { throw 'APPROVAL_HUMAN_EVENT_MISMATCH' }
        if ($event.event_id -cne $manifest.human_event.event_id) { throw 'HUMAN_EVENT_ID_MISMATCH' }
        if (-not (Test-NoteBundleDestinationEquality $manifest.destination $package.destination) -or -not (Test-NoteBundleDestinationEquality $approval.destination $package.destination) -or -not (Test-NoteBundleDestinationEquality $event.context.destination $package.destination)) { throw 'BUNDLE_DESTINATION_MISMATCH' }
        if ($manifest.destination.service -cne 'note' -or $manifest.purpose -cne 'publish') { throw 'BUNDLE_DESTINATION_PURPOSE_MISMATCH' }
        if ($package.purpose -cne 'NOTE_PUBLICATION' -or $approval.purpose -cne 'NOTE_PUBLICATION' -or $event.context.purpose -cne 'NOTE_PUBLICATION') { throw 'APPROVAL_PURPOSE_MISMATCH' }

        [pscustomobject]@{
            result = 'PASS'
            state = 'HANDOFF_VERIFIED'
            previous_state = 'HANDOFF_PENDING'
            next_gate = 'G5'
            bundle_id = $manifest.bundle_id
            bundle_identity_sha256 = $manifest.identity_sha256
            package_id = $package.package_id
            paths = [pscustomobject]$paths
        }
    } catch {
        if ($_.Exception.Message.StartsWith('BUNDLE_HANDOFF_FAIL:')) { throw }
        throw "BUNDLE_HANDOFF_FAIL: $($_.Exception.Message)"
    }
}

function Expand-NotePublicationBundleSecure {
    param(
        [Parameter(Mandatory)][string]$BundleZipPath,
        [Parameter(Mandatory)][string]$ExtractionDirectory
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (-not (Test-Path -LiteralPath $BundleZipPath -PathType Leaf)) { throw 'BUNDLE_ZIP_NOT_FOUND' }
    if ([IO.Path]::GetExtension($BundleZipPath) -cne '.zip') { throw 'BUNDLE_ZIP_REQUIRED' }
    $root = [IO.Path]::GetFullPath($ExtractionDirectory)
    if (Test-Path -LiteralPath $root) {
        if (@(Get-ChildItem -LiteralPath $root -Force).Count) { throw 'HANDOFF_EXTRACTION_DIRECTORY_NOT_EMPTY' }
    } else { New-Item -ItemType Directory -Path $root | Out-Null }
    $prefix = $root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    $archive = [IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($BundleZipPath))
    try {
        foreach ($entry in $archive.Entries) {
            $relative = $entry.FullName.Replace('/', [IO.Path]::DirectorySeparatorChar)
            $target = [IO.Path]::GetFullPath((Join-Path $root $relative))
            if (-not $target.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'BUNDLE_ZIP_PATH_ESCAPE' }
            if ([string]::IsNullOrEmpty($entry.Name)) {
                New-Item -ItemType Directory -Force -Path $target | Out-Null
                continue
            }
            $parent = Split-Path $target -Parent
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
            if (Test-Path -LiteralPath $target) { throw 'BUNDLE_ZIP_DUPLICATE_ENTRY' }
            $input = $entry.Open()
            $output = [IO.File]::Open($target, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
            try { $input.CopyTo($output) } finally { $output.Dispose(); $input.Dispose() }
        }
    } finally { $archive.Dispose() }
}

function Test-NotePublicationBundleHandoff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BundleZipPath,
        [Parameter(Mandatory)][string]$ExpectedPackageId,
        [Parameter(Mandatory)][string]$ExtractionDirectory
    )
    try {
        Expand-NotePublicationBundleSecure $BundleZipPath $ExtractionDirectory
        $extractionRoot = [IO.Path]::GetFullPath($ExtractionDirectory)
        $topLevel = @(Get-ChildItem -LiteralPath $extractionRoot -Force)
        if ($topLevel.Count -ne 1 -or $topLevel[0].Name -cne 'PublicationBundle' -or -not $topLevel[0].PSIsContainer) { throw 'BUNDLE_ZIP_TOP_LEVEL_INVALID' }
        $bundleDirectory = Join-Path $extractionRoot 'PublicationBundle'
        $result = Test-NotePublicationBundleDirectory -BundleDirectory $bundleDirectory -ExpectedPackageId $ExpectedPackageId
        $result | Add-Member -NotePropertyName transport -NotePropertyValue 'single_zip'
        $result | Add-Member -NotePropertyName zip_path -NotePropertyValue ([IO.Path]::GetFullPath($BundleZipPath))
        $result
    } catch {
        if ($_.Exception.Message.StartsWith('BUNDLE_HANDOFF_FAIL:')) { throw }
        throw "BUNDLE_HANDOFF_FAIL: $($_.Exception.Message)"
    }
}

function New-NotePublicationBundle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$HumanEventPath,
        [Parameter(Mandatory)][string]$ApprovalPath,
        [Parameter(Mandatory)][string]$SourceManifestPath,
        [Parameter(Mandatory)][string]$D3BodyPath,
        [Parameter(Mandatory)][string]$HeaderPath,
        [Parameter(Mandatory)][string]$OutputDirectory
    )
    try {
        Test-NoteApprovedPackageBinding -PackagePath $PackagePath -HumanEventPath $HumanEventPath -ApprovalPath $ApprovalPath -ActualPackagePath $PackagePath -SourceManifestPath $SourceManifestPath -D3BodyPath $D3BodyPath -HeaderPath $HeaderPath | Out-Null
        $package = Get-Content -LiteralPath $PackagePath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $approval = Get-Content -LiteralPath $ApprovalPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $event = Get-Content -LiteralPath $HumanEventPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 50
        $conditionsIdentity = Get-NotePublicationConditionsIdentity $package.publication_conditions
        $conditionsDocument = [ordered]@{
            schema_version = 'note-publication-conditions/v1'
            identity_sha256 = $conditionsIdentity.identity_sha256
            conditions = $conditionsIdentity.normalized
        }
        $conditionsJson = $conditionsDocument | ConvertTo-Json -Depth 40
        $conditionsSha = Get-NoteBundleTextSha256 $conditionsJson

        $manifest = [ordered]@{
            schema_version = 'note-publication-bundle-manifest/v1'
            builder_version = 'note-publication-bundle-builder/v1'
            bundle_id = ''
            identity_sha256 = ''
            state = 'BUNDLE_SEALED'
            handoff_state = 'HANDOFF_PENDING'
            article_id = [string]$package.article_id
            package = [ordered]@{
                package_id = [string]$package.package_id
                identity_sha256 = [string]$package.identity_sha256
                path = 'final-review-package.json'
                sha256 = Get-NoteBundleFileSha256 $PackagePath
            }
            body = [ordered]@{ path = 'body.md'; sha256 = Get-NoteBundleFileSha256 $D3BodyPath }
            header = [ordered]@{ path = 'header.png'; sha256 = Get-NoteBundleFileSha256 $HeaderPath }
            publication_conditions = [ordered]@{ path = 'publication-conditions.json'; sha256 = $conditionsSha; identity_sha256 = $conditionsIdentity.identity_sha256 }
            approval_evidence = [ordered]@{ path = 'approval-evidence.json'; approval_id = [string]$approval.approval_id; sha256 = Get-NoteBundleFileSha256 $ApprovalPath }
            human_event = [ordered]@{ path = 'human-event.json'; event_id = [string]$event.event_id; sha256 = Get-NoteBundleFileSha256 $HumanEventPath }
            source_manifest = [ordered]@{ path = 'source-manifest.json'; manifest_id = [string]$package.source_manifest.manifest_id; sha256 = Get-NoteBundleFileSha256 $SourceManifestPath }
            destination = [ordered]@{
                service = 'note'
                account_id = [string]$package.destination.account_id
                publication_target = [string]$package.destination.publication_target
            }
            purpose = 'publish'
        }
        $identity = Get-NotePublicationBundleIdentity $manifest
        $manifest.bundle_id = $identity.bundle_id
        $manifest.identity_sha256 = $identity.identity_sha256
        $manifestJson = $manifest | ConvertTo-Json -Depth 50

        if (-not (Test-Path -LiteralPath $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory | Out-Null }
        $outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
        $versionRoot = Join-Path $outputRoot $manifest.bundle_id
        $bundleDirectory = Join-Path $versionRoot 'PublicationBundle'
        $zipPath = Join-Path $versionRoot ($identity.safe_article_id + '_PublicationBundle.zip')
        if (Test-Path -LiteralPath $versionRoot) {
            Test-NotePublicationBundleDirectory -BundleDirectory $bundleDirectory -ExpectedPackageId $package.package_id | Out-Null
            if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) { throw 'BUNDLE_IMMUTABLE_CONFLICT: transport ZIP missing from existing sealed Bundle' }
            return [pscustomobject]@{
                result = 'PASS'; previous_state = 'HUMAN_APPROVED'; state = 'BUNDLE_SEALED'; handoff_state = 'HANDOFF_PENDING'
                bundle_id = $manifest.bundle_id; bundle_identity_sha256 = $manifest.identity_sha256; package_id = $package.package_id
                bundle_directory = $bundleDirectory; zip_path = $zipPath; transport = 'single_zip'
            }
        }

        $temporaryRoot = Join-Path $outputRoot ('.bundle-build-' + [guid]::NewGuid().ToString('N'))
        $temporaryBundle = Join-Path $temporaryRoot 'PublicationBundle'
        New-Item -ItemType Directory -Path $temporaryBundle | Out-Null
        try {
            Copy-Item -LiteralPath $D3BodyPath -Destination (Join-Path $temporaryBundle 'body.md')
            Copy-Item -LiteralPath $HeaderPath -Destination (Join-Path $temporaryBundle 'header.png')
            Copy-Item -LiteralPath $ApprovalPath -Destination (Join-Path $temporaryBundle 'approval-evidence.json')
            Copy-Item -LiteralPath $HumanEventPath -Destination (Join-Path $temporaryBundle 'human-event.json')
            Copy-Item -LiteralPath $SourceManifestPath -Destination (Join-Path $temporaryBundle 'source-manifest.json')
            Copy-Item -LiteralPath $PackagePath -Destination (Join-Path $temporaryBundle 'final-review-package.json')
            Set-Content -LiteralPath (Join-Path $temporaryBundle 'publication-conditions.json') -Value $conditionsJson -Encoding utf8 -NoNewline
            Set-Content -LiteralPath (Join-Path $temporaryBundle 'manifest.json') -Value $manifestJson -Encoding utf8 -NoNewline
            Test-NotePublicationBundleDirectory -BundleDirectory $temporaryBundle -ExpectedPackageId $package.package_id | Out-Null
            $temporaryZip = Join-Path $temporaryRoot ($identity.safe_article_id + '_PublicationBundle.zip')
            Compress-Archive -LiteralPath $temporaryBundle -DestinationPath $temporaryZip -CompressionLevel Optimal
            Move-Item -LiteralPath $temporaryRoot -Destination $versionRoot
        } catch {
            if (Test-Path -LiteralPath $temporaryRoot) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force }
            throw
        }

        [pscustomobject]@{
            result = 'PASS'
            previous_state = 'HUMAN_APPROVED'
            state = 'BUNDLE_SEALED'
            handoff_state = 'HANDOFF_PENDING'
            bundle_id = $manifest.bundle_id
            bundle_identity_sha256 = $manifest.identity_sha256
            package_id = $package.package_id
            bundle_directory = $bundleDirectory
            zip_path = $zipPath
            transport = 'single_zip'
        }
    } catch {
        if ($_.Exception.Message.StartsWith('BUNDLE_IMMUTABLE_CONFLICT:')) { throw }
        if ($_.Exception.Message.StartsWith('BUNDLE_BUILD_FAIL:')) { throw }
        throw "BUNDLE_BUILD_FAIL: $($_.Exception.Message)"
    }
}

function Test-NotePublicationBundleE2EPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$BundleZipPath,
        [Parameter(Mandatory)][string]$ExpectedPackageId,
        [Parameter(Mandatory)][string]$ExtractionDirectory
    )
    $handoff = Test-NotePublicationBundleHandoff -BundleZipPath $BundleZipPath -ExpectedPackageId $ExpectedPackageId -ExtractionDirectory $ExtractionDirectory
    $paths = $handoff.paths
    $g5Args = @{
        PackagePath = $paths.package
        HumanEventPath = $paths.human_event
        ApprovalPath = $paths.approval
        ActualPackagePath = $paths.package
        SourceManifestPath = $paths.source_manifest
        D3BodyPath = $paths.body
        HeaderPath = $paths.header
    }
    Test-NoteG5Approval @g5Args | Out-Null
    $plan = Test-NotePublicationE2EPlan @g5Args
    [pscustomobject]@{
        result = 'PASS'
        states = @('HANDOFF_VERIFIED','G5_PASS','NOTE_DRAFT_CREATE','BODY_APPLY','HEADER_APPLY','PUBLICATION_CONDITIONS_APPLY','SETTINGS_VERIFY','PUBLISHED','PPV_PASS')
        bundle_id = $handoff.bundle_id
        package_id = $handoff.package_id
        publication_steps = $plan.steps
        requires_additional_human_approval = $false
        stopped_for_human = $false
    }
}

Export-ModuleMember -Function Get-NoteBundleFileSha256, Get-NotePublicationConditionsIdentity, Get-NotePublicationBundleIdentity, Test-NotePublicationBundleIdentity, Test-NotePublicationBundleDirectory, Test-NotePublicationBundleHandoff, New-NotePublicationBundle, Test-NotePublicationBundleE2EPlan
