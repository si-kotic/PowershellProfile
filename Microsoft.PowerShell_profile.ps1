$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())


if (!($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )))
    {
        (get-host).UI.RawUI.Backgroundcolor="DarkRed"
        clear-host
        write-host "WARNING: POWERSHELL IS NOT RUNNING AS AN ELEVATED SESSION!"
    }
else
{
	. C:\PowerShellScripts\Get-BatteryLevel\Get-BatteryLevel.ps1
	function prompt{
		$(Get-BatteryLevel) + "ADMIN " + $(Get-Location) + ">"
	}
}

New-PSDrive -PSProvider filesystem -name Script -root "C:\PowerShellScripts"
set-location script:

Import-Module C:\PowerShellScripts\Manage-VPNs\Manage-VPNs.psm1 -Force
. .\Get-NetworkStatistics\Get-NetworkStatistics.ps1
. .\Launch-PSSession\Launch-PSSession.ps1
. .\Test-OpenPorts\Test-OpenPort.ps1
set-location $home

function RDP-Full {param ([string]$destination) mstsc /v:$destination /f}
function RDP-Span {param ([string]$destination) mstsc /v:$destination /f /multimon}
function RDP-Mini {param ([string]$destination) mstsc /v:$destination /w:1152 /h:864}
Function Connect-ExchangeOnline {
	Param (
	$Credentials
	)
	$exchSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credentials -Authentication Basic -AllowRedirection
	Import-PSSession $exchSession
}
<#  COMMENTED OUT UNTIL I'VE SET UP VIRTUALBOX!
function Run-Win2003 {. 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' startvm Win2003}
Function Get-VMs {
	$Report = "" | Select-Object -Property Name,OS,Memory,CPUs,PowerState
	. 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' list vms | ForEach-Object {
		$Report.Name = $_.Split('"')[1]
		$fullInfo = . 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' showvminfo $Report.Name
		$Report.OS = ($fullInfo | Where {$_ -like "Guest OS*"}).SubString(17)
		$Report.Memory = ($fullInfo | Where {$_ -like "Memory Size*"}).SubString(17)
		$Report.CPUs = ($fullInfo | Where {$_ -like "Number of CPUs*"}).SubString(17)
		$Report.PowerState = ($fullInfo | Where {$_ -like "State*"}).SubString(17)
		$Report
	}
} #>

$TempFileSize = 0
Get-Item C:\Tmp | Get-Childitem -Recurse | Foreach-Object {
$TempFileSize += $_.length
}
If (($TempFileSize/1MB) -ge 200)
{
	Write-Output ("Your Tmp directory is " + $TempFileSize/1MB + " MB in size, you should consider clearing it down")
}