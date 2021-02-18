$VMLocalAdminUser = "LocalAdminUser"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "J6%W98Y^rZ" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
Start-process 'C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /quit /quiet' -Credential $Credential
