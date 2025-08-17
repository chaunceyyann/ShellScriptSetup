# Modern PowerShell Profile
# Optimized for development with Oh My Posh and useful functions

#Requires -Version 5.1

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Editor preferences
$env:EDITOR = if (Get-Command code -ErrorAction SilentlyContinue) { "code" } else { "notepad" }
$env:VISUAL = $env:EDITOR

# Development environment
$env:POWERSHELL_TELEMETRY_OPTOUT = 1

# ============================================================================
# MODULE IMPORTS
# ============================================================================

# Import essential modules
$ModulesToImport = @('PSReadLine')

foreach ($Module in $ModulesToImport) {
    if (Get-Module -ListAvailable -Name $Module) {
        Import-Module $Module -Force -DisableNameChecking
    }
}

# ============================================================================
# OH MY POSH INITIALIZATION
# ============================================================================

# Initialize Oh My Posh with a beautiful theme
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Use a modern theme - you can change this to your preference
    $OhMyPoshTheme = if (Test-Path "$env:POSH_THEMES_PATH\night-owl.omp.json") {
        "$env:POSH_THEMES_PATH\night-owl.omp.json"
    } elseif (Test-Path "$env:POSH_THEMES_PATH\atomic.omp.json") {
        "$env:POSH_THEMES_PATH\atomic.omp.json"
    } else {
        # Fallback to a simple theme
        "$env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json"
    }

    oh-my-posh init pwsh --config $OhMyPoshTheme | Invoke-Expression
}

# ============================================================================
# PSREADLINE CONFIGURATION
# ============================================================================

if (Get-Module PSReadLine) {
    # Set prediction source and view
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView

    # Set edit mode
    Set-PSReadLineOption -EditMode Windows

    # Set colors
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'Cyan'
        Operator           = 'Magenta'
        Variable           = 'Green'
        String             = 'Yellow'
        Number             = 'Red'
        Type               = 'Gray'
        Comment            = 'DarkGreen'
        Keyword            = 'Blue'
        Error              = 'Red'
        Selection          = 'DarkGray'
        InlinePrediction   = 'DarkGray'
    }

    # Key bindings
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord

    # Enable history search
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
}

# ============================================================================
# ALIASES
# ============================================================================

# Basic file operations
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItemAll
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name which -Value Get-Command
Set-Alias -Name curl -Value Invoke-WebRequest
Set-Alias -Name wget -Value Invoke-WebRequest

# Text processing
if (Get-Command grep -ErrorAction SilentlyContinue) {
    # Keep grep if available
} else {
    Set-Alias -Name grep -Value Select-String
}

# Git aliases
Set-Alias -Name g -Value git

# Quick commands
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name h -Value Get-History
Set-Alias -Name q -Value exit

# Editor aliases
Set-Alias -Name e -Value $env:EDITOR
Set-Alias -Name v -Value $env:VISUAL

# ============================================================================
# FUNCTIONS
# ============================================================================

# Enhanced directory listing
function Get-ChildItemAll {
    param(
        [string]$Path = ".",
        [switch]$Force
    )
    Get-ChildItem -Path $Path -Force:$Force | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
}

