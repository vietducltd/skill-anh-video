<#
tao-anh-quang-cao · Chèn chữ tiếng Việt lên ảnh KHÔNG CHỮ: nền AI dựng (làn B) hoặc ảnh chụp thật của
người dùng (làn C — miễn phí, không gọi AI).

Cách dùng:
  powershell -ExecutionPolicy Bypass -File chen-chu.ps1 -Anh "B1-1x1-nen.png" -NoiDung "chu-tren-anh.json" -Ra "B1-1x1.png"
  Ảnh chụp thật (thường là ảnh vuông) → ảnh quảng cáo 4:5:
  powershell -ExecutionPolicy Bypass -File chen-chu.ps1 -Anh "anh-goc\sp.jpg" -NoiDung "chu-tren-anh.json" -Kho 4x5 -Ra "C1-4x5.png"
  Chỉ đưa ảnh về đúng khổ, không chèn chữ (ảnh người dùng tạo trên ChatGPT ra khổ 2:3 → 4:5):
  powershell -ExecutionPolicy Bypass -File chen-chu.ps1 -Anh "tai-ve\G1.png" -Kho 4x5 -GiuDu -Ra "G1-4x5.png"
  Ảnh ngang (ảnh bìa YouTube, banner web, ảnh chia sẻ link):
  powershell -ExecutionPolicy Bypass -File chen-chu.ps1 -Anh "anh-goc\sp.jpg" -NoiDung "chu-tren-anh.json" -Kho 16x9 -Ra "C1-16x9.png"

Tham số:
  -NoiDung    file chữ (JSON bên dưới). Bỏ trống = chỉ đổi khổ, thu về 1080px, không vẽ gì
  -Kho        khổ ảnh ra (mặc định giu = giữ tỉ lệ ảnh vào):
                1x1    1080×1080  vuông      4x5   1080×1350  dọc      9x16  1080×1920  dọc dài
                16x9   1920×1080  ngang      1.91x1  1200×628  ngang dẹt (ảnh chia sẻ link)
              Khổ dọc, vuông: ảnh vào thấp hơn khổ cần thì nới phía trên bằng nền làm mờ của chính
              ảnh (chỗ để chữ); cao hơn thì cắt giữa. Khổ ngang: ảnh vào hẹp hơn thì đặt ảnh sát phải,
              nới bên trái bằng nền mờ, chữ nằm ở nửa trái; rộng hơn thì cắt giữa.
  -RongXuat   chiều rộng ảnh ra. Bỏ trống = kích thước chuẩn của khổ ở trên (khổ giu: rộng 1080).
              0 = giữ nguyên chiều rộng ảnh vào
  -GiuDu      giữ đủ ảnh, không cắt: thu ảnh vừa khung, phần thừa hai bên (hoặc trên dưới) lấp bằng
              nền mờ của chính ảnh. Dùng cho ảnh AI (ChatGPT, Gemini) đã có chữ sát mép.

chu-tren-anh.json (UTF-8), ô nào để trống thì không vẽ:
  {
    "tieu_de": "<DÒNG 1>|<DÒNG 2>",   <- dấu | = xuống dòng
    "phu_de": "<Phụ đề>",
    "gia_nho": "<chữ nhỏ trước giá>",
    "gia": "<giá>",
    "nut": "<NÚT>",
    "mau_chu": "#RRGGBB",      chữ tiêu đề + nền nút
    "mau_nhan": "#RRGGBB",     phụ đề + nền huy hiệu giá
    "mau_nen_toi": "#RRGGBB",  dải màu mờ phía trên giúp chữ dễ đọc (ảnh nền sáng: đặt màu sáng
                               gần màu nền ảnh, và đổi mau_chu sang màu đậm)
    "mau_chu_nut": "#RRGGBB",  chữ trong huy hiệu giá và nút
    "font_tieu_de": "Cambria", font tiêu đề, giá, nút: tên font đã cài trên máy, hoặc file .ttf/.otf
                               (đường dẫn tính từ thư mục file JSON). Bỏ trống = mặc định
    "font_phu": "Segoe UI Semibold"   font phụ đề, chữ nhỏ trong huy hiệu giá
    "do_dam_nen": 220          tuỳ chọn: dải tối đậm đặc tới hết phụ đề (0-255), cho ảnh nền sáng, rối
  }

