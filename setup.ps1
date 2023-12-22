$psMajorVersion = $PSVersionTable.PSVersion.Major
if ($psMajorVersion -lt 5) {
    Write-Host "This script works best with Powershell v5.0+" -ForegroundColor Yellow
    Write-Host "To upgrade to powershell v5.0, visit: https://aka.ms/ps5" -ForegroundColor Yellow

    $inputValue = Read-Host -Prompt "Continue with setup? y/n"
    if ($inputValue.ToLower() -ne "y") {
        exit
    }
}

Write-Host "Installing posh-git for current user" -ForegroundColor Yellow
Install-Module posh-git -Scope CurrentUser
Write-Host "Posh-git installation finished" -ForegroundColor Green

Write-Host "Updating PS profile with posh-git"
Add-PoshGitToProfile

$oneBranchPsRoot = $PSScriptRoot

[Environment]::SetEnvironmentVariable("OsumOnebranchPsRoot", $oneBranchPsRoot, [System.EnvironmentVariableTarget]::User)

# Creating client customization file
if (-Not (Test-Path $oneBranchPsRoot\mine.ps1)) {
    New-Item -Path $oneBranchPsRoot -Name mine.ps1 -Value @"
# In the name of old gods and the new, I swear I'll never update this file! 
    
# Please go ahead and add your customizations
"@ | Out-Null
}