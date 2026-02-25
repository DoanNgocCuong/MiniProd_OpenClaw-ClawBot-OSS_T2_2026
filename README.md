# ClawBot

Agent cá nhân chạy trên [OpenClaw](https://openclaw.ai) — kết nối chat channels (Telegram, Discord, WhatsApp), chạy local trên WSL2/Ubuntu với model **GLM-4.5 Air (free)** qua OpenRouter.

> **v1.0** — Setup ngày 2026-02-25. OpenClaw `2026.2.23`, Node.js `v22.22.0`, WSL2 Ubuntu.

---

## Cách cài đặt

OpenClaw **không clone** — cài qua npm global:

```bash
# Yêu cầu Node.js >= 22.12.0
nvm install 22
nvm use 22
nvm alias default 22

npm install -g openclaw
```

Sau đó chạy onboarding:

```bash
openclaw onboard
```

Chi tiết từng bước: [docs/SETUP_LOG.md](docs/SETUP_LOG.md)

---

## Start gateway

```bash
source ~/.nvm/nvm.sh && nvm use 22 && openclaw gateway
```

Dashboard (Control UI): mở URL sau trong browser:

```
http://localhost:18789/#token=<gateway_token>
```

Lấy URL đầy đủ bằng:

```bash
openclaw dashboard
```

---

## Cấu trúc repo

```
ClawBot/
├── README.md                  # File này
├── docs/
│   ├── SETUP_LOG.md           # Log setup + bugs đã fix
│   ├── OPENCLAW_TELEGRAM_SETUP.md
│   └── OPENCLAW_SECURITY.md
├── scripts/
│   ├── install_openclaw.sh
│   ├── add_telegram_channel.sh
│   ├── approve_pairing.sh
│   └── script_window.ps1
└── config/
    └── .env.example
```

---

## Tài liệu

- [Setup Log & Bug Fixes](docs/SETUP_LOG.md) — toàn bộ quá trình setup + lỗi gặp phải + cách fix
- [Telegram Runbook](docs/OPENCLAW_TELEGRAM_SETUP.md)
- [Security](docs/OPENCLAW_SECURITY.md)
