#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Modern Windows Development Environment Setup

.DESCRIPTION
    This script sets up a modern Windows development environment with:
    - PowerShell Core (if not installed)
    - Oh My Posh for beautiful prompts
    - Nerd Fonts (Cascadia Code or Source Code Pro)
    - Windows Terminal configuration
    - Essential development tools
    - Package managers (Chocolatey/Winget)

.NOTES
    Author: Modern Shell Setup
    Version: 2.0
    Requires: PowerShell 5.1+ and Administrator privileges
#>

# Ensure we're running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "❌ This script must be run as Administrator. Please run PowerShell as Administrator and try again."
    exit 1
}

# Global variables
$Script:FontChoices = @{
    1 = @{ Name = "CascadiaCode"; DisplayName = "Cascadia Code Nerd Font" }
    2 = @{ Name = "SourceCodePro"; DisplayName = "Source Code Pro Nerd Font" }
    3 = @{ Name = "Both"; DisplayName = "Both Fonts" }
    4 = @{ Name = "Skip"; DisplayName = "Skip Font Installation" }
}

# Color functions for output
function Write-Header {
    param([string]$Text)
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "                    ⚡ Windows PowerShell Setup ⚡" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host ""
}

function Write-Section {
    param([string]$Text)
    Write-Host "▶ $Text" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠️  $Text" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ️  $Text" -ForegroundColor Magenta
}

# System information
function Get-SystemInfo {
    Write-Section "System Information"

    $computerInfo = Get-ComputerInfo -Property WindowsProductName, WindowsVersion, TotalPhysicalMemory
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

    Write-Host "Hostname     : $env:COMPUTERNAME"
    Write-Host "Windows      : $($computerInfo.WindowsProductName)"
    Write-Host "Version      : $($computerInfo.WindowsVersion)"
    Write-Host "Architecture : $env:PROCESSOR_ARCHITECTURE"
    Write-Host "PowerShell   : $($PSVersionTable.PSVersion)"
    Write-Host "CPU          : $($cpu.Name)"
    Write-Host "RAM          : $([math]::Round($computerInfo.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "User         : $env:USERNAME"
    Write-Host ""
}

# Check if command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Install package managers
function Install-PackageManagers {
    Write-Section "Installing Package Managers"

    # Install Chocolatey
    if (Test-CommandExists "choco") {
        Write-Success "Chocolatey already installed"
        choco --version
    }
    else {
        Write-Info "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed"
    }

    # Install/Update Winget (usually pre-installed on Windows 11)
    if (Test-CommandExists "winget") {
        Write-Success "Winget already available"
        winget --version
    }
    else {
        Write-Warning "Winget not found. Please install from Microsoft Store: 'App Installer'"
    }

    Write-Host ""
}

# Install PowerShell Core
function Install-PowerShellCore {
    Write-Section "Installing PowerShell Core"

    if (Test-CommandExists "pwsh") {
        Write-Success "PowerShell Core already installed"
        pwsh --version
    }
    else {
        Write-Info "Installing PowerShell Core..."
        if (Test-CommandExists "winget") {
            winget install Microsoft.PowerShell --silent
        }
        else {
            choco install powershell-core -y
        }
        Write-Success "PowerShell Core installed"
    }
    Write-Host ""
}

# Font selection menu
function Select-Font {
    Write-Section "Font Selection"

    Write-Host "Please select a Nerd Font to install:"
    Write-Host "1) Cascadia Code Nerd Font (Microsoft's modern font)"
    Write-Host "2) Source Code Pro Nerd Font (Adobe's popular font)"
    Write-Host "3) Both fonts"
    Write-Host "4) Skip font installation"
    Write-Host ""

    do {
        $choice = Read-Host "Enter your choice (1-4)"
        if ($choice -in 1..4) {
            return $Script:FontChoices[$choice]
        }
        Write-Error "Invalid choice. Please enter 1, 2, 3, or 4."
    } while ($true)
}

# Install Nerd Fonts
function Install-NerdFonts {
    param([hashtable]$FontChoice)

    if ($FontChoice.Name -eq "Skip") {
        return
    }

    Write-Section "Installing Nerd Fonts"

    $fontsToInstall = @()
    switch ($FontChoice.Name) {
        "CascadiaCode" { $fontsToInstall = @("CascadiaCode-NF") }
        "SourceCodePro" { $fontsToInstall = @("SourceCodePro-NF") }
        "Both" { $fontsToInstall = @("CascadiaCode-NF", "SourceCodePro-NF") }
    }

    foreach ($font in $fontsToInstall) {
        Write-Info "Installing $font..."
        try {
            if (Test-CommandExists "choco") {
                choco install $font -y
            }
            else {
                # Fallback: Download and install manually
                Install-FontManually $font
            }
            Write-Success "$font installed"
        }
        catch {
            Write-Warning "Failed to install $font via package manager, trying manual installation..."
            Install-FontManually $font
        }
    }
    Write-Host ""
}

