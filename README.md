# ADLockedOutNotification

This PowerShell script will detect and notify Active Directory users when they get locked-out.  Locked-out Active Directory users will be notified by email using their Active Directory email address and a second email address (info Active Directory field, more on this below).   

How the PowerShell script works?

You must setup a schedule task to run the PowerShell script.  In my case, I setup one schedule task to run every minute and I placed it in one of my domain controllers. The script will seek events across all domain controllers looking for "EventID 4740" in the Windows Security Event log.  The script will only continue if it finds locked-out accounts in Active Directory, otherwise it will terminate immediately.  

When the script finds an Active Directory locked-out account, it will send an email three times over a period of 3 minutes (1 email per minute).  The email sent to the user will give provide some clues of the place(s) where they got locked out.  It also creates a report.csv on the folder of your choice (Default: C:\Scripts\Locked-out-notification\report.csv) for Systems Administrators so they can also find that information as well.  The email received by the user will contain information of the place(s) and time(s) of the locked-out event. 

Will it users get more than 3 emails? 

No, they won't.  The script will skip existing locked-out users but will continue to run if it finds new locked-out users.  If the user account remains locked and another user is found after (or within) the 3 minutes, only the new user(s) will get these emails.  

Additional technical information

Mycred.xml file contains the encrypted credentials needed to authenticate to the smtp server.  The email function sends an HTML formatted email because it contains a table with the “Device name” and “Date and Time” of the locked-out event.  The email will be encrypted in transit by using the -UseSsl value.  The second email address is pulled from the Active Directory LDAP info value. This field contains an email in the form of name@domain.com.

Credits and references: 

This file "Documentation-and-resources.txt" includes several links to the work of others.  I borrowed some of their ideas to piece and build my own work, I hope you find it useful.  I think is fare to also share this work so it can help someone else.  Feel free to modify this script for to fit your own needs.

Disclaimer:  

Please use this script at your own risk.  The script does not introduce any security vulnerabilities in your environment.  On the contrary, if your user didn’t locked out themselves chances are that some suspicious activity has occurred.  


