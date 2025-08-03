#!/bin/bash
set -e

# ---------- 配置 ----------
GROMACS_VERSION=2025.2
CUDA_PATH=/usr/local/cuda-12.9
INSTALL_DIR=$HOME/gromacs-$GROMACS_VERSION
SRC_DIR=$HOME/gromacs-$GROMACS_VERSION
BUILD_DIR=$SRC_DIR/build
SM_VERSION=89  # RTX 4060 架构

echo "🚀 开始安装 GROMACS $GROMACS_VERSION（GPU版本）"

# ---------- 安装依赖 ----------
echo "📦 安装必要依赖..."
sudo apt update
sudo apt install -y build-essential cmake git wget curl \
  libhwloc-dev libfftw3-dev libxml2-dev \
  gcc-11 g++-11

# ---------- 设置 GCC 版本 ----------
echo "🔧 配置 gcc/g++ 为 gcc-11"
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-11
sudo update-alternatives --set gcc /usr/bin/gcc-11

gcc --version

# ---------- 解压源码 ----------
echo "📂 解压 ~/gromacs-${GROMACS_VERSION}.tar.gz..."
cd ~
tar -xzf gromacs-${GROMACS_VERSION}.tar.gz

# ---------- 创建构建目录 ----------
echo "📁 创建构建目录：$BUILD_DIR"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# ---------- CMake 配置 ----------
echo "⚙️ 运行 cmake ..."
cmake .. \
  -DGMX_BUILD_OWN_FFTW=ON \
  -DREGRESSIONTEST_DOWNLOAD=ON \
  -DGMX_GPU=CUDA \
  -DGMX_CUDA_TARGET_SM=${SM_VERSION} \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
  -DCMAKE_C_COMPILER=/usr/bin/gcc \
  -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
  -DCMAKE_CUDA_COMPILER=$CUDA_PATH/bin/nvcc \
  -DCMAKE_CUDA_ARCHITECTURES=${SM_VERSION} \
  -DCMAKE_CUDA_FLAGS=""

# ---------- 编译 ----------
echo "🔨 编译中..."
make -j$(nproc)

# ---------- 安装 ----------
echo "📦 安装到 $INSTALL_DIR"
make install

# ---------- 配置环境变量 ----------
echo "🔧 添加环境变量到 ~/.bashrc"
if ! grep -q "source $INSTALL_DIR/bin/GMXRC.bash" ~/.bashrc; then
  echo "source $INSTALL_DIR/bin/GMXRC.bash" >> ~/.bashrc
fi
source ~/.bashrc

# ---------- 测试 ----------
echo "✅ 安装完成，运行版本测试："
gmx mdrun -version

echo "🧪 检查 GPU 识别情况："
gmx gpus
