#!/usr/bin/env bash
# menu.sh - small wrapper so users can run `bash menu.sh` from the repo root.
# If scripts/menu.sh exists it will execute that. Otherwise it lists available scripts
# and gives guidance.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/scripts"

if [ -f "$SCRIPT_DIR/menu.sh" ]; then
  exec bash "$SCRIPT_DIR/menu.sh" "$@"
fi

if [ -x "$SCRIPT_DIR/menu" ]; then
  exec "$SCRIPT_DIR/menu" "$@"
fi

if [ -f "$SCRIPT_DIR/menu" ]; then
  exec bash "$SCRIPT_DIR/menu" "$@"
fi

echo "No scripts/menu.sh found in $SCRIPT_DIR."
if [ -d "$SCRIPT_DIR" ]; then
  echo "Available files in scripts/:"
  ls -la "$SCRIPT_DIR"
else
  echo "No scripts/ directory present."
fi

cat <<'EOF'

To run a script from the repo root use one of:
  bash scripts/<scriptname>.sh
  ./scripts/<scriptname>.sh   # if you make it executable

If you expected a menu script (menu.sh) to exist, add it to the scripts/ directory and this wrapper will run it automatically.
EOF
