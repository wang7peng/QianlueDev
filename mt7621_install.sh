#!/bin/bash

set -u

# v2.43+
install_git() {
  # 不用 git -v 识别, ubuntu 16.04 自带的 git 2.7 不支持 -v
  git --version 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then
    # if not use this repo, default 2.40 will be installed
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git -y
  else
    git config --global core.autocrlf input
    # if not, access git.yoctoproject.org will get a prompt: xxx verification failed
    git config --global http.sslVerify "false"

    echo "- git \t\t ok!"
  fi
}

# v2.7.18
install_python2() {
  python2 -V 2> /dev/null
  if [ $? -eq 127 ]; then
    cd /opt
    if [ ! -f Python-2.7.18.tgz ]; then
      sudo wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
    fi
    sudo tar zxf Python*
    cd Python-2.7.18
    sudo ./configure --enable-optimizations
    sudo make altinstall
    sudo ln -sfn '/usr/local/bin/python2.7' /usr/bin/python2
    sudo update-alternatives --config python
  else
    echo "- python2 \t ok!"
  fi
}

# include: tar
init_tools() {
  tar --version 1> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y tar
  fi
  
  sudo apt-get update
  sudo apt-get install -y \
    g++ \
    libncurses5-dev subversion libssl-dev gawk libxml-parser-perl \
    unzip wget xz-utils build-essential ccache gettext xsltproc  
  sudo apt install -y zlib1g zlib1g-dev # not zlibc

  sudo apt install -y openjdk-8-jdk
}

# install 32bit base tool such as ncurses in 64 system
init_64need32() {
  local sysBit=`getconf LONG_BIT`
  if [ $sysBit -eq 64 ]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y libc6:i386 libstdc++6:i386
    # libncurses5:i386 not exist in ubuntu23+
    sudo apt-get install -y lib32ncurses-dev
    sudo apt-get install -y lib32z1
  fi
}

# 
install_uboot() {
  if [ ! -d u-boot-hiwooya ]; then
    git clone --depth 1 https://github.com/hi-wooya/u-boot-hiwooya.git
  else
    echo "repo u-boot have downloaded!"
  fi
  local op=0
  read -p "need to install u-roob? [Y/n] " op
  case $op in
    Y | y | 1) cd u-boot*
      sudo rm -rf /opt/buildroot-gcc342 2> /dev/null
      if [ ! -d '/opt/mips-2012.03' ]; then
        sudo tar xvfj buildroot-gcc* -C /opt/
        # rename cross gcc to default dir 
        # sudo mv '/opt/buildroot-gcc342/' '/opt/mips-2012.03'
      fi
      make clean
      # only 7628, error will appears if select 7621
      make menuconfig 
      make 
    cd .. ;;
    *) echo "- u-boot \t ok!"
  esac
}

install_openWrt() {
  ./scripts/feeds update -a
  ./scripts/feeds install -a
  # use default config directly
  sudo rm .config 2> /dev/null
  cp config-HIWOOYA16128 .config

  make menuconfig
  # don't use -j8 directly, otherwise some package will download failed!
  make download -j1 V=s
  if [ $? -ne 0 ]; then 
    echo "may be need to change git:// with https://"
  else
    make V=99
  fi
}

# ----- ----- main ----- -----

init_tools

echo "- env --- start --- "
install_git
init_64need32
install_uboot
install_python2
echo "- env --- setok --- "

if [ ! -d 'openwrt-hiwooya'  ]; then
  git clone --depth 1 https://github.com/hi-wooya/openwrt-hiwooya.git
else
  echo "repo openwrt have downloaded!"
fi

cd openwrt-hiwooya
# only compile it when the suffix .bin file not exist
numbers=`find bin/ -maxdepth 2 | grep '.bin' | wc -l`
if [ $numbers -lt 1 ]; then install_openWrt
fi

ls -sh --color=auto bin/*/
cd ..
