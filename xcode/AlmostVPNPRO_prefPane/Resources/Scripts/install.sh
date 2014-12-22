#!/bin/bash
#if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" ]
#then
#	echo "ERROR : Not enough arguments"
#	echo "  USAGE : instal.sh (check|install|remove) <user name> <path to resources> <path to support> <path to preferences>"
#	# exit -3
#fi

declare ACTION="$1"
declare AVPN_USER="${2:-$USER}"
declare AVPN_RESOURCES="${3:-$( pwd )}"
declare AVPN_SUPPORT="${4:-~/Library/Application Support/AlmostVPNPRO}"
declare AVPN_PREFERENCES="${5:-~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist}"

declare AVPN="AlmostVPN"
declare AVPN_SI="/Library/StartupItems/$AVPN"

declare OSASCRIPT="/usr/bin/osascript"

echo "AlmostVPN:install.sh : id: $( id )" >/dev/console
echo "AlmostVPN:install.sh : ACTION = $ACTION : ($1)" >/dev/console
echo "AlmostVPN:install.sh : AVPN_USER = $AVPN_USER : ($2)" >/dev/console
echo "AlmostVPN:install.sh : AVPN_RESOURCES = $AVPN_RESOURCES : ($3)" >/dev/console
echo "AlmostVPN:install.sh : AVPN_SUPPORT = $AVPN_SUPPORT : ($4)" >/dev/console
echo "AlmostVPN:install.sh : AVPN_PREFERENCES = $AVPN_PREFERENCES : ($5)" >/dev/console
#
# Locate AlmostVPNServer
#
function locateAlmostVPNServer() {
	local AVPN_SERVER_PATH="${AVPN_SUPPORT}/AlmostVPNServer"

	if [ ! -f "$AVPN_SERVER_PATH" ]
	then
		AVPN_SERVER_PATH="/Library/Application Support/AlmostVPNPRO/AlmostVPNServer"
	fi
	echo "$AVPN_SERVER_PATH"
}

function checkStartupItem() {
	local message="OK"
	local rc="0" 

	[ $rc = 0 -a ! -d "$AVPN_SI" ] && message="Directory not found"&&rc="1"
	[ $rc = 0 -a ! -f "$AVPN_SI/StartupParameters.plist" ] && message="plist not found"&&rc="2"
	[ $rc = 0 -a ! -x "$AVPN_SI/$AVPN" ] && message="Script not found"&&rc="2"
	[ $rc = 0 -a ! -x "$AVPN_SI/$AVPN.env" ] && message="Env not found"&&rc="2"
	
	echo "$message"
	return $rc
}

