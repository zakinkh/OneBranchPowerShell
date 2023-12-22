# Script to check for updates
param(
    [bool] $isGroot = $false
)

$oneBranchPsRoot = $env:OsumOnebranchPsRoot
$global:updateTitle = "Latest version to OnebranchPS is available"
$global:updateMessage = "Use command ""obpsroot"" to go to OnebranchPS directory, do a ""git pull"" and run .\setup.ps1"

Set-Location $oneBranchPsRoot

$localMain = "master"
if ($isGroot) {
    $localMain = "features/next"
    $global:updateTitle = "$global:updateTitle for Groots!"
}

$originMain = "origin/$localMain"

function IsGitPullNeeded {
    git fetch origin -p # Hopefully everyone has origin!
    $localHead = ((git rev-parse $localMain) | Out-String).Trim()
    $remoteHead = ((git rev-parse $originMain) | Out-String).Trim()
    $mergeBase = ((git merge-base $localMain $originMain) | Out-String).Trim()
    $currentBranch = ((git rev-parse --abbrev-ref HEAD) | Out-String).Trim()

    # If local master and origin/master are same, no update required
    if ($localHead -eq $remoteHead) {
        return $false
    }

    # Merge base is local -> Origin/master is ahead
    if ($mergeBase -eq $localHead) {
        $canPull = CanPull $currentBranch $localMain
        if ($canPull) {
            git pull | Out-Null
            $global:updateTitle = "OnebranchPS updated!"
            $global:updateMessage = "Restart your enlistment to get new changes. See changelogs for more details"
        }
        return $true
    }

    # Merge base is not local or origin/master i.e. branches diverged
    if ($mergeBase -ne $localHead -and $mergeBase -ne $remoteHead) {
        return $true
    }

    return $false
}

function CanPull 
{
    param (
        $currentBranch,
        $trackedBranch
    )
    
    $localChanges = ((git status -s) | Out-String).Trim()
    if (($localChanges -eq "") -and ($currentBranch -eq $trackedBranch)) 
    {
        return $true
    }

    return $false
}

function CreateUpdateNotification {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $notification = New-Object System.Windows.Forms.NotifyIcon
    $notification.Icon = "$oneBranchPsRoot\icon.ico"
    $notification.BalloonTipIcon = "Info"
    $notification.BalloonTipTitle = $global:updateTitle
    $notification.BalloonTipText = $global:updateMessage

    $notification.Visible = $True 
    $notification.ShowBalloonTip(10000)
}

$isUpdateAvailable = IsGitPullNeeded
if ($isUpdateAvailable) {
    CreateUpdateNotification
}