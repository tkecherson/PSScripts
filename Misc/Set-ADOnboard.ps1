<# 
.SYNOPSIS
    Creates a basic OU structure for a new client.

.DESCRIPTION
    This script will create a root OU for a company, one or more site OUs underneath that, and various recommended OUs within those. Optionally, it creates a domain Frit Admin account.

.PARAMETER CompanyName
    A required parameter, this specifies the name of the root Company OU. The parameter name does not need to be specified.

.PARAMETER SiteCount
    A required parameter, this specifies the number of sites in the company to create sub-OUs. Default is 1. The parameter name does not need to be specified.

.PARAMETER FritPass
    An optional parameter, if set this will create a user "Frit" in the domain, copied from the domain "Administrator" user.

.EXAMPLE
    PS> .\Set-ADOnboard.ps1 -CompanyName Fabrikam
    Creates an OU "Fabrikam" in the root of the domain, then prompts for a site name and creates OUs:
    Fabrikam
    >Main Site
    >>Active Employees
    >>>Account Only
    >>Contacts
    >>Distro Groups
    >>Security Groups
    >>External Users
    >>Workstations
    >>Servers
    >>Disabled
    >>Service Accounts

.EXAMPLE
    PS> .\Set-ADOnboard.ps1 -CompanyName Fabrikam -SiteCount 3
    Creates an OU "Fabrikam" with multiple sites, all configured as above.

.EXAMPLE
    PS> .\Set-ADOnboard.ps1 Fabrikam 3
    Creates an OU "Fabrikam" with multiple sites, all configured as above.

.EXAMPLE
    PS> .\Set-ADOnboard.ps1 Fabrikam 3 -FritPass SamplePassword
    Creates an OU "Fabrikam" with multiple sites, all configured as above, and creates a domain Frit account with a password of "SamplePassword".

.NOTES
    Must be run from a domain controller or a machine with the AD Management tools installed, and as an account that has permissions to modify Active Directory.
    Author: Tim Kecherson

#>

param(
    [Parameter(Position=0,Mandatory=$true)]
    [String]$CompanyName,
    [Parameter(Position=1,Mandatory=$true)]
    [int]$SiteCount = 1,
    [Parameter(Mandatory=$false)]
    [String]$FritPass

)

# Import AD Module
Import-Module ActiveDirectory

# Get domain root
$RootDomain = (get-addomain).DistinguishedName

# Enter site names
for ($i=1;$i -le $SiteCount;$i++){

    $SiteName = Read-Host -Prompt "Enter site $i OU Name"
    New-Variable -Name "site$i" -Value $SiteName

}

# Create OUs
New-ADOrganizationalUnit -Name "$CompanyName"

for ($i=1;$i -le $siteCount;$i++){

    $SiteName = (Get-Variable -Name "site$i").value

    New-ADOrganizationalUnit -Name $SiteName -Path "OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Active Employees" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Account Only" -Path "OU=Active Employees,OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Contacts" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Distro Groups" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Security Groups" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "External Users" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Workstations" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Servers" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Disabled" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru
    New-ADOrganizationalUnit -Name "Service Accounts" -Path "OU=$SiteName,OU=$CompanyName,$rootdomain" -PassThru

}

If ($FritPass -ne $null) {

    $Administrator = Get-ADUser Administrator -Properties memberOf,ScriptPath
    $DomainRoot = (get-addomain).DNSRoot
    $FritArgs = @{
        SamAccountName = 'frit'
        GivenName = 'FRIT'
        Surname = 'Admin'
        Name = 'FRIT Admin'
        DisplayName = 'FRIT Admin'
        UserPrincipalName = ('frit@' + $DomainRoot)
        AccountPassword = (ConvertTo-SecureString -AsPlainText $FritPass -force)
        Enabled = $true
        Description = 'FRIT Administrator Account'
        Instance = $Administrator

    }

    New-ADUser @FritArgs
    $Administrator.memberof | ForEach-Object {Add-ADGroupMember $_ frit }

}

Break