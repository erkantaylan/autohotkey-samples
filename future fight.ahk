active := False


Loop, 
{
	If (active == True) {
		Send, {Numpad0}
		Sleep, 700
		Combo()
		Sleep, 1000
		Combo()
		Sleep, 1000
		Combo()
		Sleep, 1000
		Combo()
	}
}

#Persistent
SetTimer, WatchCursor, 100
return

WatchCursor:
ToolTip, %active%
return

F1::
active := True
Return

F2::
active := False
Return


Combo() {
	Send, {Numpad5}
	Sleep, 100
	Send, {Numpad4}
}