^RButton::
;WinWait, AutoHotkey Help, 
;IfWinNotActive, AutoHotkey Help, , WinActivate, AutoHotkey Help, 
;WinWaitActive, AutoHotkey Help, 
;MouseClick, left
;MouseClick, left
;Sleep, 100
Send, {CTRLDOWN}c{CTRLUP}{F10}
;WinWait, , 
IfWinNotActive, , , WinActivate, , 
WinWaitActive, , 
Send, {APPSKEY}
Sleep,100
Send, a
Sleep,100
Send, {ENTER}{F12}
;MouseClick, left,  143,  38
Sleep, 100
;Exit