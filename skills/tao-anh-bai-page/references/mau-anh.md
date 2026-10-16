# Các mẫu ảnh và cách viết noi-dung-anh.json

## Mục lục
- Cấu trúc file
- Trường dùng chung
- 8 mẫu (cau-chot, danh-sach, con-so, so-sanh, cap-doi, cau-hoi, trich-dan, anh-nen)
- Phong cách (7 kiểu)
- Album nhiều trang
- Chọn mẫu theo công thức bài
- Ví dụ đầy đủ

## Cấu trúc file

`<slug>/anh/noi-dung-anh.json` (UTF-8):

```json
{
  "bai": [
    { "ma_bai": "B001", "mau": "cau-chot", "nen": "dam", "tieu_de": "..." },
    { "ma_bai": "B004", "trang": [ { "mau": "...", ... }, { "mau": "...", ... } ] }
  ]
}
```

- Một bài một ảnh: các trường đặt thẳng trong mục của bài.
- Album: đặt các trang trong mảng `trang` (xem dưới).
- Giữ lại các bài đã dựng ở lô trước trong file — `-MaBai` chỉ dựng bài được
  chọn.

**Cách viết chữ** (mọi trường văn bản):
- `\n` = xuống dòng. Chủ động ngắt cho câu đẹp, tránh chữ mồ côi.
- `*cụm từ*` = nhấn mạnh (đổi màu; nền sáng có thêm vệt gạch chân). Chỉ 1-2
  cụm mỗi ảnh.
- Dấu ngoặc kép trong chữ viết `\"`. Đường dẫn viết bằng `/`.

## Trường dùng chung

| Trường | Bắt buộc | Ý nghĩa |
|---|---|---|
| `ma_bai` | Có | Trùng mã trong lịch |
| `mau` | Có | Tên mẫu (bên dưới) |
| `kho` | | Khổ ảnh của bài (cả album cùng khổ): `4x5`, `1x1`, `9x16`, `16x9`, `1.91x1`. Bỏ trống → `kho` trong `thiet-ke.json`, không có thì `4x5`. Khổ vuông, ngang ít chỗ hơn: viết ít chữ hơn |
| `phong_cach` | | Kiểu thiết kế (mục Phong cách). Bỏ trống → lấy `phong_cach` trong `thiet-ke.json`, không có thì `mac-dinh`. Đặt ở bài hoặc từng trang album |
| `nen` | | Chỉ dùng với `mac-dinh`: `sang` (nền kem, chữ đậm — mặc định) hoặc `dam` (nền màu chính, chữ trắng). Các phong cách khác có nền riêng |
| `nhan` | | Nhãn tròn góc trên trái. Bỏ trống → lấy `tru_cot` trong lịch. Tối đa ~4 từ (dài quá bị cắt `...`) |
| `kicker` | | Dòng chữ nhỏ in hoa phía trên tiêu đề: chủ đề, series, "Kỳ 1". Tối đa ~6 từ |
| `ket` | | Ô màu phía dưới: câu chốt / mẹo ngắn, 1 dòng |
| `nguon` | | Dòng chữ nhỏ cuối: "Nguồn: ...". **Bắt buộc khi ảnh có con số, nghiên cứu, sự kiện** |

## Phong cách (7 kiểu)

Mẫu (`mau`) quyết định bố cục chữ; phong cách (`phong_cach`) quyết định màu,
font, đồ trang trí. Mẫu nào cũng ghép được với phong cách nào. Logo, chân ảnh
giữ nguyên ở mọi phong cách.

Chọn phong cách **theo ngành và phân khúc trước, theo kiểu bài sau**: chỉ dùng
các phong cách hợp ngành (hồ sơ thương hiệu, hoặc cột "Phong cách tao-anh-bai-page" trong
`references/thiet-ke-theo-nganh.md`), rồi trong số đó
chọn cái hợp kiểu bài theo bảng dưới. Riêng `mac-dinh` (và `anh-nen`) dùng màu,
font của thương hiệu trong `thiet-ke.json`, nên đây là phong cách chính của
mọi ngành; các phong cách khác có màu, font cố định của riêng chúng.

