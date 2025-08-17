#!/bin/bash

# Universal Installation Script for Modern Shell Setup
# Automatically detects OS and runs appropriate setup script

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}              🚀 Modern Shell Environment Setup 🚀${NC}"
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

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        SETUP_SCRIPT="setup/macos-setup.sh"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        SETUP_SCRIPT="legacy/bashSetup.sh"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        OS="windows"
        SETUP_SCRIPT="setup/windows-setup.ps1"
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi

    print_info "Detected OS: $OS"
}

# Check if script exists
check_setup_script() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local full_script_path="$script_dir/$SETUP_SCRIPT"

    if [[ ! -f "$full_script_path" ]]; then
        print_error "Setup script not found: $full_script_path"
        exit 1
    fi

    SCRIPT_PATH="$full_script_path"
    print_info "Setup script: $SETUP_SCRIPT"
}

# Show options menu
show_menu() {
    echo -e "${YELLOW}What would you like to install?${NC}"
    echo
    echo "1) Complete setup (recommended)"
    echo "2) Fonts only"
    echo "3) Shell configuration only"
    echo "4) Development tools only"
    echo "5) Custom installation"
    echo "6) Exit"
    echo
}

# Run macOS setup
run_macos_setup() {
    print_section "Running macOS Setup"

    if [[ ! -x "$SCRIPT_PATH" ]]; then
        chmod +x "$SCRIPT_PATH"
    fi

    "$SCRIPT_PATH"
}

# Run Windows setup
run_windows_setup() {
    print_section "Running Windows Setup"

    if command -v powershell >/dev/null 2>&1; then
        powershell -ExecutionPolicy Bypass -File "$SCRIPT_PATH"
    elif command -v pwsh >/dev/null 2>&1; then
        pwsh -ExecutionPolicy Bypass -File "$SCRIPT_PATH"
    else
        print_error "PowerShell not found. Please install PowerShell to continue."
        exit 1
    fi
}

# Run Linux setup
run_linux_setup() {
    print_section "Running Linux Setup"

    if [[ ! -x "$SCRIPT_PATH" ]]; then
        chmod +x "$SCRIPT_PATH"
    fi

    "$SCRIPT_PATH"
}

# Install fonts only
install_fonts_only() {
    print_section "Installing Fonts Only"

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local font_script="$script_dir/setup/fonts/install-nerd-fonts.sh"

    if [[ -f "$font_script" ]]; then
        if [[ ! -x "$font_script" ]]; then
            chmod +x "$font_script"
        fi
        "$font_script"
    else
        print_error "Font installation script not found"
        exit 1
    fi
}

# Show system information
show_system_info() {
    print_section "System Information"

    echo "Hostname     : $(hostname)"
    echo "OS           : $OS"
    echo "Architecture : $(uname -m)"
    echo "Shell        : $SHELL"
    echo "User         : $USER"

    if [[ "$OS" == "macos" ]]; then
        echo "macOS Version: $(sw_vers -productVersion)"
    elif [[ "$OS" == "linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "Distribution : $NAME $VERSION"
        fi
        echo "Kernel       : $(uname -r)"
    fi

    echo
}

# Interactive menu
interactive_setup() {
    while true; do
        show_menu
        read -p "Enter your choice (1-6): " choice

        case $choice in
            1)
                print_info "Starting complete setup..."
                case $OS in
                    "macos") run_macos_setup ;;
                    "linux") run_linux_setup ;;
                    "windows") run_windows_setup ;;
                esac
                break
                ;;
            2)
                install_fonts_only
                break
                ;;
            3)
                print_warning "Shell configuration only is not yet implemented"
                print_info "Please choose complete setup for now"
                ;;
            4)
                print_warning "Development tools only is not yet implemented"
                print_info "Please choose complete setup for now"
                ;;
            5)
                print_warning "Custom installation is not yet implemented"
                print_info "Please choose complete setup for now"
                ;;
            6)
                print_info "Installation cancelled"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-6."
                ;;
        esac
    done
}

# Main function
main() {
    print_header
    show_system_info
    detect_os
    check_setup_script

    # Check if running with --fonts-only flag
    if [[ "$1" == "--fonts-only" ]]; then
        install_fonts_only
        exit 0
    fi

    # Check if running with --auto flag
    if [[ "$1" == "--auto" ]]; then
        print_info "Running automatic setup..."
        case $OS in
            "macos") run_macos_setup ;;
            "linux") run_linux_setup ;;
            "windows") run_windows_setup ;;
        esac
        exit 0
    fi

    # Show help if requested
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Modern Shell Environment Setup"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --auto        Run automatic setup based on detected OS"
        echo "  --fonts-only  Install fonts only"
        echo "  -h, --help    Show this help message"
        echo
        echo "Without options, runs interactive setup menu."
        echo
        exit 0
    fi

    # Run interactive setup
    interactive_setup

    echo
    print_success "🎉 Setup completed! 🎉"
    echo
    print_info "Next steps:"
    echo "• Restart your terminal application"
    echo "• Configure your terminal to use a Nerd Font"
    echo "• Enjoy your modern shell environment!"
    echo
}

# Run main function
main "$@"
