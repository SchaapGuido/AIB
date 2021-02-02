Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView ***'
Invoke-WebRequest -Uri 'https://www.irfanview.info/files/iview457_setup.exe' -OutFile 'c:\temp\iview457_setup.exe'
Invoke-WebRequest -Uri 'https://www.irfanview.info/files/iview457_plugins_setup.exe' -OutFile 'c:\temp\iview457_plugins_setup.exe'
Start-Sleep 10
Invoke-Expression -Command 'c:\temp\iview457_setup.exe /silent /group=1 /assoc=1 /allusers=1'
Start-Sleep 10
Invoke-Expression -Command 'c:\temp\iview457_plugins_setup.exe /silent /allusers=1'
Start-Sleep 10
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView *** - Exit Code: ' $LASTEXITCODE