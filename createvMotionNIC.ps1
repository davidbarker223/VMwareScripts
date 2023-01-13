$vmhost = Get-VMHost -Name #hostFQDN
New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup vmotion1 -VirtualSwitch vSwitch0 -IP #IP1 -SubnetMask -VMotionEnabled 1
New-VMHostNetworkAdapter -VMHost $vmhost -PortGroup vmotion2 -VirtualSwitch vSwitch0 -IP #IP2 -SubnetMask -VMotionEnabled 1