# Git functions
function gs { git status $args }
function ga { git add $args }
function gaa { git add -A }
function gc { git commit $args }
function gcm { git commit -m $args }
function gca { git commit -am $args }
function gp { git push $args }
function gpl { git pull $args }
function gl { git log --oneline --graph $args }
function gll { git log --oneline --graph --all $args }
function gd { git diff $args }
function gds { git diff --staged $args }
function gb { git branch $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gm { git merge $args }
function gr { git rebase $args }
function gst { git stash $args }
function gsp { git stash pop $args }

# Directory navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }
function - { Set-Location - }

# Create directory and navigate to it
function mkcd {
    param([Parameter(Mandatory=$true)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# Quick backup function
function backup {
    param([Parameter(Mandatory=$true)][string]$File)
    $BackupName = "$File.bak"
    Copy-Item $File $BackupName
    Write-Host "✅ Backup created: $BackupName" -ForegroundColor Green
}

# Create new file (like touch in Unix)
function touch {
    param([Parameter(Mandatory=$true)][string]$File)
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $File -Force | Out-Null
    }
}

# Find and kill process by name
function killp {
    param([Parameter(Mandatory=$true)][string]$ProcessName)

    $processes = Get-Process | Where-Object { $_.ProcessName -like "*$ProcessName*" }

    if ($processes.Count -eq 0) {
        Write-Host "❌ No process found matching: $ProcessName" -ForegroundColor Red
        return
    }

    Write-Host "Found processes:" -ForegroundColor Yellow
    $processes | Format-Table Id, ProcessName, CPU, WorkingSet

    $confirm = Read-Host "Kill these processes? [y/N]"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        $processes | Stop-Process -Force
        Write-Host "✅ Processes killed" -ForegroundColor Green
    } else {
        Write-Host "❌ Cancelled" -ForegroundColor Yellow
    }
}

# Simple HTTP server
function serve {
    param([int]$Port = 8000)

    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host "🌐 Starting HTTP server on port $Port..." -ForegroundColor Green
        Write-Host "📂 Serving current directory: $(Get-Location)" -ForegroundColor Cyan
        Write-Host "🔗 Access at: http://localhost:$Port" -ForegroundColor Yellow
        python -m http.server $Port
    } else {
        Write-Host "❌ Python not found. Please install Python to use this function." -ForegroundColor Red
    }
}

# Generate random password
function New-Password {
    param([int]$Length = 16)

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $password = -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })

    Write-Host "Generated password: $password" -ForegroundColor Green
    $password | Set-Clipboard
    Write-Host "✅ Password copied to clipboard" -ForegroundColor Yellow
}

# System information
function Get-SystemInfo {
    $computerInfo = Get-ComputerInfo
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $disk = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

    Write-Host "🖥️  System Information" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Hostname    : $env:COMPUTERNAME"
    Write-Host "OS          : $($computerInfo.WindowsProductName)"
    Write-Host "Version     : $($computerInfo.WindowsVersion)"
    Write-Host "Architecture: $env:PROCESSOR_ARCHITECTURE"
    Write-Host "CPU         : $($cpu.Name)"
    Write-Host "Cores       : $($cpu.NumberOfCores)"
    Write-Host "RAM         : $([math]::Round($memory.Sum / 1GB, 2)) GB"
    Write-Host "PowerShell  : $($PSVersionTable.PSVersion)"

    Write-Host "`n💽 Disk Information" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    foreach ($d in $disk) {
        $freeSpace = [math]::Round($d.FreeSpace / 1GB, 2)
        $totalSpace = [math]::Round($d.Size / 1GB, 2)
        $usedPercent = [math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 1)
        Write-Host "Drive $($d.DeviceID): $freeSpace GB free of $totalSpace GB ($usedPercent% used)"
    }
}

# Network information
function Get-NetworkInfo {
    Write-Host "🌐 Network Information" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    # Get public IP
    try {
        $publicIP = (Invoke-RestMethod "http://ifconfig.me/ip").Trim()
        Write-Host "Public IP   : $publicIP"
    } catch {
        Write-Host "Public IP   : Unable to retrieve"
    }

    # Get network adapters
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        $ipAddress = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty IPAddress
        Write-Host "Interface   : $($adapter.Name)"
        Write-Host "Local IP    : $ipAddress"
        Write-Host "MAC Address : $($adapter.MacAddress)"
        Write-Host ""
    }
}

# Weather function
function Get-Weather {
    param([string]$City = "")

    $url = if ($City) { "http://wttr.in/$City" } else { "http://wttr.in" }
    try {
        Invoke-RestMethod $url
    } catch {
        Write-Host "❌ Unable to retrieve weather information" -ForegroundColor Red
    }
}

# Git commit and push
function gcp {
    param([Parameter(Mandatory=$true)][string]$Message)

    git add -A
    git commit -m $Message
    git push
}

