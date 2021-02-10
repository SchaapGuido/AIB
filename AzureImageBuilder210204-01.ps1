# General settings
$imageResourceGroup = 'RG-WVD-AIB-ONT'
$location = 'WestEurope'
$subscriptionID = (Get-AzContext).Subscription.Id

# ImageBuilderTemplate settings
$imageBuilderTemplateName = 'IBT-WVD-AIB-ONT' + $timeInt
$runOutputName = 'RON-WVD-AIB-ONT'

# Role definition settings
$imageRoleDefName = "RD-WVD-AIB-ONT"
$identityName = "UAI-WVD-AIB-ONT"

# Gallery settings
$myGalleryName = 'AIBGallery'
$imageDefName = 'GID-WVD-AIB-ONT' + $timeInt

# GitHub settings
$gitParentPath = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/"

# timestamp
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')

# Maak verbinding met Azure
Connect-AzAccount
Select-AzSubscription "DHD Production Subscription (EA)"

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

# Check de status van de feature registratie.
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages `
  -FeatureName VirtualMachineTemplatePreview |
    Where-Object RegistrationState -ne Registered |
    Register-AzProviderFeature

Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages | 
    Where-Object RegistrationState -ne Registered | 
    Register-AzResourceProvider

# Create resource group if needed
Get-AzResourceGroup -Name $imageResourceGroup `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent)
{
  New-AzResourceGroup -Name $imageResourceGroup `
  -Location $location `
  -Tag @{"DHD-Application"="Windows Virtual Desktop (WVD)"; "DHD-Cluster"="Infra basis"; "DHD-Contact"="Guido Schaap;Eduard de Vries"; "DHD-Environment"="Production"; "DHD-Owner"="IT-Infra"}
}

Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup `
  -Name $identityName `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent) {
  New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup `
    -Name $identityName
}

# Store the identity resource and principal IDs in variables.
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

# Download .json config file and modify it based on the settings defined in this article.
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
$myRoleImageCreationPath = "$env:TEMP\myRoleImageCreation.json"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

Sleep 10

$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

# Create the role definition.
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

do
{
    $result = Get-AzRoleDefinition -Name $imageRoleDefName
}
until ($result)

# Grant the role definition to the image builder service principal.
$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams -Verbose

# Create the gallery.
Get-AzGallery -ResourceGroupName $imageResourceGroup `
  -Name $myGalleryName `
  -Location $location `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue

if ($notPresent) {
  New-AzGallery -ResourceGroupName $imageResourceGroup -Name $myGalleryName -Location $location
}

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
Get-AzGalleryImageDefinition @GalleryParams `
-ErrorVariable notPresent `
-ErrorAction SilentlyContinue
if ($notPresent) {
  New-AzGalleryImageDefinition @GalleryParams
} else {
  Remove-AzGalleryImageDefinition @GalleryParams -Force
  New-AzGalleryImageDefinition @GalleryParams
}

# Create Azure image builder source object.
$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'office-365'
  Sku = '20h1-evd-o365pp'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

# Create Azure image builder distributor object.
$disObjParams = @{
  SharedImageDistributor = $true
  ArtifactTag = @{tag='dis-share'}
  GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
  ReplicationRegion = $location
  RunOutputName = $runOutputName
  ExcludeFromLatest = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

# Create an Azure image builder customization object
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_1.ps1"
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

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
Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName `
  -ResourceGroupName $imageResourceGroup `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent) {
  New-AzImageBuilderTemplate @ImgTemplateParams
} else {
  Remove-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName
  New-AzImageBuilderTemplate @ImgTemplateParams
}

$imageBuilderTemplateResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

<#


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
sleep -Seconds 60

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

<#

# Stop de image builder
Stop-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -Verbose

# Verwijder het image builder template
Remove-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -Verbose

# Verwijder de resourcegroup
Remove-AzResourceGroup -Name $imageResourceGroup -Verbose

#>