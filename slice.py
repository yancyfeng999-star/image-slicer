#!/usr/bin/env python3
"""
Image Slicer - Split long images vertically every N pixels.
Cross-platform, auto-install dependencies (Python 3.6+).

Usage:
  python3 slice.py <image> [--max-height 5000] [--output-dir ./slices]

Supports macOS / Windows / Linux
"""

import argparse
import os
import sys
from pathlib import Path


def slice_image(image_path: str, max_height: int = 5000, output_dir: str = None):
    from PIL import Image

    image_path = Path(image_path).expanduser().resolve()

    if not image_path.exists():
        print(f"[error] File not found: {image_path}")
        sys.exit(1)

    img = Image.open(image_path)
    width, height = img.size
    fmt = (img.format or "").upper() or image_path.suffix.lstrip(".").upper()
    if fmt == "JPG":
        fmt = "JPEG"

    print(f"\nImage : {image_path.name}")
    print(f"Size  : {width} x {height}")
    print(f"Format: {fmt}")

    if height <= max_height:
        print(f"Height {height}px <= {max_height}px, no need to slice.")
        return []

    # Output directory
    if output_dir is None:
        output_dir = image_path.parent / "slices"
    else:
        output_dir = Path(output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    stem = image_path.stem
    ext = ".png"

    # Calculate slices
    total_slices = (height + max_height - 1) // max_height
    print(f"Will split into {total_slices} slices, max height {max_height}px each\n")

    slices = []
    for i in range(total_slices):
        top = i * max_height
        bottom = min(top + max_height, height)
        box = (0, top, width, bottom)
        cropped = img.crop(box)

        out_name = f"{stem}_{i + 1:03d}{ext}"
        out_path = output_dir / out_name
        cropped.save(out_path)
        slices.append(out_path)
        h = bottom - top
        print(f"  [{i + 1}/{total_slices}] {out_name:30s}  top={top:>6d}  bottom={bottom:>6d}  height={h}")

    print(f"\nDone! {len(slices)} slices saved to: {output_dir}")
    return slices


def main():
    parser = argparse.ArgumentParser(
        description="Image Slicer - Split long images vertically (macOS / Windows / Linux)"
    )
    parser.add_argument("image", help="Image file path")
    parser.add_argument("--max-height", type=int, default=5000, help="Max height per slice (default: 5000)")
    parser.add_argument("--output-dir", default=None, help="Output directory (default: image_dir/slices)")
    args = parser.parse_args()

    slice_image(args.image, max_height=args.max_height, output_dir=args.output_dir)


if __name__ == "__main__":
    main()
