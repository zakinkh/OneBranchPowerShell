$repoServiceMap = @{
    "Mgmt-RecoverySvcs-IaaSCoord"="IAASCoordinatingService";
    "Mgmt-RecoverySvcs-BackupMgmt"="BMSService";
    "Mgmt-RecoverySvcs-Common"="Common";
    "Mgmt-RecoverySvcs-EndpointComm"="ECService";
    "Mgmt-RecoverySvcs-IdMgmt"="IdMgmtService";
    "Mgmt-RecoverySvcs-Monitoring"="MonitoringService"
    "Mgmt-RecoverySvcs-Provisioning"="ProvisioningService";
    "Mgmt-RecoverySvcs-RegionalRP"="RegionalResourceProviderService";
    "Mgmt-RecoverySvcs-RetentionAgent"="RAService";
    "Mgmt-RecoverySvcs-BackupDataPlane"="PITCatalogService";
	"Mgmt-RecoverySvcs-PitCatalog"="PITCatalogService";
    "Mgmt-RecoverySvcs-Tools-Dev"="DevTools";
};

$Global:ServiceName = ""
if (Test-Path $env:REPOROOT\repo.config) {
    [xml]$repoConfig = Get-Content -Path $env:REPOROOT\repo.config
    $repoName = $repoConfig.Repository.Name
    $Global:ServiceName = $repoServiceMap[$repoName]
} else {
    Write-Error "File $env:REPOROOT\repo.config does not exist!"
}

function global:init {
    . $env:REPOROOT\init.ps1 $args
}

function global:sln {
    $serviceName = $Global:ServiceName

    if ($serviceName.ToLower() -eq "Common".ToLower()) { # Special handling for common repo
        vsms $env:REPOROOT\dirs.proj $args
    } elseif ($serviceName.ToLower() -eq "ProtectionService".ToLower()) {
        vsms $env:REPOROOT\src\Service\Protection\$($serviceName)\$($serviceName).ccproj $args
    } elseif ($serviceName.ToLower() -eq "RAService".ToLower()) { # Special handling for Retention Agent repo
        vsms $env:REPOROOT\src\Service\Service\$($serviceName).ccproj $args
    } elseif ($serviceName.ToLower() -eq "PITCatalogService".ToLower()) { # Special handling for PITCatalog service repo
        vsms $env:REPOROOT\src\Service\PITCatalog\$($serviceName).ccproj $args
    }else {
        vsms $env:REPOROOT\src\Service\$($serviceName)\$($serviceName).ccproj $args
    }
}

function global:apitest {
    vsms $env:REPOROOT\src\Test\Protection\ApiTests\ApiTests.csproj $args
}

function global:pit {
    Push-Location $env:REPOROOT\src\Service\PITCatalog
}

function global:pitv {
    vsms $env:REPOROOT\src\Service\PITCatalog\PITCatalogService\PITCatalogService.ccproj $args
}

function global:pitc {
    vsms $env:REPOROOT\src\Service\PITCatalog\PITCatalogService\PITCatalogService.ccproj $args
}

function global:pitsln {
    vsms $env:REPOROOT\src\Service\PITCatalog\PITCatalogService\PITCatalogService.ccproj $args
}

function global:pittest {
    Push-Location $env:REPOROOT\src\Test\PITCatalog
}

function global:pittestv {
    vsms $env:REPOROOT\src\Test\PITCatalog\dirs.proj
}

function global:ptstv {
    pittestv
}

function global:bldpit {
    clean
    init
    pit
    nocspack
    bldr
    pittest
    bldr
}

function global:bldpitcs {
    clean
    init
    pit
    cspack
    bldd
    pittest
    bldd
}

function global:runpit{
    $dfPathTemplate = "$env:INETROOT\out\debug-amd64\StartPITCatalogService\StartPITCatalogService.exe"
    $dfPath = $dfPathTemplate -f "debug"		
    Write-Host "dfPath: $dfPath"
    & $dfPath @args    
}

function global:bldrpit {
    clean
    init
    pit
    cspack
    bldd
    pittest
    bldd
	runpit
}

function global:pjs {
        edit $env:REPOROOT\src\Service\PITCatalog\PITCatalogService\PITCatalogServiceDeploymentConfig_Production.json
}

function global:ptjs {
        edit $env:REPOROOT\src\Service\PITCatalog\PITCatalogService\PITCatalogServiceDeploymentConfig_Production.json
}

function global:bcm {
    Push-Location $env:REPOROOT\src\Service\IAASCoordinatingService
}

function global:bcmsln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsmsbuild /v:16.0 $env:REPOROOT\src\Service\IAASCoordinatingService\IAASCoordinatingService.ccproj $args
#    vsms $env:REPOROOT\src\Service\IAASCoordinatingService\IAASCoordinatingService.ccproj $args
}

function global:bms {
    Push-Location $env:REPOROOT\src\Service\BMSService
}

function global:bmssln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsms $env:REPOROOT\src\Service\BMSService\BMSService.ccproj $args
}

function global:ecs {
    Push-Location $env:REPOROOT\src\Service\ECService
}

function global:ecssln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsms $env:REPOROOT\src\Service\ECService\ECService.ccproj $args
}

function global:id {
    Push-Location $env:REPOROOT\src\Service\IdMgmtService
}

function global:idsln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsms $env:REPOROOT\src\Service\IdMgmtService\IdMgmtService.ccproj $args
}

