@echo off
chcp 65001 >nul

echo ========================================
echo IndexTTS-2 WebUI 启动脚本
echo ========================================
echo.

REM 设置 HuggingFace 镜像（可选，国内用户推荐）
set HF_ENDPOINT=https://hf-mirror.com

REM 自动添加 ffmpeg 到 PATH
REM 优先级：项目内 > Conda 环境 > 系统
for /d %%i in (ffmpeg\ffmpeg-*) do (
    if exist "%%i\bin\ffmpeg.exe" (
        set "PATH=%%i\bin;%PATH%"
        echo [信息] 已添加项目内 ffmpeg 到 PATH
        goto ffmpeg_found
    )
)

REM 检查 Conda 环境中的 ffmpeg
if exist "%USERPROFILE%\miniconda3\envs\IndexTTS\Library\bin\ffmpeg.exe" (
    set "PATH=%USERPROFILE%\miniconda3\envs\IndexTTS\Library\bin;%PATH%"
    echo [信息] 已添加 Conda 环境中的 ffmpeg 到 PATH
    goto ffmpeg_found
)

REM 检查系统是否已安装 ffmpeg
where ffmpeg >nul 2>&1
if %errorlevel% equ 0 (
    echo [信息] 使用系统已安装的 ffmpeg
    goto ffmpeg_found
)

echo [警告] 未检测到 ffmpeg，可能影响部分音频格式支持
echo [提示] 请运行"一键部署工具\一键部署.bat"安装 ffmpeg

:ffmpeg_found

REM 自动检测环境类型
if exist ".venv\" (
    echo [检测] UV 虚拟环境
    echo [1/2] 激活 UV 环境...
    call .venv\Scripts\activate.bat
    if %errorlevel% neq 0 (
        echo.
        echo [错误] 无法激活 UV 环境
        echo [提示] 请先运行"一键部署工具\一键部署.bat"进行部署
        echo.
        pause
        exit /b 1
    )
) else (
    echo [检测] Conda 虚拟环境
    echo [1/2] 激活 Conda 环境...
    call conda activate IndexTTS
    if %errorlevel% neq 0 (
        echo.
        echo [错误] 无法激活 IndexTTS 环境
        echo [提示] 请先运行"一键部署工具\一键部署.bat"进行部署
        echo.
        pause
        exit /b 1
    )
)

echo [2/2] 启动 WebUI...
echo.

REM 检测端口是否已被占用
netstat -an | find ":7860" | find "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo [警告] 端口 7860 已被占用，可能有其他 WebUI 实例正在运行
    echo [提示] 请先关闭其他实例，或在任务管理器中结束 python.exe 进程
    echo.
    pause
    exit /b 1
)

echo [信息] 正在加载模型，请稍候...
echo [提示] 首次运行会自动下载额外的小模型（约 500MB）
echo [提示] 浏览器将在 WebUI 启动后自动打开
echo [提示] 请保持此窗口打开，关闭窗口将停止 WebUI 服务
echo.

REM 后台启动端口检测任务（每秒检测一次，最多60秒）
start /b cmd /c "for /L %%i in (1,1,60) do (netstat -an | find ":7860" | find "LISTENING" >nul && start http://127.0.0.1:7860 && exit || timeout /t 1 /nobreak >nul)" >nul 2>&1

REM 在当前窗口启动 webui（前台阻塞运行）
python webui.py
set WEBUI_EXIT_CODE=%errorlevel%

echo.
echo ========================================
echo WebUI 已停止运行 (退出代码: %WEBUI_EXIT_CODE%)
echo ========================================
echo.
pause
