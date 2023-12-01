#!/bin/bash

set -u

# include: tree wget vim
init_tools() {
  tree --version 1> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y tree
  fi

  wget -V 1> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y wget
  fi

  vim --version 1> /dev/null
  if [ $? -eq 127 ]; then sudo apt install -y vim
  fi

}

# v2.43+
install_git() {
  git -v 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then
    # if not use this repo, default 2.40 will be installed
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git -y
  else
    echo "- git \t\t ok!"
  fi
}

# v3.27+
install_cmake() {
  cmake -version 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then
    sudo apt install cmake
  else
    echo "- cmake \t ok!"
  fi
}

# v13.2+
install_gnu() {
  # ignore the prompt (fatal error: not input files)
  gcc 2> /dev/null
  if [ $? -eq 127 ]; then
    sudo apt install -y gcc-13 g++-13
  else
    echo "- c/c++ \t ok!"
  fi
}

# v1.21+
install_go() {
  go version 1> /dev/null 2> /dev/null
  # 127 means command not found, need install
  if [ $? -eq 127 ]; then
    cd /opt
    sudo wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
    sudo tar -C /usr/local/etc/ -zxf go1.2*
    sudo ln -s /usr/local/etc/go/bin/* /usr/local/bin/
  else
    echo "- go 1.21 \t ok!"
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

# v23.6+
install_lede() {
  local tag=20230609
  read -p "will clone tag $1? [default $tag] [Y/n] " op
  case $op in 
    Y | y | 1) tag=$1;;
    *)  
  esac
  if [ ! -d lede ]; then
    echo "get special tag: $tag"
    git clone --depth 1 -b $tag https://github.com/coolsnowwolf/lede.git
  else
    echo "lede repo have download."
  fi
  cd lede
  local numbers_pkg=`ls dl/ | wc -l`
  # after build, total 173 packages will show up in this dl directory
  if [ $numbers_pkg -lt 173 ]; then
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    # then will appears a UI menu to config yourself
    make menuconfig
    make download -j8
    # must to set up thread (-j1), otherwise this script will stuck.
    make V=s -j1
  else
    echo "build ok!"
  fi
  cd ..
}

# ----- -----  main()  ----- -----

init_tools

echo "- env --- start --- -"
install_git   # first of all
install_gnu   # gcc g++
install_go
install_cmake
install_python2
echo "- env --- setok --- -"

op=0
read -p "install lede? [Y/n] " op
case $op in 
  Y | y | 1) install_lede 20230609
    tree -C -sh -L 2 lede/bin/targets/x86
  ;;
  *) echo "lede not installed!"
esac
