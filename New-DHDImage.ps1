# VM settings
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "J6%W98Y^rZ" -AsPlainText -Force
$LocationName = "westeurope"
$ResourceGroupName = "rg-wvd-tmp-" + $timeInt
$ComputerName = "vm" + $timeInt
$VMName = "vm" + $timeInt
$VMSize = "Standard_DS1_v2"

# Network settings    
$NetworkResourceGroup = "rg-management-networking-p"
$NetworkName = "vnet-shared-p"
$NICName = "vm" + $timeInt + "NIC"
$SubnetName = "sn-wvd-p"
    
# Marketplace image settings
$ImagePublisher = "MicrosoftWindowsDesktop"
$ImageOffer = "office-365"
$ImageSKU = "20h1-evd-o365pp"

# Windows Virtual Desktop settings
$wvdWorkspace = "DHDSPUD"

# Tags settings
$CreatedOnDate = Get-Date -Format g
$tags = @{
    "DHD-CreatedOnDate"=$CreatedOnDate
}

Write-Host ""
Write-Host "[Prepare phase]"
try {
    Write-Host "Creating temporary resourcegroup."
    New-AzResourceGroup -Name $ResourceGroupName `
    -Location $LocationName `
    -Tag @{"DHD-Application"="Windows Virtual Desktop (WVD)"; "DHD-Cluster"="Infra basis"; "DHD-Contact"="Guido Schaap;Eduard de Vries"; "DHD-Environment"="Production"; "DHD-Owner"="IT-Infra"} | Out-Null
}
catch {
    Write-Warning "Failed to create temorary resource group, $_"   
}

# Image settings
$imageName = "Img-Wvd-" + $timeInt

Write-Host ""
Write-Host "[VM creation phase]"
try {
    Write-Host "Getting Vnet settings."
    $Vnet = Get-AzVirtualNetwork -Name $NetworkName `
    -ResourceGroupName $NetworkResourceGroup `

    Write-Host "Getting subnet settings."
    $SingleSubnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName `
        -VirtualNetwork $Vnet `

    Write-Host "Create VM NIC."
    $NIC = New-AzNetworkInterface -Name $NICName `
        -ResourceGroupName $ResourceGroupName `
        -Location $LocationName `
        -SubnetId $SingleSubnet.Id `
        -Tag $tags `
        
    Write-Host "Create local credentials."    
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

    Write-Host "Set VM Size."
    $VirtualMachine = New-AzVMConfig -VMName $VMName `
        -VMSize $VMSize `

    Write-Host "Set VM OS properties."
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows `
        -ComputerName $ComputerName `
        -Credential $Credential `
        -ProvisionVMAgent

    Write-Host "Set VM NIC properties."
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine `
        -Id $NIC.Id `

    Write-Host "Set VM source image properties."
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
        -PublisherName $ImagePublisher `
        -Offer $ImageOffer `
        -Skus $ImageSKU `
        -Version latest `
        
    Write-Host "Create VM."
    New-AzVM -ResourceGroupName $ResourceGroupName `
        -Location $LocationName `
        -VM $VirtualMachine `
        -Tag $tags `
}
catch {
    Write-Warning "Failed to create vm, $_"
}

Write-Host ""
Write-Host "[VM configuration phase]"
try {
<#
    Write-Host "Running Installer Script script extension"
    Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
    -VMName $VMName `
    -Location $LocationName `
    -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_1.ps1" `
    -Run 'Win10ms_O365v0_1.ps1' `
    -Name 'InstallerScript'

    Write-Host "Removing Installer Script script extension"
    Remove-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
        -Name 'InstallerScript' `
        -VMName $VMName `
        -Force
#>

    Write-Host "Running sysprep script extension"
    Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
        -VMName $VMName `
        -Location $LocationName `
        -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/sysprep.ps1" `
        -Run 'sysprep.ps1' `
        -Name 'Sysprep'
    }
catch {
    Write-Warning "Failed to run remote scripts, $_"   
}

Write-Host ""
Write-Host "[Capture phase]"
try {
    Write-Host "Stopping and deallocating VM."
    Stop-AzVM -ResourceGroupName $ResourceGroupName `
    -Name $VMName `
    -Force

    Write-Host "Setting VM to generalized."
    Set-AzVm -ResourceGroupName $ResourceGroupName `
        -Name $VMName `
        -Generalized

    Write-Host "Getting VM settings."
    $vm = Get-AzVM -Name $VMName `
        -ResourceGroupName $ResourceGroupName

    Write-Host "Getting image settings."
    $image = New-AzImageConfig -Location $LocationName `
        -SourceVirtualMachineId $vm.Id

    Write-Host "Capturing VM image."
    New-AzImage -Image $image `
        -ImageName $imageName `
        -ResourceGroupName rg-wvd-ont
    }
catch {
    Write-Warning "Failed to capture temporary VM, $_"
}

Write-Host ""
Write-Host "[Cleanup phase]"
try {
    Write-Host "Removing temporary resource group."
    Remove-AzResourceGroup -Name $ResourceGroupName -Force
}
catch {
    Write-Warning "Failed to remove temporary resourcegroup, $_"
}