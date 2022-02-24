<#
	Script: GPOs_Report_Permissions.ps1
	Author: Taylor McDougall and Dean Bunn
	Last Edited: 2022-02-23
#>

#Import Group Policy Module 
Import-Module GroupPolicy;

#Var for SAM of Currently Assigned Admin Group
[string]$adminGroupSAM = "COE-US-Admins";

#Var for Department OU Search Path
[string]$dptOUSearchPath = "ou=coe,ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu"

#Var for Domain Server
[string]$dmnServer = "ou.ad3.ucdavis.edu";

#Var for Domain FQDN
[string]$dmnFDQN = "ou.ad3.ucdavis.edu";

#Var for Admin Group to Check Permissions. User of Script Should be in this group
[string]$adminGroupDN = (Get-ADGroup -Identity $adminGroupSAM -Server $dmnServer).DistinguishedName;

#Reporting Array for GPOs
$raGPOs = @();

#Reporting Array for Department OUs
$raDOUs = @();

#HashTable for Unique GPO IDs
$htGPOIDs = @{};

#Pull Department OUs
$dptOUs = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $dptOUSearchPath -server $dmnServer;
 
#Check Each OUs for GPOs Assigned
foreach($dptOU in $dptOUs)
{
  
    #Create Custom Department OU Object
	$cstDOU = new-object PSObject -Property (@{ Name=""; DistinguishedName=""; ObjectGUID=""; LinkedGPOsCount=0; });

    #Set Values for Custom OU Object
    $cstDOU.Name = $dptOU.Name;
    $cstDOU.DistinguishedName = $dptOU.DistinguishedName;
    $cstDOU.ObjectGUID = $dptOU.ObjectGUID.ToString();
    $cstDOU.LinkedGPOsCount = $dptOU.LinkedGroupPolicyObjects.Count;

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

    #Add Custom Object to Reporting Array
    $raDOUs += $cstDOU;

}#End of $dptOUs Foreach

#Export OU Information
$raDOUs | Select-Object -Property ObjectGUID,Name,LinkedGPOsCount,DistinguishedName | Export-Csv -Path .\Report-Dept-OUs.csv -NoTypeInformation;

#Empty Check on Assigned GPOs
if($htGPOIDs.Count -gt 0)
{

    foreach($gpID in $htGPOIDs.Keys)
    {

        #Create Custom GPO Reporting Object
	    $cstGPO = new-object PSObject -Property (@{ DisplayName=""; Id=""; Owner=""; CreationTime=""; ModificationTime=""; PermissionLevel="None"; });

        #Convert String to Guid
        $guidGPOID = [Guid]$gpID;

        #Pull GPO
        $gpo = Get-GPO -Guid $guidGPOID -Server $dmnServer -Domain $dmnFDQN;

        #Set Values on Custom Object
        $cstGPO.DisplayName = $gpo.DisplayName;
        $cstGPO.Id = $gpo.Id.ToString();

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

        #Pull Permissions on GPO
        $gpoPerms = Get-GPPermission -Guid $guidGPOID -Server $dmnServer -All;

        #Check Permissions for Admin Group Access
        foreach($gpperm in $gpoPerms)
        {
            #Find Access for Admin Group
            if([string]::IsNullOrEmpty($gpperm.Trustee.DSPath) -eq $false -and [string]::Compare($gpperm.Trustee.DSPath,$adminGroupDN,$true) -eq 0)
            {
                #Report Permission Level for Admin Group
                $cstGPO.PermissionLevel = $gpperm.Permission.ToString();

            }#End of Compare Trustee DSPath

        }#End of $gpoPerms Foreach
        
        #Add Custom Object to Reporting Array
        $raGPOs += $cstGPO;

    }#End of $htGPOIDs Foreach


}#End of $htGPOIDs Count Check

#Export OU Information
$raGPOs | Select-Object -Property Id,DisplayName,Owner,CreationTime,ModificationTime,PermissionLevel | Export-Csv -Path .\Report-GPOs.csv -NoTypeInformation;


