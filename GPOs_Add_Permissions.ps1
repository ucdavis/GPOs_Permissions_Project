<#
	Script: GPOs_Add_Permissions.ps1
	Author: Taylor McDougall and Dean Bunn
	Last Edited: 2022-02-23
#>

#Import Group Policy Module 
#Import-Module GroupPolicy;

#Check for GPO Report File
$csvGPOs = Import-Csv -Path .\Report-GPOs.csv;

foreach($csvGPO in $csvGPOs)
{

    #Only Grant Rights to GPOs the Old Group had Full Rights On
    if([string]::IsNullOrEmpty($csvGPO.PermissionLevel) -eq $false -and $csvGPO.PermissionLevel -eq "GpoEditDeleteModifySecurity")
    {
        #Setup for Testing
        if($csvGPO.Id -eq "5885a54e-26f5-424a-9130-ce4c9140ce65")
        {
            $csvGPO.DisplayName;
        }
          
    }#End of Permission Level Check for Old Group
    
}#End of $csvGPOs Foreach