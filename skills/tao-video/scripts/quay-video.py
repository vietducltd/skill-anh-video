"""Quay một trang HTML hoạt hình (Canvas, SVG, CSS, GSAP, Three.js...) thành video MP4, từng khung một.

Trang chạy trong Chromium ẩn với đồng hồ ảo: mỗi khung, script đẩy đồng hồ đi đúng 1/fps giây rồi
chụp lại, nên video mượt và đúng thời gian dù cảnh 3D nặng hay máy chậm.

Cách dùng:
  python quay-video.py video.html --giay 20 --ra B007.mp4
  python quay-video.py video.html --giay 30 --rong 1080 --cao 1920 --fps 30 --nhac nhac.mp3 --ra B007.mp4

Tham số:
  --giay   độ dài video (giây)                --fps    khung/giây (mặc định 30)
  --rong, --cao  khổ (mặc định 1080x1920 dọc)  --nhac   file nhạc nền (mp3/wav), tự cắt vừa video, nhỏ dần cuối
  --cho    số giây chờ trang tải xong trước khi quay (mặc định 1.5)

Cần: Python 3.9+, playwright (pip install playwright; python -m playwright install chromium), ffmpeg.
Trang HTML phải TỰ CHẠY từ đầu đến cuối, không cần bấm chuột; tiếng Web Audio không thu được (dùng --nhac).
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

sys.stdout.reconfigure(encoding="utf-8")

# Đồng hồ ảo: thay performance.now, Date.now, requestAnimationFrame, setTimeout, setInterval
# và hoạt ảnh CSS / Web Animations bằng thời gian do script điều khiển.
DONG_HO_AO = r"""
(() => {
  const D0 = Date.now(); let t = 0, idRaf = 0, idHen = 0;
  const raf = new Map(), hen = new Map();
  performance.now = () => t;
  const _Date = Date;
  Date.now = () => D0 + t;
  window.requestAnimationFrame = cb => { raf.set(++idRaf, cb); return idRaf; };
  window.cancelAnimationFrame = id => raf.delete(id);
  window.setTimeout = (fn, ms = 0, ...a) => { hen.set(++idHen, { fn, luc: t + Math.max(0, +ms || 0), lap: 0, a }); return idHen; };
  window.setInterval = (fn, ms = 0, ...a) => { const k = Math.max(1, +ms || 1); hen.set(++idHen, { fn, luc: t + k, lap: k, a }); return idHen; };
  window.clearTimeout = window.clearInterval = id => hen.delete(id);
  window.__buoc = ms => {
    const dich = t + ms;
    for (;;) {                       // chạy các hẹn giờ tới hạn trong khoảng này, đúng thứ tự
      let id = null, h = null;
      for (const [k, v] of hen) if (v.luc <= dich && (!h || v.luc < h.luc)) { id = k; h = v; }
      if (!h) break;
      t = Math.max(t, h.luc);
      if (h.lap) h.luc += h.lap; else hen.delete(id);
      try { typeof h.fn === "function" ? h.fn(...h.a) : 0; } catch (e) { console.error(e); }
    }
    t = dich;
    const ds = [...raf.values()]; raf.clear();
    for (const cb of ds) { try { cb(t); } catch (e) { console.error(e); } }
    if (document.getAnimations) for (const an of document.getAnimations()) { try { an.pause(); an.currentTime = t; } catch (e) {} }
    return t;
  };
})();
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("html")
    ap.add_argument("--giay", type=float, required=True)
    ap.add_argument("--ra", required=True)
    ap.add_argument("--rong", type=int, default=1080)
    ap.add_argument("--cao", type=int, default=1920)
    ap.add_argument("--fps", type=int, default=30)
    ap.add_argument("--nhac", default="")
    ap.add_argument("--cho", type=float, default=1.5)
    a = ap.parse_args()

    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        sys.exit("LỖI: chưa có ffmpeg (Windows: winget install Gyan.FFmpeg, mở lại cửa sổ lệnh).")
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        sys.exit("LỖI: chưa có playwright (pip install playwright; python -m playwright install chromium).")

    html = os.path.abspath(a.html)
    if not os.path.exists(html):
        sys.exit(f"LỖI: không thấy {html}")
    so_khung = max(1, round(a.giay * a.fps))
    tam = tempfile.mkdtemp(prefix="quay-video-")
    loi_trang = []
    try:
        with sync_playwright() as p:
            tr = p.chromium.launch(args=["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--autoplay-policy=no-user-gesture-required"])
            pg = tr.new_page(viewport={"width": a.rong, "height": a.cao}, device_scale_factor=1)
            pg.on("pageerror", lambda e: loi_trang.append(str(e)))
            pg.add_init_script(DONG_HO_AO)
            pg.goto("file:///" + html.replace("\\", "/"), wait_until="load")
            pg.wait_for_timeout(int(a.cho * 1000))   # chờ thật cho font, ảnh, thư viện tải xong
            try:
                pg.evaluate("document.fonts && document.fonts.ready")
            except Exception:
                pass
            pg.evaluate("window.__buoc(0)")
            buoc = 1000.0 / a.fps
            for i in range(so_khung):
                pg.screenshot(path=os.path.join(tam, f"k{i:05d}.png"))
                pg.evaluate(f"window.__buoc({buoc})")
                if (i + 1) % (a.fps * 5) == 0:
                    print(f"  đã quay {(i + 1) / a.fps:.0f}/{a.giay:.0f} giây")
            tr.close()

        lenh = [ffmpeg, "-y", "-loglevel", "error", "-framerate", str(a.fps), "-i", os.path.join(tam, "k%05d.png")]
        if a.nhac:
            mo = max(0.0, a.giay - 1.5)
            lenh += ["-i", os.path.abspath(a.nhac), "-af", f"afade=t=out:st={mo}:d=1.5", "-shortest", "-c:a", "aac", "-b:a", "192k"]
        lenh += ["-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", "-movflags", "+faststart", os.path.abspath(a.ra)]
        subprocess.run(lenh, check=True)
    finally:
        shutil.rmtree(tam, ignore_errors=True)

    if loi_trang:
        print("CẢNH BÁO — trang báo lỗi JavaScript (xem lại video):")
        for e in loi_trang[:5]:
            print("  ", e[:200])
    print(f"OK {a.ra} | {a.rong}x{a.cao} | {a.giay:g} giây | {so_khung} khung")


if __name__ == "__main__":
    main()
