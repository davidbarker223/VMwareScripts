param($vcenter,$username,$password,$vmname,$switch)
if($vmname)
{($vmname = $vmname -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$ErrorActionPreference = 'SilentlyContinue'

Connect-VIServer -Server $vcenter -user $username -password $password -Force


 if($switch -eq "on")
{ 
Write-host "Turning on $vmname" -ForegroundColor Green
start-vm $vmname -Confirm:$false
}


if($switch -eq "off")
{
Write-host " Powering off $vmname" -ForegroundColor Yellow
Shutdown-VMGuest -VM $vmname -Confirm:$false
}