Chữ, giá và nút nằm trong vùng an toàn: lề trái/phải 10%; khổ 1x1, 4x5 từ 10% đến 88% chiều cao;
khổ 9x16 từ 15% đến 78% (chừa chỗ giao diện Story/Reels); khổ ngang: cột chữ ở 46% bên trái, từ 12%
đến 86% chiều cao. Tiêu đề tự co cỡ cho vừa.
Font mặc định: Montserrat nếu máy có, không thì Segoe UI. Chọn font theo ngành:
tao-anh-bai-page/references/thiet-ke-theo-nganh.md (bảng font Windows đủ dấu tiếng Việt —
Arial Black, Impact, Georgia, Comic Sans MS, Trebuchet MS THIẾU dấu, không dùng).
#>
param(
    [Parameter(Mandatory = $true)] [string]$Anh,
    [string]$NoiDung = "",
    [Parameter(Mandatory = $true)] [string]$Ra,
    [ValidateSet("giu", "1x1", "4x5", "9x16", "16x9", "1.91x1")] [string]$Kho = "giu",
    [int]$RongXuat = -1,
    [switch]$GiuDu
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

if ($NoiDung) {
    $c = [IO.File]::ReadAllText((Resolve-Path $NoiDung), [Text.Encoding]::UTF8) | ConvertFrom-Json
    $thuMucJson = Split-Path -Parent (Resolve-Path $NoiDung).Path
} else { $c = [pscustomobject]@{}; $thuMucJson = (Get-Location).Path }
function Gia-Tri($ten, $macDinh) { if ($c.PSObject.Properties[$ten] -and $c.$ten) { return [string]$c.$ten } return $macDinh }
function Mau([string]$hex, [int]$alpha = 255) {
    $h = $hex.TrimStart("#")
    return [System.Drawing.Color]::FromArgb($alpha, [Convert]::ToInt32($h.Substring(0, 2), 16), [Convert]::ToInt32($h.Substring(2, 2), 16), [Convert]::ToInt32($h.Substring(4, 2), 16))
}

$coSan = (New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
$giuFont = New-Object System.Collections.ArrayList   # giữ bộ font nạp từ file sống tới lúc vẽ xong
# Trả về FontFamily: tên font đã cài trên máy, hoặc file .ttf/.otf; không có thì lấy font mặc định
function Lay-Font([string]$giaTri, [string[]]$macDinh) {
    if ($giaTri) {
        if ($giaTri -match '\.(ttf|otf)$') {
            $p = if ([IO.Path]::IsPathRooted($giaTri)) { $giaTri } else { Join-Path $thuMucJson $giaTri }
            if (Test-Path $p) {
                $pfc = New-Object System.Drawing.Text.PrivateFontCollection
                $pfc.AddFontFile((Resolve-Path $p).Path); [void]$giuFont.Add($pfc)
                return $pfc.Families[0]
            }
            Write-Host "LƯU Ý: không thấy file font $p — dùng font mặc định"
        } elseif ($coSan -contains $giaTri) { return New-Object System.Drawing.FontFamily($giaTri) }
        else { Write-Host "LƯU Ý: máy chưa cài font '$giaTri' — dùng font mặc định" }
    }
    foreach ($f in $macDinh) { if ($coSan -contains $f) { return New-Object System.Drawing.FontFamily($f) } }
    return New-Object System.Drawing.FontFamily("Arial")
}
# Font đã đậm sẵn (Black, ExtraBold, SemiBold...) dùng kiểu thường; còn lại dùng kiểu đậm nếu font có
function Kieu-Dam($fam) {
    $thuong = [System.Drawing.FontStyle]::Regular; $dam = [System.Drawing.FontStyle]::Bold
    if ($fam.Name -match 'Black|Bold|Heavy|Semibold' -and $fam.IsStyleAvailable($thuong)) { return $thuong }
    if ($fam.IsStyleAvailable($dam)) { return $dam }
    return $thuong
}
$fontDam = Lay-Font (Gia-Tri "font_tieu_de" "") @("Montserrat ExtraBold", "Segoe UI Black", "Arial")
$fontVua = Lay-Font (Gia-Tri "font_phu" "") @("Montserrat SemiBold", "Segoe UI Semibold", "Arial")
$kieuDam = Kieu-Dam $fontDam
$kieuVua = Kieu-Dam $fontVua

$tieuDe = (Gia-Tri "tieu_de" "").Replace("|", "`n")
$phuDe = Gia-Tri "phu_de" ""
$giaNho = Gia-Tri "gia_nho" ""
$gia = Gia-Tri "gia" ""
$nut = Gia-Tri "nut" ""
$mChu = Mau (Gia-Tri "mau_chu" "#FFFFFF")
$mNhan = Mau (Gia-Tri "mau_nhan" "#FFFFFF")
$mChuNut = Mau (Gia-Tri "mau_chu_nut" "#111111")
$hexToi = Gia-Tri "mau_nen_toi" "#000000"

# Mở ảnh: GDI+ không đọc được WebP (ảnh tải từ ChatGPT, Gemini hay là WebP) → giải mã bằng WIC của Windows
function Mo-Anh([string]$p) {
    try { return [System.Drawing.Image]::FromFile($p) } catch { }
    Add-Type -AssemblyName PresentationCore
    $fs = [IO.File]::OpenRead($p)
    try {
        $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create($fs, [System.Windows.Media.Imaging.BitmapCreateOptions]::None, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
        $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($dec.Frames[0]))
        $ms = New-Object IO.MemoryStream; $enc.Save($ms); $ms.Position = 0
        $tam = [System.Drawing.Image]::FromStream($ms)
        $anh = New-Object System.Drawing.Bitmap($tam); $tam.Dispose(); $ms.Dispose()
        return $anh
    } catch { throw "Không mở được ảnh $p (định dạng lạ). Mở ảnh bằng Paint rồi Lưu thành PNG, chạy lại." }
    finally { $fs.Dispose() }
}
$src = Mo-Anh (Resolve-Path $Anh).Path
# Kích thước chuẩn từng khổ (rộng, cao)
$chuan = @{ "1x1" = @(1080, 1080); "4x5" = @(1080, 1350); "9x16" = @(1080, 1920); "16x9" = @(1920, 1080); "1.91x1" = @(1200, 628) }
if ($chuan.ContainsKey($Kho)) { $tiLe = $chuan[$Kho][1] / $chuan[$Kho][0] } else { $tiLe = $src.Height / $src.Width }
$W = if ($RongXuat -gt 0) { $RongXuat } elseif ($RongXuat -eq 0) { $src.Width } elseif ($chuan.ContainsKey($Kho)) { $chuan[$Kho][0] } else { 1080 }
$H = if ($RongXuat -lt 0 -and $chuan.ContainsKey($Kho)) { $chuan[$Kho][1] } else { [int][Math]::Round($W * $tiLe) }
$hAnh = [int][Math]::Round($src.Height * $W / $src.Width)   # chiều cao ảnh vào khi thu về rộng $W
$wAnh = [int][Math]::Round($src.Width * $H / $src.Height)   # chiều rộng ảnh vào khi thu về cao $H
$ngang = $W -gt $H
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
if ($GiuDu -and [Math]::Abs($hAnh - $H) -gt 2) {
    # Giữ đủ ảnh: nền = ảnh phủ kín khung rồi làm mờ (thu rất nhỏ rồi phóng lại); ảnh chính thu vừa khung
    $lat = New-Object System.Drawing.Imaging.ImageAttributes
    $lat.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
    $tiNguon = $src.Height / $src.Width
    if ($tiNguon -gt $tiLe) { $cw = $src.Width; $ch = $src.Width * $tiLe } else { $ch = $src.Height; $cw = $src.Height / $tiLe }
    $nho = New-Object System.Drawing.Bitmap(36, [int][Math]::Max(8, [Math]::Round(36 * $tiLe)))
    $gn = [System.Drawing.Graphics]::FromImage($nho)
    $gn.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear
    $gn.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $nho.Width, $nho.Height)), [single](($src.Width - $cw) / 2), [single](($src.Height - $ch) / 2), [single]$cw, [single]$ch, [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $gn.Dispose()
    $g.DrawImage($nho, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), 0, 0, $nho.Width, $nho.Height, [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $nho.Dispose()
    # Làm tối nền mờ để hai dải bên trông như viền tối, không tranh chỗ với ảnh chính
    $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(130, 0, 0, 0))), 0, 0, $W, $H)
    $s = [Math]::Min($W / $src.Width, $H / $src.Height)
    $w2 = [int][Math]::Round($src.Width * $s); $h2 = [int][Math]::Round($src.Height * $s)
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle([int](($W - $w2) / 2), [int](($H - $h2) / 2), $w2, $h2)))
} elseif ($ngang -and $wAnh -lt $W) {
    # Khổ ngang, ảnh vào hẹp hơn: đặt ảnh sát phải, phần trái lấp bằng bản làm mờ của dải trái ảnh,
    # hoà dần vào ảnh trong $chong px để không lộ đường nối. Chữ sẽ nằm ở phần trái này
    $them = $W - $wAnh; $chong = [int][Math]::Min(160, $wAnh / 4)
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle($them, 0, $wAnh, $H)))
    $lat = New-Object System.Drawing.Imaging.ImageAttributes
    $lat.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
    $nho = New-Object System.Drawing.Bitmap(8, 32)
    $gn = [System.Drawing.Graphics]::FromImage($nho)
    $gn.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear
    $gn.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, 8, 32)), 0, 0, [single]($chong * $src.Height / $H), $src.Height, [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $gn.Dispose()
    $mo = New-Object System.Drawing.Bitmap(($them + $chong), $H)
    $gm = [System.Drawing.Graphics]::FromImage($mo)
    $gm.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gm.DrawImage($nho, (New-Object System.Drawing.Rectangle(0, 0, ($them + $chong), $H)), 0, 0, 8, 32, [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $gm.Dispose(); $nho.Dispose()
    $g.DrawImage($mo, (New-Object System.Drawing.Rectangle(0, 0, $them, $H)), 0, 0, $them, $H, [System.Drawing.GraphicsUnit]::Pixel)
    $buoc = 4
    for ($i = 0; $i -lt $chong; $i += $buoc) {
        $cm = New-Object System.Drawing.Imaging.ColorMatrix
        $cm.Matrix33 = [single](1 - ($i + $buoc / 2) / $chong)
        $ia = New-Object System.Drawing.Imaging.ImageAttributes
        $ia.SetColorMatrix($cm)
        $g.DrawImage($mo, (New-Object System.Drawing.Rectangle(($them + $i), 0, $buoc, $H)), ($them + $i), 0, $buoc, $H, [System.Drawing.GraphicsUnit]::Pixel, $ia)
        $ia.Dispose()
    }
    $mo.Dispose()
} elseif ($ngang -or $hAnh -ge $H) {
    # Khổ ngang, ảnh vào rộng hơn: cắt giữa theo chiều ngang
    if ($wAnh -gt $W) {
        $wNguon = $W * $src.Height / $H
        $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), [single](($src.Width - $wNguon) / 2), 0, [single]$wNguon, $src.Height, [System.Drawing.GraphicsUnit]::Pixel)
    } else {
    # Ảnh cao hơn khổ cần: cắt giữa theo chiều dọc
    $hNguon = $H * $src.Width / $W
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $W, $H)), 0, [single](($src.Height - $hNguon) / 2), $src.Width, [single]$hNguon, [System.Drawing.GraphicsUnit]::Pixel)
    }
} else {
    # Ảnh thấp hơn khổ cần: đặt sát đáy, phần trên lấp bằng bản làm mờ của dải trên cùng ảnh,
    # hoà dần vào ảnh trong $chong px để không lộ đường nối
    $them = $H - $hAnh; $chong = [int][Math]::Min(160, $hAnh / 4)
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, $them, $W, $hAnh)))
    $lat = New-Object System.Drawing.Imaging.ImageAttributes
    $lat.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
    $nho = New-Object System.Drawing.Bitmap(32, 8)
    $gn = [System.Drawing.Graphics]::FromImage($nho)
    $gn.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBilinear
    $gn.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, 32, 8)), 0, 0, $src.Width, [single]($chong * $src.Width / $W), [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $gn.Dispose()
    $mo = New-Object System.Drawing.Bitmap($W, ($them + $chong))
    $gm = [System.Drawing.Graphics]::FromImage($mo)
    $gm.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gm.DrawImage($nho, (New-Object System.Drawing.Rectangle(0, 0, $W, ($them + $chong))), 0, 0, 32, 8, [System.Drawing.GraphicsUnit]::Pixel, $lat)
    $gm.Dispose(); $nho.Dispose()
    $g.DrawImage($mo, (New-Object System.Drawing.Rectangle(0, 0, $W, $them)), 0, 0, $W, $them, [System.Drawing.GraphicsUnit]::Pixel)
    $buoc = 4
    for ($i = 0; $i -lt $chong; $i += $buoc) {
        $cm = New-Object System.Drawing.Imaging.ColorMatrix
        $cm.Matrix33 = [single](1 - ($i + $buoc / 2) / $chong)
        $ia = New-Object System.Drawing.Imaging.ImageAttributes
        $ia.SetColorMatrix($cm)
        $g.DrawImage($mo, (New-Object System.Drawing.Rectangle(0, ($them + $i), $W, $buoc)), 0, ($them + $i), $W, $buoc, [System.Drawing.GraphicsUnit]::Pixel, $ia)
        $ia.Dispose()
    }
    $mo.Dispose()
}
$src.Dispose()
$doc916 = ($H / $W) -gt 1.5
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
# Vùng chữ: khổ dọc, vuông — giữa ảnh, lề 10%; khổ ngang — cột trái rộng 46%, canh trái
if ($ngang) {
    $le = [int]($W * 0.06); $rongChu = [single]($W * 0.46)
    $canh = New-Object System.Drawing.StringFormat
    $canh.Alignment = [System.Drawing.StringAlignment]::Near
} else {
    $le = [int]($W * 0.10); $rongChu = [single]($W - 2 * $le)
    $canh = New-Object System.Drawing.StringFormat
    $canh.Alignment = [System.Drawing.StringAlignment]::Center
}
$giua = New-Object System.Drawing.StringFormat
$giua.Alignment = [System.Drawing.StringAlignment]::Center
$giua.LineAlignment = [System.Drawing.StringAlignment]::Center

