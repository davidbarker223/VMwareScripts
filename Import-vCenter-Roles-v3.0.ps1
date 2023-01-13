#
# @author Philip Wenderby
# @email philip.wenderby@solera.com
# @create date 2021-10-27 12:49:34
# @modify date 2022-02-22 16:57:21
#

param($vcenters, $username, $password)

$vcenters = $vcenters.Split(',')

#Set-PowerCLIConfiguration -Scope AllUsers -InvalidCertificateAction Ignore -Confirm:$false
#Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCEIP $false -Confirm:$false

#Change version -like number to match installed version, must be higher than version 12
Get-Module -ListAvailable VMware* | Where-Object Version -like  12.* | Where-Object Script -eq VMware.VimAutomation.Core | Import-Module -ErrorAction SilentlyContinue


$VIRoleFilePath = "D:\jenkinshome\Scripts\roles"

$RoleFiles = Get-ChildItem -Path $VIRoleFilePath -Filter *.role


foreach ($vcenter in $vcenters) {
    write-host '****************************************' -ForegroundColor Cyan
    write-host
    write-host "Connecting to $vcenter vCenter" -foregroundcolor Green

    Connect-VIServer -Server $vcenter -user $username -password $password -WarningAction SilentlyContinue

    :Role foreach ($Role in $RoleFiles) {

        $VIRoleFullName = $Role.FullName
        $VIRoleName = $Role.BaseName
        [string[]]$VIRoleFileContent = Get-Content $VIRoleFullName -ErrorAction SilentlyContinue
            
        $VIRole = Get-VIRole -Name $VIRoleName -ErrorAction SilentlyContinue

            if ($VIRole.Name -notmatch $VIRoleName) {
                Write-Host "Role $VIRoleName Not Found in $($vcenter), progressing..." -ForegroundColor Yellow
                Write-Host "Importing Role $VIRoleName in $($vcenter)..." -ForegroundColor Green
                New-VIRole -Name $VIRoleName -Privilege (Get-VIPrivilege -Id $VIRoleFileContent -ErrorAction SilentlyContinue)
                Continue Role
                
            }
            if (Compare-Object $VIRole.PrivilegeList $VIRoleFileContent) {
                Write-Host "Role $($VIRole.Name) changed in $($vcenter), updating..." -ForegroundColor Green
                set-VIRole -Role $VIRoleName -RemovePrivilege *
                Start-Sleep 2
                set-VIRole -Role $VIRoleName -AddPrivilege (Get-VIPrivilege -Id $VIRoleFileContent -ErrorAction SilentlyContinue)
            }
            else {
                Write-Host "Role $($VIRole.Name) unchanged in $($vcenter), skipping..." -ForegroundColor Green
                Continue Role
            }

    }

    Start-Sleep 5

    Disconnect-viserver -Server $vcenter -Force -Confirm:$false

}