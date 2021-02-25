Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Adobe Acrobat Reader ***'
Invoke-WebRequest -Uri 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/1900820071/AcroRdrDC1900820071_nl_NL.exe' -OutFile 'c:\temp\AcroRdrDC1900820071_nl_NL.exe'
Start-Process -Wait 'c:\temp\AcroRdrDC1900820071_nl_NL.exe' -ArgumentList "/sAll /rs"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Adobe Acrobat Reader *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/KeePass-2.47.msi' -OutFile 'c:\temp\KeePass-2.47.msi'
Start-Process -Wait -FilePath c:\temp\KeePass-2.47.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Notepad++ ***' 
Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.2/npp.7.9.2.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Start-Process -Wait -FilePath c:\temp\notepadplusplus.exe -ArgumentList "/S"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Install Notepad++ *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip ***'
Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z1900-x64.msi' -OutFile 'c:\temp\7z1900-x64.msi'
Start-Process -Wait -FilePath c:\temp\7z1900-x64.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR ***'
Invoke-WebRequest -Uri 'https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=nl' -OutFile 'c:\temp\FirefoxEsrSetup.msi'
Start-Process -Wait -FilePath c:\temp\FirefoxEsrSetup.msi -ArgumentList "MaintenanceService=false /quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise ***'
Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=2093437' -OutFile 'c:\temp\MicrosoftEdgeEnterpriseX64.msi'
Start-Process -Wait -FilePath c:\temp\MicrosoftEdgeEnterpriseX64.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/iview457_x64_setup.exe' -OutFile 'c:\temp\iview457_x64_setup.exe'
Start-Process -Wait -FilePath c:\temp\iview457_x64_setup.exe -ArgumentList "/silent /group=1 /assoc=1 /allusers=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView Plugins ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/iview457_plugins_x64_setup.exe' -OutFile 'c:\temp\iview457_plugins_x64_setup.exe'
Start-Process -Wait -FilePath c:\temp\iview457_plugins_x64_setup.exe -ArgumentList "/silent /allusers=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView Plugins *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Start-Process -FilePath C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe -ArgumentList "/install /quiet /norestart"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60