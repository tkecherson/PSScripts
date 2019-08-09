Function New-MSPOUs {
    <# 
    .SYNOPSIS
        Creates a basic OU structure for a new client.
    .DESCRIPTION
        This script will create a root OU for a company, one or more site OUs underneath that, and various recommended OUs within those.
    .NOTES
        Must be run from a domain controller or a machine with the AD Management tools installed, and as an account that has permissions to modify Active Directory.
        Author: Tim Kecherson
    #>
    # Import AD Module
    Import-Module ActiveDirectory
    # Get domain root
    Clear-Host
    $RootDomain = (get-addomain).DistinguishedName
    $CompanyName = Read-Host "Please enter the company name for the base OU"
    $SiteCount = Read-Host "Please enter how many sites the company has"
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
    "OU Structure has been created. Returning to the base menu..." | Out-Host
    Start-Sleep -Seconds 2
}

Function New-MSPAdmin {
    Clear-Host
    "Creating MSP Admin account..." | Out-Host
    $i=1
    do {
    If ($i -gt 1) {"Passwords did not match!" | Write-Warning}
    $MSPpwd1 = Read-Host "Please enter MSP Admin Password" -AsSecureString
    $MSPpwd2 = Read-Host "Please confirm MSP Admin Password" -AsSecureString
    $MSPpwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($MSPpwd1))
    $MSPpwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($MSPpwd2))
    $i++
    }
    while ($MSPpwd1_text -cne $MSPpwd2_text)
    $MSPPass = $MSPpwd1
    $Administrator = Get-ADUser Administrator -Properties memberOf,ScriptPath
    $DomainRoot = (get-addomain).DNSRoot
    $MSPArgs = @{
        SamAccountName = 'MSP'
        GivenName = 'MSP'
        Surname = 'Admin'
        Name = 'MSP Admin'
        DisplayName = 'MSP Admin'
        UserPrincipalName = ('MSP@' + $DomainRoot)
        AccountPassword = $MSPPass
        Enabled = $true
        Description = 'MSP Administrator Account'
        Instance = $Administrator
    }
    New-ADUser @MSPArgs
    $Administrator.memberof | ForEach-Object {Add-ADGroupMember $_ MSP }
    "MSP Admin account has been created!" | Out-Host
    Start-Sleep -Seconds 2
}

Function New-MSPBackupAdmin {
    Clear-Host
    "Creating MSP Backup Admin account..." | Out-Host
    $i=1
    do {
    If ($i -gt 1) {"Passwords did not match!" | Write-Warning}
    $MSPbapwd1 = Read-Host "Please enter MSP Backup Admin Password" -AsSecureString
    $MSPbapwd2 = Read-Host "Please confirm MSP Backup Admin Password" -AsSecureString
    $MSPbapwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($MSPbapwd1))
    $MSPbapwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($MSPbapwd2))
    $i++
    }
    while ($MSPbapwd1_text -cne $MSPbapwd2_text)
    $MSPBAPass = $MSPbapwd1
    $Administrator = Get-ADUser Administrator -Properties memberOf,ScriptPath
    $DomainRoot = (get-addomain).DNSRoot
    $MSPBAArgs = @{
        SamAccountName = 'MSPbackupadmin'
        GivenName = 'MSP'
        Surname = 'Backup Admin'
        Name = 'MSP Backup Admin'
        DisplayName = 'MSP Backup Admin'
        UserPrincipalName = ('MSPbackupadmin@' + $DomainRoot)
        AccountPassword = $MSPBAPass
        Enabled = $true
        Description = 'MSP Backup Service Account'
        Instance = $Administrator
    }
    New-ADUser @MSPBAArgs
    Get-ADGroup 'Domain Admins' | Add-ADGroupMember -Members MSPbackupadmin
    "MSP Backup Admin account has been created!" | Out-Host
    Start-Sleep -Seconds 2
}

Function New-MSPPRTG {
    Clear-Host
    "Creating PRTG Monitoring account..." | Out-Host
    $i=1
    do {
    If ($i -gt 1) {"Passwords did not match!" | Write-Warning}
    $prtgpwd1 = Read-Host "Please enter PRTG Monitoring Password" -AsSecureString
    $prtgpwd2 = Read-Host "Please confirm PRTG Monitoring Password" -AsSecureString
    $prtgpwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($prtgpwd1))
    $prtgpwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($prtgpwd2))
    $i++
    }
    while ($prtgpwd1_text -cne $prtgpwd2_text)
    $prtgPass = $prtgpwd1
    $Administrator = Get-ADUser Administrator -Properties memberOf,ScriptPath
    $DomainRoot = (get-addomain).DNSRoot
    $prtgArgs = @{
        SamAccountName = 'srv_prtg'
        GivenName = 'PRTG'
        Surname = 'Service Account'
        Name = 'PRTG Service Account'
        DisplayName = 'PRTG Service Account'
        UserPrincipalName = ('srv_prtg@' + $DomainRoot)
        AccountPassword = $prtgPass
        Enabled = $true
        Description = 'MSP Monitoring Service Account'
        Instance = $Administrator
    }
    New-ADUser @prtgArgs
    Get-ADGroup 'Domain Admins' | Add-ADGroupMember -Members srv_prtg
    "PRTG Monitoring account has been created!" | Out-Host
    Start-Sleep -Seconds 2
}

