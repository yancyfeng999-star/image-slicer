# Image Slicer - PowerShell launcher
# Usage: .\run.ps1 <image_path> [max_height]
# Right-click this file -> "Run with PowerShell"
# Or in PowerShell: .\run.ps1 image.png 5000

param(
    [string]$Image,
    [int]$MaxHeight = 5000
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Log { param([string]$Msg) Write-Host "[*] $Msg" }

# ── Find Python ──
function Find-Python {
    $candidates = @(
        "python3",
        "python",
        "$env:LocalAppData\Programs\Python\Python312\python.exe",
        "$env:LocalAppData\Programs\Python\Python311\python.exe",
        "${env:ProgramFiles}\Python312\python.exe",
        "${env:ProgramFiles}\Python311\python.exe"
    )
    foreach ($c in $candidates) {
        try {
            $null = & $c --version 2>&1
            if ($LASTEXITCODE -eq 0 -or $?) { return $c }
        } catch {}
    }
    return $null
}

# ── Install Python ──
function Install-Python {
    Write-Host ""
    Write-Host "[X] Python not found."
    Write-Host ""

    # Try winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[*] Installing Python via winget..."
        winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[*] Python installed. You may need to restart PowerShell."
            return $true
        }
    }

    # Fallback: download
    Write-Host "[*] Downloading Python installer..."
    $installer = "$env:TEMP\python_installer.exe"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe" -OutFile $installer
    } catch {
        Write-Host "[X] Download failed."
        Show-Manual
        return $false
    }

    Write-Host "[*] Running installer (this may take a minute)..."
    Start-Process -FilePath $installer -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -Verb RunAs
    Remove-Item $installer -ErrorAction SilentlyContinue

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    return $true
}

function Show-Manual {
    Write-Host "Please install Python manually:"
    Write-Host "  1. Open https://python.org/downloads"
    Write-Host "  2. Download and install Python"
    Write-Host "  3. CHECK 'Add Python to PATH' during install"
    Write-Host "  4. Re-run this script"
    Write-Host ""
    Write-Host "Or use winget:"
    Write-Host "  winget install Python.Python.3.12"
}

# ── Main ──
Write-Host "========================================"
Write-Host "  Image Slicer"
Write-Host "========================================"
Write-Host ""

# Find or install Python
$python = Find-Python
if (-not $python) {
    $ok = Install-Python
    if (-not $ok) { Read-Host "Press Enter to exit"; exit 1 }
    $python = Find-Python
    if (-not $python) {
        Write-Host "[X] Python still not found. Restart PowerShell and retry."
        Read-Host "Press Enter to exit"; exit 1
    }
}

$ver = & $python --version 2>&1
Write-Log "Python: $ver"

# Check Pillow
Write-Log "Checking Pillow..."
& $python -c "from PIL import Image" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Log "Installing Pillow..."
    & $python -m pip install --quiet Pillow
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[X] Pillow install failed."
        & $python -m pip install Pillow
        Read-Host "Press Enter to exit"; exit 1
    }
    Write-Log "Pillow installed."
} else {
    Write-Log "Pillow OK"
}

# Get image path
if (-not $Image) {
    Write-Host ""
    Write-Host "Drag and drop an image file here, or type the path:"
    Write-Host ""
    $Image = Read-Host "Image path"
    if (-not $Image) {
        Write-Host "No input. Exiting."
        Read-Host "Press Enter to exit"; exit 1
    }
    $h = Read-Host "Max height per slice (default 5000)"
    if ($h) { $MaxHeight = [int]$h }
}

# Strip quotes from drag-and-drop
$Image = $Image.Trim('"').Trim("'")

# Run
Write-Host ""
& $python "$ScriptDir\slice.py" $Image --max-height $MaxHeight
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] Error occurred."
}

Write-Host ""
Read-Host "Press Enter to exit"
