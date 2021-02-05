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
Add-WindowsPackage -Online -PackagePath 'C:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End set locale *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'