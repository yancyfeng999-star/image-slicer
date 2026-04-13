@echo off
chcp 65001 >nul 2>&1
title 切图工具
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "LOG_PREFIX=[切图工具]"

echo %LOG_PREFIX% 启动...

REM ──────────────────────────────────────────
REM 查找 Python
REM ──────────────────────────────────────────
:find_python
set "PYTHON="

REM 按优先级尝试
where python >nul 2>&1 && set "PYTHON=python"
if not defined PYTHON where python3 >nul 2>&1 && set "PYTHON=python3"

REM 尝试常见安装路径
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

REM ──────────────────────────────────────────
REM 安装 Python (通过 winget)
REM ──────────────────────────────────────────
:install_python
echo.
echo %LOG_PREFIX% 未检测到 Python，开始自动安装...

REM 检查 winget
where winget >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %LOG_PREFIX% 正在通过 winget 安装 Python...
    winget install --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
    if %ERRORLEVEL% EQU 0 (
        echo %LOG_PREFIX% Python 安装成功 ✓
        goto :refresh_and_find
    ) else (
        echo %LOG_PREFIX% winget 安装失败，尝试备用方案...
    )
)

REM 备用: PowerShell 下载安装
echo %LOG_PREFIX% 正在通过 PowerShell 下载 Python 安装包...

set "PY_INSTALLER=%TEMP%\python_installer.exe"

REM 获取最新 Python 3.12 下载链接
powershell -Command ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
     $url = 'https://www.python.org/ftp/python/3.12.9/python-3.12.9-amd64.exe'; ^
     Write-Host '下载中: ' $url; ^
     Invoke-WebRequest -Uri $url -OutFile '%PY_INSTALLER%'" 2>nul

if not exist "%PY_INSTALLER%" (
    echo.
    echo %LOG_PREFIX% ✗ 自动下载失败。
    echo.
    echo 请手动安装 Python:
    echo   1. 打开 https://python.org/downloads
    echo   2. 下载并安装 Python
    echo   3. 安装时务必勾选 "Add Python to PATH"
    echo   4. 安装完成后重新运行本脚本
    echo.
    pause
    exit /b 1
)

echo %LOG_PREFIX% 正在静默安装 Python...
"%PY_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
if %ERRORLEVEL% NEQ 0 (
    echo %LOG_PREFIX% 安装可能需要管理员权限，正在尝试带 UAC 提权...
    powershell -Command "Start-Process '%PY_INSTALLER%' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Verb RunAs -Wait"
)

del "%PY_INSTALLER%" >nul 2>&1

:refresh_and_find
REM 刷新 PATH
set "PATH=%PATH%;%LocalAppData%\Programs\Python\Python312;%LocalAppData%\Programs\Python\Python312\Scripts;%ProgramFiles%\Python312;%ProgramFiles%\Python312\Scripts"

REM 重新查找
call :find_python
if not defined PYTHON (
    echo.
    echo %LOG_PREFIX% Python 安装后仍无法识别，请重启终端后重新运行本脚本。
    pause
    exit /b 1
)
goto :eof

REM ──────────────────────────────────────────
REM 安装 Pillow
REM ──────────────────────────────────────────
:install_pillow
echo %LOG_PREFIX% 正在安装 Pillow (图片处理库)...
%PYTHON% -m pip install --quiet --disable-pip-version-check Pillow >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    %PYTHON% -m pip install --user --quiet --disable-pip-version-check Pillow >nul 2>&1
)
if %ERRORLEVEL% NEQ 0 (
    echo %LOG_PREFIX% Pillow 安装失败，请手动运行: %PYTHON% -m pip install Pillow
    pause
    exit /b 1
)
echo %LOG_PREFIX% Pillow 安装成功 ✓
goto :eof

REM ══════════════════════════════════════════
REM  主流程
REM ══════════════════════════════════════════

REM 1. 查找 Python
call :find_python

REM 2. 没找到就安装
if not defined PYTHON (
    call :install_python
)

if not defined PYTHON (
    echo.
    echo %LOG_PREFIX% ✗ 无法找到或安装 Python，请手动处理。
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('%PYTHON% --version 2^>^&1') do set "PYVER=%%v"
echo %LOG_PREFIX% Python: %PYVER% ✓

REM 3. 检查 Pillow
%PYTHON% -c "from PIL import Image" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    call :install_pillow
) else (
    echo %LOG_PREFIX% Pillow ✓
)

REM 4. 解析参数
set "IMG=%~1"
set "MAX_H=%~2"
if "%MAX_H%"=="" set "MAX_H=5000"

if "%IMG%"=="" (
    echo.
    echo ========================================
    echo   切图工具 — 按高度纵向切割图片
    echo ========================================
    echo.
    echo 用法:
    echo   run.bat ^<图片路径^> [最大高度]
    echo.
    echo 示例:
    echo   run.bat screenshot.png
    echo   run.bat long_page.jpg 3000
    echo.
    echo 也可以把图片文件直接拖到这个窗口里，回车即可。
    echo.
    set /p "IMG=请输入图片路径: "
    if "!IMG!"=="" (
        echo 未输入图片路径，退出。
        pause
        exit /b 1
    )
    set /p "MAX_H=每片最大高度(px, 默认5000): "
    if "!MAX_H!"=="" set "MAX_H=5000"
)

REM 5. 运行切图
echo.
%PYTHON% "%SCRIPT_DIR%slice.py" "%IMG%" --max-height %MAX_H%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo %LOG_PREFIX% 运行出错，请检查上方错误信息。
)

pause
