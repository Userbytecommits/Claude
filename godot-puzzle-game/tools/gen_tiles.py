#!/usr/bin/env python3
"""Generates tile / environment / UI PNG assets."""
import os, random, math
from PIL import Image, ImageDraw

SPR = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
TIL = os.path.join(os.path.dirname(__file__), "..", "assets", "tiles")
UI = os.path.join(os.path.dirname(__file__), "..", "assets", "ui")
for d in (SPR, TIL, UI):
    os.makedirs(d, exist_ok=True)

random.seed(42)

STONE_DK = (35, 33, 46, 255)
STONE = (55, 52, 72, 255)
STONE_LT = (78, 74, 100, 255)
STONE_HI = (100, 96, 128, 255)
CRACK = (24, 22, 32, 255)


def save(img, folder, name):
    path = os.path.join(folder, name)
    img.save(path)
    print("wrote", path, img.size)


# --- Ground strip: 2160 x 96, tileable stone with brick pattern -----------
def make_ground(width=2160, height=96):
    img = Image.new("RGBA", (width, height), STONE_DK)
    draw = ImageDraw.Draw(img)
    # top surface highlight band
    draw.rectangle([0, 0, width, 10], fill=STONE_HI)
    draw.rectangle([0, 10, width, 16], fill=STONE_LT)

    brick_w, brick_h = 48, 24
    for row in range((height - 16) // brick_h + 1):
        y0 = 16 + row * brick_h
        offset = (brick_w // 2) if row % 2 else 0
        for col in range(-1, width // brick_w + 2):
            x0 = col * brick_w + offset
            shade = STONE if (row + col) % 2 == 0 else STONE_LT
            draw.rectangle([x0 + 1, y0 + 1, x0 + brick_w - 2, y0 + brick_h - 2], fill=shade)
            draw.rectangle([x0, y0, x0 + brick_w, y0 + brick_h], outline=CRACK)
    return img


save(make_ground(), TIL, "ground_strip.png")


def make_wall(width=64, height=2000):
    img = Image.new("RGBA", (width, height), STONE_DK)
    draw = ImageDraw.Draw(img)
    brick_h = 32
    for row in range(height // brick_h + 1):
        y0 = row * brick_h
        shade = STONE if row % 2 == 0 else STONE_LT
        draw.rectangle([2, y0 + 1, width - 2, y0 + brick_h - 2], fill=shade)
        draw.rectangle([0, y0, width, y0 + brick_h], outline=CRACK)
    return img


save(make_wall(), TIL, "wall_strip.png")

# --- Puzzle pressure tile: 64x64, glowing rune plate -----------------------
def make_puzzle_tile(active=False):
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    base = (45, 60, 90, 255) if not active else (60, 140, 210, 255)
    edge = (25, 35, 55, 255) if not active else (110, 200, 255, 255)
    draw.rounded_rectangle([4, 8, 60, 60], radius=6, fill=base, outline=edge, width=3)
    glow = (140, 210, 255, 255) if active else (80, 120, 160, 255)
    draw.ellipse([20, 22, 44, 46], outline=glow, width=3)
    draw.line([32, 26, 32, 42], fill=glow, width=2)
    draw.line([24, 34, 40, 34], fill=glow, width=2)
    return img


save(make_puzzle_tile(False), TIL, "puzzle_tile.png")
save(make_puzzle_tile(True), TIL, "puzzle_tile_active.png")

# --- Door: 64x128 stone archway that "opens" (top half fades) --------------
def make_door():
    img = Image.new("RGBA", (64, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([4, 4, 60, 124], fill=(50, 46, 66, 255), outline=(20, 18, 28, 255), width=3)
    for y in range(12, 120, 16):
        draw.rectangle([10, y, 54, y + 10], fill=(66, 60, 86, 255), outline=(30, 27, 40, 255))
    draw.ellipse([22, 16, 42, 36], outline=GOLD if False else (200, 165, 90, 255), width=3)
    return img


GOLD = (200, 165, 90, 255)
save(make_door(), TIL, "door.png")

# --- Spike hazard strip tile 64x64 -----------------------------------------
def make_spike_tile():
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 40, 64, 64], fill=STONE_DK, outline=CRACK)
    for x0 in (2, 24, 46):
        draw.polygon([(x0, 40), (x0 + 10, 8), (x0 + 20, 40)], fill=(150, 40, 50, 255), outline=(20, 10, 12, 255))
    return img


save(make_spike_tile(), TIL, "spike_hazard.png")

# --- Ice tile ---------------------------------------------------------------
def make_ice_tile():
    img = Image.new("RGBA", (64, 64), (170, 220, 235, 255))
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 64, 64], outline=(140, 200, 220, 255), width=2)
    for i in range(6):
        x = random.randint(4, 60)
        y = random.randint(4, 60)
        draw.line([x, y, x + random.randint(-10, 10), y + random.randint(-10, 10)],
                  fill=(210, 240, 250, 200), width=1)
    return img


save(make_ice_tile(), TIL, "ice_tile.png")

# --- Background parallax layers (simple gradient + silhouettes) ------------
def make_bg(width=1080, height=1920, top=(24, 20, 38), bottom=(10, 8, 16), hills=True):
    img = Image.new("RGB", (width, height), top)
    draw = ImageDraw.Draw(img)
    for y in range(height):
        t = y / height
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        draw.line([(0, y), (width, y)], fill=c)
    if hills:
        hill_color = (16, 13, 24)
        pts = [(0, height)]
        step = width // 10
        for i in range(0, width + step, step):
            pts.append((i, height - 200 - random.randint(0, 150)))
        pts.append((width, height))
        draw.polygon(pts, fill=hill_color)
    return img.convert("RGBA")


save(make_bg(), SPR, "background_far.png")
save(make_bg(top=(30, 24, 46), bottom=(14, 11, 20), hills=True), SPR, "background_near.png")

# --- UI icons: heart, coin/score star, puzzle piece -------------------------
def make_heart(filled=True):
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    color = (220, 60, 70, 255) if filled else (60, 55, 70, 255)
    draw.ellipse([2, 4, 16, 18], fill=color)
    draw.ellipse([14, 4, 28, 18], fill=color)
    draw.polygon([(2, 12), (28, 12), (15, 30)], fill=color)
    return img


save(make_heart(True), UI, "heart_full.png")
save(make_heart(False), UI, "heart_empty.png")


def make_star():
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy, r1, r2 = 16, 16, 14, 6
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        r = r1 if i % 2 == 0 else r2
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(pts, fill=(235, 195, 80, 255), outline=(150, 110, 30, 255))
    return img


save(make_star(), UI, "star.png")


def make_puzzle_icon():
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([4, 4, 28, 28], radius=4, fill=(90, 160, 220, 255), outline=(50, 90, 130, 255), width=2)
    draw.ellipse([12, 0, 20, 8], fill=(90, 160, 220, 255))
    return img


save(make_puzzle_icon(), UI, "puzzle_icon.png")


def make_app_icon():
    img = Image.new("RGBA", (192, 192), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, 192, 192], radius=36, fill=(30, 26, 46, 255))
    draw.ellipse([46, 30, 146, 130], fill=(235, 235, 245, 255))
    draw.polygon([(96, 40), (58, 96), (134, 96)], fill=(30, 26, 46, 255))
    draw.ellipse([76, 60, 92, 76], fill=(120, 200, 255, 255))
    draw.ellipse([100, 60, 116, 76], fill=(120, 200, 255, 255))
    draw.rounded_rectangle([56, 120, 136, 176], radius=10, fill=(60, 55, 90, 255))
    return img


icon = make_app_icon()
PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..")
save(icon, PROJECT_ROOT, "icon.png")

print("Tile/UI generation done.")
