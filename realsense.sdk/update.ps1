import-module au

$releases = 'https://github.com/IntelRealSense/librealsense/releases'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"   = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -UseBasicParsing -Uri $releases
    
    # there are two sdk installer names and executables
    $url   = $download_page.links | ? href -match 'Intel.RealSense.SDK.exe$|rssetup-(\d+\.){3,}\d+\.exe$' | % href | select -First 1
    $version = (Split-Path ( Split-Path $url ) -Leaf).Substring(1)

    @{
        InstallerFileName = Split-Path $url -Leaf
        URL32   = 'https://github.com' + $url
        Version = $version
    }
}

function Set-DescriptionFromInstaller($Package) {
    $pkg_path = [System.IO.Path]::GetFullPath("$Env:TEMP\chocolatey\$($package.Name)\" + $global:Latest.Version)
    $installer_path = Join-Path $pkg_path $Latest.InstallerFileName
    $readme_path = Join-Path $pkg_path 'readme.md'
    
    Get-WebFile -Url 'https://github.com/IntelRealSense/librealsense/blob/master/readme.md' -FileName $readme_path -Passthru
    
    $readme_description = Get-Content -Raw -Path $readme_path
    
    Out-String -InputObject "piiiiiiiiiiiitttttttttoooooooooo"
    
    # Extract components from the installer
    .\tools\innounp.exe -x $installer_path -d$pkg_path 'install_script.iss'
    
    if($LASTEXITCODE -ne 0) {
        throw "Error extracting the installer meta file, with the components."
    }

    $stringmatch = Get-Content -Raw -Path Join-Path $pkg_path 'install_script.iss'

    $matches = Select-String -InputObject $stringmatch '\[Components\]\s*\n((Name:\s*"(\w+)";\s*Description:\s*"([^"]+)").*\n)+' -AllMatches

    $component_keys = $matches.Matches.Groups[3].Captures.Value
    $component_descriptions = $matches.Matches.Groups[4].Captures.Value

    $components = [System.Collections.Specialized.OrderedDictionary]@{}

    for($i=0; $i -lt $component_keys.Count; $i++) {
        $components.Add($component_keys[$i], $component_descriptions[$i])
    }
    
    $description = '"#### Optional Components
$($components.GetEnumerator() | % { "* ``$($_.Name)`` - $($_.Value)`n" })
 
#### Package Parameters
The following package parameters can be set:
 * ``/NoIcons`` - install quick lauch icon
 * ``/Components`` - list of components optional components to install.

These parameters can be passed to the installer with the use of ``-params``.
For example: ``-params ''"/NoIcons /Components tools,dev"''``.

**Please Note**: This is an automatically updated package. If you find it is 
out of date by more than a day or two, please contact the maintainer(s) and
let them know the package is no longer updating correctly.
"'

#    $result = Invoke-Expression $description
    
}

function global:au_AfterUpdate ($Package)  {
    $host.ui.WriteErrorLine( '-----------------------------------------------')
    
    Set-DescriptionFromInstaller $Package
    
    Out-String -InputObject $LASTEXITCODE
    
    Out-String -InputObject $Latest.InstallerFileName

    Out-String -InputObject $Latest.URL32
    
    Out-String -InputObject $pkg_path -Width 100
    
    Out-String -InputObject $Package.Result -Width 100
    
    Out-String -InputObject $Package -Width 100
    
}    

update -ChecksumFor 32
