Param (
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$Count=1    
)
# Create Random Passphrase
#Word List
$WordList = Get-Content .\enable1.txt

$i = 1
While ($i -le $count) {
# Create Passphrase
$W1lower = Get-Random -InputObject $WordList -Count 4
$W1 = (Get-Culture).TextInfo.ToTitleCase($W1lower)

Write-Host "$($W1)"
$i+=1
}

Break