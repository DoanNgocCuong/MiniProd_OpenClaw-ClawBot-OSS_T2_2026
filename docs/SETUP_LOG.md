# ClawBot — Setup Log & Bug Fixes

> Ghi lại toàn bộ quá trình deploy ClawBot lần đầu (2026-02-25) trên WSL2 Ubuntu.
> Mỗi bug có: **triệu chứng → nguyên nhân → cách fix**.

---

## 1. Cách cài OpenClaw (KHÔNG clone)

OpenClaw là một **npm global package**, không phải repo clone về:

```bash
npm install -g openclaw
```

Sau khi cài, các file config của OpenClaw nằm ở:

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

---

## 2. Onboarding

```bash
openclaw onboard --non-interactive --accept-risk
openclaw models set google/gemini-2.0-flash
openclaw agents add test-agent --model google/gemini-2.0-flash --non-interactive
```

---

## 3. Thêm model GLM-5 (KiloCode provider)

Theo yêu cầu thêm model `kilo-code/z-ai/glm-5:free` (free, không cần API key riêng).

Trong `~/.openclaw/openclaw.json`, phần `agents.defaults.models`:

```json
"models": {
  "google/gemini-2.0-flash": {},
  "openrouter/z-ai/glm-4.5-air:free": {}
}
```

> **Lưu ý:** Model `glm-5` thực chất thuộc KiloCode provider. Trên OpenRouter tên là `z-ai/glm-4.5-air:free`. Để dùng qua OpenRouter cần đặt primary là `openrouter/z-ai/glm-4.5-air:free`.

---

## 4. Bugs gặp phải & Cách fix

---

### Bug 1 — Config validation: Unrecognized keys

**Triệu chứng:**
```
Invalid config at ~/.openclaw/openclaw.json:
- agents.defaults.models.kilo-code/z-ai/glm-5:free: Unrecognized keys: "contextWindow", "apiKey"
```

**Nguyên nhân:** Model entry trong `openclaw.json` không hỗ trợ các key `contextWindow` hay `apiKey`. Entry phải là object rỗng `{}`.

**Fix:**
```json
"models": {
  "kilo-code/z-ai/glm-5:free": {}
}
```

---

### Bug 2 — Node.js version quá cũ

**Triệu chứng:**
```
openclaw requires Node >=22.12.0.
Detected: node 20.20.0
```

**Nguyên nhân:** Node.js v20 không đủ, OpenClaw yêu cầu v22+. NVM có sẵn v22.22.0 nhưng chưa được dùng.

**Fix:**
```bash
source ~/.nvm/nvm.sh
nvm use 22
nvm alias default 22   # đặt v22 làm default vĩnh viễn
```

---

### Bug 3 — `openclaw start` không tồn tại

**Triệu chứng:**
```
error: unknown command 'start'
(Did you mean status?)
```

**Nguyên nhân:** Command để khởi động gateway là `gateway`, không phải `start`.

**Fix:**
```bash
openclaw gateway          # chạy foreground
openclaw gateway --force  # kill port cũ rồi chạy lại
```

---

### Bug 4 — Gateway không nhận Google API key

**Triệu chứng:**
```
FailoverError: No API key found for provider "google".
Auth store: ~/.openclaw/agents/main/agent/auth-profiles.json
```

**Nguyên nhân:** Gateway không nhận key từ `auth-profiles.json` vì file dùng **sai format**. Hai lỗi format:
1. `profiles` là array `[...]` thay vì object `{...}` keyed by profile ID
2. Field tên là `token` thay vì `key`, thiếu field `type`

**Format sai (array):**
```json
{
  "profiles": [
    { "id": "google:manual", "provider": "google", "token": "AIza..." }
  ],
  "order": ["google:manual"]
}
```

**Format đúng (object):**
```json
{
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "sk-or-v1-..."
    },
    "google:default": {
      "type": "api_key",
      "provider": "google",
      "key": "AIzaSy..."
    }
  },
  "order": ["openrouter:default", "google:default"]
}
```

**Các quy tắc format `auth-profiles.json`:**
- `profiles` là **object**, key là profile ID (dạng `provider:default`)
- Mỗi profile cần `type: "api_key"`, `provider`, và `key`
- `order` là array profile ID theo thứ tự ưu tiên

**Fix:** Viết lại file đúng format như trên. Sau khi fix, `openclaw models status` hiện:
```
- openrouter effective=profiles:~/.openclaw/agents/main/agent/auth-profiles.json
              | profiles=1 (api_key=1) | openrouter:default=sk-or-v1...
```

---

### Bug 5 — Model `kilo-code/z-ai/glm-5:free` bị reject

**Triệu chứng:**
```
FailoverError: Unknown model: kilo-code/z-ai/glm-5:free
```

**Nguyên nhân:** Model ID không tồn tại trực tiếp trong registry của gateway khi dùng OpenRouter provider.

**Nguyên nhân sâu hơn (từ source code):** `kilo-code/` là prefix của KiloCode provider (`https://api.kilo.ai/api/gateway/`). Để dùng GLM qua OpenRouter thì ID phải là `openrouter/z-ai/glm-4.5-air:free`.

**Fix:**
```bash
openclaw models set "openrouter/z-ai/glm-4.5-air:free"
```

Hoặc sửa trực tiếp `openclaw.json`:
```json
"model": {
  "primary": "openrouter/z-ai/glm-4.5-air:free"
}
```

---

### Bug 6 — Control UI báo "gateway token missing"

**Triệu chứng:** Dashboard hiện `unauthorized: gateway token missing`

**Nguyên nhân:** URL mở Control UI không kèm token xác thực. Gateway dùng token-based auth.

**Fix:** Lấy URL đầy đủ kèm token:
```bash
openclaw dashboard
# Output: http://127.0.0.1:18789/#token=73d760eb3137840b669e68ffc0740eeb248ba3c0a7eb4f35
```

Mở đúng URL đó trong browser (token sẽ tự lưu vào Control UI settings).

---

## 5. Cấu hình cuối cùng (v1.0)

**`~/.openclaw/openclaw.json` (phần quan trọng):**
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/z-ai/glm-4.5-air:free"
      },
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
    "auth": {
      "mode": "token",
      "token": "<gateway_token>"
    }
  }
}
```

**`~/.openclaw/agents/main/agent/auth-profiles.json`:**
```json
{
  "version": 1,
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "key": "<openrouter_key>"
    },
    "google:default": {
      "type": "api_key",
      "provider": "google",
      "key": "<google_key>"
    }
  },
  "order": ["openrouter:default", "google:default"]
}
```

**Start command:**
```bash
source ~/.nvm/nvm.sh && nvm use 22 && openclaw gateway
```

---

## 6. Môi trường

| Thành phần | Version |
|---|---|
| OS | WSL2 Ubuntu (Windows 11) |
| Node.js | v22.22.0 (NVM) |
| OpenClaw | 2026.2.23 |
| Model | `openrouter/z-ai/glm-4.5-air:free` |
| Gateway port | 18789 |
| Auth provider | OpenRouter |
