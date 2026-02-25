# ClawBot — Hướng dẫn sử dụng & Use Cases

> Sau khi setup xong (xem [SETUP_LOG.md](SETUP_LOG.md)), đây là những thứ bot làm được và cách dùng đúng.

---

## 1. Chat cơ bản qua Telegram

Nhắn thẳng vào **@doanngoccuong_bot** (sau khi đã pair):

```
"Viết script Python đọc file CSV"
"Tóm tắt bài báo này: <link>"
"Giải thích đoạn code này"
"Tìm kiếm thông tin về X"
```

---

## 2. Web Fetch — Những gì bot đọc được

Bot dùng `WebFetch` để đọc nội dung web. **Hoạt động tốt với:**

- Báo/blog: VnExpress, Tuoitre, Medium, Substack...
- Docs kỹ thuật: GitHub, Wikipedia, StackOverflow...
- API public: JSON endpoints, RSS feeds...

**KHÔNG đọc được (bị chặn):**

| Trang | Lý do |
|---|---|
| Facebook | Anti-bot, yêu cầu đăng nhập |
| Instagram | Tương tự Facebook |
| LinkedIn | Chặn crawler |
| Twitter/X | Paywall + anti-bot |

---

## 3. Bypass Facebook — Browser Skill

OpenClaw có **Browser skill** điều khiển Chrome thật qua extension, bypass được Facebook.

### Cách hoạt động

OpenClaw KHÔNG tự launch Chrome. Thay vào đó, dùng **Chrome Extension** làm relay:

1. Cài OpenClaw Chrome Extension trên Windows Chrome
2. Extension kết nối về gateway (`localhost:18789`) qua CDP port `18792`
3. Bot gửi lệnh → extension thực thi trên Chrome thật → trả kết quả về

### Setup (WSL2 + Windows Chrome)

**Bước 1 — Config path:**
```bash
openclaw config set browser.executablePath "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
openclaw gateway restart
openclaw browser status
# → detectedPath: /mnt/c/Program Files/Google/Chrome/Application/chrome.exe
```

**Bước 2 — Cài Chrome Extension:**

Mở Chrome trên Windows, vào: `chrome://extensions/` → Enable "Developer mode" → Load unpacked từ thư mục extension của OpenClaw.

> Hoặc tìm extension trên Chrome Web Store: tìm "OpenClaw"

**Bước 3 — Attach extension:**

Click icon OpenClaw trên thanh extension của Chrome → extension sẽ connect về gateway.

**Bước 4 — Test:**
```bash
openclaw browser status       # running: true
openclaw browser screenshot   # chụp tab hiện tại
openclaw browser snapshot     # đọc nội dung trang
```

### 3 cách tiếp cận (theo cộng đồng)

| Cách | Phổ biến | Use case |
|---|---|---|
| **Browser skill** (Chrome Extension) | 70-80% | Public profile/page, cần JS render |
| **Facebook Graph API** | 20% | Page management, post/comment |
| ~~WebFetch thẳng~~ | ❌ | Luôn fail với Facebook |

### Browser skill — các lệnh hay dùng

```bash
# Trạng thái browser
openclaw browser status

# Mở URL mới
openclaw browser open https://www.facebook.com/profile

# Chụp màn hình
openclaw browser screenshot

# Đọc nội dung trang (AI-optimized)
openclaw browser snapshot

# Danh sách tab đang mở
openclaw browser tabs
```

> **Lưu ý WSL2:** Extension chạy trên Windows Chrome, gateway chạy trong WSL. Cần Chrome đang mở và extension đã attach thì bot mới dùng được browser skill.

---

## 4. Các lệnh quản lý hay dùng

```bash
# Xem trạng thái tổng quát
openclaw health

# Xem agents
openclaw agents list

# Xem channels
openclaw channels list

# Restart gateway
openclaw gateway restart

# Xem logs realtime
openclaw logs --follow

# Xem sessions
openclaw sessions list
```

---

## 5. Skills có sẵn (ready to use)

```bash
openclaw skills list
```

| Skill | Dùng để |
|---|---|
| `coding-agent` | Delegate coding task cho Claude Code / Codex |
| `tmux` | Remote-control terminal sessions |
| `weather` | Hỏi thời tiết (wttr.in) |
| `healthcheck` | Security hardening check |
| `skill-creator` | Tạo skill mới |

---

## 6. Model đang dùng

```
openrouter/z-ai/glm-4.5-air:free
```

Free model qua OpenRouter — không tốn tiền. Nếu cần model mạnh hơn:

```bash
# Xem models available
openclaw models scan --no-probe

# Đổi model
openclaw models set "openrouter/google/gemma-3-27b-it:free"
```
