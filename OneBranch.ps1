param(
    [string]
    [Parameter(Mandatory=$true)]
    $initScript
)

# Onebranch initialization
. $initScript

# If REPOROOT is not set then init script sucked
if (!(Test-Path env:REPOROOT)) {
    . $initScript no_cache
}

. $env:OsumOnebranchPsRoot\OnebranchPsInit.ps1

if (!(Test-Path env:REPOROOT)) {
    if (Test-Path env:ROOT) {
        $env:REPOROOT = $env:ROOT
    } else {
        $env:REPOROOT = Split-Path -Path $initScript
    }
}

Set-Location $env:REPOROOT

# Welcome message
if ($Global:WelcomePlease) {
    Write-Host "`nThanks for using OnebranchPs!" -ForegroundColor Yellow
    Write-Host "  Run command " -NoNewline
    Write-Host "obpsorigin " -ForegroundColor Cyan -NoNewline
    Write-Host "for hugs or bugs. Contributions are appreciated!"
    Write-Host "  For commands usages run " -NoNewline
    Write-Host "obpsdoc" -ForegroundColor Cyan
    Write-Host "  To disable this annoying message, add " -NoNewline
    Write-Host "`$Global:WelcomePlease = `$false" -ForegroundColor Cyan -NoNewline
    Write-Host " in ${env:OsumOnebranchPsRoot}\mine.ps1"
}