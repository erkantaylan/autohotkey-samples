^2::

; id := 19592
; name := "kivi.exe"
; WinMaximize, %name%

; ID := 19592

; WinGet, active_id, ID, A
; WinMaximize, ahk_id %active_id%
; MsgBox, The active window's ID is "%active_id%".


#Persistent
SetTimer, WatchActiveWindow, 200
return
WatchActiveWindow:
WinGet, ControlList, ControlList, A
ToolTip, %ControlList%
return