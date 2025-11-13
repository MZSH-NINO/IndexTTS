@echo off
chcp 65001 >nul
echo ========================================
echo IndexTTS-2 WebUI 启动脚本 (UV 版本)
echo ========================================
echo.

REM 设置 HuggingFace 镜像（可选，国内用户推荐）
set HF_ENDPOINT=https://hf-mirror.com

echo 正在启动 WebUI...
echo 请耐心等待模型加载（首次运行可能需要下载额外的小模型）...
echo.

REM 启动 webui
uv run python webui.py

pause
