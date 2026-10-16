---
name: tao-anh-quang-cao
description: "TẠO ẢNH QUẢNG CÁO từ ẢNH SẢN PHẨM THẬT + bài viết quảng cáo (caption) của người dùng. Chọn phong cách thiết kế hợp ngành và phân khúc (màu, font, bối cảnh, bố cục), lấy chữ trên ảnh từ bài content (không bịa), chọn góc sáng tạo (hero sang trọng, bối cảnh sử dụng, công dụng, ưu đãi, vấn đề→giải pháp), viết prompt giữ nguyên bao bì, chữ tiếng Việt có dấu; nhiều khổ cho người dùng chọn theo chỗ đăng: dọc 4:5, vuông 1:1, 9:16 (Story/Reels), ngang 16:9, 1.91:1 (ảnh chia sẻ link). MẶC ĐỊNH MIỄN PHÍ: người dùng tải ảnh sản phẩm và dán prompt vào ChatGPT hoặc Gemini bản miễn phí, gửi ảnh lại để Claude soát chữ, sản phẩm, chính sách và đưa về đúng khổ; hoặc chèn chữ thẳng lên ảnh chụp thật. Chỉ tạo tự động qua API OpenAI (tốn phí, cần khoá) khi người dùng yêu cầu. Script PowerShell, không cần Python. Dùng khi gõ \"/tao-anh-quang-cao\", \"làm ảnh quảng cáo\", \"tạo ảnh ads\", \"thiết kế ảnh chạy quảng cáo\", \"poster sản phẩm\", \"banner quảng cáo từ ảnh sản phẩm\", \"có content rồi, làm ảnh đi\" — kể cả khi người dùng chỉ gửi ảnh sản phẩm và nói \"làm ảnh quảng cáo cho cái này\". KHÔNG dùng để viết caption, làm ảnh cho bài đăng nuôi fanpage (tao-anh-bai-page), hay làm video."
---

# Tạo ảnh quảng cáo từ ảnh sản phẩm

Đầu vào gồm **ảnh sản phẩm thật** và **bài viết quảng cáo** (caption) của người
dùng. Đầu ra là bộ ảnh quảng cáo đã soát, ghép được ngay với caption để chạy.

Claude không tự vẽ được ảnh như chụp thật: muốn dựng bối cảnh mới thì phải nhờ
một AI vẽ ảnh. Skill có bốn làn, **ưu tiên miễn phí**:

- **Làn M — thủ công trên ChatGPT (mặc định, miễn phí).** Claude chọn phong
  cách, viết prompt, chỉ rõ ảnh sản phẩm cần tải lên. Người dùng tự dán vào
  ChatGPT (hoặc Gemini) bản miễn phí, tải ảnh về, gửi lại. Claude soát và đưa
  về đúng khổ. Không cần khoá API.
- **Làn C — chèn chữ lên ảnh chụp thật (miễn phí).** `chen-chu.ps1` đặt chữ
  thẳng lên ảnh người dùng chụp. Sản phẩm và chữ đúng 100%, làm ngay, nhưng
  bối cảnh chỉ đẹp bằng ảnh gốc. Hợp khi ảnh chụp sẵn đã đẹp.
- **Làn A — tự động qua API OpenAI (tốn phí).** `tao-anh.ps1` gọi gpt-image-2
  dựng cảnh và in chữ trong một lần. Nhanh, không phải thao tác tay, nhưng mỗi
  ảnh tốn tiền và cần khoá API có nạp tiền. **Chỉ dùng khi người dùng chọn
  hoặc yêu cầu "tạo tự động".**
- **Làn B — nền không chữ + chèn chữ (dự phòng).** AI chỉ dựng cảnh, chừa chỗ
  trống (nền tạo bằng làn M hoặc A), `chen-chu.ps1` chèn chữ. Dùng khi AI viết
  sai chữ 2 lần, ảnh có khuôn mặt người thật, hoặc cần nhiều biến thể chữ.

