
function global:obpsinit {
    . $env:OsumOnebranchPsRoot\OnebranchPsInit.ps1
}
function global:obpsroot {
    Push-Location $env:OsumOnebranchPsRoot
}

function global:obpsorigin {
    explorer "https://dhratho.visualstudio.com/OnebranchPS/"
}

function global:obpsdoc {
    explorer "https://aka.ms/obpsCommands"
}

# edit alias to open file in text editor
function global:edit {
    $configuredEditor = Get-Variable -Name MyTextEditor -Scope Global -ErrorAction SilentlyContinue
    if ($configuredEditor -eq $null) {
        notepad $args
    } else {
        & $configuredEditor.Value $args
    }
}

function global:cx {
    edit $env:REPOROOT\.corext\corext.config
}

function global:editmine {
    edit $env:OsumOnebranchPsRoot\mine.ps1
}