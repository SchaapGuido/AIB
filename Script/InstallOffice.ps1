
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/setup.exe' -OutFile 'c:\temp\setup.exe'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Config.xml' -OutFile 'c:\temp\Config.xml'

Start-Sleep -Seconds 10

Start-Process -Wait -FilePath C:\temp\setup.exe -ArgumentList "/download c:\temp\config.xml"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 ***'
Start-Process -Wait -FilePath C:\temp\setup.exe -ArgumentList "/configure c:\temp\config.xml"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode ***'
Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true' -OutFile 'c:\temp\Teams.msi'
Start-Process -Wait -FilePath C:\temp\Teams.msi -ArgumentList "/quiet /l*v C:\temp\teamsinstall.log ALLUSER=1 ALLUSERS=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Teams in Machine mode *** - Exit Code: ' $LASTEXITCODE
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. ***'
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Configure Teams to start at sign in for all users. *** - Exit Code: ' $LASTEXITCODE