function installStartupItem() {
	mkdir -p $AVPN_SI
	
	cp $AVPN_RESOURCES/Install/StartupItem/* $AVPN_SI

cat <<END >$AVPN_SI/$AVPN.env
declare AVPN_USER="$AVPN_USER"
declare AVPN_RESOURCES="$AVPN_RESOURCES"
declare AVPN_SUPPORT="$AVPN_SUPPORT"
declare AVPN_PREFERENCES="$AVPN_PREFERENCES"
declare AVPN_SERVER_PATH="$( locateAlmostVPNServer )"
END

	chmod +x $AVPN_SI/$AVPN	
	chmod +x $AVPN_SI/$AVPN.env	
}

function removeStartupItem() {
	/sbin/SystemStarter stop $AVPN
	rm -rf $AVPN_SI
}

function findLoginItem() {
	local appSuffix=${1:-$AVPN_RESOURCES/AVPN.Agent.app}
"${OSASCRIPT}" <<EOF
tell application "System Events"
	set allPathes to path of every login item
	set itemCount to 1
	repeat with onePath in allPathes
		if onePath ends with "$appSuffix" then
			return itemCount
		end if
		set itemCount to itemCount + 1
	end repeat
	return 0
end tell
EOF
}

function checkLoginItem() {
	if [ "$( findLoginItem $1 )" != "0" ]
	then
		echo -n "OK"
		return 0
	else
		echo -n "Not installed"
		return 1
	fi
}

function installLoginItem() {
	local appPath=${1:-$AVPN_RESOURCES/AVPN.Agent.app}
	echo "installLoginItem : $appPath : START" >/dev/console
	
	removeLoginItem $appPath
#    make new login item at the end of login items with properties { path:"$AVPN_RESOURCES/AVPN.Agent.app", hidden:false }

	echo "installLoginItem : make new login item $appPath " >/dev/console
"${OSASCRIPT}" <<EOF
tell application "System Events"
	make new login item with properties { path:"${appPath}", hidden:false } at end
end tell
EOF
	echo "installLoginItem : open $appPath " >/dev/console
	/usr/bin/open ${appPath}

	echo "installLoginItem : $appPath : DONE" >/dev/console
}

function removeLoginItem() {
	local appPath=${1:-$AVPN_RESOURCES/AVPN.Agent.app}
	local appBaseName=$( basename $appPath )
	local appPid=$( ps -axww | grep $appBaseName | grep -v install.sh | grep -v grep | cut -c1-5 )
	if [ -n "$appPid" ] 
	then
		echo "removeLoginItem : $appBaseName : killing $appPid" > /dev/console
		kill -9 $appPid
	fi
	local itemIndex="$( findLoginItem $appBaseName )" 
	
	if [ "$itemIndex" = 0 ]
	then
		echo "removeLoginItem : $appBaseName : was not installed" > /dev/console
	else
		echo "removeLoginItem : $appBaseName : removing $itemIndex" > /dev/console
"${OSASCRIPT}" <<EOF
tell application "System Events"
    delete login item $itemIndex
end tell
EOF
	fi
}

function checkWidget() {
	local widgetPath=$( ps -axww | grep DashboardClient | grep AlmostVPN | grep -v grep | cut -d\/ -f2- | cut -d\  -f 2 )
	if [ -n "$widgetPath" -a -f "$widgetPath/AlmostVPN.html" -a -f "$widgetPath/Info.plist" ] 
	then
		echo -n "OK" 
		return 0
	else
		echo -n "Not installed"
		return 1
	fi
}

function installWidget() {
	local widgetPath=${1:-$AVPN_RESOURCES/AlmostVPN.wdgt}
	
	cp -r $widgetPath /tmp
	/usr/bin/open /tmp/AlmostVPN.wdgt
}

function uninstallWidget() {
	local widgetPath=$( ps -axww | grep DashboardClient | grep AlmostVPN | grep -v grep | cut -d\/ -f2- | cut -d\  -f 2 )
	local widgetPid=$( ps -axww | grep DashboardClient | grep AlmostVPN | grep -v grep | cut -c 1-5 )
	[ -n "$widgetPid" ] && kill -9 $widgetPid 
	[ -n "$widgetPath" -a -f "$widgetPath/AlmostVPN.html" -a -f "$widgetPath/Info.plist" ]  && rm -rf $widgetPath
}

function checkAlmostVPN() {
	local message="0:OK"
	local rc="0" 
	
	local subMessage
	subMessage=$( checkStartupItem )
	[ $rc = 0 -a $? != 0 ] && message="1|Startup Item : $subMessage" && rc="1"
	subMessage=$( checkLoginItem )
	[ $rc = 0 -a $? != 0 ] && message="2|Login Item : $subMessage" && rc="2"
	
	echo -n "$message"
	return $rc
}

function installAlmostVPN() {
	installStartupItem
	installLoginItem
}

function removeAlmostVPN() {
	removeLoginItem
	removeStartupItem
}

function uninstallAlmostVPN {
	removeAlmostVPN
	su - $AVPN_USER -c "rm -rf ~/Library/Application\ Support/AlmostVPNPRO"
	su - $AVPN_USER -c "rm -f ~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist"
	su - $AVPN_USER -c "rm -rf ~/Library/PreferencePanes/AlmostVPNPRO_prefPane.prefPane"
}

case $ACTION in
	check)
		checkAlmostVPN
		;;
	checkLoginItem)
		checkLoginItem $6
		;;		
	checkWidget)
		checkWidget $6
		;;		
	install)
		installAlmostVPN
		;;
	installStartupItem)
		installStartupItem
		;;
	installLoginItem)
		installLoginItem $6
		;;
	installWidget)
		installWidget 
		;;
	uninstallStartupItem)
		removeStartupItem
		;;
	uninstallLoginItem)
		removeLoginItem $6
		;;
	uninstallWidget)
		uninstallWidget 
		;;
	remove)
		removeAlmostVPN
		;;
	uninstall)
		uninstallAlmostVPN
		;;
esac

