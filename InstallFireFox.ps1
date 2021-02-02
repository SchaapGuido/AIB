Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR ***'
Invoke-WebRequest -Uri 'https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=nl' -OutFile 'c:\temp\FirefoxEsrSetup.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\FirefoxEsrSetup.msi MaintenanceService=false /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR *** - Exit Code: ' $LASTEXITCODE