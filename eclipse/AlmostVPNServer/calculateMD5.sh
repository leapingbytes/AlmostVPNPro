#!/bin/bash
declare SH_SEARCH_PATH=$1
cat <<EOF 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EOF
cd $SH_SEARCH_PATH
for shfile in *.sh
do
	fileName=$shfile
	md5Sum=$( md5 -q $fileName )
	cat <<EOF
		<key>${fileName}</key>
		<dict>
			<key>fileName</key>
			<string>${fileName}</string>
			<key>md5</key>
			<string>${md5Sum}</string>
		</dict>
EOF

done
cd ../../../AlmostVPNJNI.macosx/build/Release
for jnifile in *.jnilib
do
	fileName=$jnifile
	md5Sum=$( md5 -q $fileName )
	cat <<EOF
		<key>${fileName}</key>
		<dict>
			<key>fileName</key>
			<string>${fileName}</string>
			<key>md5</key>
			<string>${md5Sum}</string>
		</dict>
EOF
done

cat <<EOF
</dict>
</plist>
EOF
