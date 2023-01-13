param($vcenters, $username, $password, $file, $email)

$Date=(Get-Date -Format yyyy-MM-dd_HH-mm)

$ReportExport = "$env:WORKSPACE\VMware-VM-Power-Status-Check-Report"

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

$TargetVMList = $file
$TargetVMs = Import-Csv $TargetVMList

Start-Transcript -path "$ReportExport\VMware-VM-Power-Status-Check-Report-$Date.txt" -append


foreach ($VCSServer in $VCSServers) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $VCSServer vCenter" -foregroundcolor Green

    connect-viserver $VCSServer -user $username -password $password -WarningAction SilentlyContinue

    Start-Sleep 2

    $TargetVMs_VC = $TargetVMs | Where-Object {$_.vc -match "$VCSServer"}

    write-host "Collecting Power State Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    $PreTargetVMCheck = foreach($TargetVM in $TargetVMs_VC) {

        $TargetVM = $TargetVM.Name

        $TargetVM_Check = $null
        $TargetVM_Check = Get-VM -Name $TargetVM -ErrorAction SilentlyContinue 
        $TargetVM_Check = $TargetVM_Check.Name

        
        if ($TargetVM -eq $TargetVM_Check) {
        Get-VM -Name $TargetVM | Select-Object Name,PowerState
        }

    }

    write-host "Power State Collection Complete on VMs in vCenter $VCSServer" -foregroundcolor Green
    Write-Output $PreTargetVMCheck | Sort-Object PowerState -Descending | Format-Table

    Start-Sleep 2

    Disconnect-viserver -Server $VCSServer -Force -Confirm:$false

    write-host '****************************************' -ForegroundColor Green
    write-host
}

Stop-Transcript

if ($null -ne $email){
    Send-MailMessage -To $email -From "No-Reply-Jenkins@solera.com" -Subject "VMware-VM-Power-Status-Check-Report-$Date" -Attachments "$ReportExport\VMware-VM-Power-Status-Check-Report-$Date.txt" -SmtpServer '' -Port 25 -WarningAction Ignore
}
