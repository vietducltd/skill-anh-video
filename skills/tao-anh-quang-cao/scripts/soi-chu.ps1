<#
tao-anh-quang-cao · Cắt và phóng to các vùng có chữ để soát chính tả / dấu tiếng Việt.

Cách dùng:
  powershell -ExecutionPolicy Bypass -File soi-chu.ps1 -Anh "A1-1x1.png"
  powershell -ExecutionPolicy Bypass -File soi-chu.ps1 -Anh "A1-1x1.png" -Vung "0,0,100,35;40,55,40,25"

-Vung: các vùng "x,y,rộng,cao" tính theo % ảnh, cách nhau bằng dấu ;. Mặc định 3 dải phủ cả ảnh:
trên (tiêu đề), giữa (chữ in trên bao bì — AI hay đổi chữ ở đây), dưới (giá, nút).
Mỗi vùng lưu thành <tên ảnh>.soi-N.png, rộng 1600px, cạnh ảnh gốc. Soát xong có thể xoá.
#>
param(
    [Parameter(Mandatory = $true)] [string]$Anh,
    [string]$Vung = "0,0,100,36;0,34,100,46;0,78,100,22"
)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$full = (Resolve-Path $Anh).Path
# GDI+ không đọc được WebP (ảnh tải từ ChatGPT, Gemini hay là WebP) → giải mã bằng WIC của Windows
try { $src = [System.Drawing.Image]::FromFile($full) }
catch {
    Add-Type -AssemblyName PresentationCore
    $fs = [IO.File]::OpenRead($full)
    try {
        $dec = [System.Windows.Media.Imaging.BitmapDecoder]::Create($fs, [System.Windows.Media.Imaging.BitmapCreateOptions]::None, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
        $enc = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
        $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($dec.Frames[0]))
        $ms = New-Object IO.MemoryStream; $enc.Save($ms); $ms.Position = 0
        $tam = [System.Drawing.Image]::FromStream($ms); $src = New-Object System.Drawing.Bitmap($tam); $tam.Dispose(); $ms.Dispose()
    } finally { $fs.Dispose() }
}
$i = 0
foreach ($v in ($Vung.Split(";") | Where-Object { $_.Trim() })) {
    $i++
    $p = $v.Split(",") | ForEach-Object { [double]$_ }
    $rect = New-Object System.Drawing.Rectangle([int]($src.Width * $p[0] / 100), [int]($src.Height * $p[1] / 100), [int]($src.Width * $p[2] / 100), [int]($src.Height * $p[3] / 100))
    $w = 1600; $h = [int]($rect.Height * $w / $rect.Width)
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $w, $h)), $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $out = [IO.Path]::ChangeExtension($full, ".soi-$i.png")
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
    Write-Output $out
}
$src.Dispose()
