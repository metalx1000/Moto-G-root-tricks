#!/system/bin/sh
echo "Content-type: text/html"
echo ""

div="#########################################"
echo "<pre>"
whoami 2> /sdcard/me.tmp
cat /sdcard/me.tmp
rm /sdcard/me.tmp

echo "$div"

uname -a
echo "$div"
/sbin/busybox ifconfig
echo "$div"
/sbin/busybox df -h
echo "$div"

env

echo "EOF"
echo "</pre>"
