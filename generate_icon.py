#!/usr/bin/env python3
"""Generate a 512x512 app icon for FocusBar - a macOS menu bar app."""

from PIL import Image, ImageDraw, ImageFont
import math

SIZE = 512
PADDING = 40  # padding inside the rounded rect

def create_gradient(draw, width, height):
    """Create a blue-to-purple diagonal gradient on the full canvas."""
    # Blue: (41, 98, 255), Purple: (147, 51, 234)
    for y in range(height):
        for x in range(width):
            # Diagonal gradient factor
            t = (x / width * 0.5 + y / height * 0.5)
            r = int(41 + (147 - 41) * t)
            g = int(98 + (51 - 98) * t)
            b = int(255 + (234 - 255) * t)
            draw.point((x, y), fill=(r, g, b))


def rounded_rect_mask(size, radius):
    """Create a rounded rectangle mask."""
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return mask


def main():
    # --- Create gradient background ---
    bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    grad = Image.new("RGB", (SIZE, SIZE))
    grad_draw = ImageDraw.Draw(grad)
    create_gradient(grad_draw, SIZE, SIZE)

    # Apply rounded rectangle mask (macOS-style corner radius ~22% of size)
    corner_radius = int(SIZE * 0.22)
    mask = rounded_rect_mask((SIZE, SIZE), corner_radius)
    bg.paste(grad, (0, 0), mask)

    draw = ImageDraw.Draw(bg)

    # --- Draw a subtle inner shadow / border highlight ---
    # Slightly lighter border on top-left, darker on bottom-right for depth
    draw.rounded_rectangle(
        [1, 1, SIZE - 2, SIZE - 2],
        radius=corner_radius,
        outline=(255, 255, 255, 40),
        width=2,
    )

    # --- Draw bar chart (3 bars representing usage/focus metrics) ---
    bar_area_left = 100
    bar_area_right = SIZE - 100
    bar_area_bottom = 370
    bar_area_top = 140
    bar_width = 70
    bar_gap = 25
    total_bar_width = 3 * bar_width + 2 * bar_gap
    bar_start_x = (SIZE - total_bar_width) // 2

    bar_heights_pct = [0.55, 1.0, 0.75]  # relative heights
    bar_colors = [
        (255, 255, 255, 220),
        (255, 255, 255, 255),
        (255, 255, 255, 220),
    ]

    max_bar_h = bar_area_bottom - bar_area_top

    for i, (h_pct, color) in enumerate(zip(bar_heights_pct, bar_colors)):
        x0 = bar_start_x + i * (bar_width + bar_gap)
        x1 = x0 + bar_width
        bar_h = int(max_bar_h * h_pct)
        y0 = bar_area_bottom - bar_h
        y1 = bar_area_bottom

        # Draw bar with rounded top corners
        bar_radius = 14
        draw.rounded_rectangle([x0, y0, x1, y1], radius=bar_radius, fill=color)

        # Add a small shine/highlight on each bar
        highlight = (255, 255, 255, 50)
        draw.rounded_rectangle(
            [x0 + 4, y0 + 4, x0 + bar_width // 3, y1 - 4],
            radius=8,
            fill=highlight,
        )

    # --- Draw a crosshair / focus circle above the tallest bar ---
    # This represents "focus" - a simple target/crosshair symbol
    center_x = bar_start_x + 1 * (bar_width + bar_gap) + bar_width // 2
    center_y = bar_area_top - 45
    outer_r = 30
    inner_r = 14
    dot_r = 5

    # Outer circle
    draw.ellipse(
        [center_x - outer_r, center_y - outer_r, center_x + outer_r, center_y + outer_r],
        outline=(255, 255, 255, 230),
        width=3,
    )
    # Inner circle
    draw.ellipse(
        [center_x - inner_r, center_y - inner_r, center_x + inner_r, center_y + inner_r],
        outline=(255, 255, 255, 230),
        width=2,
    )
    # Center dot
    draw.ellipse(
        [center_x - dot_r, center_y - dot_r, center_x + dot_r, center_y + dot_r],
        fill=(255, 255, 255, 255),
    )
    # Crosshair lines
    line_color = (255, 255, 255, 200)
    line_ext = 12
    draw.line(
        [(center_x, center_y - outer_r - line_ext), (center_x, center_y - outer_r + 2)],
        fill=line_color, width=3,
    )
    draw.line(
        [(center_x, center_y + outer_r - 2), (center_x, center_y + outer_r + line_ext)],
        fill=line_color, width=3,
    )
    draw.line(
        [(center_x - outer_r - line_ext, center_y), (center_x - outer_r + 2, center_y)],
        fill=line_color, width=3,
    )
    draw.line(
        [(center_x + outer_r - 2, center_y), (center_x + outer_r + line_ext, center_y)],
        fill=line_color, width=3,
    )

    # --- Draw "FocusBar" text at the bottom ---
    # Try to use a nice font; fall back to default
    text = "FocusBar"
    font_size = 52
    try:
        font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", font_size)
    except (OSError, IOError):
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except (OSError, IOError):
            try:
                font = ImageFont.truetype(
                    "/System/Library/Fonts/Supplemental/Arial.ttf", font_size
                )
            except (OSError, IOError):
                font = ImageFont.load_default()

    # Center the text
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    text_x = (SIZE - tw) // 2
    text_y = 410

    # Subtle text shadow
    draw.text((text_x + 1, text_y + 2), text, font=font, fill=(0, 0, 0, 60))
    # Main text
    draw.text((text_x, text_y), text, font=font, fill=(255, 255, 255, 240))

    # --- Save ---
    output_path = "/Users/faiz/faiz/personal/FocusBar/icon.png"
    bg.save(output_path, "PNG")
    print(f"Icon saved to {output_path}")
    print(f"Size: {bg.size[0]}x{bg.size[1]}")


if __name__ == "__main__":
    main()
