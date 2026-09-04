Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-ExternalAuditJsonFile {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file not found: $Path"
    }

    try {
        return (Get-Content -Raw -Encoding UTF8 -LiteralPath $Path | ConvertFrom-Json -Depth 100)
    }
    catch {
        throw "Invalid JSON file: $Path"
    }
}

function Get-ExternalAuditProperty {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        [switch]$AllowEmpty
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        throw "Required property is missing: $Name"
    }
    if (-not $AllowEmpty -and $property.Value -is [string] -and [string]::IsNullOrWhiteSpace($property.Value)) {
        throw "Required property is empty: $Name"
    }
    return $property.Value
}

function Resolve-ExternalAuditSourcePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$RelativePath
    )

    if ([IO.Path]::IsPathRooted($RelativePath)) {
        throw "Source path must be repository-relative: $RelativePath"
    }

    $root = [IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $candidate = [IO.Path]::GetFullPath((Join-Path $root $RelativePath))
    $prefix = $root + [IO.Path]::DirectorySeparatorChar
    if (-not $candidate.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Source path escapes the repository root: $RelativePath"
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Source file not found: $RelativePath"
    }
    return $candidate
}

function Read-ExternalAuditSourceSpec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Spec,
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [int]$DefaultMaxChars = 20000
    )

    $relativePath = [string](Get-ExternalAuditProperty -Object $Spec -Name 'path')
    $fullPath = Resolve-ExternalAuditSourcePath -RepositoryRoot $RepositoryRoot -RelativePath $relativePath
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $fullPath

    $startProperty = $Spec.PSObject.Properties['start_marker']
    $endProperty = $Spec.PSObject.Properties['end_marker']
    if ($null -ne $startProperty -and -not [string]::IsNullOrWhiteSpace([string]$startProperty.Value)) {
        $startMarker = [string]$startProperty.Value
        $startIndex = $content.IndexOf($startMarker, [StringComparison]::Ordinal)
        if ($startIndex -lt 0) {
            throw "start_marker was not found in ${relativePath}: $startMarker"
        }

        $endIndex = $content.Length
        if ($null -ne $endProperty -and -not [string]::IsNullOrWhiteSpace([string]$endProperty.Value)) {
            $searchFrom = $startIndex + $startMarker.Length
            $endIndex = $content.IndexOf([string]$endProperty.Value, $searchFrom, [StringComparison]::Ordinal)
            if ($endIndex -lt 0) {
                throw "end_marker was not found after start_marker in ${relativePath}: $($endProperty.Value)"
            }
        }
        $content = $content.Substring($startIndex, $endIndex - $startIndex).Trim()
    }
    elseif ($null -ne $endProperty) {
        throw "end_marker cannot be used without start_marker: $relativePath"
    }

    $maxChars = $DefaultMaxChars
    $maxProperty = $Spec.PSObject.Properties['max_chars']
    if ($null -ne $maxProperty) {
        $maxChars = [int]$maxProperty.Value
    }
    if ($maxChars -lt 1) {
        throw "max_chars must be greater than zero: $relativePath"
    }
    if ($content.Length -gt $maxChars) {
        throw "Selected content exceeds max_chars ($($content.Length) > $maxChars). Narrow the markers for: $relativePath"
    }
    if ([string]::IsNullOrWhiteSpace($content)) {
        throw "Selected source content is empty: $relativePath"
    }

    $labelProperty = $Spec.PSObject.Properties['label']
    $label = if ($null -ne $labelProperty -and -not [string]::IsNullOrWhiteSpace([string]$labelProperty.Value)) {
        [string]$labelProperty.Value
    }
    else {
        $relativePath
    }

    return [ordered]@{
        label       = $label
        source_path = $relativePath.Replace('\', '/')
        content     = $content
    }
}

function Convert-ExternalAuditSourceList {
    param(
        [Parameter(Mandatory)]$Specs,
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$GroupName
    )

    $items = @($Specs)
    if ($items.Count -eq 0) {
        throw "At least one selectively scoped source is required for: $GroupName"
    }
    $result = @($items | ForEach-Object {
        Read-ExternalAuditSourceSpec -Spec $_ -RepositoryRoot $RepositoryRoot
    })
    return ,$result
}

