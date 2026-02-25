#!/usr/bin/env bash
set -e

# Install OpenClaw via official install script
# After this, run: openclaw onboard (paste OpenAI API key when prompted)

echo "Installing OpenClaw..."
curl -fsSL https://openclaw.ai/install.sh | bash

echo ""
echo "Install done. Run the following and paste your OpenAI API key when prompted:"
echo "  openclaw onboard"
echo ""