# Đo trước tiêu đề, phụ đề (biết chữ xuống tới đâu để dải tối phủ đủ), vẽ sau dải tối
# Ảnh dọc 9x16: 14% trên bị ảnh đại diện, tên page che → tiêu đề bắt đầu từ 15%
$y = if ($doc916) { [single]($H * 0.15) } elseif ($ngang) { [single]($H * 0.12) } else { [single]($H * 0.10) }
$yTd = $y; $fTd = $null; $fPd = $null
if ($tieuDe) {
    # Khổ ngang: tiêu đề cao tối đa 45% ảnh, chừa chỗ cho phụ đề và hàng giá/nút
    $co = if ($ngang) { [single]($H * 0.105) } else { [single]($W * 0.085) }
    do {
        $fTd = New-Object System.Drawing.Font($fontDam, $co, $kieuDam, [System.Drawing.GraphicsUnit]::Pixel)
        $ktTd = $g.MeasureString($tieuDe, $fTd, 100000, $canh)
        if ($ktTd.Width -le $rongChu -and (-not $ngang -or $ktTd.Height -le $H * 0.45)) { break }
        $fTd.Dispose(); $co -= 2
    } while ($co -gt 14)
    $y += $ktTd.Height + $H * 0.005
    $coPhu = $co * 0.62
} else { $coPhu = if ($ngang) { [single]($H * 0.06) } else { [single]($W * 0.05) } }
$yPd = $y
if ($phuDe) {
    $fPd = New-Object System.Drawing.Font($fontVua, [single]$coPhu, $kieuVua, [System.Drawing.GraphicsUnit]::Pixel)
    $ktPd = $g.MeasureString($phuDe, $fPd, [int]$rongChu, $canh)   # dài quá bề rộng vùng chữ thì xuống dòng
    $y += $ktPd.Height
}

