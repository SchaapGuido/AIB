<#  
.SYNOPSIS  
    Custimization script for Azure Image Builder including Microsoft recommneded configuration to be included in a Windows 10 ms Master Image excluding Office
.
.DESCRIPTION  
    Customization script to build a WVD Windows 10ms image
    This script configures the Microsoft recommended configuration for a Win10ms image:
        Article:    Prepare and customize a master VHD image 
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image 
        Article: Set up MSIX app attach with the Azure portal
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/app-attach-azure-portal
.
NOTES  
    File Name  : Win10ms.ps1
    Author     : Roel Schellens
    Version    : v0.0.2
    Date       : 20-Jan-2021
.
.EXAMPLE
    This script can be used in confuction with an 
.
.DISCLAIMER
    1 - All configuration settings in this script need to be validated and tested in your own environment.
    2 - Ensure to confirm the documentation online has not been updated and therefor might include different settings
    3 - Where possible also the use of Group Policies can be used.
    4 - The below script uses the Write-Host command to allow you to better troubleshoot the activity from within the Packer logs.
    5 - To get more verbose logging of the script remove the | Out-Null at the end of the PowerShell command
#>

Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Script: Win10ms.ps1                                                                        ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Exit Code '0' = 'OK'                                                                       ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Set Custimization Script Variables ***'
# NOTE: Make sure to update these variables for your environment!!! ***
# Note: Only needed when Onedrive needs to be configured (see below). When using the Marketplace Image including Office this is not required.
# $AADTenantID = "<your-AzureAdTenantId>"

# WINDOWS SECTION
Invoke-Expression -Command 'C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown'
