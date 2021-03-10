$depPackages = ('C:\Temp\Microsoft.VCLibs.140.00_14.0.29231.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.UI.Xaml.2.4_2.42007.9001.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx',
    'C:\Temp\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx')
$packagePath = 'C:\Temp\Microsoft.Todos_2.39.4622.0_neutral___8wekyb3d8bbwe.AppxBundle'

Add-AppxProvisionedPackage -Online `
    -PackagePath $packagePath `
    -DependencyPackagePath $depPackages `
    -SkipLicense