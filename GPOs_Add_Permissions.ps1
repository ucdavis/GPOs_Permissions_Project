<#
	Script: GPOs_Add_Permissions.ps1
	Author: Taylor McDougall and Dean Bunn
	Last Edited: 2022-02-24
#>

#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for Domain and Name of Admin Group to Grant Permissions
[string]$grantedAdminGroup = "AD3\COE-Admins";

#Var for Domain Server
[string]$dmnServer = "ou.ad3.ucdavis.edu";

#Check for GPO Report File
$csvGPOs = Import-Csv -Path .\Report-GPOs.csv;

foreach($csvGPO in $csvGPOs)
{

    #Only Grant Rights to GPOs the Old Group had Full Rights On
    if([string]::IsNullOrEmpty($csvGPO.Id) -eq $false -and [string]::IsNullOrEmpty($csvGPO.PermissionLevel) -eq $false -and $csvGPO.PermissionLevel -eq "GpoEditDeleteModifySecurity")
    {
        
        #Convert String to Guid
        $guidGPOID = [Guid]$csvGPO.Id;

        #Add Full Permissions to GPO for Admin Group
        Set-GPPermission -Guid $guidGPOID -TargetName $grantedAdminGroup -TargetType Group -Server $dmnServer -PermissionLevel GpoEditDeleteModifySecurity;

    }#End of Permission Level Check for Old Group
    
}#End of $csvGPOs Foreach

