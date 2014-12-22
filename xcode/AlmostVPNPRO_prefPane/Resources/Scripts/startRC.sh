
tell application "Remote Desktop"
	set allComputers to computers
	repeat with i from 1 to count allComputers
		set aComputer to item i of allComputers
		if name of aComputer is "yasha" then
			control aComputer
		end if
	end repeat
end tell
