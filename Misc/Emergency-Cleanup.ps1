<# 
.SYNOPSIS
    Clean up script for system drives.

.DESCRIPTION
    This script will clean up CBS logs, N-Able logs, and the SoftwareDownloads folder on a Windows server or desktop.

.PARAMETER ComputerName
    Determines the computer to run the scripts against.
	
.PARAMETER CBSLogsSelected
    This will determine if CBS logs are selected for cleanup. Default value is True.

.PARAMETER NAbleLogsSelected
    This will determine if N-Able logs are selected for cleanup. Default value is True.
	
.PARAMETER SoftwareDownloadsSelected
    This will determine if SystemDownloads folder is selected for cleanup. Default value is True.

.EXAMPLE
	PS> .\Emergency-Cleanup.ps1 -ComputerName localhost -CBSLogsSelected $true -NAbleLogsSelected $true = SoftwareDownloadsSelected $true
	Cleans up Windows CBS logs, N-Able agent logs, and the SoftwareDownloads directory on the local computer.

.EXAMPLE
	PS> .\Emergency-Cleanup.ps1 -CBSLogsSelected $true -NAbleLogsSelected $true = SoftwareDownloadsSelected $true
	Prompts for a computer name, then cleans up Windows CBS logs, N-Able agent logs, and the SoftwareDownloads directory.

.EXAMPLE
	PS> .\Emergency-Cleanup.ps1 -ComputerName localhost -CBSLogsSelected $false -NAbleLogsSelected $true = SoftwareDownloadsSelected $true
	Cleans up N-Able agent logs, and the SoftwareDownloads directory on the local computer, but skips CBS logs.

.EXAMPLE
	PS> .\Emergency-Cleanup.ps1 -ComputerName localhost
	Cleans up Windows CBS logs, N-Able agent logs, and the SoftwareDownloads directory on the local computer.

.NOTES
    This script should be run as an Administrator to stop the services.
    Author: Tim Kecherson
	Version Number: 1.1
	Revision Date: 2019.05.13

#>

param(
    [Parameter(Position=0,Mandatory=$false)]
    [String]$ComputerName,
    [Parameter(Position=1,Mandatory=$false)]
    [Boolean]$CBSLogsSelected=$true,
    [Parameter(Position=2,Mandatory=$false)]
    [Boolean]$NAbleLogsSelected=$true,
    [Parameter(Position=3,Mandatory=$false)]
    [Boolean]$SoftwareDownloadsSelected=$true

)

# Initial value of size variables is 0
$CBSLogSize = 0
$CBSCabSize = 0
$NAbleLogSize = 0
$NAbleLogDataSize = 0
$SoftwareDistributionFilesSize = 0

# Test admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If ($isAdmin -eq $false) {

	Write-Host "Administrative priviliges required, please run the script from an escalated shell."
	Break
	
}

# Choose the target workstation
if ($ComputerName -eq $null) {
$ComputerName = Read-Host -Prompt "Input computer name, or press enter to run locally"
}

# Set the location
If (($ComputerName -eq "") -or ($ComputerName -eq 'LocalHost')) {

	# Set Location (Local)
	Set-Location -Path C:\
	
	} Else {
	
	# Set Location (Remote)
	Set-Location -Path "\\$ComputerName\c$\"

}

Write-Host "Beginning System Scan and Cleanup."

###################
#                 #
# CBS Log Cleanup #
#                 #
###################

If ($CBSLogsSelected -eq $true) {

	# Get the logs
	Write-Host "Checking CBS Logs..."
	$CBSLogs = Get-ChildItem .\Windows\Logs\CBS\CbsPersist_*.log
	$CBSCabs = Get-ChildItem .\Windows\Temp\cab_*

	# Count the logs
	$CBSLogCount = ($CBSLogs | Measure-Object).Count
	$CBSCabCount = ($CBSCabs | Measure-Object).Count
	$CBSTotalCount = ($CBSLogCount + $CBSCabCount)

	# Get the log size
	$CBSLogSize = ($CBSLogs | Measure-Object -Sum Length).Sum
	$CBSCabSize = ($CBSCabs | Measure-Object -Sum Length).Sum


	If ($LogCount -gt 1) {

		Write-Host "Extra log files found, cleaning up."
		$CBSLogs | Remove-Item
		$CBSCabs | Remove-Item
		Write-Host "Cleared off $CBSLogCount CBS log files and $CBSCabCount associated temporary files."
		
		} Else {

		Write-Host "CBS log files are not an issue, continuing."

	}

}

