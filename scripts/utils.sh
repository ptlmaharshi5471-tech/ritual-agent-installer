#!/bin/bash

# ============================================================================
# Common Utility Functions
# ============================================================================
# Provides reusable utility functions for error handling, validation, etc.
# ============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

# ============================================================================
# Error Handling
# ============================================================================

# Exit with error message
die() {
    local message="$1"
    local code="${2:-1}"
    print_error "$message"
    exit "$code"
}

# Handle script errors
trap_error() {
    local line_number=$1
    local error_message="${2:-Unknown error}"
    print_error "Error on line $line_number: $error_message"
    exit 1
}

# Enable error handling
set_error_trap() {
    trap 'trap_error ${LINENO} "$BASH_COMMAND"' ERR
    set -o pipefail
    set -o errtrace
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_warning "Script interrupted or failed (exit code: $exit_code)"
    fi
}

# ============================================================================
# Command Checks
# ============================================================================

# Check if command exists
command_exists() {
    local cmd="$1"
    command -v "$cmd" &> /dev/null
}

# Check multiple commands
commands_exist() {
    local all_exist=true
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            print_error "Required command not found: $cmd"
            all_exist=false
        fi
    done
    [[ "$all_exist" == "true" ]]
}

# Get command path
get_command_path() {
    local cmd="$1"
    if command_exists "$cmd"; then
        which "$cmd"
    else
        echo ""
    fi
}

# Get command version
get_command_version() {
    local cmd="$1"
    if command_exists "$cmd"; then
        "$cmd" --version 2>&1 | head -n1
    else
        echo "not installed"
    fi
}

# ============================================================================
# File Operations
# ============================================================================

# Check if file exists
file_exists() {
    [[ -f "$1" ]]
}

# Check if directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if ! dir_exists "$dir"; then
        mkdir -p "$dir" || die "Failed to create directory: $dir"
        print_success "Created directory: $dir"
    fi
}

# Backup file
backup_file() {
    local file="$1"
    if file_exists "$file"; then
        local backup="${file}.backup.$(date +%s)"
        cp "$file" "$backup"
        print_info "Backed up $file to $backup"
    fi
}

# Safe write to file
safe_write_file() {
    local file="$1"
    local content="$2"
    
    # Create directory if needed
    local dir=$(dirname "$file")
    ensure_dir "$dir"
    
    # Backup existing file
    backup_file "$file"
    
    # Write file
    echo "$content" > "$file"
    print_success "Wrote to $file"
}

# ============================================================================
# User Input
# ============================================================================

