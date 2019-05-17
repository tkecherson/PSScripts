# Create Random Password
# Adjective List
$adjectivelist = (gc ".\english-adjectives.txt")

# Noun List
$nounlist = (gc ".\english-nouns.txt")
 
# Select random object
$adjective = Get-Random -InputObject $adjectivelist -Count 1
$noun = Get-Random -InputObject $nounlist -Count 1
$symbol = -join ((33..47) + (60..64) | Get-Random -Count 1 | % {[char]$_})
$symbolnumber = -join ((33..57) + (60..64) | Get-Random -Count 1 | % {[char]$_})
$number = -join ((48..57) | Get-Random -Count 1 | % {[char]$_})
$date = Get-Date

Write-Host "Password: $($adjective)$($noun)$($symbol)$($symbolnumber)$($number). Selected on $date."