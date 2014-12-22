-- Panel.applescript
-- AlmostVPNPRO.Uninstaller
on clicked theObject
	if name of theObject is "Cancel" then
		close panel (window of theObject)
	else if name of theObject is "OK" then
		close panel (window of theObject) with result 1
	end if
end clicked

--  Created by andrei tchijov on 8/20/06.
--  Copyright (c) 2003 Leaping Bytes, LLC. All rights reserved.
