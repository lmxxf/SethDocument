# 来源 https://github.com/apple/ml-stable-diffusion

# 安装conda
brew install anaconda

# conda初始化到zsh
conda init zsh

# 禁用conda自动激活
conda config --set auto_activate_base false

# create a Python environment and install dependencies
conda create -n coremlsd2_38 python=3.8 -y
conda activate coremlsd2_38
mkdir SD21ModelConvChunked
cd SD21ModelConvChunked
git clone https://github.com/apple/ml-stable-diffusion
cd ml-stable-diffusion
pip install -e .

# 登录huggingface的token
huggingface-cli login
# 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
# 或者执行
python3 -c "from huggingface_hub.hf_api import HfFolder; HfFolder.save_token('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')"