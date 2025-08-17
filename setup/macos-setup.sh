#!/bin/bash

# Modern macOS Development Environment Setup
# Features: Fish Shell + Oh My Fish + Nerd Fonts + Development Tools
# Author: Modern Shell Setup
# Version: 2.0

set -e  # Exit on error

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Font choices
readonly CASCADIA_FONT="CascadiaCode"
readonly SOURCE_CODE_FONT="SourceCodePro"

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    🐟 macOS Fish Shell Setup 🐟${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo
}

print_section() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# System information
check_system() {
    print_section "System Information"

    echo "Hostname    : $(hostname)"
    echo "macOS       : $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Architecture: $(uname -m)"
    echo "Shell       : $SHELL"
    echo "User        : $USER"
    echo
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not present
install_homebrew() {
    print_section "Installing Homebrew"

    if command_exists brew; then
        print_success "Homebrew already installed"
        brew --version
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed successfully"
    fi
    echo
}

# Install Fish shell
install_fish() {
    print_section "Installing Fish Shell"

    if command_exists fish; then
        print_success "Fish shell already installed"
        fish --version
    else
        print_info "Installing Fish shell via Homebrew..."
        brew install fish
        print_success "Fish shell installed"
    fi

    # Add Fish to /etc/shells if not present
    if ! grep -q "$(which fish)" /etc/shells; then
        print_info "Adding Fish to /etc/shells..."
        echo "$(which fish)" | sudo tee -a /etc/shells
    fi

    echo
}

# Change default shell to Fish
change_default_shell() {
    print_section "Setting Fish as Default Shell"

    if [[ "$SHELL" == *"fish" ]]; then
        print_success "Fish is already the default shell"
    else
        print_info "Changing default shell to Fish..."
        chsh -s "$(which fish)"
        print_success "Default shell changed to Fish (restart terminal to take effect)"
    fi
    echo
}

# Install Oh My Fish
install_oh_my_fish() {
    print_section "Installing Oh My Fish"

    if [[ -d "$HOME/.local/share/omf" ]]; then
        print_success "Oh My Fish already installed"
    else
        print_info "Installing Oh My Fish..."
        curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
        print_success "Oh My Fish installed"
    fi
    echo
}

# Font selection menu
select_font() {
    print_section "Font Selection"

    echo "Please select a Nerd Font to install:"
    echo "1) Cascadia Code Nerd Font (Microsoft's modern font)"
    echo "2) Source Code Pro Nerd Font (Adobe's popular font)"
    echo "3) Both fonts"
    echo "4) Skip font installation"
    echo

    while true; do
        read -p "Enter your choice (1-4): " font_choice
        case $font_choice in
            1)
                SELECTED_FONTS=("$CASCADIA_FONT")
                break
                ;;
            2)
                SELECTED_FONTS=("$SOURCE_CODE_FONT")
                break
                ;;
            3)
                SELECTED_FONTS=("$CASCADIA_FONT" "$SOURCE_CODE_FONT")
                break
                ;;
            4)
                SELECTED_FONTS=()
                print_warning "Skipping font installation"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    echo
}

