#!/usr/bin/env python3
"""
create-og-image.py — Generiši branded OG sliku (1200×630px)

Zahtijeva: pip3 install Pillow --break-system-packages

Koristi:
  python3 create-og-image.py \
    --name "Naziv Firme" \
    --tagline "Kratki opis usluge" \
    --city "Grad" \
    --domain "yourdomain.com" \
    --phone "+387 XX XXX XXX" \
    --logo "./html/images/logo.png" \
    --output "./html/images/og-image.jpg"

  ili s tagovima usluga:
    --tags "Usluga 1,Usluga 2,Usluga 3"
"""

import argparse
import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Greška: Pillow nije instaliran.")
    print("Instaliraj: pip3 install Pillow --break-system-packages")
    sys.exit(1)


def hex_to_rgb(hex_color: str) -> tuple:
    h = hex_color.lstrip('#')
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def create_og_image(
    name: str,
    tagline: str,
    city: str,
    domain: str,
    phone: str = "",
    logo_path: str = "",
    output_path: str = "./og-image.jpg",
    tags: list = None,
    bg_color: str = "#0b0f14",
    accent_color: str = "#5aabcc",
    quality: int = 92,
):
    W, H = 1200, 630
    BG     = hex_to_rgb(bg_color)
    ICE    = hex_to_rgb(accent_color)
    WHITE  = (255, 255, 255)

    img  = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img, "RGBA")

    # --- Dekorativni gradient (gornji lijevi kut) ---
    for i in range(280):
        alpha = int(35 * (1 - i / 280))
        draw.rectangle([0, 0, 280 - i, 280 - i], fill=(*ICE, alpha))

    # --- Dekorativni krugovi (desna strana) ---
    for r in range(220, 20, -20):
        alpha = max(0, int(18 * (1 - r / 220)))
        draw.ellipse(
            [W - r - 80, H // 2 - r, W - 80 + r, H // 2 + r],
            outline=(*ICE, alpha), width=1
        )

    # --- Logo ---
    logo_y = 60
    logo_h = 0
    if logo_path and os.path.exists(logo_path):
        try:
            logo = Image.open(logo_path).convert("RGBA")
            logo.thumbnail((160, 160), Image.LANCZOS)
            logo_h = logo.size[1]
            img.paste(logo, (72, logo_y), logo)
        except Exception as e:
            print(f"Upozorenje: Logo nije učitan — {e}")

    # --- Fonts ---
    def load_font(size):
        font_paths = [
            "/System/Library/Fonts/Helvetica.ttc",
            "/System/Library/Fonts/Arial.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        ]
        for fp in font_paths:
            if os.path.exists(fp):
                try:
                    return ImageFont.truetype(fp, size)
                except:
                    continue
        return ImageFont.load_default()

    font_name    = load_font(62)
    font_tagline = load_font(28)
    font_tag     = load_font(18)
    font_small   = load_font(22)

    # --- Naziv firme ---
    name_y = max(logo_y + logo_h + 20, 230)
    draw.text((72, name_y), name, font=font_name, fill=WHITE)

    # --- ICE accent linija ---
    line_y = name_y + 78
    draw.rectangle([72, line_y, 72 + 80, line_y + 4], fill=ICE)

    # --- Tagline ---
    tl_y = line_y + 22
    # Prelomi tagline na 2 linije ako je predugačak
    words = tagline.split()
    lines = []
    current = ""
    for w in words:
        test = f"{current} {w}".strip()
        bbox = draw.textbbox((0, 0), test, font=font_tagline)
        if bbox[2] - bbox[0] > 700 and current:
            lines.append(current)
            current = w
        else:
            current = test
    if current:
        lines.append(current)

    for i, line in enumerate(lines[:2]):
        draw.text((72, tl_y + i * 40), line, font=font_tagline, fill=(*WHITE, 185))

    # --- Tagovi usluga ---
    if tags:
        tx = 72
        ty = tl_y + len(lines[:2]) * 40 + 28
        pad_x, pad_y = 14, 7
        for tag in tags[:5]:
            bbox = draw.textbbox((0, 0), tag, font=font_tag)
            tw = bbox[2] - bbox[0]
            th = bbox[3] - bbox[1]
            bw = tw + pad_x * 2
            bh = th + pad_y * 2
            if tx + bw > W - 120:
                break
            draw.rounded_rectangle(
                [tx, ty, tx + bw, ty + bh],
                radius=6, outline=(*ICE, 120), width=1,
                fill=(*ICE, 18)
            )
            draw.text((tx + pad_x, ty + pad_y), tag, font=font_tag, fill=(*ICE,))
            tx += bw + 10

    # --- Grad (sredina-lijevo) ---
    city_y = H - 90
    draw.text((72, city_y), city, font=font_tagline, fill=(*ICE,))

    # --- Domena + telefon (donji desni) ---
    draw.text((W - 80, H - 75), domain, font=font_tagline, fill=(*ICE,), anchor="ra")
    if phone:
        draw.text((W - 80, H - 38), phone, font=font_small, fill=(*WHITE, 140), anchor="ra")

    # --- Desna vertikalna ICE linija ---
    draw.rectangle([W - 8, 0, W, H], fill=ICE)

    # --- Spremi ---
    output_dir = os.path.dirname(output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    img.save(output_path, "JPEG", quality=quality, optimize=True)
    size = os.path.getsize(output_path)
    print(f"✓ OG slika kreirana: {output_path} ({size / 1024:.0f}KB, {W}×{H}px)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generiši branded OG sliku")
    parser.add_argument("--name",    required=True,  help="Naziv firme")
    parser.add_argument("--tagline", required=True,  help="Tagline / opis usluge")
    parser.add_argument("--city",    default="",     help="Grad")
    parser.add_argument("--domain",  required=True,  help="Domena (npr. yourdomain.com)")
    parser.add_argument("--phone",   default="",     help="Telefon")
    parser.add_argument("--logo",    default="",     help="Putanja do logo PNG/WebP")
    parser.add_argument("--output",  default="./html/images/og-image.jpg", help="Output JPG putanja")
    parser.add_argument("--tags",    default="",     help="Tagovi usluga, odvojeni zarezom")
    parser.add_argument("--bg",      default="#0b0f14", help="Boja pozadine (hex)")
    parser.add_argument("--accent",  default="#5aabcc", help="Accent boja (hex)")
    parser.add_argument("--quality", default=92, type=int, help="JPG kvalitet 1-95")

    args = parser.parse_args()
    tags = [t.strip() for t in args.tags.split(",")] if args.tags else []

    create_og_image(
        name=args.name,
        tagline=args.tagline,
        city=args.city,
        domain=args.domain,
        phone=args.phone,
        logo_path=args.logo,
        output_path=args.output,
        tags=tags,
        bg_color=args.bg,
        accent_color=args.accent,
        quality=args.quality,
    )
