#!/system/bin/sh
echo "Content-type: text/html"
echo ""

port="868"
echo "<h1>Starting Telnetd on Loopback Device port $port</h2>"
echo "<pre>"
/system/bin/busybox telnetd -b 127.0.0.1:$port -l /system/bin/sh
echo "</pre>"