function global:prov {
    Push-Location $env:REPOROOT\src\Service\ProvisioningService
}

function global:provsln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsms $env:REPOROOT\src\Service\ProvisioningService\ProvisioningService.ccproj $args
}

function global:ra {
    Push-Location $env:REPOROOT\src\service\
}

function global:rasln {
    vsms $env:REPOROOT\src\dirs.proj /solutionname:"RA.sln" $args
}

function global:ratest {
    Push-Location $env:REPOROOT\src\Test\
}

function global:rrp {
    Push-Location $env:REPOROOT\src\Service\RegionalResourceProviderService
}

function global:rrpsln {
    Write-Warning -Message "[Deprecated] Use 'sln' command instead"
    vsms $env:REPOROOT\src\Service\RegionalResourceProviderService\RegionalResourceProviderService.ccproj $args
}

<# Adding dataplane aliases #>
function global:dt {
    Push-Location $env:REPOROOT\src\Service\DataTransfer
}

function global:dtsln {
    vsms $env:REPOROOT\src\Service\DataTransfer\DataTransferService\DataTransferService.ccproj $args
}

function global:dc {
    Push-Location $env:REPOROOT\src\Service\DiffCopy
}

function global:dcsln {
    vsms $env:REPOROOT\src\Service\DiffCopy\DiffCopyService\DiffCopyService.ccproj $args
}

function global:fc {
    Push-Location $env:REPOROOT\src\Service\FileCatalog
}

function global:fcsln {
    vsms $env:REPOROOT\src\Service\FileCatalog\FileCatalogService\FileCatalogService.ccproj $args
}

function global:prot {
    Push-Location $env:REPOROOT\src\Service\Protection
}

function global:protsln {
    vsms $env:REPOROOT\src\Service\Protection\ProtectionService\ProtectionService.ccproj $args
}

function global:rec {
    Push-Location $env:REPOROOT\src\Service\Recovery
}

function global:recsln {
    vsms $env:REPOROOT\src\Service\Recovery\RecoveryService\RecoveryService.ccproj $args
}

function global:prottest {
    Push-Location $env:REPOROOT\src\Test\Protection\MSTestCases\ProtectionTestCases
}

function global:prottestsln {
    vsms $env:REPOROOT\src\Test\Protection\MSTestCases\ProtectionTestCases\ProtectionTestCasesVS2015\ProtectionTestCasesVS2015.csproj $args
}

function global:test {
    Push-Location $env:REPOROOT\src\Test\
}

function global:pts {
    vsms $env:REPOROOT\src\Test\Protection\MSTestCases\ProtectionTestCases\ProtectionTestCasesVS2015\ProtectionTestCasesVS2015.csproj $args
}

function global:org {
    $url = git config --get remote.origin.url
    explorer $url
}

function global:origin {
    $url = git config --get remote.origin.url
    explorer $url
}

function global:js {
    if ($serviceName.ToLower() -eq "ProtectionService".ToLower())
    {
        edit $env:REPOROOT\src\Service\Protection\ProtectionService\ProtectionServiceDeploymentConfig_Production.json
    } 
    elseif ($serviceName.ToLower() -eq "BMSService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\BMSService\BCDRManagementServiceDeploymentConfig_Production.json
    }
    elseif ($serviceName.ToLower() -eq "IAASCoordinatingService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\IAASCoordinatingService\IaaSCoordinatingServiceDeploymentConfig_Production.json
    }
}

function global:tjs {    
    if ($serviceName.ToLower() -eq "ProtectionService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\Protection\ProtectionService\ProtectionServiceDeploymentConfig_Test.json	
    }
    elseif ($serviceName.ToLower() -eq "BMSService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\BMSService\BCDRManagementServiceDeploymentConfig_Test.json
    }
    elseif ($serviceName.ToLower() -eq "IAASCoordinatingService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\IAASCoordinatingService\IaaSCoordinatingServiceDeploymentConfig_Test.json
    }
}

function global:cfg {
    if ($serviceName.ToLower() -eq "ProtectionService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\Protection\ProtectionService\ServiceConfiguration.Cloud.cscfg
    }
    elseif ($serviceName.ToLower() -eq "BMSService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\BMSService\ServiceConfiguration.Cloud.cscfg
    }
    elseif ($serviceName.ToLower() -eq "IAASCoordinatingService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\IAASCoordinatingService\ServiceConfiguration.Cloud.cscfg
    }
}

function global:lcfg {
    if ($serviceName.ToLower() -eq "ProtectionService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\Protection\ProtectionService\ServiceConfiguration.Local.cscfg
    }
    elseif ($serviceName.ToLower() -eq "BMSService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\BMSService\ServiceConfiguration.Local.cscfg
    }
    elseif ($serviceName.ToLower() -eq "IAASCoordinatingService".ToLower()) 
    {
        edit $env:REPOROOT\src\Service\IAASCoordinatingService\ServiceConfiguration.Local.cscfg
    }
}

function global:cdef {
    edit $env:REPOROOT\src\Service\Protection\ProtectionService\ServiceDefinition.csdef
}

function global:out  {
    Push-Location $env:REPOROOT\out
}

function global:dbg  {
    Push-Location $env:REPOROOT\out\debug-amd64\
}

function global:ret  {
    Push-Location $env:REPOROOT\out\retail-amd64\
}