# Viết script.json

Toàn bộ video được điều khiển bằng một file `script.json` trong thư mục dự án. Không cần viết code. File gồm bốn phần: `meta` cho thương hiệu và thẻ kết, `scenes` cho hình, `lines` cho lời đọc và phụ đề, `cues` cho âm thanh nhấn.

## 1. Từ tài liệu ra kịch bản

1. Đọc tài liệu, ghi mỗi ý có thể lên màn hình thành một dòng trong `facts.md` kèm vị trí trong tài liệu. Không có trong tài liệu thì không đưa vào video.
2. Rút một thông điệp chính trong một câu, 3 đến 5 ý nhấn và một câu kết hoặc lời mời.
3. Mỗi ý nhấn thành một cảnh. Video 30 giây khoảng 6 cảnh, 60 giây khoảng 9 cảnh.
4. Mỗi cảnh một hoặc hai dòng lời, mỗi dòng dưới 15 từ, tối đa 22 từ.

## 2. Mẫu đầy đủ

Mỗi chỗ `<...>` là chỗ điền nội dung lấy từ tài liệu của người dùng.

```json
{
  "meta": {
    "brand": "<Tên hiện ở góc trên>",
    "letters": "",
    "cta": { "kicker": "<Dòng nhỏ thẻ kết>", "headline": "<Câu chốt>\n[<từ nhấn>]", "rows": [["<Nhãn liên hệ>", "<Giá trị>"]] }
  },
  "bpm": 120, "hold": 2.5, "capMaxWords": 9,
  "scenes": [
    { "type": "hook", "min": 4, "kicker": "<Chủ đề>", "headline": "<Câu hỏi mở đầu>\n[<từ nhấn>]?", "wm": "?" },
    { "type": "list", "min": 5, "kicker": "<Số ý>", "headline": "<Tiêu đề danh sách>", "items": [["1", "<Ý 1>"], ["2", "<Ý 2>"], ["3", "<Ý 3>"]] },
    { "type": "point", "min": 5, "headline": "<Tiêu đề ý 1>", "sub": "<Dòng phụ ngắn>", "prop": "clipboard", "pose": "hold", "chips": ["<Chip 1>", "<Chip 2>"] },
    { "type": "stat", "min": 4.5, "headline": "<Tiêu đề con số>", "value": 0, "unit": "", "label": "<nhãn con số>", "countAt": { "line": 4, "word": "con số" } },
    { "type": "quiz", "min": 5, "headline": "<Câu hỏi tình huống>?", "answer": { "text": "<Đáp án ngắn>", "at": { "line": 6, "word": "đáp án" } } },
    { "type": "cta", "min": 4 }
  ],
  "lines": [
    { "scene": 0, "sub": "<Câu mở đầu nêu vấn đề hoặc câu hỏi>" },
    { "scene": 1, "sub": "<Câu giới thiệu ba ý chính>" }
  ],
  "cues": [ { "line": 4, "word": "con số", "sfx": "ding" } ]
}
```

## 3. Sáu kiểu cảnh

| Kiểu | Dùng khi | Trường riêng | Giới hạn |
|---|---|---|---|
| `hook` | mở đầu, câu hỏi hoặc nỗi đau | `bubble` (chữ trong bong bóng, mặc định “?”) | tiêu đề tối đa 34 ký tự |
| `list` | liệt kê bước, thành phần | `items: [["1", "Tên"], ...]`, `itemsAt` | 2 đến 5 mục, mỗi mục tối đa 20 ký tự |
| `point` | một ý có minh hoạ | `figure`, `partner`, `pose`, `prop`, `actionAt`, `chips` | tối đa 3 chip, mỗi chip 22 ký tự |
| `quiz` | hỏi và đáp, tình huống | `answer: {"text", "at"}` | đáp án tối đa 30 ký tự |
| `stat` | một con số quan trọng | `value`, `unit`, `label`, `countAt` | số phải có trong tài liệu |
| `cta` | cảnh kết, lời mời | lấy nội dung từ `meta.cta` | mỗi dòng liên hệ ngắn |

Giá trị cho kiểu `point` gồm có các nhóm sau.

- `figure`, `partner` gồm `coach`, `coach2`, `client`
- `pose` gồm `point`, `hold`, `cheer`, `squat`, `wave`
- `prop` gồm `bulb`, `chart`, `plant`, `check`, `clipboard`, `none`

Các trường chung của mọi cảnh như sau.

| Trường | Ý nghĩa |
|---|---|
| `kicker` | dòng nhỏ phía trên tiêu đề |
| `headline` | tiêu đề, `\n` để xuống dòng chủ động, `[từ]` để tô màu nhấn, `_` nối từ ghép |
| `sub` | dòng phụ dưới tiêu đề |
| `wm` | chữ nền khổng lồ mờ phía sau |
| `min` | số giây tối thiểu của cảnh; cảnh tự dài thêm nếu lời đọc dài |

## 4. Dòng lời

| Trường | Ý nghĩa |
|---|---|
| `scene` | số thứ tự cảnh, bắt đầu từ 0 |
| `sub` | phụ đề hiện trên màn hình, dấu `_` nối từ ghép để không bị ngắt dòng |
| `tts` | chữ cho máy đọc khi khác phụ đề, dạng `[["vi", "..."], ["en", "..."]]`; dùng cho tên tiếng Anh, số điện thoại, chữ viết tắt |
| `say` | câu cho máy đọc trả phí (OpenAI, Gemini) |
| `pause` | giây nghỉ sau dòng, mặc định 0,28; câu hỏi nên để 0,7 |

Với số điện thoại, ví dụ `"sub": "Gọi 0900 123 456"`, `"tts": [["vi", "Gọi không chín không không, một hai ba, bốn năm sáu"]]`.

## 5. Neo theo từ

Mọi trường kết thúc bằng `At` và mục `cues` nhận neo `{"line": số dòng, "word": "từ"}`. Hình hoặc âm thanh sẽ xuất hiện đúng lúc từ đó được đọc. Từ phải có nguyên văn trong `sub` của dòng đó, không phân biệt dấu. Sửa lời đọc thì mốc tự dời theo.

Âm thanh nhấn có sẵn gồm có: `whoosh`, `pop`, `ding`, `chime`, `boom`, `tick`, `rise`. Thêm `"vol"` (0,5 là chuẩn) và `"offset"` (giây, âm là sớm hơn) nếu cần.

## 6. Đổi thương hiệu

Sửa `brand.css`: màu `--accent`, `--accent-2`, `--ink`, nền `--bg`, phông `--f-head`, `--f-body`. Thay `assets/logo.png` (thẻ kết) và `assets/mark.png` (góc trên), dùng PNG nền trong. Phông mới tải bằng `python3 tools/get_fonts.py "Tên phông:700,800" "Phông nội dung:500,600"`, chỉ chọn phông có dấu tiếng Việt.

## 7. Kiểm trước khi dựng

`python3 <skill>/scripts/check_script.py <dự án> --target 45` kiểm độ dài chữ, số chip, số mục, neo có trong phụ đề không, và ước tính thời lượng. Sửa hết lỗi trước khi chạy tạo giọng, vì tạo giọng và render tốn thời gian nhất.
