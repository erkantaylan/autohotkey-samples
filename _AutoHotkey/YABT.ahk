/*  YABT - Yet Another Borderless-Window Toggle
 *  by Barrow (March 30, 2012)
 *  rewritten by kon (May 16, 2014)
 *  http://www.autohotkey.com/board/topic/78903-yabt-yet-another-borderless-window-toggle/page-2#entry650488
 *  updated by Hastarin (Dec 5, 2014)
 *  tested with AutoHotkey v1.1.16.05
 */
#w::Toggle_Window(WinExist("A"))    ; Win+W to maximize the active window
!^w::Toggle_Window()                ; Ctrl+Alt+W to maximize the window under the mouse

Toggle_Window(Window:="") {
    static A := Init()
    if (!Window)
        MouseGetPos,,, Window
    WinGet, S, Style, % (i := "_" Window) ? "ahk_id " Window :  ; Get window style
    if (S & +0xC00000) {                                        ; If not borderless
        WinGet, IsMaxed, MinMax,  % "ahk_id " Window
        if (A[i, "Maxed"] := IsMaxed = 1 ? true : false)
            WinRestore, % "ahk_id " Window
        WinGetPos, X, Y, W, H, % "ahk_id " Window               ; Store window size/location
        for k, v in ["X", "Y", "W", "H"]
            A[i, v] := %v%
        Loop, % A.MCount {                                      ; Determine which monitor to use
            if (X >= A.Monitor[A_Index].Left
            &&  X <  A.Monitor[A_Index].Right
            &&  Y >= A.Monitor[A_Index].Top
            &&  Y <  A.Monitor[A_Index].Bottom) {
                WinSet, Style, -0xC00000, % "ahk_id " Window    ; Remove borders
		WinSet, Style, -0x40000, % "ahk_id " Window    ; Including the resize border
                ; The following lines are the x,y,w,h of the maximized window
                ; ie. to offset the window 10 pixels up: A.Monitor[A_Index].Top - 10
                WinMove, % "ahk_id " Window,
                , A.Monitor[A_Index].Left                               ; X position
                , A.Monitor[A_Index].Top                                ; Y position
                , A.Monitor[A_Index].Right - A.Monitor[A_Index].Left    ; Width
                , A.Monitor[A_Index].Bottom - A.Monitor[A_Index].Top    ; Height
                break
            }
        }
    }
    else if (S & -0xC00000) {                                           ; If borderless
	WinSet, Style, +0x40000, % "ahk_id " Window    		; Reapply borders
        WinSet, Style, +0xC00000, % "ahk_id " Window
        WinMove, % "ahk_id " Window,, A[i].X, A[i].Y, A[i].W, A[i].H    ; Return to original position
        if (A[i].Maxed)
            WinMaximize, % "ahk_id " Window
        A.Remove(i)
    }
}

Init() {
    A := {}
    SysGet, n, MonitorCount
    Loop, % A.MCount := n {
        SysGet, Mon, Monitor, % i := A_Index
        for k, v in ["Left", "Right", "Top", "Bottom"]
            A["Monitor", i, v] := Mon%v%
    }
    return A
}