######################
#                    #
# N-Able Log Cleanup #
#                    #
######################

If ($NAbleLogsSelected -eq $true) {

	# Get the logs
	Write-Host "Checking N-Able Logs..."

	If ((Test-Path -Path ".\Program Files (x86)") -eq $True) {

		$NAbleLogs = Get-ChildItem ".\Program Files (x86)\N-able Technologies\Windows Agent\Temp\Script\AutomationManager" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-3)}
		$NAbleLogsData = Get-ChildItem ".\ProgramData\N-Able Technologies\AutomationManager\Logs" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-3)}

		} Else {
		
		$NAbleLogs = Get-ChildItem ".\Program Files\N-able Technologies\Windows Agent\Temp\Script\AutomationManager" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-3)}
		$NAbleLogsData = Get-ChildItem ".\ProgramData\N-Able Technologies\AutomationManager\Logs" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-3)}
		
	}

	# Count the logs
	$NAbleLogCount = ($NAbleLogs | Measure-Object).Count
	$NAbleLogDataCount = ($NAbleLogsData | Measure-Object).Count
	$NAbleTotalCount = ($NAbleLogCount + $NAbleLogDataCount)

	# Get the Log Size
	$NAbleLogSize = ($NAbleLogs | Measure-Object -Sum Length).Sum
	$NAbleLogDataSize = ($NAbleLogsData | Measure-Object -Sum Length).Sum

	# Delete the Logs
	If ($NAbleLogCount -gt 10000) {

		Write-Host "Extra N-Able log files found, cleaning up."
		$NAbleLogs | Remove-Item -Recurse
		$NAbleLogsData | Remove-Item -Recurse
		Write-Host "Cleared off $NAbleTotalCount N-Able log files."
		
		} Else {

		Write-Host "Your N-Able log files are not an issue, continuing."

	}

}

#########################
#                       #
# Software Distribution #
#    Folder Cleanup     #
#                       #
#########################

If ($SoftwareDownloadsSelected -eq $true) {

	# Stop Services
	Write-Host "Stopping Update Services..."
	Stop-Service -Name "BITS"
	Stop-Service -Name "wuauserv"

	# Begin Cleanup
	Write-Host "Cleaning up files."
	$SoftwareDistributionFiles = Get-ChildItem .\Windows\SoftwareDistribution\Download -Recurse

	# Count the files
	$SoftwareDistributionFilesCount = ($SoftwareDistributionFiles | Measure-Object).Count

	# Get the size of the files
	$SoftwareDistributionFilesSize = ($SoftwareDistributionFiles | Measure-Object -Sum Length).Sum

	# Delete the files
	Get-ChildItem .\Windows\SoftwareDistribution\Download -Recurse | Remove-Item -Recurse

	# Start Services
	Write-Host "Starting Update Services..."
	Start-Service -Name "wuauserv"
	Start-Service -Name "BITS"

}

################
#              #
# Final Output #
#              #
################

# Get the total count
$TotalCount = ($CBSTotalCount + $NAbleLogCount + $SoftwareDistributionFilesCount)

# Get total size freed up
$TotalSizeFreed = ($CBSLogSize + $CBSCabSize + $NAbleLogSize + $NAbleLogDataSize + $SoftwareDistributionFilesSize)
$TotalSizeFreedKB = [math]::Round(($TotalSizeFreed / 1KB),2)
$TotalSizeFreedMB = [math]::Round(($TotalSizeFreed / 1MB),2)
$TotalSizeFreedGB = [math]::Round(($TotalSizeFreed / 1GB),2)

# Write Total Output
Write-Host "System Cleanup Complete."
Write-Host "Removed $TotalCount Files"
If ($TotalSizeFreedGB -gt 1) {
	
	Write-Host "Freed up $TotalSizeFreedGB GB."
		
	} Else {
		
		If ($TotalSizeFreedMB -gt 1) {
		
			Write-Host "Freed up $TotalSizeFreedMB MB."
			
			} Else {
				
				If ($TotalSizeFreedKB -gt 1) {
				
					Write-Host "Freed up $TotalSizeFreedKB KB."
			
					} Else {
				
				Write-Host "Freed up $TotalSizeFreed Bytes."
					
			}
	
		}
	
	}

Write-Host "Exiting Script."
Break