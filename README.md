# Gromacs-wsl-GPU
Install Gromacs on WSL2 Ubuntu 24.04

1.**升级 WSL 2**：在 Windows PowerShell （管理员权限）中执行

```
wsl --update       # 更新 WSL 内核
```



2.已经下载并修改好的脚本放在WIN11 DOWNLOADS文件夹下面：

```
D:\Downloads
```



Windows 的驱动器会在 WSL 中挂载到 `/mnt/` 目录下。例如，`C:\Users\用户名\Downloads` 会在 WSL 中显示为 `/mnt/c/Users/用户名/Downloads`[learn.microsoft.com](https://learn.microsoft.com/en-us/windows/wsl/filesystems#:~:text=,user name>\Project)。因此，假设脚本保存在 Windows 的下载目录，你可以在 WSL 终端中查看它：



所以D:\Downloads对应WSL文件夹就是：/mnt/e/Sysdok/Downloads



### 3.**检查 GCC 版本兼容性**

运行：

```
gcc --version
```

默认 Ubuntu 24.04 安装的是 GCC 13.x。很多 CUDA 版本（包括 12.x）**只兼容到 GCC 11 或 12**。你需要安装一个兼容版本。

安装 GCC-11 并切换：

```
sudo apt install gcc-11 g++-11
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-11
sudo update-alternatives --config gcc  # 选择 gcc-11
gcc --version  # 确认切换
```



**3.复制到 WSL 主目录**

```
cp /mnt/e/Sysdok/Downloads/install_gromacs_gpu.sh ~/
```



**WINDOWS手动下载gromacs**

https://manual.gromacs.org/documentation/current/download.html

https://ftp.gromacs.org/gromacs/gromacs-2025.2.tar.gz



**后复制到WSL ~**

cp /mnt/e/Sysdok/Downloads/gromacs-2025.2.tar.gz ~/



4.**转换换行符并赋予执行权限**
 如果脚本是在 Windows 上创建的，可能包含 CRLF 换行符，需要用 `dos2unix` 转换（一般不需要转换）：

```
##dos2unix install_gromacs_gpu.sh
chmod +x install_gromacs_gpu.sh
```



5.**运行脚本**



 在 WSL 终端中执行脚本即可：

```
./install_gromacs_gpu.sh
```

脚本会提示输入密码并完成安装。



### 每次重新安装，**都需要彻底删除旧 build 目录**

```
rm -rf build
```

每次修改 GPU 架构参数都要删！



6.安装完成后，执行 

```
gmx --version
```

 应显示版本信息。



*注意确保 Windows 主机已安装支持 WSL 的 NVIDIA 驱动，否则 CUDA 将无法工作。



## gmx: command not found解决方法

你只需要**重新加载 GROMACS 的环境配置脚本**，或者重新打开终端。

### 方法：当前会话手动加载

```
source ~/gromacs-2025.2/bin/GMXRC.bash
```

然后再测试：

```
gmx mdrun -version
gmx gpus
```





---------------------------------------

## 将 CHARMM36 力场添加到全局可用目录

### 1. 下载 `charmm36-jul2022.ff.tgz`

前往官方下载页面：
https://mackerell.umaryland.edu/charmm_ff.shtml#gromacs



下载文件：`charmm36-jul2022.ff.tgz`

### 2. 将文件复制到 WSL Ubuntu 并解压

如果你下载的是 Windows 系统路径下：

```
cp /mnt/e/Sysdok/Downloads/charmm36-jul2022.ff.tgz ~/
```

然后解压：

```
cd ~
tar -xzf charmm36-jul2022.ff.tgz
```

你将得到：

```
~/charmm36-jul2022.ff/
├── forcefield.itp
├── aminoacids.rtp
├── ...
```

------

### 3. 移动到 GROMACS 安装路径

```
###mkdir -p ~/gromacs-2025.2/share/top/
cp -r ~/charmm36-jul2022.ff ~/gromacs-2025.2/share/top/
```

确认：

```
ls ~/gromacs-2025.2/share/top/charmm36-jul2022.ff/forcefield.itp
```



每次使用需要将**将 forcefield 文件夹复制到每次模拟的目录**（最稳定），否则会报错。

### ✅ 方法 ：**将 forcefield 文件夹复制到每次模拟的目录**（最稳定）

#### 步骤：

```
cp -r ~/gromacs-2025.2/share/top/charmm36-jul2022.ff ~/MD/
```

然后确保 `.top` 文件中的所有 `#include` 保持原样，比如：

```
#include "charmm36-jul2022.ff/forcefield.itp"
#include "charmm36-jul2022.ff/tip3p.itp"
#include "charmm36-jul2022.ff/ions.itp"
```

GROMACS 会在**当前工作目录**找到 `charmm36-jul2022.ff`，不再报错。

✅ **以后每次新建模拟目录，都复制一份 `.ff` 目录过去**，是最保险的做法。
