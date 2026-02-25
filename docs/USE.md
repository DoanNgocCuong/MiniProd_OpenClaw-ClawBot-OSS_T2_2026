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

## 3. Bypass Facebook — Browser Skill (Playwright)

OpenClaw có **Browser skill** dùng Chrome thật để simulate user, bypass được Facebook.

### Cách dùng

OpenClaw browser dùng Chrome trên máy. Trên Windows, Chrome có ở:
```
C:\Program Files\Google\Chrome\Application\chrome.exe
```

Cấu hình browser path trong OpenClaw:

```bash
openclaw config set browser.executablePath "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
openclaw browser status
```

### 3 cách tiếp cận (theo cộng đồng)

| Cách | Phổ biến | Use case |
|---|---|---|
| **Browser skill** (Playwright/Chrome) | 70-80% | Public profile/page, cần JS render |
| **Facebook Graph API** | 20% | Page management, post/comment |
| ~~WebFetch thẳng~~ | ❌ | Luôn fail với Facebook |

### Browser skill — cài và dùng

```bash
# Kiểm tra browser skill
openclaw skills list | grep browser

# Start browser session
openclaw browser open --url "https://www.facebook.com/profile"

# Screenshot
openclaw browser screenshot

# Đọc nội dung trang
openclaw browser snapshot
```

> **Lưu ý WSL2:** Browser chạy từ Windows Chrome, OpenClaw kết nối qua CDP port `18792`. Nếu Chrome chưa mở, OpenClaw sẽ tự launch.

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
