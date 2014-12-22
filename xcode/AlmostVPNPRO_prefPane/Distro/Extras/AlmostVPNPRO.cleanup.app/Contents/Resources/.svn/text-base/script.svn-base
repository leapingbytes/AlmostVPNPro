#!/bin/bash

function allInterfaces() {
	ifconfig | grep "^..[0-9]:" | cut -d: -f 1
}

function allAliases() {
	ifconfig | grep "netmask 0xffffffff" | cut -d\  -f 2
}

function deleteAllAliases() {
	for alias in $( allAliases )
	do
		for interface in $( allInterfaces ) 
		do
			/sbin/ifconfig $interface $alias -alias >/dev/null 2>&1
		done
		echo "ifconfig alias $alias has been deleted"
	done
}

function deleteAllMachines() {
	local allMachineNames=$( /usr/bin/nicl . search /machines 1 1 creator AlmostVPN | grep name | cut -d\  -f 2 )
	for name in $allMachineNames
	do
		/usr/bin/nicl . delete /machines/$name
		echo "virtual host name $name has been deleted"
	done
}

function restoreLookupOrder() {
	if [ -d /etc/lookupd ]
	then
		if [ -f /etc/lookupd/hosts ]
		then
			if [ "$( grep CreatedByAlmostVPN /etc/lookupd/hosts )" != "" ] # we created this file
			then
				rm -rf /etc/lookupd/hosts
				
				if [ -f /etc/lookupd/hosts.original.before.almostvpn ]
				then
					mv /etc/lookupd/hosts.original.before.almostvpn /etc/lookupd/hosts
				fi
				kill -HUP $(cat /var/run/lookupd.pid) 
				echo "lookup order has been restored"
			fi
		fi
	fi
}

deleteAllAliases
deleteAllMachines
restoreLookupOrder
