# 切图工具 - PowerShell 启动器
# 用法: 双击 run.cmd 或 PowerShell 中运行 .\run.ps1
# 支持拖拽文件到窗口

param(
    [string]$Image,
    [int]$MaxHeight = 5000
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Log { param([string]$Msg) Write-Host "[*] $Msg" }

# ── 查找 Python ──
function Find-Python {
    # 先试命令
    foreach ($c in @("python3", "python")) {
        try {
            $null = & $c --version 2>&1
            if ($LASTEXITCODE -eq 0) { return $c }
        } catch {}
    }
    # 再试常见安装路径
    foreach ($p in @(
        "$env:LocalAppData\Programs\Python\Python312\python.exe",
        "$env:LocalAppData\Programs\Python\Python311\python.exe",
        "$env:LocalAppData\Programs\Python\Python310\python.exe",
        "${env:ProgramFiles}\Python312\python.exe",
        "${env:ProgramFiles}\Python311\python.exe"
    )) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# ── 安装 Python ──
function Install-Python {
    Write-Host ""
    Write-Host "[!] 未检测到 Python，正在安装..."
    Write-Host ""

    # 尝试 winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Log "正在通过 winget 安装 Python..."
        winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Log "Python 安装成功"
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
            return $true
        }
        Log "winget 安装失败，尝试下载安装..."
    }

    # 备用: 下载安装包
    $installer = "$env:TEMP\python_installer.exe"
    Log "正在下载 Python 安装包（可能需要几分钟）..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" -OutFile $installer
    } catch {
        Write-Host "[X] 下载失败: $_"
        return $false
    }

    if (-not (Test-Path $installer)) {
        Write-Host "[X] 下载失败"
        return $false
    }

    Log "正在安装 Python（需要管理员权限）..."
    Start-Process -FilePath $installer -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -Verb RunAs
    Remove-Item $installer -ErrorAction SilentlyContinue
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    return $true
}

# ── 安装 Pillow ──
function Install-Pillow {
    param([string]$PythonExe)

    Log "正在安装 Pillow（图片处理库）..."
    $result = & $PythonExe -m pip install Pillow 2>&1
    if ($LASTEXITCODE -eq 0) {
        Log "Pillow 安装成功"
        return $true
    }

    Log "重试（--user 模式）..."
    $result = & $PythonExe -m pip install --user Pillow 2>&1
    if ($LASTEXITCODE -eq 0) {
        Log "Pillow 安装成功"
        return $true
    }

    Write-Host "[X] Pillow 安装失败"
    Write-Host "    可以手动执行: $PythonExe -m pip install Pillow"
    return $false
}

# ════════════════════════════════════════
#  主流程
# ════════════════════════════════════════

Write-Host "========================================"
Write-Host "  切图工具"
Write-Host "  纵向切割长图，每 ${MaxHeight}px 一刀"
Write-Host "========================================"
Write-Host ""

# 1. 查找或安装 Python
$python = Find-Python
if (-not $python) {
    $ok = Install-Python
    if (-not $ok) {
        Write-Host ""
        Write-Host "请手动安装 Python:"
        Write-Host "  1. 打开 https://python.org/downloads"
        Write-Host "  2. 下载并安装 Python"
        Write-Host "  3. 安装时勾选 [Add Python to PATH]"
        Write-Host "  4. 重新运行本脚本"
        Write-Host ""
        Read-Host "按回车退出"
        return
    }
    $python = Find-Python
    if (-not $python) {
        Write-Host "[X] Python 安装后仍未找到，请重启终端后重试"
        Read-Host "按回车退出"
        return
    }
}

$ver = & $python --version 2>&1
Log "Python: $ver"

# 2. 检测 / 安装 Pillow
Log "正在检测 Pillow..."
$pillowOk = $false
try {
    & $python -c "from PIL import Image" 2>$null
    if ($LASTEXITCODE -eq 0) { $pillowOk = $true }
} catch {}

if (-not $pillowOk) {
    $pillowOk = Install-Pillow -PythonExe $python
    if (-not $pillowOk) {
        Read-Host "按回车退出"
        return
    }
} else {
    Log "Pillow 已就绪"
}

# 3. 获取图片路径
if (-not $Image) {
    Write-Host ""
    Write-Host "请输入图片路径（可以拖拽文件到此窗口）:"
    Write-Host ""
    $Image = Read-Host "图片路径"
    if (-not $Image) {
        Write-Host "未输入图片路径，退出。"
        Read-Host "按回车退出"
        return
    }
    $h = Read-Host "每片最大高度（默认 5000px，直接回车）"
    if ($h) { $MaxHeight = [int]$h }
}

# 去掉拖拽带的引号
$Image = $Image.Trim('"').Trim("'")

# 4. 运行切图
Write-Host ""
& $python "$ScriptDir\slice.py" $Image --max-height $MaxHeight

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] 运行出错，请检查上方错误信息"
}

Write-Host ""
Read-Host "按回车退出"
