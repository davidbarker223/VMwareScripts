param($vcenters, $username, $password, $email)

$Date=(Get-Date -Format yyyy-MM-dd_HH-mm)

$ReportExport = "$env:WORKSPACE\VMware-Check-Host-Tools-Files-Report"

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

Start-Transcript -path "$ReportExport\VMware-Check-Host-Tools-Files-Report-$Date.txt" -append


foreach ($VCSServer in $VCSServers) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $VCSServer vCenter" -foregroundcolor Green

    connect-viserver $VCSServer -user $username -password $password -WarningAction SilentlyContinue

    Start-Sleep 5

    write-host "Checking VMHost Adv Config in vCenter $VCSServer...." -foregroundcolor Yellow
    $VMwareHosts = Get-VMHost
    $advSettings = foreach ($VMwareHost in $VMwareHosts) { 
        $VMwareHost
        Get-AdvancedSetting -Entity $VMwareHost -Name UserVars.ProductLockerLocation
    }

    $advSettings | Select-Object Name,Value | Format-Table -AutoSize
    write-host "Check VMHost Adv Config in vCenter $VCSServer is as expected, then continue" -foregroundcolor Cyan
}

Stop-Transcript

if ($null -ne $email){
    Send-MailMessage -To $email -From "" -Subject "VMware-Check-Host-Tools-Files-Report-$Date" -Attachments "$ReportExport\VMware-Check-Host-Tools-Files-Report-$Date.txt" -SmtpServer '' -Port 25 -WarningAction Ignore
}
