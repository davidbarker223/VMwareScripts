param($vcenters, $username, $password, $email)

$Date=(Get-Date -Format yyyy-MM-dd_HH-mm)

$ReportExport = "$env:WORKSPACE\VMware-Tools-Config-Update-Report"

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

Start-Transcript -path "$ReportExport\VMware-Tools-Config-Update-Report-$Date.txt" -append


foreach ($VCSServer in $VCSServers) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $VCSServer vCenter" -foregroundcolor Green

    connect-viserver $VCSServer -user $username -password $password -WarningAction SilentlyContinue

    Start-Sleep 5

    #Collect VM info
    write-host "Collecting Config Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    $TargetVMs = Get-VM | Where-Object {$_.ExtensionData.Config.GuestFullName -match "Microsoft Windows Server 201" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows Server 2008 R2" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 7" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 8" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 10"}
    write-host "Collection Complete on VMs in vCenter $VCSServer" -foregroundcolor Green

    #Configure VM Tools policy
    write-host "Configuring VMware Tools Update Policy on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    foreach ($VM in $TargetVMs) {
        $VMConfigCheck = Get-VM -name $VM | Sort-Object | Get-View 
        
        if ($VMConfigCheck.Config.Tools.ToolsUpgradePolicy -notmatch "UpgradeAtPowerCycle") {
            $VMConfig = Get-View -VIObject $VM.Name 
            $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec 
            $vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo 
            $vmConfigSpec.Tools.ToolsUpgradePolicy = "UpgradeAtPowerCycle" 
            $VMConfig.ReconfigVM($vmConfigSpec)

        }
    }

    write-host "VMware Tools Policy Update Complete on VMs in vCenter $VCSServer" -foregroundcolor Green
    
    write-host "Collecting Updated Config Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    #VM Tools Config Check
    Get-VM | Sort-Object | Get-View | Select-Object -Property Name, @{N='ToolsUpgradePolicy';E={$_.Config.Tools.ToolsUpgradePolicy}}, @{N="Configured OS";E={$_.Config.GuestFullName}},  @{N="Running OS";E={$_.Guest.GuestFullName}} | Format-Table -AutoSize

    Disconnect-viserver -Server $VCSServer -Force -Confirm:$false

    write-host '****************************************' -ForegroundColor Green
    write-host
}

Stop-Transcript

if ($null -ne $email){
    Send-MailMessage -To $email -From "" -Subject "VMware-Tools-Config-Update-Report-$Date" -Attachments "$ReportExport\VMware-Tools-Config-Update-Report-$Date.txt" -SmtpServer '' -Port 25 -WarningAction Ignore
}
