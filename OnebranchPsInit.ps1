$Global:CheckForUpdate = $true
$Global:WelcomePlease = $true
$Global:IamGroot = $false

# Aliases initialization
$oneBranchPsRoot = $env:OsumOnebranchPsRoot
. $oneBranchPsRoot\scripts\system\aliases\common_aliases.ps1
. $oneBranchPsRoot\scripts\system\aliases\repo_aliases.ps1
. $oneBranchPsRoot\scripts\system\aliases\devfabric.ps1
. $oneBranchPsRoot\scripts\system\aliases\other.ps1

. $oneBranchPsRoot\scripts\system\post.ps1

. $oneBranchPsRoot\scripts\system\localpack.ps1

# Client customization
if (Test-Path $oneBranchPsRoot\mine.ps1) {
    . $oneBranchPsRoot\mine.ps1
}

# Trigger update check in background
if ($Global:CheckForUpdate) {
    Start-Job -FilePath $oneBranchPsRoot\scripts\system\update.ps1 -Name "OnebranchPS Update" `
    -ArgumentList $Global:IamGroot | Out-Null
}