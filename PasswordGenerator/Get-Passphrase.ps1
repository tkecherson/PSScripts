[CmdletBinding()]
[OutputType()]
Param (
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$Count=5    
)
# Create Random Password
#Word List
$WordList = Get-Content .\enable1.txt
# Define Password Object
$PassList = @()

$i = 1
While ($i -le $count) {

# Create Passphrase
$W1lower = Get-Random -InputObject $WordList -Count 4
$W1 = (Get-Culture).TextInfo.ToTitleCase($W1lower)
$space = [char]32
$number = -join ((48..57) | Get-Random -Count 2 | ForEach-Object {[char]$_})
$NewPass = "$($W1)$($space)$($number)"

$password = New-Object PSObject 
$password | Add-Member Noteproperty Passwords $NewPass
$password | Add-Member Noteproperty PassLength $newpass.length
$passlist += $password
$i += 1
}

#Output Password Object
$PassList | Sort-Object -Property PassLength -Descending