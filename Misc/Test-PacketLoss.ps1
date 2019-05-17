<# 
.SYNOPSIS
    Tests for a percentage of ping packets dropped.

.DESCRIPTION
    Runs a given number of pings (by default, 100) and returns how many were lost.

.PARAMETER Server
    Required, the server that is being tested.

.PARAMETER PingCount
    Required, the number of pings sent. This is 100 by default

.EXAMPLE
    PS> .\Test-Packetloss.ps1 -Server 8.8.8.8 -PingCount 1000
	Sends 1000 packets to 8.8.8.8 and returns how many did not get a response.

.EXAMPLE
    PS> .\Test-Packetloss.ps1 8.8.8.8 1000
	Sends 1000 packets to 8.8.8.8 and returns how many did not get a response.

.NOTES
    Author: Tim Kecherson
	Version Number: 1.1
	Revision Date: 2019.05.13

#>

param(
    [Parameter(Position=0,Mandatory=$True)]
    [String]$Server,
    [Parameter(Position=1,Mandatory=$True)]
    [Int]$PingCount=100

)

$pingStatus = Test-Connection $Server -Count $PingCount -ErrorAction SilentlyContinue

$pingsLost = $PingCount - ($pingStatus).Count

$percentLost = $pingsLost / $PingCount * 100

$percentLostRounded = [math]::Round($percentLost,2)

Write-Host "There were $pingsLost packets lost out of $PingCount, or $percentLostRounded%."

Break