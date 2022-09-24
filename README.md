# ADLockedOutNotification

The PowerShell script ADduserlockedout.ps1 will detect and notify Active Directory users when they get locked-out either intentionally or unintentionally.  Locked-out Active Directory users will be notified by email using their Active Directory email address and a second email address (info Active Directory field, more on this below).   

How the PowerShell script works?

You must setup a ST to run the PowerShell script.  In my case, I setup one schedule task to run every minute and I place it in one of my domain controllers. The script will seek events across all domain controllers looking for "EventID 4740" in the Windows Security Event log.  The script will only continue if it finds locked-out accounts in Active Directory; otherwise it will terminate immediately.  

When the script finds an Active Directory locked-out account, it will send an email three times over a period of 3 minutes (1 email per minute).  The email sent to the user will provide some clues of the place(s) where the user got locked out.  It also creates a report.csv in the folder of your choice (Default: C:\Scripts\Locked-out-notification\report.csv) for Systems Administrators so they can find that information as well.  The email received by the user will contain information about the place(s) and time(s) of the locked-out event. 

Will it users get more than 3 emails? 

No, they won't.  The script will skip existing locked-out users, after they have been issues their 3 notifications, but will continue to run if it finds new locked-out users.  

Additional technical information

Mycred.xml file contains the encrypted credentials needed to authenticate the smtp server.  To create this file, you can find the link to the website in the "Documentation-and-resources.txt" section.  The email function sends an HTML formatted email and contains a table with the “Device name” and “Date and Time” of the locked-out event.  The email will be encrypted in transit by using the -UseSsl value.  The second email address is pulled from the Active Directory LDAP info value. This field contains an email in the form of name(at)domain.com.  

Throughout the script, I added sections to test certain actions if necessary.  These sections are commented and not required for the script. Also, these sections are only for trobleshooting purposes. 

Credits and references: 

This file "Documentation-and-resources.txt" includes several links to the work of others.  I borrowed some of their ideas to piece and build my own work. I hope you find this script useful.  I think is fair to also share this work so it can help someone else.  Feel free to modify this script to fit your own needs.  Finally, this my first time posting something in GitHub. 

Disclaimer:  

Please use this script at your own risk.  The script does not introduce any security vulnerabilities into your environment.  On the contrary, this script can helpo you detect suspicious actvity.  


