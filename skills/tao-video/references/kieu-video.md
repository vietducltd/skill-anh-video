# Làm video cho bài `video-ngan`

## Mục lục
- Ba cách dựng
- Trang video mẫu: 4 loại
- Loại 1 — Motion graphics
- Loại 2 — Explainers (video giải thích)
- Loại 3 — 3D scenes (cảnh 3D)
- Loại 4 — Games (trò chơi)
- Khung brief chung
- Quy trình dựng video HTML
- Chuẩn chung khi dựng
- Ghi lại (khi có file lịch CSV)

Danh mục đủ 418 video mẫu (mô tả tiếng Việt, gợi ý hợp bài nào, link): `mau-video.md`.

## Ba cách dựng

| Cách | Khi nào | Làm bằng |
|---|---|---|
| **A. Video hoạt hình HTML** (4 loại của trang mẫu) | Muốn video kiểu motion design: chữ, hình, số, cảnh 3D chuyển động theo nhạc; không cần giọng đọc | Claude tự viết **một file HTML** hoạt hình, rồi `scripts/quay-video.py` quay thành MP4 |
| **B. Video người que có giọng đọc** | Cần **giọng đọc tiếng Việt** và phụ đề khớp lời, nhân vật người que giải thích | Cách B trong `SKILL.md` của skill này |
| **C. Người dùng tự quay** | Người thật nói, cảnh quay sản phẩm, hậu trường | Không dựng |

Cả A và B đều miễn phí, không cần khoá API. A cần Python, `playwright`, `ffmpeg`
(cùng bộ công cụ với cách B). Chưa có thì hướng dẫn cài theo
README của bộ skill rồi mới dựng.

## Trang video mẫu: 4 loại

**https://skillry.dev/ai-videos/opus-5-5** — thư viện video người dùng làm bằng
Claude Opus 5.5, mỗi video kèm đúng prompt tác giả dùng và bản làm lại để so.
Đọc ngày 15/10/2026: **418 video, chia 4 loại**:

| Loại | Số video | Là gì |
|---|---|---|
| Motion graphics | 229 | Chữ, hình khối, đồ hoạ chuyển động theo nhịp: showreel, quảng cáo ngắn, giới thiệu thương hiệu, sản phẩm, app |
| Explainers | 68 | Giải thích một khái niệm, quy trình, cấu tạo bên trong một vật |
| 3D scenes | 56 | Dựng cảnh, vật thể 3D trong trình duyệt: công trình, phong cảnh, máy móc |
| Games | 65 | Trò chơi chơi được trong trình duyệt, quay lại thành video giới thiệu |

Trang có thể thêm video, thêm loại. Mỗi lô có bài video thì **mở trang xem vài
mẫu cùng loại trước khi dựng** (công cụ đọc web, hoặc trình duyệt nếu trang tải
bằng script) để lấy ý tưởng chuyển động. Không đọc được trang thì dùng hướng dẫn
dưới đây và báo người dùng. Chỉ lấy ý tưởng: không chép logo, nhân vật, thương
hiệu, nhạc của video mẫu.

Cách mọi video trên trang được làm: Claude viết một file HTML (Canvas, SVG, CSS,
GSAP, Three.js, WebGL) tự chạy hoạt hình, rồi quay lại. Skill này làm đúng như
vậy, khổ dọc cho Reels.

**Số liệu rút từ 418 prompt** (đọc 15/10/2026; chủ đề ước lượng theo từ khoá):

| Loại | Độ dài giữa | Công nghệ hay dùng | Chủ đề nhiều nhất |
|---|---|---|---|
| Motion graphics | 30 giây | Canvas 62%, SVG 54%, GSAP 27%, CSS 20% | Quảng cáo, ra mắt sản phẩm / app (~40%); số liệu, biểu đồ động (~35%); showreel theo nhạc (~22%) |
| Explainers | 40 giây | Canvas 60%, SVG 51%, Three.js 27%, GSAP 22% | Giải thích khái niệm, kiến thức (~50%); cấu tạo, cách hoạt động (~25%); video cho bài viết, sản phẩm (~20%) |
| 3D scenes | 28 giây | Three.js 82%, Canvas 60%, GLSL 58% | Máy móc, vật thể (~25%); thành phố, công trình (~20%); thiên nhiên, hành tinh (~20%) |
| Games | 32 giây | Canvas 76%, Three.js 64%, GLSL 40% | Game 3D đua, bay (~30%); pixel 2D (~20%); mô phỏng (~10%) |