# Install Nerd Fonts
install_nerd_fonts() {
    if [[ ${#SELECTED_FONTS[@]} -eq 0 ]]; then
        return
    fi

    print_section "Installing Nerd Fonts"

    # Add Homebrew Fonts tap
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Adding Homebrew Fonts tap..."
        brew tap homebrew/cask-fonts
    fi

    for font in "${SELECTED_FONTS[@]}"; do
        font_cask="font-${font,,}-nerd-font"  # Convert to lowercase

        if brew list --cask | grep -q "$font_cask"; then
            print_success "$font Nerd Font already installed"
        else
            print_info "Installing $font Nerd Font..."
            brew install --cask "$font_cask"
            print_success "$font Nerd Font installed"
        fi
    done
    echo
}

# Install development tools
install_dev_tools() {
    print_section "Installing Development Tools"

    local tools=(
        "git"
        "wget"
        "curl"
        "jq"
        "tree"
        "htop"
        "neofetch"
        "bat"
        "exa"
        "fd"
        "ripgrep"
        "fzf"
    )

    print_info "Installing essential development tools..."

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
        fi
    done

    # Install fun tools
    print_info "Installing fun terminal tools..."
    local fun_tools=("cowsay" "fortune" "figlet" "lolcat")

    for tool in "${fun_tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool already installed"
        else
            brew install "$tool" 2>/dev/null || print_warning "Failed to install $tool"
        fi
    done

    echo
}

# Setup Fish configuration
setup_fish_config() {
    print_section "Setting Up Fish Configuration"

    local fish_config_dir="$HOME/.config/fish"
    local config_file="$fish_config_dir/config.fish"

    # Create config directory if it doesn't exist
    mkdir -p "$fish_config_dir"

    # Create or update config.fish
    cat > "$config_file" << 'EOF'
# Fish shell configuration
# Generated by macOS setup script

# Set greeting
set fish_greeting "🐟 Welcome to Fish Shell! 🐟"

# Environment variables
set -gx EDITOR vim
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Homebrew paths (for Apple Silicon Macs)
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
end

# User bin path
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# Common aliases
alias ls='exa --group-directories-first --icons'
alias ll='exa -l --group-directories-first --icons'
alias la='exa -la --group-directories-first --icons'
alias tree='exa --tree --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias top='htop'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Quick commands
alias c='clear'
alias h='history'
alias q='exit'

# Fun commands
alias weather='curl wttr.in'
alias myip='curl ifconfig.me'

# Custom functions
function mkcd
    mkdir -p $argv && cd $argv
end

function backup
    cp $argv $argv.bak
end

function extract
    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar e $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
            echo "Unknown archive format"
    end
end

# Load additional configurations if they exist
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
EOF

    print_success "Fish configuration created at $config_file"
    echo
}

# Install and configure Oh My Fish theme
setup_omf_theme() {
    print_section "Setting Up Oh My Fish Theme"

    print_info "Installing useful OMF packages..."

    # Install in Fish shell context
    fish -c "
        # Install useful packages
        omf install shellder
        omf install bass  # For bash compatibility
        omf install z     # Directory jumping
        omf install grc   # Generic colorizer

        # Set theme
        omf theme shellder
    " 2>/dev/null || print_warning "Some OMF packages may have failed to install"

    print_success "Oh My Fish theme and packages configured"
    echo
}

# Create completion and cleanup
final_setup() {
    print_section "Final Setup"

    # Update Homebrew
    print_info "Updating Homebrew..."
    brew update

    # Copy custom cowfiles if they exist
    if [[ -d "$(dirname "$0")/../dotFiles/cows" ]]; then
        local cow_dir="/usr/local/share/cowsay/cows"
        if [[ -d "$cow_dir" ]]; then
            print_info "Copying custom cowfiles..."
            sudo cp "$(dirname "$0")/../dotFiles/cows"/*.cow "$cow_dir/" 2>/dev/null || true
        fi
    fi

    print_success "Setup completed!"
    echo
}

# Main execution
main() {
    print_header

    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi

    check_system
    install_homebrew
    install_fish
    change_default_shell
    install_oh_my_fish
    select_font
    install_nerd_fonts
    install_dev_tools
    setup_fish_config
    setup_omf_theme
    final_setup

    echo -e "${GREEN}🎉 macOS Fish Shell Environment Setup Complete! 🎉${NC}"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal or run: exec fish"
    echo "2. Configure your terminal app to use a Nerd Font"
    echo "3. Enjoy your modern Fish shell environment!"
    echo
    echo -e "${CYAN}Useful commands to try:${NC}"
    echo "  • fish_config    - Open Fish web-based configuration"
    echo "  • omf list       - List installed OMF packages"
    echo "  • omf theme      - Change OMF theme"
    echo "  • neofetch       - Display system information"
    echo
}

# Run main function
main "$@"
