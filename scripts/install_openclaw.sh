#!/usr/bin/env bash
set -e

# Cài OpenClaw qua npm global
# Yêu cầu: Node.js >= 22.12.0 (dùng nvm)

echo "Kiểm tra Node.js version..."
NODE_VER=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [[ -z "$NODE_VER" || "$NODE_VER" -lt 22 ]]; then
  echo "Node.js >= 22 là bắt buộc. Cài qua nvm:"
  echo "  source ~/.nvm/nvm.sh && nvm install 22 && nvm alias default 22"
  exit 1
fi

echo "Cài OpenClaw..."
npm install -g openclaw

echo ""
echo "Cài xong! Chạy onboarding:"
echo "  openclaw onboard"
echo ""
echo "Sau onboard, cấu hình API key (OpenRouter hoặc Google):"
echo "  openclaw configure"
echo ""
