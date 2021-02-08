# Guido's test AIB installer script
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Set Custimization Script Variables ***'
# NOTE: Make sure to update these variables for your environment!!! ***
# Note: Only needed when Onedrive needs to be configured (see below). When using the Marketplace Image including Office this is not required.
$AADTenantID = "458c4725-6f38-4ae7-8aff-204c3d056d9e"

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' `
    -ItemType Directory -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Disable windows update ***'
$reg_path = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
Set-ItemProperty $reg_path -Name NoAutoUpdate -Value 1
Set-ItemProperty $reg_path -Name AUOptions -Value 3
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Disable windows update *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection ***'
$reg_path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
Set-ItemProperty $reg_path -Name SpecialRoamingOverrideAllowed -Value 1
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense ***'
$reg_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense"
if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
Set-ItemProperty $reg_path -Name AllowStorageSenseGlobal -Value 0
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense ***'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Set locale ***'
Set-WinHomeLocation -GeoId 176
Set-TimeZone -Id 'W. Europe Standard Time'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Set locale *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' `
    -OutFile 'C:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Add-WindowsPackage -Online -PackagePath 'C:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Set WinUserLanguageList ***'
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("nl-nl")
Set-WinUserLanguageList $LanguageList -force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Set WinUserLanguageList ***'

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/setup.exe' -OutFile 'c:\temp\setup.exe'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Config.xml' -OutFile 'c:\temp\Config.xml'
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\setup.exe /download c:\temp\config.xml'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 ***'
Invoke-Expression -Command 'C:\temp\setup.exe /configure c:\temp\config.xml'
Start-Sleep -Seconds 30
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

# Note: When using the Marketplace Image for Windows 10 Enterprise Multu Session with Office Onedrive is already installed correctly (for 20H1). 
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL ONEDRIVE *** Uninstall Ondrive per-user mode and Install OneDrive in per-machine mode ***'
Invoke-WebRequest -Uri 'https://aka.ms/OneDriveWVD-Installer' -OutFile 'c:\temp\OneDriveSetup.exe'
New-Item -Path 'HKLM:\Software\Microsoft\OneDrive' -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /uninstall'
New-ItemProperty -Path 'HKLM:\Software\Microsoft\OneDrive' -Name 'AllUsersInstall' -Value '1' -PropertyType DWORD -Force | Out-Null
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\OneDriveSetup.exe /allusers'
Start-Sleep -Seconds 10
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Configure OneDrive to start at sign in for all users. ***'
New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDrive' -Value 'C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background' -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Silently configure user account ***'
$reg_path = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
Set-ItemProperty $reg_path -Name SilentAccountConfig -Value 1
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Silently configure user account *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Redirect and move Windows known folders to OneDrive by running the following command. ***'
$reg_path = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
if (-Not (Test-Path $reg_path)) { New-Item $reg_path -Force }
Set-ItemProperty $reg_path -Name KFMSilentOptIn -Value $AADTenantID
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG ONEDRIVE *** Redirect and move Windows known folders to OneDrive by running the following command. ***'


Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'