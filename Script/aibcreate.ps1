$imageResourceGroup = "rg-wvd-ont"
$imageRoleDefName = "Azure Image Builder Service Image Creation Role"
$identityName = "AIB-UserassignedIdentity"
$location = 'westeurope'
$subscriptionID = '92d0bf2b-bd52-4b00-b9b7-5969d1949ba0'
$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD-Images'
$runOutputName = 'myDistResults'
$imageTemplateName = 'myWinImage'

New-AzResourceGroup -Name rg-wvd-ont -Location 'westeurope'
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

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

New-AzGallery -GalleryName $myGalleryName -ResourceGroupName $imageResourceGroup -Location $location

$GalleryParams = @{
    GalleryName = $myGalleryName
    ResourceGroupName = $imageResourceGroup
    Location = $location
    Name = $imageDefName
    OsState = 'generalized'
    OsType = 'Windows'
    Publisher = 'DHD'
    Offer = 'WindowsVirtualDesktop'
    Sku = 'WVDOffice365'
  }
  New-AzGalleryImageDefinition @GalleryParams

  $SrcObjParams = @{
    SourceTypePlatformImage = $true
    Publisher = 'MicrosoftWindowsDesktop'
    Offer = 'office-365'
    Sku = '20h1-evd-o365pp'
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
    ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_2.ps1"
  }
  $Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

  $ImgTemplateParams = @{
    ImageTemplateName = $imageTemplateName
    ResourceGroupName = $imageResourceGroup
    Source = $srcPlatform
    Distribute = $disSharedImg
    Customize = $Customizer01
    Location = $location
    UserAssignedIdentityId = $identityNameResourceId
  }
  New-AzImageBuilderTemplate @ImgTemplateParams

  Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState

  Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName