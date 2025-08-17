# Setup Guide

This guide will walk you through setting up your modern development environment.

## Quick Start

### One-Command Installation

```bash
# Clone and install automatically
git clone https://github.com/yourusername/ShellScriptSetup.git
cd ShellScriptSetup
./install.sh --auto
```

### Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ShellScriptSetup.git
   cd ShellScriptSetup
   ```

2. **Run the installer**
   ```bash
   ./install.sh
   ```

3. **Follow the interactive prompts**

## Platform-Specific Setup

### 🍎 macOS Setup

The macOS setup script will install and configure:

- **Homebrew** package manager
- **Fish Shell** as default shell
- **Oh My Fish** framework
- **Nerd Fonts** (your choice)
- **Development tools** (git, curl, jq, etc.)
- **Modern aliases and functions**

```bash
# Run macOS-specific setup
./setup/macos-setup.sh
```

#### Prerequisites
- macOS 10.15+ (Catalina or later)
- Xcode Command Line Tools
- Internet connection

#### What gets installed
- Fish shell with Oh My Fish
- Essential development tools via Homebrew
- Nerd Fonts for terminal icons
- Modern shell configuration

### 🪟 Windows Setup

The Windows setup script will install and configure:

- **Package managers** (Chocolatey, Winget)
- **PowerShell Core** (if needed)
- **Oh My Posh** for beautiful prompts
- **Nerd Fonts** (your choice)
- **Windows Terminal** configuration
- **Development tools**

```powershell
# Run as Administrator
.\setup\windows-setup.ps1
```

#### Prerequisites
- Windows 10/11
- PowerShell 5.1+ (PowerShell 7+ recommended)
- Administrator privileges
- Internet connection

#### What gets installed
- PowerShell with Oh My Posh
- Windows Terminal with proper font configuration
- Essential development tools
- Modern PowerShell profile

### 🐧 Linux Setup (Legacy)

The original Linux setup is preserved for compatibility:

```bash
./legacy/bashSetup.sh
```

This provides the original functionality for bash/zsh setup.

## Font Installation

### Automatic Font Installation

Fonts are installed automatically during the main setup, but you can also install them separately:

```bash
# Install fonts only
./install.sh --fonts-only

# Or use the dedicated script
./setup/fonts/install-nerd-fonts.sh
```

### Available Fonts

- **Cascadia Code Nerd Font** - Microsoft's modern monospace font
- **Source Code Pro Nerd Font** - Adobe's popular programming font
- **Fira Code Nerd Font** - Font with programming ligatures
- **JetBrains Mono Nerd Font** - JetBrains' developer font

### Manual Font Installation

If automatic installation fails, you can download fonts manually:

1. Go to [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases)
2. Download your preferred font
3. Install according to your OS:
   - **macOS**: Double-click `.ttf` files or use Font Book
   - **Windows**: Right-click `.ttf` files and select "Install"
   - **Linux**: Copy to `~/.local/share/fonts/` and run `fc-cache -fv`

## Terminal Configuration

### macOS Terminal Apps

#### iTerm2 (Recommended)
1. Install: `brew install --cask iterm2`
2. Preferences → Profiles → Text → Font
3. Select a Nerd Font (e.g., "CascadiaCode Nerd Font")
4. Enable: "Use built-in Powerline glyphs"

#### Terminal.app
1. Preferences → Profiles → Font
2. Select a Nerd Font
3. May need to adjust spacing

### Windows Terminal

The setup script automatically configures Windows Terminal, but you can manually:

1. Open Windows Terminal
2. Settings (Ctrl+,)
3. Profiles → PowerShell → Appearance
4. Font face: "CascadiaCode Nerd Font"

### Linux Terminal Apps

#### GNOME Terminal
1. Preferences → Profiles → Text
2. Custom font: Select Nerd Font
3. Uncheck "Use system fixed width font"

#### Alacritty
Add to `~/.config/alacritty/alacritty.yml`:
```yaml
font:
  normal:
    family: "CascadiaCode Nerd Font"
    style: Regular
  size: 12.0
```

## Shell Configuration

### Fish Shell (macOS)

Configuration is automatically created at `~/.config/fish/config.fish`.

#### Key Features
- Git-aware prompt with Oh My Fish
- Enhanced aliases (using exa, bat, ripgrep when available)
- Useful functions for development
- Auto-completion and syntax highlighting

#### Customization
Create `~/.config/fish/local.fish` for personal customizations.

### PowerShell (Windows)

Profile is automatically created for all PowerShell versions.

#### Key Features
- Oh My Posh integration with beautiful themes
- Enhanced PSReadLine configuration
- Git aliases and functions
- Cross-platform compatibility

#### Customization
Create `local.ps1` in the same directory as your profile for personal customizations.

## Troubleshooting

### Common Issues

#### Fonts not displaying correctly
- Ensure terminal is configured to use a Nerd Font
- Restart terminal after font installation
- Check font installation: `fc-list | grep -i nerd` (Linux/macOS)

#### Permission denied errors
- Ensure scripts are executable: `chmod +x script-name.sh`
- Run with appropriate privileges (sudo for system-wide changes)

#### Shell not changing (macOS)
- Add Fish to `/etc/shells`: `echo $(which fish) | sudo tee -a /etc/shells`
- Change default shell: `chsh -s $(which fish)`
- Restart terminal

#### Oh My Posh not loading (Windows)
- Check PowerShell execution policy: `Get-ExecutionPolicy`
- Set if needed: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Restart PowerShell

### Getting Help

1. Check this documentation
2. Look at the scripts' `--help` options
3. Check the [Issues](https://github.com/yourusername/ShellScriptSetup/issues) page
4. Create a new issue with:
   - Your operating system and version
   - Terminal application
   - Error messages
   - Steps to reproduce

## Advanced Configuration

### Custom Themes

#### Fish with Oh My Fish
```bash
# List available themes
omf theme

# Install a new theme
omf install bobthefish

# Set theme
omf theme bobthefish
```

#### PowerShell with Oh My Posh
```powershell
# List available themes
Get-PoshThemes

# Set a different theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression
```

### Adding Custom Functions

#### Fish Shell
Add to `~/.config/fish/local.fish`:
```bash
function my_custom_function
    echo "Hello from custom function!"
end
```

#### PowerShell
Add to your local profile:
```powershell
function My-CustomFunction {
    Write-Host "Hello from custom function!" -ForegroundColor Green
}
```

### Environment Variables

#### Fish Shell
```bash
# Add to config.fish
set -gx MY_VARIABLE "value"
```

#### PowerShell
```powershell
# Add to profile
$env:MY_VARIABLE = "value"
```
