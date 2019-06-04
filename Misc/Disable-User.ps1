<# 
.SYNOPSIS
    Disables a given account.

.DESCRIPTION
    This script is used to disable an active directory account, remove
    its memberships, and kick off an AAD sync cycle.

.PARAMETER Username
    This specifies the user to be disabled, and is mandatory.
	
.PARAMETER Password
    This specifies the new password for the account, and is mandatory.
	
.PARAMETER DisableOnly
    Adding this parameter will prevent the script from removing AD Group memberships.

.EXAMPLE
    PS> .\Disable-User.ps1 -Username SampleUser -Password SamplePassword
	Disables the user, moves it to the Disabled Users OU, sets its password, 
	removes all group memberships except Domain Users , and starts an 
	Azure AD Sync cycle.

.EXAMPLE
    PS> .\Disable-User.ps1 SampleUser SamplePassword
	Disables the user, moves it to the Disabled Users OU, sets its password, 
	removes all group memberships except Domain Users , and starts an 
	Azure AD Sync cycle.

.EXAMPLE
    PS> .\Disable-User.ps1 -Username SampleUser -Password SamplePassword -DisableOnly
	Disables the user, moves it to the Disabled Users OU, sets its password, and 
	starts an Azure AD Sync cycle.

.NOTES
    This script must be run under Domain Admin credentials.
    Author: Tim Kecherson
	Version Number: 1.0
	Revision Date: 2019.06.04

#>

param (
    [Parameter(Position=0,Mandatory=$true)]
    [String]$UserName,
    [Parameter(Position=1,Mandatory=$true)]
    [String]$Password,
    [Parameter(Position=2,Mandatory=$false)]
    [Switch]$DisableOnly
)

# Import AD Module if necessary
Import-Module ActiveDirectory

# Define common variables
$Date = (Get-Date).ToShortDateString()
$AADSyncServer = #Insert the name of your AD Sync Server
$Password = ConvertTo-SecureString -AsPlainText $Password -Force
$DisabledUsersOU = "" #Insert the path of your Disabled Users OU here

# Move and disable account
Get-ADUser $User | Move-ADObject -TargetPath $DisabledUsersOU
Set-ADAccountPassword -Identity $User -NewPassword $Password -Reset
Get-ADUser -Identity $User | Set-ADUser -Description "Disabled on $Date"
Disable-ADAccount -Identity $User

# If $DisableOnly is not selected, remove all group memberships
If ($DisableOnly.IsPresent -ne $true) {

    Get-AdPrincipalGroupMemberShip $User | Where-Object {$_.Name -ne 'Domain Users'} | Remove-AdGroupMember -member $User -Confirm:$False

}

# Kick off AAD Sync
$session = New-PSSession -ComputerName $AADSyncServer
Invoke-Command -Session $session -ScriptBlock {Import-Module -Name 'ADSync'}
Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
Remove-PSSession $session

Write-Host "User" $($User) "has been disabled."

Break