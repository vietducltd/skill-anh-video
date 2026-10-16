# Quy tắc viết chữ trên ảnh bài page

Người lướt Facebook nhìn ảnh trước khi đọc caption, và chỉ nhìn khoảng 1-2
giây. Ảnh có nhiệm vụ làm họ dừng lại: **một ý, đọc được ngay, khớp với bài**.

## Ít chữ

| Phần | Giới hạn |
|---|---|
| Tiêu đề | ≤ 12 từ, tối đa 3 dòng |
| Dòng phụ | ≤ 20 từ |
| Danh sách | 3-5 mục, mỗi mục ≤ 8 từ (dòng nhỏ ≤ 8 từ) |
| Cả ảnh | khoảng ≤ 45 từ |

Script tự thu nhỏ chữ khi tràn, nhưng chữ nhỏ trên điện thoại khó đọc. Báo
"thu nhỏ còn dưới 90%" nghĩa là chữ quá nhiều → bớt, đừng giữ.

Nhiều ý không gói được trong một ảnh → đề nghị đổi bài sang album (cần người
dùng đồng ý vì đổi `dinh_dang` trong lịch đã duyệt).

## Khớp với bài, không thêm gì mới

- Chữ trên ảnh **tóm tắt caption**: không thêm con số, sự kiện, lời hứa,
  công dụng nào caption không có. Người đọc thấy ảnh nói một đằng, bài nói
  một nẻo thì mất tin.
- Con số, nghiên cứu, sự kiện → dòng `nguon` ngắn ("Nguồn: <cơ quan công bố>",
  "Nguồn: <tên báo> <ngày đăng>"). Số liệu của chính thương hiệu → "Số liệu
  của shop" hoặc bỏ dòng nguồn nếu caption đã nói rõ.
- Từ cấm, cam kết cấm trong hồ sơ mục 4 cấm cả trên ảnh. Ngành có quy định
  quảng cáo (mỹ phẩm, thực phẩm chức năng, y tế, tài chính): ảnh không hứa kết
  quả, không "trước/sau" về cơ thể.
- Trích dẫn chỉ lấy lời có thật (chủ page, hoặc nhân vật có nguồn).

## Cái không đưa lên ảnh

- Logo, bao bì, tên thương hiệu khác (kể cả thương hiệu được kể trong case
  thật) — ghi rõ trong `ghi_chu` của lịch nếu cần.
- Ảnh người nổi tiếng, ảnh báo chí, ảnh sự kiện của bài trend, ảnh tải trên
  mạng.
- Những thứ hồ sơ mục 7 ghi "Tránh" (VD ảnh stock giả tạo, hình ảnh ngành đó
  nên tránh).
- Hashtag, link, số điện thoại dài (để trong caption).

## Ngắt dòng và nhấn mạnh

- **Chủ động xuống dòng** (`\n`) theo cụm nghĩa: "<cụm 1>\n<cụm 2>" — không
  để trình duyệt tự ngắt giữa cụm.
- **Không để chữ mồ côi**: một chữ đứng riêng ở dòng cuối.
  Script cảnh báo; sửa bằng cách ngắt sớm hơn hoặc đổi chữ.
- **Không tách đôi tên riêng, con số với đơn vị**: tên người, địa danh,
  "<số> đồng", "<số> phút" phải nằm trọn một dòng.
- **Nhấn 1-2 cụm** bằng `*...*` — cụm mang ý chính (con số, từ khoá). Nhấn
  nhiều quá thì không cụm nào nổi.
- Câu hỏi giữ dấu `?`; tiêu đề không cần dấu chấm cuối, trừ câu chốt có chủ ý.

## Cả lô

- Xen nền `sang` và `dam`; không quá 2 ảnh liền nhau cùng mẫu.
- Cùng series (VD "<tên series> kỳ 1, kỳ 2...") thì giữ cùng mẫu, cùng nền, cùng nhãn —
  người theo dõi nhận ra series qua ảnh.
- `nhan` dùng tên trụ cột hoặc tên series, viết ngắn.

## Chọn khổ ảnh

Mặc định 1080×1350 (dọc 4:5): khổ chiếm nhiều chỗ nhất trên bảng tin điện thoại
mà Facebook không cắt. Đăng chỗ khác thì chọn khổ hợp chỗ đó (bảng trong
SKILL.md Bước 1): vuông 1x1 cho Zalo, nhóm; 9x16 cho Story; 16x9 cho YouTube,
website; 1.91x1 cho ảnh chia sẻ link. Chữ quan trọng nằm cách mép ít nhất 72px
(khung mẫu đã chừa sẵn), vì một số chỗ hiển thị (xem trước, chia sẻ) cắt mép
ảnh.

## Lỗi hay gặp

- **Logo chưa tải xong lúc chụp** → ảnh thiếu logo. Script chờ ảnh tải và
  báo "logo không tải được" nếu lỗi; vẫn nên nhìn góc dưới trái khi mở ảnh.
- **Chữ mồ côi** là lỗi hay gặp nhất khi để trình duyệt tự ngắt dòng.
- **Danh sách dài** bị thu nhỏ chữ: 7 mục trên một ảnh là quá nhiều.
- Model tạo ảnh AI viết chữ tiếng Việt hay sai dấu — lý do skill này dựng ảnh
  bằng HTML thay vì nhờ AI vẽ chữ.
