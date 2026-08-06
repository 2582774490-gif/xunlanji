"""Non-destructive helper for six-frame AI sprite-sheet production sources."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def frame_paths(directory: Path, prefix: str, suffix: str) -> list[Path]:
    return [directory / f"{prefix}_f{index}_{suffix}.png" for index in range(1, 7)]


def crop_sheet(sheet_path: Path, output_dir: Path, prefix: str) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(sheet_path).convert("RGBA")
    width, height = sheet.size
    for index, frame_path in enumerate(frame_paths(output_dir, prefix, "key")):
        left = round(index * width / 6)
        right = round((index + 1) * width / 6)
        sheet.crop((left, 0, right, height)).save(frame_path)


def align_alpha_frames(directory: Path, prefix: str, edge_clear_px: int) -> None:
    paths = frame_paths(directory, prefix, "alpha")
    images = [Image.open(path).convert("RGBA") for path in paths]
    for image in images:
        alpha = image.getchannel("A")
        alpha.paste(0, (0, 0, edge_clear_px, image.height))
        alpha.paste(0, (image.width - edge_clear_px, 0, image.width, image.height))
        image.putalpha(alpha)
    bottoms = [image.getchannel("A").getbbox() for image in images]
    if any(bbox is None for bbox in bottoms):
        raise ValueError("One or more alpha frames contain no visible subject.")
    target_bottom = max(bbox[3] for bbox in bottoms if bbox is not None)
    for image, path, bbox in zip(images, paths, bottoms):
        if bbox is None:
            continue
        canvas = Image.new("RGBA", image.size, (0, 0, 0, 0))
        canvas.alpha_composite(image, (0, target_bottom - bbox[3]))
        canvas.save(path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("step", choices=("crop", "align"))
    parser.add_argument("--prefix", required=True)
    parser.add_argument("--sheet")
    parser.add_argument("--source-dir")
    parser.add_argument("--alpha-dir")
    parser.add_argument("--edge-clear-px", type=int, default=12)
    args = parser.parse_args()
    if args.step == "crop":
        if not args.sheet or not args.source_dir:
            parser.error("crop requires --sheet and --source-dir")
        crop_sheet(Path(args.sheet), Path(args.source_dir), args.prefix)
    else:
        if not args.alpha_dir:
            parser.error("align requires --alpha-dir")
        align_alpha_frames(Path(args.alpha_dir), args.prefix, args.edge_clear_px)


if __name__ == "__main__":
    main()
