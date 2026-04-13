@echo off
chcp 437 >nul 2>&1
title Image Slicer
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PYTHON="

REM ---- Find Python ----
where python.exe >nul 2>&1 && set "PYTHON=python.exe"
if not defined PYTHON where python3.exe >nul 2>&1 && set "PYTHON=python3.exe"

if not defined PYTHON (
    for /d %%d in ("%LocalAppData%\Programs\Python\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)
if not defined PYTHON (
    for /d %%d in ("%ProgramFiles%\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)

if not defined PYTHON (
    echo.
    echo [X] Python not found.
    echo.
    echo Install Python:
    echo   1. Open https://python.org/downloads
    echo   2. Download and install Python
    echo   3. CHECK "Add Python to PATH" during install
    echo   4. Re-run this script
    echo.
    echo Or use winget:
    echo   winget install Python.Python.3.12
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('"%PYTHON%" --version 2^>^&1') do set "PYVER=%%v"
echo [*] Python: %PYVER%

REM ---- Check / Install Pillow ----
"%PYTHON%" -c "from PIL import Image" >nul 2>&1
if errorlevel 1 (
    echo [*] Installing Pillow...
    "%PYTHON%" -m pip install --quiet Pillow
    if errorlevel 1 (
        echo [X] Pillow install failed.
        echo     Try: %PYTHON% -m pip install Pillow
        pause
        exit /b 1
    )
    echo [*] Pillow installed.
) else (
    echo [*] Pillow OK
)

REM ---- Get input ----
set "IMG=%~1"
set "MAX_H=%~2"
if "%MAX_H%"=="" set "MAX_H=5000"

if "%IMG%"=="" (
    echo.
    echo ========================================
    echo   Image Slicer
    echo ========================================
    echo.
    set /p "IMG=Enter image path: "
    if "!IMG!"=="" (
        echo No input. Exiting.
        pause
        exit /b 1
    )
    set /p "MAX_H=Max height per slice (default 5000): "
    if "!MAX_H!"=="" set "MAX_H=5000"
)

REM ---- Run ----
echo.
"%PYTHON%" "%SCRIPT_DIR%slice.py" "!IMG!" --max-height !MAX_H!
if errorlevel 1 (
    echo.
    echo [X] Error occurred.
)

echo.
pause
