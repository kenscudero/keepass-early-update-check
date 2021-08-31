# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

function Set-File-KeePass-EarlyUpdate-Config() {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$toolsDir,
    [Parameter(Mandatory = $true)]
    [string]$sourcePluginsDir,
    [Parameter(Mandatory = $true)]
    [string]$destPluginPath
  )

  begin {
    # This is the name of
    # standard (e.g. downloaded) 'plugin configuration file'
    $KeePassPluginCfgName	= 'ExternalPluginUpdates.xml'
    # This is the name of a 'plugin configuration addendum file(s)'
    # (optionally found in the Keepass plugins directory)
    # which should automatically be appended
    # to the standard (e.g. downloaded) 'plugin configuration file'
    $KeePassPluginCfg2Name	= 'AddExternalPluginUpdates-*.xml'
    # This is the full path of
    # the standard (e.g. downloaded) 'plugin configuration file'
    # (found in the Tools directory)
    $sourceFile2FullPath	= "$(Join-Path -Path $sourcePluginsDir -ChildPath $KeePassPluginCfgName)"
    # This is the full path of a 'plugin configuration addendum file'
    # (optionally found in the Tools directory)
    # which should automatically be appended
    # to the standard (e.g. downloaded) 'plugin configuration file'
    $sourceFile3FullPath	= "$(Join-Path -Path $toolsDir -ChildPath $KeePassPluginCfg2Name)"
    # This is the full path to
    # the installed 'plugin configuration file'
    $destFile2FullPath		= "$(Join-Path -Path $destPluginPath -ChildPath $KeePassPluginCfgName)"
  }
  process {
    if (Test-Path $destPluginPath) {
       if (Test-Path $destFile2FullPath) {
           Write-Host "Found Keepass plugin configuration file`n  '$destFile2FullPath'"
           $destFile2FullPathTimestamped = (Get-FileName-Globbed -filename $destFile2FullPath -globbed 'time')
           Write-Host "Backing up KeePass plugin configuration file '$destFile2FullPath'`n   to (timestamped) file '$destFile2FullPathTimestamped'"
           Copy-Item -Path $destFile2FullPath -Destination $destFile2FullPathTimestamped -Force
       }
       Write-Host "Looking for Keepass plugin configuration addendum files`n  in '$destPluginPath\$KeePassPluginCfg2Name'"
       $addendumFiles = ( Get-ChildItem -Name -Path $destPluginPath -file $KeePassPluginCfg2Name )
       if ([string]::IsNullOrEmpty($addendumFiles)) {
           Write-Warning "Did not find (optional) Keepass plugin configuration addendum files`n  in '$destPluginPath\$KeePassPluginCfg2Name'"
           Write-Host "Copying Keepass plugin configuration file '$sourceFile2FullPath'`n  to '$destFile2FullPath'"
           Copy-Item -Path $sourceFile2FullPath -Destination $destFile2FullPath
       } else {
           Write-Host "Found [$($addendumFiles.Length)] Keepass plugin configuration addendum files`n  in '$destPluginPath\$KeePassPluginCfg2Name'`n"
           $addendumFiles | ForEach-Object {
              $sourceFile3FullPath = "$destPluginPath\$_"
              Write-Host "Found Keepass plugin configuration addendum file`n  '$sourceFile3FullPath'"

              $filterSourceFile2 = '^</UpdateInfoExternList>$'
              $filterSourceFile3 = '^<.xml version=".*" encoding=".*".>$|^<UpdateInfoExternList>$'

              Write-Host "Reading Keepass plugin configuration file`n  from '$sourceFile2FullPath'"
              $contentsFile2 = ( Get-Content -Path $sourceFile2FullPath ) -replace($filterSourceFile2) | where {$_ -ne ''}
              Write-Host "Reading Keepass plugin configuration addendum file`n  from'$sourceFile3FullPath'"
              $contentsFile3 = ( Get-Content -Path $sourceFile3FullPath ) -replace($filterSourceFile3) | where {$_ -ne ''}

              Write-Host "Combining Keepass plugin configuration files"
              $contentsFile = @()
              $contentsFile2 | ForEach-Object { $contentsFile += $_ }
              $contentsFile3 | ForEach-Object { $contentsFile += $_ }

              Write-Host "Writing combined Keepass plugin configuration files`n  to '$destFile2FullPath'`n"
              $contentsFile | Out-File -FilePath $destFile2FullPath
              $sourceFile2FullPath = $destFile2FullPath
           }
       }
       if (Test-Path $destFile2FullPath) {
          Write-Host "Found Keepass plugin configuration file`n  '$destFile2FullPath'"
          $destFile2FullPathTimestamped = (Get-FileName-Globbed -filename $destFile2FullPath -globbed 'time')
	  Write-Host "Backing up KeePass plugin configuration file '$destFile2FullPath'`n   to (timestamped) file '$destFile2FullPathTimestamped'"
	  Copy-Item -Path $destFile2FullPath -Destination $destFile2FullPathTimestamped -Force
       }
    } else {
       $errorMessage = "Cannot install plugin files in Keepass plugin destination!"
    }
  }
}