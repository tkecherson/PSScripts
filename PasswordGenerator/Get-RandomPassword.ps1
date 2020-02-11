[CmdletBinding(DefaultParameterSetName='Normal')]
[OutputType()]
param(
    [Alias("Length")]
    [Parameter(ParameterSetName="Normal",Position=0,Mandatory=$False)]
    [Parameter(ParameterSetName="AlphaNumeric")]
    [Parameter(ParameterSetName="Hex")]
    [Parameter(ParameterSetName="All")]
    [Int]$PassLength=32,
    [Alias("Count")]
    [Parameter(ParameterSetName="Normal",Position=1,Mandatory=$False)]
    [Parameter(ParameterSetName="AlphaNumeric")]
    [Parameter(ParameterSetName="Hex")]
    [Int]$PassCount=10,
    [Alias("AN")]
    [Parameter(ParameterSetName="AlphaNumeric",Mandatory=$False)]
    [Switch]$AlphaNumeric,
    [Alias("Hex")]
    [Parameter(ParameterSetName="Hex",Mandatory=$False)]
    [Switch]$Hexadecimal,
    [Parameter(ParameterSetName="All",Mandatory=$False)]
    [Switch]$All
)

# Define Password Object
$PassList = @()

If ($All.IsPresent) {$PassCount = 1}

If (!($All.IsPresent)) {

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
            $passlist += $password

            $i += 1
        }

    }

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

    }

$PassList