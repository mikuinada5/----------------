Set-StrictMode -Version Latest

function Get-RepositorySyncClassification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][int]$LocalAhead,
        [Parameter(Mandatory)][int]$RemoteAhead,
        [Parameter(Mandatory)][bool]$WorkingTreeClean,
        [bool]$GitCapabilityVerified = $true
    )
    $classification=''; $action='STOP'; $ready=$false; $reason=''
    if (-not $GitCapabilityVerified) { $classification='BLOCKED_GIT_CAPABILITY'; $reason='fetch or Git state could not be verified' }
    elseif ($LocalAhead -gt 0 -and $RemoteAhead -gt 0) { $classification='STOP_DIVERGED'; $reason='local and remote contain independent commits' }
    elseif (-not $WorkingTreeClean -and $RemoteAhead -gt 0) { $classification='STOP_DIRTY_REMOTE_AHEAD'; $reason='remote advanced while local changes are present' }
    elseif (-not $WorkingTreeClean) { $classification='STOP_DIRTY_WORKTREE'; $reason='maintenance requires a clean working tree' }
    elseif ($RemoteAhead -gt 0) { $classification='AUTO_FAST_FORWARD'; $action='FAST_FORWARD'; $reason='remote-only commits are a normal inbound update' }
    elseif ($LocalAhead -gt 0) { $classification='LOCAL_AHEAD_REVIEW'; $action='PUSH_POLICY_REVIEW'; $reason='local commits require the existing push authorization check' }
    else { $classification='READY'; $action='NONE'; $ready=$true; $reason='local and remote are equal and the working tree is clean' }
    [pscustomobject]@{ schema_version='repository-sync-result/v1'; classification=$classification; action=$action; ready=$ready; local_ahead=$LocalAhead; remote_ahead=$RemoteAhead; working_tree_clean=$WorkingTreeClean; reason=$reason }
}

Export-ModuleMember -Function Get-RepositorySyncClassification
