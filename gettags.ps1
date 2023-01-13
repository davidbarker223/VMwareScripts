Connect-VIServer #vCenter
Get-VM | Get-TagAssignment

where{$_.Tag -like 'Backups/Backup*'}

Select @{N='VM';E={$_.Entity.Name}}

Export-CSV C:\temp\tagged.csv -NoTypeInformation

Disconnect-VIServer #vCenter -Confirm:$False
