Set-Location C:\Install\InstallScript
$computerList = @('vmwvdac0121-0')

# Add registry settings
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\Registry\RegAdjust.cmd' -ComputerList $computerList -EnablePSRemoting

# Install Language Packs
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\LIPContent\LipInstall.cmd' -ComputerList $computerList

# Install Latest Office
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOfficeInstall\DefOffBehaviour.cmd' -ComputerList $computerList
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOfficeInstall\setup.exe' -AppArgs '/configure C:\temp\WVDOfficeInstall\config.xml' -ComputerList $computerList

# Install Teams
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDTeams\installRegKey.cmd' -ComputerList $computerList
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDTeams\Teams_windows_x64.msi' -AppArgs '/l*v C:\Temp\TeamsInstall.log ALLUSERS=1 /quiet' -ComputerList $computerList

# Install OneDrive
# Prefer not to use this, instead use image with Office 365 apps integrated
#.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOneDrive\preinstall.cmd' -ComputerList $computerList
#.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOneDrive\OneDriveSetup.exe' -AppArgs '/allusers' -ComputerList $computerList
#.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOneDrive\postinstall.cmd' -ComputerList $computerList

# Install Adobe Acrobat Reader
# Get updates here: https://get2.adobe.com/reader/enterprise/ or https://www.mozilla.org/en-US/firefox/all/#product-desktop-release
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\AdobeReader\AcroRead.msi' -AppArgs '/quiet' -ComputerList $computerList

# Install Mozilla FireFox
# Get it here: https://support.mozilla.org/en-US/kb/deploy-firefox-msi-installers
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\FireFox\FirefoxSetup7802.msi' -AppArgs 'DesktopShortcut=true MaintenanceService=false /quiet' -ComputerList $computerList

# Install Microsoft Edge
# Get it here: https://www.microsoft.com/en-us/edge/business/download
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\Edge\MicrosoftEdgeEnterpriseX64.msi' -AppArgs '/quiet' -ComputerList $computerList

# Install KeePass
# Get it here: https://sourceforge.net/projects/keepass/files/KeePass%202.x/
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\Keepass\KeePass-2.47.msi' -AppArgs '/quiet' -ComputerList $computerList

# Install Notepad++
# Get it here: https://notepad-plus-plus.org/downloads/
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\NPP\npp.7.9.1.Installer.x64.exe' -AppArgs '/S' -ComputerList $computerList

# Install 7-zip
# Get it here: https://www.7-zip.org/download.html
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\7-zip\7z1900-x64.msi' -AppArgs '/quiet' -ComputerList $computerList

<#
IrfanView

get it here  : https://www.irfanview.com/64bit.htm
Installer options
folder       : destination folder; if not indicated: old IrfanView folder is used, if not found, the "Program Files" folder is used
desktop      : create desktop shortcut; 0 = no, 1 = yes (default: 0)
thumbs       : create desktop shortcut for thumbnails; 0 = no, 1 = yes (default: 0)
group        : create group in Start Menu; 0 = no, 1 = yes (default: 0)
allusers     : desktop/group links are for all users; 0 = current user, 1 = all users (used ONLY IF /desktop=1 and/or /group=1 are set)
assoc        : if used, set file associations; 0 = none, 1 = images only, 2 = select all (default: 0)
assocallusers: if used, set associations for all users (Windows XP only)
ini          : if used, set custom INI file folder (system environment variables are allowed)
#>
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\IrfanView\iview456_x64_setup.exe' -AppArgs '/silent /group=1 /assoc=1 /allusers=1' -ComputerList $computerList

# Install IrfanView Plugins
# get it here: https://www.irfanview.com/64bit.htm
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\IrfanView\iview456_plugins_x64_setup.exe' -AppArgs '/silent /allusers=1' -ComputerList $computerList

# Install Microsoft To Do
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\MSToDo\MSToDoInstall.cmd' -ComputerList $computerList

# Install FSLogix software
# Get it here: https://docs.microsoft.com/en-us/fslogix/install-ht
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\FSLogix\FSLogixAppsSetup.exe' -AppArgs '/install /quiet /norestart' -ComputerList $computerList

# Remove default desktop icons
.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\Registry\ErasePublicUserDesktopItems.cmd' -ComputerList $computerList

# Run the Virtual Desktop Optimization Tool
#.\InstallSoftwareRemotely.ps1 -AppPath 'C:\Install\WVDOptimizeTool\Win10_VirtualDesktop_Optimize.ps1' -AppArgs '-WindowsVersion 2004 -Verbose' -ComputerList $computerList