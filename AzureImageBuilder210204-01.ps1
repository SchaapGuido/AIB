# General settings
$imageResourceGroup = 'RG-WVD-AIB-ONT'
$location = 'WestEurope'
$subscriptionID = (Get-AzContext).Subscription.Id
$imageBuilderTemplateName = 'IBT-WVD-AIB-ONT' + $timeInt
$runOutputName = 'RON-WVD-AIB-ONT'
$imageRoleDefName = "RD-WVD-AIB-ONT"
$identityName = "UAI-WVD-AIB-ONT"
$myGalleryName = 'AIBGallery'
$imageDefName = 'GID-WVD-AIB-ONT' + $timeInt
$gitParentPath = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/"
$roleDefinitionTemplate = "aibRoleImageCreation.json"

function Write-Logline ($logMessage)
{
  $timeStamp = get-date -UFormat %H%M%S-%d%m%y
  $logLine = $timeStamp + " - " + $logMessage
  Write-Output $logLine
}

Write-Logline -logMessage "Azure image builder script started"

# timestamp
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')
<#
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
#>

Write-Logline -logMessage "Checking status of provider features"
Get-AzProviderFeature -ProviderNamespace Microsoft.VirtualMachineImages `
  -FeatureName VirtualMachineTemplatePreview |
    Where-Object RegistrationState -ne Registered |
    Register-AzProviderFeature

Write-Logline -logMessage "Checking status of resource providers"
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages | 
    Where-Object RegistrationState -ne Registered | 
    Register-AzResourceProvider

Write-Logline -logMessage "Checking resource group"
Get-AzResourceGroup -Name $imageResourceGroup `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent)
{
  New-AzResourceGroup -Name $imageResourceGroup `
  -Location $location `
  -Tag @{"DHD-Application"="Windows Virtual Desktop (WVD)"; "DHD-Cluster"="Infra basis"; "DHD-Contact"="Guido Schaap;Eduard de Vries"; "DHD-Environment"="Production"; "DHD-Owner"="IT-Infra"}
}

Write-Logline -logMessage "Checking status of user assigned identity"
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

Write-Logline -logMessage "Downloading json for role definition"
# Download .json config file and modify it based on the settings defined in this article.
$roleImageCreationUrl = $gitParentPath + $roleDefinitionTemplate
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Content = Invoke-WebRequest -Uri $roleImageCreationUrl -UseBasicParsing
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

Write-Logline -logMessage "Checking role definition"
Get-AzRoleDefinition -Name $imageRoleDefName `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent) {
  New-AzRoleDefinition -InputFile $myRoleImageCreationPath
} else {
  Remove-AzRoleDefinition -Name $imageRoleDefName `
    -Force
    New-AzRoleDefinition -InputFile $myRoleImageCreationPath
}

Write-Logline -logMessage "Grant the role definition to the image builder service principal"
$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams

Write-Logline -logMessage "Create the gallery"
Get-AzGallery -ResourceGroupName $imageResourceGroup `
  -Name $myGalleryName `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue

if ($notPresent) {
  New-AzGallery -ResourceGroupName $imageResourceGroup -Name $myGalleryName -Location $location
}

Write-Logline -logMessage "Create a gallery definition"
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
Get-AzGalleryImageDefinition -Name $imageDefName `
  -ResourceGroupName $imageResourceGroup `
  -GalleryName $myGalleryName `
  -ErrorVariable notPresent `
  -ErrorAction SilentlyContinue
if ($notPresent) {
  New-AzGalleryImageDefinition @GalleryParams
} else {
  Remove-AzGalleryImageDefinition -Name $imageDefName `
  -ResourceGroupName $imageResourceGroup `
  -GalleryName $myGalleryName `
  -Force
  New-AzGalleryImageDefinition @GalleryParams
}

Write-Logline -logMessage "Create Azure image builder source object"
$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'office-365'
  Sku = '20h1-evd-o365pp'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

Write-Logline -logMessage "Create Azure image builder distributor object"
$disObjParams = @{
  SharedImageDistributor = $true
  ArtifactTag = @{tag='dis-share'}
  GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
  ReplicationRegion = $location
  RunOutputName = $runOutputName
  ExcludeFromLatest = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

Write-Logline -logMessage "Create an Azure image builder customization object"
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_2.ps1"
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Logline -logMessage "Create Azure image builder template"
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

$builderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

if ($builderResult.ProvisioningState -eq "Succeeded") {
  Write-Logline -logMessage "Create Azure image builder image"
  Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName
}
else {
  Write-Warning "Builder result is $($builderResult.ProvisioningState)"
}

do
{
    Start-Sleep -Seconds 300
    $result = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
    $logMessage = "Status: $($result.LastRunStatusRunState), $($result.LastRunStatusRunSubState)"
    Write-Logline -logMessage $logMessage
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