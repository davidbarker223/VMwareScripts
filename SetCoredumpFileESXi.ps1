connect-viserver #vCenter
Param (
  [Parameter(Mandatory=$true)]
    [string]$vcenter,
  [Parameter(Mandatory=$true)]
    [string]$user,
  [Parameter(Mandatory=$true)]
    [string]$password,
  [Parameter(Mandatory=$true)]
    [string]$datastore
) Connect-VIServer -Server $vcenter -user $user -Password $password $GetHost = Get-VMhost 
$vcenter = "vcenter"
Foreach ($hst in $GetHost)
{
Get-VMhost $hst 
$datastore = "datastorename"
$hst = "hostname"
$esxcli = Get-VMHost $hst | Get-EsxCli
$esxcli.system.coredump.file.add($null,$datastore, $true, $hst)
} Disconnect-VIServer $vcenter -Force -Confirm:$false -ErrorAction SilentlyContinue


#Simplified Version

$datastore = "datastorename"
$hst = "hostname"
$esxcli = Get-VMHost $hst | Get-EsxCli
$esxcli.system.coredump.file.add($null,$datastore, $true, $hst)
