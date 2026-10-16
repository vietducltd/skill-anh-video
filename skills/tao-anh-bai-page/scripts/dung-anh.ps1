<#
tao-anh-bai-page · Dựng ảnh chữ cho bài fanpage từ file nội dung ảnh (JSON), bằng trình duyệt
Edge/Chrome có sẵn trên máy (chạy ẩn). Không cần Python, không gọi API, không tốn phí.

Cách dùng (chạy trong thư mục dự án):
  Dựng ảnh cho mọi bài trong file nội dung:
    powershell -ExecutionPolicy Bypass -File dung-anh.ps1 -ThuMuc "<slug>"
  Chỉ dựng lại vài bài:
    powershell -ExecutionPolicy Bypass -File dung-anh.ps1 -ThuMuc "<slug>" -MaBai B003,B005
  Dựng xong ghi đường dẫn ảnh vào cột file_anh của lich-content.csv:
    ... -GhiCsv
  Tạo trang xem nhanh mọi ảnh (anh\xem-anh.html):
    ... -Xem
  Làm thêm bản khổ khác cho vài bài (VD bản Story 9x16), không đụng bản chính:
    ... -MaBai B003 -Kho 9x16

Khổ ảnh: "kho" trong thiet-ke.json (cả trang), ghi đè được bằng "kho" của từng bài, hoặc -Kho khi chạy:
  1x1  1080×1080 vuông · 4x5  1080×1350 dọc (mặc định) · 9x16  1080×1920 dọc dài (Story, chừa 14% trên,
  20% dưới cho giao diện) · 16x9  1920×1080 ngang · 1.91x1  1200×628 ngang dẹt (ảnh chia sẻ link)

Đọc:
  <ThuMuc>\anh\thiet-ke.json        bộ nhận diện: màu, logo, chân ảnh, chữ góc (tạo 1 lần)
  <ThuMuc>\anh\noi-dung-anh.json    chữ trên từng ảnh (Claude viết theo caption)
Ghi:
  <ThuMuc>\anh\<ma_bai>.png          bài 1 ảnh;  <ma_bai>-1.png, -2.png...  bài album
                                    khổ khác 4x5 thêm đuôi khổ: B001-1x1.png, B004-2-16x9.png
  <ThuMuc>\anh\html\                 file HTML gốc của từng ảnh (để sửa tay nếu cần)

Mỗi ảnh được kiểm tra tự động: chữ tràn khung (script tự thu nhỏ chữ tối đa 25% trước khi báo),
logo/ảnh nền không tải được, font chưa nạp. Vẫn phải MỞ XEM từng ảnh: script không thấy được
chữ mồ côi (1 chữ rớt xuống dòng riêng) hay câu ngắt xấu.
Chạy được trên Windows PowerShell 5.1 và PowerShell 7.
#>
param(
    [Parameter(Mandatory = $true)] [string]$ThuMuc,
    [string]$NoiDung = "",
    [string]$ThietKe = "",
    [string[]]$MaBai = @(),
    [switch]$GhiCsv,
    [switch]$Xem,
    [ValidateSet("", "1x1", "4x5", "9x16", "16x9", "1.91x1")] [string]$Kho = "",
    [string]$TrinhDuyet = ""
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Fail([string]$m) { Write-Output "LỖI: $m"; exit 1 }

# Gọi bằng -File thì "-MaBai B001,B002" tới dưới dạng một chuỗi — tách lại
$MaBai = @($MaBai | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$ThuMuc = (Resolve-Path $ThuMuc).Path
$AnhDir = Join-Path $ThuMuc "anh"
if (-not $NoiDung) { $NoiDung = Join-Path $AnhDir "noi-dung-anh.json" }
if (-not $ThietKe) { $ThietKe = Join-Path $AnhDir "thiet-ke.json" }
if (-not (Test-Path $ThietKe)) { Fail "chưa có $ThietKe — chốt bộ nhận diện trước (SKILL.md Bước 1)" }
$CsvPath = Join-Path $ThuMuc "lich-content.csv"
$SkillDir = Split-Path -Parent $PSScriptRoot
$FontDir = Join-Path $SkillDir "assets\fonts"

# ---------- trình duyệt ----------
function Find-TrinhDuyet {
    $ds = @()
    if ($TrinhDuyet) { $ds += $TrinhDuyet }
    $ds += @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    )
    foreach ($p in $ds) { if ($p -and (Test-Path $p)) { return $p } }
    return $null
}
$Browser = Find-TrinhDuyet
if (-not $Browser) { Fail "không thấy Chrome hoặc Edge. Cài Chrome, hoặc chỉ đường dẫn bằng -TrinhDuyet `"...\chrome.exe`"" }

function To-Uri([string]$p) { return ([Uri](Resolve-Path $p).Path).AbsoluteUri }

function Resolve-TuThuMuc([string]$p) {
    if (-not $p) { return $null }
    if ($p -match '^(https?|file):') { return $p }
    if ([IO.Path]::IsPathRooted($p)) { $full = $p } else { $full = Join-Path $ThuMuc $p }
    if (-not (Test-Path $full)) { return "THIEU:$p" }
    return (To-Uri $full)
}

# ---------- màu ----------
function Hex-Rgb([string]$h) {
    $h = $h.Trim().TrimStart('#')
    if ($h.Length -eq 3) { $h = ($h.ToCharArray() | ForEach-Object { "$_$_" }) -join '' }
    if ($h -notmatch '^[0-9a-fA-F]{6}$') { Fail "mã màu không hợp lệ: #$h" }
    return @([Convert]::ToInt32($h.Substring(0, 2), 16), [Convert]::ToInt32($h.Substring(2, 2), 16), [Convert]::ToInt32($h.Substring(4, 2), 16))
}
function Mix([string]$a, [string]$b, [double]$t) {
    $x = Hex-Rgb $a; $y = Hex-Rgb $b
    $r = 0..2 | ForEach-Object { [int][Math]::Round($x[$_] + ($y[$_] - $x[$_]) * $t) }
    return ('#{0:X2}{1:X2}{2:X2}' -f $r[0], $r[1], $r[2])
}
function Rgba([string]$h, [double]$a) { $c = Hex-Rgb $h; return "rgba($($c[0]),$($c[1]),$($c[2]),$a)" }

# ---------- đọc cấu hình ----------
function Read-Json([string]$f) {
    try { return (Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json) }
    catch { Fail "$f không đúng định dạng JSON ($($_.Exception.Message)). Đường dẫn trong JSON viết bằng dấu / (VD D:/thu-muc/logo.png)" }
}
$tk = Read-Json $ThietKe
function Get-Tk([string]$k, [string]$def) { $v = $tk.$k; if ([string]::IsNullOrWhiteSpace([string]$v)) { return $def } return [string]$v }
$C1 = Get-Tk "mau_chinh" "#2B3A55"
$C2 = Get-Tk "mau_phu" "#E8A33D"
$NEN = Get-Tk "mau_nen" (Mix $C2 "#FFFFFF" 0.9)
$CHU = Get-Tk "mau_chu" (Mix $C1 "#000000" 0.75)
$FONT = Get-Tk "font" "Be Vietnam Pro"
$FONT_TD = Get-Tk "font_tieu_de" $FONT   # font riêng cho tiêu đề, câu trích, con số (phong cách mac-dinh)
$TEN = Get-Tk "ten_thuong_hieu" ""
$CHU_GOC = Get-Tk "chu_goc" $TEN
$DONG1 = Get-Tk "chan_dong_1" ""
$DONG2 = Get-Tk "chan_dong_2" ""
$LOGO = Resolve-TuThuMuc (Get-Tk "logo" "")
if ($LOGO -like "THIEU:*") { Fail "không thấy file logo: $($LOGO.Substring(6)) (sửa 'logo' trong thiet-ke.json)" }
# Nhúng logo vào trang (data URI): logo dạng link file đôi khi chưa vẽ xong lúc chụp → mất nửa logo
if ($LOGO -like "file:*") {
    $lp = ([Uri]$LOGO).LocalPath
    $lm = @{ ".png" = "image/png"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"; ".webp" = "image/webp"; ".svg" = "image/svg+xml"; ".gif" = "image/gif" }[[IO.Path]::GetExtension($lp).ToLower()]
    if ($lm -and (Get-Item $lp).Length -lt 3MB) { $LOGO = "data:$lm;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($lp)) }
}

if (-not (Test-Path $NoiDung)) { Fail "chưa có $NoiDung — viết nội dung ảnh trước (SKILL.md Bước 2)" }
$nd = Read-Json $NoiDung
$dsBai = @($nd.bai)
if ($dsBai.Count -eq 0) { Fail "$NoiDung không có bài nào (cần mảng 'bai')" }

$lich = @{}
if (Test-Path $CsvPath) { foreach ($r in @(Import-Csv $CsvPath -Encoding UTF8)) { $lich[$r.ma_bai] = $r } }

# ---------- CSS ----------
$fontCss = ""
$ranges = [ordered]@{
    "vietnamese" = "U+0102-0103,U+0110-0111,U+0128-0129,U+0168-0169,U+01A0-01A1,U+01AF-01B0,U+0300-0301,U+0303-0304,U+0308-0309,U+0323,U+0329,U+1EA0-1EF9,U+20AB"
    "latin-ext"  = "U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF"
    "latin"      = "U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD"
}
if ($FONT -eq "Be Vietnam Pro" -or $FONT_TD -eq "Be Vietnam Pro") {
    foreach ($w in 500, 700, 800) {
        foreach ($sub in $ranges.Keys) {
            $f = Join-Path $FontDir "BeVietnamPro-$w-$sub.woff2"
            if (-not (Test-Path $f)) { Fail "thiếu font $f — cài lại skill" }
            $fontCss += "@font-face{font-family:`"Be Vietnam Pro`";font-weight:$w;font-display:block;src:url(`"$(To-Uri $f)`") format(`"woff2`");unicode-range:$($ranges[$sub])}`n"
        }
    }
}
# Font đi kèm cho các phong cách (đã cắt gọn còn chữ Latin + tiếng Việt; giấy phép OFL)
$fontKem = @(
    @("Noto Serif", 400, "normal", "NotoSerif-Regular"), @("Noto Serif", 700, "normal", "NotoSerif-Bold"),
    @("Noto Serif", 400, "italic", "NotoSerif-Italic"), @("Noto Serif", 700, "italic", "NotoSerif-BoldItalic"),
    @("Montserrat", 300, "normal", "Montserrat-Light"), @("Montserrat", 500, "normal", "Montserrat-Medium"),
    @("Montserrat", 800, "normal", "Montserrat-ExtraBold"), @("Montserrat", 900, "normal", "Montserrat-Black"),
    @("Patrick Hand", 400, "normal", "PatrickHand-Regular"), @("Anton", 400, "normal", "Anton-Regular")
)
foreach ($fk in $fontKem) {
    $f = Join-Path $FontDir "$($fk[3]).woff"
    if (Test-Path $f) { $fontCss += "@font-face{font-family:`"$($fk[0])`";font-weight:$($fk[1]);font-style:$($fk[2]);font-display:block;src:url(`"$(To-Uri $f)`") format(`"woff`")}`n" }
}
# Font biến thiên (một file cho mọi độ đậm), chọn qua "font" trong thiet-ke.json để hợp ngành:
# Playfair Display — chữ có chân thanh lịch; Nunito — chữ tròn mềm, thân thiện
foreach ($fb in @(@("Playfair Display", "PlayfairDisplay"), @("Nunito", "Nunito"))) {
    foreach ($sub in $ranges.Keys) {
        $f = Join-Path $FontDir "$($fb[1])-$sub.woff2"
        if (Test-Path $f) { $fontCss += "@font-face{font-family:`"$($fb[0])`";font-weight:400 900;font-display:block;src:url(`"$(To-Uri $f)`") format(`"woff2`");unicode-range:$($ranges[$sub])}`n" }
    }
}

