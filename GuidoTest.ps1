# Guido's test AIB installer script

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install Notepad++ ***'
Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.2/npp.7.9.2.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Install Notepad++ *** - Exit Code: ' $LASTEXITCODE

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

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'   