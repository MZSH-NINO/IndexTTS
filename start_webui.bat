@echo off
chcp 65001 >nul
echo ========================================
echo IndexTTS-2 WebUI 启动脚本
echo ========================================
echo.

REM 设置 HuggingFace 镜像（可选，国内用户推荐）
set HF_ENDPOINT=https://hf-mirror.com

REM 激活 conda 环境
call conda activate IndexTTS
if %errorlevel% neq 0 (
    echo [错误] 无法激活 IndexTTS 环境
    echo 请先运行 deploy_conda.bat 进行部署
    pause
    exit /b 1
)

echo 正在启动 WebUI...
echo 请耐心等待模型加载（首次运行可能需要下载额外的小模型）...
echo.

REM 启动 webui
python webui.py

pause
