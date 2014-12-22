#!/bin/bash
function getPid() {
	 ps -axww -O user | grep $1 | grep $2 | grep -v grep | cut -c 1-5 | head -1
}

function testForAnyPid() {
	local pidToTest=$1
	if [ $( ps -o pid -p $pidToTest | wc -l ) != 1 ]
	then
		echo $pidToTest
	else
		echo 0
	fi
}

function waitForAnyPid() {
	local pidToWait=$1
	if [ "$pidToWait" = "" ]
	then
		echo 0
		return
	fi
	local waitTimeout=${2:-5}
	
	for (( i=0 ; i < $waitTimeout ; i++ )) 
	do
		if [ $( testForAnyPid $pidToWait ) != 0 ]
		then
			sleep 1
		else
			echo $i
			return
		fi
	done
	echo $i
}

function waitForAnyProcess() {
	local processPid=$( getPid $1 $2 )
	waitForAnyPid $processPid $3 >/dev/null 2>&1
}

function printResult() {
	if [ "$?" = "0" ]
	then
		echo "Success"
	else
		echo "Fail"
	fi
}
echo "Uninstalling AlmostVPNPRO service "
[ -f ~/Library/Application\ Support/AlmostVPNPRO/AlmostVPNServer  ] && \
	~/Library/Application\ Support/AlmostVPNPRO/AlmostVPNServer --uninstallService
waitForAnyProcess AlmostVPNServer AlmostVPNServer 10	
[ ! -f /Library/StartupItems/AlmostVPN ] ; printResult
echo "Remove AlmostVPNPRO preferences "
rm -rf ~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist ; printResult
echo "Remote AlmostVPNPRO App Support folder "
rm -rf ~/Library/Application\ Support/AlmostVPNPRO && echo ; printResult
echo "Remote AlmostVPNPRO preference pane"
rm -rf ~/Library/PreferencePanes/AlmostVPNPRO*  && echo ; printResult
echo "Remote AlmostVPNPRO secure storage file"
rm -rf ~/.almostVPN.ssp && echo ; printResult
echo "AlmostVPN/PRO Uninstalled"