AI vẽ ảnh thỉnh thoảng viết sai chữ, đổi chữ trên bao bì, nên **mọi ảnh AI
đều phải soát** (Bước 4), dù tạo thủ công hay tự động.

Thư mục `scripts/` của skill này chứa 3 script PowerShell có sẵn trên
Windows: `tao-anh.ps1`, `chen-chu.ps1`, `soi-chu.ps1`. Gọi bằng đường dẫn đầy
đủ: `powershell -ExecutionPolicy Bypass -File "<thư mục skill>/scripts/<tên>.ps1" ...`.
Trên macOS cần cài PowerShell 7 và dùng `pwsh`. Riêng `chen-chu.ps1` và
`soi-chu.ps1` dùng System.Drawing nên chỉ chạy trên Windows.

## Bước 0 — Hỏi cách tạo ảnh, thu thập đầu vào

**Tin nhắn đầu tiên** hỏi gộp: cách tạo ảnh, ảnh sản phẩm, bài content, ảnh
dùng ở đâu (quảng cáo Facebook/Instagram, Story/Reels, Shopee/Zalo,
YouTube/website... — để đề xuất khổ ở Bước 1). Phần
hỏi cách tạo ảnh viết rõ như sau (chỉnh xưng hô theo người dùng):

> Bạn muốn tạo ảnh theo cách nào?
> 1. **Thủ công, miễn phí (khuyên dùng):** mình chọn phong cách và viết sẵn
>    lệnh (prompt). Bạn mở ChatGPT bản miễn phí, tải ảnh sản phẩm lên, dán
>    lệnh, rồi tải ảnh về gửi lại để mình soát chữ và chỉnh khổ. Không cần
>    khoá API, không tốn tiền.
> 2. **Tự động qua API OpenAI:** mình tạo ảnh trực tiếp, bạn không phải làm
>    gì, nhưng mỗi ảnh tốn tiền và cần tài khoản OpenAI có nạp tiền.
> 3. **Chèn chữ lên ảnh bạn đã chụp:** miễn phí, xong ngay, giữ nguyên ảnh gốc.
>
> Bạn chưa chọn thì mình làm theo cách 1.

Người dùng không trả lời phần này, hoặc nói "không dùng API", "làm thủ công",
"miễn phí" → **làn M**, không nhắc gì tới khoá API nữa. Chỉ chuyển sang làn A
khi người dùng chọn cách 2 hoặc nói rõ "tạo tự động".

1. **Khoá API OpenAI — chỉ khi chọn làn A.** Chạy `tao-anh.ps1 -KiemTra`. Chưa
   có khoá thì hướng dẫn người dùng:
   - Lấy khoá tại platform.openai.com/api-keys. Tài khoản cần nạp sẵn tiền; lần
     đầu dùng model ảnh có thể phải xác minh tổ chức (Verify Organization).
   - Tự mở file bằng lệnh `notepad "$env:USERPROFILE\.openai_api_key"` (PowerShell),
     dán khoá vào (1 dòng) rồi lưu.
   - **Không bao giờ xin người dùng dán khoá vào khung chat**, không in khoá
     ra, không ghi khoá vào thư mục dự án.
   - Người dùng lỡ dán khoá vào chat: không dùng khoá đó và không nhắc lại nó.
     Khuyên người dùng thu hồi khoá này trên trang API keys (nó đã nằm trong
     lịch sử chat), tạo khoá mới rồi tự lưu vào file như hướng dẫn ở trên.
   - Người dùng đổi ý, không muốn làm khoá nữa → chuyển về làn M.
