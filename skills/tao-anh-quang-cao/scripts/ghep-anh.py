"""tao-anh-quang-cao · Làn D: tách sản phẩm khỏi ảnh chụp thật rồi ghép vào nền mới. Miễn phí, chạy trên máy.

Sản phẩm giữ nguyên từng điểm ảnh (bao bì, chữ in trên hộp đúng 100%), chỉ thêm bóng đổ và chỉnh nhẹ
độ sáng, tông màu cho khớp nền. Chữ quảng cáo chèn sau bằng chen-chu.ps1 (cùng -Kho).

Cần: Python 3.9+, pip install "rembg[cpu]" pillow numpy. Lần tách đầu tiên tự tải bộ nhận dạng
(khoảng 180 MB, cần mạng), các lần sau chạy không cần mạng.

1) Tách sản phẩm (ra PNG nền trong suốt, đã cắt sát viền):
   python ghep-anh.py tach "anh-goc/sp.jpg" --ra "tach/sp.png"
   --vung "x,y,rong,cao"   chỉ tách trong vùng này của ảnh (tính theo %), khi ảnh có nhiều thứ
   --mo-hinh               bộ nhận dạng: isnet-general-use (mặc định, nhanh) | birefnet-general-lite
                           (chậm hơn, thử khi viền sản phẩm bị lẹm)

2) Ghép vào nền:
   python ghep-anh.py ghep --sp "tach/sp.png" --nen "nen/ban-go.jpg" --kho 4x5 --ra "G1-4x5.png"
   --sp      1-3 ảnh sản phẩm, cách nhau bằng dấu ; (PNG đã tách; ảnh thường thì tự tách trước)
   --ti-le   chiều cao tương đối từng sản phẩm, VD "1,0.7" (mặc định đều 1)
   --nen     ảnh nền (jpg/png/webp), hoặc nền dựng sẵn:
               studio:#mau1,#mau2        phông trơn chuyển màu, sàn, đèn rọi sau sản phẩm
               studio:#mau1,#mau2,buc    thêm bục tròn dưới sản phẩm
   --kho     1x1 | 4x5 | 9x16 | 16x9 | 1.91x1 (kích thước chuẩn như chen-chu.ps1)
   Vị trí (tính theo phần của khung ảnh; bỏ trống = mặc định theo khổ, chừa chỗ cho chữ của chen-chu.ps1):
   --cao     chiều cao sản phẩm lớn nhất      --day   đường đáy sản phẩm (0 = mép trên, 1 = mép dưới)
   --x       tâm ngang cụm sản phẩm           --nen-tam "x,y" phần ảnh nền giữ lại khi cắt cho vừa khổ
   --san     ảnh mặt phẳng chụp từ trên xuống (mặt gỗ, đá, vải, giấy...): trải thành mặt bàn nhìn nghiêng
             dưới sản phẩm, phông --nen ở phía sau. Ảnh kho miễn phí loại này rất nhiều và dễ khớp góc chụp
   --san-vung "x,y,rong,cao" chỉ lấy vùng mặt phẳng sạch trong ảnh đó (theo %), bỏ đồ vật lẫn vào
   --san-sau chiều sâu mặt bàn sau sản phẩm (phần của chiều cao khung, mặc định 0.12)
   Hiệu ứng: --bong 0..1 (bóng đổ, mặc định 1) · --mo-nen <px> (làm mờ nền, mặc định 0)
             --hoa-mau 0..1 (kéo màu sản phẩm về tông nền, mặc định 0.12) · --phan-chieu 0..1 (bóng
             phản chiếu dưới sản phẩm, hợp nền bóng/bục, mặc định 0)

In ra: kích thước ảnh và khung sản phẩm (theo %), để soát chữ của chen-chu.ps1 có đè sản phẩm không.
"""
import argparse, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

KHO = {"1x1": (1080, 1080), "4x5": (1080, 1350), "9x16": (1080, 1920), "16x9": (1920, 1080), "1.91x1": (1200, 628)}
# Vị trí mặc định (cao, đáy, tâm x): chừa dải chữ phía trên (khổ dọc) hoặc nửa trái (khổ ngang) cho chen-chu.ps1;
# khổ dọc, vuông: đáy sản phẩm trên hàng giá/nút (78-88%); 9x16: đáy trên vùng giao diện Story che (20% dưới)
MAC_DINH = {"1x1": (0.42, 0.76, 0.5), "4x5": (0.40, 0.77, 0.5), "9x16": (0.32, 0.79, 0.5),
            "16x9": (0.70, 0.88, 0.73), "1.91x1": (0.72, 0.88, 0.73)}


