; For Touch/Type Cover
; ---------------------------------------------------------
; On-screen Caps Lock Indicator
CapsLock::
GetKeyState, state, CapsLock, T  ;  D if CapsLock is ON or U otherwise.
 
if state = D
{
	Send,QQWRQQQ
}
;else
;{
;ToolTip, Caps Lock is DISABLED ;
;SetTimer, RemoveToolTip, 3000 ; Display ToolTip for 5 seconds
;}
return
 
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return