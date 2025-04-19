# This is a powershell setup script
# check if the script is running in powershell
if ($PSVersionTable.PSEdition -ne "Desktop" -and $PSVersionTable.PSEdition -ne "Core") {
    Write-Error "This script must be run in PowerShell"
    exit 1
}
Write-Host "PowerShell version $($PSVersionTable.PSVersion) detected"

# check system information
Write-Host "################################"
Write-Host "Checking system configurations..."

# Get system info
$computerInfo = Get-ComputerInfo
$processorInfo = Get-WmiObject Win32_Processor
$memoryInfo = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
$diskInfo = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
$networkInfo = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

# Display system info
Write-Host "################################"
Write-Host "Hostname : $($env:COMPUTERNAME)"
Write-Host "OS       : $($computerInfo.WindowsProductName)"
Write-Host "Version  : $($computerInfo.WindowsVersion)"
Write-Host "Architecture: $($env:PROCESSOR_ARCHITECTURE)"

# CPU info
Write-Host "`nProcessor Information:"
Write-Host "CPU      : $($processorInfo.Name)"
Write-Host "Cores    : $($processorInfo.NumberOfCores)"
Write-Host "Logical Processors: $($processorInfo.NumberOfLogicalProcessors)"

# Memory info
$totalRAM = [math]::Round($memoryInfo.Sum / 1GB, 2)
Write-Host "`nMemory Information:"
Write-Host "Total RAM: $totalRAM GB"

# Disk info
Write-Host "`nDisk Information:"
foreach ($disk in $diskInfo) {
    $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
    $totalSpace = [math]::Round($disk.Size / 1GB, 2)
    Write-Host "Drive $($disk.DeviceID): $freeSpace GB free of $totalSpace GB"
}

# Network info
Write-Host "`nNetwork Information:"
foreach ($adapter in $networkInfo) {
    $ipAddress = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress
    $adapterType = if ($adapter.PhysicalMediaType -eq "802.11") { "WiFi" } else { "LAN" }
    Write-Host "Adapter: $($adapter.Name) ($adapterType)"
    Write-Host "IP     : $ipAddress"
}
# Check GPU information
$gpuInfo = Get-WmiObject Win32_VideoController
Write-Host "`nGPU Information:"
foreach ($gpu in $gpuInfo) {
    Write-Host "GPU      : $($gpu.Name)"
    Write-Host "Driver   : $($gpu.DriverVersion)"
}

# Check for NVIDIA GPU and tools
$nvidiaGPU = $gpuInfo | Where-Object { $_.Name -like "*NVIDIA*" }
if ($nvidiaGPU) {
    Write-Host "`nNVIDIA GPU detected"
    
    # Check NVIDIA driver version using nvidia-smi
    try {
        $nvidiaSmi = & "nvidia-smi" "--query-gpu=driver_version" "--format=csv,noheader"
        Write-Host "NVIDIA Driver: $nvidiaSmi"
    } catch {
        Write-Host "Could not get NVIDIA driver version using nvidia-smi"
    }

    # Check CUDA version
    try {
        $nvcc = & "nvcc" "--version" 2>&1
        if ($nvcc -match "release (\d+\.\d+)") {
            Write-Host "CUDA Version: $($matches[1])"
        }
    } catch {
        Write-Host "CUDA not found or not installed"
    }

    # Check cuDNN version
    $cudnnDll = "C:\Windows\System32\cudnn64*.dll"
    if (Test-Path $cudnnDll) {
        $cudnnVersion = (Get-Item $cudnnDll).VersionInfo.FileVersion
        Write-Host "cuDNN Version: $cudnnVersion"
    } else {
        Write-Host "cuDNN not found or not installed"
    }
}

# check common tools:
Write-Host "`nChecking Common Development Tools:"

# Function to check if a command exists
function Test-CommandExists {
    param ($command)
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    } catch {
        return $false
    }
}

# Array of tools to check
$tools = @(
    @{
        Name="Python"; 
        Command="python"; 
        VersionArg="--version";
        InstallCommand="winget install Python.Python.3.11";
        InstallNote="Or use: choco install python"
    },
    @{
        Name="Anaconda"; 
        Command="conda"; 
        VersionArg="--version";
        InstallCommand="winget install Anaconda.Miniconda3";
        InstallNote="Or use: choco install miniconda3"
    },
    @{
        Name="Node.js"; 
        Command="node"; 
        VersionArg="--version";
        InstallCommand="winget install OpenJS.NodeJS";
        InstallNote="Or use: choco install nodejs"
    },
    @{
        Name="Java"; 
        Command="java"; 
        VersionArg="--version";
        InstallCommand="winget install Oracle.JDK.17";
        InstallNote="Or use: choco install openjdk"
    },
    @{
        Name="Go"; 
        Command="go"; 
        VersionArg="version";
        InstallCommand="winget install GoLang.Go";
        InstallNote="Or use: choco install golang"
    },
    @{
        Name="Rust"; 
        Command="rustc"; 
        VersionArg="--version";
        InstallCommand="winget install Rustlang.Rust";
        InstallNote="Or use: choco install rust"
    },
    @{
        Name="Docker"; 
        Command="docker"; 
        VersionArg="--version";
        InstallCommand="winget install Docker.DockerDesktop";
        InstallNote="Or use: choco install docker-desktop"
    },
    @{
        Name="Kubernetes CLI"; 
        Command="kubectl"; 
        VersionArg="version --client";
        InstallCommand="winget install Kubernetes.kubectl";
        InstallNote="Or use: choco install kubernetes-cli"
    },
    @{
        Name="Git"; 
        Command="git"; 
        VersionArg="--version";
        InstallCommand="winget install Git.Git";
        InstallNote="Or use: choco install git"
    },
    @{
        Name="Vim"; 
        Command="vim"; 
        VersionArg="--version";
        InstallCommand="winget install Vim.Vim";
        InstallNote="Or use: choco install vim"
    },
    @{
        Name="Tmux"; 
        Command="tmux"; 
        VersionArg="-V";
        InstallCommand="winget install Tmux.Tmux";
        InstallNote="Or use: choco install tmux"
    }
)

foreach ($tool in $tools) {
    if (Test-CommandExists $tool.Command) {
        try {
            $version = & $tool.Command $tool.VersionArg 2>&1
            Write-Host "$($tool.Name) : Installed ($(($version -split "`n")[0]))"
        } catch {
            Write-Host "$($tool.Name) : Installed (Version check failed)"
        }
    } else {
        Write-Host "$($tool.Name) : Not installed"
        Write-Host "  To install, run: $($tool.InstallCommand)"
        Write-Host "  $($tool.InstallNote)"
    }
}
