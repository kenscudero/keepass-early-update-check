# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

$packageName		= $env:ChocolateyPackageName
$toolsDir		= "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url			= 'https://github.com/Rookiestyle/EarlyUpdateCheck/releases/download/v3.4.2/EarlyUpdateCheck.plgx'
$url2			= 'https://raw.githubusercontent.com/Rookiestyle/EarlyUpdateCheck/master/ExternalPluginUpdates/ExternalPluginUpdates.xml'
$checksum		= '1573B52948233419595772245731EA533B42959C7BCF290944227045987D1E12'
$checksumType		= 'SHA256'
$checksum2		= 'B2A65101DF59AB784623A670D53E794374EAF06DF8E16359A4007091C63AF065'
$checksum2Type		= 'SHA256'
$sourcePluginsDir	= "$(Join-Path -Path $toolsDir -ChildPath Plugins)"
$KeePassPluginName	= 'EarlyUpdateCheck.plgx'
# This is the name of
# standard (e.g. downloaded) 'plugin configuration file'
$KeePassPluginCfgName	= "ExternalPluginUpdates.xml"
# This is the name of a 'plugin configuration addendum file(s)'
# (optionally found in the Keepass plugins directory)
# which should automatically be appended
# to the standard (e.g. downloaded) 'plugin configuration file'
$KeePassPluginCfg2Name	= 'AddExternalPluginUpdates-*.xml'
$sourceFileFullPath	= "$(Join-Path -Path $sourcePluginsDir -ChildPath $KeePassPluginName)"
$sourceFile2FullPath	= "$(Join-Path -Path $sourcePluginsDir -ChildPath $KeePassPluginCfgName)"
# This is the full path of a 'plugin configuration addendum file'
# (optionally found in the Tools directory)
# which should automatically be appended
# to the standard (e.g. downloaded) 'plugin configuration file'
$sourceFile3FullPath	= "$(Join-Path -Path $toolsDir -ChildPath $KeePassPluginCfg2Name)"

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

Get-ChocolateyWebFile -PackageName "$packageName" `
                      -Url $url -FileFullPath "$sourceFileFullPath" `
                      -Checksum "$checksum" -ChecksumType "$checksumType"

Get-ChocolateyWebFile -PackageName "$packageName" `
                      -Url $url2 -FileFullPath "$sourceFile2FullPath" `
                      -Checksum "$checksum2" -ChecksumType "$checksum2Type"

$packageSearch		= 'KeePass Password Safe*'
$KeePassPath		= ''

if ([array]$key = Get-UninstallRegistryKey -SoftwareName $packageSearch) {
  $KeePassPath = $key.InstallLocation
}

if ([string]::IsNullOrEmpty($KeePassPath)) {
  Write-Verbose "Cannot find '$packageSearch' in Add / Remove Programs or Programs and Features."
  Write-Verbose "Searching '$env:ChocolateyToolsLocation' for portable install..."
  $portPath = Join-Path -Path $env:ChocolateyToolsLocation -ChildPath "keepass"
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
  Write-Error -Message 'Cannot find Keepass! Exiting now as it''s needed to install the plugin.' -ErrorAction Stop
}

Write-Host "Found Keepass install location at '$KeePassPath'."

$KeePassPluginPath	= 'Plugins'
$destPluginPath		= "$(Join-Path -Path $KeePassPath -ChildPath $KeePassPluginPath)"
$destFileFullPath	= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginName)"
$destFile2FullPath	= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginCfgName)"

$errorMessage		=
if (Test-Path $sourceFileFullPath) {
  if (Test-Path $sourceFile2FullPath) {
    if (Test-Path $destPluginPath) {
      Write-Host "Copying Keepass plugin file '$sourceFileFullPath'`n  to '$destFileFullPath'"
      Copy-Item -Path $sourceFileFullPath -Destination $destFileFullPath
      Set-File-KeePass-EarlyUpdate-Config -toolsDir $toolsDir -sourcePluginsDir $sourcePluginsDir -destPluginPath $destPluginPath
    } else {
      $errorMessage = 'Cannot find Keepass plugin destination!'
    }
  } else {
    $errorMessage = 'Cannot find Keepass plugin configuration file source!'
  }
} else {
    $errorMessage = 'Cannot find Keepass plugin source!'
}
if ($errorMessage) {
  Write-Error -Message "$errorMessage Exiting now as it's needed to install the plugin." -ErrorAction Stop
}

$processName		= 'KeePass'

if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
  Write-Warning "$processName is currently running.`n$($packageName) will be available at next restart."
} else {
  Write-Host "$($packageName) will be loaded the next time $processName is started."
}
