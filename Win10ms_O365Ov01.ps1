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
# $AADTenantID = "<your-AzureAdTenantId>"

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

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** START OS CONFIG *** Update the recommended OS configuration ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Automatic Updates ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Automatic Updates *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Specify Start layout for Windows 10 PCs (optional) ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SpecialRoamingOverrideAllowed' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Specify Start layout for Windows 10 PCs (optional) *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fEnableTimeZoneRedirection' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense ***'
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense' -Name 'AllowStorageSenseGlobal' -Value '0' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense *** - Exit Code: ' $LASTEXITCODE

# Note: Remove if not required!
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** For feedback hub collection of telemetry data on Windows 10 Enterprise multi-session ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value '3' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** For feedback hub collection of telemetry data on Windows 10 Enterprise multi-session *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Fix Watson crashes ***'
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' -Name "CorporateWerServer*" | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Fix Watson crashes *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Temp fix for 20H1 SXS Bug ***'
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs' -Name 'fReverseConnectMode' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Temp fix for 20H1 SXS Bug *** - Exit Code: ' $LASTEXITCODE

# Note: Remove if not required!
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Disable Store auto update ***'
New-Item -Path 'HKLM:\Software\Policies\Microsoft\WindowsStore' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\WindowsStore' -Name 'AutoDownload' -Value '0' -PropertyType DWORD -Force | Out-Null
Invoke-Expression -Command 'Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable'
Invoke-Expression -Command 'Schtasks /Change /Tn "\Microsoft\Windows\WindowsUpdate\Scheduled Start" /Disable'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Disable Store auto update *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Disable Content Delivery auto download apps that they want to promote to users'
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Debug' -Name 'ContentDeliveryAllowedOverride' -Value 0x2 -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Disable Content Delivery auto download apps that they want to promote to users *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Mount default registry hive ***'
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT
Start-Sleep -Seconds 5
New-ItemProperty -Path 'HKLM:\DEFAULT\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'PreInstalledAppsEnabled' -Value '0' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET MSIX APPATTACH REGKEYS *** Mount default registry hive *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** WE LEAVE DEFAULT USER PROFILE OPEN FOR NEXT SECTION! ***'
# Note: DO NOT PLACE ANYTHING BETWEEN MSIX and OFFICE SECTION As Default User hive is still open!

# OFFICE365 SECTION

# Note: For Settings below it is also recommended to set user settings through GPO's
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** START OFFICE CONFIG *** Config the recommended Office configuration ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Default registry hive is still loaded!***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE *** Set InsiderslabBehavior ***'
New-Item -Path 'HKLM:\DEFAULT\SOFTWARE\Policies\Microsoft\office\16.0\common' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\DEFAULT\SOFTWARE\Policies\Microsoft\office\16.0\common' -Name 'InsiderSlabBehavior' -Value '2' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE *** Set InsiderslabBehavior *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE *** Set Outlooks Cached Exchange Mode behavior ***'
New-ItemProperty -Path 'HKLM:\DEFAULT\software\policies\microsoft\office\16.0\outlook\cached mode' -Name 'enable' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\DEFAULT\software\policies\microsoft\office\16.0\outlook\cached mode' -Name 'syncwindowsetting' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\DEFAULT\software\policies\microsoft\office\16.0\outlook\cached mode' -Name 'CalendarSyncWindowSetting' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\DEFAULT\software\policies\microsoft\office\16.0\outlook\cached mode' -Name 'CalendarSyncWindowSettingMonths' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE *** Set Outlooks Cached Exchange Mode behavior *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Un-mount default registry hive. Still Open from MSIX secioion ***'
[GC]::Collect()
& REG UNLOAD HKLM\DEFAULT
Start-Sleep -Seconds 5
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Un-mount default registry hive. Still Open from MSIX secioion *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Set Office Update Notifiations behavior ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name 'hideupdatenotifications' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name 'hideenabledisableupdates' -Value '1' -PropertyType DWORD -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Set Office Update Notifiations behavior *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode ***'
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1 ALLUSERS=1'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. ***'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Start-Sleep -Seconds 45
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\temp' -Recurse | Remove-Item -Recurse -Force | Out-Null
Remove-Item -Path 'C:\temp' -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'   