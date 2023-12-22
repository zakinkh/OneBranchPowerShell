$Global:CsRunPath = "C:\Program Files\Microsoft SDKs\Azure\Emulator\csrun.exe"

$serviceDevFabricMap = @{
    "BMSService"="StartBMS";
    "ECService"="ECSDevFabricExe";
    "IdMgmtService"="CsRunExe";
    "MonitoringService"="StartMOS"
    "ProvisioningService"="CsRunExe";
    "RegionalResourceProviderService"="CsRunExe";
    "RAService"="StartRA";
    "PITCatalogService"="StartPITCatalogService";
    "IAASCoordinatingService"="StartBCMService";
};

$serviceAliasMap = @{
    "prot"="StartProtectionService";
    "rec"="StartRecoveryService";
    "dc"="StartDiffCopyService";
    "dts"="StartDataTransferService";
    "bms"="StartBMS";
    "id"="CsRunExe";
    "mon"="StartMOS";
    "prov"="CsRunExe";
    "rrp"="CsRunExe";
    "ecs"="ECSDevFabricExe";
    "ra"="StartRA";
    "pitc"="StartPITCatalogService";
    "pit"="StartPITCatalogService";
    "ic"="StartBCMService";
};

function global:RunService {
    param(
        $ServiceAlias = $null,

        [ValidateSet("debug", "retail")]
        $mode = "debug",

        # If $probe is true then it will first look into debug-amd64 and then retail-amd64.
        $probe = $false
    )

    Write-Host "ServiceAlias: $ServiceAlias"

    $dfName = $null

    # Try with $ServiceAlias first
    if ($null -ne $ServiceAlias) {
        if ($serviceAliasMap.ContainsKey($ServiceAlias)) 
        {
            $dfName = $serviceAliasMap[$ServiceAlias];
        } 
        else 
        {
            Write-Error "I can't understand this alias. Trying the old way!"
        }
    }    

    if ($null -eq $dfName) {
        $serviceName = $Global:ServiceName

        if ($serviceDevFabricMap.ContainsKey($serviceName)) 
        {
            $dfName = $serviceDevFabricMap[$serviceName]
        }
        else
        {
            Write-Error "No can do. No clue how to run service $serviceName"
            return
        }
    }	  
	
    $dfPathTemplate = "$env:INETROOT\out\{0}-amd64\$dfName\${dfName}.exe"
    if ($probe) 
    {
        # In case of probing (which is default behaviour) try debug path first.
        # General consensus is that debug build is preferred. Survey done with Prasant only. Totally biased survey!
        $debugDfPath = $dfPathTemplate -f "debug"
        if (Test-Path $debugDfPath)
        {
            & $debugDfPath @args
        }
        else
        {
            $retailDfPath = $dfPathTemplate -f "retail"
            & $retailDfPath @args
        }
    }
    else 
    {
        $dfPath = $dfPathTemplate -f $mode
		
        Write-Host "dfPath: $dfPath"
        & $dfPath @args
    }
}

function global:runs {
    param(
        $ServiceAlias = $null
    )

    Write-Host "ServiceAlias: $ServiceAlias"
    Write-Host @args

    RunService $ServiceAlias "debug" $true @args
}

function global:runsr {
    param(
        $ServiceAlias = $null
    )

    RunService $ServiceAlias "retail" $false @args
}

function global:runsd {
    param(
        $ServiceAlias = $null
    )

    RunService $ServiceAlias "debug" $false @args
}

function StopService {
    & $Global:CsRunPath /removeall
}

function global:ss {
    StopService
}

# Existing aliases for devfabric
function global:startbmsd {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsd
}

function global:startbmsr {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsr
}

function global:startecsd {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsd
}

function global:startecsr {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsr
}

function global:startmosd {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsd
}

function global:startmosr {
    Write-Warning -Message "[Deprecated] Use 'runs/runsr/runsd' command instead"
    runsr
}