#!/bin/bash

# Nerd Fonts Installation Script for macOS/Linux
# Supports automated installation of popular Nerd Fonts

set -e

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# Font definitions
declare -A FONTS=(
    ["cascadia"]="CascadiaCode"
    ["source"]="SourceCodePro"
    ["fira"]="FiraCode"
    ["jetbrains"]="JetBrainsMono"
    ["hack"]="Hack"
    ["inconsolata"]="Inconsolata"
    ["ubuntu"]="UbuntuMono"
    ["dejavu"]="DejaVuSansMono"
)

print_header() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    🔤 Nerd Fonts Installer 🔤${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
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

# Check operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        FONT_DIR="$HOME/Library/Fonts"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        FONT_DIR="$HOME/.local/share/fonts"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    print_info "Detected OS: $OS"
    print_info "Font directory: $FONT_DIR"
    echo
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install via Homebrew (macOS)
install_via_homebrew() {
    local font_name="$1"
    local cask_name="font-${font_name,,}-nerd-font"

    print_info "Installing $font_name via Homebrew..."

    # Add fonts tap if not already added
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_info "Adding Homebrew Fonts tap..."
        brew tap homebrew/cask-fonts
    fi

    if brew list --cask | grep -q "$cask_name"; then
        print_success "$font_name already installed via Homebrew"
        return 0
    fi

    if brew install --cask "$cask_name"; then
        print_success "$font_name installed via Homebrew"
        return 0
    else
        print_warning "Failed to install $font_name via Homebrew"
        return 1
    fi
}

# Install via package manager (Linux)
install_via_package_manager() {
    local font_name="$1"

    if command_exists apt-get; then
        # Debian/Ubuntu
        local package_name="fonts-${font_name,,}-nerd-font"
        if apt list --installed 2>/dev/null | grep -q "$package_name"; then
            print_success "$font_name already installed via apt"
            return 0
        fi

        print_info "Installing $font_name via apt..."
        if sudo apt-get update && sudo apt-get install -y "$package_name"; then
            print_success "$font_name installed via apt"
            return 0
        fi
    elif command_exists pacman; then
        # Arch Linux
        local package_name="ttf-${font_name,,}-nerd"
        if pacman -Qi "$package_name" >/dev/null 2>&1; then
            print_success "$font_name already installed via pacman"
            return 0
        fi

        print_info "Installing $font_name via pacman..."
        if sudo pacman -S --noconfirm "$package_name"; then
            print_success "$font_name installed via pacman"
            return 0
        fi
    elif command_exists dnf; then
        # Fedora
        local package_name="${font_name,,}-fonts"
        if rpm -q "$package_name" >/dev/null 2>&1; then
            print_success "$font_name already installed via dnf"
            return 0
        fi

        print_info "Installing $font_name via dnf..."
        if sudo dnf install -y "$package_name"; then
            print_success "$font_name installed via dnf"
            return 0
        fi
    fi

    print_warning "Could not install $font_name via package manager"
    return 1
}

# Manual installation from GitHub releases
install_manually() {
    local font_name="$1"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    local temp_dir=$(mktemp -d)

    print_info "Installing $font_name manually from GitHub..."

    # Create font directory if it doesn't exist
    mkdir -p "$FONT_DIR"

    # Download font
    print_info "Downloading $font_name..."
    if ! curl -L "$download_url" -o "$temp_dir/${font_name}.zip"; then
        print_error "Failed to download $font_name"
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract fonts
    print_info "Extracting fonts..."
    if ! unzip -q "$temp_dir/${font_name}.zip" -d "$temp_dir"; then
        print_error "Failed to extract $font_name"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install font files
    local font_files=0
    while IFS= read -r -d '' font_file; do
        cp "$font_file" "$FONT_DIR/"
        ((font_files++))
    done < <(find "$temp_dir" -name "*.ttf" -o -name "*.otf" -print0)

    # Clean up
    rm -rf "$temp_dir"

    if [[ $font_files -gt 0 ]]; then
        print_success "$font_name installed manually ($font_files font files)"

        # Update font cache on Linux
        if [[ "$OS" == "linux" ]]; then
            print_info "Updating font cache..."
            fc-cache -fv "$FONT_DIR" >/dev/null 2>&1 || true
        fi

        return 0
    else
        print_error "No font files found for $font_name"
        return 1
    fi
}

# Install a single font
install_font() {
    local font_key="$1"
    local font_name="${FONTS[$font_key]}"

    if [[ -z "$font_name" ]]; then
        print_error "Unknown font: $font_key"
        return 1
    fi

    print_section "Installing $font_name Nerd Font"

    # Try package manager first, then manual installation
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            if install_via_homebrew "$font_name"; then
                return 0
            fi
        fi
    elif [[ "$OS" == "linux" ]]; then
        if install_via_package_manager "$font_name"; then
            return 0
        fi
    fi

    # Fallback to manual installation
    install_manually "$font_name"
}

# Show available fonts
show_fonts() {
    print_section "Available Nerd Fonts"
    echo
    for key in "${!FONTS[@]}"; do
        printf "  %-12s %s\n" "$key" "${FONTS[$key]}"
    done
    echo
}

# Interactive font selection
interactive_selection() {
    show_fonts

    echo "Enter font keys to install (space-separated), or 'all' for all fonts:"
    read -r selection

    if [[ "$selection" == "all" ]]; then
        for font_key in "${!FONTS[@]}"; do
            install_font "$font_key"
        done
    else
        for font_key in $selection; do
            install_font "$font_key"
        done
    fi
}

# Main function
main() {
    print_header
    detect_os

    if [[ $# -eq 0 ]]; then
        interactive_selection
    elif [[ "$1" == "--list" || "$1" == "-l" ]]; then
        show_fonts
    elif [[ "$1" == "--all" ]]; then
        print_section "Installing all available Nerd Fonts"
        for font_key in "${!FONTS[@]}"; do
            install_font "$font_key"
        done
    else
        for font_arg in "$@"; do
            install_font "$font_arg"
        done
    fi

    echo
    print_success "Font installation completed!"
    echo
    print_info "Note: You may need to restart your terminal application to see the new fonts."

    if [[ "$OS" == "macos" ]]; then
        echo "You can also check installed fonts in Font Book.app"
    elif [[ "$OS" == "linux" ]]; then
        echo "You can list installed fonts with: fc-list | grep -i nerd"
    fi
    echo
}

# Help function
show_help() {
    echo "Nerd Fonts Installer"
    echo
    echo "Usage: $0 [OPTIONS] [FONTS...]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --list     List available fonts"
    echo "      --all      Install all available fonts"
    echo
    echo "Available fonts:"
    for key in "${!FONTS[@]}"; do
        printf "  %-12s %s\n" "$key" "${FONTS[$key]}"
    done
    echo
    echo "Examples:"
    echo "  $0                    # Interactive selection"
    echo "  $0 cascadia source    # Install Cascadia Code and Source Code Pro"
    echo "  $0 --all              # Install all fonts"
    echo
}

# Check for help argument
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Run main function
main "$@"
