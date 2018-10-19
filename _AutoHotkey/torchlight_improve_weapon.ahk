0::
;WinWait, , 
;IfWinNotActive, , , WinActivate, , 
;WinWaitActive, , 
;MouseClick, left,  270,  12
;Sleep, 50
;WinWait, Torchlight, 
;IfWinNotActive, Torchlight, , WinActivate, Torchlight, 
;WinWaitActive, Torchlight, 
;MouseClick, left,  626,  344
Sleep, 50
Send, {SHIFTDOWN}
MouseClick, left,  1075,  538
Sleep, 50
Send, {SHIFTUP}
MouseClick, left,  258,  441
Sleep, 50
Send, {ENTER}
Sleep, 50
Send, {ENTER}
Sleep, 50
Send, i