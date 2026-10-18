# Khung prompt ảnh quảng cáo

Prompt ghép từ 6 khối theo đúng thứ tự dưới đây, viết **tiếng Anh** (ChatGPT,
Gemini và API đều hiểu tốt hơn). Riêng chữ sẽ in lên ảnh thì giữ nguyên tiếng
Việt, đặt trong ngoặc kép. Lưu mỗi prompt thành 1 file `.txt` UTF-8 trong
`prompt/`; làn A không dán prompt thẳng vào dòng lệnh vì PowerShell dễ làm
hỏng dấu tiếng Việt và ngoặc kép.

```
[KHỐI 1 · KHỔ] [KHỐI 2 · SẢN PHẨM] [KHỐI 3 · BỐI CẢNH] [KHỐI 4 · CHỮ hoặc CHỪA CHỖ] [KHỐI 5 · GIỮ BAO BÌ] [KHỐI 6 · TRÁNH]
```

## Khối 1 — Khổ

**Làn A (API)** — API ra đúng khổ:

| Khổ | Câu mở đầu |
|---|---|
| 1x1 | `Square 1:1 product promotion image.` |
| 4x5 | `Vertical 4:5 product promotion image.` |
| 9x16 | `Vertical 9:16 full-screen product promotion image. Keep the top 14% and bottom 20% of the frame free of text and important objects.` |
| 16x9 | `Horizontal 16:9 wide product promotion image.` |
| 1.91x1 | `Horizontal wide product promotion image (16:9). It will be cropped to a 1.91:1 banner, so keep all text and the product between 10% and 90% of the image height.` |

**Làn M (ChatGPT, Gemini bản web)** — ChatGPT chỉ ra ảnh vuông, dọc 2:3 hoặc
ngang 3:2, nên dặn chừa mép để Claude cắt về đúng khổ mà không mất chữ:

| Khổ cần | Câu mở đầu |
|---|---|
| 1x1 | `Square 1:1 product promotion image.` |
| 4x5 | `Vertical portrait product promotion image (2:3). It will be cropped to 4:5, so keep all text and the product between 17% and 80% of the image height; the top 15% and the bottom 20% must contain only plain background.` |
| 9x16 | `Vertical portrait product promotion image (2:3). It will be extended to 9:16 for Stories: keep all text in the upper half below the top 5%, and keep the bottom 25% free of text (only background and the lower part of the scene).` |
| 16x9 | `Horizontal landscape product promotion image (3:2). It will be cropped to 16:9, so keep all text and the product between 12% and 88% of the image height; the top 10% and the bottom 10% must contain only plain background.` |
| 1.91x1 | `Horizontal landscape product promotion image (3:2). It will be cropped to a wide 1.91:1 banner, so keep all text and the product between 15% and 85% of the image height; the top 13% and the bottom 13% must contain only plain background.` |

Ảnh 2:3 tải về được đưa về khổ bằng `chen-chu.ps1 -Kho 4x5 -GiuDu` (giữ đủ ảnh,
hai bên lấp nền mờ tối — mặc định, vì ChatGPT hay đặt chữ sát mép bất kể prompt)
hoặc `-Kho 9x16` (nới phía trên bằng nền mờ, đúng vùng giao diện Story che).
Ảnh ngang 3:2 → `-Kho 16x9 -GiuDu` hoặc `-Kho 1.91x1 -GiuDu`. Không ép ảnh
dọc sang khổ ngang: sản phẩm nhỏ, hai bên trống quá nửa ảnh — tạo ảnh ngang
riêng.

Vì sao 17–80%: cắt 2:3 về 4:5 bỏ 8,3% trên và 8,3% dưới, nên vùng an toàn
10–88% của ảnh 4:5 ứng với 17–80% của ảnh 2:3. Ở khối 4a của làn M khổ 4x5,
đặt nút ở **khoảng 72–78% chiều cao** (không phải 80–85% như làn A) và tiêu
đề bắt đầu từ khoảng 18%.

## Khối 2 — Sản phẩm (quan trọng nhất)

Mô tả đúng những gì **nhìn thấy trong ảnh gốc**: hình dáng, màu, chất liệu
(nhám/bóng), chữ in trên bao bì (chép nguyên văn), hoạ tiết. Sau đó khoá lại:

```
Use the reference photo as the exact product: <mô tả>. Keep the product
identical in shape, proportion, color, material and label — do not redesign,
do not add or remove anything on the packaging.
```

Mẫu cách mô tả (thay phần trong `<...>` bằng đúng sản phẩm của người dùng):
`a <matte/glossy> <màu> <dáng> bottle with a <màu> label reading "<CHỮ LỚN TRÊN NHÃN>" and <hoạ tiết>, standing next to its <màu> box printed "<CHỮ LỚN TRÊN HỘP>"`.