| `phong_cach` | Trông thế nào | Hợp với bài |
|---|---|---|
| `mac-dinh` | Màu thương hiệu, nền kem (`sang`) hoặc nền màu chính (`dam`), vòng tròn mờ | Bài nền tảng, kiến thức chính |
| `tap-chi` | Giấy ngà, chữ có chân (Noto Serif), kẻ đôi, đỏ gạch, số đánh nghiêng | Câu chuyện, case thật, trích dẫn, tin báo |
| `tuong-phan` | Nền đen, chữ đứng in hoa (Anton) nhấn khối vàng, vạch sọc cảnh báo | Trend, cảnh báo, con số gây sốc, việc cần làm gấp |
| `so-tay` | Trang vở kẻ dòng, chữ viết tay (Patrick Hand), bút dạ quang, giấy nhớ, băng dính | Mẹo, ghi chép, lá thư, so sánh trước – sau |
| `bang-den` | Bảng đen khung gỗ, phấn trắng – vàng | Bài giảng, nguyên tắc, đố vui, câu hỏi |
| `toi-gian` | Trắng, nhiều khoảng thở, Montserrat, một vạch màu thương hiệu | Quan điểm thẳng, nghiên cứu, con số lớn |
| `pastel` | Hồng đào – tím nhạt, thẻ bo tròn, chấm số gradient | Gia đình, vợ chồng, con cái, các kiểu người |

- `tuong-phan`: tiêu đề in hoa nên ngắn (≤ 4 dòng), con số đẹp nhất với mẫu `con-so`.
- `so-tay`, `bang-den`: chữ viết tay to hơn, mỗi mục danh sách nên ≤ 6 từ.
- VD lô 14 ảnh: 4-5 phong cách hợp ngành, mỗi phong cách 2-4 ảnh, không 2 ảnh
  liền nhau cùng phong cách.

## 8 mẫu

### `cau-chot` — một câu lớn
Hợp: hook, nguyên tắc, câu hỏi FAQ, câu trả lời ngắn.

| Trường | |
|---|---|
| `tieu_de` | Câu chính, ≤ 12 từ |
| `phu` | Câu giải thích, ≤ 20 từ (tuỳ chọn) |
| `co_chu` | `lon` (câu rất ngắn, ≤ 6 từ) / `vua` (câu dài) — tuỳ chọn |

### `danh-sach` — các bước, các ý
Hợp: danh-sach, mẹo, checklist.

| Trường | |
|---|---|
| `tieu_de` | Tiêu đề ngắn |
| `muc` | 3-5 mục. Mỗi mục là chuỗi, hoặc `{"t": "dòng chính", "phu": "dòng nhỏ"}` |
| `dau` | `tick` để thay số thứ tự bằng dấu ✓ |

### `con-so` — một con số lớn
Hợp: số liệu gây chú ý (trend, nghiên cứu, thành tích có thật).

| Trường | |
|---|---|
| `so` | Con số, ≤ 7 ký tự (VD `38%`, `1.200`, `250.000`) |
| `don_vi` | Đơn vị nhỏ bên cạnh (`đ/tháng`, `khách`) |
| `tieu_de` | Ý nghĩa của con số, 1-2 dòng |
| `phu` | Tuỳ chọn |
| `nguon` | Bắt buộc |

### `so-sanh` — hai thẻ cạnh nhau
Hợp: bab (trước/sau), lật hiểu lầm (nghĩ là / thật ra), A vs B.

| Trường | |
|---|---|
| `tieu_de` | Tiêu đề |
| `trai`, `phai` | `{"nhan": "nhãn nhỏ", "lon": "chữ lớn ≤ 3 từ", "mo_ta": "≤ 8 từ"}` |
| `chon` | `trai` / `phai`: viền đậm cho bên đúng |
| `gach` | `trai` / `phai`: gạch ngang chữ lớn bên sai |

### `cap-doi` — bảng 2 cột
Hợp: nên/tránh, đúng/sai, A/B nhiều tiêu chí.

| Trường | |
|---|---|
| `tieu_de` | Tiêu đề |
| `cot` | 2 tên cột |
| `hang` | 3-5 hàng, mỗi hàng `["ô trái", "ô phải"]`, mỗi ô ≤ 3 từ |

### `cau-hoi` — bài tương tác
Hợp: cau-hoi (chọn A/B).

| Trường | |
|---|---|
| `tieu_de` | Câu hỏi |
| `lua_chon` | 2-4 lựa chọn, mỗi cái ≤ 5 từ (tự đánh A, B, C...) |
| `nguon` | Dùng làm dòng hướng dẫn: "Bình luận A hoặc B" |

### `trich-dan` — một câu nói
Hợp: storytelling, quan điểm, nguyên tắc của chủ page.

| Trường | |
|---|---|
| `tieu_de` | Câu nói, ≤ 16 từ |
| `ai` | Người nói. **Chỉ trích lời có thật**: lời chủ page (trong hồ sơ/caption), hoặc lời nhân vật có nguồn; lời dịch ghi "đại ý" trong caption |

### `anh-nen` — ảnh thật phủ chữ
Hợp: ảnh thật của thương hiệu (cửa hàng, xưởng, lớp học, sản phẩm) + một câu.

