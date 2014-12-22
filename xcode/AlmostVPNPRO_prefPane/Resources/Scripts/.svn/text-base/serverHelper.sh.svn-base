#!/bin/bash

# ------------------------------------------------------------------------------------
# Figure out BASE_DIR and load $BASE_DIR/utils.sh
# ------------------------------------------------------------------------------------
BASE_DIR=`dirname $0`
BASE_DIR=`cd $BASE_DIR; pwd`

. $BASE_DIR/utils.sh

# ------------------------------------------------------------------------------------
# global declarations
# ------------------------------------------------------------------------------------
declare JAVA="/System/Library/Frameworks/JavaVM.framework/Versions/1.4/Commands/java"

declare ALMOSTVPN_CLASSPATH="$BASE_DIR/AlmostVPN.jar"
declare ALMOSTVPN_MAIN_CLASS="com.leapingbytes.almostvpn.tool.Main"
# ------------------------------------------------------------------------------------
# define funcitons
# ------------------------------------------------------------------------------------

function sendCommandWithParameter() {
	$JAVA -cp $ALMOSTVPN_CLASSPATH -Dalmostvpn.classpath=$ALMOSTVPN_CLASSPATH $ALMOSTVPN_MAIN_CLASS $1 $2
}

function sendCommand() {
	sendCommandWithParameter $1
}
# ------------------------------------------------------------------------------------
# parse arguments
# ------------------------------------------------------------------------------------
case $1 in
	+start)
		sendCommandWithParameter $1 $2
	;;
	+stop)
		sendCommandWithParameter $1 $2
	;;
	+status)
		sendCommandWithParameter $1 stdout
	;;
	+exit)
		sendCommand $1
	;;
esac