# Modern Development Environment Setup
> Cross-platform shell and development environment configuration tool

## 🎯 Purpose

This repository provides automated setup scripts for modern development environments across macOS, Windows, and Linux. It focuses on creating beautiful, functional shell environments with proper font support and modern tooling.

## ✨ Features

### 🍎 macOS Setup
- **Fish Shell** with Oh My Fish framework
- **Nerd Fonts** (Cascadia Code or Source Code Pro)
- Modern prompt themes and plugins
- Development tools integration

### 🪟 Windows Setup
- **PowerShell** with Oh My Posh
- **Nerd Fonts** for consistent iconography
- Windows Terminal configuration
- Cross-platform tool detection

### 🐧 Linux Setup (Legacy)
- Bash/Zsh configuration
- Vim setup with color schemes
- Git and Tmux configuration
- System information reporting

## 🚀 Quick Start

### macOS
```bash
# Run the macOS setup script
./setup/macos-setup.sh
```

### Windows
```powershell
# Run the Windows setup script (as Administrator)
.\setup\windows-setup.ps1
```

### Linux (Legacy)
```bash
# Run the original Linux setup
./bashSetup.sh
```

## 📁 Repository Structure

```
ShellScriptSetup/
├── setup/                    # Modern setup scripts
│   ├── macos-setup.sh       # macOS Fish + OMF setup
│   ├── windows-setup.ps1    # Windows PowerShell + OMP setup
│   └── fonts/               # Font installation scripts
├── configs/                 # Modern configuration files
│   ├── fish/               # Fish shell configs
│   ├── powershell/         # PowerShell profiles
│   └── shared/             # Cross-platform configs
├── dotFiles/               # Legacy dotfiles (maintained)
├── scripts/                # Utility scripts
└── legacy/                 # Original setup scripts
```

## 🎨 Included Themes & Fonts

### Nerd Fonts
- **Cascadia Code Nerd Font** - Microsoft's modern monospace font
- **Source Code Pro Nerd Font** - Adobe's popular programming font

### Themes
- **Fish**: Modern, Git-aware prompts with async loading
- **PowerShell**: Cross-platform Oh My Posh themes with icons

## 🛠️ What Gets Configured

- ✅ Shell environment (Fish/PowerShell)
- ✅ Modern prompt with Git integration
- ✅ Nerd Font installation and configuration
- ✅ Common development tools detection
- ✅ Useful aliases and functions
- ✅ Color schemes and themes
- ✅ Package manager setup (Homebrew/Chocolatey)

## 📋 Requirements

### macOS
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools
- Internet connection for downloads

### Windows
- Windows 10/11
- PowerShell 5.1+ (PowerShell 7+ recommended)
- Administrator privileges for font installation
- Internet connection for downloads

## 🤝 Contributing

Feel free to contribute improvements, additional themes, or support for other platforms!
