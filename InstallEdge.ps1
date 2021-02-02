Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise ***'
Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=2093437' -OutFile 'c:\temp\MicrosoftEdgeEnterpriseX64.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\MicrosoftEdgeEnterpriseX64.msi /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise *** - Exit Code: ' $LASTEXITCODE