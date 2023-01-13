param($vcenters, $username, $password, $file, $VM_NIC_Connect_at_Power_On, $VM_NIC_Connected)

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue

$VCSServers = $vcenters
$VCSServers = $VCSServers.Split(',')

$TargetVMList = $file
$TargetVMs = Import-Csv $TargetVMList


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


    $TargetVMs_VC = $TargetVMs | Where-Object {$_.vc -match "$VCSServer"}

    :TargetVM foreach($TargetVM in $TargetVMs_VC) {

        $TargetVM = $TargetVM.Name 

        $TargetVM_Check = $null
        $TargetVM_Check = Get-VM -Name $TargetVM -ErrorAction SilentlyContinue 
        $TargetVM_CheckName = $TargetVM_Check.Name
        $TargetVM_CheckPowerState = $TargetVM_Check.PowerState

        
        if ($TargetVM -eq $TargetVM_CheckName) {
            if ($VM_NIC_Connect_at_Power_On -eq $true) {
                Write-Host "Setting $TargetVM Connect at Power On True"
                Get-VM -Name $TargetVM | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$true -Confirm:$false | Out-Null
            }
            if ($VM_NIC_Connect_at_Power_On -eq $false) {
                Write-Host "Setting $TargetVM Connect at Power On False"
                Get-VM -Name $TargetVM | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false | Out-Null
            }
            if ($TargetVM_CheckPowerState -eq 'PoweredOn') {
                Start-Sleep 1
                if ($VM_NIC_Connected -eq $true) {
                    Write-Host "Setting $TargetVM Connected True"
                    Get-VM -Name $TargetVM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -Confirm:$false | Out-Null
                }
                if ($VM_NIC_Connected -eq $false) {
                    Write-Host "Setting $TargetVM Connected False"
                    Get-VM -Name $TargetVM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -Confirm:$false | Out-Null
                }
            }
            Write-Host
        }
        else {
            Write-Host "VM $TargetVM Not Found in vCenter Skipping..." -ForegroundColor Red
            Continue TargetVM
        }
        

    }

    Start-Sleep 2

    write-host "Collecting Updated Config Info on VMs in vCenter $VCSServer...." -foregroundcolor Yellow
    $TargetVMCheck = foreach($TargetVM in $TargetVMs_VC) {

        $TargetVM = $TargetVM.Name 

        $TargetVM_Check = $null
        $TargetVM_Check = Get-VM -Name $TargetVM -ErrorAction SilentlyContinue 
        $TargetVM_Check = $TargetVM_Check.Name

        
        if ($TargetVM -eq $TargetVM_Check) {
        Get-VM -Name $TargetVM | Get-NetworkAdapter | Select-Object Parent,ConnectionState
        }

    }

    write-host "Updated Collection Complete on VMs in vCenter $VCSServer" -foregroundcolor Green
    Write-Output $TargetVMCheck | Format-Table

    Disconnect-viserver -Server $VCSServer -Force -Confirm:$false

    write-host '****************************************' -ForegroundColor Green
    write-host
}

