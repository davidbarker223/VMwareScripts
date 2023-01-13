Connect-VIServer #vCenter
New-TagCategory -Name Exception -Description "Exception to vROPs Reports" -Cardinality Single -EntityType VM
New-Tag -Name Snapshot -Category Exception -Description "Snapshot Report Exception"
New-Tag -Name Idle -Category Exception -Description "Idle VM Report Exception"
New-Tag -Name PoweredOff -Category Exception -Description "Powered Off Report Exception"
Disconnect-VIServer #vCenter -Confirm:$False
