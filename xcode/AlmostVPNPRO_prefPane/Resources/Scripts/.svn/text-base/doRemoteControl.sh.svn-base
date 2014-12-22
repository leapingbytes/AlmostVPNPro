#!/bin/bash
if [ "$1" = "start" ]
then
	if [ "${_rc_type_}" = "VNC" ]
	then
		if [ -n "$_rc_password_" ]
		then
			./chickenpassword ${_rc_password_} ${_rc_host_}
			/Applications/Chicken\ of\ the\ VNC.app/Contents/MacOS/Chicken\ of\ the\ VNC \
				--PasswordFile ~/.vnc.password.${_rc_host_} ${_rc_address_}:${_rc_port_:-5900} >/dev/null 2>&1 &
		else
			/Applications/Chicken\ of\ the\ VNC.app/Contents/MacOS/Chicken\ of\ the\ VNC \
				${_rc_address_}:${_rc_port_:-5900} >/dev/null 2>&1 &
		fi
		PID="$!"
		( sleep 5 ; rm -rf ~/.vnc.password.${_rc_host_} )&
		echo $PID
	else
		echo "As of now, only VNC can be used with 'start to control' option"
		exit 1
	fi
else 
	if [ "$1" = "stop" -a -n "$2" ]
	then
		kill -9 $2 >/dev/null 2>&1
	fi
fi	
exit 0
