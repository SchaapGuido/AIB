Write-Host "Running Installer Script script extension"

Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
-VMName $VMName `
    -Location $LocationName `
    -FileUri "https://raw.githubusercontent.com/SchaapGuido/AIB/main/Win10ms_O365v0_3.ps1" `
    -Run 'Win10ms_O365v0_3.ps1' `
    -Name 'InstallerScript'

Write-Host "Removing Installer Script script extension"

Remove-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
    -Name 'InstallerScript' `
    -VMName $VMName `
    -Force