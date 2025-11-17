@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ========================================
REM IndexTTS-2 交互式一键部署脚本
REM ========================================

REM 切换到项目根目录
cd /d "%~dp0\.."

:main_menu

REM ========================================
REM 第一步：选择环境类型
REM ========================================

:select_env
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                                                              ║
echo ║           IndexTTS-2 交互式一键部署脚本 v2.0                ║
echo ║                                                              ║
echo ║           让小白用户也能轻松部署 AI 语音合成！              ║
echo ║                                                              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo ┌──────────────────────────────────────────────────────────────┐
echo │ 步骤 1/2: 选择 Python 环境类型                               │
echo └──────────────────────────────────────────────────────────────┘
echo.
echo   [1] Conda 虚拟环境 (推荐新手)
echo       - 优点：环境隔离，易于管理
echo       - 需要：已安装 Miniconda/Anaconda
echo.
echo   [2] Python + UV (官方推荐)
echo       - 优点：速度快，依赖管理精准
echo       - 需要：已安装 Python 3.10+
echo       - 说明：UV 会自动安装
echo.
echo   [0] 退出安装
echo.
set /p ENV_CHOICE="请输入选项 [1/2/0]: "

if "%ENV_CHOICE%"=="0" exit /b 0
if "%ENV_CHOICE%"=="1" goto check_conda
if "%ENV_CHOICE%"=="2" goto check_python
echo.
echo [错误] 无效选项，请重新选择
timeout /t 2 >nul
goto select_env

REM ========================================
REM 检测 Conda 环境
REM ========================================

:check_conda
cls
echo.
echo [信息] 正在检测 Conda 环境...
echo.

where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║                                                              ║
    echo ║                      ❌ 环境检测失败                         ║
    echo ║                                                              ║
    echo ╚══════════════════════════════════════════════════════════════╝
    echo.
    echo [错误] 未检测到 Conda 环境
    echo.
    echo [解决方案] 请先安装 Miniconda 或 Anaconda：
    echo   下载地址：https://docs.conda.io/en/latest/miniconda.html
    echo.
    echo   安装完成后，请重新运行本脚本。
    echo.
    pause
    goto select_env
)

echo [✓] 检测到 Conda 环境
set "INSTALL_METHOD=conda"
goto detect_cuda

REM ========================================
REM 检测 Python 环境
REM ========================================

:check_python
cls
echo.
echo [信息] 正在检测 Python 环境...
echo.

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo ╔══════════════════════════════════════════════════════════════╗
    echo ║                                                              ║
    echo ║                      ❌ 环境检测失败                         ║
    echo ║                                                              ║
    echo ╚══════════════════════════════════════════════════════════════╝
    echo.
    echo [错误] 未检测到 Python 环境
    echo.
    echo [解决方案] 请先安装 Python 3.10 或更高版本：
    echo   下载地址：https://www.python.org/downloads/
    echo.
    echo   安装完成后，请重新运行本脚本。
    echo.
    pause
    goto select_env
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [✓] 检测到 Python 环境 (版本: !PYTHON_VERSION!)
set "INSTALL_METHOD=uv"
goto detect_cuda

REM ========================================
REM 第二步：自动检测 CUDA
REM ========================================

:detect_cuda
echo.
echo [信息] 正在检测 CUDA 环境...
echo.

set "CUDA_AVAILABLE=0"
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] 检测到 NVIDIA 显卡驱动
    set "CUDA_AVAILABLE=1"
    set "DEVICE_TYPE=cuda"
    echo [信息] 将使用 CUDA 加速模式
) else (
    echo [✗] 未检测到 NVIDIA 显卡驱动
    set "DEVICE_TYPE=cpu"
    echo [信息] 将使用 CPU 模式
    echo [提示] 如需 GPU 加速，请先安装 NVIDIA 驱动
)

echo.
timeout /t 2 >nul
goto confirm_install

REM ========================================
REM 确认安装配置
REM ========================================

