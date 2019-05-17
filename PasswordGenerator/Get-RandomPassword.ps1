#Request Password Length
$count = Read-Host -Prompt "Input Password Length"

#Generate Password
$password0 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password1 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password2 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password3 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password4 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password5 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password6 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password7 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password8 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})
$password9 = -join ((33..126) * 3 | Get-Random -Count $count | % {[char]$_})

#Output Password
Write-Host ""
Write-Host "Your passwords are:"
Write-Host ""
Write-Host "$($password0)"
Write-Host "$($password1)"
Write-Host "$($password2)"
Write-Host "$($password3)"
Write-Host "$($password4)"
Write-Host "$($password5)"
Write-Host "$($password6)"
Write-Host "$($password7)"
Write-Host "$($password8)"
Write-Host "$($password9)"
Write-Host ""