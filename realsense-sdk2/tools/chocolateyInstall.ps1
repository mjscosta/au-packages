$ErrorActionPreference = 'Stop'
 
$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1
 
$pp = Get-PackageParameters

$packageArgs = @{
    PackageName  = 'realsense.sdk'
    FileType     = 'exe'
    SoftwareName = 'Intel® RealSense™ SDK 2.0'
    url          = 'https://github.com/IntelRealSense/librealsense/releases/download/v2.20.0/Intel.RealSense.SDK.exe'
    checksum     = '3b4a4afdbff58c2c1976b3b523b9eef7e6e82ffe4968637f3d6468a2ad185445'
    checksumType = "sha256"
    silentArgs   = "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/NOCANCEL", "/SP-", 
                   "/LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).Install.log`"", 
                   (Get-InstallComponents $pp), (Get-InstallOptions $pp)
    validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

$installDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
