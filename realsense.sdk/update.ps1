import-module au

$releases = 'https://github.com/IntelRealSense/librealsense/releases'

function global:au_SearchReplace {
   @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"   = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum)'"
        }
    }
}

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -UseBasicParsing -Uri $releases
    
    # there are two sdk installer names and executables
    $url   = $download_page.links | ? href -match 'Intel.RealSense.SDK.exe$|rssetup-(\d+\.){3,}\d+\.exe$' | % href | select -First 1
    $version = (Split-Path ( Split-Path $url ) -Leaf).Substring(1)

    @{
        URL32   = 'https://github.com' + $url
        Version = $version
    }
}

function global:au_AfterUpdate ($Package)  {

}

update
