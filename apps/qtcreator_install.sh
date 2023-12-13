#!/bin/bash

set -u

sudo apt install -y libglib2.0-bin

ver="12.0.1"

addlogo2favorite() {
  local qtdesktop="org.qt-project.qtcreator.desktop"
  local likelist=`gsettings get org.gnome.shell favorite-apps`
  echo $likelist
  likelist=$(echo $likelist | sed -e "s/]/, '$qtdesktop']/")
  gsettings set org.gnome.shell favorite-apps "$likelist"
}

pkgRun=qt-creator-opensource-linux-x86_64-$ver.run # 200M
if [ ! -f $pkgRun ]; then
  wget --no-verbose \
    https://download.qt.io/official_releases/qtcreator/12.0/$ver/$pkgRun
fi


chmod +777 $pkgRun

# sudo will install in /opt
op=0
echo "qt will install in root? (default not)" op
case $op in 
  Y | y | 1) sudo ./$pkgRun;;
  *) ./$pkgRun
esac

if [ $? -eq 0 ]; then
  echo "export PATH=\$PATH:/opt/qtcreator-$ver/bin" >> ~/.bashrc
  source ~/.bashrc
fi

# ubuntu20+
addlogo2favorite