def mo_anh(p):
    im = Image.open(p)
    return ImageOps.exif_transpose(im)


def tach(duong, ra=None, vung=None, mo_hinh="isnet-general-use", in_ra=True):
    try:
        from rembg import remove, new_session
    except ImportError:
        sys.exit('LỖI: chưa cài công cụ tách nền. Chạy: pip install "rembg[cpu]" pillow numpy')
    im = mo_anh(duong).convert("RGB")
    if vung:
        x, y, w, h = [float(v) / 100 for v in vung.split(",")]
        im = im.crop((int(x * im.width), int(y * im.height), int((x + w) * im.width), int((y + h) * im.height)))
    out = remove(im, session=new_session(mo_hinh))
    a = np.array(out.split()[-1])
    a[a < 12] = 0                      # bỏ vệt mờ lẻ tẻ quanh viền
    out.putalpha(Image.fromarray(a))
    bb = out.getbbox()
    if not bb:
        sys.exit("LỖI: không tìm thấy sản phẩm trong ảnh (ảnh trống hoặc vùng --vung sai)")
    out = out.crop(bb)
    if not ra:
        ra = os.path.splitext(duong)[0] + "-tach.png"
    os.makedirs(os.path.dirname(os.path.abspath(ra)), exist_ok=True)
    out.save(ra)
    phu = (a > 128).mean()
    if in_ra:
        print(f"OK tach | {out.width}x{out.height} | sản phẩm chiếm {phu:.0%} ảnh | {os.path.abspath(ra)}")
    return out


def lay_sp(duong, mo_hinh):
    im = mo_anh(duong)
    if im.mode == "RGBA" and np.array(im.split()[-1]).min() < 250:
        bb = im.getbbox()
        return im.crop(bb) if bb else im
    goc = os.path.splitext(duong)[0] + "-tach.png"
    if os.path.exists(goc):
        return Image.open(goc).convert("RGBA")
    return tach(duong, ra=goc, mo_hinh=mo_hinh, in_ra=False)


def hex_rgb(h):
    h = h.strip().lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def nen_studio(W, H, mau, day, x_tam, rong_sp, co_buc):
    c1, c2 = np.array(hex_rgb(mau[0]), float), np.array(hex_rgb(mau[1]), float)
    yy, xx = np.mgrid[0:H, 0:W].astype(float)
    t = yy / (H - 1)
    phong = c1 * (1 - t[..., None]) + c2 * t[..., None]
    # sàn: phía dưới đường chân trời tối hơn một chút, chuyển mềm
    chan = day * H - 0.06 * H
    san = np.clip((yy - chan) / (0.10 * H), 0, 1)[..., None]
    anh = phong * (1 - 0.18 * san)
    # đèn rọi sau sản phẩm (vầng sáng giúp sản phẩm tách khỏi phông, nhất là phông tối) + tối dần về các góc
    cx, cy = x_tam * W, (day - 0.25) * H
    r = np.hypot((xx - cx) / (0.42 * min(W, H)), (yy - cy) / (0.42 * min(W, H)))
    sang = np.clip(1 - r, 0, 1) ** 1.6
    anh = anh + (np.clip(c1 * 1.6 + 40, 0, 255) - anh) * (0.38 * sang)[..., None]
    rg = np.hypot((xx - W / 2) / W, (yy - H / 2) / H)
    anh = anh * (1 - 0.35 * np.clip(rg - 0.35, 0, 1)[..., None])
    nen = Image.fromarray(np.clip(anh, 0, 255).astype(np.uint8), "RGB")
    if co_buc:
        d = ImageDraw.Draw(nen, "RGBA")
        bw = rong_sp * 1.35; mat = day * H; bh = min(0.07 * H, max(8, (H - mat - bw * 0.09) * 0.7))
        mau_buc = tuple(int(v) for v in np.clip(c1 * 0.55 + c2 * 0.45 + 18, 0, 255))
        sam = tuple(int(v * 0.7) for v in mau_buc)
        x0, x1 = x_tam * W - bw / 2, x_tam * W + bw / 2
        d.rectangle((x0, mat, x1, mat + bh), fill=sam + (255,))
        d.ellipse((x0, mat + bh - bw * 0.09, x1, mat + bh + bw * 0.09), fill=sam + (255,))
        d.ellipse((x0, mat - bw * 0.09, x1, mat + bw * 0.09), fill=mau_buc + (255,))
    return nen


