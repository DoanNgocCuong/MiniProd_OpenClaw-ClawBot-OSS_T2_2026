#!/usr/bin/env bash
set -e

# Usage: ./approve_pairing.sh <6-digit-code>
# Example: ./approve_pairing.sh 483921

if ! command -v openclaw &>/dev/null; then
  echo "Error: openclaw not found. Run scripts/install_openclaw.sh and openclaw onboard first."
  exit 1
fi

if [[ -z "${1:-}" ]]; then
  echo "Usage: $0 <6-digit-pairing-code>"
  echo "Example: $0 483921"
  exit 1
fi

openclaw pairing approve telegram "$1"
