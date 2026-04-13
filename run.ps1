# Image Slicer - PowerShell launcher
# Usage: double-click run.vbs or run in PowerShell: .\run.ps1
# Supports drag-and-drop

param(
    [string]$Image,
    [int]$MaxHeight = 5000
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Log { param([string]$Msg) Write-Host "[*] $Msg" }

# -- Find Python --
function Find-Python {
    foreach ($c in @("python3", "python")) {
        try {
            $null = & $c --version 2>&1
            if ($LASTEXITCODE -eq 0) { return $c }
        } catch {}
    }
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

# -- Install Python --
function Install-Python {
    Write-Host ""
    Write-Host "[!] Python not found. Installing..."
    Write-Host ""

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Log "Installing Python via winget..."
        winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Log "Python installed."
            $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
            return $true
        }
        Log "winget failed, trying download..."
    }

    $installer = "$env:TEMP\python_installer.exe"
    Log "Downloading Python (may take a few minutes)..."
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

    Log "Running installer (needs admin)..."
    Start-Process -FilePath $installer -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1" -Wait -Verb RunAs
    Remove-Item $installer -ErrorAction SilentlyContinue
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
    return $true
}

# -- Install Pillow --
function Install-Pillow {
    param([string]$PythonExe)

    Log "Installing Pillow..."
    & $PythonExe -m pip install Pillow 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Log "Pillow installed."
        return $true
    }

    Log "Retrying with --user..."
    & $PythonExe -m pip install --user Pillow 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Log "Pillow installed."
        return $true
    }

    Write-Host "[X] Pillow install failed."
    Write-Host "    Try manually: $PythonExe -m pip install Pillow"
    return $false
}

# ==========================================
#  Main
# ==========================================

Write-Host "========================================"
Write-Host "  Image Slicer"
Write-Host "  Split long images every $MaxHeight px"
Write-Host "========================================"
Write-Host ""

# 1. Find or install Python
$python = Find-Python
if (-not $python) {
    $ok = Install-Python
    if (-not $ok) {
        Write-Host ""
        Write-Host "Install Python manually:"
        Write-Host "  1. Open https://python.org/downloads"
        Write-Host "  2. Download and install Python"
        Write-Host "  3. CHECK 'Add Python to PATH' during install"
        Write-Host "  4. Re-run this script"
        Write-Host ""
        Read-Host "Press Enter to exit"
        return
    }
    $python = Find-Python
    if (-not $python) {
        Write-Host "[X] Python installed but not found. Restart terminal and retry."
        Read-Host "Press Enter to exit"
        return
    }
}

$ver = & $python --version 2>&1
Log "Python: $ver"

# 2. Check / install Pillow
Log "Checking Pillow..."
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
    Log "Pillow OK"
}

# 3. Get image path
if (-not $Image) {
    Write-Host ""
    Write-Host "Enter image path (or drag file here):"
    Write-Host ""
    $Image = Read-Host "Image path"
    if (-not $Image) {
        Write-Host "No input. Exiting."
        Read-Host "Press Enter to exit"
        return
    }
    $h = Read-Host "Max height per slice (default 5000, press Enter)"
    if ($h) { $MaxHeight = [int]$h }
}

# Strip quotes from drag-and-drop
$Image = $Image.Trim('"').Trim("'")

# 4. Run slicer
Write-Host ""
& $python "$ScriptDir\slice.py" $Image --max-height $MaxHeight

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[X] Error occurred. Check messages above."
}

Write-Host ""
Read-Host "Press Enter to exit"