| Trường | |
|---|---|
| `anh` | Đường dẫn ảnh (tính từ thư mục thương hiệu, dấu `/`). Cùng dáng với khổ (dọc cho 4x5, 9x16; ngang cho 16x9, 1.91x1), cạnh ngắn ≥ 1080px |
| `tieu_de` | ≤ 10 từ, nằm ở phần dưới ảnh trên lớp tối |
| `phu` | Tuỳ chọn |
| `co_chu` | `lon` / `vua` — tuỳ chọn. `vua` khi sản phẩm nằm thấp, cần chữ chiếm ít chỗ |
| `vi_tri_anh` | Tuỳ chọn. Phần ảnh giữ lại khi cắt cho vừa khung, VD `top`, `50% 30%`, `left`. Chỉ có tác dụng theo chiều ảnh bị cắt: ảnh dọc cao hơn khung thì chỉnh trên/dưới; ảnh vuông, ảnh ngang thì chỉnh trái/phải |

Khối chữ nằm sát đáy ảnh. Ảnh có sản phẩm nằm thấp (giữa – dưới khung) thì
chữ dễ đè lên sản phẩm: bỏ `kicker`, dùng `co_chu: vua`, viết tiêu đề 1 dòng,
hoặc chọn ảnh có khoảng trống phía dưới. Mở ảnh ra xem để chắc chữ không đè
nhãn sản phẩm.

Chỉ dùng ảnh người dùng đưa hoặc ảnh trong hồ sơ mục 8. Không dùng ảnh trên
mạng, ảnh báo chí, ảnh người nổi tiếng.

## Album nhiều trang

```json
{ "ma_bai": "B004", "nhan": "<nhãn chung của album>",
  "trang": [
    { "mau": "cau-chot", "nen": "dam", "tieu_de": "Trang bìa: hứa điều người đọc nhận được" },
    { "mau": "danh-sach", "nen": "sang", "...": "..." },
    { "mau": "cau-chot", "nen": "dam", "tieu_de": "Trang kết: câu chốt + lời mời bình luận" }
  ] }
```

- 3-6 trang. Trang 1 là bìa (Facebook hiện to nhất), trang cuối là câu chốt.
- Góc trên phải tự hiện số trang `1/4`, `2/4`.
- `nhan` đặt ở mức bài dùng cho mọi trang; trang nào cần khác thì đặt riêng.
- Ảnh ra `B004-1.png`... và `file_anh` = `anh/B004-1.png|anh/B004-2.png|...`.

## Chọn mẫu theo công thức bài

| `cong_thuc` / góc viết | Mẫu gợi ý |
|---|---|
| hook-value-cta | `cau-chot` (câu hook), `con-so` nếu hook là con số |
| danh-sach | `danh-sach`; nhiều ý dài → album |
| faq | `cau-chot` (câu hỏi + trả lời ngắn ở `phu`), `so-sanh` (nghĩ là / thật ra) |
| storytelling | `trich-dan`, `anh-nen` (ảnh thật), `cau-chot` |
| bab | `so-sanh` (trước / sau) |
| cau-hoi | `cau-hoi` |
| thong-bao | `cau-chot` với `ket` = thời gian / ưu đãi; có ảnh sản phẩm thật → `anh-nen` |
| Bài trend có con số | `con-so` + `nguon` |
| Lật hiểu lầm | `so-sanh` (gạch bên sai) |
| Các kiểu người | `danh-sach` hoặc album mỗi kiểu một trang |

## Ví dụ đầy đủ

```json
{
  "bai": [
    { "ma_bai": "B001", "mau": "cau-chot", "nen": "dam", "nhan": "<tên series>",
      "kicker": "Kỳ 1",
      "tieu_de": "<vế đầu câu hỏi>\n*<cụm nhấn>* <vế cuối>?",
      "phu": "<câu trả lời ngắn lấy từ bài>\n<ý giải thích lấy từ bài>",
      "ket": "<mẹo ngắn lấy từ bài>" },
    { "ma_bai": "B003", "mau": "cau-hoi", "nhan": "<tên trụ cột>",
      "tieu_de": "<câu hỏi lấy từ bài>,\nbạn *<cụm nhấn>*?",
      "lua_chon": ["<lựa chọn A>", "<lựa chọn B>"],
      "nguon": "Bình luận \"A\" hoặc \"B\" nhé" },
    { "ma_bai": "B005", "mau": "con-so", "nen": "dam", "kicker": "<chủ đề tin, ngày áp dụng>",
      "so": "<con số trong bài>", "don_vi": "<đơn vị>",
      "tieu_de": "<ý nghĩa con số>.\n<câu hỏi gợi suy nghĩ có *<cụm nhấn>*>",
      "nguon": "Nguồn: <tên văn bản hoặc báo, ngày đăng>" }
  ]
}
```
