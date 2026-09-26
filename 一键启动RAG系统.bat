@echo off
setlocal enabledelayedexpansion

title 垂直领域企业级RAG智能问答系统 V3.1.0
cls
pushd "%~dp0"

rem ===== 所有路径基于本bat所在目录，U盘换盘符也能跑 =====
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

rem ===== 配置Ollama模型目录 =====
rem 优先用本机合并后的模型（FAT32 U盘放不下4.87GB完整模型）
set "OLLAMA_MODELS=%LOCALAPPDATA%\ollama_models"
if not exist "%OLLAMA_MODELS%\blobs\sha256-a3de86cd1c132c822487ededd47a324c50491393e6565cd14bafa40d0b8e686f" (
    echo.
    echo   [提示] 本机尚未合并大模型。
    echo   首次使用请先双击运行【合并模型到本机.bat】，完成后再启动本系统。
    echo.
    pause
    exit /b 1
)
set "OLLAMA_HOST=127.0.0.1:11434"

rem ===== 配置RAG系统使用本地Ollama后端 =====
set "LLM_BACKEND=ollama"
set "OLLAMA_BASE_URL=http://127.0.0.1:11434/v1"
set "OLLAMA_MODEL_NAME=qwen3:8b"

rem ===== 配置HuggingFace嵌入模型走U盘内离线缓存 =====
set "HF_HOME=%ROOT%\hf_cache"
set "HF_HUB_OFFLINE=1"
set "TRANSFORMERS_OFFLINE=1"
set "PYTHONIOENCODING=utf-8"

rem ===== 便携Python =====
set "PYEXE=%ROOT%\python\python.exe"

:menu
cls
echo.
echo ==============================================================
echo.
echo        垂直领域企业级RAG智能问答系统 V3.1.0
echo.
echo ==============================================================
echo.
echo   本系统使用本地 Ollama 大模型（qwen3:8b），无需联网、无需API Key。
echo.
echo   系统列表：
echo.
echo   [1]  通用RAG智能问答系统        (端口 7861)
echo   [2]  法律知识问答系统           (端口 7869)
echo   [3]  教育知识问答系统           (端口 7870)
echo   [4]  医疗健康问答系统           (端口 7871)
echo   [5]  金融知识问答系统           (端口 7872)
echo   [6]  IT技术问答系统             (端口 7873)
echo   [7]  电商零售问答系统           (端口 7874)
echo   [8]  政务服务问答系统           (端口 7875)
echo   [9]  人力资源问答系统           (端口 7876)
echo   [10] 科研学术问答系统           (端口 7877)
echo.
echo   [11] 一键启动全部10套系统 + 自动打开浏览器
echo   [0]  退出
echo.
echo ==============================================================
echo.
echo   当前目录: %CD%
echo.

set /p choice=  请输入选项编号: 

if "%choice%"=="0" goto end
if "%choice%"=="" goto end

rem ===== 检查便携Python =====
if not exist "%PYEXE%" (
    echo.
    echo   [错误] 未找到便携Python: %PYEXE%
    pause
    exit /b 1
)

rem ===== 启动Ollama服务（如未运行）=====
"%SystemRoot%\System32\curl.exe" -f -s -o nul --connect-timeout 2 http://127.0.0.1:11434/api/tags >nul 2>&1
if not errorlevel 1 goto ollama_ready

echo.
echo   正在启动本地大模型服务（Ollama）...
start "OllamaServer" /min "%ROOT%\ollama\ollama.exe" serve

set /a wait=0
:wait_ollama
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
set /a wait+=2
"%SystemRoot%\System32\curl.exe" -f -s -o nul --connect-timeout 2 http://127.0.0.1:11434/api/tags >nul 2>&1
if not errorlevel 1 goto ollama_ready
if !wait! GEQ 60 (
    echo.
    echo   [错误] Ollama服务60秒内未就绪，请检查电脑内存是否≥16GB。
    pause
    exit /b 1
)
goto wait_ollama

:ollama_ready
echo   本地大模型服务已就绪。

if "%choice%"=="11" goto start_all

echo.
echo   正在启动选中的系统...
echo.

