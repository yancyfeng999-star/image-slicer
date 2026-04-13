@echo off
title Image Slicer
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"

REM =========================================
REM  Find Python
REM =========================================
:find_python
set "PYTHON="

where python >nul 2>&1 && set "PYTHON=python"
if not defined PYTHON where python3 >nul 2>&1 && set "PYTHON=python3"

if not defined PYTHON (
    for /d %%d in ("%LocalAppData%\Programs\Python\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)
if not defined PYTHON (
    for /d %%d in ("C:\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)
if not defined PYTHON (
    for /d %%d in ("%ProgramFiles%\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)
if not defined PYTHON (
    for /d %%d in ("%ProgramFiles(x86)%\Python3*") do (
        if exist "%%d\python.exe" set "PYTHON=%%d\python.exe"
    )
)
if not defined PYTHON (
    if exist "%LocalAppData%\Microsoft\WindowsApps\python3.exe" (
        set "PYTHON=%LocalAppData%\Microsoft\WindowsApps\python3.exe"
    )
)
goto :eof

REM =========================================
REM  Install Python
REM =========================================
:install_python
echo.
echo [*] Python not found. Installing...

where winget >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [*] Installing via winget...
    winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
    if %ERRORLEVEL% EQU 0 (
        echo [*] Python installed.
        goto :refresh_and_find
    ) else (
        echo [*] winget failed, trying PowerShell...
    )
)

echo [*] Downloading Python...
set "PY_INSTALLER=%TEMP%\python_installer.exe"

powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe' -OutFile '%PY_INSTALLER%'" 2>nul

if not exist "%PY_INSTALLER%" (
    echo.
    echo [X] Download failed.
    echo.
    echo Please install Python manually:
    echo   1. Open https://python.org/downloads
    echo   2. Download and install Python
    echo   3. CHECK "Add Python to PATH" during install
    echo   4. Re-run this script
    echo.
    pause
    exit /b 1
)

echo [*] Running installer...
"%PY_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
if %ERRORLEVEL% NEQ 0 (
    echo [*] Trying with UAC elevation...
    powershell -Command "Start-Process '%PY_INSTALLER%' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Verb RunAs -Wait"
)

del "%PY_INSTALLER%" >nul 2>&1

:refresh_and_find
set "PATH=%PATH%;%LocalAppData%\Programs\Python\Python312;%LocalAppData%\Programs\Python\Python312\Scripts;%ProgramFiles%\Python312;%ProgramFiles%\Python312\Scripts"

call :find_python
if not defined PYTHON (
    echo.
    echo [X] Python still not found. Please restart terminal and retry.
    pause
    exit /b 1
)
goto :eof

REM =========================================
REM  Install Pillow
REM =========================================
:install_pillow
echo [*] Installing Pillow...
%PYTHON% -m pip install --quiet --disable-pip-version-check Pillow >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    %PYTHON% -m pip install --user --quiet --disable-pip-version-check Pillow >nul 2>&1
)
if %ERRORLEVEL% NEQ 0 (
    echo [X] Pillow install failed. Try: %PYTHON% -m pip install Pillow
    pause
    exit /b 1
)
echo [*] Pillow installed.
goto :eof

REM =========================================
REM  Main
REM =========================================

REM 1. Find or install Python
call :find_python

if not defined PYTHON (
    call :install_python
)

if not defined PYTHON (
    echo.
    echo [X] Cannot find or install Python.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('%PYTHON% --version 2^>^&1') do set "PYVER=%%v"
echo [*] Python: %PYVER%

REM 2. Check Pillow
%PYTHON% -c "from PIL import Image" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :install_pillow
) else (
    echo [*] Pillow OK
)

REM 3. Parse args
set "IMG=%~1"
set "MAX_H=%~2"
if "%MAX_H%"=="" set "MAX_H=5000"

if "%IMG%"=="" (
    echo.
    echo ========================================
    echo   Image Slicer
    echo ========================================
    echo.
    echo Usage:
    echo   run.bat ^<image_path^> [max_height]
    echo.
    echo Example:
    echo   run.bat screenshot.png
    echo   run.bat long_page.jpg 3000
    echo.
    echo You can also drag and drop an image file here.
    echo.
    set /p "IMG=Enter image path: "
    if "!IMG!"=="" (
        echo No image path entered. Exiting.
        pause
        exit /b 1
    )
    set /p "MAX_H=Max height per slice (default 5000): "
    if "!MAX_H!"=="" set "MAX_H=5000"
)

REM 4. Run
echo.
%PYTHON% "%SCRIPT_DIR%slice.py" "%IMG%" --max-height %MAX_H%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [X] Error occurred. Check messages above.
)

pause
