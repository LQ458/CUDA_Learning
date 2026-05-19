#!/bin/bash
# ===== 每次新实例跑一次 =====

# git
git config --global user.email "lqn458@gmail.com"
git config --global user.name "LQ458"

# ncu
wget -qO- https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add -
echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list
apt update && apt install -y nsight-compute 2>/dev/null

# 拉你自己的 repo（小，快）
cd ~
[ -d projects ] || git clone https://github.com/lq458/CUDA_Learning.git projects
cd ~/projects
git remote set-url origin "$(cat /mnt/.git_token)@github.com/lq458/CUDA_Learning.git"
git pull 2>/dev/null

echo "Ready. nvcc: $(nvcc --version | head -1)"
ncu --version 2>/dev/null | head -1
