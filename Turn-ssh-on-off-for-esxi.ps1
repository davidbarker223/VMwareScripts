param($VIserver,$username,$password,$VMhosts,$switch)
if($VMhosts)
{($VMhosts = $VMhosts -split "`n")}
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer $VIserver -User $username -Password $password

#Turn on ssh serverice
 if($switch -eq "on")
{ 
Get-VMHostService $VMhosts | Where-Object {$_.key -eq "TSM-ssh"} |Set-VMHostService -policy "on" -Confirm:$false 
Get-VMHostService $VMhosts | Where-Object {$_.Key -eq "TSM-SSH"} | Restart-VMHostService -Confirm:$false
}
#Turn off ssh servcie 
if($switch -eq "off")
{
Get-VMHostService $VMhosts | Where-Object {$_.key -eq "TSM-ssh"} |Stop-VMHostService -Confirm:$false
Get-VMHostService $VMhosts | Where-Object {$_.key -eq "TSM-ssh"} |Set-VMHostService -policy "off" -Confirm:$false 
}