@echo off
chcp 65001 >nul

REM 切换到项目根目录
cd /d "%~dp0\.."

echo ========================================
echo IndexTTS-2 WebUI 启动脚本 (Conda 版本)
echo ========================================
echo.

REM 设置 HuggingFace 镜像（可选，国内用户推荐）
set HF_ENDPOINT=https://hf-mirror.com

REM 激活 conda 环境
echo [1/2] 激活 Conda 环境...
call conda activate IndexTTS
if %errorlevel% neq 0 (
    echo.
    echo [错误] 无法激活 IndexTTS 环境
    echo [提示] 请先运行"一键部署.bat"进行部署
    echo.
    pause
    exit /b 1
)

echo [2/2] 启动 WebUI...
echo.
echo [信息] 正在加载模型，请稍候...
echo [提示] 首次运行会自动下载额外的小模型（约 500MB）
echo [提示] 启动后请在浏览器访问显示的地址（通常是 http://127.0.0.1:7860）
echo.

REM 启动 webui
python webui.py

pause
