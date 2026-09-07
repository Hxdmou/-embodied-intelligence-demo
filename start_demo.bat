@echo off
setlocal enabledelayedexpansion
title 机械臂智能控制演示（便携版）
pushd "%~dp0"

rem ===== 所有路径基于本bat所在目录，U盘换盘符也能跑 =====
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "PYEXE=%ROOT%\python\python.exe"
set "PYTHONNOUSERSITE=1"
set "PYTHONIOENCODING=utf-8"

echo ==============================================================
echo           机械臂智能控制演示 v1.0（便携版）
echo ==============================================================
echo.

echo [1/3] 检查 Ollama 服务（本地大模型）...
"%SystemRoot%\System32\curl.exe" -f -s -o nul --connect-timeout 2 http://127.0.0.1:11434/api/tags >nul 2>&1
if errorlevel 1 (
    echo       未检测到 Ollama，正在启动便携版...
    set "OLLAMA_MODELS=%LOCALAPPDATA%\ollama_models"
    if not exist "!OLLAMA_MODELS!\blobs\sha256-a3de86cd1c132c822487ededd47a324c50491393e6565cd14bafa40d0b8e686f" (
        echo       [提示] 本机尚未合并大模型，请先运行【合并模型到本机.bat】。
        pause
        exit /b 1
    )
    start "" /B "%ROOT%\ollama\ollama.exe" serve
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
) else (
    echo       Ollama 已在运行。
)

echo [2/3] 进入演示目录...
cd /d "%ROOT%\embodied-intelligence"

echo [3/3] 启动机械臂 GUI...
echo.
echo 鼠标: 左键=旋转 右键=平移 滚轮=缩放
echo 按键: H=回零 R=复位 C=复位视角 ESC=退出
echo.

"%PYEXE%" demo_robot_gui.py

echo.
echo 演示已退出。
pause
