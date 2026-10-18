# Quy tắc ảnh quảng cáo Facebook + bảng soát

## Kích thước

| Khổ | File xuất (script tự làm) | Dùng cho |
|---|---|---|
| 4x5 | 1080×1350 | Bảng tin trên điện thoại. **Khổ chính**, chiếm nhiều diện tích nhất |
| 1x1 | 1080×1080 | Bảng tin, cột phải, Marketplace |
| 9x16 | 1080×1920 | Story, Reels, TikTok, Zalo Story |
| 16x9 | 1920×1080 | Ảnh bìa video YouTube, banner website, slide, màn hình ở cửa hàng |
| 1.91x1 | 1200×628 | Ảnh hiện khi chia sẻ link website/bài blog, quảng cáo dạng link |

Sàn thương mại điện tử (Shopee, Lazada, TikTok Shop) và Zalo dùng ảnh vuông 1x1.

Khi bật "Vị trí Advantage+", nên có 1 ảnh 4x5 (hoặc 1x1) và 1 ảnh 9x16 cùng góc
sáng tạo để Facebook tự chọn theo vị trí.

## Vùng an toàn

- Bảng tin (1x1, 4x5): chữ và sản phẩm nằm trong **80% ở giữa**, vì Facebook có
  thể tự cắt mép tới 5%.
- Story/Reels (9x16): **14% trên** (ảnh đại diện, tên page) và **20% dưới** (nút
  kêu gọi, ô trả lời) bị giao diện che. Không đặt chữ hay nút ở hai vùng này.
- Ngang (16x9, 1.91x1): chữ và sản phẩm trong **90% ở giữa**. Ảnh chia sẻ link
  hiện khá nhỏ trên điện thoại: tiêu đề ngắn, chữ to, ít chữ phụ.

## Lượng chữ

- Facebook đã bỏ luật cứng 20% chữ, nhưng ảnh nhiều chữ thì giá hiển thị cao
  hơn và phân phối kém hơn. Giữ tổng diện tích chữ **dưới 20%**.
- Tiêu đề trên ảnh ≤ 8 chữ, phụ đề ≤ 6 chữ, nút ≤ 3 chữ. Phần giải thích dài
  để dành cho caption (bài viết quảng cáo), không nhồi lên ảnh.

## Chính sách nội dung (bị từ chối nếu vi phạm)

- **Không ảnh "trước – sau" về cơ thể** (da, cân nặng, tóc, mụn...), không
  phóng to khuyết điểm cơ thể.
- **Mỹ phẩm, thực phẩm chức năng:** không chữ mang nghĩa điều trị trên ảnh
  ("trị", "chữa", "đặc trị", "hết mụn", "trắng da sau X ngày"). Dùng lợi ích
  cảm nhận được: hương, cảm giác, tiện lợi. Xem thêm từ cấm của ngành trong hồ
  sơ thương hiệu (nếu người dùng có).
- **Không giao diện giả:** nút play giả, thông báo tin nhắn giả, nút đóng giả.
- **Không bịa:** ưu đãi, giá, số khách hàng, số sao đánh giá, logo báo chí hay
  chứng nhận chỉ được đưa lên ảnh khi có thật và có trong content hoặc hồ sơ.
- **Không gọi thẳng đặc điểm cá nhân** của người xem ("Bạn đang béo?", "Bạn bị
  hói?"). Cách viết này hợp trong caption dạng câu hỏi mở, nhưng trên
  ảnh thì dễ bị từ chối.

## Bảng soát từng ảnh (bắt buộc trước khi giao)

Chạy `soi-chu.ps1` để phóng to vùng chữ, rồi mở từng ảnh ra xem.

| # | Kiểm tra | Cách xử lý khi hỏng |
|---|---|---|
| 1 | Chữ trên ảnh **đúng từng ký tự và dấu** so với bảng chữ đã chốt (ă/â, ơ/ô, ư, dấu hỏi/ngã, đ) | Làn M: gửi câu sửa trong cùng cuộc trò chuyện ChatGPT. Làn A: tạo lại, nhắc riêng chữ bị sai. Sai lần 2 thì chuyển sang làn B |
| 2 | Giá, số liệu đúng tuyệt đối (250.000đ, không phải 25.000đ hay 250.00đ) | Như trên |
| 3 | Sản phẩm giống ảnh gốc: dáng, màu, logo, chữ lớn trên bao bì | Mô tả sản phẩm kỹ hơn ở khối 2, thêm ảnh gốc góc khác. Chữ li ti ở mặt hông bao bì bị nhoè thì chấp nhận được |
| 4 | Không có chữ lạ, logo lạ, watermark, giao diện giả | Tạo lại, kiểm tra prompt có lọt từ cấm không |
| 5 | Chữ trong vùng an toàn, 9x16 không có chữ ở 14% trên và 20% dưới | Tạo lại, hoặc làn B |
| 6 | Tổng chữ < 20% diện tích | Bỏ bớt phụ đề hoặc nhãn |
| 7 | Không vi phạm chính sách ở trên | Sửa bảng chữ, tạo lại |
| 8 | Màu, kiểu chữ, bối cảnh, bố cục **đúng phong cách đã chọn và hợp ngành, phân khúc** (VD trà cao cấp không ra kiểu flash sale chữ vàng đỏ; đồ chơi trẻ em không ra tông đen nặng) | Sửa khối 3, 4a theo `thiet-ke-theo-nganh.md`, tạo lại |

| 9 | Làn D (ảnh ghép): viền sạch, có bóng tiếp đất, góc nhìn và hướng sáng khớp nền | Tách lại với `--vung` hoặc `--mo-hinh birefnet-general-lite`; đổi nền cùng góc nhìn; chỉnh `--day`, `--bong` |

Mỗi ảnh ghi kết quả vào `duyet-anh.md`: **Đạt**, **Tạo lại** (kèm lý do), hoặc
**Chuyển làn B**.

## Nguồn

Các quy tắc về khổ ảnh, vùng an toàn, lượng chữ, từ cấm trong prompt và câu
giữ chữ trên bao bì được rút gọn từ bộ skill mã nguồn mở
[motiful/product-shots](https://github.com/motiful/product-shots) (giấy phép
MIT), sau đó chỉnh lại cho quảng cáo Facebook tại Việt Nam.
