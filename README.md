## GPOs Permissions Project

This project solution is based upon two scripts. 

One to report the current permission level granted to a specific AD group on each GPO assigned to OUs in a department OU.

The second script will add permissions for the new admin group by taking the GPO Ids from the report of the first script and configuring the required settings.

Additionally, we had to fix permissions granted to individual admins. Those scripts are located in a sub directory.

### Requirements

The PowerShell Active Directory and Group Policy Modules must be installed on the system.




