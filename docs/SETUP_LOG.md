# ClawBot — Setup Log, Hướng dẫn & Bug Fixes

> Ghi lại toàn bộ quá trình deploy ClawBot lần đầu (2026-02-25) trên WSL2 Ubuntu.
> Mỗi bug có: **triệu chứng → nguyên nhân → cách fix**.

---

## 1. Cách cài OpenClaw (KHÔNG clone)

OpenClaw là một **npm global package**, không phải repo clone về:

```bash
# Yêu cầu Node.js >= 22.12.0
source ~/.nvm/nvm.sh
nvm install 22 && nvm alias default 22

npm install -g openclaw
```

Sau khi cài, config nằm ở:

```
~/.openclaw/
├── openclaw.json          # Config chính (model, gateway, agents)
├── agents/
│   └── main/
│       └── agent/
│           ├── auth-profiles.json   # API keys các provider
│           └── auth.json
├── workspace/             # Workspace của agent main
└── logs/
```

Hoặc dùng script có sẵn:

```bash
./scripts/install_openclaw.sh
```

---

## 2. Onboarding

```bash
openclaw onboard
openclaw models set "openrouter/z-ai/glm-4.5-air:free"
openclaw agents add test-agent --model "openrouter/z-ai/glm-4.5-air:free" --non-interactive
```

---

## 3. Cấu hình API key (OpenRouter)

