F::

#SingleInstance force
CoordMode, Mouse, Relative
SetTitleMatchMode 2
SetTimer MMT, 2000

LastActiveWin =
Return

MMT:
WinID := WinExist("A")
IfEqual WinID, %LastActiveWin%
   return
LastActiveWin = %WinID%
WinGetActiveStats, AWTitle, AWWidth, AWHeight, AWX, AWY
MPosX := (AWWidth//2)
MPosY := (AWHeight//2)
MouseMove, %MPosX%, %MPosY%
Return