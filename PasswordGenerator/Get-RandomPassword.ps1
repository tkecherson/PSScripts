[CmdletBinding(DefaultParameterSetName='Normal')]
[OutputType()]
param(
    [Parameter(Position=0,Mandatory=$False)]
    [Int]$PassLength=32,
    [Parameter(Position=1,Mandatory=$False)]
    [Int]$PassCount=10,
    [Parameter(Mandatory=$False)]
    [Switch]$AlphaNumeric,
    [Parameter(Mandatory=$False)]
    [Switch]$Hexadecimal,
    [Parameter(Mandatory=$False)]
    [Switch]$All
)

If ((($AlphaNumeric.IsPresent) -and ($Hexadecimal.IsPresent)) -or (($AlphaNumeric.IsPresent) -and ($All.IsPresent)) -or (($All.IsPresent) -and ($Hexadecimal.IsPresent)) -or (($AlphaNumeric.IsPresent) -and ($Hexadecimal.IsPresent) -and ($All.IsPresent))) {
    Throw "Please choose one of the three switches (-AlphaNumeric, -Hexadecimal, -All) and run the command again."
}

# Define Password Object
$PassList = @()

If ($All.IsPresent) {$PassCount = 1}

$i = 1
While ($i -le $passcount) {

#Generate Password
If (!($AlphaNumeric.IsPresent) -and !($Hexadecimal.IsPresent) -and !($All.IsPresent)) {
    $NewPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((33..126) | Get-Random | ForEach-Object {[char]$_})
        $NewPass += $character 
        $charCount += 1
    }
    
    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $NewPass
    $password | Add-Member Noteproperty Type "Random"
    $passlist += $password

    $i += 1
    }

If ($AlphaNumeric.IsPresent) {
    $ANPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((48..57) + (65..90) + (97..122) | Get-Random | ForEach-Object {[char]$_})
        $ANPass += $character 
        $charCount += 1
    }

    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $ANPass
    $password | Add-Member Noteproperty Type "AlphaNumeric"
    $passlist += $password

    $i += 1
    }

If ($Hexadecimal.IsPresent) {
    $HexPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((48..57) + (65..70) | Get-Random | ForEach-Object {[char]$_})
        $HexPass += $character 
        $charCount += 1
    }

    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $HexPass
    $password | Add-Member Noteproperty Type "Hexadecimal"
    $passlist += $password

    $i += 1
    }

If ($All.IsPresent) {
    $RandPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((33..126) | Get-Random | ForEach-Object {[char]$_})
        $RandPass += $character 
        $charCount += 1
    }

    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $RandPass
    $password | Add-Member Noteproperty Type "Random"
    $passlist += $password

    $ANPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((48..57) + (65..90) + (97..122) | Get-Random | ForEach-Object {[char]$_})
        $ANPass += $character 
        $charCount += 1
    }

    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $ANPass
    $password | Add-Member Noteproperty Type "AlphaNumeric"
    $passlist += $password

    $HexPass = ""
    $charCount = 1
    while ($CharCount -le $PassLength) {
        $character = -join ((48..57) + (65..70) | Get-Random | ForEach-Object {[char]$_})
        $HexPass += $character 
        $charCount += 1
    }

    $password = New-Object PSObject 
    $password | Add-Member Noteproperty Passwords $HexPass
    $password | Add-Member Noteproperty Type "Hexadecimal"
    $passlist += $password

    $i += 1
    }
}

$PassList