---
name: tao-video
description: "TẠO VIDEO DỌC 9:16 (1080×1920) cho Reels, TikTok, Shorts, Zalo từ bài viết, tài liệu của người dùng — miễn phí, không cần khoá API. Hai cách: (A) VIDEO HOẠT HÌNH HTML theo 4 loại của thư viện 418 video mẫu (Motion graphics, Explainers, 3D scenes, Games): có danh mục đủ 418 mẫu kèm mô tả tiếng Việt, gợi ý hợp bài page nào và link prompt gốc; Claude viết một file HTML hoạt hình rồi quay thành MP4 bằng scripts/quay-video.py (đồng hồ ảo, mượt cả cảnh 3D); (B) VIDEO NGƯỜI QUE CÓ GIỌNG ĐỌC tiếng Việt, phụ đề karaoke, nhạc nền, chỉ cần viết script.json theo 6 kiểu cảnh, có cổng nghiệm thu. Màu, phông theo thương hiệu, hợp ngành và phân khúc. Dùng khi gõ \"/tao-video\", \"làm video\", \"làm video cho bài\", \"video Reels\", \"video TikTok\", \"video hoạt hình\", \"motion graphics\", \"video giải thích\", \"video 3D\", \"video có giọng đọc\", \"làm video dọc từ tài liệu này\", \"xem mẫu video\", \"kiểu video\". KHÔNG dùng khi cần cảnh quay người thật, khẩu hình khớp lời (người dùng tự quay)."
---

# Tạo video dọc cho fanpage

Đường dẫn trong skill tính từ thư mục chứa file này, ký hiệu `<skill>`. Mọi
đầu ra nằm trong thư mục dự án của người dùng, không ghi vào thư mục skill.

## Chọn cách dựng

| Cách | Khi nào | Làm bằng |
|---|---|---|
| **A. Video hoạt hình HTML** | Muốn video kiểu motion design: chữ, hình, số, cảnh 3D, trò chơi chuyển động theo nhạc; không cần giọng đọc | Claude viết **một file HTML** hoạt hình theo 4 loại của thư viện mẫu, rồi `scripts/quay-video.py` quay thành MP4 |
| **B. Video người que có giọng đọc** | Cần **giọng đọc tiếng Việt** và phụ đề khớp lời, nhân vật người que giải thích quy trình, bài học | `scripts/new_project.py` + `script.json` + `scripts/pipeline.py` |
| Người dùng tự quay | Người thật nói, cảnh quay sản phẩm, hậu trường | Không dựng; gợi ý người dùng tự quay |

Người dùng chưa nói rõ thì đề xuất một cách kèm lý do (bài nhiều số liệu, mẹo,
ra mắt sản phẩm → A; bài giải thích cần lời nói → B), hỏi một lần rồi làm.

Cả hai cách đều cần Python 3.9+, ffmpeg; A cần thêm `playwright` (có trình duyệt
Chromium), B cần thêm Node.js 18+, numpy, Pillow, gTTS. Thiếu thì hướng dẫn cài
theo README của bộ skill, không tự tải phần mềm khi chưa hỏi.

**Thiết kế hợp ngành:** màu, phông, bối cảnh theo thương hiệu người dùng (logo,
bao bì, hồ sơ thương hiệu nếu có); chưa có thì theo
`../tao-anh-bai-page/references/thiet-ke-theo-nganh.md` (skill cùng bộ, tính từ
thư mục skill này), đề xuất 2 phương án cho người dùng chọn. Không để một màu
mặc định cho mọi video.

## Cách A — Video hoạt hình HTML (4 loại, 418 mẫu)

Đọc **`references/kieu-video.md`** trước khi làm: 4 loại (Motion graphics,
Explainers, 3D scenes, Games), mỗi loại hợp bài page nào, kiểu hay gặp, cách làm
cho hay, kỹ thuật, khung brief 8 khối, quy trình dựng, chuẩn vùng an toàn Reels.

**Tìm mẫu tham khảo:** `references/mau-video.md` là danh mục đủ **418 video mẫu**
của thư viện https://skillry.dev/ai-videos/opus-5-5, chia theo loại; mỗi mẫu có
độ dài, công nghệ, mô tả tiếng Việt, gợi ý hợp bài page nào, và link. Cách dùng:
1. Lọc danh mục theo loại đã chọn và cột "Hợp với" gần nội dung bài (đọc mục
   lục, tìm từ khoá trong file).
