/*
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 
 When a Windows XP PC is locked by CTRL-ALT-DEL or Win-L, the system does not
 merely initiate a screensaver.  It actually initiates an alternate desktop (the winlogon desktop).
 This alternate desktop has no icons and no application windows can open on it.  Therefore, it is
 not possible for AHK to manipulate windows or send keystrokes and mouseclicks because there is
 no active window when the system is locked.
 
 LockUP was written as a substitute to Windows' locked workstation state.  LockUP allows the user
 to be compliant by disallowing unauthorized access to the PC, but at the same time allows AHK to manipulate
 windows as needed.  
 
 The script does the following.
 
	-- Disables keyboard and mouse inputs
	-- Sets a password to unlock the station
	-- Creates a black colored window that covers the entire desktop
	-- Sends a mousemove every 10 minutes to prevent the system from entering 
	    Windows' locked workstation state.
	-- Handles TaskManager in the event someone tries to enter the system
	    by killing the AHK process.
	-- Handles Remote Desktop lockout.  This is needed because when disconnecting
	    from a remote computer, that machine automatically becomes locked by Windows.
	-- Allows keyboard and mouse unlock via a hotkey combination which presents
	    a GUI requesting the password to kill LockUP.
	   
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
*/
#NoEnv ; Avoids checking empty variables to see if they are environment variables
#Persistent
DetectHiddenWindows, On
SetTimer,TaskManager
SetTimer,MMove, 600000
FileInstall, locked.bmp,%A_ScriptDir%\locked.bmp

; SET the quit hotkey
; Note: the quit hotkey MUST be based on at least one of these: Control, Shift, Alt
QUIT_HOTKEY=~Escape
Hotkey,%QUIT_HOTKEY%,ExitSub

; 'SET pwd' GUI
Gui, Margin,-1,0
Gui, Add, Picture,Section,%A_ScriptDir%\locked.bmp
Gui, Add, Text, Section ym+90 xm+50,This PC is about to be locked.  Please set a password to unlock.`n`nOnce locked, pressing ESC key will allow you to enter the password.
Gui, Add, Text, Section yp+70 ,Password:
Gui, Add, Edit, Password vpwd ys-3 xs+65 w180,
Gui, Add, Text, Section ys+30 xm+50 ,Confirm:
Gui, Add, Edit, Password vpwdc ys-3 xs+65 w180,
Gui, Add, Button, ys+30 xm+240 w75 Default, OK
Gui, Add, Button, ys+30 xm+325 w75, Cancel
Gui, Show, w411 h255, LockUP!
return

ButtonOK:
Gui, Submit, NoHide
If pwd is space
	{
	MsgBox, 4112,ERROR, You must set a password.
	GuiControl,,pwd,
	GuiControl,,pwdc,
	GuiControl,Focus,pwd
	Exit
	}
If pwd <> %pwdc%
	{
	MsgBox, 4112,ERROR, The confirmation does not match the password.  Please try again.
	GuiControl,,pwd,
	GuiControl,,pwdc,
	GuiControl,Focus,pwd
	Exit
	}
Gui, Destroy

; AFTER the pwd is set, block inputs
WinHide ahk_class Shell_TrayWnd
BlockKeyboardInputs("On")      
BlockMouseClicks("On")
BlockInput MouseMove

; DETERMINE size of desktop area to cover
SysGet, numOfMonitors, MonitorCount
screenX=0
screenY=0
Loop, %numOfMonitors%
{
	SysGet, currentMon, Monitor, %A_Index%
	if (currentMonLeft < screenX)
				screenX = %currentMonLeft%
	if (currentMonTop < screenY)
				screenY = %currentMonTop%
}
SysGet, mX, 78
SysGet, mY, 79

; HIDE cursor
MouseMove, %mX%,%mX%,0

; SHOW Blank Window
Gui, 2:Color, 000000
Gui, 2: +AlwaysOnTop -Caption
Gui, 2:Show, NoActivate w%mX% h%mX% x%screenX% y%screenY%,cover

; HANDLE RDP Lockout
SysGet, rdp, 4096
if rdp <> 0
{
FileAppend, @`%windir`%\System32\tscon.exe 0 /dest:console,%A_ScriptDir%\rdpdisc.bat
RunWait, %A_ScriptDir%\rdpdisc.bat, ,Hide
FileDelete, %A_ScriptDir%\rdpdisc.bat
}
; SEND the monitor into off mode
Sleep 500
SendMessage 0x112, 0xF170, 2,,Program Manager