2. **Ảnh sản phẩm thật.** Chấp nhận jpg, png, webp. Người dùng đưa link trang
   sản phẩm thì thử tải ảnh gốc về (chọn bản lớn nhất). **Shopee, Lazada,
   TikTok Shop bắt đăng nhập nên không tải tự động được**: khi đó hướng dẫn
   người dùng tự lưu ảnh (máy tính: chuột phải vào ảnh → Lưu hình ảnh; điện
   thoại: nhấn giữ ảnh → Lưu) rồi kéo thả vào khung chat. **Không lấy ảnh tìm
   trên mạng** (Google, Bing...): kết quả thường là sản phẩm na ná của shop
   khác, dùng vào là quảng cáo sai sản phẩm. Chép ảnh vào
   `<thư mục làm việc>/anh-goc/`. Mở ảnh ra xem để mô tả đúng sản phẩm (khối 2
   trong `references/khung-prompt.md`); chữ in trên bao bì thì phóng to bằng
   `soi-chu.ps1 -Vung` để chép đúng từng dấu. Ảnh mờ, bị che, hoặc chụp nhiều
   sản phẩm lẫn lộn thì báo người dùng và xin ảnh khác.
3. **Bài viết quảng cáo** (dán vào chat hoặc file `.md`). Đọc bài để lấy chất liệu
   chữ trên ảnh. Chưa có bài content thì hỏi nhanh: tên sản phẩm, 1 lợi ích
   chính, giá hoặc ưu đãi thật, lời kêu gọi.
4. **Hồ sơ thương hiệu** (`ho-so-thuong-hieu.md`, logo, bảng màu) nếu người dùng có:
   màu, font, phong cách ảnh, ngành, phân khúc, từ cấm.

**Thư mục làm việc:** đã có thư mục thương hiệu `<slug>/` (làm ảnh bài viết
hay video trước đó) thì dùng `<slug>/anh-quang-cao/`. Không có thì dùng `anh-quang-cao-<ten-san-pham>/`
nằm cạnh file bài viết (cùng thư mục với file `.md` của bài); người dùng
dán content vào chat thì đặt ở thư mục đang mở và lưu bài vào
`content-goc.md` trong đó.

## Bước 1 — Chọn phong cách thiết kế, góc sáng tạo, khổ

**Phong cách hợp ngành và phân khúc.** Học viên bán đủ loại sản phẩm, dịch
vụ: màu, font, bối cảnh, bố cục phải hợp từng sản phẩm, không dùng một kiểu
cho mọi ngành.
- Người dùng có hồ sơ thương hiệu ghi màu, font → theo hồ sơ.
- Chưa có → đọc `../tao-anh-bai-page/references/thiet-ke-theo-nganh.md`
  (tính từ thư mục skill này). Xác định ngành, phân khúc (bình dân / trung /
  cao cấp), khách hàng; lấy màu từ bao bì, logo trước; rồi chốt: màu chính,
  nhấn, nền; kiểu chữ (câu mô tả cho AI, font Windows cho làn B, C); bối cảnh
  (đạo cụ, ánh sáng); bố cục theo phân khúc.
- Đề xuất **2 phương án phong cách khác hẳn nhau** (VD "Sang trọng tối" /
  "Tươi sáng gần gũi"), mỗi phương án 1 dòng, nói vì sao hợp sản phẩm.

**Góc sáng tạo.** Đọc bảng 5 góc trong `references/khung-prompt.md`. Đề xuất
**2 góc** hợp nhất với bài content và phân khúc: tiêu đề nói về nỗi đau thì
chọn G5, có ưu đãi thật thì G4, sản phẩm giá cao thì G1... Nói ngắn gọn vì sao.

**Khổ ảnh — đề xuất để người dùng chọn.** Mỗi chỗ đăng hợp một khổ, không
mặc định một khổ cho mọi người:

| Khổ | Kích thước | Dáng | Hợp với |
|---|---|---|---|
| `4x5` | 1080×1350 | Dọc | Quảng cáo, bài đăng trên bảng tin Facebook/Instagram (điện thoại): chiếm nhiều màn hình nhất |
| `1x1` | 1080×1080 | Vuông | Bảng tin, quảng cáo nhiều thẻ trượt (carousel), Marketplace, ảnh sản phẩm Shopee/Lazada/TikTok Shop, Zalo |
| `9x16` | 1080×1920 | Dọc dài | Story, Reels, TikTok, Zalo Story |
| `16x9` | 1920×1080 | Ngang | Ảnh bìa video YouTube, banner website, slide, màn hình ở cửa hàng |
| `1.91x1` | 1200×628 | Ngang dẹt | Ảnh hiện khi chia sẻ link website/bài blog, quảng cáo dạng link |

