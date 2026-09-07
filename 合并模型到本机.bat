@echo off
setlocal enabledelayedexpansion
title 合并大模型到本机（首次使用必跑一次）
pushd "%~dp0"

rem ===== 所有路径基于本bat所在目录，U盘换盘符也能跑 =====
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "SRC=%ROOT%\ollama\models"
set "TARGET=%LOCALAPPDATA%\ollama_models"
set "BLOB=sha256-a3de86cd1c132c822487ededd47a324c50491393e6565cd14bafa40d0b8e686f"

echo ==============================================================
echo    合并大模型文件到本机（qwen3:8b，4.87GB）
echo ==============================================================
echo.
echo 说明：U盘是FAT32格式，单个文件不能超过4GB，
echo       所以大模型被拆成2个分卷存放。
echo       本脚本把分卷合并到本机硬盘，只需运行一次。
echo.

if exist "%TARGET%\blobs\%BLOB%" (
    echo 检测到本机已存在合并后的模型，无需重复合并。
    echo 路径: %TARGET%\blobs\%BLOB%
    echo.
    pause
    exit /b 0
)

rem ===== 检查分卷是否存在 =====
if not exist "%SRC%\blobs\qwen3_8b.part1" (
    echo [错误] 未找到分卷1: %SRC%\blobs\qwen3_8b.part1
    pause
    exit /b 1
)
if not exist "%SRC%\blobs\qwen3_8b.part2" (
    echo [错误] 未找到分卷2: %SRC%\blobs\qwen3_8b.part2
    pause
    exit /b 1
)

echo [1/4] 创建目录结构...
mkdir "%TARGET%\blobs" 2>nul
mkdir "%TARGET%\manifests\registry.ollama.ai\library\qwen3" 2>nul

echo [2/4] 复制小文件（配置/模板/许可/参数/清单）...
copy /y "%SRC%\blobs\sha256-05a61d37b08453e59290add468e3bb2f688e23a01e967fecb0e2fa41218cea76" "%TARGET%\blobs\" >nul
copy /y "%SRC%\blobs\sha256-ae370d884f108d16e7cc8fd5259ebc5773a0afa6e078b11f4ed7e39a27e0dfc4" "%TARGET%\blobs\" >nul
copy /y "%SRC%\blobs\sha256-d18a5cc71b84bc4af394a31116bd3932b42241de70c77d2b76d69a314ec8aa12" "%TARGET%\blobs\" >nul
copy /y "%SRC%\blobs\sha256-cff3f395ef3756ab63e58b0ad1b32bb6f802905cae1472e6a12034e4246fbbdb" "%TARGET%\blobs\" >nul
copy /y "%SRC%\manifests\registry.ollama.ai\library\qwen3\8b" "%TARGET%\manifests\registry.ollama.ai\library\qwen3\" >nul

echo [3/4] 合并大模型分卷（约4.87GB，请耐心等待1-3分钟）...
copy /b "%SRC%\blobs\qwen3_8b.part1" + "%SRC%\blobs\qwen3_8b.part2" "%TARGET%\blobs\%BLOB%" >nul
if errorlevel 1 (
    echo [错误] 合并失败，请检查本机磁盘剩余空间是否≥6GB。
    pause
    exit /b 1
)

echo [4/4] 校验文件大小...
for %%F in ("%TARGET%\blobs\%BLOB%") do set "FSIZE=%%~zF"
if "!FSIZE!"=="5225374496" (
    echo 校验通过：5225374496 字节，模型完整。
) else (
    echo [错误] 大小不符：!FSIZE! 字节（应为5225374496）。
    echo        请删除 %TARGET%\blobs\%BLOB% 后重新运行本脚本。
    pause
    exit /b 1
)

echo.
echo ==============================================================
echo  合并完成！模型位置: %TARGET%
echo  现在可以运行【一键启动RAG系统.bat】或【Demo启动菜单.bat】。
echo ==============================================================
echo.
pause