function Assert-ExternalAuditJsonSchema {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Value,
        [Parameter(Mandatory)][string]$SchemaPath,
        [Parameter(Mandatory)][string]$Label
    )

    if (-not (Test-Path -LiteralPath $SchemaPath -PathType Leaf)) {
        throw "Schema file not found: $SchemaPath"
    }
    $json = $Value | ConvertTo-Json -Depth 100
    $valid = Test-Json -Json $json -SchemaFile $SchemaPath -ErrorAction SilentlyContinue
    if (-not $valid) {
        throw "$Label does not conform to schema: $SchemaPath"
    }
}

function New-ExternalAuditInput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$RequestSchemaPath,
        [Parameter(Mandatory)][string]$InputSchemaPath
    )

    $manifest = Read-ExternalAuditJsonFile -Path $ManifestPath
    Assert-ExternalAuditJsonSchema -Value $manifest -SchemaPath $RequestSchemaPath -Label 'Audit request manifest'
    $internalAudit = Get-ExternalAuditProperty -Object $manifest -Name 'internal_audit'
    $internalStatus = [string](Get-ExternalAuditProperty -Object $internalAudit -Name 'status')
    if ($internalStatus -ne 'PASS') {
        throw "External Audit is blocked until internal_audit.status is PASS. Current: $internalStatus"
    }
    [void](Get-ExternalAuditProperty -Object $internalAudit -Name 'report_ref')

    $content = Get-ExternalAuditProperty -Object $manifest -Name 'content'
    $sources = Get-ExternalAuditProperty -Object $manifest -Name 'sources'
    $story = Read-ExternalAuditSourceSpec -Spec (Get-ExternalAuditProperty -Object $content -Name 'story') -RepositoryRoot $RepositoryRoot -DefaultMaxChars 50000
    $practice = Read-ExternalAuditSourceSpec -Spec (Get-ExternalAuditProperty -Object $content -Name 'practice') -RepositoryRoot $RepositoryRoot -DefaultMaxChars 70000
    $archive = Read-ExternalAuditSourceSpec -Spec (Get-ExternalAuditProperty -Object $content -Name 'session_archive') -RepositoryRoot $RepositoryRoot -DefaultMaxChars 70000

    $input = [ordered]@{
        series_name          = [string](Get-ExternalAuditProperty -Object $manifest -Name 'series_name')
        section_number       = [string](Get-ExternalAuditProperty -Object $manifest -Name 'section_number')
        session_number       = [string](Get-ExternalAuditProperty -Object $manifest -Name 'session_number')
        article_title        = [string](Get-ExternalAuditProperty -Object $manifest -Name 'article_title')
        story                = $story.content
        practice             = $practice.content
        session_archive      = $archive.content
        evidence_notes       = Convert-ExternalAuditSourceList -Specs (Get-ExternalAuditProperty -Object $sources -Name 'evidence_notes') -RepositoryRoot $RepositoryRoot -GroupName 'evidence_notes'
        series_policy        = Convert-ExternalAuditSourceList -Specs (Get-ExternalAuditProperty -Object $sources -Name 'series_policy') -RepositoryRoot $RepositoryRoot -GroupName 'series_policy'
        session_scope        = Convert-ExternalAuditSourceList -Specs (Get-ExternalAuditProperty -Object $sources -Name 'session_scope') -RepositoryRoot $RepositoryRoot -GroupName 'session_scope'
        downstream_boundary  = Convert-ExternalAuditSourceList -Specs (Get-ExternalAuditProperty -Object $sources -Name 'downstream_boundary') -RepositoryRoot $RepositoryRoot -GroupName 'downstream_boundary'
        voice_archive_rules  = Convert-ExternalAuditSourceList -Specs (Get-ExternalAuditProperty -Object $sources -Name 'voice_archive_rules') -RepositoryRoot $RepositoryRoot -GroupName 'voice_archive_rules'
    }

    $reauditProperty = $manifest.PSObject.Properties['reaudit_context']
    if ($null -ne $reauditProperty -and $null -ne $reauditProperty.Value) {
        $reaudit = $reauditProperty.Value
        $previous = Read-ExternalAuditSourceSpec -Spec (Get-ExternalAuditProperty -Object $reaudit -Name 'previous_audit') -RepositoryRoot $RepositoryRoot -DefaultMaxChars 50000
        $revision = Read-ExternalAuditSourceSpec -Spec (Get-ExternalAuditProperty -Object $reaudit -Name 'revision_summary') -RepositoryRoot $RepositoryRoot -DefaultMaxChars 20000
        $input.reaudit_context = [ordered]@{
            previous_audit  = $previous.content
            revision_summary = $revision.content
        }
    }

    Assert-ExternalAuditJsonSchema -Value $input -SchemaPath $InputSchemaPath -Label 'Audit input'
    return $input
}

