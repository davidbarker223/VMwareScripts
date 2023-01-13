#Change this to the vcenter you're connecting
connect-viserver #vCenter
#Change this to where you saved your CSV file to be imported
$FileList = "C:\Temp\import.csv"
$VMList=Import-CSV $FileList
ForEach($Line in $VMList)
 {
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Business Unit" -Value $Line."Business Unit"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Core Application" -Value $Line."Core Application"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Data Classification" -Value $Line."Data Classification"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Environment" -Value $Line.Environment
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "IT Owner" -Value $Line."IT Owner"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Intermapper Map" -Value $Line."Intermapper Map"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Patch Group" -Value $Line."Patch Group" 
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Product Owner" -Value $Line."Product Owner"
 Get-Vm $Line.VMName | Set-Annotation -CustomAttribute "Server Role" -Value $Line."Server Role"
 }
 #Changet this to the vcenter you set at the top
Disconnect-VIServer -Server #vCenter -Confirm:$False
