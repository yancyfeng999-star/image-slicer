#!/usr/bin/env python3
"""
切图工具 — 按高度每 N 像素从上往下纵向切割图片
跨平台自检环境，自动安装依赖 (Python 3.6+)

用法:
  python3 slice.py <图片路径> [--max-height 5000] [--output-dir ./slices]

支持 macOS / Windows / Linux
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path


# ──────────────────────────────────────────────
# 环境检查 & 自动安装
# ──────────────────────────────────────────────

def ensure_pip():
    """确保 pip 可用，没有则尝试 bootstrap"""
    try:
        import pip  # noqa: F401
        return True
    except ImportError:
        print("[环境] 未检测到 pip，正在尝试自动安装...")
        try:
            subprocess.check_call([sys.executable, "-m", "ensurepip", "--default-pip"])
            print("[环境] pip 安装成功")
            return True
        except Exception:
            print("[环境] pip 安装失败，请手动安装: https://pip.pypa.io/en/stable/installation/")
            return False


def ensure_pillow():
    """确保 Pillow 已安装"""
    try:
        from PIL import Image  # noqa: F401
        print("[环境] Pillow ✓")
        return True
    except ImportError:
        print("[环境] 未检测到 Pillow，正在自动安装...")
        if not ensure_pip():
            sys.exit(1)
        try:
            subprocess.check_call([
                sys.executable, "-m", "pip", "install",
                "--quiet", "--disable-pip-version-check", "Pillow"
            ])
            # 安装后验证 import
            import importlib
            importlib.invalidate_caches()
            from PIL import Image  # noqa: F401
            print("[环境] Pillow 安装成功 ✓")
            return True
        except subprocess.CalledProcessError:
            print("[环境] Pillow 安装失败，请手动运行: pip install Pillow")
            sys.exit(1)
        except ImportError:
            print("[环境] Pillow 安装后仍无法导入，请重启终端后重试")
            sys.exit(1)


def check_environment():
    """完整环境检查"""
    # 检查 Python 版本
    ver = sys.version_info
    print(f"[环境] Python {ver.major}.{ver.minor}.{ver.micro}")
    if ver < (3, 6):
        print("[环境] 需要 Python 3.6 或更高版本")
        sys.exit(1)

    # 检查 Pillow
    ensure_pillow()


# ──────────────────────────────────────────────
# 切图逻辑
# ──────────────────────────────────────────────

def slice_image(image_path: str, max_height: int = 5000, output_dir: str = None):
    from PIL import Image

    image_path = Path(image_path).expanduser().resolve()

    if not image_path.exists():
        print(f"错误: 文件不存在 — {image_path}")
        sys.exit(1)

    img = Image.open(image_path)
    width, height = img.size
    fmt = (img.format or "").upper() or image_path.suffix.lstrip(".").upper()
    if fmt == "JPG":
        fmt = "JPEG"

    print(f"\n图片: {image_path.name}")
    print(f"尺寸: {width} x {height}")
    print(f"格式: {fmt}")

    if height <= max_height:
        print(f"图片高度 {height}px 未超过 {max_height}px，无需切割。")
        return []

    # 输出目录
    if output_dir is None:
        output_dir = image_path.parent / "slices"
    else:
        output_dir = Path(output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    stem = image_path.stem
    # 保持 PNG 输出，兼容性最好
    ext = ".png"

    # 计算切片
    total_slices = (height + max_height - 1) // max_height
    print(f"将切割为 {total_slices} 片，每片最大高度 {max_height}px\n")

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
        print(f"  [{i + 1}/{total_slices}] {out_name:30s}  top={top:>6d}px  bottom={bottom:>6d}px  高度={h}px")

    print(f"\n完成! {len(slices)} 个切片已保存到: {output_dir}")
    return slices


# ──────────────────────────────────────────────
# 入口
# ──────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="切图工具 — 按高度纵向切割图片 (支持 macOS / Windows / Linux)"
    )
    parser.add_argument("image", help="要切割的图片路径")
    parser.add_argument(
        "--max-height", type=int, default=5000,
        help="每片最大高度(px)，默认 5000"
    )
    parser.add_argument(
        "--output-dir", default=None,
        help="输出目录，默认: 图片同目录/slices"
    )
    parser.add_argument(
        "--skip-check", action="store_true",
        help="跳过环境检查 (已确认环境正常时使用)"
    )
    args = parser.parse_args()

    if not args.skip_check:
        check_environment()

    slice_image(args.image, max_height=args.max_height, output_dir=args.output_dir)


if __name__ == "__main__":
    main()