2. Chọn 2-3 mẫu gần nhất, **mở link** đọc nguyên prompt tác giả (trang cho đọc và
   chép prompt tự do) để học cách họ mô tả bố cục, chuyển động, màu.
3. Viết brief của mình theo khung trong `kieu-video.md`, thay nội dung bằng bài
   của người dùng, màu, phông của thương hiệu. Không chép logo, nhân vật, thương
   hiệu, nhạc của video mẫu.

Tóm tắt quy trình (chi tiết trong `kieu-video.md`):
1. Chọn loại và cách thể hiện; viết brief `<slug>/video/<ma_bai>/brief.md`.
2. Viết `<slug>/video/<ma_bai>/index.html`: khung 1080×1920, mọi chuyển động chạy
   theo thời gian, tự chạy từ đầu đến cuối không cần bấm.
3. Quay thử 4 giây, xem 2-3 khung; rồi quay bản đủ:
   ```
   python "<skill>/scripts/quay-video.py" "<slug>/video/<ma_bai>/index.html" --giay 20 --ra "<slug>/video/<ma_bai>.mp4" --nhac "<file nhạc>"
   ```
4. Trích khoảng 8 khung, **mở xem từng khung** (dấu tiếng Việt, chữ tràn, vùng an
   toàn, màu thương hiệu), sửa rồi quay lại. Giao file MP4 và brief.

## Cách B — Video người que có giọng đọc

Biến một tài liệu (quy trình, chính sách, hướng dẫn, báo cáo, bài giảng, trang sản phẩm) thành video hoạt hình dọc 1080×1920 có giọng đọc tiếng Việt, phụ đề karaoke khớp từng từ, nhạc nền và âm thanh nhấn. Hình là nhân vật người que và đạo cụ vẽ bằng SVG, màu và phông theo thương hiệu. Không dùng model AI tạo video, không cần khoá API.

Khổ dọc hợp với TikTok, Reels, YouTube Shorts, Zalo và xem trên điện thoại. Skill tự chừa vùng an toàn cho giao diện các ứng dụng này: 220 px phía trên, 470 px phía dưới, không đặt chữ ở x > 950 trong đoạn y 880 đến 1450.

### Khi nào không dùng

Không dùng khi cần cảnh quay thật, khuôn mặt thật, khẩu hình khớp lời hay chuyển động mềm như vải, nước. Khi đó nói rõ với người dùng thay vì cố dựng bằng SVG.

### Nguyên tắc

1. Chỉ dùng thông tin có trong tài liệu người dùng đưa. Mỗi con số, mỗi nhận định trên màn hình phải truy được về tài liệu; ghi vào `facts.md` của dự án. Số minh hoạ thì ghi rõ “ví dụ”.
2. Hỏi đủ bốn câu và chờ người dùng đồng ý kế hoạch trước khi tạo giọng. Bốn câu gồm có: video để làm gì, ai xem, đăng ở đâu, xem xong người xem nên làm gì.
3. Không viết code cảnh. Mọi thứ nằm trong `script.json` theo [references/kich-ban.md](references/kich-ban.md).
4. Chỉ giao video khi cổng nghiệm thu báo ĐẠT, và báo lại bằng số đo.
5. Không bật máy đọc trả phí, không tải model hay phần mềm mới khi chưa hỏi. Không in khoá API.
6. Không dùng khuôn mặt, tên thật hay logo của bên thứ ba khi chưa có đồng ý.

### Quy trình 6 bước

1. **Đọc tài liệu.** Tóm tắt trong 3 câu, ghi `facts.md` mỗi dòng một ý kèm vị trí trong tài liệu.
2. **Chốt kế hoạch.** Hỏi bốn câu ở nguyên tắc 2. Đề xuất trong 4 đến 6 câu gồm thông điệp chính, số cảnh, độ dài ước tính, lời mời cuối, và phong cách hình ảnh (màu, phông hợp ngành). Chờ đồng ý.
3. **Tạo dự án.** `python3 <skill>/scripts/new_project.py <thư mục> [--brand brand.css --logo logo.png --mark dau.png]`. Ghi vào `brand.css` của dự án: `--accent` màu chính, `--accent-2` màu nhấn, `--bg` nền, `--f-head` và `--f-body` phông, theo phương án thiết kế đã chọn (mục "Thiết kế hợp ngành" ở trên); phông khác Be Vietnam Pro thì tải bằng `python3 tools/get_fonts.py "Tên phông:700,800"` (VD `"Playfair Display:700,800"`, `"Nunito:700,800"`). Trên Windows, `python3` tương đương `python`.
4. **Viết kịch bản.** Viết `script.json` theo [references/kich-ban.md](references/kich-ban.md), dùng ít nhất 3 kiểu cảnh khác nhau. Chạy `python3 <skill>/scripts/check_script.py <thư mục> --target <giây>` tới khi ĐẠT.
5. **Dựng.** `python3 <skill>/scripts/pipeline.py <thư mục> --name <tên-video> --social`. Lệnh chạy lần lượt kiểm kịch bản, tạo giọng, căn lời, âm thanh, đo cân bằng, đo phách, lint, tự soát, render, phụ đề, nghiệm thu. Bước nào lỗi thì dừng; đọc lỗi, sửa, chạy lại với `--from <bước>`.
6. **Giao.** Mở `review/self-eval.png` xem một lượt. Giao bản có giọng, bản không lời, bản nén social và file `.srt` trong `renders/`. Ghi một mục vào `project.md` gồm quyết định và việc còn treo.

