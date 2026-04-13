# 切图工具 (Image Slicer)

> 纵向切割长图，每 5000px 一刀，零门槛全自动

## 这是什么?

当你有一张很长的图片（比如网页长截图、设计稿、数据报表），某些平台限制上传尺寸时，可以用这个工具自动纵向切成多张小图。

**切之前:**
```
┌──────────┐
│          │
│  18000px │
│          │
│          │
└──────────┘
```

**切之后:**
```
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  001     │  │  002     │  │  003     │  │  004     │
│  5000px  │  │  5000px  │  │  5000px  │  │  3000px  │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

## 特性

- **全自动环境** — 没有 Python? 自动装。没有依赖? 自动装。
- **跨平台** — macOS / Windows / Linux
- **零配置** — 双击运行，拖入图片，搞定
- **支持主流格式** — PNG / JPG / WebP / BMP / GIF

## 快速开始

### macOS

1. 打开终端 (Spotlight 搜索 "终端")
2. 进入工具目录:
   ```bash
   cd ~/Desktop/Mac\ Dpxx项目/skills/自建skills/slice-image
   ```
3. 运行:
   ```bash
   ./run.sh
   ```
4. 按提示输入图片路径 (或直接拖文件到终端窗口)

### Windows

1. 双击 `run.bat`
2. 按提示输入图片路径 (或直接拖文件到窗口)

就这么简单。脚本会自动处理剩下的事情。

## 目录结构

```
slice-image/
├── README.md        ← 你正在看的文件
├── TUTORIAL.md      ← 详细教程
├── SKILL.md         # 技能说明 (给 AI 用的)
├── slice.py         # 核心切割脚本
├── run.sh           # macOS/Linux 启动器
└── run.bat          # Windows 启动器
```

## 命令行用法

如果你熟悉终端，也可以直接调用 Python 脚本:

```bash
# 基本用法
./run.sh ./长截图.png

# 自定义切片高度 (每 3000px 切一次)
./run.sh ./长截图.png 3000

# 指定输出目录
python3 slice.py ./长截图.png --max-height 5000 --output-dir ./输出目录

# 跳过环境检查 (已确认环境正常时)
python3 slice.py ./长截图.png --skip-check
```

## 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `图片路径` | 必填 | 要切割的图片 |
| `最大高度` | 5000 | 每片最大高度 (px) |
| `--output-dir` | 图片同目录/slices | 输出目录 |
| `--skip-check` | false | 跳过环境检查 |

## 运行效果

```
[切图工具] 启动
[切图工具] 系统: macos | 包管理器: brew
[切图工具] Python: python3 (Python 3.12.0) ✓
[切图工具] Pillow ✓

图片: long_screenshot.png
尺寸: 1080 x 18000
格式: PNG
将切割为 4 片，每片最大高度 5000px

  [1/4] long_screenshot_001.png       top=     0px  bottom= 5000px  高度=5000px
  [2/4] long_screenshot_002.png       top= 5000px  bottom=10000px  高度=5000px
  [3/4] long_screenshot_003.png       top=10000px  bottom=15000px  高度=5000px
  [4/4] long_screenshot_004.png       top=15000px  bottom=18000px  高度=3000px

完成! 4 个切片已保存到: ./slices
```

## 常见问题

**Q: 运行后没反应?**
A: 可能是第一次运行在后台下载安装 Python，等几分钟就好。

**Q: 提示权限不足?**
A: macOS/Linux 终端运行: `chmod +x run.sh`

**Q: 图片高度没超过 5000px 会怎样?**
A: 直接告诉你不用切，什么也不做。

**Q: 输出格式是什么?**
A: 统一输出 PNG，兼容性最好。

**Q: 可以切多张图片吗?**
A: 目前一次一张，可以连续运行多次。

**Q: Windows 上 python 找不到?**
A: 安装 Python 时记得勾选 "Add to PATH"。如果已安装但没勾，重启终端试试。

## 技术栈

- Python 3.6+
- Pillow (PIL) — 图片处理库
- 无其他依赖

## License

随便用。
