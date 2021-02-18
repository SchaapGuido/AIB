Select-AzSubscription -Subscription '92d0bf2b-bd52-4b00-b9b7-5969d1949ba0'

$imageResourceGroup = 'rg-wvd-ont'
$location = 'Westeurope'
$imageTemplateName = 'WVD-Images'
$runOutputName = 'myDistResults'
$subscriptionID = (Get-AzContext).Subscription.Id
$identityName = "AzureImageBuilderUserIdentity"
$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD-Images'

$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'office-365'
  Sku = '20h2-evd-o365pp'
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
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_4.ps1"
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

$ImgTemplateParams = @{
  ImageTemplateName = $imageTemplateName
  ResourceGroupName = $imageResourceGroup
  Source = $srcPlatform
  Distribute = $disSharedImg
  Customize = $Customizer
  Location = $location
  UserAssignedIdentityId = $userAssignedIdentity.Id
}
New-AzImageBuilderTemplate @ImgTemplateParams

$imageBuilderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

$imageBuilderResult |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState, ProvisioningErrorMessage

if ($imageBuilderResult.ProvisioningState -eq "Succeeded")
{
  Write-Output "Creating image started."
  Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName
  Write-Output "Creating image finished."
}
else 
{
  Write-Warning "Creating template failed!"
  Write-Warning $imageBuilderResult.ProvisioningErrorMessage
}
# Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

# Stop-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName