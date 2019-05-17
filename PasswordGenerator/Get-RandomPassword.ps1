<# 
.SYNOPSIS
    Generates random passwords.

.DESCRIPTION
    Generates random passwords of a given length.

.PARAMETER PassLength
    Required, the requested password length. This is 24 by default.

.PARAMETER PassCount
    Required, the number of passwords generated. This is 10 by default.

.EXAMPLE
    PS> .\Get-RandomPassword.ps1 -PassLength 24 -PassCount 10
	Creates 10 passwords that are each 24 characters long.

.EXAMPLE
    PS> .\Get-RandomPassword.ps1 24 10
	Creates 10 passwords that are each 24 characters long.

.EXAMPLE
    PS> .\Get-RandomPassword.ps1
	Creates 10 passwords that are each 24 characters long.

.NOTES
    -------------------------
    Author: Tim Kecherson
	Version Number: 1.1
	Revision Date: 2019.05.17
    -------------------------
    
#>

param(
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$PassLength=24,
    [Parameter(Position=1,Mandatory=$False)]
    [Int]$PassCount=10

)

Write-Host "Generating passwords, please wait."
For ($i=1; $i -le 4; $i++)
{
    Write-Host "..."
    Start-Sleep -Milliseconds 250
}
Write-Host "Your passwords are:"
Write-Host ""

For ($i=1; $i -le $PassCount; $i++)
{
    #Generate Password
    -join ((33..126) * 4 | Get-Random -Count $PassLength | ForEach-Object {[char]$_}) | Out-Host
}

Write-Host ""

Break