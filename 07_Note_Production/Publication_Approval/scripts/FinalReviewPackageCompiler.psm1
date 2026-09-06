Set-StrictMode -Version Latest

function Get-NoteCompilerFileSha256 {
    param([Parameter(Mandatory)][string]$LiteralPath)
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "FILE_NOT_FOUND: $LiteralPath" }
    (Get-FileHash -LiteralPath $LiteralPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-NoteCompilerTextSha256 {
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Assert-NoteCompilerJsonSchema {
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][string]$SchemaPath,
        [Parameter(Mandatory)][string]$Label
    )
    if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) { throw "$Label`_NOT_FOUND: $LiteralPath" }
    try {
        $valid = Test-Json -LiteralPath $LiteralPath -SchemaFile $SchemaPath -ErrorAction Stop
    } catch {
        throw "$Label`_SCHEMA_FAIL: $($_.Exception.Message)"
    }
    if (-not $valid) { throw "$Label`_SCHEMA_FAIL" }
}

function Resolve-NoteCompilerLocalPath {
    param(
        [Parameter(Mandatory)][string]$InputDirectory,
        [Parameter(Mandatory)][string]$LocalPath
    )
    if ([IO.Path]::IsPathRooted($LocalPath)) { return [IO.Path]::GetFullPath($LocalPath) }
    [IO.Path]::GetFullPath((Join-Path $InputDirectory $LocalPath))
}

function Assert-NoteCompilerArtifact {
    param(
        [Parameter(Mandatory)][string]$InputDirectory,
        [Parameter(Mandatory)]$Artifact,
        [Parameter(Mandatory)][string]$Label
    )
    $resolved = Resolve-NoteCompilerLocalPath $InputDirectory $Artifact.local_path
    $actual = Get-NoteCompilerFileSha256 $resolved
    $expected = ([string]$Artifact.sha256).ToLowerInvariant()
    if ($actual -ne $expected) { throw "$Label`_SHA_MISMATCH: expected=$expected actual=$actual" }
    [pscustomobject]@{ path = $resolved; sha256 = $actual }
}

function ConvertTo-NotePublicationConditions {
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

function Get-NoteFinalReviewIdentityPayload {
    param([Parameter(Mandatory)]$Package)
    [ordered]@{
        article_id = [string]$Package.article_id
        title = [string]$Package.title
        d3_body = [ordered]@{
            artifact_id = [string]$Package.d3_body.artifact_id
            file = [string]$Package.d3_body.file
            sha256 = ([string]$Package.d3_body.sha256).ToLowerInvariant()
        }
        marketing_review = [ordered]@{
            status = [string]$Package.marketing_review.status
            identity = [string]$Package.marketing_review.identity
            version = [string]$Package.marketing_review.version
            evidence = [ordered]@{
                artifact_id = [string]$Package.marketing_review.evidence.artifact_id
                file = [string]$Package.marketing_review.evidence.file
                sha256 = ([string]$Package.marketing_review.evidence.sha256).ToLowerInvariant()
            }
        }
        header = [ordered]@{
            asset_id = [string]$Package.header.asset_id
            file = [string]$Package.header.file
            sha256 = ([string]$Package.header.sha256).ToLowerInvariant()
            asset_qa = [ordered]@{
                status = [string]$Package.header.asset_qa.status
                evidence = [ordered]@{
                    artifact_id = [string]$Package.header.asset_qa.evidence.artifact_id
                    file = [string]$Package.header.asset_qa.evidence.file
                    sha256 = ([string]$Package.header.asset_qa.evidence.sha256).ToLowerInvariant()
                }
            }
        }
        publication_conditions = ConvertTo-NotePublicationConditions $Package.publication_conditions
        destination = [ordered]@{
            service = [string]$Package.destination.service
            account_id = [string]$Package.destination.account_id
            publication_target = [string]$Package.destination.publication_target
        }
        purpose = [string]$Package.purpose
        source_manifest = [ordered]@{
            manifest_id = [string]$Package.source_manifest.manifest_id
            file = [string]$Package.source_manifest.file
            sha256 = ([string]$Package.source_manifest.sha256).ToLowerInvariant()
        }
    }
}

function Get-NoteFinalReviewPackageIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Package)
    $payload = Get-NoteFinalReviewIdentityPayload $Package
    $canonical = $payload | ConvertTo-Json -Depth 40 -Compress
    $identity = Get-NoteCompilerTextSha256 $canonical
    $safeArticle = ([string]$Package.article_id -replace '[^A-Za-z0-9._-]', '-').Trim('-')
    if (-not $safeArticle) { throw 'ARTICLE_ID_NOT_FILESYSTEM_SAFE' }
    [pscustomobject]@{
        package_id = "FRP-$safeArticle-$identity"
        identity_sha256 = $identity
        canonical_identity_json = $canonical
    }
}

function Test-NoteFinalReviewPackageIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Package)
    $expected = Get-NoteFinalReviewPackageIdentity $Package
    if ($Package.package_id -cne $expected.package_id) { throw 'FINAL_REVIEW_PACKAGE_IDENTITY_MISMATCH' }
    if ($Package.identity_sha256 -cne $expected.identity_sha256) { throw 'FINAL_REVIEW_PACKAGE_IDENTITY_SHA_MISMATCH' }
    [pscustomobject]@{ result = 'PASS'; package_id = $expected.package_id; identity_sha256 = $expected.identity_sha256 }
}

function New-NoteFinalReviewPresentationText {
    param(
        [Parameter(Mandatory)]$Package,
        [Parameter(Mandatory)][string]$PackageSha256
    )
    $membership = "enabled=$($Package.publication_conditions.membership.enabled); name=$($Package.publication_conditions.membership.name); plan=$($Package.publication_conditions.membership.plan)"
    $magazine = "enabled=$($Package.publication_conditions.magazine.enabled); name=$($Package.publication_conditions.magazine.name)"
    $tags = @($Package.publication_conditions.tags) -join ' / '
    $other = if (@($Package.publication_conditions.other_conditions).Count) { @($Package.publication_conditions.other_conditions) -join ' / ' } else { '(なし)' }
    $text = @"
# note Final Review Package

- Package ID: $($Package.package_id)
- Package identity SHA-256: $($Package.identity_sha256)
- Package file SHA-256: $PackageSha256
- State: READY_FOR_FINAL_REVIEW
- Approval: PENDING
- Destination / Purpose: note / NOTE_PUBLICATION

## 1. 最終本文

### $($Package.title)

$($Package.d3_body.content)

## 2. Header

- Asset ID: $($Package.header.asset_id)
- Canonical pointer: $($Package.header.file)
- SHA-256: $($Package.header.sha256)
- Asset QA: PASS
- Asset QA Evidence: $($Package.header.asset_qa.evidence.artifact_id) / $($Package.header.asset_qa.evidence.file)

## 3. 無料／Membership境界

- Mode: $($Package.publication_conditions.access_boundary.mode)
- 無料範囲末尾: $($Package.publication_conditions.access_boundary.free_end_marker)
- Membership限定開始位置: $($Package.publication_conditions.access_boundary.membership_start_marker)

## 4. Membership

$membership

## 5. Magazine

$magazine

## 6. price

$($Package.publication_conditions.price.amount) $($Package.publication_conditions.price.currency)

## 7. tags

$tags

## 8. その他Publication Conditions

$other

## Marketing Review / Source

- Marketing Review: PASS
- Marketing identity / version: $($Package.marketing_review.identity) / $($Package.marketing_review.version)
- Marketing Evidence: $($Package.marketing_review.evidence.artifact_id) / $($Package.marketing_review.evidence.file)
- Source Manifest: $($Package.source_manifest.manifest_id) / $($Package.source_manifest.file) / $($Package.source_manifest.sha256)
"@
    $text.TrimStart()
}

