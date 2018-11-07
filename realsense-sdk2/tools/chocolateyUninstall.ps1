$ErrorActionPreference = 'Stop'

$packageArgs = @{
  packageName   = 'realsense-sdk2'
  softwareName  = 'Intel RealSense SDK 2.0*'
  fileType      = 'exe'
  validExitCodes= @(0)
}

# lookup for the package installed data in the registry.
[array]$key = Get-UninstallRegistryKey @packageArgs

if ($key.Count -eq 1) {
  $key | ForEach-Object {
    $packageArgs['file'] = "$($_.QuietUninstallString)"

    Uninstall-ChocolateyPackage @packageArgs

    # Waiting Uninstall-ChocolateyPath to be added to chocolatey.
    # https://github.com/chocolatey/choco/issues/310
    # https://github.com/chocolatey/choco/pull/1663
#    $installDir = (${env:ProgramFiles(x86)}, ${env:ProgramFiles} -ne $null)[0]
#
#        Uninstall-ChocolateyPath -PathToUninstall ($installDir + '\Intel RealSense SDK 2.0\bin\x64') -PathType Machine 
#        Uninstall-ChocolateyPath -PathToUninstall ($installDir + '\Intel RealSense SDK 2.0\bin\x86') -PathType Machine 
#        Uninstall-ChocolateyPath -PathToUninstall ($installDir + '\Intel RealSense SDK 2.0\tools') -PathType Machine 
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert the package maintainer that the following keys were matched:"
  $key | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
}

