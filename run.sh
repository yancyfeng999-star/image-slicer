#!/bin/bash
# Image Slicer - macOS / Linux launcher
# Usage: ./run.sh <image_path> [max_height]
# Auto-detects and installs Python + Pillow if missing.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log()  { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
die()  { echo "[X] $*" >&2; exit 1; }

# ──────────────────────────────────────────
# Detect OS
# ──────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin*)  echo "macos" ;;
        Linux*)   echo "linux" ;;
        *)        echo "unknown" ;;
    esac
}

# ──────────────────────────────────────────
# Detect package manager
# ──────────────────────────────────────────
detect_pkg_manager() {
    if command -v brew &>/dev/null; then echo "brew"; return; fi
    if command -v apt-get &>/dev/null; then echo "apt"; return; fi
    if command -v dnf &>/dev/null; then echo "dnf"; return; fi
    if command -v yum &>/dev/null; then echo "yum"; return; fi
    if command -v pacman &>/dev/null; then echo "pacman"; return; fi
    if command -v apk &>/dev/null; then echo "apk"; return; fi
    if command -v zypper &>/dev/null; then echo "zypper"; return; fi
    echo "none"
}

# ──────────────────────────────────────────
# Install Homebrew (macOS)
# ──────────────────────────────────────────
install_homebrew() {
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
    if [ -d "/opt/homebrew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    log "Homebrew installed."
}

# ──────────────────────────────────────────
# Install Python
# ──────────────────────────────────────────
install_python() {
    local os="$1"
    local pkg_mgr="$2"

    log "Python not found. Installing..."

    case "$os" in
        macos)
            if [ "$pkg_mgr" != "brew" ]; then
                install_homebrew
                pkg_mgr="brew"
            fi
            log "Installing Python via Homebrew..."
            brew install python3
            ;;
        linux)
            case "$pkg_mgr" in
                apt)
                    log "Installing Python via apt..."
                    sudo apt-get update -qq
                    sudo apt-get install -y -qq python3 python3-pip python3-pil
                    ;;
                dnf)
                    log "Installing Python via dnf..."
                    sudo dnf install -y python3 python3-pip python3-pillow
                    ;;
                yum)
                    log "Installing Python via yum..."
                    sudo yum install -y python3 python3-pip
                    ;;
                pacman)
                    log "Installing Python via pacman..."
                    sudo pacman -Sy --noconfirm python python-pip python-pillow
                    ;;
                apk)
                    log "Installing Python via apk..."
                    sudo apk add --no-cache python3 py3-pip py3-pillow
                    ;;
                zypper)
                    log "Installing Python via zypper..."
                    sudo zypper install -y python3 python3-pip
                    ;;
                none)
                    die "No package manager found. Install Python manually: https://python.org/downloads"
                    ;;
            esac
            ;;
        *)
            die "Unsupported OS. Install Python manually: https://python.org/downloads"
            ;;
    esac

    log "Python installed."
}

# ──────────────────────────────────────────
# Find Python
# ──────────────────────────────────────────
find_python() {
    if [ -d "/opt/homebrew/bin" ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi

    for candidate in \
        python3 \
        python \
        /usr/bin/python3 \
        /usr/local/bin/python3 \
        /opt/homebrew/bin/python3 \
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
# Install Pillow
# ──────────────────────────────────────────
install_pillow() {
    local python="$1"
    log "Installing Pillow..."
    "$python" -m pip install --quiet --disable-pip-version-check Pillow 2>/dev/null \
        || "$python" -m pip3 install --quiet --disable-pip-version-check Pillow 2>/dev/null \
        || die "Pillow install failed. Try: $python -m pip install Pillow"
    log "Pillow installed."
}

# ──────────────────────────────────────────
# Main
# ──────────────────────────────────────────
log "Image Slicer starting..."

# 1. Detect OS
OS=$(detect_os)
PKG_MGR=$(detect_pkg_manager)
log "System: $OS | Package manager: $PKG_MGR"

# 2. Find or install Python
PYTHON=$(find_python || true)

if [ -z "$PYTHON" ]; then
    install_python "$OS" "$PKG_MGR"
    PYTHON=$(find_python) || die "Python installed but not found. Restart terminal and retry."
    "$PYTHON" -m ensurepip --default-pip 2>/dev/null || true
fi

PYVER=$("$PYTHON" --version 2>&1)
log "Python: $PYTHON ($PYVER)"

# 3. Check Pillow
if ! "$PYTHON" -c "from PIL import Image" 2>/dev/null; then
    install_pillow "$PYTHON"
fi
log "Pillow OK"

# 4. Parse args
IMG="$1"
MAX_H="${2:-5000}"

if [ -z "$IMG" ]; then
    echo ""
    echo "========================================"
    echo "  Image Slicer"
    echo "========================================"
    echo ""
    echo "Usage:"
    echo "  ./run.sh <image_path> [max_height]"
    echo ""
    echo "Example:"
    echo "  ./run.sh screenshot.png"
    echo "  ./run.sh long_page.jpg 3000"
    echo ""
    echo "You can also drag and drop a file into this window."
    echo ""
    read -rp "Enter image path: " IMG
    if [ -z "$IMG" ]; then
        echo "No image path entered. Exiting."
        exit 1
    fi
    read -rp "Max height per slice (default 5000): " MAX_H
    MAX_H="${MAX_H:-5000}"
fi

# Strip quotes from drag-and-drop
IMG="${IMG//\'/}"
IMG="${IMG//\"/}"

# 5. Run
"$PYTHON" "$SCRIPT_DIR/slice.py" "$IMG" --max-height "$MAX_H"