function Assert-ExternalAuditSharingApproval {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Manifest)

    # Legacy Manifest assertions are not authenticated Human approval evidence.
    throw 'BLOCKED_APPROVAL_RUNTIME: manifest approved/approval_ref cannot authorize external invocation.'
}

function Get-ExpectedExternalAuditStatus {
    param([Parameter(Mandatory)]$AuditResult)

    $issues = @($AuditResult.issues)
    if (@($issues | Where-Object { $_.severity -eq 'BLOCKER' -or $_.human_decision_required }).Count -gt 0) {
        return 'HUMAN_DECISION_REQUIRED'
    }
    if (@($issues | Where-Object severity -eq 'MAJOR').Count -gt 0) {
        return 'REVISE'
    }
    if (@($issues | Where-Object severity -eq 'MINOR').Count -gt 0) {
        return 'PASS_WITH_MINOR'
    }
    return 'PASS'
}

function ConvertFrom-ExternalAuditModelResponse {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$ResponseSchemaPath
    )

    $candidate = $Text.Trim()
    if ($candidate -match '(?s)^```(?:json)?\s*(.*?)\s*```$') {
        $candidate = $Matches[1].Trim()
    }
    try {
        $result = $candidate | ConvertFrom-Json -Depth 100
    }
    catch {
        throw 'External auditor returned invalid JSON.'
    }

    Assert-ExternalAuditJsonSchema -Value $result -SchemaPath $ResponseSchemaPath -Label 'Audit response'

    $ids = @($result.issues | ForEach-Object id)
    if (@($ids | Sort-Object -Unique).Count -ne $ids.Count) {
        throw 'Audit response contains duplicate issue IDs.'
    }
    foreach ($issue in @($result.issues)) {
        if ($issue.severity -eq 'BLOCKER' -and -not $issue.human_decision_required) {
            throw "BLOCKER must set human_decision_required=true: $($issue.id)"
        }
    }

    $expectedStatus = Get-ExpectedExternalAuditStatus -AuditResult $result
    if ($result.audit_status -ne $expectedStatus) {
        throw "audit_status is inconsistent with issues. Expected $expectedStatus, got $($result.audit_status)."
    }
    return $result
}

function Get-ExternalAuditRouting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$AuditResult,
        [ValidateSet('after_major','after_any_revision','never')][string]$ReauditPolicy = 'after_major'
    )

    $issues = @($AuditResult.issues)
    $humanIssues = @($issues | Where-Object { $_.severity -eq 'BLOCKER' -or $_.human_decision_required })
    $majorIssues = @($issues | Where-Object severity -eq 'MAJOR')
    $minorIssues = @($issues | Where-Object severity -eq 'MINOR')
    $requiredRevision = @($issues | Where-Object { $_.severity -in @('MAJOR','MINOR') -and -not $_.human_decision_required })

    if ($humanIssues.Count -gt 0) {
        $action = 'HUMAN_DECISION_REQUIRED'
        $automaticRevisionAllowed = $false
    }
    elseif ($requiredRevision.Count -gt 0) {
        $action = 'RETURN_TO_INTERNAL_AI'
        $automaticRevisionAllowed = $true
    }
    else {
        $action = 'PASS_TO_FINALIZATION'
        $automaticRevisionAllowed = $false
    }

    $reauditRequired = switch ($ReauditPolicy) {
        'after_any_revision' { $requiredRevision.Count -gt 0 }
        'after_major' { $majorIssues.Count -gt 0 }
        'never' { $false }
    }

    return [ordered]@{
        audit_status               = $AuditResult.audit_status
        action                     = $action
        automatic_revision_allowed = $automaticRevisionAllowed
        revision_issue_ids         = @($requiredRevision | ForEach-Object id)
        human_issue_ids            = @($humanIssues | ForEach-Object id)
        note_issue_ids             = @($issues | Where-Object severity -eq 'NOTE' | ForEach-Object id)
        external_reaudit_required  = $reauditRequired
        severity_counts            = [ordered]@{
            BLOCKER = $humanIssues.Where({ $_.severity -eq 'BLOCKER' }).Count
            MAJOR   = $majorIssues.Count
            MINOR   = $minorIssues.Count
            NOTE    = @($issues | Where-Object severity -eq 'NOTE').Count
        }
    }
}

