param($vcenter,$username,$password,$vmname)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force

Write-host "Deleting VM $vmname" -ForegroundColor Green
Remove-VM -VM $vmname -DeletePermanently -Confirm:$false 

Disconnect-VIServer -Server $vcenter -Confirm:$False
