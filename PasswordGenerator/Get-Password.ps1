Param (
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$Count=1    
)
# Create Random Password
# Adjective List
$adjectivelist = (Get-Content ".\english-adjectives.txt")

# Noun List
$nounlist = (Get-Content ".\english-nouns.txt")

$i = 1
While ($i -le $count) {
# Select random object
$adjective = Get-Random -InputObject $adjectivelist -Count 1
$noun = Get-Random -InputObject $nounlist -Count 1
$symbol = -join ((33..47) + (60..64) | Get-Random -Count 1 | ForEach-Object {[char]$_})
$symbolnumber = -join ((33..57) + (60..64) | Get-Random -Count 1 | ForEach-Object {[char]$_})
$number = -join ((48..57) | Get-Random -Count 1 | ForEach-Object {[char]$_})

Write-Host "$($adjective)$($noun)$($symbol)$($symbolnumber)$($number)"
$i+=1
}