### Kết quả nhận được

| File | Dùng khi |
|---|---|
| `renders/<tên>_1080x1920_giong-doc.mp4` | bản gốc có giọng đọc |
| `renders/<tên>_1080x1920_social.mp4` | đăng mạng xã hội, dung lượng nhỏ |
| `renders/<tên>_1080x1920_khong-loi.mp4` | lồng giọng người thật hoặc chỉ cần nhạc |
| `renders/<tên>.srt` | tải phụ đề lên nền tảng |
| `review/self-eval.png` | tấm ghép khung hình kèm dạng sóng để duyệt nhanh |

Chuẩn nghiệm thu gồm có: đúng khổ 1080x1920, 30 fps, AAC 48 kHz stereo, -14 LUFS ± 1, đỉnh thật từ -1 dBTP trở xuống, không khung đen, nhạc thấp hơn lời 4 đến 6 dB, tự soát 0 lỗi.

### Đổi gì chạy lại từ đâu

| Đã đổi | Lệnh |
|---|---|
| lời đọc | `pipeline.py <thư mục> --from voice` |
| neo, độ dài cảnh | `--from layout` |
| mức nhạc | `--from audio` |
| chữ trên màn hình, màu, phông, kiểu cảnh | `--from data` |

### Lỗi hay gặp

| Lỗi | Cách xử lý |
|---|---|
| `check_script` báo chữ quá dài | rút gọn, tách cảnh; không thu nhỏ chữ |
| `NEO HOẶC JS: W(...) không thấy` | từ neo phải có nguyên văn trong phụ đề của dòng đó |
| `CỘT PHẢI BỊ NÚT CHE`, `VÙNG AN TOÀN` | rút ngắn chip hay tiêu đề; chữ khổ dọc phải tránh vùng nút của ứng dụng |
| máy đọc sai tên tiếng Anh, số | viết trường `tts` với đoạn `["en", ...]` hoặc số bằng chữ |
| giọng máy nghe đều đều | chạy `VOICE_ENGINE=say` thử giọng khác, hoặc hỏi người dùng có muốn dùng dịch vụ trả phí |

### Môi trường

Cần Node.js 18 trở lên (chạy HyperFrames qua `npx`), ffmpeg và ffprobe, Python 3.9 trở lên với numpy, Pillow, playwright. Nên có gTTS (giọng đọc, cần mạng) và openai-whisper với model `base` đã tải (căn lời chính xác hơn). Thiếu whisper thì skill tự dùng bộ căn theo năng lượng; thiếu gTTS thì dùng macOS `say`. Lần đầu HyperFrames tự tải Chrome headless.

## Tài nguyên

| Đường dẫn | Nội dung |
|---|---|
| `references/kieu-video.md` | Cách A: 4 loại video, khung brief, quy trình dựng, chuẩn Reels |
| `references/mau-video.md` | Cách A: danh mục 418 video mẫu kèm mô tả tiếng Việt và link |
| `scripts/quay-video.py` | Cách A: quay trang HTML thành MP4 từng khung (đồng hồ ảo), gắn nhạc nền |
| `references/kich-ban.md` | Cách B: cách viết script.json, 6 kiểu cảnh, neo theo từ, đổi thương hiệu |
| `assets/template/` | Cách B: template dọc 1080×1920, engine `vendor/story.js`, scene kit, `brand.css` |
| `assets/pipeline/` | Cách B: công cụ được chép vào `tools/` của mỗi dự án |
| `scripts/` (còn lại) | Cách B: `new_project.py`, `check_script.py`, `pipeline.py`, `qa_video.py` |
