<#
tao-anh-quang-cao · Tạo 1 ảnh quảng cáo từ ảnh sản phẩm thật bằng OpenAI gpt-image-2.

Cách dùng:
  powershell -ExecutionPolicy Bypass -File tao-anh.ps1 -PromptFile "anh-quang-cao\prompt\A1-1x1.txt" -AnhSanPham "anh-goc\sp.jpg" -Kho 1x1 -Ra "anh-quang-cao\A1-1x1.png"
  Kiểm tra khoá API, không tạo ảnh (không tốn tiền):
  powershell -ExecutionPolicy Bypass -File tao-anh.ps1 -KiemTra

Tham số:
  -PromptFile   file .txt (UTF-8) chứa prompt tiếng Anh + chữ tiếng Việt cần in lên ảnh
  -AnhSanPham   1 hoặc nhiều ảnh sản phẩm thật (jpg/png/webp), nhiều ảnh cách nhau bằng dấu ;
                (VD "anh-goc\sp-1.jpg;anh-goc\sp-2.jpg"). Ảnh > 1024px tự thu nhỏ.
  -Kho          1x1 (1080×1080) | 4x5 (1080×1350) | 9x16 (1080×1920) | 16x9 (1920×1080)
                | 1.91x1 (1200×628, ảnh chia sẻ link; tạo ngang 16:9 rồi cắt bớt trên dưới). Mặc định 1x1
  -Ra           đường dẫn ảnh PNG đầu ra
  -RongXuat     chiều rộng ảnh cuối. Bỏ trống = kích thước chuẩn của khổ ở trên. 0 = giữ nguyên ảnh API
  -ChatLuong    auto | low | medium | high (mặc định auto)
  -Model        mặc định gpt-image-2

Khoá API đọc theo thứ tự: biến môi trường OPENAI_API_KEY → file %USERPROFILE%\.openai_api_key
→ file %USERPROFILE%\.product_shots_imagegen_api_key. Script không bao giờ in khoá ra màn hình.
Chạy được trên Windows PowerShell 5.1 và PowerShell 7.
#>
param(
    [string]$PromptFile = "",
    [string]$AnhSanPham = "",
    [ValidateSet("1x1", "4x5", "9x16", "16x9", "1.91x1")] [string]$Kho = "1x1",
    [string]$Ra = "",
    [int]$RongXuat = -1,
    [ValidateSet("auto", "low", "medium", "high")] [string]$ChatLuong = "auto",
    [string]$Model = "gpt-image-2",
    [switch]$KiemTra
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Net.Http
Add-Type -AssemblyName System.Drawing

function Lay-Khoa {
    if ($env:OPENAI_API_KEY) { return @($env:OPENAI_API_KEY.Trim(), "biến OPENAI_API_KEY") }
    foreach ($ten in ".openai_api_key", ".product_shots_imagegen_api_key") {
        $p = Join-Path $env:USERPROFILE $ten
        if (Test-Path $p) {
            $k = (Get-Content $p -Raw).Trim()
            if ($k) { return @($k, $p) }
        }
    }
    return @($null, $null)
}

$khoa, $nguonKhoa = Lay-Khoa
if (-not $khoa) {
    Write-Output "LOI: chua co khoa OpenAI. Tao file $env:USERPROFILE\.openai_api_key (1 dong, chi chua khoa) roi chay lai."
    exit 2
}
if ($KiemTra) {
    $http = New-Object System.Net.Http.HttpClient
    $http.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $khoa)
    $r = $http.GetAsync("https://api.openai.com/v1/models/$Model").Result
    $code = [int]$r.StatusCode
    if ($code -eq 200) { Write-Output "OK: khoa hop le ($nguonKhoa, bat dau bang $($khoa.Substring(0,8))...), model $Model dung duoc." ; exit 0 }
    Write-Output "LOI $code khi kiem tra khoa/model: $($r.Content.ReadAsStringAsync().Result.Substring(0, [Math]::Min(300, $r.Content.ReadAsStringAsync().Result.Length)))"
    exit 1
}

