# Guido's test AIB installer script

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin set locale ***'
Set-WinHomeLocation -GeoId 176
Set-TimeZone -Id 'W. Europe Standard Time'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End set locale *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Begin set locale ***'
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
DISM.exe /Online /Add-Package /PackagePath:c:\temp\LIPContent\Microsoft-Windows-Client-Language-Pack_x64_nl-nl.cab
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** End set locale *** - Exit Code: ' $LASTEXITCODE


Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'   