## GPOs Permissions Project

These two scripts will help my unit with checking the COE department OU and then assigning permissions for the new AD3 GPO group. 


### Required Setup

The PowerShell Active Directory Module must be installed on the system.

```powershell
# On Windows 10 systems
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