# Manual font installation fallback
function Install-FontManually {
    param([string]$FontName)

    $downloadUrls = @{
        "CascadiaCode-NF" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
        "SourceCodePro-NF" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip"
    }

    if ($downloadUrls.ContainsKey($FontName)) {
        $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -Type Directory -Path $_ }
        $zipPath = Join-Path $tempDir "$FontName.zip"

        try {
            Write-Info "Downloading $FontName..."
            Invoke-WebRequest -Uri $downloadUrls[$FontName] -OutFile $zipPath

            Write-Info "Extracting fonts..."
            Expand-Archive -Path $zipPath -DestinationPath $tempDir

            Write-Info "Installing font files..."
            $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse
            foreach ($fontFile in $fontFiles) {
                $destination = Join-Path $env:WINDIR "Fonts\$($fontFile.Name)"
                Copy-Item $fontFile.FullName $destination -Force

                # Register font in registry
                $fontName = $fontFile.BaseName
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "$fontName (TrueType)" -Value $fontFile.Name -PropertyType String -Force | Out-Null
            }
            Write-Success "$FontName installed manually"
        }
        catch {
            Write-Error "Failed to install $FontName manually: $($_.Exception.Message)"
        }
        finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Install Oh My Posh
function Install-OhMyPosh {
    Write-Section "Installing Oh My Posh"

    if (Test-CommandExists "oh-my-posh") {
        Write-Success "Oh My Posh already installed"
        oh-my-posh --version
    }
    else {
        Write-Info "Installing Oh My Posh..."
        if (Test-CommandExists "winget") {
            winget install JanDeDobbeleer.OhMyPosh --silent
        }
        else {
            choco install oh-my-posh -y
        }
        Write-Success "Oh My Posh installed"
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-Host ""
}

# Install development tools
function Install-DevelopmentTools {
    Write-Section "Installing Development Tools"

    $tools = @(
        @{ Name = "Git"; Package = "Git.Git"; ChocoName = "git" }
        @{ Name = "Windows Terminal"; Package = "Microsoft.WindowsTerminal"; ChocoName = "microsoft-windows-terminal" }
        @{ Name = "VS Code"; Package = "Microsoft.VisualStudioCode"; ChocoName = "vscode" }
        @{ Name = "7-Zip"; Package = "7zip.7zip"; ChocoName = "7zip" }
        @{ Name = "Curl"; Package = "cURL.cURL"; ChocoName = "curl" }
        @{ Name = "Wget"; Package = "JernejSimoncic.Wget"; ChocoName = "wget" }
        @{ Name = "jq"; Package = "stedolan.jq"; ChocoName = "jq" }
        @{ Name = "Neofetch"; Package = "nepnep.neofetch-win"; ChocoName = "neofetch" }
    )

    Write-Info "Installing essential development tools..."

    foreach ($tool in $tools) {
        if (Test-CommandExists $tool.Name.Replace(" ", "").ToLower()) {
            Write-Success "$($tool.Name) already installed"
        }
        else {
            Write-Info "Installing $($tool.Name)..."
            try {
                if (Test-CommandExists "winget") {
                    winget install $tool.Package --silent --accept-package-agreements --accept-source-agreements
                }
                else {
                    choco install $tool.ChocoName -y
                }
                Write-Success "$($tool.Name) installed"
            }
            catch {
                Write-Warning "Failed to install $($tool.Name)"
            }
        }
    }
    Write-Host ""
}

# Setup PowerShell profile
function Setup-PowerShellProfile {
    Write-Section "Setting Up PowerShell Profile"

    # Create profile for all PowerShell versions
    $profiles = @($PROFILE.AllUsersAllHosts, $PROFILE.CurrentUserAllHosts)

    foreach ($profilePath in $profiles) {
        if (-not (Test-Path $profilePath)) {
            New-Item -ItemType File -Path $profilePath -Force | Out-Null
            Write-Info "Created profile: $profilePath"
        }
    }

    $profileContent = @'
# PowerShell Profile
# Generated by Windows setup script

# Oh My Posh initialization
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\night-owl.omp.json" | Invoke-Expression
}

# Environment variables
$env:EDITOR = "code"

# Import modules
Import-Module PSReadLine -Force

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name curl -Value Invoke-WebRequest
Set-Alias -Name wget -Value Invoke-WebRequest

# Git aliases
function gs { git status $args }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git log --oneline $args }
function gd { git diff $args }

# Directory navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# Quick commands
function h { Get-History }
function c { Clear-Host }
function q { exit }

# Utility functions
function mkcd($path) {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Location $path
}

function backup($file) {
    Copy-Item $file "$file.bak"
}

function touch($file) {
    New-Item -ItemType File -Path $file -Force | Out-Null
}

function Get-Weather($city = "") {
    if ($city) {
        Invoke-RestMethod "http://wttr.in/$city"
    } else {
        Invoke-RestMethod "http://wttr.in"
    }
}

function Get-MyIP {
    (Invoke-RestMethod "http://ifconfig.me/ip").Trim()
}

# Enhanced directory listing
function ls {
    param(
        [string]$Path = ".",
        [switch]$l,
        [switch]$a
    )

    $items = Get-ChildItem -Path $Path
    if ($a) { $items = Get-ChildItem -Path $Path -Force }

    if ($l) {
        $items | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
    } else {
        $items | Format-Wide Name -Column 4
    }
}

# Load local profile if it exists
$localProfile = Join-Path (Split-Path $PROFILE) "local.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

# Welcome message
Write-Host "⚡ PowerShell with Oh My Posh is ready! ⚡" -ForegroundColor Green
'@

    # Write profile content
    foreach ($profilePath in $profiles) {
        $profileContent | Out-File -FilePath $profilePath -Encoding UTF8
    }

    Write-Success "PowerShell profile configured"
    Write-Host ""
}

