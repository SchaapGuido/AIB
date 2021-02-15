﻿<#  
.SYNOPSIS  
    Custimization script for Azure Image Builder including Microsoft recommneded configuration to be included in a Windows 10 ms Master Image including Office
.
.DESCRIPTION  
    Customization script to build a WVD Windows 10ms image
    This script configures the Microsoft recommended configuration for a Win10ms image:
        Article:    Prepare and customize a master VHD image 
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image 
        Article:    Install Office on a master VHD image 
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/install-office-on-wvd-master-image
        Article:    Use Microsoft Teams on Windows Virtual desktop
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-wvd
        Article: S   et up MSIX app attach with the Azure portal
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach-azure-portal
NOTES  
    File Name  : Win10ms_O365.ps1
    Author     : Roel Schellens
    Version    : v0.0.2
    Date       : 20-Jan-2021
.
.EXAMPLE
    This script can be used in confuction with an 
.
.DISCLAIMER
    1 - All configuration settings in this script need to be validated and tested in your own environment.
    2 - Ensure to confirm the documentation online has not been updated and therefor might include different settings
    3 - Where possible also the use of Group Policies can be used.
    4 - The below script uses the Write-Host command to allow you to better troubleshoot the activity from within the Packer logs.
    5 - To get more verbose logging of the script remove the | Out-Null at the end of the PowerShell command
#>

Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Script: Win10ms_O365.ps1                                                                   ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Exit Code '0' = 'OK'                                                                       ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Set Custimization Script Variables ***'
# NOTE: Make sure to update these variables for your environment!!! ***
# Note: Only needed when Onedrive needs to be configured (see below). When using the Marketplace Image including Office this is not required.
$AADTenantID = "458c4725-6f38-4ae7-8aff-204c3d056d9e"

# WINDOWS SECTION

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Start-Sleep -Seconds 10
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack ***'
##Disable Language Pack Cleanup##
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"
##Set Language Pack Content Stores## 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' -OutFile 'c:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Add-WindowsPackage -Online -PackagePath c:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("nl-NL")
Set-WinUserLanguageList $LanguageList -force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack ***'

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/setup.exe' -OutFile 'c:\temp\setup.exe'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Config.xml' -OutFile 'c:\temp\Config.xml'
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\setup.exe /download c:\temp\config.xml'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 ***'
Invoke-Expression -Command 'C:\temp\setup.exe /configure c:\temp\config.xml'
Start-Sleep -Seconds 30
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode ***'
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet ALLUSER=1'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. ***'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force | Out-Null
Start-Sleep -Seconds 45
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/KeePass-2.47.msi' -OutFile 'c:\temp\KeePass-2.47.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\KeePass-2.47.msi /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Notepad++ ***' 
Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.2/npp.7.9.2.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Notepad++ *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip ***'
Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z1900-x64.msi' -OutFile 'c:\temp\7z1900-x64.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\7z1900-x64.msi /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR ***'
Invoke-WebRequest -Uri 'https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=nl' -OutFile 'c:\temp\FirefoxEsrSetup.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\FirefoxEsrSetup.msi MaintenanceService=false /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise ***'
Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=2093437' -OutFile 'c:\temp\MicrosoftEdgeEnterpriseX64.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\MicrosoftEdgeEnterpriseX64.msi /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** START OS CONFIG *** Update the recommended OS configuration ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Automatic Updates ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Automatic Updates *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fEnableTimeZoneRedirection' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense ***'
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense' -Name 'AllowStorageSenseGlobal' -Value '0' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Fix Watson crashes ***'
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name "CorporateWerServer*" | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Fix Watson crashes *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Start Sleep 10 min ***'
Start-Sleep -Seconds 600
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Start Sleep 10 min ***'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\temp' -Recurse | Remove-Item -Recurse -Force | Out-Null
Remove-Item -Path 'C:\temp' -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Start Sleep 5 min ***'
Start-Sleep -Seconds 300
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Start Sleep 5 min ***'

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'