# ---------- phong cách ----------
# Mỗi phong cách: font chính (để kiểm tra đã nạp) + đồ trang trí. "mac-dinh" dùng màu thương hiệu, nền sang/dam.
$PhongCach = [ordered]@{
    "mac-dinh"   = @{ font = $FONT; trangTri = '<div class="ring r1"></div><div class="ring r2"></div><div class="ring r3"></div>' }
    "tap-chi"    = @{ font = "Noto Serif"; trangTri = '' }
    "tuong-phan" = @{ font = "Anton"; trangTri = '<div class="soc s1"></div><div class="soc s2"></div>' }
    "so-tay"     = @{ font = "Patrick Hand"; trangTri = '<div class="lo l1"></div><div class="lo l2"></div><div class="lo l3"></div><div class="bang-dinh"></div>' }
    "bang-den"   = @{ font = "Patrick Hand"; trangTri = '<div class="ke"></div><div class="phan"></div>' }
    "toi-gian"   = @{ font = "Montserrat"; trangTri = '<div class="vach"></div>' }
    "pastel"     = @{ font = "Montserrat"; trangTri = '<div class="dom d1"></div><div class="dom d2"></div>' }
}
$PC_MD = Get-Tk "phong_cach" "mac-dinh"
# Khổ ảnh: kích thước dựng trang (rộng, cao) và kích thước ảnh ra. 1.91x1 dựng ở 1910×1000 cho đủ chỗ
# chữ rồi thu về 1200×628 (chuẩn ảnh chia sẻ link)
$KhoCo = [ordered]@{
    "1x1" = @(1080, 1080, 1080, 1080); "4x5" = @(1080, 1350, 1080, 1350); "9x16" = @(1080, 1920, 1080, 1920)
    "16x9" = @(1920, 1080, 1920, 1080); "1.91x1" = @(1910, 1000, 1200, 628)
}
$KHO_MD = Get-Tk "kho" "4x5"
if (-not $KhoCo.Contains($KHO_MD)) { Fail "kho '$KHO_MD' trong thiet-ke.json không có. Dùng: $($KhoCo.Keys -join ', ')" }
if (-not $PhongCach.Contains($PC_MD)) { Fail "phong_cach '$PC_MD' trong thiet-ke.json không có. Dùng: $($PhongCach.Keys -join ', ')" }