function Get-ExternalAuditHttpStatus {
    param([Parameter(Mandatory)]$ErrorRecord)

    if ($ErrorRecord.Exception.Data.Contains('StatusCode')) {
        return [int]$ErrorRecord.Exception.Data['StatusCode']
    }
    $responseProperty = $ErrorRecord.Exception.PSObject.Properties['Response']
    if ($null -ne $responseProperty -and $null -ne $responseProperty.Value -and $null -ne $responseProperty.Value.StatusCode) {
        return [int]$responseProperty.Value.StatusCode
    }
    return $null
}

function Test-ExternalAuditRetryableError {
    param([Parameter(Mandatory)]$ErrorRecord)

    $status = Get-ExternalAuditHttpStatus -ErrorRecord $ErrorRecord
    if ($null -eq $status) { return $true }
    return ($status -in @(408, 409, 425, 429) -or $status -ge 500)
}

function Invoke-WithExternalAuditRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Operation,
        [ValidateRange(0, 6)][int]$RetryCount = 2,
        [ValidateRange(1, 30)][int]$InitialDelaySeconds = 2
    )

    $attempts = $RetryCount + 1
    for ($attempt = 1; $attempt -le $attempts; $attempt++) {
        try {
            return (& $Operation $attempt)
        }
        catch {
            $status = Get-ExternalAuditHttpStatus -ErrorRecord $_
            $retryable = Test-ExternalAuditRetryableError -ErrorRecord $_
            if (-not $retryable -or $attempt -eq $attempts) {
                $statusLabel = if ($null -eq $status) { 'network_or_timeout' } else { [string]$status }
                $stage = if ($_.Exception.Data.Contains('AuditStage')) { [string]$_.Exception.Data['AuditStage'] } else { 'unknown' }
                $exceptionType = $_.Exception.GetType().Name
                throw "External provider request failed (status=$statusLabel, attempts=$attempt, stage=$stage, exception_type=$exceptionType). Response content was not logged."
            }
            $delay = [Math]::Min(30, $InitialDelaySeconds * [Math]::Pow(2, $attempt - 1))
            Start-Sleep -Seconds $delay
        }
    }
}

function New-ExternalAuditProviderException {
    param(
        [Parameter(Mandatory)][int]$StatusCode,
        [string]$RequestId
    )
    $exception = [InvalidOperationException]::new('External provider returned a non-success status. Response body suppressed.')
    $exception.Data['StatusCode'] = $StatusCode
    if (-not [string]::IsNullOrWhiteSpace($RequestId)) {
        $exception.Data['RequestId'] = $RequestId
    }
    return $exception
}

function Get-ExternalAuditRequestId {
    param($Headers)
    if ($null -eq $Headers) { return $null }
    foreach ($name in @('request-id','x-request-id','anthropic-request-id')) {
        if ($Headers.ContainsKey($name)) { return [string]$Headers[$name][0] }
    }
    return $null
}

