# 切图工具 — 详细教程

## 目录

1. [第一次使用](#第一次使用)
2. [macOS 使用指南](#macos-使用指南)
3. [Windows 使用指南](#windows-使用指南)
4. [场景示例](#场景示例)
5. [自定义参数](#自定义参数)
6. [批量处理](#批量处理)
7. [自动安装了什么](#自动安装了什么)
8. [故障排除](#故障排除)

---

## 第一次使用

无论什么系统，操作都一样：

1. 找到这个工具文件夹
2. 运行启动脚本
3. 拖入图片或输入路径
4. 完成

就这么简单。脚本会自动搞定 Python、Pillow 等一切依赖。

---

## macOS 使用指南

### 方式一：终端命令 (推荐)

1. **打开终端**
   - 按 `Cmd + 空格` 打开 Spotlight
   - 输入 `终端` 或 `Terminal`，回车

2. **进入工具目录**
   ```bash
   cd ~/Desktop/Mac\ Dpxx项目/skills/自建skills/slice-image
   ```

3. **运行脚本**
   ```bash
   ./run.sh
   ```

4. **输入图片路径**
   - 手动输入路径: `/Users/dpxx/Desktop/screenshot.png`
   - 或者直接把图片文件 **拖到终端窗口**，路径会自动填入

5. **输入切片高度**
   - 直接回车使用默认 5000px
   - 或输入自定义值，比如 `3000`

6. **等待完成**
   - 切片自动保存在图片同目录的 `slices/` 文件夹

### 方式二：一步到位

```bash
# 直接指定图片和高度
./run.sh ~/Desktop/长截图.png 3000
```

### 首次运行会看到什么

```
[切图工具] 启动
[切图工具] 系统: macos | 包管理器: brew
[切图工具] Python: python3 (Python 3.12.0) ✓
[切图工具] Pillow ✓

图片: 长截图.png
尺寸: 1080 x 15000
格式: PNG
将切割为 3 片，每片最大高度 5000px

  [1/3] 长截图_001.png                top=     0px  bottom= 5000px  高度=5000px
  [2/3] 长截图_002.png                top= 5000px  bottom=10000px  高度=5000px
  [3/3] 长截图_003.png                top=10000px  bottom=15000px  高度=5000px

完成! 3 个切片已保存到: /Users/dpxx/Desktop/slices
```

> 如果是第一次运行，会在 Python 检测前多几行安装信息，耐心等待即可。

---

## Windows 使用指南

### 方式一：双击运行

1. **找到 `run.bat` 文件**
   - 在切图工具文件夹里

2. **双击 `run.bat`**
   - 弹出一个黑色命令行窗口

3. **输入图片路径**
   - 手动输入路径: `C:\Users\dpxx\Desktop\screenshot.png`
   - 或者直接把图片文件 **拖到窗口里**

4. **输入切片高度**
   - 直接回车使用默认 5000px

5. **按任意键退出**
   - 切片保存在图片同目录的 `slices/` 文件夹

### 方式二：命令行

```cmd
cd C:\Users\dpxx\Desktop\Mac Dpxx项目\skills\自建skills\slice-image
run.bat "C:\Users\dpxx\Desktop\长截图.png" 3000
```

> 路径有空格时记得加引号。

### 首次运行会看到什么

```
[切图工具] 启动...
[切图工具] Python: Python 3.12.0 ✓
[切图工具] Pillow ✓

========================================
  切图工具 — 按高度纵向切割图片
========================================

请输入图片路径: C:\Users\dpxx\Desktop\长截图.png
每片最大高度(px, 默认5000): 3000

图片: 长截图.png
尺寸: 1080 x 15000
格式: PNG
将切割为 5 片，每片最大高度 3000px

  [1/5] 长截图_001.png                top=     0px  bottom= 3000px  高度=3000px
  [2/5] 长截图_002.png                top= 3000px  bottom= 6000px  高度=3000px
  [3/5] 长截图_003.png                top= 6000px  bottom= 9000px  高度=3000px
  [4/5] 长截图_004.png                top= 9000px  bottom=12000px  高度=3000px
  [5/5] 长截图_005.png                top=12000px  bottom=15000px  高度=3000px

完成! 5 个切片已保存到: C:\Users\dpxx\Desktop\slices

请按任意键继续. . .
```

> 如果电脑没有 Python，窗口会多几行安装信息。

---

## 场景示例

### 场景一：网页长截图切片

微信/钉钉发图有大小限制，长截图会被压缩。

```bash
./run.sh ~/Desktop/网页截图.png 4000
```

得到的切片清晰度不会被压缩。

### 场景二：设计稿按屏切分

1920x10800 的设计稿，想按每 1080px (一屏) 切分：

```bash
./run.sh design.psd 1080
```

> 注意：PSD 格式不支持，先导出为 PNG/JPG。

### 场景三：长表格截图

Excel/表格长截图，按 2000px 切分，方便在文档中插入：

```bash
./run.sh report.png 2000
```

### 场景四：GIF 动图切帧

把一张长 GIF 的每一帧切出来（会转成 PNG）：

```bash
./run.sh animation.gif 1
```

### 场景五：超长信息图

20000px 高的信息图，想切成方便管理的小块：

```bash
./run.sh infographic.png 5000
```

---

## 自定义参数

### 改变切片高度

```bash
# 每 2000px 切一次
./run.sh image.png 2000

# 每 10000px 切一次
./run.sh image.png 10000
```

### 指定输出目录

```bash
# 输出到指定目录
python3 slice.py image.png --output-dir ~/Desktop/my_slices

# 输出到当前目录
python3 slice.py image.png --output-dir .
```

### 组合使用

```bash
python3 slice.py image.png --max-height 3000 --output-dir ./output
```

---

## 批量处理

一次切多张图片？写个循环：

**macOS/Linux (bash):**

```bash
for img in ~/Desktop/*.png; do
    ./run.sh "$img" 5000
done
```

**Windows (cmd):**

```cmd
for %f in (C:\Users\dpxx\Desktop\*.png) do run.bat "%f" 5000
```

**Windows (PowerShell):**

```powershell
Get-ChildItem C:\Users\dpxx\Desktop\*.png | ForEach-Object {
    python slice.py $_.FullName --max-height 5000
}
```

---

## 自动安装了什么

脚本会按需自动安装，不会多装任何东西：

| 组件 | 什么时候装 | 装到哪 |
|------|-----------|--------|
| **Homebrew** | macOS 没有 brew 时 | `/opt/homebrew` (Apple Silicon) 或 `/usr/local` (Intel) |
| **Python 3** | 系统没有 Python 时 | 系统默认位置 |
| **pip** | Python 没有 pip 时 | 跟 Python 一起 |
| **Pillow** | 没有 Pillow 时 | Python 的 site-packages |

**不会安装的东西：**
- 不会修改系统文件
- 不会安装任何其他软件
- 不会启动后台服务
- 不会收集任何数据

---

## 故障排除

### macOS

| 问题 | 原因 | 解决 |
|------|------|------|
| `permission denied` | 脚本没有执行权限 | `chmod +x run.sh` |
| `command not found: python3` | Python 安装失败 | 手动: `brew install python3` |
| `Pillow 安装失败` | pip 权限问题 | `pip3 install --user Pillow` |
| `xcode-select: error` | macOS 需要命令行工具 | `xcode-select --install` |

### Windows

| 问题 | 原因 | 解决 |
|------|------|------|
| `python 不是内部或外部命令` | Python 没加 PATH | 重启终端，或重新安装时勾选 "Add to PATH" |
| `winget 找不到` | Windows 版本太旧 | 会自动用 PowerShell 方式安装 |
| `乱码` | 终端编码问题 | run.bat 已自动设置 UTF-8 |
| `权限被拒绝` | 防火墙/杀毒拦截 | 暂时关闭，或把文件夹加入白名单 |

### Linux

| 问题 | 原因 | 解决 |
|------|------|------|
| `sudo: command not found` | 非 root 用户 | 切换到有 sudo 权限的用户 |
| `apt-get update 失败` | 网络问题 | 检查网络连接和代理 |
| `Pillow 编译失败` | 缺少编译依赖 | `sudo apt-get install python3-dev` |

### 通用

| 问题 | 原因 | 解决 |
|------|------|------|
| 图片切出来是黑的 | 图片格式特殊 | 先转成 PNG 再切 |
| 切片数量不对 | 图片高度测量方式 | 检查原图是否损坏 |
| 输出目录没出现 | 路径有特殊字符 | 用纯英文/数字路径重试 |

---

## 卸载

这个工具没有安装任何东西到系统里，直接删除文件夹就行。

如果你想清理它自动安装的依赖：

```bash
# 卸载 Pillow (不影响其他 Python 项目)
pip3 uninstall Pillow

# Python 和 Homebrew 请保留，很多其他软件也需要它们
```

---

## 更多帮助

- 查看 `README.md` 了解基本信息
- 查看 `SKILL.md` 了解技术细节
- 遇到问题可以截图发给作者