:confirm_install
cls
echo.
echo ┌──────────────────────────────────────────────────────────────┐
echo │ 步骤 2/2: 确认安装配置                                       │
echo └──────────────────────────────────────────────────────────────┘
echo.
echo   系统已自动检测您的配置：
echo   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   环境类型：!INSTALL_METHOD!
echo   设备类型：!DEVICE_TYPE!
if "!INSTALL_METHOD!"=="conda" (
    echo   环境名称：IndexTTS
)
if "!DEVICE_TYPE!"=="cuda" (
    echo   PyTorch：  CUDA 12.1 版本
    echo   性能：    ⚡ GPU 加速 (快速)
) else (
    echo   PyTorch：  CPU 版本
    echo   性能：    🐌 CPU 模式 (较慢)
)
echo   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo   预计安装时间：10-50 分钟 (取决于网速)
echo.
echo   [1] 确认并开始安装
echo   [0] 返回上一步
echo.
set /p CONFIRM="请确认 [1/0]: "

if "%CONFIRM%"=="0" goto select_env
if "%CONFIRM%"=="1" goto start_install
echo [错误] 无效选项，请重新选择
timeout /t 2 >nul
goto confirm_install

REM ========================================
REM 第三步：开始安装
REM ========================================

:start_install
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    开始安装 IndexTTS-2                       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo [信息] 安装方式：!INSTALL_METHOD! + !DEVICE_TYPE!
echo [信息] 安装过程可能需要 5-30 分钟，请耐心等待...
echo.

if "!INSTALL_METHOD!"=="conda" goto install_conda
if "!INSTALL_METHOD!"=="uv" goto install_uv

REM ========================================
REM Conda 安装流程
REM ========================================

:install_conda
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   Conda 安装流程
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo [1/7] 检查 Conda 环境...
conda info --envs | findstr "IndexTTS" >nul
if %errorlevel% equ 0 (
    echo [✓] 检测到已存在 IndexTTS 环境，跳过创建
    goto conda_activate
)

echo [2/7] 创建 Python 3.10 虚拟环境...
conda create -n IndexTTS python=3.10 -y
if %errorlevel% neq 0 (
    echo [✗] 环境创建失败
    pause
    exit /b 1
)

:conda_activate
echo [3/7] 激活环境...
call conda activate IndexTTS
if %errorlevel% neq 0 (
    echo [✗] 环境激活失败
    pause
    exit /b 1
)

echo [4/7] 安装 UV 工具...
where uv >nul 2>&1
if %errorlevel% neq 0 (
    echo [信息] UV 未安装，正在自动安装...
    pip install -U uv
    if %errorlevel% neq 0 (
        echo [⚠️] UV 安装失败，继续安装其他依赖
    ) else (
        echo [✓] UV 安装成功
    )
) else (
    echo [✓] UV 已安装
)

echo [5/7] 安装 PyTorch...
if "!DEVICE_TYPE!"=="cuda" (
    echo [信息] 安装 CUDA 12.1 版本 PyTorch
    pip install torch==2.8.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu121
) else (
    echo [信息] 安装 CPU 版本 PyTorch
    pip install torch==2.8.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cpu
)
if %errorlevel% neq 0 (
    echo [✗] PyTorch 安装失败
    pause
    exit /b 1
)

echo [6/7] 安装项目依赖...
pip install accelerate==1.8.1 cn2an==0.5.22 cython==3.0.7 descript-audiotools==0.7.2 einops ffmpeg-python==0.2.0 g2p-en==2.1.0 jieba==0.42.1 json5==0.10.0 keras==2.9.0 librosa==0.10.2.post1 matplotlib==3.8.2 modelscope==1.27.0 munch==4.0.0 numba==0.58.1 numpy==1.26.2 omegaconf opencv-python==4.9.0.80 pandas==2.3.2 safetensors==0.5.2 sentencepiece tensorboard==2.9.1 textstat tokenizers==0.21.0 tqdm transformers==4.52.1 wetext gradio==5.45.0
if %errorlevel% neq 0 (
    echo [✗] 依赖安装失败
    pause
    exit /b 1
)

