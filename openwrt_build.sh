#!/bin/bash

set -u

# include: python3 gcc
checkenv() {
  # GNU Awk v5.1
  awk -V 2> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y gawk;
  fi

  # default v3.5.2 in Ubuntu1604
  python3 -V 2> /dev/null
  if [ $? -eq 127 ]; then echo "you need to install python3 first!"; exit;
  fi
  G_verPy3=$(python3 -V | awk '{print $2}')

  # other condition
}

check_sys() {
  # cat /proc/version | grep -q -i "ubuntu"
  grep -i ubuntu --silent /proc/version
  if [ $? -eq 0 ]; then echo "ubuntu"
  else echo "unknown"
  fi
}

# rules:
#       ubuntu1604 default -> 2102
#
select_version() {
  local ret=2305
  
  # if Python3 < 3.6, openwrt after v22.03+ can not be installed
  local verCurMid=$(echo $G_verPy3 | tr '.' ' ' | awk '{print $2}')
  if [ $verCurMid -lt 6 ]; then
    ret=2102
  fi

  echo $[ret]
}

compile_openwrt() {
  ./scripts/feeds update -a
  ./scripts/feeds install -a

  make menuconfig

  make download -j1 V=s
  make
}

# ----- ----- main ----- -----

checkenv

op=0
read -p "Let's compile openwrt in $check_sys? [Y/n] " op
case $op in
  Y | y | 1) ;;
  *) exit
esac

ver=`select_version` 
branch=openwrt-${ver:0:2}.${ver:0-2}
echo "branch: $branch will be used ..."

dirSrc=openwrt-$ver
if [ ! -d $dirSrc ]; then
  # e.g. xxx  --branch openwrt-23.05 https://github.com/openwrt/openwrt.git openwrt-2305
  git clone --depth 1 --branch $branch https://github.com/openwrt/openwrt.git $dirSrc
fi

cd $dirSrc

compile_openwrt 

cd ..
