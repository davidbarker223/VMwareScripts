param($vcenter,$username,$password,$vmname,$envtag,$apptag,$exctag)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force

Write-host "Adding tag on $vmname" -ForegroundColor Green
Get-Vm $vmname | New-TagAssignment -tag $envtag -confirm:$false
Get-Vm $vmname | New-TagAssignment -tag $apptag -confirm:$false
Get-Vm $vmname | New-TagAssignment -tag $exctag -confirm:$false
Get-Vm $vmname | New-TagAssignment -tag $backtag -confirm:$false

Disconnect-VIServer -Server $vcenter -Confirm:$False

