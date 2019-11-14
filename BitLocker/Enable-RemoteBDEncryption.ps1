[CmdletBinding()]
[OutputType()]
Param ()

# Define object for status
$ComputerStatus = @()

# Define Script Blocks
$SetBLPartiton = {
    Get-Service -Name defragsvc -ErrorAction SilentlyContinue | Set-Service -Status Running -ErrorAction SilentlyContinue
    BdeHdCfg -target $env:SystemDrive shrink -quiet
}

$EnableBDEncryption = {
    gpupdate /force

    #Creating the recovery key
    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
    
    #Adding TPM key
    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -TpmProtector
    Start-Sleep -Seconds 15 #This is to give sufficient time for the protectors to fully take effect.
    
    #Enabling Encryption
    Start-Process 'manage-bde.exe' -ArgumentList " -on $env:SystemDrive -em xts_aes256" -Verb runas -Wait
    
    #Getting Recovery Key GUID
    $RecoveryKeyGUID = (Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | Where-Object {$_.Keyprotectortype -eq 'RecoveryPassword'} | Select-Object -ExpandProperty KeyProtectorID
    
    #Backing up the Recovery to AD.
    manage-bde.exe  -protectors $env:SystemDrive -adbackup -id $RecoveryKeyGUID
}

# Import computer list
$ComputerList = Get-Content .\TargetComputers.txt

# Import Computer List - By OU
# $ComputerList = (Get-ADComputer -filter * -SearchBase 'OU=SubOU,OU=OU,DC=domain,DC=tld' -SearchScope 2).name
# Adjust the OU as needed. To prevent recursion, change SearchScope from 2 to 1.

#
Foreach ($Computer in $ComputerList) {

    $Comp = New-Object PSObject
    $Comp | Add-Member NoteProperty ComputerName $Computer

    If (!(Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        $Comp | Add-Member NoteProperty TPMPresent Offline
        $Comp | Add-Member NoteProperty WindowsVersionCheck Offline
        $Comp | Add-Member NoteProperty DriveReady Offline
        $Comp | Add-Member NoteProperty DriveEncrypted Offline
        $ComputerStatus += $Comp
        Continue
    }

    $TPM = Get-WmiObject win32_tpm -Namespace root\cimv2\security\microsofttpm -ComputerName $Computer | Where-Object {$_.IsEnabled().Isenabled -eq 'True'} -ErrorAction SilentlyContinue
    $WindowsVer = Get-WmiObject -Query 'select * from Win32_OperatingSystem where (Version like "6.2%" or Version like "6.3%" or Version like "10.0%") and ProductType = "1"' -COmputerName $Computer -ErrorAction SilentlyContinue
    $SystemDriveBitLockerRDY = (Invoke-Command -ComputerName $Computer -ScriptBlock { Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue }).ProtectionStatus

    If ($TPM) {
        $Comp | Add-Member NoteProperty TPMPresent Yes
    } else {
        $Comp | Add-Member NoteProperty TPMPresent No
        $Comp | Add-Member NoteProperty WindowsVersionCheck No
        $Comp | Add-Member NoteProperty DriveReady No
        $Comp | Add-Member NoteProperty DriveEncrypted No
        $ComputerStatus += $Comp
        Continue
    }

    If ($WindowsVer) {
        $Comp | Add-Member NoteProperty WindowsVersionCheck Yes
    } else {
        $Comp | Add-Member NoteProperty WindowsVersionCheck No
        $Comp | Add-Member NoteProperty DriveReady No
        $Comp | Add-Member NoteProperty DriveEncrypted No
        $ComputerStatus += $Comp
        Continue
    }

    If ($SystemDriveBitLockerRDY) {
        $Comp | Add-Member NoteProperty DriveReady Yes
    } else {
        Invoke-Command -ComputerName $Computer -ScriptBlock $SetBLPartiton
        $Comp | Add-Member NoteProperty DriveReady Reboot
        $Comp | Add-Member NoteProperty DriveEncrypted No
        $ComputerStatus += $Comp
        Continue
    }

    If ($SystemDriveBitLockerRDY -eq 'On') {
        $Comp | Add-Member NoteProperty DriveEncrypted Yes
        $ComputerStatus += $Comp
    } Else {
        Invoke-Command -ComputerName $Computer -ScriptBlock $EnableBDEncryption
        $Comp | Add-Member NoteProperty DriveEncrypted Reboot
        $ComputerStatus += $Comp
        Continue
    }

}

$ComputerStatus | Export-Csv .\Results\ComputerBLStatus.csv -NoTypeInformation