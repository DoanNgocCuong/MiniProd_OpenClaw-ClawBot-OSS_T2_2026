# OpenClaw — Tóm tắt bảo mật

## Local-first

- Hội thoại, memory và file **nằm trên máy bạn**; không gửi lên server OpenClaw.
- Code open source, có thể audit.

## Telegram bot (private)

- Bot chỉ cho phép **user đã pair** chat; người khác nhắn bị **drop** (allowlist).
- Không expose gateway localhost ra internet thì chỉ bạn dùng được bot.

## Điểm data rời máy: OpenAI API

- Khi agent gọi LLM, **tin nhắn được gửi tới API OpenAI** theo [privacy policy của OpenAI](https://openai.com/policies/privacy). Đây là điểm duy nhất dữ liệu rời máy bạn (tương tự dùng ChatGPT).

## Khuyến nghị

- **Không** nhập DB production, private keys hay data nhạy cảm vào chat khi test.
- Gateway chạy localhost, không expose ra internet — đủ an toàn cho test cá nhân (FinTech analysis, scripting).
- Rủi ro tăng khi bật các skill mạnh (SSH, email, browser) hoặc deploy production.

## Tham khảo

- [OpenClaw Privacy (getopenclaw)](https://www.getopenclaw.ai/privacy)
- [Giskard — OpenClaw security risks](https://www.giskard.ai/knowledge/openclaw-security-vulnerabilities-include-data-leakage-and-prompt-injection-risks)
