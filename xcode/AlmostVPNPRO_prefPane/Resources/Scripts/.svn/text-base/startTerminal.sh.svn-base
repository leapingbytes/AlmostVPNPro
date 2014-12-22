#!/bin/bash
declare PORT=$1
declare TITLE=$2

#cat <<EOF | /usr/bin/osascript >>/tmp/shell.log 2>&1 &
#	tell application "Terminal" to launch
#	tell application "Terminal" to do script "/usr/bin/telnet localhost $PORT; echo -e '\nconnection closed. hit enter to close window'; read rc; exit"
#EOF

cat >/tmp/avpn.term <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>WindowSettings</key>
	<array>
		<dict>
			<key>TitleBits</key>
			<string>8</string>
			<key>CustomTitle</key>
			<string>${TITLE}</string>
			<key>Shell</key>
			<string>telnet localhost ${PORT}</string>
		</dict>
	</array>
</dict>
</plist>
EOF

open /tmp/avpn.term