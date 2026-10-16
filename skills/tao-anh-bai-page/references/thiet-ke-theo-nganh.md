# Thiết kế theo ngành: màu, font, bố cục, bối cảnh ảnh

> Dùng chung cho cả bộ: tao-anh-bai-page (ảnh minh hoạ bài viết),
> tao-anh-quang-cao (ảnh quảng cáo), tao-video (video). Đây là **gợi ý khởi
> đầu**, không phải luật: logo, bao bì, màu thương hiệu đã có luôn đi trước.
> Bảng dùng khi thương hiệu chưa có nhận diện, hoặc để chọn phần còn thiếu.

## Mục lục
- Cách chọn (3 bước)
- Nguyên tắc chung
- Font có đủ dấu tiếng Việt
- Bảng theo ngành
- Bố cục ảnh quảng cáo theo phân khúc
- Ghi lại ở đâu

## Cách chọn (3 bước)

1. **Lấy cái có sẵn trước.** Logo, bao bì, biển hiệu, màu page đang dùng → rút
   ra 1 màu chính, 1 màu nhấn. Có rồi thì chỉ dùng bảng để chọn font, bố cục,
   bối cảnh. Mở ảnh sản phẩm ra xem: màu bao bì thường là gợi ý tốt nhất.
2. **Xác định ngành + phân khúc + khách hàng.** Phân khúc đổi lựa chọn nhiều
   hơn ngành: đồng hồ cao cấp khác hẳn đồng hồ thời trang giá rẻ; nhà hàng
   sang trọng khác quán ăn vặt sinh viên. Hỏi nếu chưa rõ (giá bán, khách là ai).
3. **Đề xuất 2–3 phương án khác hẳn nhau**, mỗi phương án đủ: màu chính, màu
   nhấn, nền, font tiêu đề + nội dung, phong cách tao-anh-bai-page, bối cảnh ảnh quảng
   cáo. Đặt tên dễ hiểu ("Sang trọng tối", "Tươi sáng gần gũi") và nói ngắn
   vì sao hợp sản phẩm. Người dùng chọn; không tự quyết một phương án.

## Nguyên tắc chung

- Tối đa **2 font** (1 tiêu đề, 1 nội dung), **1 màu chính, 1 màu nhấn, 1 nền**.
- **Tương phản đủ mạnh** để đọc trên điện thoại ngoài nắng: chữ đậm trên nền
  sáng hoặc chữ sáng trên nền đậm. Tránh vàng nhạt trên trắng, đỏ trên xanh lá,
  chữ mảnh trên ảnh nhiều chi tiết.
- Màu nhấn dùng ít: nút, chữ nhấn, con số. Không phủ cả ảnh.
- **Cao cấp:** nhiều khoảng trống, ít chữ, màu trầm, font có chân hoặc mảnh.
  **Bình dân, khuyến mãi:** màu tươi, tương phản mạnh, chữ to đậm.
- Font phải **đủ dấu tiếng Việt** (bảng dưới). Font thiếu dấu làm chữ hiện ô
  vuông hoặc dấu lệch, rất mất uy tín.

## Font có đủ dấu tiếng Việt

| Kiểu chữ | tao-anh-bai-page (`font`, `font_tieu_de` trong `thiet-ke.json`, hoặc phong cách) | tao-anh-quang-cao chèn chữ (font Windows có sẵn) | Mô tả cho AI trong prompt | Hợp với |
|---|---|---|---|---|
| Không chân, hiện đại, rõ | Be Vietnam Pro, Montserrat | Segoe UI Semibold, Segoe UI Black, Calibri | clean modern sans-serif | Đa số ngành, dịch vụ, khoá học, công nghệ |
| Có chân, thanh lịch | `font_tieu_de`: Playfair Display + `font`: Be Vietnam Pro; Noto Serif (phong cách tap-chi) | Cambria, Palatino Linotype, Constantia | elegant high-contrast serif | Spa, mỹ phẩm cao cấp, trang sức, trà, quà biếu, nội thất, bất động sản cao cấp |
| Tròn mềm, thân thiện | Nunito | Candara, Corbel | soft rounded friendly sans-serif | Mẹ & bé, thú cưng, đồ ăn vặt, trà sữa, giáo dục trẻ em |
| Đứng đậm, mạnh | Anton (phong cách tuong-phan), Montserrat | Segoe UI Black, Bahnschrift | bold condensed uppercase | Gym, thể thao, xe, khuyến mãi lớn, flash sale |
| Viết tay | Patrick Hand (phong cách so-tay, bang-den) | Không có font Windows viết tay đủ dấu: dùng tao-anh-bai-page hoặc AI | casual handwritten | Mẹo, ghi chép, quán nhỏ, đồ handmade |

Font Windows **thiếu dấu tiếng Việt, không dùng:** Arial Black, Impact, Georgia,
Comic Sans MS, Trebuchet MS, Franklin Gothic, Segoe Print, Segoe Script, Gabriola.

