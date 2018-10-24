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
    $installer_script = Join-Path $pkg_path 'install_script.iss'
    
    # clean installer script otherwise it will hang
    if(Test-Path $installer_script) {
        rm $installer_script
    }

    # Extract components from the installer
    .\tools\innounp.exe -x $installer_path "-d$pkg_path" 'install_script.iss'
    
    if($LASTEXITCODE -ne 0) {
        throw "Error extracting the installer meta file, with the components."
    }

    $stringmatch = Get-Content -Raw -Path $installer_script

    # clean installer script otherwise it will hang
    rm $installer_script

    $matches = Select-String -InputObject $stringmatch '\[Components\]\s*\n((Name:\s*"(\w+)";\s*Description:\s*"([^"]+)").*\n)+' -AllMatches

    $component_keys = $matches.Matches.Groups[3].Captures.Value
    $component_descriptions = $matches.Matches.Groups[4].Captures.Value

    $components = [System.Collections.Specialized.OrderedDictionary]@{}

    for($i=0; $i -lt $component_keys.Count; $i++) {
        $components.Add($component_keys[$i], $component_descriptions[$i])
    }
    
    $description_template = '"
#### Optional Components
$($components.GetEnumerator() | % { "* ``$($_.Name)`` - $($_.Value)`n" })
 
"'

    $description_header = 'Intel� RealSense� SDK 2.0 is a cross-platform library for Intel� RealSense� depth cameras (D400 series and the SR300).

The SDK allows depth and color streaming, and provides intrinsic and extrinsic calibration information. The library also offers synthetic streams (pointcloud, depth aligned to color and vise-versa), and a built-in support for record and playback of streaming sessions.
'

    $description_footer = '#### Package Parameters
The following package parameters can be set:
 * ``/NoIcons`` - install quick lauch icon
 * ``/Components`` - list of components optional components to install.

These parameters can be passed to the installer with the use of ``-params``.
For example: ``-params ''"/NoIcons /Components tools,dev"''``.

**Please Note**: This is an automatically updated package. If you find it is 
out of date by more than a day or two, please contact the maintainer(s) and
let them know the package is no longer updating correctly.'


    $description_body = Invoke-Expression $description_template
    
    $updated_description = $description_header + $description_body + $description_footer
    $cdata = $Package.NuspecXml.CreateCDataSection($updated_description)
    $xml_Description = $Package.NuspecXml.GetElementsByTagName('description')[0]
    $xml_Description.RemoveAll()
    $xml_Description.AppendChild($cdata) | Out-Null

    $Package.SaveNuspec()    
}

function global:au_AfterUpdate ($Package)  {
    Set-DescriptionFromInstaller $Package  
}    

update -ChecksumFor 32
