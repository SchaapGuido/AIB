# VM settings
[int]$timeInt = $(Get-Date -UFormat '%m%d%H%M%S')
$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "J6%W98Y^rZ" -AsPlainText -Force
$LocationName = "westeurope"
$ResourceGroupName = "rg-wvd-ont"
$ComputerName = "vm" + $timeInt
$VMName = "vm" + $timeInt
$VMSize = "Standard_D2s_v3"

# Network settings    
$NetworkResourceGroup = "rg-management-networking-p"
$NetworkName = "vnet-shared-p"
$NICName = "vm" + $timeInt + "NIC"
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