# Dải tối mờ sau chữ: khổ dọc ở phía trên, khổ ngang ở bên trái.
# "do_dam_nen" (0-255) trong JSON: dải đậm đặc phủ kín tới hết phụ đề rồi mới mờ dần — dùng cho ảnh nền
# sáng, nhiều hoa văn mà dải mờ mặc định không đủ làm nổi chữ (VD 220)
$doDam = Gia-Tri "do_dam_nen" ""
if ($tieuDe -or $phuDe) {
    if ($ngang) {
        $rongDai = [int]($W * 0.62)
        if ($doDam) {
            $kin = [int]($le + $rongChu + $W * 0.03); $rongDai = [int]($kin + $W * 0.14)
            $g.FillRectangle((New-Object System.Drawing.SolidBrush((Mau $hexToi ([int]$doDam)))), 0, 0, $kin, $H)
            $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(($kin - 1), 0, ($rongDai - $kin + 2), $H)), (Mau $hexToi ([int]$doDam)), (Mau $hexToi 0), 0)
            $g.FillRectangle($grad, $kin, 0, ($rongDai - $kin), $H); $grad.Dispose()
        } else {
            $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(-1, 0, ($rongDai + 2), $H)), (Mau $hexToi 190), (Mau $hexToi 0), 0)
            $g.FillRectangle($grad, 0, 0, $rongDai, $H); $grad.Dispose()
        }
    } elseif ($doDam) {
        $kin = [int]($y + $H * 0.025); $caoDai = [int]($kin + $H * 0.14)
        $g.FillRectangle((New-Object System.Drawing.SolidBrush((Mau $hexToi ([int]$doDam)))), 0, 0, $W, $kin)
        $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(0, ($kin - 1), $W, ($caoDai - $kin + 2))), (Mau $hexToi ([int]$doDam)), (Mau $hexToi 0), 90)
        $g.FillRectangle($grad, 0, $kin, $W, ($caoDai - $kin)); $grad.Dispose()
    } else {
        $caoDai = if ($doc916) { [int]($H * 0.45) } else { [int]($H * 0.40) }
        # vùng brush cao hơn vùng tô 2px: tránh GDI+ lặp màu đầu ở mép dưới (thành đường kẻ)
        $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(0, -1, $W, ($caoDai + 2))), (Mau $hexToi 175), (Mau $hexToi 0), 90)
        $g.FillRectangle($grad, 0, 0, $W, $caoDai); $grad.Dispose()
    }
}

