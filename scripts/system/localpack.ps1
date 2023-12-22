$Global:LocalPackageDir = "\\$env:COMPUTERNAME\C$\Users\$env:USERNAME\OnebranchLocalPack"
$Global:RudeNoInit = $false
$Global:RudeDirtyCacheroot = $false
$Global:CacheRoot = $env:NugetMachineInstallRoot

$nupkgRegex = [regex]"^(.+?(?=\.\d+\.\d+))\.(.+)"

# Upload packages from current one branch repo to local package directory
function global:repack {
    $repoPackageDir = "$env:REPOROOT/out/packages"
    if (!(Test-Path $repoPackageDir)) {
        Write-Host "Repo package dir $repoPackageDir doesn't exist" -ForegroundColor Yellow
        return
    }

    $nupkgs = GetNupkgsInDirectory($repoPackageDir)
    $nupkgs = RemoveOldNupkgs($nupkgs)
    WriteToLocalPackageDir($nupkgs)

    # Cleanup LocalPackageDir with duplicates
    $nupkgs = GetNupkgsInDirectory($Global:LocalPackageDir)
    RemoveOldNupkgs($nupkgs) | Out-Null
}

# This function deletes all nupkg files from shared location i.e. $Global:LocalPackageDir
function global:unpack {
    $nupkgs = GetNupkgsInDirectory($Global:LocalPackageDir)
    foreach ($nupkg in $nupkgs) {
        Remove-Item $nupkg.FullName
    }
}

# Update .corext/corext.config with latest version of local packages
function global:rude {

    [CmdletBinding(DefaultParameterSetName="include")]
    param(
        [Parameter(ParameterSetName="include",
            HelpMessage="Include only matched packages. List should be a comma separated value")]
        [string] $Include,

        [Parameter(ParameterSetName="exclude",
            HelpMessage="Include all packages except for matched packages. List should be a comma separated value")]
        [string] $Exclude,

        [Parameter(HelpMessage="Do not trigger init with rude")]
        [Switch] $NoInit
    )

    if ($Global:RudeNoInit) {
        $NoInit = $true
    }

    rudeCorextHelper $Include $Exclude
    if (!$NoInit) {
        init
    }
}

# Undo changes of .corext/corext.config
function global:rune {
    $corextConfigFile = "$env:REPOROOT/.corext/corext.config"
    git checkout $corextConfigFile
}

function global:lspack {
    GetNupkgsInDirectory($Global:LocalPackageDir)
}

##################################################################################
##################################################################################
#       Local Methods and Implementation below this line                         #
##################################################################################
##################################################################################

function rudeCorextHelper ($Include, $Exclude) {
    $Includes = $Include.Split(",", [System.StringSplitOptions]'RemoveEmptyEntries')
    $Excludes = $Exclude.Split(",", [System.StringSplitOptions]'RemoveEmptyEntries')

    if (!($Includes.Count -gt 0)) {
        $Includes = @()
    }

    if (!($Excludes.Count -gt 0)) {
        $Excludes = @()
    }

    $corextConfigFile = "$env:REPOROOT/.corext/corext.config"
    $corextConfig = Get-Content $corextConfigFile

    $nupkgs = GetNupkgsInDirectory($Global:LocalPackageDir)
    RemoveOldNupkgs($nupkgs) | Out-Null

    if (!$Global:RudeDirtyCacheroot) {
        Write-Host "Trying to delete new nupkg from Cacheroot if present!" -ForegroundColor Yellow
        $nupkgs = GetNupkgsInDirectory($Global:LocalPackageDir)
        RemoveNupkgsFromCacheRoot($nupkgs) | Out-Null
    }

    foreach ($nupkg in $nupkgs) {
        $pkgIdVersion = GetPkgIdAndVersion($nupkg)
        if ($pkgIdVersion -eq $null) {
            Write-Host "Package name '$pkgName' is not in right format" -ForegroundColor Yellow
            continue
        }
        
        $pkgId = $pkgIdVersion[0]
        $pkgVersion = $pkgIdVersion[1]

        $shouldIncludePkg = ShouldIncludePackageInRude $pkgId $Includes $Excludes

        if (!$shouldIncludePkg) {
            continue
        }

        $matchString = "id=`"$pkgId`"\s+version=`"[^`"]*`""
        $replaceString = "id=`"$pkgId`" version=`"$pkgVersion`""
        Write-Host "Updated package '$pkgId' to version '$pkgVersion'" -ForegroundColor Cyan

        $corextConfig = $corextConfig -replace $matchString, $replaceString
    }

    # Add local package directory to repos in corext.config
    $corextLocalRepoRegex = "<repo\s+name=`"CorextLocal`"[^>]*>"
    $corextLocalRepo = "<repo name=`"CorextLocal`" uri=`"$Global:LocalPackageDir`" />"
    if ($corextConfig -match $corextLocalRepoRegex) {
        $corextConfig = $corextConfig -replace $corextLocalRepoRegex, $corextLocalRepo
    } else {
        $corextConfig = $corextConfig -replace "</repositories>", "  $corextLocalRepo`n  </repositories>"
    }

    Set-Content -LiteralPath $corextConfigFile -Value $corextConfig
}