if "%choice%"=="1" (
    start "通用RAG" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run run.py --server.port 7861 --server.headless true"
    set "url=http://localhost:7861"
    goto open_single
)
if "%choice%"=="2" (
    start "法律知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run legal_qa.py --server.port 7869 --server.headless true"
    set "url=http://localhost:7869"
    goto open_single
)
if "%choice%"=="3" (
    start "教育知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run education_qa.py --server.port 7870 --server.headless true"
    set "url=http://localhost:7870"
    goto open_single
)
if "%choice%"=="4" (
    start "医疗健康" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run medical_qa.py --server.port 7871 --server.headless true"
    set "url=http://localhost:7871"
    goto open_single
)
if "%choice%"=="5" (
    start "金融知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run finance_qa.py --server.port 7872 --server.headless true"
    set "url=http://localhost:7872"
    goto open_single
)
if "%choice%"=="6" (
    start "IT技术" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run tech_qa.py --server.port 7873 --server.headless true"
    set "url=http://localhost:7873"
    goto open_single
)
if "%choice%"=="7" (
    start "电商零售" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run e_commerce_qa.py --server.port 7874 --server.headless true"
    set "url=http://localhost:7874"
    goto open_single
)
if "%choice%"=="8" (
    start "政务服务" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run government_qa.py --server.port 7875 --server.headless true"
    set "url=http://localhost:7875"
    goto open_single
)
if "%choice%"=="9" (
    start "人力资源" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run hr_qa.py --server.port 7876 --server.headless true"
    set "url=http://localhost:7876"
    goto open_single
)
if "%choice%"=="10" (
    start "科研学术" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run academic_qa.py --server.port 7877 --server.headless true"
    set "url=http://localhost:7877"
    goto open_single
)

echo.
echo   无效选项，请重新输入。
pause
goto menu

:open_single
echo.
echo   等待服务启动（约15秒）...
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
echo   正在打开浏览器: !url!
start "" "!url!"
echo.
echo   完成！请勿关闭黑色的cmd窗口。
goto end

:start_all
echo.
echo   正在启动全部10套系统，请稍候...
echo.

echo   [1/10] 启动通用RAG智能问答系统 (端口 7861)...
start "通用RAG" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run run.py --server.port 7861 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [2/10] 启动法律知识问答系统 (端口 7869)...
start "法律知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run legal_qa.py --server.port 7869 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [3/10] 启动教育知识问答系统 (端口 7870)...
start "教育知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run education_qa.py --server.port 7870 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [4/10] 启动医疗健康问答系统 (端口 7871)...
start "医疗健康" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run medical_qa.py --server.port 7871 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [5/10] 启动金融知识问答系统 (端口 7872)...
start "金融知识" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run finance_qa.py --server.port 7872 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [6/10] 启动IT技术问答系统 (端口 7873)...
start "IT技术" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run tech_qa.py --server.port 7873 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [7/10] 启动电商零售问答系统 (端口 7874)...
start "电商零售" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run e_commerce_qa.py --server.port 7874 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [8/10] 启动政务服务问答系统 (端口 7875)...
start "政务服务" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run government_qa.py --server.port 7875 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [9/10] 启动人力资源问答系统 (端口 7876)...
start "人力资源" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run hr_qa.py --server.port 7876 --server.headless true"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   [10/10] 启动科研学术问答系统 (端口 7877)...
start "科研学术" cmd /k "cd /d "%ROOT%\app" && "%PYEXE%" -m streamlit run academic_qa.py --server.port 7877 --server.headless true"

echo.
echo   等待所有服务启动（约30秒）...
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul

echo   正在打开浏览器标签页...
echo.
start "" "http://localhost:7861"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7869"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7870"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7871"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7872"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7873"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7874"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7875"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7876"
"%SystemRoot%\System32\ping.exe" -n 3 127.0.0.1 >nul
start "" "http://localhost:7877"

echo.
echo ==============================================================
echo.
echo           全部10套系统启动完成！
echo.
echo ==============================================================
echo.
echo   访问地址：
echo      [1]  通用RAG智能问答系统:    http://localhost:7861
echo      [2]  法律知识问答系统:       http://localhost:7869
echo      [3]  教育知识问答系统:       http://localhost:7870
echo      [4]  医疗健康问答系统:       http://localhost:7871
echo      [5]  金融知识问答系统:       http://localhost:7872
echo      [6]  IT技术问答系统:         http://localhost:7873
echo      [7]  电商零售问答系统:       http://localhost:7874
echo      [8]  政务服务问答系统:       http://localhost:7875
echo      [9]  人力资源问答系统:       http://localhost:7876
echo      [10] 科研学术问答系统:       http://localhost:7877
echo.
echo   提示：关闭对应黑色cmd窗口即可停止该系统。
echo   若页面提示"拒绝连接"，请再等待10秒后刷新页面。
echo.

:end
echo.
pause
popd
