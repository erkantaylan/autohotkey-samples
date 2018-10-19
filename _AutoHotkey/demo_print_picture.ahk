; a::


s::
Click, Right
Sleep, 3000
Send, p

WinWait, Print Pictures
Send, {TAB}
Sleep, 50
Send, {TAB}
Sleep, 50
Send, {TAB}
Sleep, 50
Send, {TAB}
Sleep, 50
Send, {TAB}
Sleep, 50
Send, 2
Sleep, 50
Send, {TAB}
Sleep, 50
Send, {Space}
Sleep, 50
Send, {Enter}

return


a::
WinGetActiveTitle, Title
MsgBox, The active window is "%Title%".