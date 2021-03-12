
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool ***'
Invoke-WebRequest -uri 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/master.zip' -OutFile 'c:\temp\wvdoptool.zip'
Expand-Archive -Path 'c:\temp\wvdoptool.zip' -DestinationPath 'C:\Temp'
Set-Location 'C:\Temp\Virtual-Desktop-Optimization-Tool-master'
.\Win10_VirtualDesktop_Optimize.ps1 -WindowsVersion 2009 -verbose
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60
