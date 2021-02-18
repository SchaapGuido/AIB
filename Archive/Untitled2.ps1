# Destination image resource group name
$imageResourceGroup = 'rg-wvd-ont'

# Azure region
$location = 'Westeurope'

# Name of the image to be created
$imageTemplateName = 'WVD-Images'

# Distribution properties of the managed image upon completion
$runOutputName = 'myDistResults'

# Your Azure Subscription ID
$subscriptionID = (Get-AzContext).Subscription.Id
Write-Output $subscriptionID

$imageRoleDefName = "Azure Image Builder Image Role Definition"
$identityName = "AzureImageBuilderUserIdentity"

New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

Select-AzSubscription -Subscription 92d0bf2b-bd52-4b00-b9b7-5969d1949ba0

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
$myRoleImageCreationPath = "$env:TEMP\myRoleImageCreation.json"

Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

New-AzRoleDefinition -InputFile $myRoleImageCreationPath

$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams

$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD-Images'

New-AzGallery -GalleryName $myGalleryName -ResourceGroupName $imageResourceGroup -Location $location

$GalleryParams = @{
  GalleryName = $myGalleryName
  ResourceGroupName = $imageResourceGroup
  Location = $location
  Name = $imageDefName
  OsState = 'generalized'
  OsType = 'Windows'
  Publisher = 'DHD'
  Offer = 'Windows'
  Sku = 'Win10EnterpriseMultiSession'
}
New-AzGalleryImageDefinition @GalleryParams