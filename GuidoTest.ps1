# Guido's test AIB installer script

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' `
    -ItemType Directory -Force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin set locale ***'
Set-WinHomeLocation -GeoId 176
Set-TimeZone -Id 'W. Europe Standard Time'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End set locale *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin set locale ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' `
    -OutFile 'C:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Invoke-Expression -Command 'DISM.exe /Online /Add-Package /PackagePath:c:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End set locale *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin download latest Office 365 ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/setup.exe' `
    -OutFile 'c:\temp\setup.exe'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Config.xml' `
    -OutFile 'c:\temp\Config.xml'
Start-Sleep -Seconds 10
Invoke-Expression -Command 'C:\temp\setup.exe /download c:\temp\config.xml'
Start-Sleep -Seconds 30
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End download latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin install latest Office 365 ***'
Invoke-Expression -Command 'C:\temp\setup.exe /configure c:\temp\config.xml'
Start-Sleep -Seconds 30
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End Install latest Office 365 *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'   