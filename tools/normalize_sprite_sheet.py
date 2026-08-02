"""Normalize AI sprite-sheet cells to a shared canvas and foot baseline.

AI sheets often keep different transparent padding per action. This utility keeps
each frame's pixels intact while fitting it into an identical cell size, so a
character does not visually grow or sink when Godot changes animations.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--columns", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--cell-width", type=int, required=True)
    parser.add_argument("--cell-height", type=int, required=True)
    parser.add_argument("--padding", type=int, default=12)
    parser.add_argument("--bottom-padding", type=int, default=8)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = Image.open(args.input).convert("RGBA")
    output = Image.new(
        "RGBA",
        (args.columns * args.cell_width, args.rows * args.cell_height),
        (0, 0, 0, 0),
    )
    source_cell_width = source.width / args.columns
    source_cell_height = source.height / args.rows
    max_width = args.cell_width - args.padding * 2
    max_height = args.cell_height - args.padding - args.bottom_padding

    for row in range(args.rows):
        for column in range(args.columns):
            left = round(column * source_cell_width)
            top = round(row * source_cell_height)
            right = round((column + 1) * source_cell_width)
            bottom = round((row + 1) * source_cell_height)
            frame = source.crop((left, top, right, bottom))
            bounds = frame.getchannel("A").getbbox()
            if bounds is None:
                continue
            frame = frame.crop(bounds)
            scale = min(max_width / frame.width, max_height / frame.height, 1.0)
            resized_size = (
                max(1, round(frame.width * scale)),
                max(1, round(frame.height * scale)),
            )
            frame = frame.resize(resized_size, Image.Resampling.LANCZOS)
            destination_x = column * args.cell_width + (args.cell_width - frame.width) // 2
            destination_y = (row + 1) * args.cell_height - args.bottom_padding - frame.height
            output.alpha_composite(frame, (destination_x, destination_y))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    output.save(args.output)
    print(f"Wrote {args.output} ({output.width}x{output.height})")


if __name__ == "__main__":
    main()