return
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

ExitSub:
IfWinExist, LockUP!
	WinActivate
Else
{
Gui, 2: -AlwaysOnTop
Gui, 3:Margin,-1,0
Gui, 3:Add, Picture,Section,%A_ScriptDir%\locked.bmp
Gui, 3:Add, Text, Section ym+90 xm+70,This computer is in use and has been locked.`n`nPlease enter the password that was set when the system`nwas locked.
Gui, 3:Add, Text, Section yp+70 ,Password:
Gui, 3:Add, Edit, Password vpwdu ys-3 xs+65 w180,
Gui, 3:Add, Button, ys+30 xm+240 w75 Default, OK
Gui, 3:Add, Button, ys+30 xm+325 w75, Cancel
Gui, 3: +AlwaysOnTop
Gui, 3:+owner2
Gui, 2: -Disabled
Gui, 3:Show, w411 h225, LockUP!
BlockKeyboardInputs("Off")      
BlockMouseClicks("Off")
BlockInput MouseMoveOff
}
return

3ButtonCancel:
Gui, 2: +AlwaysOnTop
Gui, 3:Destroy
BlockKeyboardInputs("On")      
BlockMouseClicks("On")
BlockInput MouseMove
MouseMove, %mX%,%mX%,0
return
3ButtonOK:
Gui, 3:Submit, NoHide
If pwdu <> %pwd%
	{
	MsgBox, 4112,ERROR, The password you entered is incorrect.  Please try again.
	GuiControl,3:,pwdu,
	GuiControl,3:Focus,pwdu
	Exit
	}

ButtonCancel:
WinShow ahk_class Shell_TrayWnd
FileDelete locked.bmp
ExitApp ; The only way for an OnExit script to terminate itself is to use ExitApp in the OnExit subroutine.

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; Function:
;   The following 2 functions were posted by AHK user Andreone and can be found
;       at http://www.autohotkey.com/forum/topic22761.html
;
;   BlockKeyboardInputs(state="On") disables all keyboard key presses,
;   but Control, Shift, Alt (thus a hotkey based on these keys can be used to unblock the keyboard)
;
; Param
;   state [in]: On or Off

BlockKeyboardInputs(state = "On")
{
   static keys
   keys=Space,Enter,Tab,Esc,BackSpace,Del,Ins,Home,End,PgDn,PgUp,Up,Down,Left,Right,CtrlBreak,ScrollLock,PrintScreen,CapsLock
,Pause,AppsKey,LWin,LWin,NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot
,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear
,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel,Media_Next,Media_Play_Pause,Media_Prev,Media_Stop,Volume_Down,Volume_Up
,Volume_Mute,Browser_Back,Browser_Favorites,Browser_Home,Browser_Refresh,Browser_Search,Browser_Stop,Launch_App1,Launch_App2
,Launch_Mail,Launch_Media,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22
,1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
,²,&,é,",',(,-,è,_,ç,à,),=,$,£,ù,*,~,#,{,[,|,``,\,^,@,],},;,:,!,?,.,/,§,<,>,vkBC
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, KeyboardDummyLabel, %state% UseErrorLevel
   Return
; hotkeys need a label, so give them one that do nothing
KeyboardDummyLabel:
Return
}

; ******************************************************************************
; Function:
;    BlockMouseClicks(state="On") disables all mouse clicks
;
; Param
;   state [in]: On or Off
;
BlockMouseClicks(state = "On")
{
   static keys="RButton,LButton,MButton,WheelUp,WheelDown"
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, MouseDummyLabel, %state% UseErrorLevel
   Return
; hotkeys need a label, so give them one that do nothing
MouseDummyLabel:
Return
}

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
; Timers to handle TaskManager and prevent initiation of Windows locked workstation state

TaskManager:
IfWinExist, Windows Task Manager
WinHide, Windows Task Manager
WinClose,Windows Task Manager
return

MMove:
ID := WinExist("A") 
If ID <> 0
	{
	MouseMove, 5,5,0,R
	Sleep 2000
	MouseMove, -5,-5,0,R
	}
Return 