<#
	Script: GPOs_Add_Individual_Admin_Permissions.ps1
	Author: Taylor McDougall and Dean Bunn
	Last Edited: 2022-03-01
#>

#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for GPO Domain FQDN
[string]$dmnGPOFDQN = "ou.ad3.ucdavis.edu";

#Check for GPO Report File
$csvGPOs = Import-Csv -Path .\Add_Perms.csv;

foreach($csvGPO in $csvGPOs)
{

    #Null\Empty Checks on GPO ID and AD3 Admin or Group
    if([string]::IsNullOrEmpty($csvGPO.GPO_ID) -eq $false -and [string]::IsNullOrEmpty($csvGPO.AD3_Admin) -eq $false)
    {
        
        #Convert String to Guid
        $guidGPOID = [Guid]$csvGPO.GPO_ID;

        #Var for Domain and Name of Admin Object to Grant Permissions
        [string]$grantedAdminObj = $csvGPO.AD3_Admin;

        #Var for Admin Type (Group or User)
        [string]$grantedAdminType = $csvGPO.Admin_Type;

        #Add Full Permissions to GPO for Admin Group
        Set-GPPermission -Guid $guidGPOID -TargetName $grantedAdminObj -TargetType $grantedAdminType -Server $dmnGPOFDQN -DomainName $dmnGPOFDQN -PermissionLevel GpoEditDeleteModifySecurity;

    }#End of Null\Empty Checks on GPO ID and AD3 Object
    
}#End of $csvGPOs Foreach

