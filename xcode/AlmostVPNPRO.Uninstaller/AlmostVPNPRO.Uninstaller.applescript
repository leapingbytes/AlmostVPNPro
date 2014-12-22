-- AlmostVPNPRO.Uninstaller.applescript
-- AlmostVPNPRO.Uninstaller

--  Created by andrei tchijov on 8/20/06.
--  Copyright 2006 Leaping Bytes, LLC. All rights reserved.

property sudoUser : ""
property sudoPassword : ""

global doGroup1
global doGroup2
global doGroup3
global doGroup4

global doGroupFlags

global group1Box
global group2Box
global group3Box
global group4Box

global groupBoxes

global showAs
global doDryRun
global showLog

global drawerLog
global LogController

global LogClearButton
global LogSaveAsButton

global cancelButton
global uninstallButton

-- global thingsToDo

property thingsToDo : {Â
	{name:"group1", title:"Uninstall AlmostVPN/PRO Backend", needsSudo:true, commands:{Â
		{name:"command1", unixCommand:"/sbin/SystemStarter stop AlmostVPN", descriptive:"stop AlmostVPN service", dryRunCommand:"ps -ax | grep AlmostVPNServer | grep -v grep"}, Â
		{name:"command2", unixCommand:"rm -rf /Library/StartupItems/AlmostVPN", descriptive:"delete /Library/StartupItems/AlmostVPN", dryRunCommand:"find /Library/StartupItems/AlmostVPN"}}}, Â
	{name:"group2", title:"Remove AlmostVPN/PRO Support Folder", needsSudo:false, commands:{Â
		{name:"command1", unixCommand:"rm -rf ~/Library/Application\\ Support/AlmostVPNPRO", descriptive:"delete ~/Library/Application\\ Support/AlmostVPNPRO", dryRunCommand:"find ~/Library/Application\\ Support/AlmostVPNPRO"}, Â
		{name:"command2", unixCommand:"rm -rf /Library/Application\\ Support/AlmostVPNPRO", descriptive:"delete /Library/Application\\ Support/AlmostVPNPRO", dryRunCommand:"find /Library/Application\\ Support/AlmostVPNPRO"}}}, Â
	{name:"group3", title:"Uninstall AlmostVPN/PRO Binaries", needsSudo:false, commands:{Â
		{name:"command1", unixCommand:"killall -m AVPN.Agent AlmostVPNProMenuBar", descriptive:"stop AlmostVPN agent and menu bar", dryRunCommand:"killall -s -m AVPN.Agent AlmostVPNProMenuBar"}, Â
		{name:"command2", unixCommand:"rm -rf ~/Library/PreferencePanes/AlmostVPNPRO.prefPane", descriptive:"delete ~/Library/PreferencePanes/AlmostVPNPRO.prefPane", dryRunCommand:"find ~/Library/PreferencePanes/AlmostVPNPRO.prefPane"}, Â
		{name:"command3", unixCommand:"rm -rf /Applications/AlmostVPNProMenuBar.app", descriptive:"delete /Applications/AlmostVPNProMenuBar.app", dryRunCommand:"find /Applications/AlmostVPNProMenuBar.app"}}}, Â
	{name:"group4", title:"Uninstall AlmostVPN/PRO Configuration Files", needsSudo:false, commands:{Â
		{name:"command1", unixCommand:"mv ~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist ~/.Trash", descriptive:"move to trash ~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist", dryRunCommand:"ls  ~/Library/Preferences/com.leapingbytes.AlmostVPNPRO.plist"}, Â
		{name:"command2", unixCommand:"mv ~/.almostVPN.ssp ~/.Trash", descriptive:"move to trash ~/.almostVPN.ssp", dryRunCommand:"ls  ~/.almostVPN.ssp"}}} Â
		}

on displayCommandsAs(commandFormat)
	tell window "Main"
		repeat with i from 1 to count thingsToDo
			set theGroup to item i of thingsToDo
			set groupBox to box ("group" & i)
			set title of groupBox to ("" & i & ") " & (get title of theGroup))
			set groupCommands to (get commands of theGroup)
			repeat with j from 1 to count groupCommands
				set command to item j of groupCommands
				if commandFormat is "unix" then
					set commandString to (get unixCommand of command)
				else
					set commandString to (get descriptive of command)
				end if
				set commandTextField to text field ("command" & j) of groupBox
				set string value of commandTextField to commandString
			end repeat
		end repeat
	end tell
end displayCommandsAs

--		echo $SUDO_PASSWORD | su $SUDO_USER -c "echo $SUDO_PASSWORD | /usr/bin/sudo -S /bin/bash -c \"source $BASE_DIR/utils.sh;$command\""

