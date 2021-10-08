Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Adobe Acrobat Reader ***'
Invoke-WebRequest -Uri 'https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/1900820071/AcroRdrDC1900820071_nl_NL.exe' -OutFile 'c:\temp\AcroRdrDC1900820071_nl_NL.exe'
Start-Process -Wait 'c:\temp\AcroRdrDC1900820071_nl_NL.exe' -ArgumentList "/sAll /rs"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Adobe Acrobat Reader *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/KeePass-2.47.msi' -OutFile 'c:\temp\KeePass-2.47.msi'
Start-Process -Wait -FilePath c:\temp\KeePass-2.47.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install KeePass *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Notepad++ ***' 
Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.9.2/npp.7.9.2.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Start-Process -Wait -FilePath c:\temp\notepadplusplus.exe -ArgumentList "/S"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG TEAMS *** Install Notepad++ *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip ***'
Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z1900-x64.msi' -OutFile 'c:\temp\7z1900-x64.msi'
Start-Process -Wait -FilePath c:\temp\7z1900-x64.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install 7-zip *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR ***'
Invoke-WebRequest -Uri 'https://download.mozilla.org/?product=firefox-esr-msi-latest-ssl&os=win64&lang=nl' -OutFile 'c:\temp\FirefoxEsrSetup.msi'
Start-Process -Wait -FilePath c:\temp\FirefoxEsrSetup.msi -ArgumentList "MaintenanceService=false /quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Mozilla Firefox ESR *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise ***'
Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=2093437' -OutFile 'c:\temp\MicrosoftEdgeEnterpriseX64.msi'
Start-Process -Wait -FilePath c:\temp\MicrosoftEdgeEnterpriseX64.msi -ArgumentList "/quiet"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft Edge Enterprise *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/iview457_x64_setup.exe' -OutFile 'c:\temp\iview457_x64_setup.exe'
Start-Process -Wait -FilePath c:\temp\iview457_x64_setup.exe -ArgumentList "/silent /group=1 /assoc=1 /allusers=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView Plugins ***' 
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/iview457_plugins_x64_setup.exe' -OutFile 'c:\temp\iview457_plugins_x64_setup.exe'
Start-Process -Wait -FilePath c:\temp\iview457_plugins_x64_setup.exe -ArgumentList "/silent /allusers=1"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install IrfanView Plugins *** - Exit Code: ' $LASTEXITCODE

<#
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft To Do Provisioning App ***'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.VCLibs.140.00_14.0.29231.0_x64__8wekyb3d8bbwe.Appx' -OutFile 'c:\temp\Microsoft.VCLibs.140.00_14.0.29231.0_x64__8wekyb3d8bbwe.Appx'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx' -OutFile 'c:\temp\Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx' -OutFile 'c:\temp\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx' -OutFile 'c:\temp\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.Todos_2.41.4902.0_neutral___8wekyb3d8bbwe.AppxBundle' -OutFile 'c:\temp\Microsoft.Todos_2.41.4902.0_neutral___8wekyb3d8bbwe.AppxBundle'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SchaapGuido/AIB/main/Installers/Microsoft.Todos_8wekyb3d8bbwe_b7add246-4cf8-3e59-4d3e-18da8ae3c88d.xml' -OutFile 'c:\temp\Microsoft.Todos_8wekyb3d8bbwe_b7add246-4cf8-3e59-4d3e-18da8ae3c88d.xml'
$depPackages = ('C:\Temp\Microsoft.VCLibs.140.00_14.0.29231.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx')
$packagePath = 'C:\Temp\Microsoft.Todos_2.41.4902.0_neutral___8wekyb3d8bbwe.AppxBundle'
$licensePath = 'C:\Temp\Microsoft.Todos_8wekyb3d8bbwe_b7add246-4cf8-3e59-4d3e-18da8ae3c88d.xml'
Add-AppxProvisionedPackage -Online -PackagePath $packagePath -DependencyPackagePath $depPackages -LicensePath $licensePath
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Microsoft To Do Provisioning App *** - Exit Code: ' $LASTEXITCODE

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool ***'
Write-Host '* Downloading...'
Invoke-WebRequest -uri 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/master.zip' -OutFile 'c:\temp\wvdoptool.zip'
Write-Host '* Extracting...'
Expand-Archive -Path 'c:\temp\wvdoptool.zip' -DestinationPath 'C:\Temp'
Write-Host '* Switching to temp directory'
Set-Location 'C:\Temp\Virtual-Desktop-Optimization-Tool-master'
Write-Host '* Starting tool..'
.\Win10_VirtualDesktop_Optimize.ps1 -WindowsVersion 2009 -verbose -Optimizations 'WindowsMediaPlayer','AppxPackages','ScheduledTasks','DefaultUserSettings','Autologgers','Services','LGPO','DiskCleanup'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Wvd Optimization Tool *** - Exit Code: ' $LASTEXITCODE
#>

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Start-Process -Wait -FilePath C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe -ArgumentList "/install /quiet /norestart"
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60
