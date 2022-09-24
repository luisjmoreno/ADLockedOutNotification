#
# This is v4.3 of the script. This script will email users automatically when they are locked out from AD. 
# The script will provide some clues for places where they got locked out. The script will send 3 email notifications to two email addresses. 
# 
#
Import-Module -Name ActiveDirectory
$Global:dte = Get-Date 
$Global:val30
$creds = Import-CliXml -Path "C:\Scripts\Locked-out-notification\mycred.xml"
#
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#
#
# Search for users that have the AD Lock out status in the domain. 
#
$ADUserLock =
search-adaccount -searchbase 'ou=, ou=, dc=, dc=, dc=' -LockedOut |
where-object {$_.Enabled -eq $True}
#
$ADUserLock | export-csv "C:\Scripts\Locked-out-notification\report.csv" -NoTypeInformation
#

if($ADUserLock -eq $null) 
    {
    echo "Nothing to report, stop now."
    exit
    }


function skipadusr 
{
# Testing lines - uncommenet if diagnosing script.
# echo ""
# echo "Stop or Continue tests"
#
# echo "Current time:"
# echo $Global:dte
# echo "User's locked out time:"
# echo $Global:val30

$condition1 = $Global:val30.AddMinutes(3)

# echo "Condition:"
# echo $condition1
#
if($Global:dte -gt $condition1) 
    {
    echo "Will skip user"
    continue;
    }
else {
    echo " will continue"
     }
}

foreach($user in $ADUserLock){

    $Usr = $user.samaccountname


### Begin of DC tests to determine places where user has incorrect information
#

$Pdc = (Get-AdDomain).PDCEmulator

$ParamsEvn = @{
‘Computername’ = $Pdc
‘LogName’ = ‘Security’
‘FilterXPath’ = "*[System[EventID=4740] and EventData[Data[@Name='TargetUserName']='$Usr']]"
}
#
$Evnts = Get-WinEvent @ParamsEvn
# $Evnts2 = $Evnts | foreach {$_.Properties[1].value + ' ' + $_.TimeCreated}
$Evnts2 = $Evnts | foreach {$_.Properties[1].value + ' '}
$Evnts3 = $Evnts | foreach {$_.TimeCreated}

# Get the 4 most recent lockout events

$val20 = $Evnts2.Item(0)
$Global:val30 = $Evnts3.Item(0)
$val21 = $Evnts2.Item(1)
$val31 = $Evnts3.Item(1)
$val22 = $Evnts2.Item(2)
$val32 = $Evnts3.Item(2)
$val23 = $Evnts2.Item(3)
$val33 = $Evnts3.Item(3)

skipadusr;


## End of DC tests
#
## Send email notification to user's <domain> email and secondary email. 
#

$AccountInfo = Get-aduser $user.samaccountname -properties name,emailaddress,info

$message =
@"
Hello $($AccountInfo.name),<br><br>
This is an automated message. Your <> (AD) account is currently locked out.  If this wasn't caused by you, please report this activity immediately to DoIT Help Desk.<br><br>
To unlock your AD account, go to <link> self-service system.  <b>Please note:</b> this message will repeat automatically 3 times.  You won't be able to use any <> systems until you take some action.  If you changed your password  recently, please update your credentials across all your devices. <br><br>
If you require further assistance, please contact <> Help Desk by email <> or by phone at <> .<br><br><br>

Lock out locations are listed below.<br> 
<table>
  <tr>
    <th>Device name</th>
    <th>Date and Time</th>
   </tr>
  <tr>
    <td>$val20</td>
    <td>$Global:val30</td>
  </tr>
  <tr>
    <td>$val21</td>
    <td>$val31</td>
  </tr>
  <tr>
    <td>$val22</td>
    <td>$val32</td>
  </tr>
  <tr>
    <td>$val23</td>
    <td>$val33</td>
  </tr>
</table>

<br><br>
DoIT<br>
My school<br>
Address<br>
New York, NY, 10023<br>
"@

    $mailpr = @{
        from       = "noreply@something.edu"
        to         = $AccountInfo.EmailAddress
        cc         = $AccountInfo.info
        subject    = "Your My Scohol Active Directory account is locked out. "
        body       = $message 
        bodyashtml = $true
        smtpserver = 'smtp.something.edu'
        port       = 25
    }

    Send-MailMessage @mailpr -Credential $creds -UseSsl

}

exit