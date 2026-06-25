#!/bin/bash

# ============================================================================
# Foundry Installation and Management
# ============================================================================
# Installs and manages the Foundry toolkit for smart contract development
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

FOUNDRY_INSTALL_URL="https://foundry.paradigm.xyz"

# ============================================================================
# Foundry Checks
# ============================================================================

# Check if forge is installed
is_forge_installed() {
    command_exists "forge"
}

# Check if cast is installed
is_cast_installed() {
    command_exists "cast"
}

# Check if anvil is installed
is_anvil_installed() {
    command_exists "anvil"
}

# Check Foundry installation
check_foundry() {
    print_section "Checking Foundry Installation"
    
    local all_installed=true
    
    if is_forge_installed; then
        local version=$(forge --version)
        print_success "forge is installed: $version"
    else
        print_warning "forge is NOT installed"
        all_installed=false
    fi
    
    if is_cast_installed; then
        local version=$(cast --version)
        print_success "cast is installed: $version"
    else
        print_warning "cast is NOT installed"
        all_installed=false
    fi
    
    if is_anvil_installed; then
        local version=$(anvil --version)
        print_success "anvil is installed: $version"
    else
        print_warning "anvil is NOT installed"
        all_installed=false
    fi
    
    [[ "$all_installed" == "true" ]]
}

# ============================================================================
# Foundry Installation
# ============================================================================

# Install Foundry
install_foundry() {
    print_section "Installing Foundry"
    
    # Check if already installed
    if check_foundry; then
        print_success "Foundry is already installed"
        return 0
    fi
    
    print_info "Downloading Foundry installer..."
    
    # Download and run installer
    if curl -L "$FOUNDRY_INSTALL_URL" | bash &>/dev/null; then
        print_success "Foundry installer script downloaded"
    else
        print_error "Failed to download Foundry installer"
        return 1
    fi
    
    # Run foundryup
    print_info "Running foundryup..."
    if ~/.foundry/bin/foundryup &>/dev/null; then
        print_success "foundryup completed"
    else
        print_error "foundryup failed"
        return 1
    fi
    
    # Verify installation
    print_info "Verifying Foundry installation..."
    if check_foundry; then
        print_success "Foundry installed successfully"
        return 0
    else
        print_error "Foundry installation verification failed"
        return 1
    fi
}

# Update Foundry
update_foundry() {
    print_section "Updating Foundry"
    
    if ! is_forge_installed; then
        print_error "Foundry is not installed"
        return 1
    fi
    
    print_info "Running foundryup to update..."
    
    if ~/.foundry/bin/foundryup &>/dev/null; then
        print_success "Foundry updated"
        check_foundry
        return 0
    else
        print_error "Foundry update failed"
        return 1
    fi
}

# ============================================================================
# Foundry Configuration
# ============================================================================

# Add Foundry to PATH
add_foundry_to_path() {
    local foundry_bin="$HOME/.foundry/bin"
    
    if [[ ! -d "$foundry_bin" ]]; then
        print_error "Foundry bin directory not found: $foundry_bin"
        return 1
    fi
    
    if [[ ":$PATH:" != *":$foundry_bin:"* ]]; then
        export PATH="$foundry_bin:$PATH"
        print_success "Added Foundry to PATH"
    else
        print_info "Foundry already in PATH"
    fi
}

# ============================================================================
# Foundry Commands
# ============================================================================

# Get forge version
get_forge_version() {
    if is_forge_installed; then
        forge --version
    else
        echo "not installed"
    fi
}

# Get cast version
get_cast_version() {
    if is_cast_installed; then
        cast --version
    else
        echo "not installed"
    fi
}

# Get anvil version
get_anvil_version() {
    if is_anvil_installed; then
        anvil --version
    else
        echo "not installed"
    fi
}

# Run forge test
run_forge_test() {
    local project_dir="${1:-.}"
    
    print_info "Running forge tests in $project_dir..."
    
    if cd "$project_dir" && forge test; then
        print_success "Forge tests completed"
        return 0
    else
        print_error "Forge tests failed"
        return 1
    fi
}

# Run forge build
run_forge_build() {
    local project_dir="${1:-.}"
    
    print_info "Running forge build in $project_dir..."
    
    if cd "$project_dir" && forge build; then
        print_success "Forge build completed"
        return 0
    else
        print_error "Forge build failed"
        return 1
    fi
}

# ============================================================================
# Foundry Status
# ============================================================================

# Print Foundry status
print_foundry_status() {
    print_header "Foundry Status"
    
    print_status "forge" "$(get_forge_version)"
    print_status "cast" "$(get_cast_version)"
    print_status "anvil" "$(get_anvil_version)"
}

# ============================================================================
# Export Functions
# ============================================================================

export -f is_forge_installed is_cast_installed is_anvil_installed
export -f check_foundry install_foundry update_foundry
export -f add_foundry_to_path
export -f get_forge_version get_cast_version get_anvil_version
export -f run_forge_test run_forge_build print_foundry_status
