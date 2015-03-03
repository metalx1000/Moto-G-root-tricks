#!/system/bin/sh
echo "Content-type: text/html"
echo ""

echo ""
eval $(echo "$QUERY_STRING"|awk -F'&' '{for(i=1;i<=NF;i++){print $i}}')
tmp=`/sbin/busybox httpd -d $echo`
echo "<h1>$tmp</h1>"
echo "<br>"
echo "$echo"
echo "<br>"
echo "$QUERY_STRING"