if ($tieuDe) {
    $g.DrawString($tieuDe, $fTd, (New-Object System.Drawing.SolidBrush($mChu)), (New-Object System.Drawing.RectangleF($le, $yTd, $rongChu, $ktTd.Height)), $canh)
    $fTd.Dispose()
}
if ($phuDe) {
    $g.DrawString($phuDe, $fPd, (New-Object System.Drawing.SolidBrush($mNhan)), (New-Object System.Drawing.RectangleF($le, $yPd, $rongChu, ($ktPd.Height + 2))), $canh)
    $fPd.Dispose()
}

function Ve-Khung-Bo-Goc($x, $y, $w, $h, $r, $mau) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    $g.FillPath((New-Object System.Drawing.SolidBrush($mau)), $p); $p.Dispose()
}

$cao = if ($ngang) { [single]($H * 0.10) } else { [single]($W * 0.09) }
# Đo trước bề rộng huy hiệu giá + nút; không vừa trong vùng chữ thì thu nhỏ cả hàng
$khoangCach = if ($ngang) { $H * 0.03 } else { $W * 0.03 }
while ($gia -and $nut -and $cao -gt 30) {
    $f1 = New-Object System.Drawing.Font($fontVua, [single]($cao * 0.32), $kieuVua, [System.Drawing.GraphicsUnit]::Pixel)
    $f2 = New-Object System.Drawing.Font($fontDam, [single]($cao * 0.50), $kieuDam, [System.Drawing.GraphicsUnit]::Pixel)
    $f3 = New-Object System.Drawing.Font($fontDam, [single]($cao * 0.38), $kieuDam, [System.Drawing.GraphicsUnit]::Pixel)
    $rongGia = $(if ($giaNho) { $g.MeasureString($giaNho + " ", $f1).Width } else { 0 }) + $g.MeasureString($gia, $f2).Width + 2 * $cao * 0.30
    $rongNut = $g.MeasureString($nut, $f3).Width + $cao
    $f1.Dispose(); $f2.Dispose(); $f3.Dispose()
    if ($rongGia + $rongNut + $khoangCach -le $rongChu) { break }
    $cao -= 2
}
# Ảnh dọc 9x16: 20% dưới bị giao diện Story/Reels che, sản phẩm lại thường nằm thấp → hàng giá/nút
# đặt ngay dưới phụ đề, ở nửa trên ảnh. Khổ ngang: đáy ở 86%, trong cột chữ. Khổ khác: đáy ở 88%,
# vẫn trong vùng 80% ở giữa (Facebook có thể cắt mép tới 5%)
$day = if ($doc916) { [single][Math]::Min($y + $H * 0.03 + $cao, $H * 0.78) } elseif ($ngang) { [single]($H * 0.86) } else { [single]($H * 0.88) }
$y0 = $day - $cao
$bk = $cao * 0.22
$trai = New-Object System.Drawing.StringFormat
$trai.LineAlignment = [System.Drawing.StringAlignment]::Center
$xNut = $W - $le   # mép phải của nút (khổ ngang: tính lại ngay sau huy hiệu giá)

