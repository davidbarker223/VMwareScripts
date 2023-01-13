#Change this to the vcenter you're connecting
connect-viserver #vCenter

$Report = @()

Get-VM | foreach{

$Summary = "" | Select VMName

$Summary.VMName = $_.Name

$_ | Get-Annotation | foreach{

Add-Member -InputObject $Summary -MemberType NoteProperty -Name $_.Name -Value $_.Value

}

$Report += $Summary

}

#Change the Path to where you want the csv file saved
$Report | Export-Csv -Path C:\Temp\attributeexport.csv -NoTypeInformation

#Change this to the vcenter set at the top
Disconnect-VIServer -Server #vCenter -Confirm:$False
