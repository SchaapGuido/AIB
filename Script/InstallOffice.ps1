Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

New-Item -Path 'C:\temp' -ItemType Directory -Force

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/setup.exe' -OutFile 'c:\temp\setup.exe'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Config.xml' -OutFile 'c:\temp\Config.xml'

Start-Sleep -Seconds 10

Start-Process -Wait -FilePath C:\temp\setup.exe -ArgumentList "/download c:\temp\config.xml"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 ***'
Start-Process -Wait -FilePath C:\temp\setup.exe -ArgumentList "/configure c:\temp\config.xml"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set Iswvdenvironment key ***'
New-Item -Path HKLM:\SOFTWARE\Microsoft -Name Teams -ErrorAction Continue
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name IsWVDEnvironment -PropertyType DWORD -Value '1' -ErrorAction Continue
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set Iswvdenvironment key *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode ***'
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true' -OutFile 'c:\temp\Teams.msi'
Start-Process -Wait -FilePath C:\temp\Teams.msi -ArgumentList "/quiet /l*v C:\temp\teamsinstall.log ALLUSER=1 ALLUSERS=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. ***'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. *** - Exit Code: ' $LASTEXITCODE

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

Start-Sleep -Seconds 60
