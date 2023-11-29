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
    # only 7628, error will appears if select 7621
    make menuconfig 
    make 
  cd ..
  echo "- u-boot \t ok!"
}

install_openWrt() {
  if [ ! -d 'openwrt-hiwooya'  ]; then
    git clone --depth 1 https://github.com/hi-wooya/openwrt-hiwooya.git
  else
    echo "repo openwrt have downloaded!"
  fi

  cd openwrt-hi*
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
  cd ..
}

# ----- ----- main ----- -----

init_tools

echo "- env --- start --- "
init_64need32
install_uboot

echo "- env --- setok --- "

install_openWrt
