# Image Slicer - 详细教程

## 目录

- [第一次使用](#第一次使用)
- [macOS 使用](#macos-使用)
- [Windows 使用](#windows-使用)
- [Linux 使用](#linux-使用)
- [场景示例](#场景示例)
- [自定义参数](#自定义参数)
- [批量处理](#批量处理)
- [自动安装了什么](#自动安装了什么)
- [故障排除](#故障排除)

---

## 第一次使用

不管你用什么系统，流程都一样：

1. 下载 / 克隆这个项目
2. 运行对应平台的启动脚本
3. 拖入图片或输入路径
4. 等待完成，切片在 `slices/` 目录

脚本会自动处理 Python、Pillow 等一切依赖。

---

## macOS 使用

### 方式一：终端运行

1. 打开终端（Cmd + 空格，搜 "终端"）
2. 进入项目目录：
   ```bash
   cd ~/path/to/slice-image
   ```
3. 运行：
   ```bash
   ./run.sh
   ```
4. 输入图片路径，或直接拖文件到终端窗口
5. 输入切片高度（默认 5000，直接回车）

### 方式二：一步到位

```bash
./run.sh ~/Desktop/长截图.png
./run.sh ~/Desktop/长截图.png 3000
```

### 首次运行

```
[*] Image Slicer starting...
[*] System: macos | Package manager: brew
[*] Python: /opt/homebrew/bin/python3 (Python 3.12.0)
[*] Pillow OK

Image : 长截图.png
Size  : 1080 x 15000
Format: PNG
Will split into 3 slices, max height 5000px each

  [1/3] 长截图_001.png                top=     0  bottom= 5000  height=5000
  [2/3] 长截图_002.png                top= 5000  bottom=10000  height=5000
  [3/3] 长截图_003.png                top=10000  bottom=15000  height=5000

Done! 3 slices saved to: /Users/dpxx/Desktop/slices
```

如果是第一次运行，会多几行安装 Python / Pillow 的信息，耐心等待。

---

## Windows 使用

### 方式一：右键运行（推荐）

1. 找到 `run.ps1` 文件
2. **右键** → 选择「使用 PowerShell 运行」
3. 输入图片路径，或拖文件到窗口
4. 输入切片高度（默认 5000，直接回车）

### 方式二：PowerShell 命令

```powershell
cd C:\path\to\slice-image
.\run.ps1
.\run.ps1 "C:\Users\dpxx\Desktop\长截图.png" 3000
```

> 如果提示「无法加载脚本」，先运行：
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### 首次运行

```
========================================
  Image Slicer
========================================

[*] Python: Python 3.12.0
[*] Pillow OK

Drag and drop an image file here, or type the path:

Image path: C:\Users\dpxx\Desktop\长截图.png
Max height per slice (default 5000): 3000

Image : 长截图.png
Size  : 1080 x 15000
Format: PNG
Will split into 5 slices, max height 3000px each

  [1/5] 长截图_001.png                top=     0  bottom= 3000  height=3000
  [2/5] 长截图_002.png                top= 3000  bottom= 6000  height=3000
  [3/5] 长截图_003.png                top= 6000  bottom= 9000  height=3000
  [4/5] 长截图_004.png                top= 9000  bottom=12000  height=3000
  [5/5] 长截图_005.png                top=12000  bottom=15000  height=3000

Done! 5 slices saved to: C:\Users\dpxx\Desktop\slices

Press Enter to exit
```

---

## Linux 使用

```bash
cd slice-image
./run.sh
./run.sh ./screenshot.png 3000
```

支持 apt / dnf / yum / pacman / apk / zypper 自动安装 Python。

---

## 场景示例

### 1. 网页长截图

微信/钉钉发图会被压缩，切成小图保持清晰。

```bash
./run.sh ~/Desktop/网页截图.png 4000
```

### 2. 设计稿按屏切分

1920x10800 的设计稿，按每屏 1080px 切：

```bash
./run.sh design.png 1080
```

### 3. 长表格截图

Excel 长截图，按 2000px 切分方便插入文档：

```bash
./run.sh report.png 2000
```

### 4. 超长信息图

20000px 的信息图切成小块：

```bash
./run.sh infographic.png 5000
```

---

## 自定义参数

```bash
# 每 2000px 切一次
./run.sh image.png 2000

# 指定输出目录
python3 slice.py image.png --output-dir ~/Desktop/output

# 组合
python3 slice.py image.png --max-height 3000 --output-dir ./out

# 跳过环境检查
python3 slice.py image.png --skip-check
```

---

## 批量处理

### macOS / Linux

```bash
for img in ~/Desktop/*.png; do
    ./run.sh "$img" 5000
done
```

### Windows PowerShell

```powershell
Get-ChildItem C:\Users\dpxx\Desktop\*.png | ForEach-Object {
    python slice.py $_.FullName --max-height 5000
}
```

---

## 自动安装了什么

脚本只在需要时安装，不会多装任何东西：

| 组件 | 什么时候装 | 安装位置 |
|------|-----------|---------|
| Homebrew | macOS 没有 brew 时 | /opt/homebrew |
| Python 3 | 系统没有 Python 时 | 系统默认 |
| pip | Python 没有 pip 时 | 跟 Python 一起 |
| Pillow | 没有 Pillow 时 | site-packages |

不会安装其他软件、不会修改系统、不会收集数据。

---

## 故障排除

### macOS

| 问题 | 解决 |
|------|------|
| permission denied | `chmod +x run.sh` |
| command not found: python3 | `brew install python3` |
| xcode-select error | `xcode-select --install` |

### Windows

| 问题 | 解决 |
|------|------|
| 无法加载脚本 | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| python 不是内部命令 | 安装时勾选 "Add to PATH"，重启终端 |
| winget 找不到 | 会自动用 PowerShell 下载安装 |

### Linux

| 问题 | 解决 |
|------|------|
| sudo 权限不足 | 切换到有 sudo 权限的用户 |
| apt update 失败 | 检查网络和代理 |

### 通用

| 问题 | 解决 |
|------|------|
| 切出来是黑的 | 先转成 PNG 再切 |
| 输出目录没出现 | 用纯英文路径重试 |

---

## 卸载

直接删除文件夹。没有安装任何系统组件。

清理 Pillow（可选，不影响其他项目）：
```bash
pip3 uninstall Pillow
```