Function New-MSPNCentral {
    Clear-Host
    "Creating N-Central Management account..." | Out-Host
    $i=1
    do {
    If ($i -gt 1) {"Passwords did not match!" | Write-Warning}
    $ncentralpwd1 = Read-Host "Please enter N-Central Management Password" -AsSecureString
    $ncentralpwd2 = Read-Host "Please confirm N-Central Management Password" -AsSecureString
    $ncentralpwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ncentralpwd1))
    $ncentralpwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($ncentralpwd2))
    $i++
    }
    while ($ncentralpwd1_text -cne $ncentralpwd2_text)
    $ncentralPass = $ncentralpwd1
    $Administrator = Get-ADUser Administrator -Properties memberOf,ScriptPath
    $DomainRoot = (get-addomain).DNSRoot
    $ncentralArgs = @{
        SamAccountName = 'srv_ncentral'
        GivenName = 'N-Central'
        Surname = 'Service Account'
        Name = 'N-Central Service Account'
        DisplayName = 'N-Central Service Account'
        UserPrincipalName = ('srv_ncentral@' + $DomainRoot)
        AccountPassword = $ncentralPass
        Enabled = $true
        Description = 'MSP Management Service Account'
        Instance = $Administrator
    }
    New-ADUser @ncentralArgs
    Get-ADGroup 'Domain Admins' | Add-ADGroupMember -Members srv_ncentral
    "N-Central Management account has been created!" | Out-Host
    Start-Sleep -Seconds 2
}

Function New-MSPAccounts {
    Clear-Host
    "Please note all passwords before creating the accounts!" | Write-Warning
    "Passwords will NOT be visible during or after the script is run!" | Write-Warning
    Start-Sleep -Seconds 3
    New-MSPAdmin
    New-MSPBackupAdmin
    New-MSPPRTG
    New-MSPNCentral
    "MSP Accounts have been created!" | Out-Host
    Start-Sleep -Seconds 2
}

Function Import-MSPGPOs {
    Clear-Host
    if (([Environment]::OSVersion).Version.Major -eq '10') {
        Copy-Item .\GPOExport2016\ c:\Temp\GPOExport\ -Recurse
    }
    if ((([Environment]::OSVersion).Version.Major -eq '6') -and (([Environment]::OSVersion).Version.Minor -eq '3')) {
        Copy-Item .\GPOExport\ c:\Temp\GPOExport\ -Recurse
    }
    "Importing MSP GPOs..." | Out-Host
    Import-GPO -BackupGpoName "MSP Disable USB" -TargetName "MSP Disable USB" -BackupLocation C:\Temp\GPOExport -CreateIfNeeded
    Import-GPO -BackupGpoName "MSP Password Policy" -TargetName "MSP Password Policy" -BackupLocation c:\Temp\GPOExport\ -CreateIfNeeded
    Import-GPO -BackupGpoName "MSP Remote Management" -TargetName "MSP Remote Management" -BackupLocation c:\Temp\GPOExport\ -CreateIfNeeded
    Import-GPO -BackupGpoName "MSP Screen Lock" -TargetName "MSP Screen Lock" -BackupLocation c:\Temp\GPOExport\ -CreateIfNeeded
    Import-GPO -BackupGpoName "MSP Service Accounts" -TargetName "MSP Service Accounts" -BackupLocation c:\Temp\GPOExport\ -CreateIfNeeded
    "GPOs have been successfully imported!" | Out-Host
    Start-Sleep -Seconds 2
}

Function Start-MSPOnboarding {
    Clear-Host
    New-MSPOUs
    New-MSPAccounts
    Import-MSPGPOs
    "Onboarding complete!" | Out-Host
    Start-Sleep -Seconds 2
}

Function Show-OnboardingBaseMenu {
    Do {
        Clear-Host
        Write-Host "
    
        Welcome to the MSP Active Directory onboarding script!

        Please select a task:
    
        1. Create OU Structure
        2. Create MSP Accounts
        3. Import MSP Recommended GPOs
        4. Perform all three steps automatically
        Q. Quit the program.
    
    "
    $MainMenu = Read-Host -Prompt "Please select a task by number, or press Q to quit"  
    } until ($MainMenu -eq "1" -or $MainMenu -eq "2" -or $MainMenu -eq "3" -or $MainMenu -eq "4" -or $MainMenu -eq "Q")
    Switch ($MainMenu) {
        "1" { New-MSPOUs;Show-OnboardingBaseMenu }
        "2" { New-MSPAccounts;Show-OnboardingBaseMenu }
        "3" { Import-MSPGPOs;Show-OnboardingBaseMenu }
        "4" { Start-MSPOnboarding;;Show-OnboardingBaseMenu }
        "Q" { "Quitting the program..." | Out-Host; Break }
    }
}

Show-OnboardingBaseMenu