Joy1::Send {Up}  ; Have button #1 send a left-arrow keystroke.
Joy3::Send {Down} ; Have button #2 send a click of left mouse button.
Joy4::Send {Left}  ; Have button #3 send the letter "a" followed by Escape, Space, and Enter.
Joy2::Send {Right}  ; Have button #4 send a two-line signature.Sincerely,


;Joy5:: ; L1
;Joy6:: ; R1
;Joy7:: ; L2
;Joy8:: ; R2
/*Joy9::
Run Notepad
WinWait Untitled - Notepad
WinActivate
Send, This is the text that will appear in Notepad.{Enter}
return*/

/*#Persistent  ; Keep this script running until the user explicitly exits it.
SetTimer, WatchAxis, 5
return

WatchAxis:
GetKeyState, JoyX, JoyX  ; Get position of X axis.
GetKeyState, JoyY, JoyY  ; Get position of Y axis.
KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).

if JoyX > 70
    KeyToHoldDown = Right
else if JoyX < 30
    KeyToHoldDown = Left
else if JoyY > 70
    KeyToHoldDown = Down
else if JoyY < 30
    KeyToHoldDown = Up
else
    KeyToHoldDown =

if KeyToHoldDown = %KeyToHoldDownPrev%  ; The correct key is already down (or no key is needed).
    return  ; Do nothing.

; Otherwise, release the previous key and press down the new key:
SetKeyDelay -1  ; Avoid delays between keystrokes.
if KeyToHoldDownPrev   ; There is a previous key to release.
    Send, {%KeyToHoldDownPrev% up}  ; Release it.
if KeyToHoldDown   ; There is a key to press down.
    Send, {%KeyToHoldDown% down}  ; Press it down.
return*/