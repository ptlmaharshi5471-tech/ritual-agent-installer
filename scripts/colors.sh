#!/bin/bash

# ============================================================================
# Color and Formatting Utilities
# ============================================================================
# Provides ANSI color codes and formatting functions for terminal output
# ============================================================================

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Bold variants
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'

# Text Formatting
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# ============================================================================
# Print Functions
# ============================================================================

# Print colored header
print_header() {
    local title="$1"
    echo -e "\n${BOLD_CYAN}======================================${NC}"
    echo -e "${BOLD_CYAN}  ${title}${NC}"
    echo -e "${BOLD_CYAN}======================================${NC}\n"
}

# Print section header
print_section() {
    local title="$1"
    echo -e "\n${BOLD_BLUE}▸ ${title}${NC}\n"
}

# Print success message
print_success() {
    local message="$1"
    echo -e "${GREEN}✓${NC} ${message}"
}

# Print error message
print_error() {
    local message="$1"
    echo -e "${RED}✗${NC} ${message}" >&2
}

# Print warning message
print_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} ${message}"
}

# Print info message
print_info() {
    local message="$1"
    echo -e "${CYAN}ℹ${NC} ${message}"
}

# Print debug message
print_debug() {
    local message="$1"
    if [[ "${DEBUG}" == "true" ]]; then
        echo -e "${GRAY}🐛 ${message}${NC}"
    fi
}

# Print with custom emoji
print_emoji() {
    local emoji="$1"
    local message="$2"
    local color="${3:-${WHITE}}"
    echo -e "${color}${emoji}${NC} ${message}"
}

# Print colored text
print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Print bold text
print_bold() {
    local message="$1"
    echo -e "${BOLD}${message}${NC}"
}

# Print a line separator
print_line() {
    local char="${1:-─}"
    local length="${2:-40}"
    printf '%*s\n' "$length" | tr ' ' "$char"
}

# Print loading spinner
print_spinner() {
    local pid=$1
    local message="${2:-Loading}"
    local spinner=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
    local i=0
    
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "\r${CYAN}${spinner[$i]}${NC} ${message}..."
        i=$(( (i+1) % ${#spinner[@]} ))
        sleep 0.1
    done
    echo -ne "\r"
}

# Print progress bar
print_progress() {
    local current=$1
    local total=$2
    local message="${3:-Progress}"
    local width=30
    
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "%s [" "$message"
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '░'
    printf "] %d%% (%d/%d)\r" "$percentage" "$current" "$total"
}

# Print menu option
print_menu_option() {
    local number="$1"
    local emoji="$2"
    local text="$3"
    printf "  ${BOLD_CYAN}%d${NC}. ${emoji} ${text}\n" "$number"
}

# Print alert box
print_alert() {
    local title="$1"
    local message="$2"
    local type="${3:-info}" # info, warning, error, success
    
    local color=$CYAN
    local symbol="ℹ"
    
    case "$type" in
        warning)
            color=$YELLOW
            symbol="⚠"
            ;;
        error)
            color=$RED
            symbol="✗"
            ;;
        success)
            color=$GREEN
            symbol="✓"
            ;;
    esac
    
    echo -e "\n${color}┌─────────────────────────────────────┐${NC}"
    echo -e "${color}│ ${symbol} ${title}${NC}${color} │${NC}"
    echo -e "${color}├─────────────────────────────────────┤${NC}"
    echo -e "${color}│ ${message}${NC}${color} │${NC}"
    echo -e "${color}└─────────────────────────────────────┘${NC}\n"
}

# Clear and print centered title
print_title_centered() {
    local title="$1"
    clear
    local width=$(tput cols)
    local title_length=${#title}
    local padding=$(( (width - title_length) / 2 ))
    
    echo -e "\n${BOLD_CYAN}$(printf '%*s' "$padding")${title}${NC}\n"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Get color by status
get_status_color() {
    local status="$1"
    case "$status" in
        ok|success|installed|running)
            echo -n "$GREEN"
            ;;
        warning|pending)
            echo -n "$YELLOW"
            ;;
        error|failed|missing)
            echo -n "$RED"
            ;;
        *)
            echo -n "$GRAY"
            ;;
    esac
}

# Get status symbol
get_status_symbol() {
    local status="$1"
    case "$status" in
        ok|success|installed|running)
            echo -n "✓"
            ;;
        warning|pending)
            echo -n "⚠"
            ;;
        error|failed|missing)
            echo -n "✗"
            ;;
        *)
            echo -n "?"
            ;;
    esac
}

# Print status line
print_status() {
    local label="$1"
    local status="$2"
    local color=$(get_status_color "$status")
    local symbol=$(get_status_symbol "$status")
    
    printf "${color}%-30s${NC} %s ${symbol}${NC}\n" "$label" "$status"
}

export -f print_header print_section print_success print_error print_warning
export -f print_info print_debug print_emoji print_color print_bold
export -f print_line print_spinner print_progress print_menu_option print_alert
export -f print_title_centered get_status_color get_status_symbol print_status
