#
# @author Philip Wenderby
# @email philip.wenderby@solera.com
# @create date 2021-10-27 12:49:34
# @modify date 2022-11-22 16:00:42
#

param($vcenters, $username, $password, $email)

$Date=(Get-Date -Format yyyy-MM-dd_HH-mm)

$ReportExport = "$env:WORKSPACE\VMware-Tools-Mount-Report"

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

Start-Transcript -path "$ReportExport\VMware-Tools-Mount-Report-$Date.txt" -append


foreach ($VCSServer in $VCSServers) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $VCSServer vCenter" -foregroundcolor Green

    connect-viserver $VCSServer -user $username -password $password -WarningAction SilentlyContinue

    Start-Sleep 5

    Write-Host "Checking for VMware Tools Mounts on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    Get-VM -Server $VCSServer | Get-CDDrive | Where-Object{$_.IsoPath -match "vmware/isoimages"} | Select-Object Parent,IsoPath,ParentId | Format-Table -AutoSize

    
    Disconnect-viserver -Server $VCSServer -Force -Confirm:$false
}

Stop-Transcript
if ($null -ne $email){
    Send-MailMessage -To $email -From "No-Reply-Jenkins@solera.com" -Subject "VMware-Tools-Mount-Report-$Date" -Attachments "$ReportExport\VMware-Tools-Mount-Report-$Date.txt" -SmtpServer 'mail.axadmin.net' -Port 25 -WarningAction Ignore
}
