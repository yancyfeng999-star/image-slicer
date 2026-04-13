---
name: slice-image
description: 切图工具 — 按高度每5000px从上往下纵向切割图片，全自动安装环境
---

# 切图工具 (Image Slicer)

将图片从上往下，每隔 5000px 纵向切一刀，直到图片底部。

**全自动**: 没有 Python? 自动装。没有 Pillow? 自动装。
**跨平台**: macOS / Windows / Linux
**即拖即用**: 支持拖拽图片到终端窗口

## 目录结构

```
slice-image/
├── SKILL.md       # 本说明文档
├── slice.py       # 核心脚本 (Python 3.6+)
├── run.sh         # macOS / Linux 启动脚本
└── run.bat        # Windows 启动脚本
```

## 用法

### macOS / Linux
```bash
./run.sh <图片路径> [最大高度]
```

### Windows
```cmd
run.bat <图片路径> [最大高度]
```

不给参数时进入交互模式，支持拖拽文件。

## 自动安装流程

```
run.sh / run.bat
  │
  ├── 有 Python 吗?
  │     ├── 有 ↓
  │     └── 没有 → 自动安装
  │           ├── macOS: brew install python3 (没有 brew 自动装)
  │           ├── Linux: apt/dnf/yum/pacman install python3
  │           └── Windows: winget install Python / PowerShell 下载安装包
  │
  ├── 有 Pillow 吗?
  │     ├── 有 ↓
  │     └── 没有 → pip install Pillow
  │
  └── 开始切图
```

## 各平台安装方式

| 平台 | Python 安装方式 | 条件 |
|------|----------------|------|
| macOS | `brew install python3` | 没 brew 自动装 brew |
| Linux (Debian/Ubuntu) | `apt install python3 python3-pip` | 需 sudo |
| Linux (RHEL/CentOS) | `yum install python3 python3-pip` | 需 sudo |
| Linux (Arch) | `pacman -S python python-pip` | 需 sudo |
| Windows | `winget install Python.Python.3.12` | 首选 |
| Windows (备选) | PowerShell 下载 python.org 安装包静默安装 | 无 winget 时 |

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `图片路径` | 必填 | 要切割的图片路径 |
| `最大高度` | 5000 | 每片最大高度(px) |

也可直接用 Python:
```bash
python3 slice.py <图片路径> [--max-height 5000] [--output-dir ./slices] [--skip-check]
```

## 输出

- 输出目录: `图片同目录/slices/`
- 文件名: `原名_001.png`, `原名_002.png`, ...
- 每片宽度与原图相同，高度不超过设定值（最后一片可能更短）
- 输出格式统一为 PNG
- 支持输入: PNG / JPG / WebP / BMP / GIF

## 输出 (全英文，无乱码)

```
[*] Image Slicer starting...
[*] System: macos | Package manager: brew
[*] Python: /opt/homebrew/bin/python3 (Python 3.12.0)
[*] Pillow OK

Image : long_screenshot.png
Size  : 1080 x 18000
Format: PNG
Will split into 4 slices, max height 5000px each

  [1/4] long_screenshot_001.png       top=     0  bottom= 5000  height=5000
  [2/4] long_screenshot_002.png       top= 5000  bottom=10000  height=5000
  [3/4] long_screenshot_003.png       top=10000  bottom=15000  height=5000
  [4/4] long_screenshot_004.png       top=15000  bottom=18000  height=3000

Done! 4 slices saved to: ./slices
```

## 故障排查

| 问题 | 解决方案 |
|------|----------|
| Python 安装后仍找不到 | 重启终端，重新运行脚本 |
| sudo 权限不足 (Linux) | 确保当前用户有 sudo 权限 |
| winget 找不到 | Windows 版本太旧，用 PowerShell 方式安装 |
| Pillow 安装失败 | 手动运行: `pip install Pillow` |
| 编码乱码 (Windows) | run.bat 已自动设置 UTF-8 |
