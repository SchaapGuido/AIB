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

New-AzResourceGroup -Name $ResourceGroupName -Location $LocationName

# Image settings
$imageName = "WVD-Test"
    
$Vnet = Get-AzVirtualNetwork -Name $NetworkName `
    -ResourceGroupName $NetworkResourceGroup `
    -Verbose

$SingleSubnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName `
    -VirtualNetwork $Vnet `
    -Verbose

$NIC = New-AzNetworkInterface -Name $NICName `
    -ResourceGroupName $ResourceGroupName `
    -Location $LocationName `
    -SubnetId $SingleSubnet.Id `
    -Tag $tags `
    -Verbose
    
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
    
$VirtualMachine = New-AzVMConfig -VMName $VMName `
    -VMSize $VMSize `
    -Verbose

$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows `
    -ComputerName $ComputerName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate `
    -Verbose

$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine `
    -Id $NIC.Id `
    -Verbose

$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
    -PublisherName $ImagePublisher `
    -Offer $ImageOffer `
    -Skus $ImageSKU `
    -Version latest `
    -Verbose
    
New-AzVM -ResourceGroupName $ResourceGroupName `
    -Location $LocationName `
    -VM $VirtualMachine `
    -Tag $tags `
    -Verbose
    
Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
    -VMName $VMName `
    -Location $LocationName `
    -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v01.ps1" `
    -Run 'Win10ms_O365V01.ps1' `
    -Name 'InstallerScript'

Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
    -VMName $VMName `
    -Location $LocationName `
    -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/sysprep.ps1" `
    -Run 'sysprep.ps1' `
    -Name 'Sysprep'

$ipAddress = $NIC.IpConfigurations.PrivateIpAddress

# Capture image

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




    