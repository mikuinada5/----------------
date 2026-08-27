[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$secureKey = $null
$plainKey = $null

try {
    Write-Host 'Anthropic External Audit API Key setup' -ForegroundColor Cyan
    Write-Host 'The key will not be displayed or written to this repository.'
    $secureKey = Read-Host 'Paste the complete Anthropic API key, then press Enter' -AsSecureString
    $plainKey = [Net.NetworkCredential]::new('', $secureKey).Password

    if ([string]::IsNullOrWhiteSpace($plainKey)) {
        throw 'No API key was entered.'
    }
    if ($plainKey -notmatch '^sk-ant-[A-Za-z0-9_-]{16,}$') {
        throw 'The entered value does not look like a complete Anthropic API key. Nothing was saved.'
    }

    [Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', $plainKey, 'User')
    Write-Host 'ANTHROPIC_API_KEY was configured in Windows User scope.' -ForegroundColor Green
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
finally {
    $plainKey = $null
    $secureKey = $null
}

[void](Read-Host 'Press Enter to close this window')