def nen_anh(duong, W, H, tam):
    im = mo_anh(duong).convert("RGB")
    tx, ty = tam
    s = max(W / im.width, H / im.height)
    im = im.resize((max(W, round(im.width * s)), max(H, round(im.height * s))), Image.LANCZOS)
    x = int((im.width - W) * tx); y = int((im.height - H) * ty)
    return im.crop((x, y, x + W, y + H))


def he_so_phoi_canh(dich, nguon):
    """Hệ số PERSPECTIVE của PIL: điểm ảnh ra (x, y) lấy màu từ ảnh vào theo 4 cặp góc dich -> nguon."""
    A, b = [], []
    for (x, y), (u, v) in zip(dich, nguon):
        A += [[x, y, 1, 0, 0, 0, -u * x, -u * y], [0, 0, 0, x, y, 1, -v * x, -v * y]]
        b += [u, v]
    return np.linalg.solve(np.array(A, float), np.array(b, float)).tolist()


def ve_san(nen, duong, y_chan, mo, vung=None):
    """Trải ảnh mặt phẳng chụp từ trên xuống (gỗ, đá, vải...) thành mặt bàn nhìn nghiêng từ chân trời
    y_chan tới mép dưới: xa thì thu nhỏ, mờ và tối dần; chân trời hoà mềm vào phông phía sau."""
    W, H = nen.size
    tex = mo_anh(duong).convert("RGB")
    if vung:                                   # chỉ lấy khoảng mặt phẳng sạch, không dính đồ vật
        x, y, w, h = [float(v) / 100 for v in vung.split(",")]
        tex = tex.crop((int(x * tex.width), int(y * tex.height), int((x + w) * tex.width), int((y + h) * tex.height)))
    tw, th = tex.size
    yc = int(y_chan)
    cao_san = H - yc
    # mép xa của mặt bàn lấy cả bề ngang ảnh mặt phẳng, mép gần chỉ lấy khúc giữa -> nhìn có chiều sâu
    he = he_so_phoi_canh([(0, 0), (W, 0), (W, cao_san), (0, cao_san)],
                         [(0, 0), (tw, 0), (tw * 0.72, th), (tw * 0.28, th)])
    san = tex.transform((W, cao_san), Image.PERSPECTIVE, he, Image.BICUBIC)
    mo_xa = san.filter(ImageFilter.GaussianBlur(max(2, mo if mo > 0 else 0.006 * H)))
    t = np.linspace(1, 0, cao_san)[:, None, None] ** 1.5          # 1 ở chân trời, 0 ở mép dưới
    s, m = np.array(san, float), np.array(mo_xa, float)
    s = s * (1 - t) + m * t
    s = s * (1 - 0.35 * t)                                          # xa thì tối hơn
    san = Image.fromarray(np.clip(s, 0, 255).astype(np.uint8))
    mat_na = Image.fromarray((np.clip(np.linspace(0, 1, cao_san) / 0.06, 0, 1)[:, None] * np.ones((1, W)) * 255).astype(np.uint8))
    nen.paste(san, (0, yc), mat_na)
    return nen


def chinh_mau(sp, nen_vung, muc):
    """Kéo nhẹ độ sáng và tông màu sản phẩm về phía nền (muc 0..1), giữ nguyên chi tiết bao bì."""
    if muc <= 0:
        return sp
    a = np.array(sp, float)
    rgb, al = a[..., :3], a[..., 3:] / 255
    m = al[..., 0] > 0.5
    if m.sum() < 50:
        return sp
    tb_sp = rgb[m].mean(0); tb_nen = np.array(nen_vung, float).reshape(-1, 3).mean(0)
    he_so = np.clip((tb_nen + 1) / (tb_sp + 1), 0.8, 1.25)        # theo từng kênh màu
    sang = np.clip(tb_nen.mean() / max(tb_sp.mean(), 1), 0.85, 1.15)
    he_so = he_so / he_so.mean() * sang
    rgb = rgb * (1 + (he_so - 1) * muc)
    return Image.fromarray(np.concatenate([np.clip(rgb, 0, 255), a[..., 3:]], -1).astype(np.uint8), "RGBA")


