param($vcenters, $username, $password, $email, $vmx_version, $file)

$Date=(Get-Date -Format yyyy-MM-dd_HH-mm)

$ReportExport = "$env:WORKSPACE\VMware-Update-VM-HW-Report"

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

$TargetVMList = $file
$TargetVMImport = Import-Csv $TargetVMList

Start-Transcript -path "$ReportExport\VMware-Update-VM-HW-Report-$Date.txt" -append


foreach ($VCSServer in $VCSServers) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $VCSServer vCenter" -foregroundcolor Green

    connect-viserver $VCSServer -user $username -password $password -WarningAction SilentlyContinue

    Start-Sleep 5
        
        #Collect VM info
        $TargetVMs_VC = $TargetVMImport | Where-Object {$_.vc -match "$VCSServer"}
        write-host "Collecting Config Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
        $TargetVMs = foreach($TargetVM in $TargetVMs_VC) {
            $TargetVM = $TargetVM.Name
            Get-VM -Name $TargetVM | Where-Object {$_.ExtensionData.Config.GuestFullName -match "Microsoft Windows Server 201" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows Server 2008 R2" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 7" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 8" -or $_.ExtensionData.Config.GuestFullName -match "Microsoft Windows 10"}
        }
        write-host "Collection Complete on VMs in vCenter $VCSServer" -foregroundcolor Green

        #Configure VM Tools policy
        write-host "Configuring VMware HW Update Policy and reboot VMs in vCenter $VCSServer...." -foregroundcolor Yellow
        foreach ($VM in $TargetVMs) {
            $VMConfigCheck = Get-VM -name $VM | Sort-Object | Get-View 

            #get vmx version for comparison in integer
            $vmx_check = 0
            $vmx_target = 0
            if ($vmx_check.getType().name -eq "Int32") {Remove-Variable vmx_check}
            if ($vmx_target.getType().name -eq "Int32") {Remove-Variable vmx_target}
            $vmx_check = $VMConfigCheck.Config.Version
            $vmx_check = $vmx_check.Remove(0,4)
            $vmx_target = $vmx_version

            [int]$vmx_check = $vmx_check
            [int]$vmx_target = $vmx_target
            
            #apply the upgrade settings
            if ($vmx_check -lt $vmx_target) {
                $VMConfig = Get-View -VIObject $VM.Name 
                $vmConfigSpec = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
                $vmConfigSpec.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
                $vmConfigSpec.ScheduledHardwareUpgradeInfo.UpgradePolicy = "always"
                $vmConfigSpec.ScheduledHardwareUpgradeInfo.VersionKey = "vmx-$vmx_version"
                $VMConfig.ReconfigVM($vmConfigSpec)
                Start-Sleep 2
                $vmGuestState = Get-VM $VM
                if ($vmGuestState.PowerState -eq 'PoweredOn'){
                    $vmGuestState | Where-Object {$_.Guest.State -eq "Running"} | Restart-VMGuest -Confirm:$false
                    $vmGuestState | Where-Object {$_.Guest.State -eq "NotRunning"} | Restart-VM -Confirm:$false
                }
                

            }
        }

        write-host "VMware HW Update Policy and reboot Update Complete on VMs in vCenter $VCSServer" -foregroundcolor Green
    
        write-host "Collecting Updated Config Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
        #VM Tools Config Check
        Start-Sleep 10
        $CheckTargetVMs = foreach($CheckTargetVM in $TargetVMs_VC) {
            $CheckTargetVM = $CheckTargetVM.Name
            Get-VM -Name $CheckTargetVM
        }
        $CheckTargetVMs | Sort-Object | Get-View | Select-Object -Property Name, @{N='PowerState';E={$_.Runtime.PowerState}}, @{N='Version';E={$_.Config.Version}}, @{N="Configured OS";E={$_.Config.GuestFullName}},  @{N="Running OS";E={$_.Guest.GuestFullName}} | Format-Table -AutoSize
    



    Disconnect-viserver -Server $VCSServer -Force -Confirm:$false

    write-host '****************************************' -ForegroundColor Green
    write-host
}

Stop-Transcript

if ($null -ne $email){
    Send-MailMessage -To $email -From "" -Subject "VMware-Update-VM-HW-Report-$Date" -Attachments "$ReportExport\VMware-Update-VM-HW-Report-$Date.txt" -SmtpServer '' -Port 25 -WarningAction Ignore
}