# Setup Windows Terminal configuration
function Setup-WindowsTerminal {
    Write-Section "Setting Up Windows Terminal"

    $wtConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path $wtConfigPath) {
        Write-Info "Backing up existing Windows Terminal settings..."
        Copy-Item $wtConfigPath "$wtConfigPath.backup" -Force

        # Basic Windows Terminal configuration with Nerd Font
        $wtConfig = @{
            '$help' = "https://aka.ms/terminal-documentation"
            '$schema' = "https://aka.ms/terminal-profiles-schema"
            'defaultProfile' = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
            'profiles' = @{
                'defaults' = @{
                    'fontFace' = "CascadiaCode Nerd Font"
                    'fontSize' = 12
                    'cursorShape' = "vintage"
                }
                'list' = @(
                    @{
                        'commandline' = "pwsh.exe"
                        'guid' = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
                        'hidden' = $false
                        'name' = "PowerShell"
                        'source' = "Windows.Terminal.PowershellCore"
                        'colorScheme' = "Campbell Powershell"
                        'fontFace' = "CascadiaCode Nerd Font"
                    }
                )
            }
            'schemes' = @()
            'actions' = @(
                @{ 'command' = @{ 'action' = "copy"; 'singleLine' = $false }; 'keys' = "ctrl+c" }
                @{ 'command' = "paste"; 'keys' = "ctrl+v" }
            )
        }

        $wtConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $wtConfigPath -Encoding UTF8
        Write-Success "Windows Terminal configuration updated"
    }
    else {
        Write-Warning "Windows Terminal not found or not installed"
    }
    Write-Host ""
}

# Final setup and cleanup
function Complete-Setup {
    Write-Section "Final Setup"

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    # Install PSReadLine if not present
    if (-not (Get-Module PSReadLine -ListAvailable)) {
        Write-Info "Installing PSReadLine..."
        Install-Module PSReadLine -Force -AllowClobber
    }

    Write-Success "Setup completed!"
    Write-Host ""
}

# Main execution
function Main {
    Write-Header

    # Check Windows version
    $windowsVersion = [System.Environment]::OSVersion.Version
    if ($windowsVersion.Major -lt 10) {
        Write-Error "This script requires Windows 10 or later"
        exit 1
    }

    Get-SystemInfo
    Install-PackageManagers
    Install-PowerShellCore

    $fontChoice = Select-Font
    Install-NerdFonts $fontChoice

    Install-OhMyPosh
    Install-DevelopmentTools
    Setup-PowerShellProfile
    Setup-WindowsTerminal
    Complete-Setup

    Write-Host "🎉 Windows PowerShell Environment Setup Complete! 🎉" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Restart your terminal or open a new PowerShell window"
    Write-Host "2. Configure Windows Terminal to use a Nerd Font (if not done automatically)"
    Write-Host "3. Run 'Get-PoshThemes' to see available Oh My Posh themes"
    Write-Host "4. Enjoy your modern PowerShell environment!"
    Write-Host ""
    Write-Host "Useful commands to try:" -ForegroundColor Cyan
    Write-Host "  • Get-PoshThemes     - Browse available themes"
    Write-Host "  • oh-my-posh --help  - Oh My Posh help"
    Write-Host "  • neofetch           - Display system information"
    Write-Host "  • Get-Weather        - Check the weather"
    Write-Host ""
}

# Run main function
Main