# Prompt user for yes/no
confirm() {
    local prompt="$1"
    local default="${2:-n}" # y or n
    local response
    
    if [[ "$default" == "y" ]]; then
        read -p "$(print_color "$BOLD_CYAN" "$prompt [Y/n]: ")" response
        response="${response:-y}"
    else
        read -p "$(print_color "$BOLD_CYAN" "$prompt [y/N]: ")" response
        response="${response:-n}"
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Prompt user for input
prompt_input() {
    local prompt="$1"
    local default="${2:-}"
    local response
    
    if [[ -z "$default" ]]; then
        read -p "$(print_color "$BOLD_CYAN" "$prompt: ")" response
    else
        read -p "$(print_color "$BOLD_CYAN" "$prompt [$default]: ")" response
        response="${response:-$default}"
    fi
    
    echo "$response"
}

# Prompt for password (hidden input)
prompt_password() {
    local prompt="$1"
    local password
    
    read -s -p "$(print_color "$BOLD_CYAN" "$prompt: ")" password
    echo ""
    echo "$password"
}

# Select from menu
select_from_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice
    
    echo ""
    for i in "${!options[@]}"; do
        print_menu_option "$((i+1))" "▸" "${options[$i]}"
    done
    echo ""
    
    while true; do
        read -p "$(print_color "$BOLD_CYAN" "$prompt: ")" choice
        if [[ "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return 0
        else
            print_error "Invalid selection. Please try again."
        fi
    done
}

# ============================================================================
# System Information
# ============================================================================

# Get OS type
get_os() {
    uname -s
}

# Get OS version
get_os_version() {
    case "$(get_os)" in
        Linux)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                echo "$ID $VERSION_ID"
            else
                echo "Unknown Linux"
            fi
            ;;
        Darwin)
            echo "macOS $(sw_vers -productVersion)"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# Check if running on Ubuntu
is_ubuntu() {
    [[ "$(get_os)" == "Linux" ]] && \
    [[ -f /etc/os-release ]] && \
    grep -q "ID=ubuntu\|ID=debian" /etc/os-release
}

# Check if running in WSL
is_wsl() {
    grep -qi "microsoft\|wsl" /proc/version /proc/sys/kernel/osrelease 2>/dev/null
}

# Get available disk space in MB
get_disk_space() {
    local path="${1:-.}"
    df -BM "$path" | awk 'NR==2 {print $4}' | sed 's/M//'
}

# ============================================================================
# Process Management
# ============================================================================

# Check if process is running
is_process_running() {
    local pid="$1"
    kill -0 "$pid" 2>/dev/null
}

# Get PID of command
get_command_pid() {
    local cmd="$1"
    pgrep -f "$cmd" | head -n1
}

# Wait for process with timeout
wait_for_process() {
    local pid="$1"
    local timeout="${2:-30}"
    local elapsed=0
    
    while is_process_running "$pid" && [[ $elapsed -lt $timeout ]]; do
        sleep 1
        ((elapsed++))
    done
    
    if is_process_running "$pid"; then
        print_warning "Process $pid still running after ${timeout}s"
        return 1
    fi
    return 0
}

# ============================================================================
# Logging
# ============================================================================

# Initialize log file
init_log() {
    local log_file="$1"
    ensure_dir "$(dirname "$log_file")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log initialized" > "$log_file"
}

# Log message
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-./ritual-installer.log}"
    
    if [[ ! -f "$log_file" ]]; then
        init_log "$log_file"
    fi
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$log_file"
}

# Log info
log_info() {
    log_message "INFO" "$1" "${2:-./ritual-installer.log}"
}

# Log error
log_error() {
    log_message "ERROR" "$1" "${2:-./ritual-installer.log}"
}

# Log warning
log_warning() {
    log_message "WARN" "$1" "${2:-./ritual-installer.log}"
}

# ============================================================================
# Text Processing
# ============================================================================

# Trim whitespace
trim() {
    local var="$1"
    echo "$var" | xargs
}

# Convert string to lowercase
to_lowercase() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
to_uppercase() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Remove color codes from string
remove_colors() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

# ============================================================================
# Validation
# ============================================================================

# Validate URL
is_valid_url() {
    local url="$1"
    curl -s --max-time 2 -I "$url" &>/dev/null
    return $?
}

# Validate IPv4 address
is_valid_ipv4() {
    local ip="$1"
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    fi
    return 1
}

# Validate Ethereum address
is_valid_eth_address() {
    local addr="$1"
    # Remove 0x prefix if present
    addr="${addr#0x}"
    if [[ ${#addr} -eq 40 ]] && [[ $addr =~ ^[0-9a-fA-F]+$ ]]; then
        return 0
    fi
    return 1
}

# ============================================================================
# Export Functions
# ============================================================================

export -f die trap_error set_error_trap cleanup
export -f command_exists commands_exist get_command_path get_command_version
export -f file_exists dir_exists ensure_dir backup_file safe_write_file
export -f confirm prompt_input prompt_password select_from_menu
export -f get_os get_os_version is_ubuntu is_wsl get_disk_space
export -f is_process_running get_command_pid wait_for_process
export -f init_log log_message log_info log_error log_warning
export -f trim to_lowercase to_uppercase remove_colors
export -f is_valid_url is_valid_ipv4 is_valid_eth_address
