# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
$ErrorActionPreference	= 'Stop';

if ( -not ( Test-Path -Path "$env:ProgramData\Chocolatey" ) ) {
	Write-Error -Message "Chocolatey is not installed" -ErrorAction Stop
}

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition

$helpers = @('Get-FileName-Globbed','Set-File-KeePass-EarlyUpdate-Config')
foreach ($helper in $helpers) {
	Write-Verbose "$($MyInvocation.MyCommand):Looking for helper script: $toolsPath\$helper.ps1"
	if ( ( Test-Path -Path "$toolsPath\$helper.ps1" ) ) {
		Write-Verbose "$($MyInvocation.MyCommand):Loading helper script: $toolsPath\$helper.ps1"
		. $toolsPath\$helper.ps1
	} else {
		Write-Error -Message "Helper script is not installed: $toolsPath\$helper.ps1" -ErrorAction Stop
	}
}
