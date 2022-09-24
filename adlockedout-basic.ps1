
### Can't find where I found this code. But this was the original idea. 

$Usr = Read-Host -Prompt "Please enter a user name"

# $Usr = ‘username1’

$Pdc = (Get-AdDomain).PDCEmulator

$ParamsEvn = @{

‘Computername’ = $Pdc

‘LogName’ = ‘Security’

‘FilterXPath’ = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$Usr']]"

}

$Evnts = Get-WinEvent @ParamsEvn

$Evnts | foreach {$_.Properties[1].value + ' ' + $_.TimeCreated}

