# OpenClaw + Telegram — Runbook setup

Môi trường khuyến nghị: **Ubuntu** (local). Trên Windows có thể dùng **WSL2** (Ubuntu); chạy toàn bộ lệnh trong terminal WSL, các bước logic giữ nguyên.

---

## Bước 1 — Cài OpenClaw

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

Sau khi cài xong, chạy onboard và dán **OpenAI API key** khi được hỏi:

```bash
openclaw onboard
```

Hoặc dùng script trong repo (chỉ gọi install, onboard vẫn chạy tay):

```bash
./scripts/install_openclaw.sh
```

---

## Bước 2 — Tạo Telegram Bot (BotFather)

1. Mở Telegram, tìm **@BotFather**.
2. Gửi `/newbot`.
3. Đặt tên bot (vd: `MyClaw`), username phải kết thúc bằng `bot` (vd: `myclaw_fintech_bot`).
4. Copy **token** (dạng `1234567890:AAF...`) — dùng ở bước 3.

---

## Bước 3 — Kết nối channel Telegram

Đặt token vào biến môi trường hoặc file `.env` (copy từ `config/.env.example`), rồi chạy:

```bash
openclaw channels add telegram --token YOUR_BOT_TOKEN
```

Hoặc dùng script (đọc `TELEGRAM_BOT_TOKEN` từ env / `.env`):

```bash
# Từ repo root, đã có .env hoặc export TELEGRAM_BOT_TOKEN
./scripts/add_telegram_channel.sh
```

---

## Bước 4 — Pairing (chỉ user đã pair mới chat được)

1. Trong Telegram, mở bot vừa tạo, gửi bất kỳ tin (vd: `hello`).
2. Bot trả lời **mã 6 chữ số** (vd: `483921`).
3. Trên máy (Ubuntu/WSL2), approve:

```bash
openclaw pairing approve telegram 483921
```

Hoặc:

```bash
./scripts/approve_pairing.sh 483921
```

Gateway tự restart; bot sẵn sàng nhận lệnh.

---

## Windows (PowerShell)

Các bước tương đương trong một file `scripts/script_window.ps1`:

| Bước   | Lệnh |
|--------|------|
| Cài    | `.\script_window.ps1 Install` → sau đó chạy `wsl openclaw onboard` |
| Channel| Đặt token trong `.env` (repo root hoặc `config/`), rồi `.\script_window.ps1 AddChannel` |
| Pairing| `.\script_window.ps1 Approve -Code 483921` |

Script tự dùng **openclaw** trong PATH nếu có, không thì gọi qua **WSL**. Bước Install chạy script cài qua WSL (cần cài WSL + Ubuntu trước).

---

## Bước 5 — Test nhanh

Gửi thử trong Telegram, ví dụ FinTech:

- `Phân tích VPB stock`
- `Viết script Python đọc CSV`
- `Tóm tắt tin tức tài chính hôm nay`

---

## Mở rộng (tùy chọn)

- **Skills**: Cài thêm skill (vd. stock-screener) rồi trigger qua chat (vd. "lọc cổ phiếu PE < 15").
- **Scheduled tasks**: Cấu hình agent chạy theo lịch (vd. 8h sáng gửi báo cáo thị trường vào Telegram).

Tài liệu chính thức: [OpenClaw](https://open-claw.co), [OpenClaw Guide – Telegram](https://openclawguide.org/integrations/openclaw-telegram).