function Assert-NoteFinalReviewPresentation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackagePath,
        [Parameter(Mandatory)][string]$PresentationPath
    )
    $schemaRoot = Join-Path (Split-Path $PSScriptRoot -Parent) 'schemas'
    Assert-NoteCompilerJsonSchema $PackagePath (Join-Path $schemaRoot 'final_review_package.schema.json') 'PACKAGE'
    if (-not (Test-Path -LiteralPath $PresentationPath -PathType Leaf)) { throw "FINAL_REVIEW_PRESENTATION_NOT_FOUND: $PresentationPath" }
    $package = Get-Content -LiteralPath $PackagePath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 40
    Test-NoteFinalReviewPackageIdentity $package | Out-Null
    $presentation = Get-Content -LiteralPath $PresentationPath -Raw -Encoding UTF8
    $required = @(
        '# note Final Review Package',
        '## 1. 最終本文',
        '## 2. Header',
        '## 3. 無料／Membership境界',
        '## 4. Membership',
        '## 5. Magazine',
        '## 6. price',
        '## 7. tags',
        '## 8. その他Publication Conditions',
        [string]$package.package_id,
        [string]$package.identity_sha256,
        [string]$package.d3_body.content,
        [string]$package.header.asset_id,
        [string]$package.publication_conditions.access_boundary.free_end_marker,
        [string]$package.publication_conditions.access_boundary.membership_start_marker,
        [string]$package.publication_conditions.membership.name,
        [string]$package.publication_conditions.membership.plan,
        [string]$package.publication_conditions.magazine.name,
        [string]$package.publication_conditions.price.amount,
        [string]$package.marketing_review.identity,
        [string]$package.source_manifest.manifest_id
    )
    $required += @($package.publication_conditions.tags)
    $required += @($package.publication_conditions.other_conditions)
    $missing = @($required | Where-Object { $_ -and -not $presentation.Contains($_) })
    if ($missing.Count) { throw ('FINAL_REVIEW_PRESENTATION_INCOMPLETE: ' + ($missing -join ', ')) }
    [pscustomobject]@{ result = 'PASS'; package_id = $package.package_id; required_section_count = 8 }
}

function Write-NoteImmutableText {
    param(
        [Parameter(Mandatory)][string]$LiteralPath,
        [Parameter(Mandatory)][string]$Content,
        [Parameter(Mandatory)][string]$Label
    )
    if (Test-Path -LiteralPath $LiteralPath) {
        $existing = Get-Content -LiteralPath $LiteralPath -Raw -Encoding UTF8
        if ($existing -cne $Content) { throw "IMMUTABLE_PACKAGE_CONFLICT: $Label $LiteralPath" }
        return
    }
    Set-Content -LiteralPath $LiteralPath -Value $Content -Encoding utf8 -NoNewline
}

