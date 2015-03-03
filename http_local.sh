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

echo "Getting http config files..."
wget "https://github.com/metalx1000/Moto-G-root-tricks/blob/master/www.zip?raw=true" -O www.zip
unzip www.zip
rm www.zip
chmod +x www/cgi-bin/*

echo -n "Please Enter a Username: "
read user

echo -n "Please Enter a Password: "
read password

echo "/:$user:$password" >> www.conf

echo "Adding Service to Startup..."
cat << EOF >> init.rc

service init_my /init_my.sh
    class main
    user root
    group root
    oneshot

EOF

echo "Creating Custom init Script..."
cat << EOS > init_my.sh
#!/system/bin/sh
echo "loading..."
sleep 30
cd /www
/sbin/busybox httpd -p $port -c ../www.conf
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
adb reboot bootloader

echo "Loading $img2 to phone's RAM..."
fastboot boot ./$img2
#adb shell
