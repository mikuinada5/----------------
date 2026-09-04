[CmdletBinding()]
param([Parameter(Mandatory)][string]$RunnerPath)
$ErrorActionPreference = 'Stop'
$path = (Resolve-Path -LiteralPath $RunnerPath).Path
$expected = '5887cc7c771ea162913f7531b9fedc43a8f896acad367e214d68f2bcfcb90aa5'
$marker = '# APPROVAL-INCIDENT-CONTAINMENT: no trusted Human-event ingress'
$original = [IO.File]::ReadAllText($path)
if ($original.Contains($marker)) {
    throw 'Already marked: verify the installed guard instead of treating a marker as proof.'
}
if ((Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant() -cne $expected) {
    throw 'Legacy runner identity differs; read-only investigation required.'
}
$needle = "`$ErrorActionPreference = 'Stop'"
if ([regex]::Matches($original, [regex]::Escape($needle)).Count -ne 1) { throw 'Runner patch anchor ambiguous.' }
$guard = @'
# APPROVAL-INCIDENT-CONTAINMENT: no trusted Human-event ingress
# Local validation/synthetic safety tests remain available; no live bypass flag.
if (-not ($ValidateOnly -or $TestErrorSafety -or $TestTimeoutSafety)) {
    [Console]::Error.WriteLine('BLOCKED_APPROVAL_RUNTIME: external invocation disabled pending trusted Human evidence ingress.')
    exit 1
}
'@
$updated = $original.Replace($needle, $needle + "`n" + $guard)
[IO.File]::WriteAllText($path, $updated, [Text.UTF8Encoding]::new($false))
[ordered]@{status='LIVE_RUNNER_BLOCKED'; original_sha256=$expected; installed_sha256=(Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant()} | ConvertTo-Json -Compress
