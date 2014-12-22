export ALMOST_VPN_VERSION="1.6"
BUILD_NUMBER=$( cat .avpnBuildNumber )
export ALMOST_VPN_MILESTONE="$BUILD_NUMBER"
echo $(( $BUILD_NUMBER + 1 )) >.avpnBuildNumber
export TIMESTAMP=$( date "+%d/%m/%y %H:%M" )
cd ~/Work/LeapingBytes/AlmostVPNPRO/eclipse
( cd AlmostVPNServer ; \
	echo "$ALMOST_VPN_VERSION $ALMOST_VPN_MILESTONE $TIMESTAMP" >bin/com/leapingbytes/almostvpn/util/timestamp.txt
	ant 
)
cd ~/Work/LeapingBytes/AlmostVPNPRO/xcode
( cd AlmostVPNServer.starter; xcodebuild -target AlmostVPNServer -configuration Release clean )
( cd AlmostVPNPRO_prefPane ; \
	xcodebuild -target AlmostVPNProMenuBar -configuration Release clean \
	xcodebuild -target AlmostVPNPRO_prefPane -configuration Release clean \
)
( cd AlmostVPNPRO_prefPane ; \
	xcodebuild -target AlmostVPNPRO_prefPane -configuration Release build \
		"ALMOST_VPN_VERSION=$ALMOST_VPN_VERSION" \
		"ALMOST_VPN_MILESTONE=$ALMOST_VPN_MILESTONE" \
		"ALMOST_VPN_DATE=$TIMESTAMP"\
)