# Quick project setup
function New-Project {
    param([Parameter(Mandatory=$true)][string]$ProjectName)

    $projectPath = Join-Path (Get-Location) $ProjectName
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    Set-Location $projectPath

    # Initialize git
    git init
    "# $ProjectName" | Out-File -FilePath "README.md" -Encoding UTF8

    # Create .gitignore
    @"
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log

# Dependencies
node_modules/

# Environment variables
.env
.env.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

    git add .
    git commit -m "Initial commit"

    Write-Host "✅ Project '$ProjectName' created and initialized" -ForegroundColor Green
}

# Extract various archive formats
function Expand-Archive-Extended {
    param([Parameter(Mandatory=$true)][string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Host "❌ File not found: $Path" -ForegroundColor Red
        return
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLower()

    switch ($extension) {
        ".zip" {
            Expand-Archive -Path $Path -DestinationPath (Get-Location)
        }
        ".rar" {
            if (Get-Command unrar -ErrorAction SilentlyContinue) {
                unrar e $Path
            } else {
                Write-Host "❌ unrar not found. Please install WinRAR or 7-Zip" -ForegroundColor Red
            }
        }
        ".7z" {
            if (Get-Command 7z -ErrorAction SilentlyContinue) {
                7z x $Path
            } else {
                Write-Host "❌ 7z not found. Please install 7-Zip" -ForegroundColor Red
            }
        }
        default {
            Write-Host "❌ Unsupported archive format: $extension" -ForegroundColor Red
        }
    }
}

Set-Alias -Name extract -Value Expand-Archive-Extended

# ============================================================================
# STARTUP MESSAGE
# ============================================================================

function Show-WelcomeMessage {
    $currentTime = Get-Date
    $greeting = switch ($currentTime.Hour) {
        { $_ -lt 12 } { "Good morning" }
        { $_ -lt 17 } { "Good afternoon" }
        default { "Good evening" }
    }

    Write-Host "⚡ $greeting, $env:USERNAME! ⚡" -ForegroundColor Green
    Write-Host "📅 $($currentTime.ToString('dddd, MMMM dd, yyyy \at h:mm tt'))" -ForegroundColor Yellow

    # Show current directory if not home
    $currentDir = Get-Location
    $homeDir = $env:USERPROFILE
    if ($currentDir.Path -ne $homeDir) {
        Write-Host "📂 Current directory: $(Split-Path $currentDir -Leaf)" -ForegroundColor Cyan
    }

    # Show Git status if in a Git repository
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            $gitBranch = git branch --show-current 2>$null
            if ($gitBranch) {
                Write-Host "🌿 Git branch: $gitBranch" -ForegroundColor Magenta
            }
        } catch {
            # Not in a Git repository
        }
    }

    Write-Host ""
}

# ============================================================================
# LOAD ADDITIONAL CONFIGURATIONS
# ============================================================================

# Load local configuration if it exists
$localProfile = Join-Path (Split-Path $PROFILE) "local.ps1"
if (Test-Path $localProfile) {
    . $localProfile
}

# Load work-specific configuration if it exists
$workProfile = Join-Path (Split-Path $PROFILE) "work.ps1"
if (Test-Path $workProfile) {
    . $workProfile
}

# ============================================================================
# STARTUP
# ============================================================================

# Show welcome message
Show-WelcomeMessage

# Check for updates reminder (Windows)
$lastCheckFile = Join-Path $env:USERPROFILE ".last_update_check"
$currentTime = Get-Date
$weekInSeconds = 604800

if (-not (Test-Path $lastCheckFile) -or
    ((Get-Date) - (Get-Item $lastCheckFile).LastWriteTime).TotalSeconds -gt $weekInSeconds) {
    $currentTime | Out-File $lastCheckFile
    Write-Host "💡 Consider running 'winget upgrade --all' or 'choco upgrade all' to update your packages" -ForegroundColor Yellow
}
