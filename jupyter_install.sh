# 前提条件：安装Anaconda3
# 安装conda，先下载
bash Anaconda3-2023.03-Linux-x86_64.sh
conda create --name tensorflow-nvidia python=3.8
conda activate tensorflow-nvidia

conda info --env

pip install nvidia-pyindex
pip install nvidia-tensorflow[horovod]

# 退出conda某个虚拟环境
conda deactivate tensorflow-nvidia
# 删除conda某个虚拟环境
conda remove tensorflow-nvidia
# 或者（不知道为什么时灵时不灵）
conda remove --name tensorflow-nvidia --all


#############################################################################

# 安装jupyter虚拟环境
# conda install jupyter notebook
conda create --name jupyter-notebook
conda activate jupyter-notebook

# 安装组件
pip3 install jupyter
pip3 install transformers

# 运行
jupyter notebook 
# 会自动启动浏览器

# 设置密码（不设置不行）
jupyter notebook password


# 生成jupyter配置文件（默认为~/.jupyter/jupyter_notebook_config.py）
jupyter notebook --generate-config
# 修改文件以允许其它主机访问 ~/.jupyter/jupyter_notebook_config.py
<<EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
EOF
# 配置文件路径通过这条命令获取
jupyter --config-dir

