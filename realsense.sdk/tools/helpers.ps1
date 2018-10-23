function Get-InstallComponents( [HashTable]$pp )
{
    if ($pp.Full) {
        $res += "tools", "dev", "py", "net", "matlab", "pdb"
    } elseif($pp.Components){ 
        $res += $pp.Components
    }

    if ($res.Length -eq 0) { return }
    return '/COMPONENTS="{0}"' -f ($res -join ",")
}

function Get-InstallOptions( [HashTable]$pp )
{
    
    if ($pp.NoIcons) { 
        $res += "/NOICONS"
    } 

#    $tasks += "desktopicon", "quicklaunchicon"
#    return '/TASKS="{0}"' -f ($res -join ",")
    return $res
}