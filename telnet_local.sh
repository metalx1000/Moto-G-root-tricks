#!/bin/bash

#check if root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user"
  echo "Trying to restart script as sudo"
  sudo $@
  exit 
fi

#check for needed programs
if [ ! -f "/usr/bin/abootimg" ] || [ ! -f "/usr/bin/fastboot" ] || [ ! -f "/usr/bin/adb" ]
then
  apt-get install abootimg android-tools-fastboot android-tools-adb -y
fi

#get stock boot img
url="https://github.com/metalx1000/Moto-G-root-tricks/blob/master/img/stock_boot.img?raw=true"
dir="work"
mkdir $dir

wget "$url" -O "$dir/boot.img"

cd $dir
#unpack stock boot img
img=boot.img
img2=boot2.img

file $img
#head -n1 $img
mkdir boot
cd boot
abootimg -x ../$img
file initrd.img
mkdir ramdisk
cd ramdisk
gunzip -c ../initrd.img | cpio -i

#change selinux to permissive
#by adding androidboot.selinux=permissive  to the “cmdline” in the bootimg.cfg file
vim boot/bootimg.cfg


