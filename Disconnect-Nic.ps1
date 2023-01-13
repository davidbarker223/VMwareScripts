param($vcenter,$username,$password,$vmname,$screamtag)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force

Write-host "Disabling NIC and adding tag to $vmname" -ForegroundColor Green
Get-VM $vmname | Get-NetworkAdapter | where{$_.ConnectionState.Connected} | Set-NetworkAdapter -Connected:$false -StartConnected:$false -Confirm:$false
#Set-VM $vmname -Notes $notes -Confirm:$false
Get-Vm $vmname | New-TagAssignment -tag $screamtag -confirm:$false

Disconnect-VIServer -Server $vcenter -Confirm:$False
