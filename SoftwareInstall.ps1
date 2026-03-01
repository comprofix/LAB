Write-Output "[START] - Software"

function Install-WinGet {
    [CmdletBinding()]
    param (
        [int]$TimeoutSeconds = 180
    )

    $ErrorActionPreference = "Stop"

    Write-Host "Installing WinGet..."

    $tempPath = "C:\Windows\Temp"
    $bundlePath = Join-Path $tempPath "WinGet.msixbundle"
    $depsZipPath = Join-Path $tempPath "DesktopAppInstaller_Dependencies.zip"
    $licensePath = Join-Path $tempPath "license.xml"
    $depsExtractPath = Join-Path $tempPath "DesktopAppInstaller_Dependencies"

    # Clean previous leftovers
    Remove-Item $bundlePath,$depsZipPath,$licensePath -ErrorAction SilentlyContinue
    Remove-Item $depsExtractPath -Recurse -Force -ErrorAction SilentlyContinue

    # Download latest release assets
    Start-BitsTransfer `
        -Source "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" `
        -Destination $bundlePath

    Start-BitsTransfer `
        -Source "https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip" `
        -Destination $depsZipPath

    Start-BitsTransfer `
        -Source "https://github.com/microsoft/winget-cli/releases/latest/download/e53e159d00e04f729cc2180cffd1c02e_License1.xml" `
        -Destination $licensePath

    Expand-Archive -Path $depsZipPath -DestinationPath $depsExtractPath -Force

    # Install dependencies
    Get-ChildItem "$depsExtractPath\x64\*.appx" | ForEach-Object {
        Write-Host "Installing dependency: $($_.Name)"
        Add-AppxPackage -Path $_.FullName -ErrorAction SilentlyContinue
    }

    # Provision package for system
    Write-Host "Provisioning DesktopAppInstaller..."
    Add-AppxProvisionedPackage -Online `
        -PackagePath $bundlePath `
        -LicensePath $licensePath | Out-Null

    # Force registration for current user (critical step)
    Write-Host "Registering package for current user..."
    $pkg = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -AllUsers |
           Sort-Object Version -Descending |
           Select-Object -First 1

    if ($pkg) {
        Add-AppxPackage -Register "$($pkg.InstallLocation)\AppxManifest.xml" `
                        -DisableDevelopmentMode
    }

    # Refresh PATH in current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH","User")

    # Wait deterministically for winget availability
    Write-Host "Waiting for winget to become available..."
    $elapsed = 0

    while (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Start-Sleep -Seconds 5
        $elapsed += 5

        if ($elapsed -ge $TimeoutSeconds) {
            throw "Winget did not become available within $TimeoutSeconds seconds."
        }
    }

    Write-Host "Winget installed successfully."
    winget --version
}

Install-WinGet



#RefreshEnv
#winget --info

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# try {
#     Write-Output "🛠️  - Installing Chocolatey"
#     $null = Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#     Write-Output "✅ - Successfully installed Chocolatey"
# } catch {
#      Write-Output "❌ - Failed to Install Chocolatey $_"
# }

# Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1

# # Enable Chocolatey features for smoother installs
# try {
#     choco feature enable -n allowEmptyChecksums | Out-Null
#     choco feature enable -n allowGlobalConfirmation | Out-Null
#     choco feature enable -n usePackageExitCodes | Out-Null
#     Write-Output "✅ Enabled Chocolatey features"
# } catch {
#     Write-Output "❌ - Failed to enable Chocolatey features: $_"
# }

# # Hashtable mapping packages to optional extra arguments
# $packages = @{
#     'sysinternals'                  = '--ignore-checksums'
#     'git.install'                   = ''
#     'notepadplusplus'               = ''
#     'vcredist140'                   = ''
#     'nerd-fonts-hack'               = ''
#     'cascadiamono'                  = ''
#     'powershell-core'               = ''
# }

# # Loop through packages
# foreach ($pkg in $packages.Keys) {
#     try {
#         $args = $packages[$pkg]
#         Write-Output "🛠️  - Installing Package: $pkg"
#         choco install $pkg -y $args | Out-Null
#         Write-Output "✅ - Successfully installed $pkg"
#     } catch {
#         Write-Output "❌ - Failed to install $pkg $_"
#     }
# }

# # Upgrade all packages at the end
# try {
#     choco upgrade all --ignore-checksums -y | Out-Null
#     Write-Output "✅ - Upgraded all packages"
# } catch {
#     Write-Output "❌ - Failed to upgrade packages $_"
# }






# $env:PATH = "C:\Program Files\Git\cmd;" + $env:PATH
# Write-Output "✅ - Update Paths"

# # Define repo and clone path
# $fontRepo = 'https://github.com/mrbvrz/segoe-ui-linux'
# $clonePath = 'C:\Temp\segoe-ui-linux'

# # Ensure C:\Temp exists
# if (!(Test-Path 'C:\Temp')) {
#     New-Item -Path 'C:\Temp' -ItemType Directory | Out-Null
#     Write-Output "Created folder: C:\Temp"
# }

# # Clone the fonts repo if not already cloned
# if (!(Test-Path $clonePath)) {
#     git clone $fontRepo $clonePath
#     Write-Output "✅ - Cloned repository to: $clonePath"
# } else {
#     Write-Output "⚠️ - Repository already exists: $clonePath"
# }

# # Install fonts
# $fontsPath = Join-Path $clonePath 'font'
# $fonts = Get-ChildItem -Path $fontsPath -Include *.ttf,*.otf -Recurse

# foreach ($font in $fonts) {
#     $destination = "$Env:SystemRoot\Fonts\$($font.Name)"
#     if (!(Test-Path $destination)) {
#         Copy-Item -Path $font.FullName -Destination $destination
#         Write-Output "Installed font: $($font.Name)"
#         $fontRegName = $font.BaseName
#         $fontFileName = $font.Name
#         New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
#                         -Name $fontRegName `
#                         -PropertyType String `
#                         -Value $fontFileName -Force | Out-Null
#         Write-Output "✅ - Registered font: $fontRegName"
#     } else {
#         Write-Output "⚠️ - Font already exists: $($font.Name)"
#     }
# }

