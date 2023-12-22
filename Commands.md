Available Commands & Aliases
============================

Global Variables
----------------
Add these in mine.ps1 to tweak small settings of this tool
1. `$Global:WelcomePlease = $true`  
	Enable/Disable OnebranchPS welcome message. 
2. `$Global:MyTextEditor = "C:\Program Files (x86)\Notepad++\notepad++.exe"`  
    Configure the text editor to be used for `edit` command. By default `edit` opens files in notepad. 
3. `$Global:LocalPackageDir = "\\mycomputer\path\to\shared\packages"`  
    Directory where local packages are copied via `repack` command.
4. `$Global:CheckForUpdate = $false`  
    Disable checks for OnebranchPs tool updates. (But please don't disable it. please!)
5. `$Global:ServiceName`  
    This variable contains name of service which is currently loaded. This variable exists only for development purpose and is populated at runtime. Though you can use it to create your own fun commands in mine.ps1.
6. `$Global:RudeNoInit`  
    If set to `$true` then `rude` will not run `init` by default.
7. `$Global:MSBuildArgs`  
    Value for msbuild args to run with `mb` or `smsb`. Default value is `"/verbosity:m /clp:Summary"`.
8. `$Global:CacheRoot`  
    Location of cacheroot directory. Default value is taken from environment variable `NugetMachineInstallRoot`.
9. `$Global:RudeDirtyCacheroot`  
    If set to `$true`, rude will not delete local packages from cacheroot before triggering `init`.
10. `$Global:IamGroot`  
    If set to `$true`, new feature update notifications will come for `features/next` branch.

New commands
------------
- **repack**  
    This command copies all generated packages from `out/packages` to a shared path from where it can be consumed by other onebranch projects. Default path is `\\%COMPUTERNAME%\C$\Users\%USERNAME%\OnebranchLocalPack`.  
    To change it, add following line in `mine.ps1`:  
    ```powershell
    $Global:LocalPackageDir = "\\mycomputer\path\to\shared\packages"
    # This path must be UNC path
    # Use env variables as $env:VARIABLE_NAME e.g. $env:COMPUTERNAME, $env:USERNAME
    ```
- **rude**  
This command does following things:
    - Adds corext local packages entry to `.corext/corext.config`  
    e.g. `<repo name="CorextLocal" uri="\\master-yoda\C$\Users\dhratho\OnebranchLocalPack" />`. Uri is picked from variable `$Global:LocalPackageDir` defined in `mine.ps1`
    - Updates package version in `corext.config`  
    e.g. `<package id="Mgmt.RecoverySvcs.BackupMgmt.ClientLib" version="3.0.3-dhratho173412626" />`
    - Delete local packages to be copied from cacheroot. See `$Global:RudeDirtyCacheroot` and `$Global:Cacheroot`.
    - Trigger `init`. See `$Global:RudeNoInit`.

    By default rude command updates package version of all packages available in shared location. To provide more control over that, there are two switches available:
    - *Include*  
        Takes comma separarated list of patterns for packages which should be included  
        e.g. `rude -Include backup,iaascoord` This will now update package version of packages which match the pattern `backup` or `iaascoord`
    - *Exclude*  
        Takes comma separarated list of patterns for packages which should be included  
        e.g. `rude -Exclude iaascoord` This will update packages where package name doesn't contain `iaascoord`

    *Include* and *Exclude* are mutually exclusive commands and **must** not be provided together

- **rune**  
Undo changes in `corext.config` file. It is just an alias for `git checkout $env:REPOROOT/.corext/corext.config`

- **origin**  
This command opens your project in default browser for quick access.  
E.g. For `BackupMgmt` it opens `https://msazure.visualstudio.com/One/_git/Mgmt-RecoverySvcs-BackupMgmt`

- **unpack**  
This command deletes all nupkg files from shared path for local nupkg directory i.e. `$Global:LocalPackageDir`

- **lspack**  
This command lists packages available in local nupkg directory. Equivalent to `ls $Global:LocalPackageDir`

- **edit**  
This command opens a file in configured text editor. Default editor is notepad.  
Usages: `edit BMSWorkerRole.cs`  
To configure text editor add following line in `mine.ps` (see command `editmine`)  
`$Global:MyTextEditor = "C:\Program Files (x86)\Notepad++\notepad++.exe"`

- **cx**  
This command opens `.corext\corext.config` directory for editing

- **editmine**  
This command opens `mine.ps1` from your OnebranchPS installation directory for editing

- **mb, mbr, mbd**  
Alternative to existing build commands. This runs MsBuild with minimal verbosity and sets `$env:DisableCspkgGeneration` to `$true` to disable cspkg build. `mb` is just and alias to `mbr`.

- **cspack, nocspack**  
Enable or disable cspkg build respectively.

- **df, nodf**  
Enable or disable DevFabric build respectively.

- **smsb, nosmsb**  
Enable or disable simple minimalistic msbuild for build commands.

- **runs, runsr, runsd, ss**  
Start devfabric in debug mode or retail mode. `runs` will first try to start in debug mode if available, otherwise will go to retail mode. `ss` is alias for `StopService`.  
`runs`, `runsr`, `runsd` also take optional argument service alias like `runs prot`. This now works for BackupDataPlane services.

OnebranchPS Management Commands
-------------------------------
- **obpsinit** - Re-initializes OnebranchPS
- **obpsroot** - Switches to OnebranchPS installation directory
- **obpsorigin** - Opens https://dhratho.visualstudio.com/OnebranchPS/ in browser
- **obpsdoc** - Opens this file in browser for viewing documentation. Url: https://aka.ms/obpsCommands

Repo oriented commands
----------------------
- **sln** => Opens current repo's solution (only works for bcm, bms, common, ecs, id, mon, prov, rrp)
- **bmssln** => Opens BMS solution
- **bcmsln** => Opens BCM solution
- **dtsln** => Opens Data Transfer Service solution
- **dcsln** => Opens Diff Copy Service solution
- **ecssln** => Opens Endpoint Communication Service solution
- **fcsln** => Opens File Catalog Service solution
- **protsln** => Opens Protection Service solution
- **prottestsln** => Opens Protection Test project

Other Aliases ported from OneBranch
-----------------------------------
- *init*  
    `. $env:REPOROOT\init.ps1 $args`

- *reporoot*  
	`pushd $env:REPOROOT\$args`

- *..*  
	`pushd ..`

- *...*  
	`pushd ..\..`

- *....*  
	`pushd ..\..\..`

- *vsms*  
	`vsmsbuild /v:16.0 $args`

- *vsms14*  
	`vsmsbuild /v:14.0 $args`

- *vsms15*  
    `vsmsbuild /v:15.0 $args`

- *bld*  
	`quickbuild`

- *bldd*  
	`build debug -amd64 $args`

- *bldr*  
	`build retail -amd64 $args`

- *gp*  
	`git pull`

- *gb*  
	`git branch $args`

- *gco*  
	`git checkout $args`

- *gcco*  
	`git checkout -b $args`

- *ga*  
	`git add $args`

- *gaa*  
	`git add -A`

- *gaac*  
	`git add .`

- *gs*  
	`git status $args`

- *gcm*  
	`git commit -m $args`

- *gcam*  
	`git commit -a -m $args`

- *gbd*  
	`git branch -D $args`

- *gprune*  
	`git remote prune origin`

- *gr*  
	`git rm $args`

- *gm*  
	`git merge $args`

- *gmt*  
	`git mergetool`

- *gdt*  
	`git difftool $args`

- *gdtc*  
	`git difftool --cached`

- *q*  
	`quickbuild $args`

- *qbc*  
	`quickbuild -buildcop`

- *qbcop*  
	`quickbuild -buildcop`

- *qimd*  
	`quickbuild -detectinputmismatches=BreakBuild`

- *qnocache*  
	`quickbuild -cachetype none -nocbc $args`

- *packd*  
    `pushd $env:REPOROOT ; quickbuild ; popd`

- *packr*  
    `pushd $env:REPOROOT ; build retail -amd64 ; popd`

- *clean*  
    `git clean -xfd -e .gen -e gen -e .packages $args`

- *root*  
    `pushd $env:REPOROOT\$args`

- *src*  
    `pushd $env:SRCROOT\$args`

- *nuget*  
    `pushd $env:SRCROOT\NuGet\$args`

- *sign*  
    `pushd $env:SRCROOT\Codesign\$args`

- *svc*  
    `pushd $env:SRCROOT\Service\$args`