def vien_hoa_nen(sp, nen_mo, muc=0.3):
    """Pha một chút màu nền vào mép trong sản phẩm (light wrap) để viền không sắc như cắt dán."""
    a = sp.split()[-1]
    trong = a.filter(ImageFilter.MinFilter(5))
    mep = (np.array(a, float) - np.array(trong, float)) / 255
    mep = np.array(Image.fromarray((mep * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5)), float) / 255
    s = np.array(sp, float)
    n = np.array(nen_mo, float)
    s[..., :3] = s[..., :3] * (1 - muc * mep[..., None]) + n * (muc * mep[..., None])
    return Image.fromarray(np.clip(s, 0, 255).astype(np.uint8), "RGBA")


def ghep(a):
    W, H = KHO[a.kho]
    cao, day, x_tam = MAC_DINH[a.kho]
    cao = a.cao if a.cao is not None else cao
    day = a.day if a.day is not None else day
    x_tam = a.x if a.x is not None else x_tam
    co_buc = a.nen.lower().startswith("studio:") and a.nen.rstrip().lower().endswith(",buc")
    if co_buc and a.day is None:
        day -= 0.06 if W <= H else 0.10      # nâng sản phẩm lên cho bục không tràn mép dưới

    dsp = [p.strip() for p in a.sp.split(";") if p.strip()]
    if not 1 <= len(dsp) <= 3:
        sys.exit("LỖI: --sp cần 1 đến 3 ảnh sản phẩm")
    ti_le = [float(v) for v in a.ti_le.split(",")] if a.ti_le else [1.0] * len(dsp)
    ti_le = (ti_le + [ti_le[-1]] * 3)[:len(dsp)]
    sps = []
    for p, k in zip(dsp, ti_le):
        sp = lay_sp(p, a.mo_hinh).convert("RGBA")
        h = cao * H * k / max(ti_le)
        sp = sp.resize((max(1, round(sp.width * h / sp.height)), max(1, round(h))), Image.LANCZOS)
        sps.append(sp)
    # xếp cạnh nhau, chồng nhẹ 6%, cùng đường đáy
    chong = [int(0.06 * min(s.width for s in sps))] * (len(sps) - 1)
    tong = sum(s.width for s in sps) - sum(chong)
    if tong > 0.92 * W * (0.52 if W > H else 1):
        k = 0.92 * W * (0.52 if W > H else 1) / tong
        sps = [s.resize((max(1, round(s.width * k)), max(1, round(s.height * k))), Image.LANCZOS) for s in sps]
        chong = [int(c * k) for c in chong]; tong = int(tong * k)
    x0 = x_tam * W - tong / 2
    y_day = day * H

    if a.nen.lower().startswith("studio:"):
        phan = a.nen.split(":", 1)[1].split(",")
        if len(phan) < 2:
            sys.exit("LỖI: --nen studio cần 2 màu, VD studio:#2A2A2A,#0E0E0E")
        nen = nen_studio(W, H, phan[:2], day, x_tam, tong, len(phan) > 2 and phan[2].strip() == "buc")
    else:
        if not os.path.exists(a.nen):
            sys.exit(f"LỖI: không thấy ảnh nền {a.nen}")
        tam = [float(v) for v in a.nen_tam.split(",")] if a.nen_tam else [0.5, 0.5]
        nen = nen_anh(a.nen, W, H, tam)
        if a.mo_nen > 0:
            nen = nen.filter(ImageFilter.GaussianBlur(a.mo_nen))
    if a.san:
        if not os.path.exists(a.san):
            sys.exit(f"LỖI: không thấy ảnh mặt bàn {a.san}")
        nen = ve_san(nen.convert("RGB"), a.san, y_day - a.san_sau * H, a.mo_nen, a.san_vung)
    nen = nen.convert("RGBA")
    nen_mo = nen.convert("RGB").filter(ImageFilter.GaussianBlur(12))

    # 1) bóng: bóng tiếp đất (elip sẫm sát đáy) + bóng mềm phía sau (hình sản phẩm ép dẹt, làm mờ)
    bong = Image.new("L", (W, H), 0)
    vi_tri = []
    x = x0
    for i, s in enumerate(sps):
        vi_tri.append((int(x), int(y_day - s.height)))
        x += s.width - (chong[i] if i < len(chong) else 0)
    if a.bong > 0:
        d = ImageDraw.Draw(bong)
        for (px, py), s in zip(vi_tri, sps):
            rw, rh = s.width * 0.46, max(4, s.width * 0.045)
            d.ellipse((px + s.width / 2 - rw, y_day - rh, px + s.width / 2 + rw, y_day + rh), fill=int(200 * a.bong))
            dep = s.split()[-1].resize((s.width, max(1, int(s.height * 0.16))))
            bong.paste(Image.eval(dep, lambda v: int(v * 0.55 * a.bong)), (px + int(s.width * 0.06), int(y_day - dep.height * 0.55)), dep)
        bong = bong.filter(ImageFilter.GaussianBlur(max(3, 0.018 * H)))
        toi = Image.new("RGBA", (W, H), (0, 0, 0, 255))
        toi.putalpha(Image.eval(bong, lambda v: int(v * 0.75)))
        nen = Image.alpha_composite(nen, toi)

    # 2) phản chiếu (tuỳ chọn)
    if a.phan_chieu > 0:
        for (px, py), s in zip(vi_tri, sps):
            lat = ImageOps.flip(s)
            g = np.linspace(a.phan_chieu, 0, lat.height)[:, None]
            al = (np.array(lat.split()[-1], float) * g).astype(np.uint8)
            lat.putalpha(Image.fromarray(al))
            lop = Image.new("RGBA", (W, H), (0, 0, 0, 0)); lop.paste(lat, (px, int(y_day)), lat)
            nen = Image.alpha_composite(nen, lop.filter(ImageFilter.GaussianBlur(1.5)))

    # 3) sản phẩm: chỉnh màu theo nền, hoà viền, làm mềm mép 1 điểm ảnh
    for (px, py), s in zip(vi_tri, sps):
        hop = (max(0, px - s.width // 3), max(0, py - s.height // 4), min(W, px + s.width * 4 // 3), min(H, int(y_day) + s.height // 8))
        s = chinh_mau(s, nen.convert("RGB").crop(hop), a.hoa_mau)
        s = vien_hoa_nen(s, nen_mo.crop((px, py, px + s.width, py + s.height)).resize(s.size))
        s.putalpha(s.split()[-1].filter(ImageFilter.GaussianBlur(0.6)))
        lop = Image.new("RGBA", (W, H), (0, 0, 0, 0)); lop.paste(s, (px, py), s)
        nen = Image.alpha_composite(nen, lop)

    os.makedirs(os.path.dirname(os.path.abspath(a.ra)), exist_ok=True)
    nen.convert("RGB").save(a.ra)
    x1 = min(p[0] for p in vi_tri); x2 = max(p[0] + s.width for p, s in zip(vi_tri, sps))
    y1 = min(p[1] for p in vi_tri)
    print(f"OK ghep | {W}x{H} | sản phẩm: ngang {x1 / W:.0%}-{x2 / W:.0%}, dọc {y1 / H:.0%}-{y_day / H:.0%} | {os.path.abspath(a.ra)}")


def main():
    ap = argparse.ArgumentParser(description="Tách sản phẩm khỏi ảnh chụp và ghép vào nền mới")
    sub = ap.add_subparsers(dest="lenh", required=True)
    t = sub.add_parser("tach")
    t.add_argument("anh"); t.add_argument("--ra"); t.add_argument("--vung")
    t.add_argument("--mo-hinh", default="isnet-general-use")
    g = sub.add_parser("ghep")
    g.add_argument("--sp", required=True); g.add_argument("--ti-le")
    g.add_argument("--nen", required=True); g.add_argument("--nen-tam")
    g.add_argument("--san"); g.add_argument("--san-vung"); g.add_argument("--san-sau", type=float, default=0.12)
    g.add_argument("--kho", required=True, choices=list(KHO)); g.add_argument("--ra", required=True)
    g.add_argument("--cao", type=float); g.add_argument("--day", type=float); g.add_argument("--x", type=float)
    g.add_argument("--bong", type=float, default=1.0); g.add_argument("--mo-nen", type=float, default=0)
    g.add_argument("--hoa-mau", type=float, default=0.12); g.add_argument("--phan-chieu", type=float, default=0)
    g.add_argument("--mo-hinh", default="isnet-general-use")
    a = ap.parse_args()
    if a.lenh == "tach":
        tach(a.anh, a.ra, a.vung, a.mo_hinh)
    else:
        ghep(a)


if __name__ == "__main__":
    main()