if (-not $PromptFile -or -not (Test-Path $PromptFile)) { throw "Thiếu -PromptFile hoặc file không tồn tại: $PromptFile" }
$dsAnh = @($AnhSanPham.Split(";") | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($dsAnh.Count -eq 0) { throw "Thiếu -AnhSanPham (ảnh sản phẩm thật)." }
if (-not $Ra) { $Ra = [IO.Path]::ChangeExtension($PromptFile, ".png") }

$kichThuoc = @{ "1x1" = "1024x1024"; "4x5" = "1024x1280"; "9x16" = "1024x1824"; "16x9" = "1824x1024"; "1.91x1" = "1824x1024" }[$Kho]
$chuan = @{ "1x1" = @(1080, 1080); "4x5" = @(1080, 1350); "9x16" = @(1080, 1920); "16x9" = @(1920, 1080); "1.91x1" = @(1200, 628) }[$Kho]
$prompt = [IO.File]::ReadAllText((Resolve-Path $PromptFile), [Text.Encoding]::UTF8).Trim()

# Ảnh tham chiếu: thu nhỏ về tối đa 1024px, lưu PNG tạm (tránh lỗi timeout và lỗi định dạng)
function Chuan-Bi-Anh-WPF([string]$full) {
    # Dự phòng cho webp/heic...: bộ giải mã ảnh của Windows 10/11
    Add-Type -AssemblyName PresentationCore
    $fs = [IO.File]::OpenRead($full)
    try {
        $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create($fs, [System.Windows.Media.Imaging.BitmapCreateOptions]::None, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        $frame = $dec.Frames[0]
    } finally { $fs.Dispose() }
    $scale = [Math]::Min(1.0, 1024.0 / [Math]::Max($frame.PixelWidth, $frame.PixelHeight))
    $src = New-Object System.Windows.Media.Imaging.TransformedBitmap($frame, (New-Object System.Windows.Media.ScaleTransform($scale, $scale)))
    $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
    $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($src))
    $tmp = Join-Path $env:TEMP ("anh_ref_" + [guid]::NewGuid().ToString("N") + ".png")
    $out = [IO.File]::Create($tmp); $enc.Save($out); $out.Dispose()
    return $tmp
}

function Chuan-Bi-Anh([string]$duong) {
    $full = (Resolve-Path $duong).Path
    try { $img = [System.Drawing.Image]::FromFile($full) }
    catch { return Chuan-Bi-Anh-WPF $full }
    try {
        $scale = [Math]::Min(1.0, 1024.0 / [Math]::Max($img.Width, $img.Height))
        $w = [int]($img.Width * $scale); $h = [int]($img.Height * $scale)
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($img, 0, 0, $w, $h); $g.Dispose()
        $tmp = Join-Path $env:TEMP ("anh_ref_" + [guid]::NewGuid().ToString("N") + ".png")
        $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
        return $tmp
    } finally { $img.Dispose() }
}

$form = New-Object System.Net.Http.MultipartFormDataContent
$form.Add((New-Object System.Net.Http.StringContent($Model)), "model")
$form.Add((New-Object System.Net.Http.StringContent($prompt, [Text.Encoding]::UTF8)), "prompt")
$form.Add((New-Object System.Net.Http.StringContent($kichThuoc)), "size")
$form.Add((New-Object System.Net.Http.StringContent("1")), "n")
if ($ChatLuong -ne "auto") { $form.Add((New-Object System.Net.Http.StringContent($ChatLuong)), "quality") }
$tamXoa = @()
foreach ($a in $dsAnh) {
    $tmp = Chuan-Bi-Anh $a; $tamXoa += $tmp
    $bytes = New-Object System.Net.Http.ByteArrayContent(, [IO.File]::ReadAllBytes($tmp))
    $bytes.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue("image/png")
    $form.Add($bytes, "image[]", [IO.Path]::GetFileName($tmp))
}

$http = New-Object System.Net.Http.HttpClient
$http.Timeout = [TimeSpan]::FromSeconds(300)
$http.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $khoa)

$dongHo = [Diagnostics.Stopwatch]::StartNew()
$ketQua = $null
for ($lan = 1; $lan -le 3; $lan++) {
    try {
        $resp = $http.PostAsync("https://api.openai.com/v1/images/edits", $form).Result
        $body = $resp.Content.ReadAsStringAsync().Result
        $code = [int]$resp.StatusCode
        if ($code -eq 200) { $ketQua = $body | ConvertFrom-Json; break }
        if ($code -eq 401 -or $code -eq 403 -or $code -eq 400) { throw "OpenAI báo lỗi $code`: $($body.Substring(0, [Math]::Min(500, $body.Length)))" }
        Write-Output "Lan $lan loi $code, thu lai..."
    } catch [System.AggregateException] {
        Write-Output "Lan $lan loi ket noi: $($_.Exception.InnerException.Message)"
    }
    Start-Sleep -Seconds ([Math]::Pow(4, $lan - 1))
}
$tamXoa | ForEach-Object { Remove-Item $_ -ErrorAction SilentlyContinue }
if (-not $ketQua) { throw "Không tạo được ảnh sau 3 lần thử." }

$raw = [Convert]::FromBase64String($ketQua.data[0].b64_json)
$thuMuc = Split-Path -Parent ([IO.Path]::GetFullPath($Ra))
if ($thuMuc -and -not (Test-Path $thuMuc)) { New-Item -ItemType Directory -Path $thuMuc | Out-Null }
$RaFull = [IO.Path]::GetFullPath($Ra)

if ($RongXuat -ne 0) {
    $ms = New-Object IO.MemoryStream(, $raw)
    $src = [System.Drawing.Image]::FromStream($ms)
    # Xuất đúng tỷ lệ khổ (VD 9x16: 1080x1920), cắt đều hai mép (trên/dưới hoặc trái/phải) nếu lệch
    $tyLe = $chuan[1] / $chuan[0]
    if ($RongXuat -gt 0) { $w = $RongXuat; $h = [int][Math]::Round($RongXuat * $tyLe) } else { $w = $chuan[0]; $h = $chuan[1] }
    if ($src.Height / $src.Width -gt $tyLe) {
        $caoNguon = [int][Math]::Round($src.Width * $tyLe)
        $vungNguon = New-Object System.Drawing.Rectangle(0, [int](($src.Height - $caoNguon) / 2), $src.Width, $caoNguon)
    } else {
        $rongNguon = [int][Math]::Round($src.Height / $tyLe)
        $vungNguon = New-Object System.Drawing.Rectangle([int](($src.Width - $rongNguon) / 2), 0, $rongNguon, $src.Height)
    }
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $w, $h)), $vungNguon, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose(); $src.Dispose(); $ms.Dispose()
    $bmp.Save($RaFull, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
} else {
    [IO.File]::WriteAllBytes($RaFull, $raw)
}

$token = if ($ketQua.usage) { $ketQua.usage.total_tokens } else { "?" }
Write-Output ("OK {0:N0}s | {1} | kho {2} | tokens={3} | {4}" -f $dongHo.Elapsed.TotalSeconds, $Model, $Kho, $token, $RaFull)
