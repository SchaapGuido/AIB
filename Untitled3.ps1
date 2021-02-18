$imageResourceGroup = 'rg-wvd-ont'
$location = 'Westeurope'
$imageTemplateName = 'WVD-Images'
$runOutputName = 'myDistResults'
$subscriptionID = (Get-AzContext).Subscription.Id
$imageRoleDefName = "Azure Image Builder Image Role Definition"
$identityName = "AzureImageBuilderUserIdentity"
$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD-Images'

$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'windows-10'
  Sku = '20h1-evd'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

$disObjParams = @{
  SharedImageDistributor = $true
  ArtifactTag = @{tag='dis-share'}
  GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
  ReplicationRegion = $location
  RunOutputName = $runOutputName
  ExcludeFromLatest = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_3.ps1"
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

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

Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState, ProvisioningErrorMessage

# Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

# Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName