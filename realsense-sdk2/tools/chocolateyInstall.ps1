$ErrorActionPreference = 'Stop'
 
$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1
 
$pp = Get-PackageParameters

$packageArgs = @{
    PackageName  = 'realsense.sdk'
    FileType     = 'exe'
    SoftwareName = 'Intel® RealSense™ SDK 2.0'
    url          = 'https://github.com/IntelRealSense/librealsense/releases/download/v2.17.1/Intel.RealSense.SDK.exe'
    checksum     = '575b877d749c818a29e7b678e0923188c20f5f4d57afa94e812b37d8beb13e7e'
    checksumType = "sha256"
    silentArgs   = "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/NOCANCEL", "/SP-", 
                   "/LOG=`"$($env:TEMP)\$($env:chocolateyPackageName).$($env:chocolateyPackageVersion).Install.log`"", 
                   (Get-InstallComponents $pp), (Get-InstallOptions $pp)
    validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

$installDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]

if($pp.Addx64LibsToPath) {
    Install-ChocolateyPath -PathToInstall ($installDir + '\Intel RealSense SDK 2.0\bin\x64') -PathType Machine 
}

if($pp.Addx86LibsToPath) {
    Install-ChocolateyPath -PathToInstall ($installDir + '\Intel RealSense SDK 2.0\bin\x86') -PathType Machine 
}

if($pp.AddToolsToPath) {
    Install-ChocolateyPath -PathToInstall ($installDir + '\Intel RealSense SDK 2.0\tools') -PathType Machine 
}
