#!/bin/bash

img=boot.img
img2=boot2.img
port=9999

url="https://github.com/metalx1000/Moto-G-root-tricks/blob/master/img/stock_boot.img?raw=true"
dir="work"

#check if root user
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user"
  echo "Trying to restart script as sudo"
  sudo $0 $@
  exit 
fi

echo "Removing any previous work..."
rm -fr $dir

mkdir $dir

if [ "$1" = "remote" ]
then
  echo """
    Warning!!!
    This is not safe!
    By using 'remote' option you
    are granting root access to
    anyone on your network
"""
  sleep 2
  access=""
else
  access="-b 127.0.0.1"
fi


#check for needed programs
if [ ! -f "/usr/bin/abootimg" ] || [ ! -f "/usr/bin/fastboot" ] || [ ! -f "/usr/bin/adb" ]
then
  apt-get install abootimg android-tools-fastboot android-tools-adb -y
fi

#get stock boot img
wget -c "$url" -O "$dir/$img"

cd $dir
#unpack stock boot img
file $img
#head -n1 $img
mkdir boot
cd boot

abootimg -x ../$img
file initrd.img

echo "updating bootimg.cfg"
rm bootimg.cfg
wget "https://raw.githubusercontent.com/metalx1000/Moto-G-root-tricks/master/config/bootimg.cfg"

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
/system/bin/busybox telnetd -p $port -l /system/bin/sh $access
#/sbin/busybox telnetd -p 9999 -l /system/bin/sh

EOS
chmod 777 init_my.sh

echo "Getting Busybox for boot image..."
wget "https://github.com/metalx1000/Moto-G-root-tricks/blob/master/bin/busybox?raw=true" -O sbin/busybox
chmod 777 sbin/busybox

#repack boot img
cd ../
pwd
rm -fr initrd_new.img
abootimg-pack-initrd initrd_new.img ramdisk/
abootimg --create ../$img2 -f bootimg.cfg -k zImage -r initrd_new.img
cd ../
sudo adb reboot bootloader
echo "--"
ls
echo "--"
echo "Loading $img2 to phone's RAM..."
sudo fastboot boot ./$img2
#sudo adb shell
