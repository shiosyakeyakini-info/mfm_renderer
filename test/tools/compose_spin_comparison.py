#!/usr/bin/env python3
"""ブラウザ側とFlutter側の $[spin] のコマを1枚に並べる。

    # ブラウザ側
    chromium --headless --hide-scrollbars --force-device-scale-factor=2 \
      --window-size=800,520 --screenshot=/tmp/spin/browser.png \
      test/tools/spin_browser_reference.html

    # Flutter側
    SPIN_FRAME_DIR=/tmp/spin/frames \
      flutter test test/tools/generate_spin_comparison.dart

    python3 test/tools/compose_spin_comparison.py \
      /tmp/spin/browser.png /tmp/spin/frames [/tmp/spin/frames_fixed]

第3引数は任意。パッチを当てた状態で撮ったコマを渡すと3段目に並ぶ。
Pillowが要る (pip install pillow)。
"""

import sys
from PIL import Image, ImageDraw, ImageFont

FONT = "/usr/share/fonts/truetype/fonts-japanese-gothic.ttf"
CELL = 120
N = 8
LABEL = 300

VARIANTS = [
    r"$[spin.y ★]",
    r"$[spin.y,left ★]",
    r"$[spin.y $[spin.y,left ★]]",
    r"$[spin.y $[spin.y ★]]",
]

# spin_browser_reference.html を dpr=2 で撮ったときのセル中心。
BROWSER_X = [420, 568, 719, 870, 1019, 1168, 1319, 1470]
BROWSER_Y = [240, 384, 528, 672]


def main():
    browser_png, frame_dir = sys.argv[1], sys.argv[2]
    fixed_dir = sys.argv[3] if len(sys.argv) > 3 else None

    rows = [("ブラウザ(本家CSS)", None), ("miria(現状)", frame_dir)]
    if fixed_dir:
        rows.append(("miria(修正後)", fixed_dir))

    browser = Image.open(browser_png).convert("RGB")
    frames = {d: [Image.open(f"{d}/frame_{k}.png").convert("RGB")
                  for k in range(N)] for _, d in rows if d}

    f_small = ImageFont.truetype(FONT, 20)
    f_mid = ImageFont.truetype(FONT, 22)
    f_big = ImageFont.truetype(FONT, 23)

    head = 46
    block = 46 + CELL * len(rows) + 18
    out = Image.new("RGB", (LABEL + CELL * N + 20,
                            head + block * len(VARIANTS) + 10), (255, 255, 255))
    draw = ImageDraw.Draw(out)

    for k in range(N):
        draw.text((LABEL + CELL * k + CELL // 2, 16), f"{100 * k / N:g}%",
                  fill=(110, 110, 110), font=f_small, anchor="mm")

    for vi, title in enumerate(VARIANTS):
        top = head + block * vi
        draw.text((16, top + 6), title, fill=(20, 20, 20), font=f_big)
        for ri, (rname, src) in enumerate(rows):
            y = top + 46 + CELL * ri
            draw.text((LABEL - 16, y + CELL // 2), rname, fill=(90, 90, 90),
                      font=f_mid, anchor="rm")
            for k in range(N):
                if src is None:
                    cx, cy = BROWSER_X[k], BROWSER_Y[vi]
                    src_im = browser
                else:
                    src_im = frames[src][k]
                    cw = src_im.size[0] // len(VARIANTS)
                    cx, cy = cw * vi + cw // 2, src_im.size[1] // 2
                out.paste(src_im.crop((cx - CELL // 2, cy - CELL // 2,
                                       cx + CELL // 2, cy + CELL // 2)),
                          (LABEL + CELL * k, y))
            draw.line([(LABEL, y), (LABEL + CELL * N, y)], fill=(225, 225, 225))
        bottom = top + 46 + CELL * len(rows)
        draw.line([(LABEL, bottom), (LABEL + CELL * N, bottom)],
                  fill=(225, 225, 225))
        for k in range(N + 1):
            draw.line([(LABEL + CELL * k, top + 46), (LABEL + CELL * k, bottom)],
                      fill=(225, 225, 225))

    out.save("doc/assets/spin_nested_comparison.png")
    print("doc/assets/spin_nested_comparison.png", out.size)


if __name__ == "__main__":
    main()
