#!/bin/bash

#
# refer: www.cnblogs.com/tangm421/p/17622894.html


set -u

# must exist: automake cmake
check_tool() {
  sudo apt install -y autoconf automake yasm \
	  python3-distutils

  cmake --version 1> /dev/null 2> /dev/null
  if [ $? -eq 127 ]; then echo "install cmake first!"; exit
  fi
  cmake --version | head --lines=1
}

check_env() {
  TOKEN="pat_kdfVXr4YGy1Edda7pnjGm8An"
  sudo apt-get update 
  sudo apt-get install -yq gnupg2 wget lsb-release
  
  sudo wget --http-user=18795975517@163.com --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
  sudo chmod 666 /etc/apt/auth.conf
  sudo echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
  sudo chmod 666 /etc/apt/auth.conf

  sudo echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list

  sudo echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list

  sudo apt-get update
  sudo apt-get build-dep freeswitch
}

check_env2() {
  sudo apt install -y \
	libtool zlib1g-dev libcurl4-openssl-dev libpcre3-dev \
       	libopus-dev libspeex-dev libspeexdsp-dev libldns-dev libssl-dev \
        liblua5.3-dev libshout-dev libmpg123-dev libmp3lame-dev \
       	libsndfile-dev libopus-dev libedit-dev libnode-dev

  # picture
  sudo apt install -y \
	  libtiff-dev libtiff5-dev libjpeg-dev

  sudo apt install --yes build-essential pkg-config \
	  libsndfile1-dev unzip liblua5.2-dev liblua5.2-0  \
          unixodbc-dev ntpdate libxml2-dev sngrep
}

install_db() {
  sudo apt install -y \
	  libpq-dev libpq5 \
	  libmongoc-dev mariadb-server libsqlite3-dev
}

install_module-ffmpeg() {
  sudo apt install -y \
    libavresample-dev libavformat-dev libswscale-dev

  sudo apt install -y libx264-dev libvlc-dev
}

install_libks() {
  sudo apt install -y uuid-dev

  cd /usr/local/src
  if [ ! -d libks ]; then
    # Don't add --depth 1
    sudo git clone https://github.com/signalwire/libks.git
  fi
  cd libks
  sudo cmake . 
  sudo make
  sudo make install
  sudo ldconfig 
  cd ~/Desktop  
}

install_signalwire() {
  cd /usr/local/src
  if [ ! -d "signalwire-c" ]; then
    sudo git clone https://github.com/signalwire/signalwire-c.git
  fi
  cd signalwire-c
  sudo cmake .
  sudo make
  sudo make install
  cd ~/Desktop
}

# need version 3.0+
install_spanDSP() {
  sudo apt install -y libtiff-dev

  local op=0
  read -p "install spanDSP3? [Y/n] " op
  case $op in
    Y | y | 1) ;;
    *) return 0
  esac
  
  if [ ! -d spandsp ]; then
    git clone --depth 35 https://github.com/freeswitch/spandsp.git
  fi
  cd spandsp
  git checkout 0d2e6ac
  ./bootstrap.sh
  ./configure
  make
  sudo make install
  sudo ldconfig
  cd ..
}

# need version 1.13+
install_sofiaSip() {
  local op=0
  read -p "install sofia-sip? [Y/n] " op
  case $op in
    Y | y | 1) ;;
    *) return 0
  esac

  if [ ! -d sofia-sip ]; then
    git clone -b v1.13.17 --depth 1 https://github.com/freeswitch/sofia-sip.git
  fi
  cd sofia-sip
  ./bootstrap.sh
  ./configure
  make
  sudo make install
  cd ..
}

# ----- ----- ----- -----

check_tool
check_env2

install_db
install_module-ffmpeg

# install libks first
sudo ldconfig -p | grep libks
if [ $? -eq 1 ]; then install_libks
fi

sudo ldconfig && ldconfig -p | grep signalwire
if [ $? -eq 1 ]; then install_signalwire
fi

#install_spanDSP
#install_sofiaSip

cd ~/Desktop

if [ ! -d freeswitch ]; then
  git clone --depth 2 --branch v1.10 https://github.com/signalwire/freeswitch.git
fi

cd freeswitch

./bootstrap.sh -j

./configure

op=0
read -p "start make and install? [Y/n] " op
case $op in
  Y | y | 1) make;;
  *) exit
esac

sudo make install
sudo make cd-sounds-install
sudo make cd-moh-install 

cd ..

# setup env
echo "export PATH=\$PATH:/usr/local/freeswitch/bin" >> ~/.bashrc
source ~/.bashrc

echo  "try running: sudo freeswitch -nonat "
