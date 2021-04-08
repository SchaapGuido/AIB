﻿Write-Host "Log in with an Azure account"
Connect-AzAccount

Select-AzSubscription -Subscription '92d0bf2b-bd52-4b00-b9b7-5969d1949ba0'

Write-Host "Setting variables."
$imageResourceGroup = 'rgwvdsys'
$location = 'Westeurope'
$imageTemplateName = 'Template-WVD-Images'
$runOutputName = 'myDistResults'
$subscriptionID = (Get-AzContext).Subscription.Id
$identityName = "AzureImageBuilderUserIdentity"
$myGalleryName = 'WvdImageGallery'
$imageDefName = 'WvdAccImages'

Write-Host "Checking if an old template exists"
$result = Get-AzImageBuilderTemplate -Resourcegroupname $imageResourceGroup
if ($result)
{
  Write-Host "Removing old template first."
  Get-AzImageBuilderTemplate -Resourcegroupname $imageResourceGroup | Remove-AzImageBuilderTemplate
}

Write-Host "Getting user assigned identity"
$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName

Write-Host "Setting parameters for AIB Source Object."
$SrcObjParams = @{
  SourceTypePlatformImage = $true
  Publisher = 'MicrosoftWindowsDesktop'
  Offer = 'office-365'
  Sku = '20h2-evd-o365pp'
  Version = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

Write-Host "Setting parameters for AIB Distribution Object."
$disObjParams = @{
  SharedImageDistributor = $true
  ArtifactTag = @{tag='dis-share'}
  GalleryImageId = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/galleries/$myGalleryName/images/$imageDefName"
  ReplicationRegion = $location
  RunOutputName = $runOutputName
  ExcludeFromLatest = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

Write-Host "Setting parameters for 1st AIB Customizer Object."
# Phase 1: installing language pack
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'Install_Language'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallLang.ps1"
}
$Customizer01 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Setting parameters for 2nd AIB Customizer Object."
$ImgUpdateParams = @{
  WindowsUpdateCustomizer = $true
  CustomizerName = 'WindowsUpdates'
}
$Customizer02 = New-AzImageBuilderCustomizerObject @ImgUpdateParams

Write-Host "Setting parameters for 3rd AIB Customizer Object."
$ImgCustomParams = @{
  RestartCustomizer = $true
  CustomizerName = 'RestartVM'
  RestartCommand = 'shutdown /f /r /t 60 /c "Packer Restart"'
  RestartCheckCommand = 'powershell -command "& {Write-Output "restarted after Windows update."}"'
}
$Customizer03 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Setting parameters for 4th AIB Customizer Object."
# Phase 2: installing Office, Teams and Wvd Optimization Tool
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallOfficeTeams'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallOffice.ps1"
}
$Customizer04 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Setting parameters for 5th AIB Customizer Object."
$ImgCustomParams = @{
  RestartCustomizer = $true
  CustomizerName = 'RestartVM'
  RestartCommand = 'shutdown /f /r /t 60 /c "Packer Restart"'
  RestartCheckCommand = 'powershell -command "& {Write-Output "restarted after software installed."}"'
}
$Customizer05 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Setting parameters for 6th AIB Customizer Object."
# Phase 3: installing other packages
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'InstallOthers'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/InstallOthers.ps1"
}
$Customizer06 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Setting parameters for 7th AIB Customizer Object."
# Phase 4: Cleanup
$ImgCustomParams = @{
  PowerShellCustomizer = $true
  CustomizerName = 'Cleanup'
  RunElevated = $true
  ScriptUri = "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Script/Cleanup.ps1"
}
$Customizer08 = New-AzImageBuilderCustomizerObject @ImgCustomParams

Write-Host "Creating AIB Template."
$ImgTemplateParams = @{
  ImageTemplateName = $imageTemplateName
  ResourceGroupName = $imageResourceGroup
  Source = $srcPlatform
  Distribute = $disSharedImg
  Customize = $Customizer01,$Customizer02,$Customizer03,$Customizer04,$Customizer05,$Customizer06,$Customizer08
  Location = $location
  UserAssignedIdentityId = $userAssignedIdentity.Id
  VMProfileVmSize = 'Standard_D2s_v3'
}
New-AzImageBuilderTemplate @ImgTemplateParams

Write-Host "Getting status of AIB Template."
$imageBuilderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup

$imageBuilderResult |
  Select-Object -Property Name, LastRunStatusRunState, LastRunStatusMessage, ProvisioningState, ProvisioningErrorMessage

if ($imageBuilderResult.ProvisioningState -eq "Succeeded")
{
  Write-Output "Creating image started"
  Start-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName -AsJob
  do {
    start-sleep -seconds 60
    $imageBuilderResult = Get-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
    Write-Host $(Get-Date),$imageBuilderResult.LastRunStatusRunState,$imageBuilderResult.LastRunStatusRunSubState
  } until ($imageBuilderResult.LastRunStatusRunState -ne "Running")
  Write-Output "Creating image finished on $($imageBuilderResult.LastRunStatusEndTime)"
}
else 
{
  Write-Warning "Creating template failed!"
  Write-Warning $imageBuilderResult.ProvisioningErrorMessage
}

<#
  Stop-AzImageBuilderTemplate -ResourceGroupName $imageResourceGroup -Name $imageTemplateName
  Remove-AzImageBuilderTemplate -ImageTemplateName $imageTemplateName -ResourceGroupName $imageResourceGroup
#>

