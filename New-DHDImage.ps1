# VM settings
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "J6%W98Y^rZ" -AsPlainText -Force
$LocationName = "westeurope"
$ResourceGroupName = "rg-wvd-ont-" + $timeInt
$ComputerName = "vmwvd" + $timeInt
$VMName = "vmwvd" + $timeInt
$VMSize = "Standard_DS1_v2"

# Network settings    
$NetworkResourceGroup = "rg-management-networking-p"
$NetworkName = "vnet-shared-p"
$NICName = "vmwvd" + $timeInt
$SubnetName = "sn-wvd-p"
    
# Marketplace image settings
$ImagePublisher = "MicrosoftWindowsDesktop"
$ImageOffer = "office-365"
$ImageSKU = "20h1-evd-o365pp"

# Tags settings
$CreatedOnDate = Get-Date -Format g
$tags = @{
    "DHD-CreatedOnDate"=$CreatedOnDate
}

Write-Host "Creating temporary resource group"
try {
    New-AzResourceGroup -Name $ResourceGroupName `
    -Location $LocationName `
    -Tag @{"DHD-Application"="Windows Virtual Desktop (WVD)"; "DHD-Cluster"="Infra basis"; "DHD-Contact"="Guido Schaap;Eduard de Vries"; "DHD-Environment"="Production"; "DHD-Owner"="IT-Infra"} | Out-Null
    Write-Host "Created temporary resource group"
}
catch {
    Write-Warning "Failed to create temorary resource group, $_"   
}

# Image settings
$imageName = "Img-Wvd-" + $timeInt
    
Write-Host "Creating temporary VM"
try {
    $Vnet = Get-AzVirtualNetwork -Name $NetworkName `
    -ResourceGroupName $NetworkResourceGroup `

    $SingleSubnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName `
        -VirtualNetwork $Vnet `

    $NIC = New-AzNetworkInterface -Name $NICName `
        -ResourceGroupName $ResourceGroupName `
        -Location $LocationName `
        -SubnetId $SingleSubnet.Id `
        -Tag $tags `
        
    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
        
    $VirtualMachine = New-AzVMConfig -VMName $VMName `
        -VMSize $VMSize `

    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows `
        -ComputerName $ComputerName `
        -Credential $Credential `
        -ProvisionVMAgent `
        -EnableAutoUpdate `

    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine `
        -Id $NIC.Id `

    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
        -PublisherName $ImagePublisher `
        -Offer $ImageOffer `
        -Skus $ImageSKU `
        -Version latest `
        
    New-AzVM -ResourceGroupName $ResourceGroupName `
        -Location $LocationName `
        -VM $VirtualMachine `
        -Tag $tags `
}
catch {
    Write-Warning "Failed to create vm, $_"
}

try {
    Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
    -VMName $VMName `
    -Location $LocationName `
    -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_1.ps1" `
    -Run 'Win10ms_O365v0_1.ps1' `
    -Name 'InstallerScript'

    Start-Sleep -Seconds 60

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
    
try {
    Stop-AzVM -ResourceGroupName $ResourceGroupName `
    -Name $VMName `
    -Force

    Set-AzVm -ResourceGroupName $ResourceGroupName `
        -Name $VMName `
        -Generalized

    $vm = Get-AzVM -Name $VMName `
        -ResourceGroupName $ResourceGroupName

    $image = New-AzImageConfig -Location $LocationName `
        -SourceVirtualMachineId $vm.Id

    New-AzImage -Image $image `
        -ImageName $imageName `
        -ResourceGroupName rg-wvd-p
    }
catch {
    Write-Warning "Failed to capture temporary VM, $_"
}

try {
    Remove-AzResourceGroup -Name $ResourceGroupName -Force
}
catch {
    Write-Warning "Failed to remove temporary resourcegroup, $_"
}





    