function Invoke-AnthropicExternalAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApiKey,
        [Parameter(Mandatory)][string]$Model,
        [Parameter(Mandatory)][string]$SystemPrompt,
        [Parameter(Mandatory)][string]$AuditInputJson,
        [ValidateRange(10, 600)][int]$TimeoutSeconds = 120,
        [ValidateRange(0, 6)][int]$RetryCount = 2,
        [ValidateRange(512, 32000)][int]$MaxOutputTokens = 12000,
        [ValidateSet('default','disabled')][string]$ThinkingMode = 'disabled'
    )

    throw 'BLOCKED_APPROVAL_RUNTIME: Anthropic transport disabled pending trusted Human evidence ingress.'
    $bodyObject = [ordered]@{
        model       = $Model
        max_tokens  = $MaxOutputTokens
        system      = $SystemPrompt
        messages    = @(
            [ordered]@{
                role    = 'user'
                content = "以下のaudit_input JSONだけを監査対象として使用してください。Repositoryの他の内容を推測で補完しないでください。`n`n$AuditInputJson"
            }
        )
    }
    if ($ThinkingMode -eq 'disabled') {
        $bodyObject.thinking = [ordered]@{ type = 'disabled' }
    }
    $body = $bodyObject | ConvertTo-Json -Depth 100 -Compress

    $operation = {
        param($Attempt)
        $responseHeaders = $null
        $statusCode = 0
        $auditStage = 'invoke_http'
        try {
            $response = Invoke-RestMethod `
                -Method Post `
                -Uri 'https://api.anthropic.com/v1/messages' `
                -Headers @{ 'x-api-key' = $ApiKey; 'anthropic-version' = '2023-06-01' } `
                -ContentType 'application/json; charset=utf-8' `
                -Body $body `
                -ConnectionTimeoutSeconds $TimeoutSeconds `
                -OperationTimeoutSeconds $TimeoutSeconds `
                -SkipHttpErrorCheck `
                -StatusCodeVariable statusCode `
                -ResponseHeadersVariable responseHeaders

            $auditStage = 'read_response_headers'
            $requestId = $null
            if ($null -ne $responseHeaders) {
                foreach ($headerName in @('request-id','x-request-id','anthropic-request-id')) {
                    if ($responseHeaders.ContainsKey($headerName)) {
                        $requestId = [string]$responseHeaders[$headerName][0]
                        break
                    }
                }
            }
            $auditStage = 'check_http_status'
            if ($statusCode -lt 200 -or $statusCode -ge 300) {
                $providerException = [InvalidOperationException]::new('External provider returned a non-success status. Response body suppressed.')
                $providerException.Data['StatusCode'] = $statusCode
                if (-not [string]::IsNullOrWhiteSpace($requestId)) {
                    $providerException.Data['RequestId'] = $requestId
                }
                throw $providerException
            }
            $auditStage = 'read_text_blocks'
            $textBlocks = @($response.content | Where-Object type -eq 'text' | ForEach-Object text)
            if ($textBlocks.Count -eq 0) {
                throw 'Anthropic response did not contain a text block.'
            }
            return [ordered]@{ text = ($textBlocks -join "`n"); request_id = $requestId }
        }
        catch {
            if (-not $_.Exception.Data.Contains('AuditStage')) {
                $_.Exception.Data['AuditStage'] = $auditStage
            }
            throw
        }
    }.GetNewClosure()

    return Invoke-WithExternalAuditRetry -Operation $operation -RetryCount $RetryCount
}

function Invoke-GeminiExternalAudit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApiKey,
        [Parameter(Mandatory)][string]$Model,
        [Parameter(Mandatory)][string]$SystemPrompt,
        [Parameter(Mandatory)][string]$AuditInputJson,
        [ValidateRange(10, 600)][int]$TimeoutSeconds = 120,
        [ValidateRange(0, 6)][int]$RetryCount = 2,
        [ValidateRange(512, 32000)][int]$MaxOutputTokens = 12000
    )

    throw 'BLOCKED_APPROVAL_RUNTIME: Gemini transport disabled pending trusted Human evidence ingress.'
    $escapedModel = [Uri]::EscapeDataString($Model)
    $uri = "https://generativelanguage.googleapis.com/v1beta/models/${escapedModel}:generateContent"
    $body = [ordered]@{
        systemInstruction = [ordered]@{ parts = @([ordered]@{ text = $SystemPrompt }) }
        contents = @([ordered]@{
            role = 'user'
            parts = @([ordered]@{ text = "以下のaudit_input JSONだけを監査対象として使用してください。`n`n$AuditInputJson" })
        })
        generationConfig = [ordered]@{
            temperature = 0
            maxOutputTokens = $MaxOutputTokens
            responseMimeType = 'application/json'
        }
    } | ConvertTo-Json -Depth 100 -Compress

    $operation = {
        param($Attempt)
        $responseHeaders = $null
        $statusCode = 0
        $response = Invoke-RestMethod `
            -Method Post `
            -Uri $uri `
            -Headers @{ 'x-goog-api-key' = $ApiKey } `
            -ContentType 'application/json; charset=utf-8' `
            -Body $body `
            -ConnectionTimeoutSeconds $TimeoutSeconds `
            -OperationTimeoutSeconds $TimeoutSeconds `
            -SkipHttpErrorCheck `
            -StatusCodeVariable statusCode `
            -ResponseHeadersVariable responseHeaders

        $requestId = $null
        if ($null -ne $responseHeaders) {
            foreach ($headerName in @('request-id','x-request-id')) {
                if ($responseHeaders.ContainsKey($headerName)) {
                    $requestId = [string]$responseHeaders[$headerName][0]
                    break
                }
            }
        }
        if ($statusCode -lt 200 -or $statusCode -ge 300) {
            $providerException = [InvalidOperationException]::new('External provider returned a non-success status. Response body suppressed.')
            $providerException.Data['StatusCode'] = $statusCode
            if (-not [string]::IsNullOrWhiteSpace($requestId)) {
                $providerException.Data['RequestId'] = $requestId
            }
            throw $providerException
        }
        $parts = @($response.candidates[0].content.parts | ForEach-Object text)
        if ($parts.Count -eq 0) {
            throw 'Gemini response did not contain a text part.'
        }
        return [ordered]@{ text = ($parts -join "`n"); request_id = $requestId }
    }.GetNewClosure()

    return Invoke-WithExternalAuditRetry -Operation $operation -RetryCount $RetryCount
}

