#!/usr/bin/env bash
set -e

# Load .env from repo root or config/ if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
for f in "$REPO_ROOT/.env" "$REPO_ROOT/config/.env"; do
  if [[ -f "$f" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$f"
    set +a
    break
  fi
done

if ! command -v openclaw &>/dev/null; then
  echo "Error: openclaw not found. Run scripts/install_openclaw.sh and openclaw onboard first."
  exit 1
fi

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" ]]; then
  echo "Error: TELEGRAM_BOT_TOKEN not set. Set it in .env or export it."
  exit 1
fi

openclaw channels add telegram --token "$TELEGRAM_BOT_TOKEN"
