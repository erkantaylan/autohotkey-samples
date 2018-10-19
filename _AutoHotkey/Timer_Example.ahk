
#Include Timer.ahk

F1::
	If Timer("Bash")            ; Check if Timer "Bash" is finished
	{
		Send 1              ; Send key press to game
		Timer("Bash",6000)  ; Reset Timer "Bash" with 6 seconds
		Sleep 500           ; Global cooldown of game before any other ability can be activated 
	}
	If Timer("Thrash")
	{
		Send 2
		Timer("Thrash",5000)
		Sleep 500
	}
	If Timer("Trash")
	{
		Send 3
		Timer("Trash",8000)
		Sleep 500
	}
	If Timer("Slash")
	{
		Send 4
		Timer("Slash",4500)
		Sleep 500
	}
	If Timer("Crash")
	{
		Send 5
		Timer("Crash",17250)
		Sleep 500
	}
return