function Invoke-ExternalAuditProvider {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('anthropic','gemini')][string]$Provider,
        [Parameter(Mandatory)][string]$ApiKey,
        [Parameter(Mandatory)][string]$Model,
        [Parameter(Mandatory)][string]$SystemPrompt,
        [Parameter(Mandatory)][string]$AuditInputJson,
        [int]$TimeoutSeconds = 120,
        [int]$RetryCount = 2,
        [int]$MaxOutputTokens = 12000,
        [ValidateSet('default','disabled')][string]$AnthropicThinkingMode = 'disabled'
    )

    throw 'BLOCKED_APPROVAL_RUNTIME: provider dispatch disabled pending trusted Human evidence ingress.'
    if ([string]::IsNullOrWhiteSpace($ApiKey)) { throw 'Provider API key is empty.' }
    if ([string]::IsNullOrWhiteSpace($Model)) { throw 'Provider model must be specified explicitly.' }

    switch ($Provider) {
        'anthropic' {
            return Invoke-AnthropicExternalAudit `
                -ApiKey $ApiKey `
                -Model $Model `
                -SystemPrompt $SystemPrompt `
                -AuditInputJson $AuditInputJson `
                -TimeoutSeconds $TimeoutSeconds `
                -RetryCount $RetryCount `
                -MaxOutputTokens $MaxOutputTokens `
                -ThinkingMode $AnthropicThinkingMode
        }
        'gemini' {
            return Invoke-GeminiExternalAudit `
                -ApiKey $ApiKey `
                -Model $Model `
                -SystemPrompt $SystemPrompt `
                -AuditInputJson $AuditInputJson `
                -TimeoutSeconds $TimeoutSeconds `
                -RetryCount $RetryCount `
                -MaxOutputTokens $MaxOutputTokens
        }
    }
}

function Get-ExternalAuditSha256 {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text)
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
}

function Write-ExternalAuditJsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Value,
        [Parameter(Mandatory)][string]$Path
    )

    $parent = Split-Path -Parent ([IO.Path]::GetFullPath($Path))
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "Output directory does not exist: $parent"
    }
    $json = $Value | ConvertTo-Json -Depth 100
    [IO.File]::WriteAllText([IO.Path]::GetFullPath($Path), $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
}

Export-ModuleMember -Function @(
    'Read-ExternalAuditJsonFile',
    'Resolve-ExternalAuditSourcePath',
    'Read-ExternalAuditSourceSpec',
    'Assert-ExternalAuditJsonSchema',
    'New-ExternalAuditInput',
    'Assert-ExternalAuditSharingApproval',
    'ConvertFrom-ExternalAuditModelResponse',
    'Get-ExpectedExternalAuditStatus',
    'Get-ExternalAuditRouting',
    'Invoke-WithExternalAuditRetry',
    'Invoke-ExternalAuditProvider',
    'Get-ExternalAuditSha256',
    'Write-ExternalAuditJsonFile'
)
