# Cai (hoac cap nhat) bo skill anh va video vao Claude tren Windows.
# Chay trong PowerShell:
#   irm https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.ps1 | iex
# Chay lai lenh tren bat cu luc nao de cap nhat ban moi nhat.

# Chay trong khoi rieng (& { }) de bien cua script khong de len bien cua phien PowerShell dang mo
& {
    $ErrorActionPreference = "Stop"
    $repo = "vietducltd/skill-anh-video"
    $dich = if ($env:SKILL_ANH_VIDEO_DICH) { $env:SKILL_ANH_VIDEO_DICH } else { Join-Path $env:USERPROFILE ".claude\skills" }

    $tam = Join-Path $env:TEMP ("skill-anh-video-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    New-Item -ItemType Directory -Path $tam | Out-Null
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "Dang tai bo skill tu github.com/$repo ..."
        $zip = Join-Path $tam "repo.zip"
        Invoke-WebRequest "https://github.com/$repo/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive $zip -DestinationPath $tam -Force
        $goc = Get-ChildItem $tam -Directory | Where-Object { Test-Path (Join-Path $_.FullName "skills") } | Select-Object -First 1
        if (-not $goc) { throw "Khong thay thu muc skills trong ban tai ve." }

        New-Item -ItemType Directory -Force -Path $dich | Out-Null
        $ds = @(Get-ChildItem (Join-Path $goc.FullName "skills") -Directory)
        foreach ($s in $ds) {
            $d = Join-Path $dich $s.Name
            New-Item -ItemType Directory -Force -Path $d | Out-Null
            Copy-Item (Join-Path $s.FullName "*") $d -Recurse -Force
            Write-Host "  + $($s.Name)"
        }
        Write-Host ""
        Write-Host "Da cai $($ds.Count) skill vao $dich"
        Write-Host "Mo phien Claude moi de dung. Go thu: 'lam anh quang cao', 'lam anh cho bai' hoac 'lam video cho bai'."
    } finally {
        Remove-Item $tam -Recurse -Force -ErrorAction SilentlyContinue
    }
}
