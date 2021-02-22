Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download language pack files ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' -OutFile 'c:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft-Windows-LanguageFeatures-Basic-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' -OutFile 'c:\temp\Microsoft-Windows-LanguageFeatures-Basic-nl-nl-Package~31bf3856ad364e35~amd64~~.cab'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft-Windows-LanguageFeatures-Handwriting-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' -OutFile 'c:\temp\Microsoft-Windows-LanguageFeatures-Handwriting-nl-nl-Package~31bf3856ad364e35~amd64~~.cab'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft-Windows-LanguageFeatures-OCR-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' -OutFile 'c:\temp\Microsoft-Windows-LanguageFeatures-OCR-nl-nl-Package~31bf3856ad364e35~amd64~~.cab'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft-Windows-LanguageFeatures-TextToSpeech-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' -OutFile 'c:\temp\Microsoft-Windows-LanguageFeatures-TextToSpeech-nl-nl-Package~31bf3856ad364e35~amd64~~.cab'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Download language pack files ***'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack ***'
##Disable Language Pack Cleanup##
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup" | Out-Null
##Set Language Pack Content Stores## 
Start-Sleep -Seconds 10
Add-WindowsPackage -Online -PackagePath 'c:\temp\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab' | Out-Null
Add-WindowsPackage -Online -PackagePath 'c:\temp\Microsoft-Windows-LanguageFeatures-Basic-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' | Out-Null
Add-WindowsPackage -Online -PackagePath 'c:\temp\Microsoft-Windows-LanguageFeatures-Handwriting-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' | Out-Null
Add-WindowsPackage -Online -PackagePath 'c:\temp\Microsoft-Windows-LanguageFeatures-OCR-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' | Out-Null
Add-WindowsPackage -Online -PackagePath 'c:\temp\Microsoft-Windows-LanguageFeatures-TextToSpeech-nl-nl-Package~31bf3856ad364e35~amd64~~.cab' | Out-Null
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("nl-NL")
Set-WinUserLanguageList $LanguageList -force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Install language pack *** - Exit Code: ' $LASTEXITCODE