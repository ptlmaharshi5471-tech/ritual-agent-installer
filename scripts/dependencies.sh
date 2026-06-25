#!/bin/bash

# ============================================================================
# System Dependencies Installation
# ============================================================================
# Installs all required system packages for Ritual Agent
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# System packages to install
REQUIRED_PACKAGES=(
    "git"
    "curl"
    "wget"
    "unzip"
    "jq"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
    "pkg-config"
    "libssl-dev"
)

# ============================================================================
# Package Management
# ============================================================================

# Check if package is installed
is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii.*$package" 2>/dev/null
}

# Get list of installed packages
get_installed_packages() {
    dpkg -l | grep "^ii" | awk '{print $2}' | cut -d':' -f1
}

# Install package
install_package() {
    local package="$1"
    
    if is_package_installed "$package"; then
        print_success "Package already installed: $package"
        return 0
    fi
    
    print_info "Installing $package..."
    
    if sudo apt-get install -y "$package" &>/dev/null; then
        print_success "Installed: $package"
        return 0
    else
        print_error "Failed to install: $package"
        return 1
    fi
}

# Install multiple packages
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    print_section "Installing System Packages"
    
    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_error "Failed to install: ${failed_packages[*]}"
        return 1
    fi
    
    print_success "All packages installed successfully"
    return 0
}

# ============================================================================
# System Updates
# ============================================================================

# Update package lists
update_package_lists() {
    print_info "Updating package lists..."
    
    if sudo apt-get update &>/dev/null; then
        print_success "Package lists updated"
        return 0
    else
        print_error "Failed to update package lists"
        return 1
    fi
}

# Upgrade installed packages
upgrade_packages() {
    print_info "Upgrading installed packages..."
    
    if sudo apt-get upgrade -y &>/dev/null; then
        print_success "Packages upgraded"
        return 0
    else
        print_error "Failed to upgrade packages"
        return 1
    fi
}

# ============================================================================
# Dependency Checking
# ============================================================================

# Check all required packages
check_dependencies() {
    local missing_packages=()
    
    print_section "Checking System Dependencies"
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if is_package_installed "$package"; then
            print_success "$package is installed"
        else
            print_warning "$package is NOT installed"
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_error "Missing packages: ${missing_packages[*]}"
        return 1
    fi
    
    print_success "All dependencies are installed"
    return 0
}

# Check optional packages
check_optional_dependencies() {
    local optional_packages=(
        "git"
        "curl"
        "jq"
    )
    
    print_section "Checking Optional Dependencies"
    
    for package in "${optional_packages[@]}"; do
        if is_package_installed "$package"; then
            print_success "$package is installed"
        else
            print_warning "$package is NOT installed (recommended)"
        fi
    done
}

# ============================================================================
# Python Checks
# ============================================================================

# Check Python installation
check_python() {
    print_section "Checking Python Installation"
    
    if command_exists python3; then
        local version=$(python3 --version 2>&1)
        print_success "Python is installed: $version"
        return 0
    else
        print_error "Python3 is not installed"
        return 1
    fi
}

# Check Python3 pip
check_pip() {
    print_section "Checking pip Installation"
    
    if command_exists pip3; then
        local version=$(pip3 --version)
        print_success "pip is installed: $version"
        return 0
    else
        print_error "pip3 is not installed"
        return 1
    fi
}

# ============================================================================
# Full Installation Workflow
# ============================================================================

# Install all dependencies
install_all_dependencies() {
    print_header "Installing All System Dependencies"
    
    # Update system
    print_section "Step 1: Updating System Packages"
    if ! update_package_lists; then
        print_error "Failed to update package lists"
        return 1
    fi
    
    # Upgrade system
    print_section "Step 2: Upgrading Installed Packages"
    if ! upgrade_packages; then
        print_warning "Package upgrade had issues, continuing..."
    fi
    
    # Install required packages
    print_section "Step 3: Installing Required Packages"
    if ! install_packages "${REQUIRED_PACKAGES[@]}"; then
        print_error "Failed to install required packages"
        return 1
    fi
    
    # Verify installation
    print_section "Step 4: Verifying Installation"
    if check_dependencies; then
        print_success "All dependencies installed successfully"
        return 0
    else
        print_error "Some dependencies are still missing"
        return 1
    fi
}

# Quick dependency check
quick_check() {
    local missing_packages=()
    
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! is_package_installed "$package"; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_warning "Missing packages: ${missing_packages[*]}"
        return 1
    fi
    
    return 0
}

# ============================================================================
# Export Functions
# ============================================================================

export -f is_package_installed get_installed_packages install_package
export -f install_packages update_package_lists upgrade_packages
export -f check_dependencies check_optional_dependencies
export -f check_python check_pip install_all_dependencies quick_check