on doUnixCommand(description, needsSudo, command)
	if needsSudo then
		set iAm to do shell script "whoami"
		if iAm is sudoUser then
			set command to "echo \"" & sudoPassword & "\" | sudo -S " & command
		else
			set command to "echo \"" & sudoPassword & "\" | su " & sudoUser & " -c \"echo \\\"" & sudoPassword & "\\\" | sudo -S " & command & "\""
		end if
	end if
	set commandResult to do shell script (command & " 2>&1 ; echo ")
	tell LogController to addResultToLog("" & commandResult)
end doUnixCommand

on doUninstallCommand(gIndex, group, cIndex, command)
	set needsSudo to false
	if state of doDryRun is 1 then
		set unixCommand to (get dryRunCommand of command)
	else
		set unixCommand to (get unixCommand of command)
		set needsSudo to (get needsSudo of group)
	end if
	if needsSudo then
		tell LogController to addResultToLog("#" & unixCommand)
	else
		tell LogController to addResultToLog("$" & unixCommand)
	end if
	set thisGroupBox to item gIndex of groupBoxes
	set thisCommandProgress to progress indicator ("command" & cIndex & "Running") of thisGroupBox
	set uses threaded animation of thisCommandProgress to true
	tell thisCommandProgress to start
	my doUnixCommand((get descriptive of command), needsSudo, unixCommand)
	set uses threaded animation of thisCommandProgress to false
	tell thisCommandProgress to stop
end doUninstallCommand

on doUninstallGroup(gIndex, group)
	tell LogController to addResultToLog("-- " & (get title of group))
	
	set groupBox to box ("group" & gIndex) of window "Main"
	set groupCommands to (get commands of group)
	repeat with j from 1 to count groupCommands
		set command to item j of groupCommands
		my doUninstallCommand(gIndex, group, j, command)
	end repeat
end doUninstallGroup

on doUninstall()
	if state of doDryRun is 1 then
		set state of showLog to 1
		tell drawerLog to open drawer on bottom edge
	end if
	repeat with i from 1 to count thingsToDo
		set theGroup to item i of thingsToDo
		if state of (item i of doGroupFlags) is 1 then
			my doUninstallGroup(i, theGroup)
		end if
	end repeat
end doUninstall

on clicked theObject
	if theObject is equal to doGroup1 and (sudoUser & sudoPassword) is "" then
		display panel window "AskPasswordPanel" attached to window "Main"
	else if theObject is equal to showAs then
		set selectedRow to current row of showAs
		if selectedRow is 1 then
			my displayCommandsAs("descriptive")
		else
			my displayCommandsAs("unix")
		end if
	else if theObject is equal to showLog then
		if state of showLog is 1 then
			tell drawerLog to open drawer on bottom edge
		else
			tell drawerLog to close drawer
		end if
	else if theObject is equal to uninstallButton then
		my doUninstall()
	else if theObject is equal to LogClearButton then
		tell LogController to clearLog()
	else if theObject is equal to LogSaveAsButton then
		set logFile to choose file name with prompt "Save Log As" default name "AlmostVPN Uninstall Log.txt"
		tell LogController to saveLogInFile(logFile)
	end if
end clicked

on panel ended thePanel with result theResult
	if theResult is 1 then
		tell thePanel
			set sudoUser to contents of text field "AskPasswordUserName"
			set sudoPassword to contents of text field "AskPasswordPassword"
		end tell
		
		if sudoUser is not "" and sudoPassword is not "" then
			set image of (button "Lock" of window "Main") to image of (button "unlocked" of window "Main")
			set state of doGroup1 to 1
		else
			set state of doGroup1 to 0
		end if
	else
		set state of doGroup1 to 0
	end if
end panel ended

on pathToScripts()
	set appPath to (path to me from user domain) as text
	return (appPath & "Contents:Resources:Scripts:") as text
end pathToScripts

on loadScript(scriptName)
	return load script file (my pathToScripts() & scriptName & ".scpt")
end loadScript

on launched theObject
	set logLib to my loadScript("Log Controller")
	set LogController to LogController of logLib
	tell LogController to initialize()
end launched

on awake from nib theObject
	tell window "Main"
		set doGroup1 to button "doGroup1"
		set doGroup2 to button "doGroup2"
		set doGroup3 to button "doGroup3"
		set doGroup4 to button "doGroup4"
		
		set doGroupFlags to {doGroup1, doGroup2, doGroup3, doGroup4}
		
		set group1Box to box 1
		set group2Box to box 2
		set group3Box to box 3
		set group4Box to box 4
		
		set groupBoxes to {group1Box, group2Box, group3Box, group4Box}
		
		set showAs to matrix "showAs"
		set doDryRun to button "doDryRun"
		set showLog to button "showLog"
		
		set drawerLog to drawer "Log"
		
		set LogClearButton to button "LogClear" of drawer "Log"
		set LogSaveAsButton to button "LogSaveAs" of drawer "Log"
		
		set cancelButton to button "Cancel"
		set uninstallButton to button "Uninstall"
	end tell
	my displayCommandsAs("descriptive")
end awake from nib

(*
on opened theObject
end opened
*)

