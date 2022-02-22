<#
	Script: GPOs_Permissions_Report.ps1
	Author: Dean Bunn
	Last Edited: 2022-02-22
#>

#Import Group Policy Module 
#Import-Module GroupPolicy;

#OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu

#Get-ADOrganizationalUnit

 Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'ou=coe,ou=departments,dc=ou,dc=ad3,dc=ucdavis,dc=edu' -server ou.ad3.ucdavis.edu


<#
#Var for DN of Parent OU to Check
[string]$parentOUDN = "OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu";

#Var for DN of Admin Group to Check for
[string]$adminGroupDN = "CN=COE-US-Admins,OU=COE,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu";

#Var for ADsPath of Parent OU
[string]$parentOUADsPath = "LDAP://" + $parentOUDN;

#Var for ADsPath of Admin Group
[string]$admnGrpADsPath = "LDAP://" + $adminGroupDN;

#Var for Display Name of Admin Group
[string]$admnGrpName = "";

#Array for OU DNs
$arrOUDNs = @();

#Array List for GPO Guids
$alGPOGuids = New-Object System.Collections.ArrayList;

#Array List for GPO Guids Needing Perms
$alGPOGuidsNP = New-Object System.Collections.ArrayList;

#Array List for OU Locations with GPOs that We Don't Have Permissions to Even Read
$alOULocsNoRead = New-Object System.Collections.ArrayList;

#Array List for GPO Guids We Can Ignore
$alGPOGuidsIgnore = New-Object System.Collections.ArrayList;

#Array for Custom GPO Objects
$arrCstGPOs = @();

#Load Ignore List
[Void]$alGPOGuidsIgnore.add("b5788b69-2dac-4170-a060-959bfd60a431");
[Void]$alGPOGuidsIgnore.add("b6a0cca3-93fa-4967-bc18-f838557c2986");
[Void]$alGPOGuidsIgnore.add("454e61c1-6695-43f2-b281-367b2db2c714");
[Void]$alGPOGuidsIgnore.add("48d25dc2-9ca6-4536-ac23-0dcccdeea431");
[Void]$alGPOGuidsIgnore.add("558089e5-3ac7-4e26-8302-2ed6b6d7a585");
[Void]$alGPOGuidsIgnore.add("909c731d-0911-4040-8c6c-b92c3ccea46e");
[Void]$alGPOGuidsIgnore.Add("d6da4e75-0dc1-4f70-8ffa-beab1b925a18");


#Pull Directory Entry for Main OU
$deParentOU = [ADSI]$parentOUADsPath;

#Pull Directory Entry for Admin Group
$deAdminGroup = [ADSI]$admnGrpADsPath;
#>

