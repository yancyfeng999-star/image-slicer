# Image Slicer

纵向切割长图，每 5000px 一刀。零门槛，全自动。

## 这是什么

当你有一张很长的图片（网页长截图、设计稿、数据报表），某些平台限制上传尺寸时，用这个工具自动切成多张小图。

```
切之前:                切之后:

+----------+          +----------+  +----------+  +----------+  +----------+
|          |          |  001     |  |  002     |  |  003     |  |  004     |
|          |   --->   |  5000px  |  |  5000px  |  |  5000px  |  |  3000px  |
|  18000px |          +----------+  +----------+  +----------+  +----------+
|          |
|          |
+----------+
```

## 特性

- 全自动环境 — 没 Python? 自动装。没 Pillow? 自动装。
- 跨平台 — macOS / Windows / Linux
- 零配置 — 双击运行，拖入图片，搞定
- 支持格式 — PNG / JPG / WebP / BMP / GIF

## 快速开始

### macOS

```bash
cd slice-image
./run.sh
```

按提示输入图片路径，或拖文件到终端窗口。

### Windows

右键 `run.ps1`，选择「使用 PowerShell 运行」。

```powershell
# 或在 PowerShell 中:
.\run.ps1
.\run.ps1 screenshot.png 3000
```

按提示输入图片路径，或拖文件到窗口。

就这么简单。

## 项目结构

```
slice-image/
├── README.md          ← 你正在看的文件
├── TUTORIAL.md        ← 详细教程
├── SKILL.md           技能说明
├── slice.py           核心切割脚本
├── run.sh             macOS / Linux 启动器
└── run.ps1            Windows 启动器 (PowerShell)
```

## 命令行用法

```bash
# macOS / Linux
./run.sh ./screenshot.png
./run.sh ./screenshot.png 3000

# 直接用 Python
python3 slice.py ./screenshot.png --max-height 5000 --output-dir ./output

# Windows PowerShell
.\run.ps1 .\screenshot.png 3000
```

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| image | 必填 | 图片路径 |
| max_height | 5000 | 每片最大高度 (px) |
| --output-dir | 图片同目录/slices | 输出目录 |
| --skip-check | false | 跳过环境检查 |

## 运行效果

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

## 常见问题

**Q: 运行后没反应？**
第一次运行会在后台安装 Python / Pillow，等几分钟。

**Q: 图片高度没超过阈值？**
直接提示无需切割，什么都不做。

**Q: 输出是什么格式？**
统一 PNG，兼容性最好。

**Q: Windows 找不到 Python？**
安装时勾选 "Add to PATH"。或用 winget: `winget install Python.Python.3.12`

## License

随便用。