Theo chỗ người dùng định đăng (hỏi ở Bước 0), đề xuất **khổ chính** kèm một câu
lý do, liệt kê các khổ còn lại để người dùng chọn thêm (chọn nhiều cũng được).
VD chạy quảng cáo Facebook mọi vị trí → `4x5` + `9x16`; bán trên Shopee → `1x1`;
chia sẻ link bài blog → `1.91x1`. Người dùng không chọn → `4x5`.
Mỗi khổ một prompt riêng (khối 1 và bố cục chữ theo khổ). **Khổ ngang phải tạo
riêng bằng prompt ngang:** ép ảnh dọc sang khổ ngang thì sản phẩm nhỏ, hai bên
trống quá nửa ảnh.

**Lô thử mặc định: 2 góc × khổ chính = 2 ảnh.** Người dùng chọn được góc ưng
thì mới làm các khổ còn lại đã chọn cho góc đó.

**Chọn bao bì đưa vào ảnh:** AI giữ đúng chữ lớn trên bao bì, nhưng bao bì có
**nhiều đoạn chữ nhỏ** (nhãn mô tả, thành phần, công dụng) thì AI hay viết lại
sai và còn bịa thêm câu, kể cả câu về công dụng sức khoẻ. Sản phẩm có nhiều
kiểu bao bì thì ưu tiên kiểu ít chữ; chỉ có bao bì nhiều chữ thì dùng làn B
hoặc làn C.

## Bước 2 — Chốt bảng chữ trên ảnh

Mọi chữ trên ảnh phải lấy từ bài content hoặc hồ sơ thương hiệu. Rút gọn lại
cho vừa ảnh, **không bịa thêm**:

| Ô | Lấy từ | Giới hạn |
|---|---|---|
| `tieu_de` | Tiêu đề bài viết, hoặc lợi ích chính trong bài | ≤ 8 chữ, viết hoa, dùng `\|` để xuống dòng |
| `phu_de` | Điểm khác biệt hoặc cảm nhận chính trong bài | ≤ 6 chữ |
| `gia_nho` + `gia` | Ưu đãi thật trong bài, hoặc giá bán | Để trống nếu content không nêu giá/ưu đãi |
| `nut` | Lời kêu gọi cuối bài | ≤ 3 chữ, VD "MUA NGAY", "NHẮN NGAY" |

Soát bảng chữ theo `references/quy-tac-anh-quang-cao.md` mục Chính sách
(mỹ phẩm không dùng chữ mang nghĩa điều trị, không nêu con số không kiểm
chứng được). Lưu bảng chữ thành `chu-tren-anh.json` (UTF-8, đúng các khoá
`chen-chu.ps1` đọc), kèm màu và font của phong cách đã chọn (`mau_*`,
`font_tieu_de`, `font_phu`). File này dùng chung cho mọi làn.

**Xác nhận với người dùng trong một tin nhắn:** phong cách, góc, khổ, bảng chữ,
số ảnh, làn. Làn M, C: nói rõ không tốn tiền. Làn A: nhắc mỗi ảnh tốn tiền API,
xem chi phí thực tế ở trang Usage của OpenAI, và có làn M miễn phí. Chỉ gọi
API khi người dùng đồng ý.

## Bước 3 — Viết prompt

Ghép 6 khối theo `references/khung-prompt.md` (khối 1 chọn theo làn: làn M
dùng câu khổ cho ChatGPT; khối 3, 4a theo phong cách ở Bước 1) và lưu mỗi
prompt thành `prompt/G<n>-<kho>.txt` (UTF-8). Đặt tên ảnh `G<n>-<kho>.png`, ví
dụ `G1-4x5.png`.

### Bước 3M — Làn M: hướng dẫn người dùng tạo trên ChatGPT

