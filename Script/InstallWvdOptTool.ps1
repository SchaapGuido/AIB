Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool ***'
Write-Host '* Downloading...'
Invoke-WebRequest -uri 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/master.zip' -OutFile 'c:\temp\wvdoptool.zip'
Write-Host '* Extracting...'
Expand-Archive -Path 'c:\temp\wvdoptool.zip' -DestinationPath 'C:\Temp'
Write-Host '* Switching to temp directory'
Set-Location 'C:\Temp\Virtual-Desktop-Optimization-Tool-master'
Write-Host '* Starting tool..'
.\Win10_VirtualDesktop_Optimize.ps1 -WindowsVersion 2009 -verbose
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool *** - Exit Code: ' $LASTEXITCODE