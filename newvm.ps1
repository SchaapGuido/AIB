New-AzVm `
    -ResourceGroupName "myResourceGroup" `
    -Name "myVM" `
    -Location "West Europe" `
    -VirtualNetworkName "vnet-shared-p" `
    -SubnetName "sn-wvd-p" 