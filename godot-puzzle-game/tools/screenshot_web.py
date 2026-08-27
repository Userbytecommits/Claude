#!/usr/bin/env python3
"""Loads the exported Web build in the pre-installed Chromium and takes a
screenshot once Godot has actually finished booting, to visually confirm
the export runs (not just that it exported without errors)."""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=True,
        executable_path="/opt/pw-browsers/chromium-1194/chrome-linux/chrome",
        args=[
            "--enable-unsafe-swiftshader",
            "--use-gl=angle",
            "--use-angle=swiftshader",
            "--no-sandbox",
        ],
    )
    page = browser.new_page(viewport={"width": 540, "height": 960})
    page.goto("http://localhost:8791/index.html")
    # Give the ~38MB wasm binary real wall-clock time to fetch/compile/boot.
    page.wait_for_timeout(15000)
    page.screenshot(path="/tmp/game_booted.png")
    print("menu screenshot saved")

    canvas = page.locator("canvas")
    box = canvas.bounding_box()
    start_x = box["x"] + 269
    start_y = box["y"] + 531
    page.mouse.click(start_x, start_y)
    page.wait_for_timeout(2500)
    page.screenshot(path="/tmp/game_level.png")
    print("level screenshot saved")

    # Hold "right" (simulate keyboard) to walk into the level and confirm
    # the player/enemies/ground actually render while moving.
    page.keyboard.down("d")
    page.wait_for_timeout(2500)
    page.screenshot(path="/tmp/game_level_walking.png")
    page.keyboard.up("d")
    print("walking screenshot saved")

    browser.close()
