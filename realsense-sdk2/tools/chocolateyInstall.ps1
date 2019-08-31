$ErrorActionPreference = 'Stop'
 
$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1
 
$pp = Get-PackageParameters

$packageArgs = @{
    PackageName  = 'realsense.sdk'
    FileType     = 'exe'
    SoftwareName = 'Intel® RealSense™ SDK 2.0'
    url          = 'https://github.com/IntelRealSense/librealsense/releases/download/v2.27.0/Intel.RealSense.SDK.exe'
    checksum     = '096bd0673fcb4ac8e98ea14f45c9f4eeba411d47bcb05764a3077d7613590b97'
    checksumType = "sha256"
    silentArgs   = "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/NOCANCEL", "/SP-", 
                   "/LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).Install.log`"", 
                   (Get-InstallComponents $pp), (Get-InstallOptions $pp)
    validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

$installDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
