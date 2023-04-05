# ubuntu下安装chrome
# https://zhuanlan.zhihu.com/p/137114100
# 下载
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# 安装
sudo apt install ./google-chrome-stable_current_amd64.deb

# 安装git
# https://zhuanlan.zhihu.com/p/41351705

# aria2下载工具
# https://blog.csdn.net/ChaoFeiLi/article/details/109351922
sudo apt-get install aria2

# 挂载ntfs硬盘
# https://www.cnblogs.com/wx2020/p/16083742.html
# 查找硬盘
sudo fdisk -l

# 获取硬盘uuid
sudo blkid

# 编辑fstab
sudo vi /etc/fstab
# 添加一行
# UUID=5AF011B2F011957B /home/lmxxf/DiskD ntfs defaults 0 0
sudo mount -a

# 安装conda，先下载
bash Anaconda3-2023.03-Linux-x86_64.sh
conda create --name tensorflow-nvidia python=3.8
conda activate tensorflow-nvidia

pip install nvidia-pyindex
pip install nvidia-tensorflow[horovod]




# 安装python3.8
# https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/
sudo apt update

sudo apt --list upgradable

sudo apt upgrade

sudo apt install ca-certificates apt-transport-https software-properties-common lsb-release -y

sudo gpg --list-keys

sudo gpg --no-default-keyring --keyring /usr/share/keyrings/deadsnakes.gpg --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776

echo "deb [signed-by=/usr/share/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/python.list

sudo apt update

# 再次安装python3.8将成功
sudo apt install python3.8
python3.8 --version


# 安装nvidia显卡驱动
# https://blog.51cto.com/u_4029519/5909904
# https://zhuanlan.zhihu.com/p/581720480

sudo apt get update
sudo apt get install g++
sudo apt install gcc
sudo apt install make

ubuntu-drivers devices
sudo apt install nvidia-driver-525-open

# 安装cuda 11.8
# https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Linux

# 重启后enroll SDK，再启动执行nvidia-smi才有反应

# cuDNN https://developer.nvidia.com/rdp/cudnn-download
# https://developer.download.nvidia.com/compute/cudnn/secure/8.8.1/local_installers/11.8/cudnn-local-repo-ubuntu2204-8.8.1.3_1.0-1_amd64.deb?gXRnv6ha3YI8VEKLw2Krdv1MnZcg2V9TxcGpLKqMRtyqmr5-bqjC5vdDvT-w--QYEZJfU_cWBsnsWFldu8QCgBUO8YH5whBx6KNc4qkdfKj4Ktjlg2nxyxV24U8S6IzrZUpMkyasmYZyh-ixKW6y1IoGc59RmKDhoTIT1RGfgG10-FTjdBZb0XfH5XmXyIiGlpD5qqP56IwSId_GAirKcUOWow==&t=eyJscyI6ImdzZW8iLCJsc2QiOiJodHRwczovL3d3dy5nb29nbGUuY29tLyJ9


# 删除有问题的本地软件源
cd /etc/apt/sources.list.d

sudo rm -rf cuda-ubuntu2204-11-8-local.list 
sudo rm -rf cuda-ubuntu2204-12-1-local.list 
sudo rm cudnn-local-ubuntu2204-8.8.1.3.list


# 以下是在Ubuntu 22.04上安装Nvidia 3080显卡驱动、CUDA和cuDNN的步骤：

sudo apt update
sudo apt install nvidia-driver-495

sudo apt update
sudo apt install nvidia-cuda-toolkit

sudo apt update
sudo apt install libcudnn8 libcudnn8-dev

nvidia-smi
nvcc -V