Gửi người dùng, cho **từng ảnh**:
- Prompt trong một khối code (để bấm sao chép), ghi rõ ảnh này là góc nào.
- Danh sách ảnh sản phẩm cần tải lên kèm, ghi **đường dẫn đầy đủ** trên máy
  (VD `D:\...\anh-goc\sp.jpg`). Nhiều góc chụp thì AI giữ sản phẩm đúng
  hơn, tối đa 2–3 ảnh.

Kèm các bước (lần đầu ghi đủ, các ảnh sau chỉ nhắc ngắn):
1. Mở **chatgpt.com**, đăng nhập tài khoản miễn phí, bấm **New chat** (mỗi
   ảnh một cuộc trò chuyện mới để AI không lẫn với ảnh trước).
2. Bấm dấu **+** (hoặc biểu tượng kẹp giấy) cạnh ô nhập → tải lên các ảnh sản
   phẩm trong danh sách.
3. Dán prompt vào ô nhập, gửi. Chờ khoảng 1 phút.
4. Bấm vào ảnh vừa tạo → nút tải xuống. Kéo thả ảnh đó vào khung chat với
   Claude, ghi ảnh của góc nào (VD "ảnh G1").

Lưu ý gửi kèm:
- Bản miễn phí giới hạn số ảnh mỗi ngày, mức giới hạn thay đổi theo thời
  điểm. Hết lượt thì dùng **gemini.google.com** (cũng tải ảnh lên và dán prompt
  như trên) hoặc đợi hôm sau.
- ChatGPT chỉ ra 3 dáng: vuông, dọc 2:3, ngang 3:2, không đúng hẳn khổ cần.
  Không sao: prompt đã ghi dáng gần nhất và dặn chừa mép, Claude sẽ đưa về
  đúng khổ.

Nhận ảnh: lưu vào `<lv>/tai-ve/G<n>.<đuôi gốc>` (ChatGPT, Gemini hay trả về
**WebP**; script đọc được WebP), rồi đưa về đúng khổ (kích thước chuẩn ở bảng
Bước 1):

```
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/chen-chu.ps1" -Anh "<lv>/tai-ve/G1.webp" -Kho 4x5 -GiuDu -Ra "<lv>/G1-4x5.png"
```

- Khổ khác thì đổi `-Kho` (`1x1`, `9x16`, `16x9`, `1.91x1`) và tên file.
- Không truyền `-NoiDung` = chỉ đổi khổ, không vẽ thêm gì.
- `-GiuDu` (mặc định cho làn M): giữ đủ ảnh, hai bên lấp nền mờ tối. ChatGPT
  thường **không theo % vị trí** trong prompt: hay đặt tiêu đề ở ~11%, nút ở
  ~86–91% chiều cao ảnh 2:3. Cắt giữa về 4:5 sẽ làm chữ dính sát mép
  (3% và 99%). Chỉ bỏ `-GiuDu` (để cắt tràn khung) khi soát thấy mọi chữ của
  ảnh 2:3 nằm trong khoảng 17–80% chiều cao.

Rồi soát như Bước 4.

### Bước 3A — Làn A: tạo tự động qua API

```
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/tao-anh.ps1" -PromptFile "<lv>/prompt/G1-4x5.txt" -AnhSanPham "<lv>/anh-goc/sp.jpg" -Kho 4x5 -Ra "<lv>/G1-4x5.png"
```

- Nhiều ảnh gốc thì nối bằng dấu `;`: `-AnhSanPham "a.jpg;b.jpg"`.
- Mỗi ảnh mất khoảng 35–45 giây. Các ảnh độc lập với nhau thì chạy song song
  (mỗi ảnh một lệnh chạy nền) cho nhanh.
- Script tự thu nhỏ ảnh gốc, tự thử lại khi mạng lỗi, và xuất đúng kích thước
  chuẩn của khổ (`-Kho` `1x1`, `4x5`, `9x16`, `16x9`, `1.91x1`).

