# These two lines appear to fix an infinite sysprep loop, https://github.com/hashicorp/packer/issues/9818
New-Item -Path HKLM:\Software\Microsoft\DesiredStateConfiguration
New-ItemProperty -Path HKLM:\Software\Microsoft\DesiredStateConfiguration -Name 'AgentId' -PropertyType STRING -Force

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\temp' -Recurse | Remove-Item -Recurse -Force | Out-Null
Remove-Item -Path 'C:\temp' -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60