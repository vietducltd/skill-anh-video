# Bộ skill ảnh và video cho fanpage (Claude)

3 skill tiếng Việt dùng trong Claude (tab **Code** của app Claude, hoặc Claude Code):
làm ảnh quảng cáo, ảnh minh hoạ cho bài viết và video dọc Reels/TikTok. Cả 3 đều
có cách làm **miễn phí**, không cần khoá API.

| Skill | Làm gì | Gõ để gọi |
|---|---|---|
| `tao-anh-quang-cao` | Ảnh quảng cáo Facebook từ ảnh sản phẩm thật. **Mặc định miễn phí:** Claude chọn phong cách hợp ngành và viết sẵn lệnh (prompt), bạn tạo ảnh trên ChatGPT/Gemini bản miễn phí rồi gửi lại để Claude soát chữ và đưa về đúng khổ; chèn chữ lên ảnh bạn chụp; hoặc ghép sản phẩm thật vào nền mới (phông studio, mặt bàn gỗ, đá), bao bì giữ nguyên. Tạo tự động qua API OpenAI (tốn phí) chỉ khi bạn yêu cầu | "làm ảnh quảng cáo cho sản phẩm này" |
| `tao-anh-bai-page` | Ảnh minh hoạ cho bài viết: ảnh chữ, album nhiều trang, chữ đặt lên ảnh thật. 7 phong cách, 7 font đủ dấu tiếng Việt, màu và font chọn theo ngành. Làm từng bài lẻ, hoặc cả loạt bài từ file lịch | "làm ảnh cho bài này" |
| `tao-video` | Video dọc 9:16. **Cách A:** video hoạt hình (motion graphics, video giải thích, cảnh 3D, trò chơi) theo thư viện **418 video mẫu**, có danh mục mô tả tiếng Việt từng mẫu và gợi ý hợp bài nào. **Cách B:** video người que có giọng đọc tiếng Việt, phụ đề | "làm video cho bài này", "xem mẫu video" |

Dán bài viết vào chat rồi nhờ "làm ảnh cho bài này" hoặc "làm video cho bài này" là
được, không cần chuẩn bị gì thêm.

**Thiết kế hợp từng ngành.** Mỗi người bán một thứ khác nhau, nên các skill không
dùng một kiểu chung: Claude lấy màu từ logo, bao bì của bạn, xác định ngành và
phân khúc (bình dân / cao cấp), rồi đề xuất 2-3 phương án màu, font, bố cục, bối
cảnh để bạn chọn. Bảng gợi ý cho 17 ngành nằm ở
`skills/tao-anh-bai-page/references/thiet-ke-theo-nganh.md`, cả 3 skill dùng chung.

**Khổ ảnh theo chỗ đăng.** Claude hỏi bạn đăng ở đâu rồi đề xuất khổ để bạn chọn
(một hay nhiều khổ): dọc 4:5 (bảng tin Facebook, Instagram), vuông 1:1 (Shopee,
Zalo, quảng cáo nhiều thẻ trượt), dọc dài 9:16 (Story, Reels), ngang 16:9 (YouTube,
website), ngang dẹt 1.91:1 (ảnh hiện khi chia sẻ link).

## Cài đặt (Windows)

**Cách 1 — nhờ Claude cài.** Mở app Claude, vào tab **Code**, chọn một thư mục làm
việc, rồi gõ:

> Cài giúp tôi bộ skill ở https://github.com/vietducltd/skill-anh-video

**Cách 2 — tự chạy một lệnh.** Mở **PowerShell** (bấm Start, gõ PowerShell), dán
lệnh sau rồi Enter:

```powershell
irm https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.ps1 | iex
```

Lệnh tải 3 skill vào thư mục `C:\Users\<tên bạn>\.claude\skills\`. Xong thì **mở
phiên Claude mới** (đóng phiên đang mở, tạo phiên mới) là dùng được.

**Cập nhật bản mới:** chạy lại đúng lệnh ở cách 2 (hoặc nhắn Claude "cập nhật bộ
skill ảnh video"). Skill cùng tên được ghi đè bằng bản mới.

**macOS / Linux:** `curl -fsSL https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.sh | sh`.
Phần lớn script viết bằng PowerShell cho Windows; trên macOS cần cài PowerShell 7,
và phần chèn chữ của `tao-anh-quang-cao` chỉ chạy trên Windows.

**Dùng Claude Code bản dòng lệnh (CLI)?** Có thể cài dạng plugin thay cho cách 2
(đừng cài cả hai, sẽ bị trùng skill):

```
/plugin marketplace add https://github.com/vietducltd/skill-anh-video
/plugin install anh-video@litado-anh-video
```

Skill cài dạng plugin có tên kèm tiền tố, VD `/anh-video:tao-video`.

## Cần chuẩn bị gì

| Skill | Cần có |
|---|---|
| Mọi skill | Máy Windows, app Claude (tab Code) hoặc Claude Code |
| `tao-anh-quang-cao` | Ảnh sản phẩm tự chụp hoặc tự lưu về máy; tài khoản ChatGPT (chatgpt.com) hoặc Gemini bản miễn phí. Khoá API OpenAI **chỉ cần nếu bạn muốn tạo tự động** — skill hỏi rõ lúc bắt đầu; không dùng API thì skill đi theo cách thủ công miễn phí. Ghép ảnh sản phẩm vào nền mới (tuỳ chọn): thêm Python và `pip install "rembg[cpu]"` |
| `tao-anh-bai-page` | Chrome hoặc Edge (máy Windows có sẵn Edge). Không cần cài gì thêm |
| `tao-video` cách A (hoạt hình) | Python 3.9+, ffmpeg, playwright kèm Chromium |
| `tao-video` cách B (giọng đọc) | Thêm Node.js 18+, numpy, Pillow, gTTS |

Cài công cụ làm video (chạy trong PowerShell, mỗi dòng một lệnh):

```powershell
winget install Python.Python.3.12
winget install Gyan.FFmpeg
winget install OpenJS.NodeJS.LTS
pip install playwright numpy pillow gTTS
pip install "rembg[cpu]"
python -m playwright install chromium
```

Chỉ làm cách A thì bỏ qua dòng Node.js; dòng `rembg` chỉ cần khi ghép ảnh sản phẩm vào nền mới. Không quen dòng lệnh thì nhắn Claude:
"kiểm tra và cài đủ công cụ làm video". Trên Windows, lệnh `python3` trong skill
tương đương `python`.

## Lưu ý

- **Khoá API, mật khẩu: không bao giờ dán vào khung chat.** Skill hướng dẫn tự
  lưu khoá vào file trên máy.
- Ảnh quảng cáo làm bằng AI phải soát chữ và bao bì từng ảnh trước khi chạy (skill
  tự soát và báo lỗi, nhưng người chạy quảng cáo vẫn nên xem lại).
- Danh mục 418 video mẫu chỉ có mô tả do bộ skill viết và link tới trang mẫu
  gốc (skillry.dev); bản quyền prompt và video mẫu thuộc tác giả trên trang đó.
- Skill không tự đăng bài hay bật quảng cáo.

---

### Dành cho Claude (khi người dùng nhờ cài từ link này)

Trên Windows, chạy lệnh PowerShell sau rồi báo người dùng mở phiên mới:

```powershell
irm https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.ps1 | iex
```

Trên macOS / Linux: `curl -fsSL https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.sh | sh`.
Lệnh chỉ chép các thư mục trong `skills/` vào `~/.claude/skills/`, không chạy gì khác.
