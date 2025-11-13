@echo off
chcp 65001 >nul
echo ========================================
echo IndexTTS-2 一键部署脚本 (Conda 版本)
echo ========================================
echo.

REM 检查 conda 是否安装
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 conda，请先安装 Miniconda 或 Anaconda
    echo 下载地址: https://docs.conda.io/en/latest/miniconda.html
    pause
    exit /b 1
)

echo [1/6] 检查 conda 环境...
conda info --envs | findstr "IndexTTS" >nul
if %errorlevel% equ 0 (
    echo 检测到已存在 IndexTTS 环境，跳过创建，直接更新依赖...
    goto skip_create
)

echo.
echo [2/6] 创建 Python 3.10 虚拟环境...
conda create -n IndexTTS python=3.10 -y
if %errorlevel% neq 0 (
    echo [错误] 环境创建失败
    pause
    exit /b 1
)

:skip_create

echo.
echo [3/6] 激活环境并安装 PyTorch (CUDA 12.1)...
call conda activate IndexTTS
if %errorlevel% neq 0 (
    echo [错误] 环境激活失败
    pause
    exit /b 1
)

REM 安装 PyTorch CUDA 版本
pip install torch==2.8.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu121
if %errorlevel% neq 0 (
    echo [错误] PyTorch 安装失败
    pause
    exit /b 1
)

echo.
echo [4/6] 安装项目依赖...
pip install accelerate==1.8.1 cn2an==0.5.22 cython==3.0.7 descript-audiotools==0.7.2 einops ffmpeg-python==0.2.0 g2p-en==2.1.0 jieba==0.42.1 json5==0.10.0 keras==2.9.0 librosa==0.10.2.post1 matplotlib==3.8.2 modelscope==1.27.0 munch==4.0.0 numba==0.58.1 numpy==1.26.2 omegaconf opencv-python==4.9.0.80 pandas==2.3.2 safetensors==0.5.2 sentencepiece tensorboard==2.9.1 textstat tokenizers==0.21.0 tqdm transformers==4.52.1 wetext gradio==5.45.0
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败
    pause
    exit /b 1
)

echo.
echo [5/6] 安装 ffmpeg...
conda install -n IndexTTS -c conda-forge ffmpeg -y
if %errorlevel% neq 0 (
    echo [警告] ffmpeg 安装失败，可能影响 m4a 等格式音频文件加载
)

echo.
echo [6/6] 下载模型文件...
if not exist "checkpoints" (
    echo 检测到 checkpoints 目录不存在，开始下载模型...
    echo 默认使用 ModelScope (国内用户推荐)
    echo 如需使用 HuggingFace，请手动设置环境变量并重新运行
    echo.

    echo 使用 ModelScope 下载...
    modelscope download --model IndexTeam/IndexTTS-2 --local_dir checkpoints

    if %errorlevel% neq 0 (
        echo [错误] ModelScope 下载失败，尝试使用 HuggingFace...
        pip install huggingface-hub[cli]
        set HF_ENDPOINT=
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
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 使用方法：
echo 1. 运行 start_webui.bat 启动 WebUI
echo 2. 或手动激活环境： conda activate IndexTTS
echo 3. 然后运行： python webui.py
echo.
pause
