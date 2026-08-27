#!/usr/bin/env python3
"""Generates real pixel-art PNG assets for Puzzle Realm (Godot 4.7.2).
Style: chunky hollow-knight-esque silhouette characters on transparent bg,
hand-authored pixel grids upscaled with nearest-neighbor for crisp pixel look.
"""
import os
from PIL import Image, ImageDraw

BASE = os.path.join(os.path.dirname(__file__), "..", "assets", "sprites")
os.makedirs(BASE, exist_ok=True)

SCALE = 4  # each "pixel" in the grid becomes SCALE x SCALE real pixels

INK = (18, 16, 24, 255)          # near-black outline, hollow-knight style
WHITE = (235, 235, 245, 255)
CLOAK = (60, 55, 90, 255)
CLOAK_DK = (40, 36, 65, 255)
ACCENT = (120, 200, 255, 255)    # glowing blue accent (soul/dash)
RED = (210, 60, 70, 255)
RED_DK = (150, 35, 45, 255)
GREEN_ICE = (150, 220, 235, 255)
GOLD = (235, 190, 90, 255)
TRANSPARENT = (0, 0, 0, 0)


def px_image(grid, palette):
    """grid: list of strings, each char maps to palette color (or ' ' = transparent)."""
    h = len(grid)
    w = max(len(row) for row in grid)
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    for y, row in enumerate(grid):
        for x, ch in enumerate(row):
            if ch == ' ':
                continue
            img.putpixel((x, y), palette.get(ch, TRANSPARENT))
    return img.resize((w * SCALE, h * SCALE), Image.NEAREST)


def save(img, name):
    path = os.path.join(BASE, name)
    img.save(path)
    print("wrote", path, img.size)


# ---------------------------------------------------------------------------
# PLAYER — small hooded knight silhouette, 3 frames (idle, run1, run2) + jump
# 16x20 grid
# ---------------------------------------------------------------------------
PAL_PLAYER = {'.': INK, 'w': WHITE, 'c': CLOAK, 'd': CLOAK_DK, 'a': ACCENT}

player_idle = [
    "     .......    ",
    "    .wwwwwww.   ",
    "   .wwwwwwwww.  ",
    "   .ww.....ww.  ",
    "   .w.a...a.w.  ",
    "   .w.......w.  ",
    "    .wwwwwww.   ",
    "     .......    ",
    "    .ccccccc.   ",
    "   .cccccccccc. ",
    "   .cccccccccc. ",
    "   .cc.ccc.cc.  ",
    "   .cc.ccc.cc.  ",
    "   .cc.ccc.cc.  ",
    "   .dd. .dd.  ",
    "   .dd. .dd.  ",
    "   .dd. .dd.  ",
    "  ....   ....  ",
]

player_run1 = [
    "     .......    ",
    "    .wwwwwww.   ",
    "   .wwwwwwwww.  ",
    "   .ww.....ww.  ",
    "   .w.a...a.w.  ",
    "   .w.......w.  ",
    "    .wwwwwww.   ",
    "     .......    ",
    "   .ccccccc.    ",
    "  .cccccccccc.  ",
    "  .cccccccccc.  ",
    "   .cc.ccc.cc.  ",
    "  .cc.  .cc.    ",
    " .dd.    .dd.   ",
    ".dd.      .dd.  ",
    "dd.        .dd  ",
    "..          ..  ",
    "                ",
]

player_run2 = [
    "     .......    ",
    "    .wwwwwww.   ",
    "   .wwwwwwwww.  ",
    "   .ww.....ww.  ",
    "   .w.a...a.w.  ",
    "   .w.......w.  ",
    "    .wwwwwww.   ",
    "     .......    ",
    "    .ccccccc.   ",
    "   .cccccccccc. ",
    "   .cccccccccc. ",
    "  .cc.cc.cc.    ",
    "  .cc. .cc.     ",
    "  .dd.   .dd.   ",
    "  .dd.    .dd.  ",
    "  .dd.     .dd. ",
    "  ..        ..  ",
    "                ",
]