## Bảng theo ngành

Màu ghi theo thứ tự **chính · nhấn · nền**. Phong cách tao-anh-bai-page: xem
`tao-anh-bai-page/references/mau-anh.md`. Bối cảnh: dùng cho khối 3 của
prompt tao-anh-quang-cao và để chọn ảnh thật làm nền.

| Ngành | Cảm giác cần có | Màu gợi ý | Font | Phong cách tao-anh-bai-page | Bối cảnh ảnh quảng cáo | Tránh |
|---|---|---|---|---|---|---|
| Mỹ phẩm, chăm sóc da | Sạch, dịu, tin cậy | #C97B84 hồng đất · #E8C9A0 champagne · #FBF5F2 kem; hoặc #5BA89A xanh mint · #F4C7B8 · #FFFFFF | Cao cấp: Playfair + Be Vietnam Pro. Bình dân, teen: Nunito | mac-dinh sáng, toi-gian, tap-chi, pastel | Mặt đá cẩm thạch, lụa, giọt nước, cánh hoa, ánh sáng mềm | Ảnh trước–sau, da phóng to, đỏ chói |
| Spa, thẩm mỹ, massage | Thư giãn, sang | #7A4E3A nâu đất · #C9A27E be vàng · #F7F1EC kem; hoặc #4F6F52 xanh lá trầm | Playfair + Be Vietnam Pro | mac-dinh sáng/đậm, toi-gian, tap-chi | Đá cuội, khăn cuộn, nến, lá xanh, gỗ | Ảnh cơ thể hở, kim tiêm, máu, màu neon |
| Thời trang, phụ kiện | Xu hướng, cá tính | #111111 đen · 1 màu theo mùa (#D8C3A5 be, #7B1E2B đỏ rượu) · #FFFFFF | Montserrat; cao cấp: Playfair | toi-gian, tap-chi; sale: tuong-phan | Phông trơn studio, phố, tường màu | Chữ đè lên trang phục, quá nhiều chữ |
| Trang sức, đồng hồ, quà cao cấp | Quý, tinh xảo | #0F0F0F đen hoặc #0E1B40 navy · #C9A24A vàng kim · #F7F3EA ngà | Playfair | toi-gian, mac-dinh đậm | Nhung tối, ánh sáng điểm, phản chiếu | Màu sặc sỡ, khung viền dày |
| Quán ăn, cà phê, bánh | Ngon, ấm, mời gọi | #D9481E đỏ cam hoặc #5B3A29 nâu cà phê · #F2B33D vàng · #FFF6E9 kem | Montserrat; đồ ngọt, trà sữa: Nunito; quán nhỏ: Patrick Hand | mac-dinh, so-tay; combo: tuong-phan | Món cận cảnh có hơi nóng, bàn gỗ, tay cầm ly | Tông xanh lạnh (món kém ngon), ảnh tối |
| Trà, cà phê đặc sản, quà biếu | Truyền thống, tinh tế | #3B2A1E nâu gỗ trầm · #B9853A vàng đồng · #F3ECDF kem giấy; hoặc #2F4A35 xanh rêu · #C9A24A vàng kim | Playfair + Be Vietnam Pro; Noto Serif | mac-dinh đậm, tap-chi, toi-gian | Gỗ tối, ấm chén, sương núi, lá trà | Màu neon, font tròn trẻ con |
| Thực phẩm sạch, nông sản | Tươi, an toàn | #3C8D2F xanh lá · #F4B400 vàng nắng · #FAF7EF ngà | Be Vietnam Pro; Nunito | mac-dinh sáng, so-tay | Vườn, rổ tre, sương sớm, tay người trồng | Màu xám, ảnh hoá chất |
| Mẹ & bé, đồ chơi | An toàn, dịu dàng, vui | #5AA9E6 xanh trời · #FFC53D vàng · #FFF8E8 kem; hoặc #F4A6B8 hồng phấn | Nunito | pastel, mac-dinh sáng, so-tay | Phòng sáng, thảm, gỗ tự nhiên | Đỏ đen gắt, chữ nhọn, ảnh bé không được phép |
| Giáo dục, khoá học, coaching | Tin cậy, rõ ràng, có kết quả | #1F5FAF xanh dương hoặc #1D7874 xanh cổ vịt · #F4B942 vàng · #FFFFFF | Be Vietnam Pro; Montserrat | mac-dinh, bang-den, toi-gian; ưu đãi: tuong-phan | Lớp học, màn hình, người dạy (ảnh thật), sổ tay | Khoe tiền, ảnh stock giả tạo |
| Y tế, nha khoa, phòng khám | Sạch, chuyên môn, an tâm | #1C7ED6 xanh y tế hoặc #12A4A0 xanh ngọc · #F59F00 cam nhẹ · #F1F5F9 xám rất nhạt | Be Vietnam Pro; Montserrat | toi-gian, mac-dinh sáng | Phòng khám sáng, dụng cụ sạch, bác sĩ (ảnh thật) | Máu, vết thương, trước–sau, đỏ gắt |
| Bất động sản | Vững chắc, đẳng cấp | #0E2A47 navy · #B88A44 vàng đồng · #FFFFFF; sinh thái: #2E5E4E | Cao cấp: Playfair; còn lại Montserrat | toi-gian, mac-dinh đậm, tap-chi | Phối cảnh giờ vàng, view, nội thất | Nhồi chữ, hứa lợi nhuận |
| Tài chính, bảo hiểm | An toàn, minh bạch | #12325B navy · #2E9E6A xanh lá · #FFFFFF | Be Vietnam Pro; Montserrat | toi-gian, mac-dinh | Gia đình, ngôi nhà, biểu đồ đơn giản | Tiền mặt, mũi tên đỏ lao dốc |
| Gym, thể thao | Năng lượng, mạnh | #0F0F0F đen · #FF6B1A cam hoặc #C6F432 xanh chanh · #1A1A1A | Anton; Montserrat | tuong-phan, toi-gian | Phòng tập ánh sáng gắt, chuyển động | Trước–sau thân hình, cam kết giảm cân |
| Công nghệ, phần mềm, điện máy | Hiện đại, thông minh | #2563EB xanh dương hoặc #4F46E5 xanh tím · #22D3EE xanh ngọc · #0B1020 nền tối hoặc #FFFFFF | Montserrat; Be Vietnam Pro | toi-gian, tuong-phan, mac-dinh đậm | Bàn làm việc, màn hình, ánh sáng xanh | Hình mạch điện rối, chữ quá nhỏ |
| Nội thất, gia dụng, handmade | Ấm cúng, tinh tế | #8B5E3C nâu gỗ · #D8C3A5 be · #F7F3EC ngà; hoặc #6B7F82 xanh xám | Playfair; Be Vietnam Pro; handmade: Patrick Hand | toi-gian, tap-chi, so-tay | Phòng thật, ánh sáng tự nhiên | Phông trắng trơn vô hồn |
| Du lịch, khách sạn | Thoáng, bay bổng | #0077B6 xanh biển · #F4A261 cam hoàng hôn · #FAF3E0 cát | Montserrat; resort: Playfair | anh-nen (ảnh thật), toi-gian | Cảnh thật góc rộng | Ảnh mạng không bản quyền |
| Dịch vụ doanh nghiệp (B2B, agency) | Chuyên nghiệp, đáng tin | #1D2B53 navy · màu nhấn của thương hiệu · #FFFFFF | Be Vietnam Pro; Montserrat | toi-gian, mac-dinh, tap-chi (case) | Đội ngũ thật, văn phòng, số liệu | Ảnh stock bắt tay |

