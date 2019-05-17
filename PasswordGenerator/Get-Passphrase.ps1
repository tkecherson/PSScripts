# Create Random Password
#Word List
$WordList = Get-Content .\enable1.txt
 
# Create Passphrase
$W1lower = Get-Random -InputObject $WordList -Count 4
$W1 = (Get-Culture).TextInfo.ToTitleCase($W1lower)
$date = Get-Date

Write-Host "Password: $($W1). Selected on $date."