Lỗi thường gặp:
- `401`: khoá sai hoặc đã bị thu hồi.
- `403`, hoặc lỗi nhắc tới verification: tổ chức OpenAI chưa xác minh.
- `400` nhắc tới safety: prompt hoặc ảnh bị bộ lọc chặn, viết lại bối cảnh.
- `429` hoặc lỗi hết hạn mức: hết tiền hoặc gọi quá nhanh.

## Bước 4 — Soát từng ảnh (bắt buộc)

```
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/soi-chu.ps1" -Anh "<lv>/G1-4x5.png"
```

Script cắt ảnh thành 3 dải phóng to: trên, giữa, dưới. Mở ảnh gốc và từng ảnh
`*.soi-N.png` ra xem, rồi đi hết các mục trong bảng soát ở
`references/quy-tac-anh-quang-cao.md`:
- So chữ quảng cáo với `chu-tren-anh.json` **từng ký tự**. Lỗi dấu (ả/ã, ơ/ô,
  ư/u) rất dễ lọt qua khi chỉ nhìn cả ảnh.
- So **chữ lớn in trên bao bì** với ảnh gốc. AI hay đổi chữ ở đây (sai một
  chữ cái, mất dấu), kể cả khi chữ quảng cáo đúng hết.
- Xem màu, kiểu chữ, bố cục có đúng phong cách đã chọn và hợp ngành không.

Cần soát kỹ vùng khác thì dùng `-Vung "x,y,rộng,cao;..."` (tính theo %).

- **Đạt:** giữ lại.
- **Sai chữ hoặc sai sản phẩm, lần 1:**
  - Làn M: đưa người dùng một câu để gửi tiếp **trong cùng cuộc trò chuyện**
    ChatGPT, VD `Giữ nguyên toàn bộ ảnh, chỉ sửa chữ "<chữ sai>" trên bao bì thành "<chữ đúng>".`
    rồi tải ảnh mới về.
  - Làn A: tạo lại, thêm vào cuối khối 2 (sản phẩm) hoặc khối 4a (chữ) một
    câu nhắc riêng chữ bị sai, ví dụ
    `The packaging text must read exactly "<chữ in trên bao bì>" — write "<chữ đúng>", not "<chữ AI viết sai>".`
- **Sai lần 2:** chuyển sang làn B (chữ do script vẽ, chắc chắn đúng) hoặc làn C.

Soát xong thì xoá các file `*.soi-*.png`.

## Bước 5 — Làn B (khi cần)

1. Tạo nền: dùng cùng prompt, nhưng thay khối 4a bằng khối 4b (chừa chỗ, không
   chữ). Làn M: người dùng tạo trên ChatGPT như Bước 3M; làn A: chạy
   `tao-anh.ps1`. Lưu ảnh thành `G<n>-<kho>-nen.png` (ảnh tải về thì đưa về
   đúng khổ trước như Bước 3M).
2. Chèn chữ:
   ```
   powershell -ExecutionPolicy Bypass -File "<skill>/scripts/chen-chu.ps1" -Anh "<lv>/G1-4x5-nen.png" -NoiDung "<lv>/chu-tren-anh.json" -Ra "<lv>/G1-4x5-B.png"
   ```
3. Soát lại như Bước 4. Chữ chắc chắn đúng, nên tập trung xem chữ có đè lên sản
   phẩm và có dễ đọc không.

Cần nhiều biến thể chữ (test tiêu đề, test giá) thì chỉ cần sửa JSON và chạy
lại bước 2, không phải tạo nền mới.

## Bước 5b — Làn C: chèn chữ lên ảnh chụp thật (miễn phí)

Chọn ảnh có **khoảng trống phía trên** sản phẩm (nền vải, tường, bầu trời...)
và sản phẩm nằm gọn ở nửa dưới. Ảnh sản phẩm thường là ảnh vuông: dùng
`-Kho 4x5`, script tự nới phía trên bằng nền làm mờ của chính ảnh để có chỗ
đặt chữ, rồi thu về kích thước chuẩn của khổ.

```
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/chen-chu.ps1" -Anh "<lv>/anh-goc/sp.jpg" -NoiDung "<lv>/chu-tren-anh.json" -Kho 4x5 -Ra "<lv>/C1-4x5.png"
```

