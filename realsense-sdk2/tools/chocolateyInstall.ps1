$ErrorActionPreference = 'Stop'
 
$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1
 
$pp = Get-PackageParameters

$packageArgs = @{
    PackageName  = 'realsense.sdk'
    FileType     = 'exe'
    SoftwareName = 'Intel® RealSense™ SDK 2.0'
    url          = 'https://github.com/IntelRealSense/librealsense/releases/download/v2.19.0/Intel.RealSense.SDK.exe'
    checksum     = 'c2b87eea2fcc7264dfa86163a640a26506797be1fefd05f22abd4dc6b8974f50'
    checksumType = "sha256"
    silentArgs   = "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/NOCANCEL", "/SP-", 
                   "/LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).Install.log`"", 
                   (Get-InstallComponents $pp), (Get-InstallOptions $pp)
    validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

$installDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
