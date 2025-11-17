@echo off
chcp 65001 >nul

REM 切换到项目根目录
cd /d "%~dp0\.."

echo ========================================
echo IndexTTS-2 WebUI 启动脚本 (UV 版本)
echo ========================================
echo.

REM 设置 HuggingFace 镜像（可选，国内用户推荐）
set HF_ENDPOINT=https://hf-mirror.com

echo [信息] 正在启动 WebUI...
echo.
echo [信息] 正在加载模型，请稍候...
echo [提示] 首次运行会自动下载额外的小模型（约 500MB）
echo [提示] 启动后请在浏览器访问显示的地址（通常是 http://127.0.0.1:7860）
echo.

REM 启动 webui
uv run python webui.py

pause