echo [7/7] 安装 ffmpeg...
conda install -n IndexTTS -c conda-forge ffmpeg -y
if %errorlevel% neq 0 (
    echo [⚠️] ffmpeg 安装失败，可能影响部分音频格式支持
)

goto download_model

REM ========================================
REM UV 安装流程
REM ========================================

:install_uv
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   UV 安装流程
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo [1/5] 检查 UV 工具...
where uv >nul 2>&1
if %errorlevel% neq 0 (
    echo [信息] UV 未安装，正在自动安装...
    pip install -U uv
    if %errorlevel% neq 0 (
        echo [✗] UV 安装失败
        pause
        exit /b 1
    )
) else (
    echo [✓] UV 已安装
)

echo [2/5] 修改 pyproject.toml 配置 (根据设备类型)...
if "!DEVICE_TYPE!"=="cpu" (
    echo [信息] 配置 CPU 版本 PyTorch
    REM 创建临时配置文件
    copy /Y pyproject.toml pyproject.toml.bak >nul
    powershell -Command "(Get-Content pyproject.toml) -replace 'torch==2.8.\*', 'torch==2.8.0' -replace 'torchaudio==2.8.\*', 'torchaudio==2.8.0' | Set-Content pyproject_cpu.toml"
    move /Y pyproject_cpu.toml pyproject.toml >nul
)

echo [3/5] 安装项目依赖...
if "!DEVICE_TYPE!"=="cpu" (
    uv sync --all-extras --index-url https://download.pytorch.org/whl/cpu
) else (
    uv sync --all-extras
)
if %errorlevel% neq 0 (
    echo [✗] 依赖安装失败
    if exist pyproject.toml.bak move /Y pyproject.toml.bak pyproject.toml >nul
    pause
    exit /b 1
)

if exist pyproject.toml.bak move /Y pyproject.toml.bak pyproject.toml >nul

echo [4/5] 安装 ffmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] ffmpeg 已安装
    goto ffmpeg_installed
)

echo [信息] ffmpeg 未安装，正在尝试自动安装...
where conda >nul 2>&1
if %errorlevel% equ 0 (
    echo [信息] 使用 Conda 安装 ffmpeg...
    conda install -c conda-forge ffmpeg -y
    if %errorlevel% equ 0 (
        echo [✓] ffmpeg 安装成功
        goto ffmpeg_installed
    )
)

where choco >nul 2>&1
if %errorlevel% equ 0 (
    echo [信息] 使用 Chocolatey 安装 ffmpeg...
    choco install ffmpeg -y
    if %errorlevel% equ 0 (
        echo [✓] ffmpeg 安装成功
        goto ffmpeg_installed
    )
)

echo [⚠️] 自动安装失败，正在下载便携版 ffmpeg...
if not exist "ffmpeg\" mkdir ffmpeg
echo [信息] 下载 ffmpeg-7.1-essentials_build.zip (约 80MB)...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg\ffmpeg.zip'}"
if %errorlevel% equ 0 (
    echo [信息] 解压 ffmpeg...
    powershell -Command "Expand-Archive -Path 'ffmpeg\ffmpeg.zip' -DestinationPath 'ffmpeg' -Force"
    for /d %%i in (ffmpeg\ffmpeg-*) do set "FFMPEG_DIR=%%i"
    echo [✓] ffmpeg 已安装到项目目录
    echo [提示] ffmpeg 路径：%cd%\!FFMPEG_DIR!\bin
    echo [提示] 请将该路径添加到系统 PATH 环境变量，或每次使用前设置：
    echo         set PATH=%cd%\!FFMPEG_DIR!\bin;%%PATH%%
) else (
    echo [✗] ffmpeg 下载失败
    echo [提示] 请手动下载并安装 ffmpeg：
    echo         https://ffmpeg.org/download.html
    echo [提示] 或使用 Chocolatey：choco install ffmpeg
)

:ffmpeg_installed

echo [5/5] 验证 GPU 加速...
if "!DEVICE_TYPE!"=="cuda" (
    uv run python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}'); print(f'Device Count: {torch.cuda.device_count()}'); print(f'Device Name: {torch.cuda.get_device_name(0)}') if torch.cuda.is_available() else print('No CUDA device found')"
)

