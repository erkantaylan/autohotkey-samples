/*

Get active window title

Open Loading Screen
Wait for loading screen

select all/copy
Send message to app

Close Loading Screen


*/

^1::

WinGetActiveTitle, activeWindow
MsgBox, %activeWindow%

Return


^2::

WinGetTitle, OutputVar, A
    ControlGet, text, Selected,,Edit1,[color=blue] %OutputVar%[/color]
If !StrLen(text)
  msgbox, no text selected
else
  msgbox, %text%

Return


^3::
DetectHiddenText, On
WinGetTitle, OutputVar, A
WinGetText, text, %OutputVar%  ; The window found above will be used.
MsgBox, The text is:`n%text%
Return