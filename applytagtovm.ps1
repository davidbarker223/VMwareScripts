#Change this to the vcenter you're connecting
connect-viserver #vCenter
#Change this to where you saved your CSV file to be imported
$FileList = "C:\Temp\vmtags.csv"
$VMList=Import-CSV $FileList
#Change these to the proper tags below
#Comment out $tag line if both are not needed
$tag = "Non-prod"
$tag2 = "App"
ForEach($Line in $VMList)
 {
 Get-Vm $Line.Name | New-TagAssignment -tag $tag -confirm:$false
 Get-Vm $Line.Name | New-TagAssignment -tag $tag2 -confirm:$false
 }
 #Change this to the vcenter you set at the top
Disconnect-VIServer -Server #vCenter -Confirm:$False
