# Variabelen


# Maak verbinding met Azure
Connect-AzAccount
Select-AzSubscription "DHD Production Subscription (EA)"

####################################
#                                  #
# Registreer de benodigde features #
#                                  #
####################################

# Installeer overige benodigde modules

Write-Host "Installeren van de benodigde modules..."

Install-Module -Name az.accounts -MinimumVersion 2.2.4
Import-module -Name az.accounts

Install-Module -Name Az
Import-Module -Name Az

Install-Module -Name Az.ImageBuilder
Import-Module -Name Az.ImageBuilder

Install-Module -Name Az.ManagedServiceIdentity
Import-Module -Name Az.ManagedServiceIdentity

# registreer de VirtualMachineTemplatePreview feature
#Register-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview

Write-Host "Registreren provider features en resource providers"

# Check de status van de feature registratie.
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages -FeatureName VirtualMachineTemplatePreview |
    Where-Object RegistrationState -ne Registered |
    Register-AzProviderFeature

Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages | 
    Where-Object RegistrationState -ne Registered | 
    Register-AzResourceProvider

######################################
#                                    #
# Registreer de benodigde variabelen #
#                                    #
######################################

$imageResourceGroup = 'rg-wvd-ont'
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')
$location = 'WestEurope'
$imageTemplateName = 'WvdTemplateAIB' + $timeInt
$runOutputName = 'WvdDistResults'
$subscriptionID = (Get-AzContext).Subscription.Id

# Create a resource group
Write-Host "Resource groep aanmaken"
New-AzResourceGroup -Name $imageResourceGroup `
  -Location $location `
  -Tag @{"DHD-Application"="Windows Virtual Desktop (WVD)"; "DHD-Cluster"="Infra basis"; "DHD-Contact"="Guido Schaap;Eduard de Vries"; "DHD-Environment"="Production"; "DHD-Owner"="IT-Infra"}

##################################################
#                                                #
# Maak een user identity en geef de correcte rol #
#                                                #
##################################################

Write-Host "Nieuwe user identity aanmaken"

# Create variables for the role definition and identity names.
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$identityName = "AibIdentity" + $timeInt

# Create a user identity.
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

# Store the identity resource and principal IDs in variables.
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

############################################################################
#                                                                          #
# Geef de user identity voldoende rechten voor het distribueren van images #
#                                                                          #
############################################################################

Write-Host "User identity voldoende rechten geven"

# Download .json config file and modify it based on the settings defined in this article.
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
$myRoleImageCreationPath = "$env:TEMP\myRoleImageCreation.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

# Create the role definition.
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

Write-Host "Waiting for creation of role definition"
Start-Sleep -Seconds 60

# Grant the role definition to the image builder service principal.
$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams

##################################################
#                                                #
# Maak een shared gallery aan                    #
#                                                #
##################################################

# Create the gallery.
$myGalleryName = 'TestGallery'
$imageDefName = 'WindowsVirtualDesktop'

New-AzGallery -ResourceGroupName $imageResourceGroup -Name $myGalleryName -Location $location

Write-Host "Nieuwe shared gallery aanmaken, stap 2"

# Create a gallery definition.
$GalleryParams = @{
  GalleryName = $myGalleryName
  ResourceGroupName = $imageResourceGroup
  Location = $location
  Name = $imageDefName
  OsState = 'generalized'
  OsType = 'Windows'
  Publisher = 'DHD'
  Offer = 'office-365'
  Sku = '20h1-evd-o365pp'
}
New-AzGalleryImageDefinition @GalleryParams

##################################################
#                                                #
# Maak een nieuw image                           #
#                                                #
##################################################

Write-Host "Image builder source object aanmaken"

# Maak een Azure image builder source object.
$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'office-365'
  Sku = '20h1-evd-o365pp'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

Write-Host "Image builder distribution object aanmaken"

# Maak een Azure image builder distributor object.
$disObjParams = @{
  SharedImageDistributor = $true
  ArtifactTag = @{tag='dis-share'}
  GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
  ReplicationRegion = $location
  RunOutputName = $runOutputName
  ExcludeFromLatest = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

Write-Host "Image builder customization object aanmaken"

# https://raw.githubusercontent.com/Everink/AzureImageBuilder/master/Scripts/AzureImageBuilder.ps1
# https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v2.ps1
# https://raw.githubusercontent.com/RoelDU/WVDImaging/master/Win10ms_O365.ps1

# Create an Azure image builder customization object
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $false
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/azureimagebuilder.ps1"
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Image builder template aanmaken"

# Maak een Azure image builder template.
$ImgTemplateParams = @{
  ImageTemplateName = $imageTemplateName
  ResourceGroupName = $imageResourceGroup
  Source = $srcPlatform
  Distribute = $disSharedImg
  Customize = $Customizer
  Location = $location
  UserAssignedIdentityId = $identityNameResourceId
}
New-AzImageBuilderTemplate @ImgTemplateParams

Write-Host "Aanmaken image builder source object controleren"

# To determine if the template creation process was successful, you can use the following example.
Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup | Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState

# Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

##################################################
#                                                #
# Start de build van het nieuwe image            #
#                                                #
##################################################

Read-Host "Druk op ENTER als het image template succesvol is aangemaakt om het image aanmaken, druk op CTRL + C om het aanmaken af te breken"

# Submit the image configuration to the VM image builder service
# Dit kan lang duren, meestal niet langer dan een uur
Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -AsJob

Write-Host "Waiting for start of building"
Start-Sleep -Seconds 60

do
{
    Start-Sleep -Seconds 30
    $result = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
    Write-Host "Status: $($result.LastRunStatusRunState), $($result.LastRunStatusRunSubState), $(Get-Date)"    
}
until ($result.LastRunStatusRunState -ne "Running")

##################################################
#                                                #
# En nu alles weer opruimen                      #
#                                                #
##################################################

# Verwijder het image builder template
#Remove-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName

# Verwijder de resourcegroup
#Remove-AzResourceGroup -Name $imageResourceGroup