#!/bin/bash

#check if root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user"
  echo "Trying to restart script as sudo"
  sudo $0
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

wget -c "$url" -O "$dir/boot.img"

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

echo "Adding Service to Startup..."
cat << EOF >> init.rc

service init_my /init_my.sh
    class main
    user root
    group root
    oneshot

EOF

echo "Creating Custom init Script..."
cat << EOS >> init_my.sh
#!/system/bin/sh
echo "loading..."
sleep 30
/system/bin/busybox telnetd -p 9999 -l /system/bin/sh

EOS
chmod 777 init_my.sh


#change selinux to permissive
#by adding androidboot.selinux=permissive  to the “cmdline” in the bootimg.cfg file
#vim boot/bootimg.cfg
cd ../
sed -i "s/utags/utags androidboot.selinux=permissive/g" bootimg.cfg