function ShouldIncludePackageInRude ($pkgId, $Includes, $Excludes) {

    if ($Includes.Count -eq 0 -and $Excludes.Count -eq 0) {
        return $true
    }
    
    if ($Includes.Count -gt 0) {
        foreach($pkgPattern in $Includes) {
            if ($pkgId -match $pkgPattern) {
                return $true
            }
        }
        return $false
    }

    if ($Excludes.Count -gt 0) {
        foreach($pkgPattern in $Excludes) {
            if ($pkgId -match $pkgPattern) {
                return $false
            }
        }
        return $true
    }
}

function RemoveOldNupkgs ($nupkgs) {
    $latestNupkgVersions = @{}
    foreach ($nupkg in $nupkgs) {
        $pkgIdVersion = GetPkgIdAndVersion($nupkg)
        if ($pkgIdVersion -eq $null) {
            Write-Host "Package name '$pkgName' is not in right format" -ForegroundColor Yellow
            continue
        }
        $pkgId = $pkgIdVersion[0]
        $pkgVersion = $pkgIdVersion[1]

        if ($latestNupkgVersions.ContainsKey($pkgId)) {
            $currentLatest = $latestNupkgVersions[$pkgId]
            if ($currentLatest[0] -gt $pkgVersion) {
                Remove-Item $nupkg.FullName
            } else {
                $latestNupkgVersions[$pkgId] = @($pkgVersion, $nupkg)
                Remove-Item $currentLatest[1].FullName
            }
        } else {
            $latestNupkgVersions[$pkgId] = @($pkgVersion, $nupkg)
        }
    }
    $filterNupkgs = @()

    foreach ($pkgId in $latestNupkgVersions.Keys) {
        $nupkg = $latestNupkgVersions[$pkgId]
        $filterNupkgs += $nupkg[1]
    }
    return $filterNupkgs
}

function RemoveNupkgsFromCacheRoot ($nupkgs) {
    Write-Host "Cacheroot is: $Global:CacheRoot" -ForegroundColor Yellow
    foreach ($nupkg in $nupkgs) {
        $nupkgPathInCacheRoot = Join-Path $Global:CacheRoot $nupkg.Basename
        Remove-Item -Recurse $nupkgPathInCacheRoot -ErrorAction Ignore
    }
}

function WriteToLocalPackageDir ($nupkgs) {
    $localPackageDir = $Global:LocalPackageDir
    New-Item -Path $localPackageDir -ItemType Directory -Force | Out-Null
    Write-Host "Setting local nuget package directory to $localPackageDir" -ForegroundColor Cyan
    foreach ($nupkg in $nupkgs) {
        $nupkgName = $nupkg.Name
        Copy-Item $nupkg.FullName $localPackageDir
        Write-Host "Copied $nupkgName" -ForegroundColor Cyan
    }
}

function GetNupkgsInDirectory ($directory) {
    return Get-ChildItem $directory -Recurse | Where-Object {$_.Extension.ToLower() -eq ".nupkg"}
}

function GetPkgIdAndVersion ($nupkg) {
    $pkgName = $nupkg.Basename
    $matchPkgName = $nupkgRegex.Match($pkgName)
    if (!$matchPkgName.Success) {
        return $null
    }
    $pkgId = $matchPkgName.Groups[1].Value
    $pkgVersion = $matchPkgName.Groups[2].Value

    $output = @()
    $output += $pkgId
    $output += $pkgVersion
    return $output
}