#!/bin/bash

set -u

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
  
# install libc(32bit) in 64 system
  local sysBit=`getconf LONG_BIT`
  if [ $sysBit -eq 64 ]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install libc6:i386 libstdc++6:i386
    # libncurses5:i386 not exist in ubuntu23+
    sudo apt-get install lib32ncurses-dev
    sudo apt-get install lib32z1
  fi

  sudo apt install -y openjdk-8-jdk
}

# 
install_uboot() {
  if [ ! -d u-boot-hiwooya ]; then
    git clone --depth 1 https://github.com/hi-wooya/u-boot-hiwooya.git
  else
    echo "repo have downloaded!"
  fi
  cd u-boot*
    sudo rm -rf /opt/buildroot-gcc342 2> /dev/null
    if [ ! -d '/opt/mips-2012.03' ]; then
      sudo tar xvfj buildroot-gcc* -C /opt/
      # rename cross gcc to default dir 
      sudo mv '/opt/buildroot-gcc342/' '/opt/mips-2012.03'
    fi
    make clean
    make menuconfig 
    make 
  cd ..
}

# ----- ----- main ----- -----

init_tools

echo "- env --- start --- "
install_uboot

echo "- env --- setok --- "


