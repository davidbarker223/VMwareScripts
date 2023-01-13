param($vcenter,$username,$password,$vmname)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force

Write-host "Deleting Snapshot from VM $vmname" -ForegroundColor Green
Get-VM $vmname | Get-Snapshot | Remove-Snapshot -confirm:$false

Disconnect-VIServer -Server $vcenter -Confirm:$False
