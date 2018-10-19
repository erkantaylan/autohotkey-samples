;~Capslock::
;KeyWait, 1, D  ; Wait for user to physically release it.
;MsgBox You pressed and released the Capslock key.
;return

;Transform, CtrlC, Chr, 3 ; Store the character for Ctrl-C in the CtrlC var. 
;Input, OutputVar, L1 M
;if OutputVar = %CtrlC%
;    MsgBox, You pressed Control-C.
;

^!u::  ; Control+Alt+U hotkey.
MsgBox Copy some Unicode text onto the clipboard, then return to this window and press OK to continue.
Transform, ClipUTF, Unicode
Clipboard = Transform, Clipboard, Unicode, %ClipUTF%`r`n
MsgBox The clipboard now contains the following line that you can paste into your script. When executed, this line will cause the original Unicode string you copied to be placed onto the clipboard:`n`n%Clipboard%
return