- **Màu, font theo phong cách đã chọn:** `font_tieu_de`, `font_phu` là tên font
  Windows đủ dấu tiếng Việt (bảng trong `thiet-ke-theo-nganh.md`: VD Cambria,
  Palatino Linotype cho sang trọng; Segoe UI Black cho mạnh; Candara cho thân
  thiện), hoặc file `.ttf` người dùng tải từ Google Fonts. Bỏ trống thì dùng
  Montserrat / Segoe UI.
- Ảnh nền sáng (nền kem, trắng): đặt `mau_nen_toi` thành màu sáng gần màu nền
  ảnh, `mau_chu` màu đậm của thương hiệu, `mau_chu_nut` màu sáng. Lưu
  thành file JSON riêng (VD `chu-tren-anh-nen-sang.json`).
- `-Kho 9x16` từ ảnh vuông: sản phẩm nằm sát đáy, phần dưới có thể bị giao
  diện Story che một chút; xem kỹ khi soát.
- `-Kho 1x1` từ ảnh vuông không nới thêm chỗ: chữ sẽ đè lên sản phẩm nếu sản
  phẩm chiếm phần trên ảnh. Ảnh vuông nên làm 4x5.
- `-Kho 16x9`, `-Kho 1.91x1` (ngang): script đặt ảnh sát phải, nới bên trái
  bằng nền mờ của chính ảnh; tiêu đề, phụ đề, giá, nút nằm ở nửa trái. Đẹp nhất
  với ảnh sản phẩm nằm giữa, nền đơn giản.
- Đặt tên ảnh `C<n>-<kho>.png`. Soát như Bước 4, tập trung vào: chữ có đè lên
  sản phẩm không, phụ đề có đọc rõ trên nền không (nền rối, nhiều chi tiết thì
  đổi `mau_nhan` sáng hơn).

## Bước 6 — Giao kết quả

Ghi `duyet-anh.md` trong thư mục làm việc:

```markdown
# Ảnh quảng cáo — <sản phẩm> — <ngày>

Bài viết dùng kèm: <đường dẫn file bài viết> (bài số ...)
Phong cách: <tên phương án> — màu <chính / nhấn / nền>, chữ <kiểu chữ>
Bảng chữ: chu-tren-anh.json

| Ảnh | Góc | Khổ | Làn | Soát | Ghi chú |
|---|---|---|---|---|---|
| G1-4x5.png | G1 Hero sang trọng | 4x5 | M | Đạt | |
| G2-4x5.png | G5 Vấn đề → giải pháp | 4x5 | M→B | Đạt (làn B) | ChatGPT sai dấu "<chữ>" 2 lần |

Góp ý của bạn: 
```

Gửi các ảnh **đạt** cho người dùng xem (dùng SendUserFile nếu có), kèm 2–3
dòng: góc nào nên chạy trước và vì sao, ảnh nào ghép với bài content nào. Hỏi
người dùng chọn góc nào để làm các khổ còn lại đã chọn (hoặc thêm khổ khác
trong bảng ở Bước 1).

Không tự đưa ảnh lên tài khoản quảng cáo. Nếu người dùng muốn, việc tạo quảng
cáo là bước riêng: ảnh tải lên, quảng cáo tạo ở trạng thái **tạm dừng**, người
dùng xem trước rồi mới bật.

## Sửa theo góp ý

- Sửa chữ: cập nhật `chu-tren-anh.json`. Làn B, C thì chạy lại `chen-chu.ps1`.
  Làn M: đưa người dùng câu sửa để gửi tiếp trong cuộc trò chuyện ChatGPT cũ.
  Làn A: sửa khối 4a trong prompt và tạo lại.
- Sửa bối cảnh, màu, kiểu chữ: sửa khối 3 hoặc 4a trong prompt, đưa người dùng
  prompt mới (làn M) hoặc tạo lại (làn A, nhắc lần này cũng tốn tiền).
- Cập nhật `duyet-anh.md` sau mỗi vòng sửa.
