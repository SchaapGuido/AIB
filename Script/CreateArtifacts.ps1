$systemResourceGroup = 'rgwvdsys'
$imageRoleDefName = "Azure Image Builder Role"
$identityName = "AzureImageBuilderUserIdentity"
$location = 'westeurope'

Select-AzSubscription 92d0bf2b-bd52-4b00-b9b7-5969d1949ba0

# Your Azure Subscription ID
$subscriptionID = (Get-AzContext).Subscription.Id
Write-Output $subscriptionID

New-AzUserAssignedIdentity -ResourceGroupName $systemResourceGroup -Name $identityName

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $systemResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $systemResourceGroup -Name $identityName).PrincipalId

$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
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
    Scope = "/subscriptions/$subscriptionID/resourceGroups/$systemResourceGroup"
  }
  New-AzRoleAssignment @RoleAssignParams