player_jump = [
    "     .......    ",
    "    .wwwwwww.   ",
    "   .wwwwwwwww.  ",
    "   .ww.....ww.  ",
    "   .w.a...a.w.  ",
    "   .w.......w.  ",
    "    .wwwwwww.   ",
    "     .......    ",
    "  .ccccccccccc. ",
    " .ccccccccccccc.",
    " .cc.ccccccc.cc.",
    ".cc.   .cc.   cc.",
    "dd.     dd.    dd",
    "                ",
    "                ",
    "                ",
    "                ",
    "                ",
]

save(px_image(player_idle, PAL_PLAYER), "player_idle.png")
save(px_image(player_run1, PAL_PLAYER), "player_run1.png")
save(px_image(player_run2, PAL_PLAYER), "player_run2.png")
save(px_image(player_jump, PAL_PLAYER), "player_jump.png")

# ---------------------------------------------------------------------------
# ENEMY: BLOB — round pulsing ooze, 2 frames
# ---------------------------------------------------------------------------
PAL_BLOB = {'.': INK, 'r': RED, 'd': RED_DK, 'w': WHITE}

blob1 = [
    "                ",
    "    ........    ",
    "   ..rrrrrr..   ",
    "  ..rrrrrrrr..  ",
    " ..rrrrrrrrrr.. ",
    " .rrrdrrrrdrr. ",
    " .rrrrrrrrrrr. ",
    " .rr.w..w.rrr. ",
    " .rr......rr. ",
    "  ..rrrrrrrr..  ",
    "   ..dddddd..   ",
    "    ........    ",
    "                ",
]

blob2 = [
    "                ",
    "                ",
    "     ......     ",
    "    .rrrrrr.    ",
    "   .rrrrrrrr.   ",
    "  ..rrrrrrrr..  ",
    "  .rrrdrrdrr.  ",
    "  .rrrrrrrrr.  ",
    "  .rr.w..w.rr.  ",
    "  .rr......rr.  ",
    "   .rrrrrrrr.   ",
    "    .dddddd.    ",
    "     ......     ",
]

save(px_image(blob1, PAL_BLOB), "enemy_blob1.png")
save(px_image(blob2, PAL_BLOB), "enemy_blob2.png")

# ---------------------------------------------------------------------------
# ENEMY: SPIKE — jagged crystalline hazard crawler
# ---------------------------------------------------------------------------
PAL_SPIKE = {'.': INK, 'r': RED, 'd': RED_DK, 'w': WHITE}

spike1 = [
    "       ..       ",
    "      .rr.      ",
    "     .rrrr.     ",
    "    .rrrrrr.    ",
    "  ...rrrrrr...  ",
    " .rrrrrrrrrrrr. ",
    ".rrrrrddddrrrrr.",
    ".rrrrrd..drrrrr.",
    ".rrrrrdw.wdrrrr.",
    " .rrrrdddd rrr. ",
    "  .rr.    .rr.  ",
    "  .dd.    .dd.  ",
    "  ..        ..  ",
]

save(px_image(spike1, PAL_SPIKE), "enemy_spike.png")

# ---------------------------------------------------------------------------
# ENEMY: FLYING — small winged wisp
# ---------------------------------------------------------------------------
PAL_FLY = {'.': INK, 'r': RED, 'd': RED_DK, 'w': WHITE, 'a': ACCENT}

fly1 = [
    "   ..     ..   ",
    "  .dd.   .dd.  ",
    " .drrd. .drrd. ",
    " .drrrd.drrrd. ",
    "  .rrrrrrrrr.  ",
    "   .rraarr.    ",
    "   .rr..rr.    ",
    "    .rrrr.     ",
    "     ....      ",
]

fly2 = [
    "                ",
    "  .dd.   .dd.  ",
    " .drrd. .drrd. ",
    " .drrrrrrrrrd. ",
    "  .rrrrrrrrr.  ",
    "   .rraarr.    ",
    "   .rr..rr.    ",
    "    .rrrr.     ",
    "     ....      ",
]

save(px_image(fly1, PAL_FLY), "enemy_fly1.png")
save(px_image(fly2, PAL_FLY), "enemy_fly2.png")

print("Sprite generation done.")