Lấy free API key tại [openrouter.ai](https://openrouter.ai). Sau đó ghi vào `auth-profiles.json`:

```json
{
  "version": 1,
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "<your_openrouter_key>"
    }
  },
  "order": ["openrouter:default"]
}
```

File nằm tại: `~/.openclaw/agents/main/agent/auth-profiles.json`

---

## 4. Start Gateway

### Cách 1 — Chạy foreground (manual)

```bash
source ~/.nvm/nvm.sh && nvm use 22 && openclaw gateway
```

### Cách 2 — Daemon systemd (khuyến nghị, tự chạy khi boot)

```bash
# Cài daemon một lần
openclaw gateway install --force --runtime node

# Enable + start
systemctl --user daemon-reload
systemctl --user enable openclaw-gateway
systemctl --user start openclaw-gateway

# Kiểm tra
systemctl --user status openclaw-gateway
```

Sau khi cài daemon, gateway **tự chạy ngầm** mỗi lần khởi động máy — không cần chạy tay nữa.

Các lệnh quản lý daemon:

```bash
openclaw gateway start    # start
openclaw gateway stop     # stop
openclaw gateway restart  # restart
openclaw gateway status   # xem trạng thái
```

> **Lưu ý WSL2:** Systemd user daemon hoạt động khi WSL session đang chạy. Nếu đóng terminal Windows thì daemon cũng dừng theo. Để chạy 24/7 cần giữ WSL active hoặc dùng Windows Task Scheduler.

Kiểm tra health:

```bash
openclaw health
```

---

## 5. Kết nối Telegram

### Bước 1 — Tạo bot (BotFather)

1. Mở Telegram, tìm **@BotFather**
2. Gửi `/newbot`, đặt tên + username (phải kết thúc bằng `bot`)
3. Copy **token** (dạng `1234567890:AAF...`)

### Bước 2 — Thêm channel

```bash
export TELEGRAM_BOT_TOKEN="your_token_here"
openclaw channels add telegram --token "$TELEGRAM_BOT_TOKEN"
```

Hoặc đặt token vào `config/.env` rồi chạy:

```bash
./scripts/add_telegram_channel.sh
```

### Bước 3 — Pairing

1. Mở bot trên Telegram, gửi bất kỳ tin (vd: `hello`)
2. Bot trả về mã 6 số (vd: `483921`)
3. Approve:

```bash
openclaw pairing approve telegram 483921
# hoặc
./scripts/approve_pairing.sh 483921
```

### Windows (PowerShell)

```powershell
.\scripts\script_window.ps1 Install       # cài OpenClaw qua WSL
.\scripts\script_window.ps1 AddChannel    # thêm Telegram (cần .env với TELEGRAM_BOT_TOKEN)
.\scripts\script_window.ps1 Approve -Code 483921
```

---

## 6. Mở Control UI (Dashboard)

```bash
openclaw dashboard
# Output: http://127.0.0.1:18789/#token=<gateway_token>
```

Mở đúng URL đó trong browser — token tự lưu vào Control UI.

---

## 7. Bugs gặp phải & Cách fix

### Bug 1 — Config validation: Unrecognized keys

**Triệu chứng:**
```
Invalid config at ~/.openclaw/openclaw.json:
- agents.defaults.models.kilo-code/z-ai/glm-5:free: Unrecognized keys: "contextWindow", "apiKey"
```

**Nguyên nhân:** Model entry trong `openclaw.json` không hỗ trợ key `contextWindow` hay `apiKey`. Phải là object rỗng.

**Fix:**
```json
"models": {
  "openrouter/z-ai/glm-4.5-air:free": {}
}
```

---

### Bug 2 — Node.js version quá cũ

**Triệu chứng:**
```
openclaw requires Node >=22.12.0.
Detected: node 20.20.0
```

**Fix:**
```bash
source ~/.nvm/nvm.sh && nvm use 22 && nvm alias default 22
```

---

### Bug 3 — `openclaw start` không tồn tại

**Triệu chứng:**
```
error: unknown command 'start'
```

**Nguyên nhân:** Command đúng là `gateway`.

**Fix:**
```bash
openclaw gateway --force
```

---

### Bug 4 — Gateway không nhận API key

**Triệu chứng:**
```
FailoverError: No API key found for provider "openrouter".
```

**Nguyên nhân:** `auth-profiles.json` sai format — `profiles` là array thay vì object, field `token` thay vì `key`, thiếu `type`.

**Format sai:**
```json
{
  "profiles": [
    { "id": "openrouter:manual", "provider": "openrouter", "token": "sk-..." }
  ]
}
```

**Format đúng:**
```json
{
  "version": 1,
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "sk-or-v1-..."
    }
  },
  "order": ["openrouter:default"]
}
```

---

### Bug 5 — Model `kilo-code/z-ai/glm-5:free` bị reject

**Triệu chứng:**
```
FailoverError: Unknown model: kilo-code/z-ai/glm-5:free
```

**Nguyên nhân:** `kilo-code/` là KiloCode provider riêng. Qua OpenRouter thì ID đúng là `openrouter/z-ai/glm-4.5-air:free`.

**Fix:**
```bash
openclaw models set "openrouter/z-ai/glm-4.5-air:free"
```

---

### Bug 6 — Control UI báo "gateway token missing"

**Triệu chứng:** Dashboard hiện `unauthorized: gateway token missing`

**Fix:**
```bash
openclaw dashboard
# Mở URL có kèm #token=... trong browser
```

---

## 8. Cấu hình cuối cùng (v1.0)

**`~/.openclaw/openclaw.json`:**
```json
{
  "agents": {
    "defaults": {
      "model": { "primary": "openrouter/z-ai/glm-4.5-air:free" },
      "models": {
        "google/gemini-2.0-flash": {},
        "openrouter/z-ai/glm-4.5-air:free": {}
      }
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": { "mode": "token", "token": "<gateway_token>" }
  }
}
```

---

## 9. Bảo mật

- Hội thoại & memory **nằm trên máy** — không gửi lên server OpenClaw
- Telegram bot chỉ cho **user đã pair** chat; người khác bị drop
- Khi gọi LLM, tin nhắn gửi tới API OpenRouter/Google theo privacy policy của họ
- **Không** nhập data nhạy cảm (DB, private key) vào chat khi test
- Gateway chạy `localhost` — không expose ra internet

---

## 10. Môi trường

| Thành phần | Version |
|---|---|
| OS | WSL2 Ubuntu (Windows 11) |
| Node.js | v22.22.0 (NVM) |
| OpenClaw | 2026.2.23 |
| Model | `openrouter/z-ai/glm-4.5-air:free` |
| Gateway port | 18789 |
| Auth provider | OpenRouter |