if ($gia) {
    $fGn = New-Object System.Drawing.Font($fontVua, [single]($cao * 0.32), $kieuVua, [System.Drawing.GraphicsUnit]::Pixel)
    $fG = New-Object System.Drawing.Font($fontDam, [single]($cao * 0.50), $kieuDam, [System.Drawing.GraphicsUnit]::Pixel)
    $wGn = if ($giaNho) { $g.MeasureString($giaNho + " ", $fGn).Width } else { 0 }
    $wG = $g.MeasureString($gia, $fG).Width
    $pad = $cao * 0.30
    Ve-Khung-Bo-Goc $le $y0 ($wGn + $wG + 2 * $pad) $cao $bk $mNhan
    $b = New-Object System.Drawing.SolidBrush($mChuNut)
    if ($giaNho) { $g.DrawString($giaNho, $fGn, $b, (New-Object System.Drawing.RectangleF(($le + $pad), $y0, $wGn, $cao)), $trai) }
    $g.DrawString($gia, $fG, $b, (New-Object System.Drawing.RectangleF(($le + $pad + $wGn), $y0, ($wG + 4), $cao)), $trai)
    $fGn.Dispose(); $fG.Dispose()
    $cuoiGia = $le + $wGn + $wG + 2 * $pad
} else { $cuoiGia = $le - $khoangCach }

if ($nut) {
    $fN = New-Object System.Drawing.Font($fontDam, [single]($cao * 0.38), $kieuDam, [System.Drawing.GraphicsUnit]::Pixel)
    $wN = $g.MeasureString($nut, $fN).Width + $cao
    $x1 = if ($ngang) { $cuoiGia + $khoangCach + $wN } else { $xNut }
    Ve-Khung-Bo-Goc ($x1 - $wN) $y0 $wN $cao $bk $mChu
    $g.DrawString($nut, $fN, (New-Object System.Drawing.SolidBrush($mChuNut)), (New-Object System.Drawing.RectangleF(($x1 - $wN), $y0, $wN, $cao)), $giua)
    $fN.Dispose()
}

$g.Dispose()
$RaFull = [IO.Path]::GetFullPath($Ra)
$bmp.Save($RaFull, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
Write-Output "OK font=$($fontDam.Name) / $($fontVua.Name) | ${W}x${H} | $RaFull"
