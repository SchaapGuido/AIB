Select-AzSubscription -Subscription '92d0bf2b-bd52-4b00-b9b7-5969d1949ba0'

$imageResourceGroup = 'rg-wvd-ont'
$location = 'Westeurope'
$imageTemplateName = 'WVD-Images'
$runOutputName = 'myDistResults'
$subscriptionID = (Get-AzContext).Subscription.Id
$identityName = "AzureImageBuilderUserIdentity"
$myGalleryName = 'AIBImageGallery'
$imageDefName = 'WVD-Images'

$result = Get-AzImageBuilderTemplate -Resourcegroupname $imageResourceGroup
if ($result)
{
  Get-AzImageBuilderTemplate -Resourcegroupname $imageResourceGroup | Remove-AzImageBuilderTemplate
}

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

# Phase 1: installing language pack
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallLang.ps1"
}
$Customizer01 = New-AzImageBuilderCustomizerObject @ImgCustomParams

$ImgUpdateParams = @{
  WindowsUpdateCustomizer = $true
  CustomizerName = 'WindowsUpdates'
}
$Customizer02 = New-AzImageBuilderCustomizerObject @ImgUpdateParams

$ImgCustomParams = @{
  RestartCustomizer = $true
  CustomizerName = 'RestartVM'
  RestartCommand = 'shutdown /f /r /t 0 /c "Packer Restart"'
  RestartCheckCommand = 'powershell -command "& {Write-Output "restarted."}"'
}
$Customizer03 = New-AzImageBuilderCustomizerObject @ImgCustomParams

<#
# Phase 2: installing Office and Teams
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallOffice.ps1"
}
$Customizer04 = New-AzImageBuilderCustomizerObject @ImgCustomParams

$ImgCustomParams = @{
  RestartCustomizer = $true
  CustomizerName = 'RestartVM'
  RestartCommand = 'shutdown /f /r /t 0 /c "Packer Restart"'
  RestartCheckCommand = 'powershell -command "& {Write-Output "restarted."}"'
}
$Customizer05 = New-AzImageBuilderCustomizerObject @ImgCustomParams

# Phase 2: installing Office and Teams
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallApp'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallOffice.ps1"
}
$Customizer06 = New-AzImageBuilderCustomizerObject @ImgCustomParams

$ImgCustomParams = @{
  RestartCustomizer = $true
  CustomizerName = 'RestartVM'
  RestartCommand = 'shutdown /f /r /t 0 /c "Packer Restart"'
  RestartCheckCommand = 'powershell -command "& {Write-Output "restarted."}"'
}
$Customizer07 = New-AzImageBuilderCustomizerObject @ImgCustomParams
#>

$ImgTemplateParams = @{
  ImageTemplateName = $imageTemplateName
  ResourceGroupName = $imageResourceGroup
  Source = $srcPlatform
  Distribute = $disSharedImg
  Customize = $Customizer01,$Customizer02,$Customizer03
  Location = $location
  UserAssignedIdentityId = $userAssignedIdentity.Id
  VMProfileVmSize = 'Standard_D2s_v3'
}
New-AzImageBuilderTemplate @ImgTemplateParams

$imageBuilderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

$imageBuilderResult |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState, ProvisioningErrorMessage

if ($imageBuilderResult.ProvisioningState -eq "Succeeded")
{
  Write-Output "Creating image started."
  Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -AsJob
  do {
    start-sleep -seconds 60
    $imageBuilderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
    write-host $(Get-Date),$imageBuilderResult.LastRunStatusRunState
  } until ($imageBuilderResult.LastRunStatusRunState -ne "Running")
  Write-Output "Creating image finished."
}
else 
{
  Write-Warning "Creating template failed!"
  Write-Warning $imageBuilderResult.ProvisioningErrorMessage
}

Stop-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -NoWait
Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