Có nhiều ảnh gốc (mặt trước, mặt sau, hộp) thì đưa hết vào `-AnhSanPham`. AI
giữ sản phẩm đúng hơn khi có nhiều góc.

## Khối 3 — Bối cảnh: chọn 1 góc sáng tạo

Ghi thêm `Photorealistic, sharp focus on the product, high-end commercial photography.`

**Bối cảnh phải hợp ngành và phân khúc** (phong cách chốt ở Bước 1): màu nền,
ánh sáng, đạo cụ, chất liệu mặt đặt sản phẩm lấy theo cột "Bối cảnh ảnh quảng
cáo" và "Màu gợi ý" trong `../../tao-anh-bai-page/references/thiet-ke-theo-nganh.md`
(tính từ thư mục `references/` này), hoặc hồ sơ thương hiệu của người dùng. Viết màu bằng mã
hex và tên màu tiếng Anh, VD `<tên màu tiếng Anh> (#xxxxxx) to <tên màu tiếng Anh> (#xxxxxx) gradient`.
Ví dụ cùng góc G1 nhưng khác ngành:
- Trà biếu cao cấp: `dark walnut wood surface, a few loose tea leaves, warm amber rim light`.
- Mỹ phẩm học sinh: `soft pastel pink backdrop, water droplets, bright even daylight`.
- Đồ chơi trẻ em: `bright playroom, natural wooden floor, soft sky-blue and sunny yellow accents`.
- Gym: `dark gym floor, hard side light, orange accent light, slight motion blur in background`.

| # | Góc sáng tạo | Hợp khi | Gợi ý bối cảnh (viết lại theo sản phẩm) |
|---|---|---|---|
| G1 | **Hero sang trọng** | Giá cao, cần cảm giác đáng tiền | Mặt đá/gỗ tối, nền gradient màu thương hiệu, ánh sáng viền, 3–4 nguyên liệu/thành phần thật đặt ở chân sản phẩm |
| G2 | **Bối cảnh sử dụng** | Khách cần hình dung dùng lúc nào, ở đâu | Đặt sản phẩm đúng nơi dùng thật (phòng tắm, bàn làm việc, bếp, xe...), không cần người, ánh sáng tự nhiên |
| G3 | **Công dụng nổi bật** | Có 3–4 lợi ích rõ trong content | Sản phẩm ở giữa, 3 nhãn lợi ích ngắn (≤ 4 chữ mỗi nhãn) xếp quanh, nền sạch. Nhiều chữ nhất, phải soát kỹ tỷ lệ 20% |
| G4 | **Ưu đãi** | Bài viết có ưu đãi THẬT | Sản phẩm + huy hiệu ưu đãi lớn, tương phản mạnh. Không có ưu đãi thật thì bỏ góc này |
| G5 | **Vấn đề → giải pháp** | Tiêu đề bài viết nói về nỗi đau | Ẩn dụ bằng bối cảnh (VD: phía trái u tối, lộn xộn; phía phải sáng sủa, có sản phẩm). KHÔNG dùng ảnh cơ thể "trước–sau" |

Khoá học / dịch vụ: "ảnh sản phẩm" là ảnh thật của giảng viên, không gian,
bìa tài liệu, chứng nhận. AI hay làm lệch khuôn mặt, nên với ảnh có người thì
ưu tiên **làn B** (AI chỉ dựng nền, người thật giữ nguyên) và soát khuôn mặt
thật kỹ.

## Khối 4a — Chữ trên ảnh (làn M, A)

Chép **đúng từng chữ** trong bảng chữ đã chốt (Bước 2 của SKILL.md):

```
Add Vietnamese typography, spelled exactly with correct diacritics:
at the top a large <màu> uppercase headline "<TIÊU ĐỀ>";
under it a <màu nhấn> line "<Phụ đề>";
near the bottom, a row with a <màu nhấn> <hình dạng> price badge "<Giá / ưu đãi>"
and a <màu> <hình dạng> button with <màu> text "<NÚT>", placed at about 80–85% of
the image height, with clear empty space below it.
Typography: <kiểu chữ theo ngành>, all text inside the central 80% area,
text covering less than 20% of the image.
```

Ô nào trong bảng chữ để trống thì bỏ vế đó (chỉ có nút thì viết "a <màu>
<hình dạng> button ... centered horizontally").

**Kiểu chữ và hình dạng theo phong cách đã chọn** (bảng font trong
`thiet-ke-theo-nganh.md`), không mặc định một kiểu cho mọi ngành:

| Phong cách | `<kiểu chữ theo ngành>` | `<hình dạng>` nút, huy hiệu |
|---|---|---|
| Hiện đại, rõ ràng | `clean modern bold sans-serif` | `rounded` |
| Sang trọng, cao cấp | `elegant high-contrast serif headline, thin refined sans-serif subline, generous letter spacing` | `slim rectangular outlined` hoặc `small pill-shaped` |
| Thân thiện, dễ thương | `soft rounded friendly sans-serif` | `fully rounded pill-shaped` |
| Mạnh, khuyến mãi | `bold condensed uppercase sans-serif, high contrast` | `sharp rectangular` hoặc `starburst` (huy hiệu giá) |
| Mộc, thủ công | `warm casual handwritten-style headline with a clean sans-serif subline` | `rounded, slightly hand-drawn` |

**Khổ 4x5, 1x1:** prompt chỉ ghi "bottom-left / bottom-right" thì AI hay đặt
giá và nút ở 89–95% chiều cao, ra ngoài vùng an toàn.
Vì vậy phải ghi rõ vị trí như trên. Soát vẫn thấy nút thấp hơn 90% chiều cao:
khổ 4x5 trên bảng tin vẫn hiện đủ, nhưng ghi chú vào `duyet-anh.md` và làm
riêng bản 1x1 (đừng để Facebook tự cắt 4x5 thành vuông), hoặc chuyển làn B.

**Khổ ngang (16x9, 1.91x1):** bố cục chia đôi, thay cả khối trên bằng:

```
Layout: the product on the right half of the frame. On the left half, add
Vietnamese typography, spelled exactly with correct diacritics: a large <màu>
uppercase headline "<TIÊU ĐỀ>"; under it a <màu nhấn> line "<Phụ đề>"; under
that a row with a <màu nhấn> <hình dạng> price badge "<Giá / ưu đãi>" and a
<màu> <hình dạng> button with <màu> text "<NÚT>".
Typography: <kiểu chữ theo ngành>, all text inside the left half, between 10%
and 88% of the image height, text covering less than 20% of the image.
```

**Khổ 9x16:** không viết "bottom-left/bottom-right". Dù prompt dặn "65–78% chiều
cao", AI vẫn hay đặt giá và nút ở 83–88%, tức là rơi vào vùng bị giao diện Story
che. Nên gom cả khối chữ lên nửa trên:
`directly under the subheadline, a row with a <màu nhấn> <hình dạng> price badge "<Giá>" and a <màu> <hình dạng> button "<NÚT>"; nothing in the bottom 25% of the image except the product and background`.
Soát vẫn thấy chữ lọt xuống 20% dưới thì chuyển làn B cho khổ này.

## Khối 4b — Chừa chỗ cho chữ (làn B)

```
Place the product in the lower-center of the frame. Leave the upper third of
the frame as clean dark negative space with no objects and no text, for a
headline to be added later. No added text, captions, logos or buttons anywhere.
```

Khổ ngang (16x9, 1.91x1) — chữ sẽ chèn ở nửa trái:

```
Place the product on the right third of the frame. Leave the left half of the
frame as clean dark negative space with no objects and no text, for a headline
to be added later. No added text, captions, logos or buttons anywhere.
```

## Nền trống cho làn D (ghép sản phẩm thật)

Khi làn D cần một cảnh có chiều sâu mà ảnh kho không có, nhờ ChatGPT vẽ **cảnh
trống**, không tải ảnh sản phẩm lên. Ghép khối 1 (khổ, làn M) với:

```
Empty product photography scene with no products and no text. A <mặt bàn:
wooden / marble / linen> tabletop fills the lower third, seen from eye level,
<phông phía sau> softly blurred behind it, <ánh sáng> light coming from the
<left/right>, shallow depth of field. Leave the center of the tabletop
completely empty for a product to be placed later. Colors: <màu theo phong cách>.
Avoid: products, bottles, boxes, logos, text, people, hands, watermark.
```

Hướng sáng ghi đúng hướng sáng trong ảnh sản phẩm gốc (bóng sản phẩm đổ về phía
nào thì đèn ở phía ngược lại).

## Khối 5 — Giữ chữ trên bao bì (luôn có)

```
No added graphic elements other than the text specified, BUT fully preserve
all native printed text on the product packaging — brand name, product name,
label, pattern and any markings exactly as they physically appear on the product.
```

Câu này rất cần: không có nó, lệnh "không thêm chữ" ở làn B dễ khiến AI xoá
luôn tên thương hiệu in trên chai/hộp.

## Khối 6 — Tránh

```
Avoid: distorted packaging, changed logo, misspelled text, extra products,
hands, people, watermark, UI elements, cluttered layout.
```

(Góc G2 hoặc ảnh có người thì bỏ `hands, people` khỏi danh sách.)

## Từ KHÔNG được đưa vào prompt

AI sẽ vẽ ra giao diện giả, logo nền tảng hoặc watermark nếu prompt có các từ:
`Facebook, Instagram, FB, IG, TikTok, Meta, ad, advertisement, sponsored,
like button, share button, comment, feed ad, story ad, campaign, Canva,
Photoshop`.

Diễn đạt thay: "Facebook ad" → `product promotion image`; "nút Shop Now" →
`a rounded button with text "MUA NGAY"`.
