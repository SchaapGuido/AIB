Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip ***'
Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z1900-x64.msi' -OutFile 'c:\temp\7z1900-x64.msi'
Invoke-Expression -Command 'msiexec /i c:\temp\7z1900-x64.msi /quiet'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip *** - Exit Code: ' $LASTEXITCODE