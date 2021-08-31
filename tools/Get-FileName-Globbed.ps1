# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

function Get-FileName-Globbed() {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$filename,
    $globbed
  )

  begin {
    if ([string]::IsNullOrEmpty($globbed)) { $globbed = '*' }
    else {
      $timestampPrefix = '-t'
      if ($globbed -eq 'time') {
        $timestampFull = ( ( Get-Date -Format o ) -replace(':','') )
	$timezoneLength = '00:00'.Length
        $timestamp = $timestampPrefix + $timestampFull.split('.')[0]
        $timestamp += $timestamp + $timestampFull.substring(($timestampFull.Length - $timezoneLength),$timezoneLength)
      } else { $timestamp = $timestampPrefix + '*' }
      $globbed = $timestamp
    }
  }
  process {
    if ( $fileName -match('\.') ) { $sfx = '.' + $fileName.split('.')[-1] } else { $sfx = '' }
    $pfx = $fileName.Remove(($fileName.Length - $sfx.Length),$sfx.Length)
  }
  end {
    return "$pfx$globbed$sfx"
  }
}