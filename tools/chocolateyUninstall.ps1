# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

$toolsDir		= "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$helpers = @('helpers')
foreach ($helper in $helpers) {
	Write-Verbose "$($MyInvocation.MyCommand):Looking for helper script: $toolsDir\$helper.ps1"
	if ( ( Test-Path -Path "$toolsDir\$helper.ps1" ) ) {
		Write-Verbose "$($MyInvocation.MyCommand):Loading helper script: $toolsDir\$helper.ps1"
		. $toolsDir\$helper.ps1
	} else {
		Write-Error -Message "Helper script is not installed: $toolsDir\$helper.ps1" -ErrorAction Stop
	}
}

$packageSearch		= 'KeePass Password Safe*'
$KeePassPath		= ''

if ([array]$key = Get-UninstallRegistryKey -SoftwareName $packageSearch) {
  $KeePassPath = $key.InstallLocation
}

if ([string]::IsNullOrEmpty($KeePassPath)) {
  Write-Verbose "Cannot find '$packageSearch' in Add / Remove Programs or Programs and Features."
  Write-Verbose "Searching '$env:ChocolateyToolsLocation' for portable install..."
  $portPath = Join-Path -Path $env:ChocolateyToolsLocation -ChildPath 'keepass'
  $KeePassPath = Get-ChildItem -Directory "$portPath*" -ErrorAction SilentlyContinue

  if ([string]::IsNullOrEmpty($KeePassPath)) {
    Write-Verbose "Searching '$env:Path' for unregistered install..."
    $installFullName = Get-Command -Name keepass -ErrorAction SilentlyContinue
    if ($installFullName) {
      $KeePassPath = Split-Path $installFullName.Path -Parent
    }
  }
}

if ([string]::IsNullOrEmpty($KeePassPath)) {
  Write-Error -Message 'Cannot find Keepass! Exiting now as it''s needed to remove the plugin.' -ErrorAction Stop
}

Write-Host "Found Keepass install location at '$KeePassPath'."

$KeePassPluginPath	= 'Plugins'
$KeePassPluginName	= 'EarlyUpdateCheck.plgx'
$KeePassPluginCfgName	= 'ExternalPluginUpdates.xml'
$destPluginPath		= "$(Join-Path -Path $KeePassPath -ChildPath $KeePassPluginPath)"
$destFileFullPath	= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginName)"
$destFile2FullPath	= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginCfgName)"

if (Test-Path $destFileFullPath) {
  Write-Host "Removing Keepass plugin file`n  from '$destFileFullPath'"
  Remove-Item -Path $destFileFullPath -Force
}

if (Test-Path $destFile2FullPath) {
  $destFile2FullPathTimestamped = (Get-FileName-Globbed -filename $destFile2FullPath)
  Write-Host "Removing Keepass plugin configuration file(s)`n  from '$destFile2FullPathTimestamped'"
  Remove-Item -Path $destFile2FullPathTimestamped -Force
}
