$imageResourceGroup = 'rg-wvd-ont'
$location = 'Westeurope'
$imageTemplateName = 'wvd-imagetemplate'
$runOutputName = 'wvd-runoutput'
$identityName = "AIB-UserassignedIdentity"
$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD_Images'
$subscriptionID = (Get-AzContext).Subscription.Id

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
Write-Output "AIB script started."

# Describes a virtual machine image source for building, customizing and distributing.
# -SourceTypeManagedImage: Describes an image source that is a managed image in customer subscription.
$SrcObjParams = @{
  SourceTypePlatformImage = $true
    Publisher = 'MicrosoftWindowsDesktop'
    Offer = 'office-365'
    Sku = '20h1-evd-o365pp'
    Version = 'latest'
  }
  $srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

  # Generic distribution object
  # -ArtifactTag: Tags that will be applied to the artifact once it has been created/updated by the distributor.
  # -SharedImageDistributor: Distribute via Shared Image Gallery.
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

  # Create a virtual machine image template
  $ImgTemplateParams = @{
    ImageTemplateName = $imageTemplateName
    ResourceGroupName = $imageResourceGroup
    Source = $srcPlatform       # defined with New-AzImageBuilderSourceObject
    Distribute = $disSharedImg  # defined with New-AzImageBuilderDistributorObject
    Customize = $Customizer     # defined with New-AzImageBuilderCustomizerObject
    Location = $location
    UserAssignedIdentityId = $identityNameResourceId
  }
  Write-Output "Creating image builder template..."
  New-AzImageBuilderTemplate @ImgTemplateParams

  do
  {
      Start-Sleep -Seconds 30
      Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup |
      Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState
      Write-Output "Status: $($result.LastRunStatusRunState), $($result.LastRunStatusRunSubState)"
  }
  until ($result.LastRunStatusRunState -ne "Running")

  if ($result.ProvisioningState -eq "Succeeded")
  {
    Write-Output "Creating image..."
    Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName
    do
    {
        Start-Sleep -Seconds 60
        $result = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
        Write-Output "Status: $($result.LastRunStatusRunState), $($result.LastRunStatusRunSubState), $(Get-Date -UFormat "%H:%M:%S")"
    }
    until ($result.LastRunStatusRunState -ne "Running")
  }
  else 
  {
      Write-Output "Image creation failed..."
      $result.ProvisioningErrorMessage
  }  
  
  Write-Output "Removing image builder template..."
  Remove-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -ImageTemplateName $imageTemplateName
  Write-Output "AIB script ended."