goto download_model

REM ========================================
REM 下载模型
REM ========================================

:download_model
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   下载模型文件
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

if exist "checkpoints\config.yaml" (
    echo [✓] 检测到 checkpoints 目录已存在，跳过下载
    goto install_complete
)

echo [信息] 正在下载模型文件 (约 2-5 GB)...
echo [信息] 优先使用 ModelScope (国内用户速度更快)
echo.

if "!INSTALL_METHOD!"=="conda" (
    echo [信息] 使用 ModelScope 下载...
    modelscope download --model IndexTeam/IndexTTS-2 --local_dir checkpoints
    if %errorlevel% neq 0 (
        echo [⚠️] ModelScope 下载失败，尝试 HuggingFace...
        pip install "huggingface-hub[cli]"
        set HF_ENDPOINT=
        hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
        if %errorlevel% neq 0 (
            echo [✗] 模型下载失败
            goto download_failed
        )
    )
) else (
    echo [信息] 使用 ModelScope 下载...
    uv tool install "modelscope"
    modelscope download --model IndexTeam/IndexTTS-2 --local_dir checkpoints
    if %errorlevel% neq 0 (
        echo [⚠️] ModelScope 下载失败，尝试 HuggingFace...
        uv tool install "huggingface-hub[cli,hf_xet]"
        hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints
        if %errorlevel% neq 0 (
            echo [✗] 模型下载失败
            goto download_failed
        )
    )
)

goto install_complete

:download_failed
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   模型下载失败
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo [信息] 环境已安装成功，但模型下载失败
echo [提示] 您可以稍后手动下载模型：
echo.
echo   方式1 - HuggingFace:
echo   https://huggingface.co/IndexTeam/IndexTTS-2
echo.
echo   方式2 - ModelScope (国内推荐):
echo   https://modelscope.cn/models/IndexTeam/IndexTTS-2
echo.
echo   下载后将文件解压到：%cd%\checkpoints
echo.
pause
exit /b 0

REM ========================================
REM 安装完成
REM ========================================

:install_complete
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                                                              ║
echo ║                   🎉 安装完成！🎉                           ║
echo ║                                                              ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   安装信息
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo   环境类型：!INSTALL_METHOD!
echo   设备类型：!DEVICE_TYPE!
if "!INSTALL_METHOD!"=="conda" (
    echo   环境名称：IndexTTS
)
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   使用方法
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
if "!INSTALL_METHOD!"=="conda" (
    echo   快速启动：
    echo   1. 双击运行："一键部署工具\start_webui.bat"
    echo.
    echo   手动启动：
    echo   1. 激活环境：conda activate IndexTTS
    echo   2. 启动 WebUI：python webui.py
    if "!DEVICE_TYPE!"=="cuda" (
        echo   3. 启用优化：python webui.py --use_fp16 --use_deepspeed
    )
) else (
    echo   快速启动：
    echo   1. 双击运行："一键部署工具\start_webui_uv.bat"
    echo.
    echo   手动启动：
    echo   1. 启动 WebUI：uv run webui.py
    if "!DEVICE_TYPE!"=="cuda" (
        echo   2. 启用优化：uv run webui.py --use_fp16 --use_deepspeed
    )
)
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   性能建议
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
if "!DEVICE_TYPE!"=="cuda" (
    echo   [✓] CUDA 加速已启用
    echo   [提示] 推荐使用 --use_fp16 参数降低显存占用
    echo   [提示] 可选使用 --use_deepspeed 参数提升性能
) else (
    echo   [⚠️] CPU 模式运行较慢
    echo   [提示] 如有 NVIDIA 显卡，建议重新安装并选择 CUDA 加速
)
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   技术支持
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo   GitHub：https://github.com/index-tts/index-tts
echo   QQ 群：663272642 (No.4) / 1013410623 (No.5)
echo   Discord：https://discord.gg/uT32E7KDmy
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
pause
exit /b 0
