# Image Slicer - PowerShell launcher
# Usage: .\run.ps1 <image_path> [max_height]
# Right-click -> "Run with PowerShell"
# Or: powershell -NoExit -ExecutionPolicy Bypass -File run.ps1

param(
    [string]$Image,
    [int]$MaxHeight = 5000
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log { param([string]$Msg) Write-Host "[*] $Msg" }

# ── Find Python ──
function Find-Python {
    $candidates = @("python3", "python")
    foreach ($c in $candidates) {
        try {
            $ver = & $c --version 2>&1
            if ($LASTEXITCODE -eq 0) { return $c }
        } catch {}
    }
    # Check common install paths
    $paths = @(
        "$env:LocalAppData\Programs\Python\Python312\python.exe",
        "$env:LocalAppData\Programs\Python\Python311\python.exe",
        "$env:LocalAppData\Programs\Python\Python310\python.exe",
        "${env:ProgramFiles}\Python312\python.exe",
        "${env:ProgramFiles}\Python311\python.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# ── Install Python ──
function Install-Python {
    Write-Host ""
    Write-Host "[X] Python not found."
    Write-Host ""

    # Try winget
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "[*] Installing Python via winget..."
        $result = winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[*] Python installed."
            # Refresh PATH
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
            return $true
        }
        Write-Host "[*] winget failed, trying download..."
    }

    # Fallback: download
    $installer = "$env:TEMP\python_installer.exe"
    Write-Host "[*] Downloading Python (may take a minute)..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" -OutFile $installer
    } catch {
        Write-Host "[X] Download failed: $_"
        return $false
    }

    if (-not (Test-Path $installer)) {
        Write-Host "[X] Download failed."
        return $false
    }

    Write-Host "[*] Running installer..."
    Start-Process -FilePath $installer -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -Verb RunAs
    Remove-Item $installer -ErrorAction SilentlyContinue

    # Refresh PATH
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    return $true
}

# ── Install Pillow ──
function Install-Pillow {
    param([string]$PythonExe)

    Write-Host "[*] Installing Pillow..."

    # Try pip first
    $result = & $PythonExe -m pip install Pillow 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[*] Pillow installed."
        return $true
    }

    # Try pip with --user
    Write-Host "[*] Retrying with --user..."
    $result = & $PythonExe -m pip install --user Pillow 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[*] Pillow installed."
        return $true
    }

    Write-Host "[X] Pillow install failed."
    Write-Host "[*] You can try manually: $PythonExe -m pip install Pillow"
    return $false
}

# ══════════════════════════════════════════
#  Main
# ══════════════════════════════════════════

Write-Host "========================================"
Write-Host "  Image Slicer"
Write-Host "========================================"
Write-Host ""

# 1. Find or install Python
$python = Find-Python
if (-not $python) {
    $ok = Install-Python
    if (-not $ok) {
        Write-Host ""
        Write-Host "Please install Python manually:"
        Write-Host "  https://python.org/downloads"
        Write-Host "  CHECK 'Add Python to PATH' during install"
        Write-Host ""
        Read-Host "Press Enter to exit"
        return
    }
    $python = Find-Python
    if (-not $python) {
        Write-Host "[X] Python installed but not found."
        Write-Host "[*] Restart PowerShell and retry."
        Read-Host "Press Enter to exit"
        return
    }
}

$ver = & $python --version 2>&1
Write-Log "Python: $ver"

# 2. Check / install Pillow
Write-Log "Checking Pillow..."
$pillowOk = $false
try {
    & $python -c "from PIL import Image" 2>$null
    if ($LASTEXITCODE -eq 0) { $pillowOk = $true }
} catch {}

if (-not $pillowOk) {
    $pillowOk = Install-Pillow -PythonExe $python
    if (-not $pillowOk) {
        Read-Host "Press Enter to exit"
        return
    }
} else {
    Write-Log "Pillow OK"
}

# 3. Get image path
if (-not $Image) {
    Write-Host ""
    Write-Host "Drag and drop an image file here, or type the path:"
    Write-Host ""
    $Image = Read-Host "Image path"
    if (-not $Image) {
        Write-Host "No input. Exiting."
        Read-Host "Press Enter to exit"
        return
    }
    $h = Read-Host "Max height per slice (default 5000)"
    if ($h) { $MaxHeight = [int]$h }
}

# Strip quotes from drag-and-drop
$Image = $Image.Trim('"').Trim("'")

# 4. Run slicer
Write-Host ""
& $python "$ScriptDir\slice.py" $Image --max-height $MaxHeight

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] Error occurred."
}

Write-Host ""
Read-Host "Press Enter to exit"