function New-NoteFinalReviewPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$InputPath,
        [Parameter(Mandatory)][string]$OutputDirectory
    )
    try {
        $root = Split-Path $PSScriptRoot -Parent
        $schemaRoot = Join-Path $root 'schemas'
        Assert-NoteCompilerJsonSchema $InputPath (Join-Path $schemaRoot 'final_review_package_input.schema.json') 'FINAL_PACKAGE_INPUT'
        $input = Get-Content -LiteralPath $InputPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 40
        $inputDirectory = Split-Path ([IO.Path]::GetFullPath($InputPath)) -Parent

        $bodyCheck = Assert-NoteCompilerArtifact $inputDirectory $input.d3_body 'D3_BODY'
        $marketingCheck = Assert-NoteCompilerArtifact $inputDirectory $input.marketing_review.evidence 'MARKETING_REVIEW_EVIDENCE'
        $headerCheck = Assert-NoteCompilerArtifact $inputDirectory $input.header 'HEADER'
        $headerQaCheck = Assert-NoteCompilerArtifact $inputDirectory $input.header.asset_qa.evidence 'HEADER_QA_EVIDENCE'
        $sourceCheck = Assert-NoteCompilerArtifact $inputDirectory $input.source_manifest 'SOURCE_MANIFEST'
        $bodyContent = Get-Content -LiteralPath $bodyCheck.path -Raw -Encoding UTF8
        if (-not $bodyContent) { throw 'D3_BODY_EMPTY' }
        if ($input.publication_conditions.membership.enabled -and (-not $input.publication_conditions.membership.name -or -not $input.publication_conditions.membership.plan)) { throw 'MEMBERSHIP_INCOMPLETE' }
        if ($input.publication_conditions.magazine.enabled -and -not $input.publication_conditions.magazine.name) { throw 'MAGAZINE_INCOMPLETE' }

        $package = [ordered]@{
            schema_version = 'note-final-review-package/v2'
            compiler_version = 'note-final-review-package-compiler/v1'
            package_id = ''
            identity_sha256 = ''
            state = 'READY_FOR_FINAL_REVIEW'
            article_id = [string]$input.article_id
            title = [string]$input.title
            d3_body = [ordered]@{
                artifact_id = [string]$input.d3_body.artifact_id
                file = [string]$input.d3_body.file
                sha256 = $bodyCheck.sha256
                content = $bodyContent
            }
            marketing_review = [ordered]@{
                status = 'PASS'
                identity = [string]$input.marketing_review.identity
                version = [string]$input.marketing_review.version
                evidence = [ordered]@{
                    artifact_id = [string]$input.marketing_review.evidence.artifact_id
                    file = [string]$input.marketing_review.evidence.file
                    sha256 = $marketingCheck.sha256
                }
            }
            header = [ordered]@{
                asset_id = [string]$input.header.asset_id
                file = [string]$input.header.file
                sha256 = $headerCheck.sha256
                asset_qa = [ordered]@{
                    status = 'PASS'
                    evidence = [ordered]@{
                        artifact_id = [string]$input.header.asset_qa.evidence.artifact_id
                        file = [string]$input.header.asset_qa.evidence.file
                        sha256 = $headerQaCheck.sha256
                    }
                }
            }
            publication_conditions = ConvertTo-NotePublicationConditions $input.publication_conditions
            destination = [ordered]@{
                service = 'note'
                account_id = [string]$input.destination.account_id
                publication_target = [string]$input.destination.publication_target
            }
            purpose = 'NOTE_PUBLICATION'
            source_manifest = [ordered]@{
                manifest_id = [string]$input.source_manifest.manifest_id
                file = [string]$input.source_manifest.file
                sha256 = $sourceCheck.sha256
            }
            approval = [ordered]@{ status = 'PENDING' }
        }
        $identity = Get-NoteFinalReviewPackageIdentity $package
        $package.package_id = $identity.package_id
        $package.identity_sha256 = $identity.identity_sha256

        if (-not (Test-Path -LiteralPath $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory | Out-Null }
        $outputRoot = [IO.Path]::GetFullPath($OutputDirectory)
        $packagePath = Join-Path $outputRoot ($package.package_id + '.json')
        $packageJson = $package | ConvertTo-Json -Depth 40
        Write-NoteImmutableText $packagePath $packageJson 'PACKAGE'
        Assert-NoteCompilerJsonSchema $packagePath (Join-Path $schemaRoot 'final_review_package.schema.json') 'PACKAGE'
        Test-NoteFinalReviewPackageIdentity $package | Out-Null
        $packageSha = Get-NoteCompilerFileSha256 $packagePath

        $presentationPath = Join-Path $outputRoot ($package.package_id + '.final-review.md')
        $presentation = New-NoteFinalReviewPresentationText $package $packageSha
        Write-NoteImmutableText $presentationPath $presentation 'PRESENTATION'
        Assert-NoteFinalReviewPresentation -PackagePath $packagePath -PresentationPath $presentationPath | Out-Null

        [pscustomobject]@{
            result = 'PASS'
            previous_state = 'MARKETING_APPROVED'
            build_state = 'FINAL_REVIEW_PACKAGE_BUILDING'
            state = 'READY_FOR_FINAL_REVIEW'
            approval_status = 'PENDING'
            package_id = $package.package_id
            package_identity_sha256 = $package.identity_sha256
            package_sha256 = $packageSha
            package_path = $packagePath
            presentation_path = $presentationPath
        }
    } catch {
        if ($_.Exception.Message.StartsWith('IMMUTABLE_PACKAGE_CONFLICT:')) { throw }
        if ($_.Exception.Message.StartsWith('BLOCKED_FINAL_PACKAGE_INCOMPLETE:')) { throw }
        throw "BLOCKED_FINAL_PACKAGE_INCOMPLETE: $($_.Exception.Message)"
    }
}

Export-ModuleMember -Function Get-NoteCompilerFileSha256, Get-NoteFinalReviewPackageIdentity, Test-NoteFinalReviewPackageIdentity, Assert-NoteFinalReviewPresentation, New-NoteFinalReviewPackage
