---
name: slice-image
description: Image Slicer - Split long images vertically every 5000px. Cross-platform, auto-install.
---

# Image Slicer

Split long images vertically every N pixels from top to bottom.

**Auto-install**: Python and Pillow installed automatically if missing.
**Cross-platform**: macOS / Windows / Linux
**No encoding issues**: All output in English.

## Structure

```
slice-image/
├── README.md       Quick start
├── TUTORIAL.md     Detailed tutorial
├── SKILL.md        This file
├── slice.py        Core script (Python 3.6+)
├── run.sh          macOS / Linux launcher
└── run.ps1         Windows launcher (PowerShell)
```

## Usage

```bash
# macOS / Linux
./run.sh <image> [max_height]

# Windows (PowerShell)
.\run.ps1 <image> [max_height]

# Direct Python
python3 slice.py <image> [--max-height 5000] [--output-dir ./slices]
```

## Auto-install Flow

```
run.sh / run.ps1
  |
  |-- Python exists?
  |     YES -> continue
  |     NO  -> install
  |             macOS: brew install python3
  |             Linux: apt/dnf/yum/pacman install python3
  |             Windows: winget install Python / PowerShell download
  |
  |-- Pillow exists?
  |     YES -> continue
  |     NO  -> pip install Pillow
  |
  +-- Slice image
```

## Parameters

| Param | Default | Description |
|-------|---------|-------------|
| image | required | Image file path |
| max_height | 5000 | Max slice height (px) |
| --output-dir | image_dir/slices | Output directory |
| --skip-check | false | Skip env check |

## Output

- Directory: `<image_dir>/slices/`
- Files: `name_001.png`, `name_002.png`, ...
- Format: PNG
- Input: PNG / JPG / WebP / BMP / GIF

## Example Output

```
[*] Image Slicer starting...
[*] Python: /usr/bin/python3 (Python 3.12.0)
[*] Pillow OK

Image : screenshot.png
Size  : 1080 x 18000
Format: PNG
Will split into 4 slices, max height 5000px each

  [1/4] screenshot_001.png       top=     0  bottom= 5000  height=5000
  [2/4] screenshot_002.png       top= 5000  bottom=10000  height=5000
  [3/4] screenshot_003.png       top=10000  bottom=15000  height=5000
  [4/4] screenshot_004.png       top=15000  bottom=18000  height=3000

Done! 4 slices saved to: ./slices
```
