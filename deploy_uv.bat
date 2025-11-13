@echo off
chcp 65001 >nul
echo ========================================
echo IndexTTS-2 一键部署脚本 (UV 官方推荐版本)
echo ========================================
echo.

REM 检查 uv 是否安装
where uv >nul 2>&1
if %errorlevel% neq 0 (
    echo [1/5] 未检测到 uv，开始安装...
    pip install -U uv
    if %errorlevel% neq 0 (
        echo [错误] uv 安装失败
        pause
        exit /b 1
    )
) else (
    echo [1/5] 检测到 uv 已安装
)

echo.
echo [2/5] 安装项目依赖 (CUDA 12.8)...
echo 注意：如果下载慢，可以使用国内镜像：
echo uv sync --all-extras --default-index "https://mirrors.aliyun.com/pypi/simple"
echo.

uv sync --all-extras
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败
    echo 如果是网络问题，可以尝试使用国内镜像重新运行此脚本
    pause
    exit /b 1
)

echo.
echo [3/5] 下载模型文件...
if not exist "checkpoints" (
    echo 检测到 checkpoints 目录不存在，开始下载模型...
    echo 默认使用 ModelScope (国内用户推荐)
    echo 如需使用 HuggingFace，请手动设置环境变量并重新运行
    echo.

    echo 使用 ModelScope 下载...
    uv tool install "modelscope"
    modelscope download --model IndexTeam/IndexTTS-2 --local_dir checkpoints

    if %errorlevel% neq 0 (
        echo [错误] ModelScope 下载失败，尝试使用 HuggingFace...
        uv tool install "huggingface-hub[cli,hf_xet]"
        hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

        if %errorlevel% neq 0 (
            echo [错误] 模型下载失败，请检查网络连接
            echo 可以稍后手动下载：
            echo HuggingFace: https://huggingface.co/IndexTeam/IndexTTS-2
            echo ModelScope: https://modelscope.cn/models/IndexTeam/IndexTTS-2
            pause
            exit /b 1
        )
    )
) else (
    echo checkpoints 目录已存在，跳过下载
)

echo.
echo [4/5] 安装 ffmpeg (用于支持 m4a 等格式)...
REM 检查是否有 conda
where conda >nul 2>&1
if %errorlevel% equ 0 (
    conda install -c conda-forge ffmpeg -y
) else (
    echo 未检测到 conda，请手动安装 ffmpeg：
    echo 下载地址: https://ffmpeg.org/download.html
)

echo.
echo [5/5] 检查 GPU 加速...
uv run python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'CUDA Version: {torch.version.cuda}') if torch.cuda.is_available() else None"

echo.
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 使用方法：
echo 运行： uv run python webui.py
echo 或运行： start_webui_uv.bat
echo.
pause
