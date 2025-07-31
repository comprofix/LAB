# Phase 5a [START] - Software
Write-Output "Phase 5a [START] - Software"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# Enable Chocolatey features for smoother installs
try {
    choco feature enable -n allowEmptyChecksums | Out-Null
    choco feature enable -n allowGlobalConfirmation | Out-Null
    choco feature enable -n usePackageExitCodes | Out-Null
    Write-Output "Phase 2 [INFO] - Enabled Chocolatey features"
} catch {
    Write-Output "Phase 2 [WARN] - Failed to enable Chocolatey features: $_"
}

# Install software
choco install sysinternals -y --ignore-checksums
choco install dotnetfx -y
choco install git.install -y
choco install notepadplusplus -y
choco install vcredist-all -y
choco install nerd-fonts-hack -y
choco install cascadiamono -y
choco install powershell-core -y
choco upgrade all --ignore-checksums -y

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

Write-Output "Phase 5a [INFO] - Cloning and installing Segoe UI Linux fonts"

# Define repo and clone path
$fontRepo = 'https://github.com/mrbvrz/segoe-ui-linux'
$clonePath = 'C:\Temp\segoe-ui-linux'

# Ensure C:\Temp exists
if (!(Test-Path 'C:\Temp')) {
    New-Item -Path 'C:\Temp' -ItemType Directory | Out-Null
    Write-Output "Created folder: C:\Temp"
}

# Clone the fonts repo if not already cloned
if (!(Test-Path $clonePath)) {
    git clone $fontRepo $clonePath
    Write-Output "Cloned repository to: $clonePath"
} else {
    Write-Output "Repository already exists: $clonePath"
}

# Install fonts
$fontsPath = Join-Path $clonePath 'font'
$fonts = Get-ChildItem -Path $fontsPath -Include *.ttf,*.otf -Recurse

foreach ($font in $fonts) {
    $destination = "$Env:SystemRoot\Fonts\$($font.Name)"
    if (!(Test-Path $destination)) {
        Copy-Item -Path $font.FullName -Destination $destination
        Write-Output "Installed font: $($font.Name)"
    } else {
        Write-Output "Font already exists: $($font.Name)"
    }
}

# Add fonts to registry so they show up in Windows
foreach ($font in $fonts) {
    $fontRegName = $font.BaseName
    $fontFileName = $font.Name
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                     -Name $fontRegName `
                     -PropertyType String `
                     -Value $fontFileName -Force | Out-Null
    Write-Output "Registered font: $fontRegName"
}

# Install Windows Terminal
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -outfile $env:TEMP\Microsoft.VCLibs.x86.14.00.Desktop.appx
Add-AppxPackage $env:TEMP\Microsoft.VCLibs.x86.14.00.Desktop.appx

Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -outfile -outfile $env:TEMP\Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage $env:TEMP\Microsoft.UI.Xaml.2.8.x64.appx

Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.22.11751.0/Microsoft.WindowsTerminal_1.22.11751.0_8wekyb3d8bbwe.msixbundle -outfile $env:TEMP\Microsoft.WindowsTerminal_1.22.11751.0_8wekyb3d8bbwe.msixbundle
Add-AppxPackage $env:TEMP\Microsoft.WindowsTerminal_1.22.11751.0_8wekyb3d8bbwe.msixbundle

Write-Output "Phase 5a [END] - Software"
