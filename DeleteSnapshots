Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-3)} | Select-Object VM,Name,Created

Get-VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-3)} | Remove-Snapshot -Confirm:$false
