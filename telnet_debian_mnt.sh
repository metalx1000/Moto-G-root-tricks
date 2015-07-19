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
  cat << EOM
    Warning!!!
    This is not safe!
    By using 'remote' option you
    are granting root access to
    anyone on your network
EOM
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
#/system/bin/busybox telnetd -p $port -l /system/bin/sh $access
/sbin/busybox telnetd -p $port -l /system/bin/sh $access

EOS
chmod 777 init_my.sh

cat << DEB > sbin/debian
#!/system/bin/sh
#mounts and chroots debian system on Android
#might need to create loop 
#busybox mknod /dev/loop0 b 7 0
#busybox mknod -m640 /dev/block/loop255 b 7 255

#to install this script you need to make system RW
#mmcblk0p5 might change so check 'mount' command
#mount -o remount,rw /dev/block/mmcblk0p5 /system
#on Lollipop run this to stop ld.so ERROR  -- unset LD_PRELOAD
dir=/storage/sdcard1/
chroot=\${dir}debian
img=\${dir}debian_arm.img

mounts () {
  mount -o loop -t ext4 \$img \$chroot
  busybox mount --bind /dev \$chroot/dev
  busybox mount --bind /dev/pts \$chroot/dev/pts
  busybox mount -t proc proc \$chroot/proc
  busybox mount -t sysfs sysfs \$chroot/sys
}

mount|grep "\$chroot"&&echo "Already Mounted"|| mounts

export PATH=\$bin:/usr/bin:/usr/sbin:/bin:\$PATH
export TERM=linux
export HOME=/root
export USER=root

busybox chroot \$chroot /bin/bash
DEB
chmod 777 sbin/debian

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
