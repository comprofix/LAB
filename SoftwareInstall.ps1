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

function Install-Fonts {
    param (
        [Parameter(Mandatory)]
        [string]$FontsPath
    )

    $fonts = Get-ChildItem -Path $FontsPath -Include *.ttf,*.otf -Recurse

    foreach ($font in $fonts) {
        $destination = "$Env:SystemRoot\Fonts\$($font.Name)"

        if (!(Test-Path $destination)) {
            Copy-Item -Path $font.FullName -Destination $destination
            $fontRegName  = $font.BaseName
            $fontFileName = $font.Name

            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" `
                             -Name $fontRegName `
                             -PropertyType String `
                             -Value $fontFileName `
                             -Force | Out-Null

            Write-Output "✅ - Installed font: $($font.Name)"
        }
        else {
            Write-Output "⚠️ - Font already exists: $($font.Name)"
        }
    }
}


Install-WinGet

# Hashtable mapping packages to optional extra arguments
$packages = @{
    'microsoft.sysinternals.suite'  = ''
    'git.git'                       = ''
    'notepad++.notepad++'           = ''
    'abbodi1406.vcredist'           = ''
    'microsoft.powershell'          = ''
    
}

# Loop through packages
foreach ($pkg in $packages.Keys) {
    try {
        $args = $packages[$pkg]
        Write-Output "🛠️  - Installing Package: $pkg"
        winget install --accept-package-agreements --accept-source-agreements $pkg
        Write-Output "✅ - Successfully installed $pkg"
    } catch {
        Write-Output "❌ - Failed to install $pkg $_"
    }
}

$env:Path += ";C:\Program Files\Git\cmd"

$tempPath = "C:\Windows\Temp"
$HackFontsRepo = "https://github.com/ryanoasis/nerd-fonts"
$HackFontsVer = git ls-remote --refs --tags $HackFontsRepo |
                ForEach-Object { ($_ -split '/')[ -1 ] } |
                Select-Object -Last 1
$HackFontsFile = Join-Path $tempPath "Hack.zip"
$HackFontsPath = Join-Path $tempPath "HackFonts"

Start-BitsTransfer `
    -Source "$HackFontsRepo/releases/download/$HackFontsVer/Hack.zip" `
    -Destination $HackFontsFile

Expand-Archive -Path $HackFontsFile -DestinationPath $HackFontsPath -Force

Install-Fonts -FontsPath $HackFontsPath


# Define repo and clone path
$fontRepo = 'https://github.com/mrbvrz/segoe-ui-linux'
$clonePath = 'C:\Windows\temp\segoe-ui-linux'

# Clone the fonts repo if not already cloned
if (!(Test-Path $clonePath)) {
    git clone $fontRepo $clonePath
    Write-Output "✅ - Cloned repository to: $clonePath"
} else {
    Write-Output "⚠️ - Repository already exists: $clonePath"
}

Install-Fonts -FontsPath $clonePath



