#!/bin/bash

set -u

# install latest gnu make
install_make() {
  if [ ! -f make.tar.gz ]; then
    wget --no-verbose --tries=1	-O 'make.tar.gz' \
      https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz # 2.2M
  fi
  tar -zxf make.tar.gz
  cd make-*
  ./configure
  make
  sudo make install
  make -v
}

check_env() {
  sudo apt-get install -y libasound2-dev

  # check gnu C
  gcc 2> /dev/null
  if [ $? -eq 127 ];then sudo apt install -y gcc g++
  fi
  gcc --version | head -n 1

  # check gnu make
  make -v 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then install_make
  fi
  make -v | head -n 1 
}

# ----- ----- main ----- -----
check_env

dirSrc="pjproject-2.14"

# get pkg of pjsip
if [ ! -f ${dirSrc}.tar.gz ]; then
  wget --no-verbose --tries=2	-O pjproject-2.14.tar.gz \
    https://github.com/pjsip/pjproject/archive/refs/tags/2.14.tar.gz # 9.8M
else
  echo "pkg pjsip have download!"
fi

tar -zxf ${dirSrc}.tar.gz

cd $dirSrc
./configure --prefix=/usr/local/pjsip
make
sudo make install
cd ..

echo "install ok, clear yourself"
