Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\temp' -Recurse | Remove-Item -Recurse -Force | Out-Null
Remove-Item -Path 'C:\temp' -Force | Out-Null
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. *** - Exit Code: ' $LASTEXITCODE

Start-Sleep -Seconds 60