Khoảng một nửa tác giả chỉ chia sẻ một phần prompt. Prompt rất ngắn ("làm video
15 giây cho X, làm hết sức") vẫn ra video đẹp vì mô hình tự quyết hết, nhưng
prompt chi tiết (thông số, bảng màu, kịch bản theo giây, ràng buộc) ra đúng ý
hơn: vì vậy skill luôn viết brief theo khung bên dưới trước khi dựng.

## Loại 1 — Motion graphics

**Hợp bài page:** hook theo trend, một con số gây chú ý, danh sách mẹo, ưu đãi
và ra mắt sản phẩm, giới thiệu thương hiệu, câu trích dẫn, "3 điều về...".

**Các kiểu hay gặp trên trang mẫu:**
- Chữ động (kinetic typography): từng chữ, từng dòng bật ra theo phách nhạc.
- Biến hình liên tục: một hình (đường kẻ, chấm, khối) biến thành cảnh sau, không
  cắt cảnh, không mờ chuyển.
- Giới thiệu sản phẩm / app: giao diện, tính năng lần lượt "bung ra khỏi màn hình".
- Logo reveal: logo hiện ra từ hạt, nét vẽ, mảnh ghép.
- Hạt (particles), pixel art, đồ hoạ dữ liệu (cột, bộ đếm số).
- Vòng lặp liền mạch (cảnh cuối nối khớp cảnh đầu).

**Cách làm cho hay:**
- **Một ý tưởng hình ảnh xuyên suốt**, nói được trong một câu (VD "<một vật gắn
  với sản phẩm> đi qua <các chặng> rồi thành <sản phẩm>").
- **Một font, 2–4 màu** (mã hex) theo thương hiệu. Chữ lớn rất đậm cho ý chính,
  nhãn nhỏ in hoa giãn chữ.
- Mỗi cảnh **một ý**, chữ ≤ 8 từ, đứng yên đọc được ít nhất 1,2 giây.
- Chuyển động có gia tốc (ease-in-out, nảy nhẹ), không trượt đều tuột thẳng.
- Nhịp cắt theo phách nhạc 100–128 BPM (cảnh đổi mỗi 2 hoặc 4 phách).
- Tránh các dấu hiệu "video AI": chữ nhỏ ở bốn góc, khung viền, watermark, bộ đếm
  tiến độ.

**Kỹ thuật:** Canvas 2D hoặc SVG cho hình, CSS + GSAP timeline cho chuyển động.
Độ dài hợp page: 10–30 giây.

## Loại 2 — Explainers (video giải thích)

**Hợp bài page:** khung kiến thức nhiều bước, "vì sao...", cấu tạo bên trong sản
phẩm (lớp vải, lõi nệm, động cơ máy), quy trình làm ra sản phẩm, lật hiểu lầm.

**Các kiểu hay gặp trên trang mẫu:**
- Cắt bổ vật thể 3D (cutaway): nhìn xuyên vào bên trong, nút "tách rời" (explode)
  để các bộ phận bay ra có nhãn tên.
- Mô phỏng quá trình thật (dòng chảy, ánh sáng đi qua thấu kính, bước lắp ráp)
  thay vì vẽ tượng trưng.
- Câu chuyện có nhân vật dẫn dắt, chèn hài, ghi chú số liệu thật.
- Video bài viết / sản phẩm: các ý chính của bài lần lượt hiện ra như một bản tin.

**Cách làm cho hay:**
- **Đúng và thật:** mọi số, mọi bước lấy từ caption hoặc nguồn có thật; ước lượng
  thì ghi "khoảng".
- Một cảnh một bước; nhãn chữ chỉ thẳng vào bộ phận đang nói.
- **Phụ đề cứng** trên hình (người xem Facebook hay tắt tiếng).
- Bản gốc trên trang mẫu thường cho người xem tự kéo, bấm; **video phải tự
  chạy**: viết sẵn đường đi của camera và thời điểm tách rời, ráp lại.
- Cần giọng đọc thì chuyển sang cách B (video người que có giọng đọc).

**Kỹ thuật:** SVG + GSAP cho sơ đồ phẳng; Three.js (+ GLSL) cho vật thể 3D cắt
bổ. Độ dài hợp page: 20–45 giây.

## Loại 3 — 3D scenes (cảnh 3D)

**Hợp bài page:** showroom, không gian cửa hàng, căn nhà / công trình, phong cảnh
vùng nguyên liệu (cánh đồng, vườn cây), sản phẩm xoay 360°,
"bên trong một <sản phẩm>".

**Các kiểu hay gặp trên trang mẫu:**
- Công trình, phong cảnh dựng hoàn toàn bằng code (sương, nước, ánh sáng, xe cộ
  di chuyển), không dùng ảnh hay mô hình tải về.
- Bay xuyên qua nhiều tầng (từ toàn cảnh vào chi tiết nhỏ nhất).
- Máy móc chuyển động thật (đồng hồ cơ, động cơ), vật thể phản ứng theo nhạc.
- Đi dạo trong nhà dựng từ bản vẽ, đổi ánh sáng ngày / tối.

**Cách làm cho hay:**
- Một **đường bay camera** rõ ràng: mở toàn cảnh → tiến vào chủ thể → lướt qua
  chi tiết → kết bằng khung có chỗ trống cho chữ và logo.
- Ánh sáng quyết định độ "thật": nắng xiên, sương mờ, ánh sáng viền; màu theo
  thương hiệu.
- Ít chữ: 1–2 dòng, đặt trên vùng trời hoặc vùng tối.
- Sản phẩm thật của người dùng chỉ đưa vào bằng ảnh thật của họ (dán lên mặt
  phẳng, khung tranh, màn hình trong cảnh), không vẽ lại sản phẩm bằng 3D.

**Kỹ thuật:** Three.js (+ GLSL cho nước, sương, trời). Độ dài hợp page: 15–30 giây.

## Loại 4 — Games (trò chơi)

**Hợp bài page:** biến một bài học thành mini game (VD <bài học> thành game
né <các lỗi hay gặp>), đố vui có đáp án, thử thách mời bình luận điểm số, giới
thiệu game, app của chính thương hiệu.

**Các kiểu hay gặp trên trang mẫu:**
- Game pixel art 2D, game bắn / né / nhảy, game bài, game đua 3D, game mô phỏng.
- Ẩn dụ đời thật thành luật chơi: trở ngại là quái vật, kiến thức là vật phẩm.
- Video giới thiệu game: vài pha chơi hay + tên game + lời mời chơi.

**Cách làm cho hay:**
- Video page là **đoạn quay pha chơi**, không phải để người xem chơi: viết sẵn
  **chế độ tự chơi (demo)**, một "người chơi máy" điều khiển theo kịch bản để có
  pha gay cấn, thắng ở cuối.
- Luật chơi hiện bằng 1 dòng chữ đầu video; kết video bằng câu hỏi mời bình luận
  ("Bạn qua được màn mấy?").
- Hình pixel art hoặc khối đơn giản, màu theo thương hiệu; nhân vật tự vẽ bằng
  code, không dùng nhân vật game có bản quyền.

**Kỹ thuật:** Canvas 2D (pixel art), Three.js cho game 3D. Độ dài hợp page:
15–30 giây.

## Khung brief chung

Trước khi viết code, viết **brief** (lưu `<slug>/video/<ma_bai>/brief.md`), đủ
8 khối. Brief là "prompt" cho chính mình; viết kỹ thì video đẹp, ít phải sửa.

1. **Mục tiêu:** bài nào, người xem là ai, xem xong làm gì (bình luận, nhắn tin).
2. **Thông số:** 1080×1920, 30 fps, N giây, có nhạc nền hay không.
3. **Loại và ý tưởng một câu:** VD "Motion graphics — <ý tưởng hình ảnh trong một câu>".
4. **Kịch bản theo giây:** bảng cảnh: giây bắt đầu–kết thúc, hình, chữ, chuyển cảnh.
   Mỗi cảnh ≥ 2,5 giây; chữ đứng yên ≥ 1,2 giây trước khi đổi.
5. **Chữ:** chép đúng câu từ caption, ≤ 8 từ một cảnh; số liệu phải có trong caption.
6. **Thiết kế:** màu (hex), font, phong cách theo thương hiệu (logo, bao bì, hồ sơ
   thương hiệu nếu có); chưa có thì theo bảng thiết kế theo ngành
   `../tao-anh-bai-page/references/thiet-ke-theo-nganh.md` (skill cùng bộ).
7. **Chuyển động:** kiểu chuyển cảnh (biến hình, lia, phóng), gia tốc, nhịp theo nhạc.
8. **Ràng buộc:** một file HTML, tự chạy từ đầu đến cuối không cần bấm; không ảnh
   tải từ mạng, không logo / nhân vật / thương hiệu người khác; không chữ góc,
   khung viền, watermark; chữ trong vùng an toàn Reels.

## Quy trình dựng video HTML

1. **Chọn loại và cách thể hiện** theo nội dung bài (bảng "Hợp bài page" ở trên),
   không lặp cách thể hiện trong lô. Ghi vào `mo_ta_anh` (mục cuối).
2. **Viết brief** theo khung trên.
3. **Viết `<slug>/video/<ma_bai>/index.html`:**
   - Khung cố định 1080×1920, `body` không cuộn, nền theo thương hiệu.
   - **Mọi chuyển động chạy theo thời gian** (`performance.now()`,
     `requestAnimationFrame`, GSAP timeline, hoạt ảnh CSS), không chờ chuột, phím.
     Tổng thời lượng đúng bằng brief.
   - Font tiếng Việt: dùng font kèm bộ skill bằng `@font-face` trỏ tới
     `file:///<thư mục skill tao-anh-bai-page>/assets/fonts/...` (thư mục cạnh skill
     này; có Be Vietnam Pro, Montserrat, Noto Serif, Playfair Display, Nunito, Anton,
     Patrick Hand — file `.woff2` chia theo bộ chữ thì khai báo kèm `unicode-range`); font máy thì chỉ dùng font
     đủ dấu (Segoe UI, Arial...).
   - Thư viện lấy từ cdnjs, ghi rõ số phiên bản (VD GSAP 3.12.5, Three.js r128).
   - Ảnh thật của người dùng (sản phẩm, logo) đọc từ đường dẫn trên máy.
4. **Xem nhanh:** quay thử 3–5 giây đầu
   (`--giay 4 --ra thu.mp4`), trích 2–3 khung xem bố cục, màu, chữ.
5. **Quay bản đủ:**
   ```
   python "<thư mục skill>/scripts/quay-video.py" "<slug>/video/<ma_bai>/index.html" --giay 20 --ra "<slug>/video/<ma_bai>.mp4" --nhac "<file nhạc>"
   ```
   Script quay từng khung với đồng hồ ảo nên video mượt dù cảnh nặng; khoảng 5 giây
   máy cho 1 giây video. Trang báo lỗi JavaScript thì script in CẢNH BÁO.
6. **Soát:** trích khoảng 8 khung đều nhau và **mở xem từng khung**:
   ```
   ffmpeg -i <ma_bai>.mp4 -vf "fps=8/<số giây>,scale=540:-1" <ma_bai>-k%02d.png
   ```
   Kiểm: dấu tiếng Việt, chữ tràn / đè / bị cắt, vùng an toàn, đúng màu thương hiệu,
   không còn chữ góc hay khung kiểu "AI". `ffprobe` kiểm thời lượng, có tiếng.
   Sửa HTML rồi quay lại đúng bài đó. Xoá các khung trích khi xong.
7. Gửi người dùng file MP4. Có file lịch CSV thì ghi `file_anh` = `video/<ma_bai>.mp4`.

## Chuẩn chung khi dựng

- Khổ dọc 1080×1920, 30 fps, 10–45 giây; video cho page nên 15–30 giây.
- **Vùng an toàn Reels:** chữ, logo quan trọng nằm trong y = 230…1440 px, cách mép
  trái phải ≥ 70 px (giao diện che khoảng 480 px phía dưới).
- Chữ thân ≥ 44 px; tiêu đề 80–140 px; tương phản đủ đọc trên điện thoại.
- **Âm thanh:** tiếng tạo bằng Web Audio trong trang không thu được. Nhạc nền là
  file riêng (`--nhac`), dùng nhạc có quyền sử dụng (thư viện nhạc miễn phí của
  YouTube, Facebook); không có thì quay im lặng và gắn nhạc khi đăng.
- Mọi chữ, số trên video lấy từ caption: không thêm số, không thêm lời hứa,
  không công dụng ngoài caption.
- Không logo app, ngân hàng hay thương hiệu thật của người khác. Tình huống hư cấu
  thì ghi "Tiểu phẩm minh hoạ" hoặc "Ví dụ minh hoạ".
- Cảnh kết: logo, tên thương hiệu, lời mời ngắn như chân ảnh.
- Thiết kế (màu, font, bối cảnh) hợp ngành và phân khúc như ảnh chữ.
- Nhịp mặc định khi người dùng muốn xen video: **cứ 2-3 ảnh thì 1 video**.

## Ghi lại (khi người dùng có file lịch CSV)

Cột `mo_ta_anh` của bài video ghi đủ để dựng:

- Cách A: `Video dọc 1080x1920. Kiểu: <loại trên trang mẫu> — <cách thể hiện>: <các cảnh chính>`
  VD `Video dọc 1080x1920. Kiểu: Motion graphics — chữ động theo phách: <N> mẹo lấy từ bài, mỗi mẹo một cảnh, kết logo`
- Cách B: `Video dọc 1080x1920 có giọng đọc. Cảnh: <chuỗi cảnh hook, list, point...> — <ý chính>`

Thêm `Kiểu video: <loại>` vào `ghi_chu` để sau này so loại video nào hiệu quả.
