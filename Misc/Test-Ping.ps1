Param(
[Parameter(Position=0,Mandatory=$True)]
[string]$Destination
)
while($true){
    If ((Test-Connection $Destination -count 1 -quiet) -eq $true) {
    Test-Connection $Destination -count 1 | Select-Object @{N='Time';E={[dateTime]::Now}},@{N='Destination';E={$_.address}},replysize,@{N='Time(ms)';E={$_.ResponseTime}}
    Start-Sleep -Milliseconds 1000
    } Else {
    $time = Get-Date -UFormat "%m/%d/%Y %r"
    Write-Host -ForegroundColor "Red" -Object "$($time) $($Destination) is not responding."
    }
}