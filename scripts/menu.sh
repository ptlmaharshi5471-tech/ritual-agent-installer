#!/usr/bin/env bash
# scripts/menu.sh - interactive installer for ritual-agent-installer
# Works both when run from a cloned repo, or when executed remotely via:
#   bash <(curl -fsSL https://raw.githubusercontent.com/ptlmaharshi5471-tech/ritual-agent-installer/main/menu.sh)

set -euo pipefail

REPO_OWNER="ptlmaharshi5471-tech"
REPO_NAME="ritual-agent-installer"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts"
ROOT_RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main"

# Determine if we're running inside the repo (i.e., scripts/ exists locally)
HAS_LOCAL_SCRIPTS=false
if [ -d "./scripts" ]; then
  HAS_LOCAL_SCRIPTS=true
fi

# Helper to run a script that's either local (./scripts/) or fetched from raw
run_script() {
  local name="$1"
  if [ -f "./scripts/$name" ]; then
    echo "Running local scripts/$name"
    bash "./scripts/$name"
  elif [ "$HAS_LOCAL_SCRIPTS" = true ] && [ -f "scripts/$name" ]; then
    echo "Running repo-relative scripts/$name"
    bash "scripts/$name"
  else
    echo "Fetching and running $name from repository"
    curl -fsSL "${RAW_BASE}/${name}" | bash -s --
  fi
}

configure_env() {
  # Prefer .env in current directory
  ENV_FILE=".env"
  TEMPLATE_FILE=".env.template"

  # If .env doesn't exist, try to get template locally or from raw
  if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
      cp "$TEMPLATE_FILE" "$ENV_FILE"
      echo "Created $ENV_FILE from local $TEMPLATE_FILE"
    else
      # Try fetching template from raw
      if curl -fsSL "${ROOT_RAW_BASE}/.env.template" -o "$ENV_FILE"; then
        echo "Downloaded .env.template to $ENV_FILE"
      else
        echo "No .env.template available in repo; creating empty $ENV_FILE"
        cat > "$ENV_FILE" <<EOF
# Add API and PRIVATE_KEY entries here
API_KEY=
PRIVATE_KEY=
EOF
      fi
    fi
  else
    echo "$ENV_FILE already exists; editing it."
  fi

  # Let the user edit with nano (or $EDITOR if set but prefer nano as requested)
  EDITOR_CMD="${EDITOR:-nano}"
  # Prefer nano explicitly if available
  if command -v nano >/dev/null 2>&1; then
    EDITOR_CMD=nano
  fi

  echo "Opening $ENV_FILE in $EDITOR_CMD. Please add your API and PRIVATE_KEY values, save, and exit."
  $EDITOR_CMD "$ENV_FILE"

  echo "Finished editing $ENV_FILE";
}

print_banner() {
  echo "========================================="
  echo " ritual-agent-installer - interactive menu"
  echo "========================================="
}

while true; do
  print_banner
  echo "Choose an action:"
  echo "  1) Install dependencies"
  echo "  2) Setup Foundry"
  echo "  3) Configure API / PRIVATE_KEY (.env)"
  echo "  4) Run full setup (1 then 2 then 3)"
  echo "  q) Quit"
  read -rp "Enter choice: " choice

  case "$choice" in
    1)
      run_script "dependencies.sh"
      ;;
    2)
      run_script "foundry.sh"
      ;;
    3)
      configure_env
      ;;
    4)
      run_script "dependencies.sh"
      run_script "foundry.sh"
      configure_env
      ;;
    q|Q)
      echo "Goodbye"
      exit 0
      ;;
    *)
      echo "Invalid option"
      ;;
  esac

  echo
  read -rp "Press Enter to return to the menu..." _
done
