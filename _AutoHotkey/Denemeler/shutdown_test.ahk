;          seconds          minutes                hours
delay := (1000 * 0 ) + (60 * 1000 * 30) + (3600 * 1000 * 0 )
Sleep, %delay%
; Shutdown, 1

; Force a reboot (reboot + force = 2 + 4 = 6):
Shutdown, 6

; Call the Windows API function "SetSuspendState" to have the system suspend or hibernate.
; Windows 95/NT4: Since this function does not exist, the following call would have no effect.
; Parameter #1: Pass 1 instead of 0 to hibernate rather than suspend.
; Parameter #2: Pass 1 instead of 0 to suspend immediately rather than asking each application for permission.
; Parameter #3: Pass 1 instead of 0 to disable all wake events.
; DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
