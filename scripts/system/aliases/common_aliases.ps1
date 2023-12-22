$Global:MSBuildArgs = "/verbosity:m /clp:Summary"

function global:reporoot {
    pushd $env:REPOROOT\$args
}

function global:.. {
    pushd ..
}

function global:... {
    pushd ..\..
}

function global:.... {
    pushd ..\..\..
}

function global:vsms {
    $projDir = Get-Location
    $projDir = "$projDir\"
    foreach ($arg in $args) {

        # Ignore args with "/" which are switch in old cmd style
        # vsms dirs.proj /blah:blue
        if (-not $arg.StartsWith("/"))
        {
            $projDir = $arg
            break
        }
    }

    $absPath = Resolve-Path $projDir

    $dir = [System.IO.Path]::GetDirectoryName($absPath)
    $topDir = Split-Path $dir -Leaf

    vsmsbuild /v:16.0 /solutionname:"$dir\${topDir}.sln" @args
}

function global:vsms14 {
    vsmsbuild /v:14.0 @args
}

function global:vsms15 {
    vsmsbuild /v:15.0 @args
}

function global:v {
    vsms @args
}

#region Build commands
function global:bcc {
    build -cC $args
}

function global:bcz {
    build -cZP $args
}

function global:bld {
    quickbuild
}

function global:bldd {
    build debug -amd64 $args
}

function global:bldr {
    build retail -amd64 $args
}

function global:mbt {
    param (
        $buildCommand
    )
    $currentMsb = $env:MSBuildArgs
    $currentCspack = $env:DisableCspkgGeneration

    try
    {
        $env:MSBuildArgs=$Global:MSBuildArgs
        $env:DisableCspkgGeneration='true'

        Invoke-Expression "$buildCommand"
    }
    finally
    {
        # Finally block is executed even at Ctrl-C

        $env:MSBuildArgs = $currentMsb
        $env:DisableCspkgGeneration = $currentCspack
    }
}

function global:mbr {
    mbt "bldr"
}

function global:mbd {
    mbt "bldd"
}

function global:mb {
    mbr
}
#endregion

#region Environment Variables Handling
function global:nocspack {
    $env:DisableCspkgGeneration='true'
}

function global:cspack {
    Remove-Item env:DisableCspkgGeneration -ErrorAction Ignore
}

# Don't do DevFabric Build
function global:nodf {
    $env:DisableDevFabricGeneration='true'
}

function global:df {
    Remove-Item env:DisableDevFabricGeneration -ErrorAction Ignore
}

# Simple MSBuild
function global:smsb {
    $env:MSBuildArgs=$Global:MSBuildArgs
}

function global:nosmsb {
    Remove-Item env:MSBuildArgs -ErrorAction Ignore
}
#noregion

function global:gpu {
    git pull
}

function global:gpsh {
    git push
}

function global:gpshr {
    git push --set-upstream origin $args
}

function global:gb {
    git branch $args
}

function global:gst {
    git stash
}

function global:gsp {
    git stash pop
}

function global:gco {
    git checkout $args
}

function global:gcco {
    git checkout -b $args
}

function global:ga {
    git add $args
}

function global:gaa {
    git add -A
}

function global:gaac {
    git add .
}

function global:gac {
    git add .
}

function global:gs {
    git status $args
}

function global:gcmm {
    git commit -m $args
}

function global:gcam {
    git commit -a -m $args
}

function global:gbd {
    git branch -D $args
}

function global:gl {
    git log --graph --pretty=format:"%Cred%h%Creset - %C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset"
}

function global:gprune {
    git remote prune origin
}

function global:gr {
    git rm $args
}

function global:gm {
    git merge $args
}

function global:gmt {
    git mergetool
}

function global:gd {
    git diff
}

function global:gdt {
    git difftool $args
}

function global:gdtc {
    git difftool --cached
}

function global:q {
    quickbuild $args
}

function global:qbc {
    quickbuild -buildcop
}

function global:qbcop {
    quickbuild -buildcop
}

function global:qimd {
    quickbuild -detectinputmismatches=BreakBuild
}

function global:qnocache {
    quickbuild -cachetype none -nocbc $args
}

function global:packd {
    pushd $env:REPOROOT ; quickbuild ; popd
}

function global:packr {
    pushd $env:REPOROOT ; build retail -amd64 ; popd
}

function global:clean {
    git clean -xfd -e .gen -e gen -e .packages $args
}

function global:root {
    pushd $env:REPOROOT\$args
}

function global:src {
    pushd $env:SRCROOT\$args
}

function global:nuget {
    pushd $env:SRCROOT\NuGet\$args
}

function global:sign {
    pushd $env:SRCROOT\Codesign\$args
}

function global:svc {
    pushd $env:SRCROOT\Service\$args
}

function global:cache {
	pushd $env:NugetMachineInstallRoot
}

function global:edit {
    $configuredEditor = Get-Variable -Name MyTextEditor -Scope Global -ErrorAction SilentlyContinue
    if ($configuredEditor -eq $null) {
        notepad $args
    } else {
        & $configuredEditor.Value $args
    }
}