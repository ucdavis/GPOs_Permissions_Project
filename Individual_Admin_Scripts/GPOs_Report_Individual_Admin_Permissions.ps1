<#
	Script: GPOs_Report_Individual_Admin_Permissions.ps1
	Author: Taylor McDougall and Dean Bunn
	Last Edited: 2022-02-28
#>

#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for Department OU Search Path  
[string]$dptOUSearchPath = "ou=coe,ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu";

#Var for Admin Group Domain FQDN
[string]$dmnAdminGrpFQDN = "ou.ad3.ucdavis.edu";

#Var for GPOs Domain FQDN
[string]$dmnGPOFDQN = "ou.ad3.ucdavis.edu";

#Reporting Array for GPOs
$raGPOs = @();

#HashTable for Unique GPO IDs
$htGPOIDs = @{};

#Pull Department OUs
$dptOUs = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $dptOUSearchPath -server $dmnGPOFDQN;
 
#Check Each OUs for GPOs Assigned
foreach($dptOU in $dptOUs)
{
  
    #Pull Unique GPO IDs
    if($dptOU.LinkedGroupPolicyObjects.Count -gt 0)
    {

        foreach($lnkGPO in $dptOU.LinkedGroupPolicyObjects)
        {
            #Remove Unneeded GPO Resource Data to Get Only the GPO GUID ID
            $gpoID = $lnkGPO.ToString().Split(',')[0].ToString().Replace("cn={","").Replace("}","");
            
            #Check for Unique GPO ID
            if([string]::IsNullOrEmpty($gpoID) -eq $false -and $htGPOIDs.ContainsKey($gpoID) -eq $false)
            {
                $htGPOIDs.Add($gpoID,"1");
            }

        }#End of Linked Group Policy Objects Foreach

    }#End of Linked Group Policy Objects Count Check

}#End of $dptOUs Foreach


#Empty Check on Assigned GPOs
if($htGPOIDs.Count -gt 0)
{

    foreach($gpID in $htGPOIDs.Keys)
    {

        #Convert String to Guid
        $guidGPOID = [Guid]$gpID;

        #Pull GPO
        $gpo = Get-GPO -Guid $guidGPOID -Server $dmnGPOFDQN -Domain $dmnGPOFDQN;

        #Pull Permissions on GPO
        $gpoPerms = Get-GPPermission -Guid $guidGPOID -Server $dmnGPOFDQN -DomainName $dmnGPOFDQN -All;

        #Check Permissions for Admin Group Access
        foreach($gpperm in $gpoPerms)
        {

            #Find Access for Admin Group
            if([string]::IsNullOrEmpty($gpperm.Trustee.DSPath) -eq $false)
            {

                #Var for TrusteePath 
                [string]$trusteePath = $gpperm.Trustee.DSPath.ToString().ToLower();
                
                #Check for Permissions Granted to Managed Group or OU Dept Object or AD3 Mothra Tracked User
                if($trusteePath.Contains("ou=usercreatedgroups,ou=managedgroups,dc=ad3,dc=ucdavis,dc=edu") -eq $true `
                  -or $trusteePath.Contains("ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu") -eq $true `
                  -or $trusteePath.Contains("ou=ucdusers,dc=ad3,dc=ucdavis,dc=edu") -eq $true `
                  -and ($gpperm.Permission.ToString() -ne "GpoApply" -and $gpperm.Permission.ToString() -ne "GpoRead"))
                {

                    #Create Custom GPO Reporting Object
	                $cstGPO = new-object PSObject -Property (@{ DisplayName=""; Id=""; Owner=""; CreationTime=""; ModificationTime=""; AdminAccount=""; PermissionLevel=""; });

                    #Set Values on Custom Object
                    $cstGPO.DisplayName = $gpo.DisplayName;
                    $cstGPO.Id = $gpo.Id.ToString();
                    $cstGPO.PermissionLevel = $gpperm.Permission.ToString();
                    $cstGPO.AdminAccount = $gpperm.Trustee.Domain.ToString().ToLower() + "\" + $gpperm.Trustee.Name.ToString().ToLower();

                    #Check Creation Time
                    if($gpo.CreationTime -ne $null)
                    {
                        $cstGPO.CreationTime = $gpo.CreationTime.ToString("MM/dd/yyyy");
                    }

                    #Check Modification Time
                    if($gpo.ModificationTime -ne $null)
                    {
                        $cstGPO.ModificationTime = $gpo.ModificationTime.ToString("MM/dd/yyyy");
                    }

                    #Check Ownership
                    if([string]::IsNullOrEmpty($gpo.Owner) -eq $false)
                    {
                        $cstGPO.Owner = $gpo.Owner;
                    }

                    #Add Custom Object to Reporting Array
                    $raGPOs += $cstGPO;

                }#End of Permissions Granted Checks

            }#End of Compare Trustee DSPath

        }#End of $gpoPerms Foreach

    }#End of $htGPOIDs Foreach

}#End of $htGPOIDs Count Check

#Export GPO Information
$raGPOs | Select-Object -Property AdminAccount,PermissionLevel,Id,DisplayName,Owner,CreationTime,ModificationTime | Export-Csv -Path .\Report-GPOs-Individual-Admins.csv -NoTypeInformation;

