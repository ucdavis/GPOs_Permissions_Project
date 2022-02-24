## GPOs Permissions Project

This project solution is based upon two scripts. 

One to report the current permission level granted to a specific AD group on each GPO assigned to OUs in a department OU.

The second script will take the GPO Ids from the report of the first script and assign edit and modify security rights to another AD group


### Required Setup

The PowerShell Active Directory Module must be installed on the system.

```powershell
# On Windows 10 systems
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

