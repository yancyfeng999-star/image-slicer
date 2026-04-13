#!/bin/bash
# 切图工具 — macOS / Linux 启动脚本
# 用法: ./run.sh <图片路径> [最大高度]
# 功能: 自动检测 + 自动安装 Python 和依赖

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ──────────────────────────────────────────
# 日志函数
# ──────────────────────────────────────────
log()  { echo "[切图工具] $*"; }
warn() { echo "[切图工具] ⚠ $*" >&2; }
die()  { echo "[切图工具] ✗ $*" >&2; exit 1; }

# ──────────────────────────────────────────
# 检测操作系统
# ──────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        *)        echo "unknown" ;;
    esac
}

# ──────────────────────────────────────────
# 检测包管理器
# ──────────────────────────────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v apk &>/dev/null; then
        echo "apk"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "none"
    fi
}

# ──────────────────────────────────────────
# 安装 Homebrew (macOS)
# ──────────────────────────────────────────
install_homebrew() {
    log "正在安装 Homebrew (macOS 包管理器)..."
    log "这可能需要几分钟，请耐心等待..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null

    # Apple Silicon 需要添加到 PATH
    if [ -d "/opt/homebrew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log "Homebrew 安装完成 ✓"
}

# ──────────────────────────────────────────
# 安装 Python
# ──────────────────────────────────────────
install_python() {
    local os="$1"
    local pkg_mgr="$2"

    log "未检测到 Python，开始自动安装..."

    case "$os" in
        macos)
            # macOS: 用 Homebrew
            if [ "$pkg_mgr" != "brew" ]; then
                install_homebrew
                pkg_mgr="brew"
            fi
            log "正在通过 Homebrew 安装 Python..."
            brew install python3
            ;;

        linux)
            case "$pkg_mgr" in
                apt)
                    log "正在通过 apt 安装 Python..."
                    sudo apt-get update -qq
                    sudo apt-get install -y -qq python3 python3-pip python3-pil
                    ;;
                dnf)
                    log "正在通过 dnf 安装 Python..."
                    sudo dnf install -y python3 python3-pip python3-pillow
                    ;;
                yum)
                    log "正在通过 yum 安装 Python..."
                    sudo yum install -y python3 python3-pip
                    ;;
                pacman)
                    log "正在通过 pacman 安装 Python..."
                    sudo pacman -Sy --noconfirm python python-pip python-pillow
                    ;;
                apk)
                    log "正在通过 apk 安装 Python..."
                    sudo apk add --no-cache python3 py3-pip py3-pillow
                    ;;
                zypper)
                    log "正在通过 zypper 安装 Python..."
                    sudo zypper install -y python3 python3-pip
                    ;;
                none)
                    die "未检测到包管理器，请手动安装 Python:
  https://python.org/downloads"
                    ;;
            esac
            ;;

        *)
            die "不支持的操作系统，请手动安装 Python:
  https://python.org/downloads"
            ;;
    esac

    log "Python 安装完成 ✓"
}

# ──────────────────────────────────────────
# 查找 Python 可执行文件
# ──────────────────────────────────────────
find_python() {
    # 刷新 PATH (Homebrew 安装后可能需要)
    if [ -d "/opt/homebrew/bin" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    for candidate in \
        python3 \
        python \
        /usr/bin/python3 \
        /usr/local/bin/python3 \
        /opt/homebrew/bin/python3 \
        /opt/anaconda3/bin/python \
        ~/miniconda3/bin/python3 \
        "$HOME/.pyenv/shims/python3"; do
        if command -v "$candidate" &>/dev/null 2>&1; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

# ──────────────────────────────────────────
# 安装 Pillow
# ──────────────────────────────────────────
install_pillow() {
    local python="$1"
    log "正在安装 Pillow (图片处理库)..."
    "$python" -m pip install --quiet --disable-pip-version-check Pillow 2>/dev/null \
        || "$python" -m pip3 install --quiet --disable-pip-version-check Pillow 2>/dev/null \
        || die "Pillow 安装失败，请手动运行: $python -m pip install Pillow"
    log "Pillow 安装完成 ✓"
}

# ──────────────────────────────────────────
# 主流程
# ──────────────────────────────────────────
log "切图工具启动"

# 1. 检测 OS
OS=$(detect_os)
PKG_MGR=$(detect_pkg_manager)
log "系统: $OS | 包管理器: $PKG_MGR"

# 2. 查找或安装 Python
PYTHON=$(find_python || true)

if [ -z "$PYTHON" ]; then
    install_python "$OS" "$PKG_MGR"
    PYTHON=$(find_python) || die "Python 安装后仍无法找到，请重启终端再试"
    # 刷新 pip
    "$PYTHON" -m ensurepip --default-pip 2>/dev/null || true
fi

PYVER=$("$PYTHON" --version 2>&1)
log "Python: $PYTHON ($PYVER)"

# 3. 检查 Pillow
if ! "$PYTHON" -c "from PIL import Image" 2>/dev/null; then
    install_pillow "$PYTHON"
fi
log "Pillow ✓"

# 4. 解析参数
IMG="$1"
MAX_H="${2:-5000}"

if [ -z "$IMG" ]; then
    echo ""
    echo "========================================"
    echo "  切图工具 — 按高度纵向切割图片"
    echo "========================================"
    echo ""
    echo "用法:"
    echo "  ./run.sh <图片路径> [最大高度]"
    echo ""
    echo "示例:"
    echo "  ./run.sh screenshot.png"
    echo "  ./run.sh long_page.jpg 3000"
    echo ""
    echo "也可以把图片文件直接拖到这个窗口里，回车即可。"
    echo ""
    read -rp "请输入图片路径: " IMG
    if [ -z "$IMG" ]; then
        echo "未输入图片路径，退出。"
        exit 1
    fi
    read -rp "每片最大高度(px, 默认5000): " MAX_H
    MAX_H="${MAX_H:-5000}"
fi

# 去掉 macOS 拖拽可能带的引号
IMG="${IMG//\'/}"
IMG="${IMG//\"/}"

# 5. 运行切图
export PYTHONIOENCODING=utf-8
"$PYTHON" "$SCRIPT_DIR/slice.py" "$IMG" --max-height "$MAX_H"