Ngành không có trong bảng: chọn dòng gần nhất về **cảm giác cần có** và phân
khúc, rồi chỉnh màu theo bao bì, logo.

## Bố cục ảnh quảng cáo theo phân khúc

- **Cao cấp:** sản phẩm chiếm 40–50% khung, nhiều khoảng trống, chữ tối đa 2
  dòng, không có huy hiệu giá to (góc G1). Nền trầm, ánh sáng viền.
- **Trung cấp:** sản phẩm trong bối cảnh dùng thật (G2) hoặc 3 lợi ích (G3).
- **Bình dân, khuyến mãi:** sản phẩm to, huy hiệu giá hoặc ưu đãi nổi bật, nút
  rõ (G4), màu tương phản mạnh.
- **Dịch vụ** (spa, khoá học, phòng khám): ảnh thật của nơi làm, người làm,
  kết quả được phép đăng. Không dùng ảnh trước–sau cơ thể.

## Ghi lại ở đâu

- **Người dùng có hồ sơ thương hiệu** (`ho-so-thuong-hieu.md`): ghi phương án đã chọn
  vào đó (màu chính, nhấn, nền; font tiêu đề, nội dung; phong cách ảnh; bố cục;
  tránh) để các lần sau dùng lại.
- **tao-anh-bai-page:** `anh/thiet-ke.json`: `mau_chinh`, `mau_phu`, `mau_nen`, `font`,
  `font_tieu_de`, `phong_cach`.
- **tao-anh-quang-cao:** màu và kiểu chữ trong khối 3, 4a của prompt; `chu-tren-anh.json`
  (`mau_*`, `font_tieu_de`, `font_phu`) cho làn B, C.
- **tao-video:** video hoạt hình HTML: màu, font trong file HTML; video giọng đọc: `brand.css`: `--accent` (chính), `--accent-2`
  (nhấn), `--bg` (nền), `--f-head`, `--f-body` (tải font bằng
  `tools/get_fonts.py`, VD `"Playfair Display:700,800"`, `"Nunito:700,800"`).