$D1 = Mix $C1 "#000000" 0.28
$D2 = Mix $C1 "#000000" 0.5
$cssTpl = @"
*{box-sizing:border-box;margin:0;padding:0}
html{--k:1}
html,body{width:var(--W);height:var(--H);overflow:hidden;background:#fff}
body{font-family:"$FONT","Segoe UI",Arial,sans-serif;-webkit-font-smoothing:antialiased}
.sang :is(.h1,.trich,.so,.bg),.dam :is(.h1,.trich,.so,.bg),.anhnen .h1{font-family:"$FONT_TD","$FONT","Segoe UI",Arial,sans-serif}
.page{position:relative;width:var(--W);height:var(--H);display:flex;flex-direction:column;overflow:hidden}
.sang{background:$NEN;color:$CHU;--acc:$C1;--em:$C1;--card:#FFFFFF;--line:$(Rgba $CHU 0.11);--mute:$(Mix $CHU '#FFFFFF' 0.3);--bb:$C1;--bi:#FFFFFF;--hl:$(Rgba $C2 0.42)}
.dam{background:linear-gradient(160deg,$C1 0%,$D1 52%,$D2 100%);color:#FBF8F1;--acc:$C2;--em:$C2;--card:rgba(255,255,255,.09);--line:rgba(255,255,255,.17);--mute:rgba(251,248,241,.8);--bb:$C2;--bi:$D2;--hl:transparent}
.anhnen{background:#111;color:#fff;--acc:$C2;--em:$C2;--card:rgba(0,0,0,.35);--line:rgba(255,255,255,.2);--mute:rgba(255,255,255,.85);--bb:$C2;--bi:$D2;--hl:transparent}
.bgimg{position:absolute;inset:0;width:100%;height:100%;object-fit:cover}
.shade{position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,.38) 0%,rgba(0,0,0,0) 20%,rgba(0,0,0,.05) 38%,rgba(0,0,0,.8) 80%)}
.anhnen .goc{color:#fff;text-shadow:0 1px 6px rgba(0,0,0,.6)}
.anhnen .body{justify-content:flex-end}
.ring{position:absolute;border-radius:50%;border:2px solid var(--line);pointer-events:none}
.r1{width:560px;height:560px;right:-210px;top:-230px}.r2{width:360px;height:360px;right:-110px;top:-130px}.r3{width:300px;height:300px;left:-150px;bottom:60px}
.top{position:relative;display:flex;justify-content:space-between;align-items:center;padding:60px 72px 0;gap:24px}
.chip{font-weight:800;font-size:25px;letter-spacing:.12em;text-transform:uppercase;color:var(--bi);background:var(--bb);padding:13px 26px;border-radius:999px;max-width:700px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.goc{font-weight:800;font-size:23px;letter-spacing:.22em;text-transform:uppercase;color:var(--mute);white-space:nowrap}
.body{position:relative;flex:1;display:flex;flex-direction:column;justify-content:center;padding:36px 72px 40px;gap:§34;overflow:hidden}
.kicker{font-weight:800;font-size:§28;letter-spacing:.1em;text-transform:uppercase;color:var(--acc)}
.h1{font-weight:800;font-size:§76;line-height:1.2;letter-spacing:-.012em}
.h1.lon{font-size:§88}.h1.vua{font-size:§62;line-height:1.22}
.h1 em,.t em,.lead em,.trich em,.bg em,.op em{font-style:normal;color:var(--em)}
.sang .h1 em,.sang .trich em{background:linear-gradient(transparent 66%,var(--hl) 66%)}
.lead{font-size:§38;line-height:1.42;font-weight:500;color:var(--mute)}
.nguon{font-size:§24;line-height:1.35;font-weight:500;color:var(--mute);opacity:.9}
.list{display:flex;flex-direction:column;gap:§18}
.it{display:flex;gap:§24;align-items:center;background:var(--card);border:1.5px solid var(--line);border-radius:26px;padding:§24 §30}
.n{flex:none;width:§64;height:§64;border-radius:50%;background:var(--bb);color:var(--bi);font-weight:800;font-size:§30;display:flex;align-items:center;justify-content:center}
.t{font-size:§37;font-weight:700;line-height:1.26}
.t small{display:block;font-size:§27;font-weight:500;color:var(--mute);margin-top:3px}
.bar{align-self:flex-start;background:var(--bb);color:var(--bi);font-weight:800;font-size:§31;line-height:1.3;padding:§18 §28;border-radius:18px}
.so{font-weight:800;font-size:§170;line-height:1;letter-spacing:-.02em;color:var(--acc)}
.so small{font-size:§60;letter-spacing:0;margin-left:8px}
.duo{display:flex;gap:22px}
.card{flex:1;background:var(--card);border:1.5px solid var(--line);border-radius:28px;padding:§30 §32}
.card.chon{border:3px solid var(--acc)}
.lb{font-size:§25;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--acc)}
.bg{font-size:§52;font-weight:800;line-height:1.18;margin:§10 0 §8}
.bg.gach{text-decoration:line-through;text-decoration-thickness:5px;color:var(--mute)}
.ds{font-size:§31;font-weight:500;line-height:1.36;color:var(--mute)}
.pairs{display:flex;flex-direction:column;border:1.5px solid var(--line);border-radius:26px;overflow:hidden;background:var(--card)}
.ph,.pr{display:grid;grid-template-columns:1fr 1fr}
.ph span{font-size:§25;font-weight:800;letter-spacing:.12em;text-transform:uppercase;color:var(--acc);padding:§20 §30}
.pr span{font-size:§36;font-weight:700;padding:§18 §30;border-top:1.5px solid var(--line)}
.ph span+span,.pr span+span{border-left:1.5px solid var(--line)}
.opt{display:flex;flex-direction:column;gap:§18}
.op{display:flex;gap:§24;align-items:center;background:var(--card);border:2.5px solid var(--acc);border-radius:26px;padding:§26 §30;font-size:§42;font-weight:800;line-height:1.22}
.op b{flex:none;width:§72;height:§72;border-radius:18px;background:var(--bb);color:var(--bi);display:flex;align-items:center;justify-content:center;font-size:§38}
.trich{font-size:§60;font-weight:800;line-height:1.28}
.trich:before{content:"\201C";display:block;font-size:§150;line-height:.6;color:var(--acc);margin-bottom:§10}
.ai{font-size:§30;font-weight:700;color:var(--mute)}
.foot{position:relative;height:150px;flex:none;background:#fff;display:flex;align-items:center;justify-content:space-between;gap:30px;padding:0 72px;color:#1E2622;border-top:1.5px solid rgba(20,38,31,.10)}
.foot img{max-height:110px;max-width:430px;object-fit:contain}
.wm{font-weight:800;font-size:40px;letter-spacing:.02em;color:$C1}
.who{text-align:right}
.who b{display:block;font-size:30px;font-weight:800}
.who span{font-size:23px;font-weight:500;color:#55645D}
.ring,.soc,.lo,.bang-dinh,.ke,.phan,.vach,.dom{pointer-events:none}

/* ===== tap-chi: trang báo, tạp chí — chữ có chân, kẻ đôi, đỏ gạch ===== */
.pc-tap-chi{background:#F3EDE2;color:#1C1A17;--acc:#9A2E1F;--em:#9A2E1F;--card:transparent;--line:rgba(28,26,23,.25);--mute:#4A443C;--bb:#1C1A17;--bi:#F3EDE2;--hl:transparent}
.pc-tap-chi .top{margin:0 72px;padding:58px 0 20px;border-bottom:5px double #1C1A17}
.pc-tap-chi .chip{background:none;color:#9A2E1F;padding:0;border-radius:0;font-family:"Noto Serif",serif;font-style:italic;font-weight:700;letter-spacing:.01em;text-transform:none;font-size:32px}
.pc-tap-chi .goc{font-family:"Noto Serif",serif;letter-spacing:.32em;color:#1C1A17;font-weight:700}
.pc-tap-chi .kicker{font-family:"Montserrat",sans-serif;font-weight:800;letter-spacing:.2em}
.pc-tap-chi .h1,.pc-tap-chi .so,.pc-tap-chi .t,.pc-tap-chi .bg,.pc-tap-chi .pr span,.pc-tap-chi .op,.pc-tap-chi .trich{font-family:"Noto Serif",serif;font-weight:700}
.pc-tap-chi .h1{letter-spacing:-.012em;line-height:1.2}
.pc-tap-chi .h1 em,.pc-tap-chi .trich em,.pc-tap-chi .t em{font-style:italic}
.pc-tap-chi .lead,.pc-tap-chi .ds,.pc-tap-chi .t small,.pc-tap-chi .ai,.pc-tap-chi .nguon{font-family:"Noto Serif",serif;font-style:italic;font-weight:400}
.pc-tap-chi .it{background:none;border:0;border-bottom:1.5px solid var(--line);border-radius:0;padding:§16 0}
.pc-tap-chi .n{background:none;color:#9A2E1F;font-family:"Noto Serif",serif;font-style:italic;font-weight:700;font-size:§56;border-radius:0}
.pc-tap-chi .so{color:#1C1A17}
.pc-tap-chi .so small{font-style:italic;color:#9A2E1F}
.pc-tap-chi .bar{background:none;color:#1C1A17;border-left:7px solid #9A2E1F;border-radius:0;font-family:"Noto Serif",serif;font-style:italic;font-weight:700;padding:§6 0 §6 §26}
.pc-tap-chi .card{border:0;border-top:4px solid #1C1A17;border-radius:0;padding:§22 0 0;background:none}
.pc-tap-chi .card.chon{border:0;border-top:9px solid #9A2E1F}
.pc-tap-chi .pairs{border:0;border-top:4px solid #1C1A17;border-bottom:4px solid #1C1A17;border-radius:0;background:none}
.pc-tap-chi .ph span{padding-left:0}.pc-tap-chi .pr span{padding-left:0}.pc-tap-chi .ph span+span,.pc-tap-chi .pr span+span{padding-left:§30}
.pc-tap-chi .op{border:2px solid #1C1A17;border-radius:0;background:none}
.pc-tap-chi .op b{border-radius:50%;background:#9A2E1F;color:#F3EDE2;font-family:"Noto Serif",serif;font-style:italic}
.pc-tap-chi .trich{font-style:italic}
.pc-tap-chi .trich:before{font-family:"Noto Serif",serif;font-style:normal}
.pc-tap-chi .foot{background:#F3EDE2;margin:0 72px;padding:0;border-top:2px solid #1C1A17}

/* ===== tuong-phan: đen – vàng, chữ đứng to, mạnh ===== */
.pc-tuong-phan{background:#0F0F0F;color:#FFFFFF;--acc:#FFD23F;--em:#FFD23F;--card:#1C1C1C;--line:rgba(255,255,255,.14);--mute:rgba(255,255,255,.8);--bb:#FFD23F;--bi:#0F0F0F;--hl:transparent}
.pc-tuong-phan .top *,.pc-tuong-phan .body *{font-family:"Montserrat",sans-serif}
.pc-tuong-phan .h1{font-family:"Anton",sans-serif !important;font-weight:400;text-transform:uppercase;line-height:1.3;letter-spacing:.006em;font-size:§94}
.pc-tuong-phan .h1.lon{font-size:§112}.pc-tuong-phan .h1.vua{font-size:§76;line-height:1.3}
.pc-tuong-phan .h1 *{font-family:"Anton",sans-serif !important;font-weight:400}
.pc-tuong-phan .h1 em{background:#FFD23F;color:#0F0F0F;padding:0 .12em;-webkit-box-decoration-break:clone;box-decoration-break:clone}
.pc-tuong-phan .so{font-family:"Anton",sans-serif !important;font-weight:400;font-size:§230;color:#FFD23F;line-height:1.05}
.pc-tuong-phan .so small{font-family:"Montserrat",sans-serif !important;font-weight:900;font-size:§54}
.pc-tuong-phan .kicker,.pc-tuong-phan .chip,.pc-tuong-phan .bar,.pc-tuong-phan .lb,.pc-tuong-phan .ph span{font-weight:900}
.pc-tuong-phan .chip{border-radius:0}
.pc-tuong-phan .it{border:0;border-left:9px solid #FFD23F;border-radius:0;background:#1B1B1B}
.pc-tuong-phan .n{border-radius:0;font-family:"Anton",sans-serif !important;font-weight:400}
.pc-tuong-phan .t{font-weight:800}
.pc-tuong-phan .bar{border-radius:0;text-transform:uppercase;letter-spacing:.02em}
.pc-tuong-phan .card,.pc-tuong-phan .pairs,.pc-tuong-phan .op{border-radius:0}
.pc-tuong-phan .op b{border-radius:0}
.pc-tuong-phan .bg,.pc-tuong-phan .trich{font-weight:900}
.pc-tuong-phan .soc{position:absolute;background:repeating-linear-gradient(-45deg,#FFD23F 0 22px,#0F0F0F 22px 44px)}
.pc-tuong-phan .s1{right:0;top:0;width:300px;height:30px}.pc-tuong-phan .s2{left:0;bottom:150px;width:100%;height:18px}
.pc-tuong-phan .body{padding-bottom:§58}

/* ===== so-tay: trang vở kẻ dòng, chữ viết tay, bút dạ quang ===== */
.pc-so-tay{background-color:#FFFDF5;background-image:linear-gradient(90deg,transparent 126px,rgba(214,69,69,.55) 126px,rgba(214,69,69,.55) 129px,transparent 129px),repeating-linear-gradient(180deg,transparent 0 56px,rgba(64,118,189,.2) 56px 58px);color:#22303E;--acc:#1F5FAF;--em:#C0392B;--card:#FFF3B0;--line:rgba(34,48,62,.16);--mute:#46586A;--bb:#1F5FAF;--bi:#fff;--hl:rgba(255,222,64,.8)}
.pc-so-tay .top *,.pc-so-tay .body *{font-family:"Patrick Hand",cursive;font-weight:400}
.pc-so-tay .top{padding:62px 72px 0 160px}.pc-so-tay .body{padding:30px 72px 40px 160px}
.pc-so-tay .chip{background:none;color:#C0392B;border:3px solid #C0392B;border-radius:12px;transform:rotate(-2deg);letter-spacing:.08em;font-size:30px}
.pc-so-tay .goc{letter-spacing:.14em;font-size:26px}
.pc-so-tay .kicker{letter-spacing:.06em;font-size:§34}
.pc-so-tay .h1{font-size:§96;line-height:1.14;letter-spacing:0}.pc-so-tay .h1.lon{font-size:§110}.pc-so-tay .h1.vua{font-size:§80;line-height:1.15}
.pc-so-tay .h1 em,.pc-so-tay .trich em,.pc-so-tay .t em{color:inherit;background:linear-gradient(transparent 52%,var(--hl) 52%,var(--hl) 92%,transparent 92%)}
.pc-so-tay .lead{font-size:§44;line-height:1.3}
.pc-so-tay .it{background:#FFF3B0;border:0;border-radius:3px;box-shadow:3px 4px 0 rgba(0,0,0,.07);transform:rotate(-.7deg)}
.pc-so-tay .it:nth-child(even){transform:rotate(.6deg);background:#DDF1FF}
.pc-so-tay .n{background:none;border:3px solid #1F5FAF;color:#1F5FAF;font-size:§36}
.pc-so-tay .t{font-size:§44;line-height:1.2}.pc-so-tay .t small{font-size:§32}
.pc-so-tay .so{color:#C0392B;font-size:§190}
.pc-so-tay .bar{background:none;color:#C0392B;border:3px solid #C0392B;border-radius:28px 8px 28px 8px;font-size:§38;transform:rotate(-1deg)}
.pc-so-tay .card{background:#FFF3B0;border:0;border-radius:3px;box-shadow:3px 4px 0 rgba(0,0,0,.07)}
.pc-so-tay .card.chon{outline:4px solid #C0392B;outline-offset:6px}
.pc-so-tay .bg{font-size:§58}.pc-so-tay .ds{font-size:§36}
.pc-so-tay .pairs{background:rgba(255,255,255,.6)}.pc-so-tay .pr span{font-size:§42}
.pc-so-tay .op{background:#fff;border:3px solid #1F5FAF;border-radius:14px;font-size:§48}
.pc-so-tay .trich{font-size:§72;line-height:1.18}
.pc-so-tay .lo{position:absolute;left:46px;width:34px;height:34px;border-radius:50%;background:#E9E4D6;box-shadow:inset 2px 2px 4px rgba(0,0,0,.18)}
.pc-so-tay .l1{top:190px}.pc-so-tay .l2{top:590px}.pc-so-tay .l3{top:990px}
.pc-so-tay .bang-dinh{position:absolute;top:20px;left:50%;width:230px;height:56px;margin-left:-115px;background:rgba(250,226,140,.75);transform:rotate(-3deg);box-shadow:0 1px 3px rgba(0,0,0,.12)}
.pc-so-tay .foot{background:#FFFDF5}

/* ===== bang-den: bảng đen lớp học, phấn trắng, khung gỗ ===== */
.pc-bang-den{background:radial-gradient(ellipse at 28% 22%,rgba(255,255,255,.08),transparent 58%),radial-gradient(ellipse at 78% 80%,rgba(255,255,255,.06),transparent 52%),#21382C;color:#F3F0E6;--acc:#F6D365;--em:#F6D365;--card:rgba(255,255,255,.05);--line:rgba(243,240,230,.4);--mute:rgba(243,240,230,.84);--bb:#F3F0E6;--bi:#21382C;--hl:transparent;box-shadow:inset 0 0 0 26px #6B4527,inset 0 0 0 31px #4B2F18}
.pc-bang-den .top *,.pc-bang-den .body *{font-family:"Patrick Hand",cursive;font-weight:400;text-shadow:0 0 1.5px rgba(255,255,255,.35)}
.pc-bang-den .top{padding:76px 90px 0}.pc-bang-den .body{padding:30px 90px 74px}
.pc-bang-den .chip{background:none;color:#F3F0E6;border:3px solid #F3F0E6;border-radius:14px;letter-spacing:.08em;font-size:30px}
.pc-bang-den .goc{letter-spacing:.16em;font-size:26px}
.pc-bang-den .kicker{letter-spacing:.06em;font-size:§34}
.pc-bang-den .h1{font-size:§96;line-height:1.14;letter-spacing:0}.pc-bang-den .h1.lon{font-size:§110}.pc-bang-den .h1.vua{font-size:§80;line-height:1.15}
.pc-bang-den .h1 em,.pc-bang-den .trich em{border-bottom:4px solid rgba(246,211,101,.75)}
.pc-bang-den .lead{font-size:§44;line-height:1.3}
.pc-bang-den .it{background:none;border:2.5px dashed rgba(243,240,230,.45);border-radius:16px}
.pc-bang-den .n{background:none;border:3px solid #F6D365;color:#F6D365;font-size:§36}
.pc-bang-den .t{font-size:§44;line-height:1.2}.pc-bang-den .t small{font-size:§32}
.pc-bang-den .so{font-size:§190;color:#F6D365}
.pc-bang-den .bar{background:none;color:#F6D365;border:3px solid #F6D365;border-radius:16px;font-size:§38}
.pc-bang-den .card,.pc-bang-den .pairs{border:2.5px dashed rgba(243,240,230,.45)}
.pc-bang-den .card.chon{border:3.5px solid #F6D365}
.pc-bang-den .bg{font-size:§58}.pc-bang-den .ds{font-size:§36}.pc-bang-den .pr span{font-size:§42}
.pc-bang-den .op{background:none;border:3px solid rgba(243,240,230,.6);font-size:§48}
.pc-bang-den .op b{background:none;border:3px solid #F6D365;color:#F6D365}
.pc-bang-den .trich{font-size:§72;line-height:1.18}
.pc-bang-den .ke{position:absolute;left:0;right:0;bottom:150px;height:30px;background:linear-gradient(180deg,#7A5030,#55361D)}
.pc-bang-den .phan{position:absolute;right:150px;bottom:166px;width:96px;height:18px;border-radius:6px;background:#F4F1EA;box-shadow:0 2px 2px rgba(0,0,0,.3);transform:rotate(-4deg)}

/* ===== toi-gian: trắng, nhiều khoảng thở, một vạch màu ===== */
.pc-toi-gian{background:#FFFFFF;color:#111111;--acc:$C1;--em:$C1;--card:#F4F4F2;--line:rgba(0,0,0,.12);--mute:#5C5C5C;--bb:#111111;--bi:#FFFFFF;--hl:transparent}
.pc-toi-gian .top *,.pc-toi-gian .body *{font-family:"Montserrat",sans-serif}
.pc-toi-gian .top{padding-top:70px}
.pc-toi-gian .chip{background:none;color:#111;padding:0;border-radius:0;letter-spacing:.24em;font-size:22px}
.pc-toi-gian .goc{color:#9A9A9A;font-weight:500;letter-spacing:.3em;font-size:20px}
.pc-toi-gian .kicker{color:#9A9A9A;font-weight:500;letter-spacing:.24em;font-size:§24}
.pc-toi-gian .h1{font-weight:800;letter-spacing:-.025em;line-height:1.16}
.pc-toi-gian .lead,.pc-toi-gian .ds,.pc-toi-gian .t small{font-weight:300}
.pc-toi-gian .it{background:none;border:0;border-top:1.5px solid #111;border-radius:0;padding:§22 0 §6}
.pc-toi-gian .n{background:none;color:$C1;width:auto;min-width:§56;justify-content:flex-start;border-radius:0;font-size:§34}
.pc-toi-gian .t{font-weight:500}
.pc-toi-gian .so{font-weight:300;color:#111;font-size:§210;letter-spacing:-.04em}
.pc-toi-gian .so small{font-weight:500;color:$C1}
.pc-toi-gian .bar{background:none;color:#111;border-radius:0;padding:0 0 §8;border-bottom:5px solid $C1;font-weight:800}
.pc-toi-gian .card{background:none;border:0;border-top:1.5px solid #111;border-radius:0;padding:§20 0 0}
.pc-toi-gian .card.chon{border-top:7px solid $C1}
.pc-toi-gian .pairs{border:0;border-radius:0;background:none;border-top:1.5px solid #111}
.pc-toi-gian .op{border:1.5px solid #111;border-radius:0;font-weight:500}
.pc-toi-gian .op b{border-radius:0}
.pc-toi-gian .trich{font-weight:500;letter-spacing:-.015em}
.pc-toi-gian .vach{position:absolute;left:72px;top:150px;width:110px;height:10px;background:$C1}
.pc-toi-gian .foot{margin:0 72px;padding:0;border-top:1.5px solid #111}

/* ===== pastel: hồng đào – tím nhạt, bo tròn, mềm ===== */
.pc-pastel{background:linear-gradient(160deg,#FFE8DA 0%,#FBE2EC 46%,#E5E3FF 100%);color:#33223F;--acc:#C2416B;--em:#C2416B;--card:rgba(255,255,255,.72);--line:rgba(51,34,63,.06);--mute:#5F4E6B;--bb:#33223F;--bi:#FFFFFF;--hl:rgba(194,65,107,.16)}
.pc-pastel .top *,.pc-pastel .body *{font-family:"Montserrat",sans-serif}
.pc-pastel .chip{background:#FFFFFF;color:#C2416B;box-shadow:0 6px 18px rgba(120,60,120,.1)}
.pc-pastel .h1{font-weight:900;letter-spacing:-.02em}
.pc-pastel .h1 em{background:linear-gradient(transparent 62%,var(--hl) 62%)}
.pc-pastel .lead,.pc-pastel .ds,.pc-pastel .t small{font-weight:500}
.pc-pastel .it,.pc-pastel .card,.pc-pastel .pairs,.pc-pastel .op{border:0;border-radius:36px;box-shadow:0 12px 32px rgba(120,60,120,.09)}
.pc-pastel .n,.pc-pastel .op b{background:linear-gradient(135deg,#F28CAB,#9F94FF);color:#fff}
.pc-pastel .so{font-weight:900;background:linear-gradient(135deg,#C2416B,#7B6CF0);-webkit-background-clip:text;background-clip:text;color:transparent}
.pc-pastel .so small{-webkit-text-fill-color:#5F4E6B;color:#5F4E6B}
.pc-pastel .bar{border-radius:999px;background:#33223F;padding:§18 §36}
.pc-pastel .dom{position:absolute;border-radius:50%}
.pc-pastel .d1{width:620px;height:620px;right:-220px;top:-200px;background:radial-gradient(circle,rgba(255,170,200,.55) 0,rgba(255,170,200,0) 68%)}
.pc-pastel .d2{width:560px;height:560px;left:-230px;bottom:40px;background:radial-gradient(circle,rgba(160,150,255,.45) 0,rgba(160,150,255,0) 68%)}

/* ===== khổ ảnh (4x5 là gốc) ===== */
/* 9x16 Story: 14% trên (ảnh đại diện, tên page) và 20% dưới (ô trả lời) bị giao diện che — chỉ để nền */
.k-9x16 .page{padding:270px 0 384px}
.k-9x16 .pc-bang-den .ke,.k-9x16 .pc-tuong-phan .s2{bottom:534px}
.k-9x16 .pc-bang-den .phan{bottom:550px}
/* chân ảnh thành thẻ bo góc, không cắt ngang ảnh thành hai mảng */
.k-9x16 .page:not(.pc-tap-chi):not(.pc-toi-gian) .foot{margin:0 48px;border-radius:24px}
/* ngang: chữ to hơn 30% (vẫn tự thu nhỏ nếu tràn), dòng không kéo quá dài, danh sách chia 2 cột */
html.k-ngang{--k:1.3}
.k-ngang .h1,.k-ngang .lead,.k-ngang .trich,.k-ngang .kicker,.k-ngang .nguon{max-width:1460px}
.k-ngang .list,.k-ngang .opt{display:grid;grid-template-columns:1fr 1fr;gap:§18 §26}
"@
$CSS = $fontCss + [regex]::Replace($cssTpl, '§(\d+)', 'calc(var(--k)*$1px)')

$JS = @"
<script>
(async()=>{const d=document.documentElement;
try{await document.fonts.ready}catch(e){}
const im=[...document.images];
await Promise.all(im.map(i=>i.complete?0:new Promise(r=>{i.onload=i.onerror=r})));
const lg=document.querySelector('.foot img');d.dataset.logo=lg?(lg.naturalWidth>0?'ok':'loi'):'khong';
const bg=document.querySelector('.bgimg');d.dataset.anh=bg?(bg.naturalWidth>0?'ok':'loi'):'khong';
const fc=d.dataset.fc||'';d.dataset.font=fc?([...document.fonts].some(f=>f.family.replace(/["']/g,'')===fc&&f.status==='loaded')?'ok':'loi'):'he-thong';
const b=document.querySelector('.body');const k0=parseFloat(getComputedStyle(d).getPropertyValue('--k'))||1;let k=k0;
const tran=()=>{const r0=b.getBoundingClientRect(),cs=getComputedStyle(b);
const R=r0.right-parseFloat(cs.paddingRight)+1,B=r0.bottom-parseFloat(cs.paddingBottom)+1;
if(b.scrollHeight>b.clientHeight+1)return true;
return [...b.querySelectorAll('*')].some(e=>{if(getComputedStyle(e).display==='inline')return false;const r=e.getBoundingClientRect();
return (r.width>0&&(r.right>R||r.bottom>B))||(e.clientWidth>0&&e.scrollWidth>e.clientWidth+1)})};
while(tran()&&k>k0*0.76){k=Math.round((k-0.03)*100)/100;d.style.setProperty('--k',k)}
d.dataset.co=String(Math.round(k/k0*100)/100);d.dataset.tran=tran()?'1':'0';
const mc=[];document.querySelectorAll('.h1,.lead,.t,.ds,.bg,.trich,.op span,.bar,.pr span,.kicker').forEach(el=>{
const sg=[[]];const tw=document.createTreeWalker(el,NodeFilter.SHOW_TEXT|NodeFilter.SHOW_ELEMENT);let n;
while(n=tw.nextNode()){if(n.nodeType===1){if(n.tagName==='BR'||n.tagName==='SMALL')sg.push([]);continue}
const re=/\S+/g;let m;while(m=re.exec(n.data)){sg[sg.length-1].push([n,m.index,m.index+m[0].length,m[0]])}}
const rr=x=>{const r=document.createRange();r.setStart(x[0],x[1]);r.setEnd(x[0],x[2]);const q=r.getClientRects();return q[q.length-1]};
sg.forEach(w=>{if(w.length<3)return;const a=rr(w[w.length-1]),p=rr(w[w.length-2]);
if(a&&p&&a.top>p.top+5){mc.push(w[w.length-2][3]+' '+w[w.length-1][3])}})});
d.dataset.mocoi=mc.join(' | ');d.dataset.xong='1';})();
</script>
"@

# ---------- dựng HTML ----------
function Esc([string]$s) {
    if ($null -eq $s) { return "" }
    $h = [System.Net.WebUtility]::HtmlEncode($s)
    $h = [regex]::Replace($h, '\*([^*]+)\*', '<em>$1</em>')
    return ($h -replace "`r?`n", "<br>")
}
function Has($o, [string]$k) {
    $v = $o.$k
    if ($null -eq $v) { return $false }
    if ($v -is [array]) { return $v.Count -gt 0 }
    return -not [string]::IsNullOrWhiteSpace([string]$v)
}

function Build-Body($p, [string]$nhanTrung = "") {
    $h = New-Object System.Text.StringBuilder
    $mau = [string]$p.mau
    # dòng kicker trùng chữ với nhãn tròn phía trên thì bỏ, khỏi lặp
    if ((Has $p "kicker") -and ([string]$p.kicker).Trim() -ne $nhanTrung.Trim()) { [void]$h.Append("<div class=`"kicker`">$(Esc $p.kicker)</div>") }
    switch ($mau) {
        "cau-chot" {
            $cl = "h1"; if ($p.co_chu -eq "lon") { $cl = "h1 lon" } elseif ($p.co_chu -eq "vua") { $cl = "h1 vua" }
            [void]$h.Append("<div class=`"$cl`">$(Esc $p.tieu_de)</div>")
            if (Has $p "phu") { [void]$h.Append("<div class=`"lead`">$(Esc $p.phu)</div>") }
        }
        "danh-sach" {
            if (Has $p "tieu_de") { [void]$h.Append("<div class=`"h1 vua`">$(Esc $p.tieu_de)</div>") }
            [void]$h.Append("<div class=`"list`">")
            $i = 0
            foreach ($m in @($p.muc)) {
                $i++
                if ($m -is [string]) { $t = $m; $s = "" } else { $t = [string]$m.t; $s = [string]$m.phu }
                if ($p.dau -eq "tick") { $nn = "&#10003;" } else { $nn = "$i" }
                $sm = ""; if ($s) { $sm = "<small>$(Esc $s)</small>" }
                [void]$h.Append("<div class=`"it`"><div class=`"n`">$nn</div><div class=`"t`">$(Esc $t)$sm</div></div>")
            }
            [void]$h.Append("</div>")
        }
        "con-so" {
            $don = ""; if (Has $p "don_vi") { $don = "<small>$(Esc $p.don_vi)</small>" }
            [void]$h.Append("<div class=`"so`">$(Esc $p.so)$don</div>")
            if (Has $p "tieu_de") { [void]$h.Append("<div class=`"h1 vua`">$(Esc $p.tieu_de)</div>") }
            if (Has $p "phu") { [void]$h.Append("<div class=`"lead`">$(Esc $p.phu)</div>") }
        }
        "so-sanh" {
            if (Has $p "tieu_de") { [void]$h.Append("<div class=`"h1 vua`">$(Esc $p.tieu_de)</div>") }
            [void]$h.Append("<div class=`"duo`">")
            foreach ($ben in "trai", "phai") {
                $c = $p.$ben; if ($null -eq $c) { continue }
                $cc = "card"; if ($p.chon -eq $ben) { $cc = "card chon" }
                $bc = "bg"; if ($p.gach -eq $ben) { $bc = "bg gach" }
                [void]$h.Append("<div class=`"$cc`"><div class=`"lb`">$(Esc $c.nhan)</div><div class=`"$bc`">$(Esc $c.lon)</div><div class=`"ds`">$(Esc $c.mo_ta)</div></div>")
            }
            [void]$h.Append("</div>")
        }
        "cap-doi" {
            if (Has $p "tieu_de") { [void]$h.Append("<div class=`"h1 vua`">$(Esc $p.tieu_de)</div>") }
            [void]$h.Append("<div class=`"pairs`">")
            $cot = @($p.cot)
            if ($cot.Count -eq 2) { [void]$h.Append("<div class=`"ph`"><span>$(Esc $cot[0])</span><span>$(Esc $cot[1])</span></div>") }
            foreach ($r in @($p.hang)) { $r = @($r); [void]$h.Append("<div class=`"pr`"><span>$(Esc $r[0])</span><span>$(Esc $r[1])</span></div>") }
            [void]$h.Append("</div>")
        }
        "cau-hoi" {
            [void]$h.Append("<div class=`"h1 vua`">$(Esc $p.tieu_de)</div><div class=`"opt`">")
            $chuCai = "ABCDEF"; $i = 0
            foreach ($o in @($p.lua_chon)) { [void]$h.Append("<div class=`"op`"><b>$($chuCai[$i])</b><span>$(Esc $o)</span></div>"); $i++ }
            [void]$h.Append("</div>")
        }
        "trich-dan" {
            [void]$h.Append("<div class=`"trich`">$(Esc $p.tieu_de)</div>")
            if (Has $p "ai") { [void]$h.Append("<div class=`"ai`">— $(Esc $p.ai)</div>") }
        }
        "anh-nen" {
            $cl = "h1"; if ($p.co_chu -eq "lon") { $cl = "h1 lon" } elseif ($p.co_chu -eq "vua") { $cl = "h1 vua" }
            [void]$h.Append("<div class=`"$cl`">$(Esc $p.tieu_de)</div>")
            if (Has $p "phu") { [void]$h.Append("<div class=`"lead`">$(Esc $p.phu)</div>") }
        }
        default { Fail "mẫu '$mau' không có. Dùng: cau-chot, danh-sach, con-so, so-sanh, cap-doi, cau-hoi, trich-dan, anh-nen" }
    }
    if (Has $p "ket") { [void]$h.Append("<div class=`"bar`">$(Esc $p.ket)</div>") }
    if (Has $p "nguon") { [void]$h.Append("<div class=`"nguon`">$(Esc $p.nguon)</div>") }
    return $h.ToString()
}

function Build-Html($p, [string]$nhan, [string]$goc, [string]$pc, [string]$khoAnh) {
    $nen = [string]$p.nen
    $bgHtml = ""
    $fc = [string]$PhongCach[$pc].font
    if ($p.mau -eq "anh-nen") {
        $src = Resolve-TuThuMuc ([string]$p.anh)
        if (-not $src) { Fail "mẫu anh-nen cần 'anh' (đường dẫn ảnh)" }
        if ($src -like "THIEU:*") { Fail "không thấy ảnh nền: $($src.Substring(6))" }
        # vi_tri_anh: phần ảnh giữ lại khi cắt cho vừa khung (CSS object-position), VD "top", "50% 30%"
        $viTri = ""; if ((Has $p "vi_tri_anh") -and ([string]$p.vi_tri_anh -match '^[a-z0-9%. -]+$')) { $viTri = " style=`"object-position:$($p.vi_tri_anh)`"" }
        $theme = "anhnen"; $bgHtml = "<img class=`"bgimg`" src=`"$src`"$viTri alt=`"`"><div class=`"shade`"></div>"
        $pc = "mac-dinh"; $fc = $FONT
    } elseif ($pc -ne "mac-dinh") { $theme = "pc-$pc" }
    elseif ($nen -eq "dam") { $theme = "dam" } else { $theme = "sang" }
    if ($fc -notin @("Be Vietnam Pro", "Noto Serif", "Montserrat", "Patrick Hand", "Anton", "Playfair Display", "Nunito")) { $fc = "" }   # font hệ thống: không kiểm
    $rings = ""; if ($theme -ne "anhnen") { $rings = [string]$PhongCach[$pc].trangTri }
    $chip = ""; if ($nhan) { $chip = "<span class=`"chip`">$(Esc $nhan)</span>" } else { $chip = "<span></span>" }
    if ($LOGO) { $left = "<img src=`"$LOGO`" alt=`"logo`">" } else { $left = "<div class=`"wm`">$(Esc $TEN)</div>" }
    $who = ""
    $kc = $KhoCo[$khoAnh]
    $lopKho = "k-" + ($khoAnh -replace '\.', ''); if ($kc[0] -gt $kc[1]) { $lopKho += " k-ngang" }
    $d1 = $DONG1; if (-not $LOGO -and $d1 -eq $TEN) { $d1 = "" }   # không có logo thì bên trái đã là tên thương hiệu
    if ($d1 -or $DONG2) { $who = "<div class=`"who`"><b>$(Esc $d1)</b><span>$(Esc $DONG2)</span></div>" }
    return @"
<!doctype html><html lang="vi" class="$lopKho" style="--W:$($kc[0])px;--H:$($kc[1])px" data-fc="$fc"><head><meta charset="utf-8"><style>$CSS</style></head><body>
<div class="page $theme">$bgHtml$rings
<div class="top">$chip<span class="goc">$(Esc $goc)</span></div>
<div class="body">$(Build-Body $p $nhan)</div>
<div class="foot">$left$who</div>
</div>$JS</body></html>
"@
}

$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("anh-bai-" + [Guid]::NewGuid().ToString("N").Substring(0, 8))
New-Item -ItemType Directory -Force $Tmp | Out-Null
function Invoke-Browser([string[]]$a) {
    $base = @("--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1", "--no-first-run",
        "--no-default-browser-check", "--user-data-dir=$Tmp", "--window-size=$script:CuaSo", "--virtual-time-budget=8000",
        "--allow-file-access-from-files", "--run-all-compositor-stages-before-draw")
    # Chờ tới khi trình duyệt đóng hẳn luồng ra (tiến trình chrome.exe đầu tiên thoát sớm, tiến trình con mới làm việc)
    $ds = @($base + $a) | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }
    $psi = New-Object System.Diagnostics.ProcessStartInfo $Browser
    $psi.Arguments = ($ds -join ' ')
    $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [Text.Encoding]::UTF8
    $pr = [System.Diagnostics.Process]::Start($psi)
    $er = $pr.StandardError.ReadToEndAsync()
    $ra = $pr.StandardOutput.ReadToEndAsync()
    if (-not $ra.Wait(120000)) { try { $pr.Kill() } catch {}; return "" }
    [void]$er.Wait(5000)
    return $ra.Result
}

# ---------- chạy ----------
New-Item -ItemType Directory -Force (Join-Path $AnhDir "html") | Out-Null
$ketQua = [ordered]@{}
$canhBao = 0
foreach ($bai in $dsBai) {
    $ma = [string]$bai.ma_bai
    if (-not $ma) { Fail "có bài thiếu 'ma_bai' trong $NoiDung" }
    if ($MaBai.Count -gt 0 -and $MaBai -notcontains $ma) { continue }
    $trang = @($bai)
    if ($null -ne $bai.trang) { $trang = @($bai.trang) }
    # Khổ: -Kho khi chạy > "kho" của bài > "kho" trong thiet-ke.json. Album: mọi trang cùng một khổ
    $khoBai = $KHO_MD
    if (Has $bai "kho") { $khoBai = [string]$bai.kho }
    if ($Kho) { $khoBai = $Kho }
    if (-not $KhoCo.Contains($khoBai)) { Fail "$ma`: kho '$khoBai' không có. Dùng: $($KhoCo.Keys -join ', ')" }
    $kc = $KhoCo[$khoBai]
    $script:CuaSo = "$($kc[0]),$($kc[1])"
    $duoi = ""; if ($khoBai -ne "4x5") { $duoi = "-$khoBai" }
    $nhanMacDinh = ""
    if (Has $bai "nhan") { $nhanMacDinh = [string]$bai.nhan } elseif ($lich.ContainsKey($ma)) { $nhanMacDinh = [string]$lich[$ma].tru_cot }
    $files = @()
    for ($i = 0; $i -lt $trang.Count; $i++) {
        $p = $trang[$i]
        $nhan = $nhanMacDinh; if (Has $p "nhan") { $nhan = [string]$p.nhan }
        $goc = $CHU_GOC
        if ($trang.Count -gt 1) { $tenAnh = "$ma-$($i + 1)$duoi"; $goc = "$($i + 1)/$($trang.Count)" } else { $tenAnh = "$ma$duoi" }
        $pc = $PC_MD
        if (Has $bai "phong_cach") { $pc = [string]$bai.phong_cach }
        if (Has $p "phong_cach") { $pc = [string]$p.phong_cach }
        if (-not $PhongCach.Contains($pc)) { Fail "$tenAnh`: phong_cach '$pc' không có. Dùng: $($PhongCach.Keys -join ', ')" }
        $html = Build-Html $p $nhan $goc $pc $khoBai
        $hp = Join-Path $AnhDir "html\$tenAnh.html"
        [IO.File]::WriteAllText($hp, $html, $Utf8)
        $png = Join-Path $AnhDir "$tenAnh.png"
        if (Test-Path $png) { Remove-Item $png -Force }
        $uri = To-Uri $hp
        $dom = Invoke-Browser @("--dump-dom", $uri)
        # Chụp tới khi 2 lần liên tiếp giống hệt nhau: trình duyệt chạy ẩn đôi khi chụp lúc trang chưa vẽ xong
        # (mất nửa logo, mảng màu lạ đè lên chân ảnh)
        $png2 = Join-Path $Tmp "$tenAnh-kiem.png"
        $truoc = ""; $onDinh = $false
        for ($lan = 1; $lan -le 4; $lan++) {
            if (Test-Path $png2) { Remove-Item $png2 -Force }
            [void](Invoke-Browser @("--screenshot=$png2", "--default-background-color=FFFFFFFF", $uri))
            if (-not (Test-Path $png2)) { continue }
            $bam = (Get-FileHash $png2 -Algorithm SHA256).Hash
            if ($bam -eq $truoc) { $onDinh = $true; Move-Item $png2 $png -Force; break }
            $truoc = $bam; Copy-Item $png2 $png -Force
        }
        # Khổ dựng lớn hơn khổ ra (1.91x1): thu ảnh về đúng kích thước chuẩn
        if ((Test-Path $png) -and ($kc[2] -ne $kc[0])) {
            Add-Type -AssemblyName System.Drawing
            $goc0 = [System.Drawing.Image]::FromFile($png)
            $nho = New-Object System.Drawing.Bitmap($kc[2], $kc[3])
            $gd = [System.Drawing.Graphics]::FromImage($nho)
            $gd.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $gd.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $gd.DrawImage($goc0, 0, 0, $kc[2], $kc[3]); $gd.Dispose(); $goc0.Dispose()
            $nho.Save($png, [System.Drawing.Imaging.ImageFormat]::Png); $nho.Dispose()
        }
        $loi = @()
        if (-not (Test-Path $png)) { $loi += "không tạo được ảnh" }
        elseif (-not $onDinh) { $loi += "ảnh chụp mỗi lần một khác — mở xem kỹ, chạy lại bài này" }
        $m = [regex]::Match($dom, '<html[^>]*>')
        $tag = $m.Value
        function Attr([string]$n) { $x = [regex]::Match($tag, "data-$n=`"([^`"]*)`""); if ($x.Success) { return $x.Groups[1].Value } return "" }
        if ((Attr "xong") -ne "1") { $loi += "chưa kiểm tra được (trình duyệt chưa chạy xong script)" }
        if ((Attr "tran") -eq "1") { $loi += "CHỮ TRÀN KHUNG dù đã thu nhỏ — bớt chữ" }
        if ((Attr "logo") -eq "loi") { $loi += "logo không tải được" }
        if ((Attr "anh") -eq "loi") { $loi += "ảnh nền không tải được" }
        if ((Attr "font") -eq "loi") { $loi += "font chưa nạp — chạy lại" }
        $mocoi = [System.Net.WebUtility]::HtmlDecode((Attr "mocoi"))
        if ($mocoi) { $loi += "chữ mồ côi (1 chữ rớt xuống dòng riêng) ở: `"$mocoi`" — chủ động xuống dòng trong JSON hoặc đổi chữ" }
        $co = Attr "co"
        $ghi = ""
        if ($co -and $co -ne "1") { $ghi = " (chữ đã thu nhỏ còn $([int]([double]$co * 100))%)" }
        if ($loi.Count -gt 0) { $canhBao++; Write-Output ("CẢNH BÁO {0}.png: {1}" -f $tenAnh, ($loi -join "; ")) }
        else { Write-Output ("OK  {0}.png  {1} KB{2}" -f $tenAnh, [int]((Get-Item $png).Length / 1024), $ghi) }
        $files += "anh/$tenAnh.png"
    }
    $ketQua[$ma] = $files
}
Remove-Item $Tmp -Recurse -Force -ErrorAction SilentlyContinue
if ($ketQua.Count -eq 0) { Fail "không có bài nào khớp -MaBai $($MaBai -join ',')" }
Write-Output ""
Write-Output "Đã dựng $(($ketQua.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum) ảnh cho $($ketQua.Count) bài; $canhBao ảnh có cảnh báo."

# ---------- ghi CSV ----------
if ($GhiCsv) {
    if (-not (Test-Path $CsvPath)) { Fail "không thấy $CsvPath" }
    $rows = @(Import-Csv $CsvPath -Encoding UTF8)
    $doi = 0
    foreach ($r in $rows) {
        if (-not $ketQua.Contains($r.ma_bai)) { continue }
        $moi = ($ketQua[$r.ma_bai] -join "|")
        $cu = [string]$r.file_anh
        if ($cu -and $cu -ne $moi -and $cu -notmatch '^anh/') {
            Write-Output "BỎ QUA $($r.ma_bai): file_anh đang là '$cu' (người dùng tự đặt) — không ghi đè"
            continue
        }
        if ($r.trang_thai -in @("da-len-lich", "da-dang")) {
            Write-Output "LƯU Ý $($r.ma_bai): bài đã $($r.trang_thai) — ảnh mới chưa lên page; muốn thay thì gỡ lịch đăng rồi hẹn lại"
        }
        $soFile = @($ketQua[$r.ma_bai]).Count
        if ($r.dinh_dang -eq "anh-don" -and $soFile -gt 1) {
            Write-Output "LƯU Ý $($r.ma_bai): lịch ghi anh-don nhưng có $soFile ảnh (album) — hỏi người duyệt đổi dinh_dang sang album, nếu không công cụ đăng bài có thể chặn"
        } elseif ($r.dinh_dang -eq "album" -and $soFile -eq 1) {
            Write-Output "LƯU Ý $($r.ma_bai): lịch ghi album nhưng chỉ có 1 ảnh"
        } elseif ($r.dinh_dang -in @("bai-chu", "video-ngan", "livestream")) {
            Write-Output "LƯU Ý $($r.ma_bai): lịch ghi $($r.dinh_dang) — ảnh chữ không hợp định dạng này, kiểm tra lại"
        }
        if ($cu -ne $moi) { $r.file_anh = $moi; $doi++ }
    }
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $rows | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding utf8BOM -UseQuotes Always
    } else {
        $rows | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    }
    Write-Output "CSV: cập nhật file_anh cho $doi bài ($CsvPath)"
}

# ---------- trang xem nhanh ----------
if ($Xem) {
    $the = New-Object System.Text.StringBuilder
    foreach ($ma in $ketQua.Keys) {
        $hook = ""; $tt = ""
        if ($lich.ContainsKey($ma)) { $hook = ([string]$lich[$ma].caption -split "`n")[0]; $tt = [string]$lich[$ma].trang_thai }
        foreach ($f in $ketQua[$ma]) {
            $tenAnh = [IO.Path]::GetFileName($f)
            [void]$the.Append("<figure><img src=`"$tenAnh`" loading=`"lazy`"><figcaption><b>$(Esc $ma)</b> · $(Esc $tenAnh) · $(Esc $tt)<br>$([System.Net.WebUtility]::HtmlEncode($hook))</figcaption></figure>")
        }
    }
    $trangXem = @"
<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Xem ảnh bài page</title>
<style>:root{--bg:#f6f5f1;--fg:#1d2320;--mu:#5d6662}@media(prefers-color-scheme:dark){:root{--bg:#16181a;--fg:#e8e8e6;--mu:#a3aaa6}}
body{margin:0;padding:24px 16px;background:var(--bg);color:var(--fg);font:15px/1.5 "Segoe UI",system-ui,sans-serif}
h1{font-size:20px;margin:0 0 16px}.g{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:18px}
figure{margin:0}img{width:100%;height:auto;border-radius:10px;box-shadow:0 1px 4px rgba(0,0,0,.18)}figcaption{color:var(--mu);font-size:13px;margin-top:6px}</style></head>
<body><h1>Ảnh bài page — $(Esc $TEN)</h1><div class="g">$($the.ToString())</div></body></html>
"@
    $xp = Join-Path $AnhDir "xem-anh.html"
    [IO.File]::WriteAllText($xp, $trangXem, $Utf8)
    Write-Output "Trang xem nhanh: $xp"
}
