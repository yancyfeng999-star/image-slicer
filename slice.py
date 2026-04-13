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
import subprocess
import sys
from pathlib import Path


# ──────────────────────────────────────────────
# Environment check & auto-install
# ──────────────────────────────────────────────

def ensure_pip():
    """Ensure pip is available."""
    try:
        import pip  # noqa: F401
        return True
    except ImportError:
        print("[env] pip not found, installing...")
        try:
            subprocess.check_call([sys.executable, "-m", "ensurepip", "--default-pip"])
            print("[env] pip installed.")
            return True
        except Exception:
            print("[env] pip install failed. Install manually: https://pip.pypa.io/en/stable/installation/")
            return False


def ensure_pillow():
    """Ensure Pillow is installed."""
    try:
        from PIL import Image  # noqa: F401
        print("[env] Pillow OK")
        return True
    except ImportError:
        print("[env] Pillow not found, installing...")
        if not ensure_pip():
            sys.exit(1)
        try:
            subprocess.check_call([
                sys.executable, "-m", "pip", "install",
                "--quiet", "--disable-pip-version-check", "Pillow"
            ])
            import importlib
            importlib.invalidate_caches()
            from PIL import Image  # noqa: F401
            print("[env] Pillow installed.")
            return True
        except subprocess.CalledProcessError:
            print("[env] Pillow install failed. Try: pip install Pillow")
            sys.exit(1)
        except ImportError:
            print("[env] Pillow installed but cannot import. Restart terminal and retry.")
            sys.exit(1)


def check_environment():
    """Full environment check."""
    ver = sys.version_info
    print(f"[env] Python {ver.major}.{ver.minor}.{ver.micro}")
    if ver < (3, 6):
        print("[env] Need Python 3.6 or higher.")
        sys.exit(1)
    ensure_pillow()


# ──────────────────────────────────────────────
# Slice logic
# ──────────────────────────────────────────────

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


# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Image Slicer - Split long images vertically (macOS / Windows / Linux)"
    )
    parser.add_argument("image", help="Image file path")
    parser.add_argument(
        "--max-height", type=int, default=5000,
        help="Max height per slice in px (default: 5000)"
    )
    parser.add_argument(
        "--output-dir", default=None,
        help="Output directory (default: <image_dir>/slices)"
    )
    parser.add_argument(
        "--skip-check", action="store_true",
        help="Skip environment check"
    )
    args = parser.parse_args()

    if not args.skip_check:
        check_environment()

    slice_image(args.image, max_height=args.max_height, output_dir=args.output_dir)


if __name__ == "__main__":
    main()
