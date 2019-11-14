[CmdletBinding()]
[OutputType()]
Param ()

# Import computer list
$ComputerList = Get-Content .\BackupComputers.txt

# Import Computer List - By OU
# $ComputerList = (Get-ADComputer -filter * -SearchBase 'OU=SubOU,OU=OU,DC=domain,DC=tld' -SearchScope 2).name
# Adjust the OU as needed. To prevent recursion, change SearchScope from 2 to 1.

# Define object for status
$ComputerStatus = @()

# Define Script Block
$BackupKey = {
    #Getting Recovery Key GUID
    $RecoveryKeyGUIDs = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | Where-Object {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
    #Backing up the Recovery to AD.
    Foreach ($RecoveryKeyGUID in $RecoveryKeyGUIDs) {
        manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID
    }
}

Foreach ($Computer in $ComputerList) {

    $Comp = New-Object PSObject
    $Comp | Add-Member NoteProperty ComputerName $Computer

    If (!(Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        $Comp | Add-Member NoteProperty EncryptionType Offline
        $Comp | Add-Member NoteProperty BackedUp Offline
        Continue
    }

    $CompEnc = (invoke-command -ComputerName $computer -ScriptBlock {(Get-BitLockerVolume -MountPoint c:).encryptionmethod}).value
    $Comp | Add-Member NoteProperty EncryptionType $CompEnc

    Invoke-Command -ComputerName $Computer -ScriptBlock $BackupKey
    $Comp | Add-Member NoteProperty BackedUp Yes

    $ComputerStatus += $Comp
    
}

$ComputerStatus | Export-Csv .\Results\ComputerBLBackupStatus.csv -NoTypeInformation