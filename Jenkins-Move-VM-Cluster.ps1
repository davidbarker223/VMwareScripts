param($vcenter,$username,$password,$vmname,$cluster)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force

Write-host "Moving VM $vmname to $cluster" -ForegroundColor Green
Move-VM -VM $vmname -Destination $cluster -Confirm:$false 

Disconnect-VIServer -Server $vcenter -Confirm:$False
