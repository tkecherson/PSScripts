[CmdletBinding()]
[OutputType()]
Param (
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$Count=10,    
    [Parameter(Mandatory=$False)]
    [Switch]$long,
    [Parameter(Mandatory=$False)]
    [Switch]$med,
    [Parameter(Mandatory=$False)]
    [Switch]$short,
    [Parameter(Mandatory=$False)]
    [Switch]$alphanumeric
)
# Create Random Password
# Adjective List
$adjectivelist = (Get-Content ".\english-adjectives.txt")

# Noun List
$nounlist = (Get-Content ".\english-nouns.txt")

	# Define Object
	$PassList = @()

	$i = 1
	While ($i -le $count) {

	# Select random objects

	if($long.IsPresent) {
		do {
			$adjective = Get-Random -InputObject $adjectivelist -Count 1
			$noun = Get-Random -InputObject $nounlist -Count 1
		} until (($adjective+$noun).length -ge 18)
	} elseif ($med.IsPresent) {
		do {
			$adjective = Get-Random -InputObject $adjectivelist -Count 1
			$noun = Get-Random -InputObject $nounlist -Count 1
		} until ((($adjective+$noun).length -le 17) -and (($adjective+$noun).length -ge 9))
	} elseif ($short.IsPresent) {
		do {
			$adjective = Get-Random -InputObject $adjectivelist -Count 1
			$noun = Get-Random -InputObject $nounlist -Count 1
		} until (($adjective+$noun).length -le 8)
	} else {
		$adjective = Get-Random -InputObject $adjectivelist -Count 1
		$noun = Get-Random -InputObject $nounlist -Count 1
	}
	if ($alphanumeric.IsPresent){
		$number = -join ((48..57) | Get-Random -Count 2 | ForEach-Object {[char]$_})

		# Define Password and add to list
		$newpass = "$($adjective)$($noun)$($number)"
		$password = New-Object PSObject 
		$password | Add-Member Noteproperty Passwords $newpass
		$password | Add-Member Noteproperty PassLength $newpass.length
		$passlist += $password
		$i += 1
	} else {
		$symbol = -join ((33..47) + (60..64) | Get-Random -Count 1 | ForEach-Object {[char]$_})
		$symbolnumber = -join ((33..57) + (60..64) | Get-Random -Count 1 | ForEach-Object {[char]$_})
		$number = -join ((48..57) | Get-Random -Count 1 | ForEach-Object {[char]$_})

		# Define Password and add to list
		$newpass = "$($adjective)$($noun)$($symbol)$($symbolnumber)$($number)"
		$password = New-Object PSObject 
		$password | Add-Member Noteproperty Passwords $newpass
		$password | Add-Member Noteproperty PassLength $newpass.length
		$passlist += $password
		$i += 1
		}
	}

	# Output password object
	$PassList | Sort-Object -Property PassLength -Descending