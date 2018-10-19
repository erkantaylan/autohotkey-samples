
/*
-----------------------------------
  Unofficial Macro Recorder 3.0 (by Speedmaster)
  original post "Macro Recorder" By FeiYue

  Warning ! This is a modified version of Macro Recorder v1.6 (by Feiyue) 
            and contains Findtext tool v5.2 (by Feiyue)

  Macro Recorder post:(by Feiyue)
  https://autohotkey.com//boards/viewtopic.php?f=6&t=34184

  FindText post:(by Feiyue)
  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834  
  
  Description:
  1. This script records the mouse and keyboard
     actions and then plays back.
  2. Individually press LCtrl to record mouse movement.
  3. Move the mouse to the top left corner
     of the screen to pop up the menu.
  4. If you want to stop playback process,
     please press the Pause hotkey first,
     and then click the Stop button.

  Pause  Button  -->  Pause  Record/Play (Better to use hotkey)
  Record Button  -->  Record Mouse/Keyboard/Window/Delay
  Stop   Button  -->  Stop   Record/Play (Save To LogFile)
  Play   Button  -->  Play   LogFile
  Edit   Button  -->  Edit   LogFile
  Loop Play CheckBox  -->  Loop playback options
  Relative  CheckBox  -->  relative coordinates options

  Pause  Hotkey  -->  Pause  Record/Play
-----------------------------------
*/

#NoEnv
#SingleInstance force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, ToolTip


;PREFERENCES:
;----------------------------------
ScriptVersion=v3.0

LogFile = %A_Scriptdir%\~Macro.ahk
EditorPath = notepad.exe             ;put here the path to your default editor for ex. "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
AutoScriptWriterPath = % SubStr( A_AhkPath, 1, -14 ) . "AutoScriptWriter\AutoScriptWriter.exe"   ; put here the path to AutoScriptWriter II

StartRecordDelay := 1000             ; waiting time (in millisec) before begining to record
SleepDelay       := 2000             ; Max time (in millisec) for sleep command
WinWaitDelay     := 3                ; time (in sec) for winwait command
beepsound        := 1                ; Emits a tone from the PC speaker on record
EditAfterRecord  := 0                ; Show internal editor after record

TooltipMessage   := 1                ; append tooltip messages to macro
AppendClass      := 1                ; append class name to window title
SplitLines       := 0                ; auto split long lines of keyborad recording


ShowASWIIbuttons := 0                ; Hide/Show AutoScriptWriter II buttons
ActivateFindtext := 1                ; Hide/Show Findtext button and activate findtext tool
ShowMenuButton   := 1                ; Hide/Show Disable Menu Button
ShowExitButton   := 1                ; Hide/Show Exit Button from the menu
ShowSetupButton  := 1

CoordMouseWindow := 1
RecordasVkSc       := 0              ; record inputs as VkSc code exept keys in excludevksc list
ExcludeVkSc        := "NumpadEnter,Home,End,PgUp,PgDn,Left,Right,Up,Down,Del,Ins,LButton,RButton,CtrlBreak,MButton,XButton1,XButton2,Backspace,Tab,NumpadClear,Enter,Pause,CapsLock,Esc,Space,NumpadPgUp,NumpadPgDn,NumpadEnd,NumpadHome,NumpadLeft,NumpadUp,NumpadRight,NumpadDown,PrintScreen,NumpadIns,NumpadDel,Help,,LWin,RWin,AppsKey,Sleep,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadMult,NumpadAdd,NumpadSub,NumpadDot,NumpadDiv,CapsLock,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,Numlock,ScrollLock,WheelLeft,WheelRight,WheelDown,WheelUp,LShift,RShift,LCtrl,RCtrl,LAlt,RAlt,Browser_Back,Browser_Forward,Browser_Refresh,Browser_Stop,Browser_Search,Browser_Favorites,Browser_Home,Volume_Mute,Volume_Down,Volume_Up,Media_Next,Media_Prev,Media_Stop,Media_Play_Pause,Launch_Mail,Launch_Media,Launch_App1,Launch_App2"

startmode    = 1                 ; start with menu closed (default)
startmode    = 2                 ; show menu at startup
startmode    = 3                 ; don't show the menu (=stealth mode)
startmode    = 1                 ; put here your default start value

splashscreen := 1                ; Display startup splash screen
guicolor     :="FFFFAA"
displayicons := 1                ; Display icons in menu buttons
EditorFontSize:=9

;hotkeys
Hotkey, *Pause,      Pause
Hotkey, F6 & F4,     ToggleMenu
Hotkey, F6 & F5,     Record
Hotkey, F6,          Stop
Hotkey, F6 & F7,     Play
Hotkey, F6 & F8,     toggleLoopPlay
Hotkey, F6 & F9,     toggleMouseRelative
Hotkey, F6 & F10,    Edit
Hotkey, ~RButton,   ToggleMenuR


;Append code to header
header=
(
)

;Append code to footer
footer=
( 
)

;Append code to mouse click
Append_to_Click=
(
)


;----------------------------------

Shortcuts=
(
Pause    >>   Pause 
F6 + F4  >>   Toggle Show Menu

Double Right click 
on left edge of 
screen   >>   Toggle Show Menu

F6 + F5  >>   Record
F6       >>   Stop Recording or Playing
F6 + F7  >>   Play Macro
F6 + F8  >>   Toggle Repeat
F6 + F9  >>   Toggle Mouse Relative to Window
F6 + F10 >>   Editor
F12      >>   Reload
)



;---------------------------------------CHECK IF INI EXIST IF NOT CREATE IT--------------------------------------------------------

iniFile := SubStr( A_ScriptName, 1, -3 ) . "ini"
Ini_File=%A_WorkingDir%\%iniFile%      
;msgbox, %Ini_File%
ifnotexist,%Ini_File%
 {
  iniContent =
  (
[]

;File path
-----------------------------------------------------
LogFile=%LogFile%
EditorPath=%EditorPath%
AutoScriptWriterPath=%AutoScriptWriterPath%


;macro file options
------------------------------------------------------
SleepDelay=%SleepDelay%
WinWaitDelay=%WinWaitDelay%
TooltipMessage=%TooltipMessage%
AppendClass=%AppendClass%
CoordMouseWindow=%CoordMouseWindow%
SplitLines=%SplitLines%
EditAfterRecord=%EditAfterRecord%
RecordasVkSc=%RecordasVkSc%
ExcludeVkSc="NumpadEnter,Home,End,PgUp,PgDn,Left,Right,Up,Down,Del,Ins,LButton,RButton,CtrlBreak,MButton,XButton1,XButton2,Backspace,Tab,NumpadClear,Enter,Pause,CapsLock,Esc,Space,NumpadPgUp,NumpadPgDn,NumpadEnd,NumpadHome,NumpadLeft,NumpadUp,NumpadRight,NumpadDown,PrintScreen,NumpadIns,NumpadDel,Help,,LWin,RWin,AppsKey,Sleep,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadMult,NumpadAdd,NumpadSub,NumpadDot,NumpadDiv,CapsLock,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,Numlock,ScrollLock,WheelLeft,WheelRight,WheelDown,WheelUp,LShift,RShift,LCtrl,RCtrl,LAlt,RAlt,Browser_Back,Browser_Forward,Browser_Refresh,Browser_Stop,Browser_Search,Browser_Favorites,Browser_Home,Volume_Mute,Volume_Down,Volume_Up,Media_Next,Media_Prev,Media_Stop,Media_Play_Pause,Launch_Mail,Launch_Media,Launch_App1,Launch_App2"


;use ``n as multiline separator to append some code to header footer or mouse clicks
header=%header%
footer=%footer%
Append_to_Click=%Append_to_Click%


;Interface
-------------------------------------------------------

;startmode 1 start with menu closed (default) ;mode 2 show menu at startup  ;mode 3 don't show the menu (=stealth mode)   
startmode=%startmode%
splashscreen=%splashscreen%
displayicons=%displayicons%
guicolor=%guicolor%
beepsound=%beepsound%
StartRecordDelay=%StartRecordDelay%

; show Findtext5.2 tool (by Feiyue)
ActivateFindtext=%ActivateFindtext%

; (ASWII) AutoScriptWriter II - ( by Larry Keys )
ShowASWIIbuttons=%ShowASWIIbuttons%
  )

  replaceFile(iniFile, iniContent)
 }

; call replace file function
replaceFile(File, Content)
{
	FileDelete, %File%
	FileAppend, %Content%, %File%
}


;------------------------------------Read the ini file and store its content to variables----------------------------------------------
;Call function ini 
updateini()

;----------------------------------------------------------------------------------------

StringReplace, header, header, ``n, `n, All
StringReplace, footer, footer, ``n, `n, All
StringReplace, Append_to_Click, Append_to_Click, ``n, `n, All


;-----------------------------------

Gui 1: +AlwaysOnTop -Caption +ToolWindow +Hwndgui_id +E0x08000000
Gui 1: Color, %guicolor%          ;FFFFAA
Gui 1: Margin, 0, 0

if !displayicons
{
Gui 1: Font, s12, Verdana
Gui 1: Add, Button, w120 h60 section gPause, Pause
Gui 1: Add, Button, wp hp gRecord, Record
Gui 1: Add, Button, wp hp gStop, Stop
Gui 1: Add, Button, wp hp gPlay, Play
Gui 1: Add, Button, wp hp gEdit, Edit
if ActivateFindtext
Gui 1: Add, Button, wp hp gfindtext, Find Picture
}


if displayicons
{
Gui 1: Font, s30 cbold, Webdings
Gui 1: Add, Button, w120 h60 section gPause, % chr(0x3B)
Gui 1: Add, Button, wp hp gRecord, % chr(0x3D)
Gui 1: Add, Button, wp hp gStop, % chr(0x3C)
Gui 1: Add, Button, wp hp gPlay, % chr(0x34)
Gui 1: Add, Button, wp hp gEdit, % chr(0xA4)
if ActivateFindtext
Gui 1: Add, Button, wp hp gfindtext, % chr(0x4c)
}



Gui 1: Font, s10, Verdana
if ShowASWIIbuttons
{
Gui 1: Add, Button, wp hp Left gaswii_record, ASWII: Record
Gui 1: Add, Button, wp hp Left gaswii_get, ASWII: Get
Gui 1: Add, Button, wp hp Left gaswii_clear, ASWII: Clear
}
Gui 1: Add, CheckBox, x10  hp-25 -border gtoggleLoopPlay vLoopPlay, Loop
Gui 1: Add, Edit,  xs+10 w80 h20 +Number ved_rep Disabled c5D69BA,
Gui 1: Add, UpDown, vrepeat x34  w18 h20 Range1-999999, 10




Gui 1: Font, s9, verdana
Gui 1: Add, CheckBox, -border xs+10 yp+28 w100 h35  checked%coordmousewindow% gtoggleMouseRelative vrelative, Crd Win Rel

gui 1: font, s12, webdings

if showsetupButton
Gui 1: Add, Button, xs  w40 h30 gsetup, % chr(0x40) 

if ShowMenuButton
Gui 1: Add, Button, xp+40  w40 h30 ghide, % chr(0x63)   

if ShowExitButton
Gui 1: Add, Button, xp+40  w40 h30 vexit gExit, % chr(0x72)


Gui 2: +AlwaysOnTop Caption +ToolWindow
Gui 2: Add, CheckBox, x10 section w320 h18 checked%beepsound%       -border vbeepsound       goka, Emits a beep tone from the PC speaker on record
Gui 2: Add, CheckBox, xs          wp   hp  checked%splashscreen%    -border vsplashscreen    goka, Display startup splash screen
Gui 2: Add, CheckBox, xs          wp   hp  checked%displayicons%    -border vdisplayicons    goka, Display Icons in Menu (need restart)
Gui 2: Add, CheckBox, xs          wp   hp  checked%ActivateFindtext%    -border vActivateFindtext    goka, Activate Findtext tool (need restart)
Gui 2: Add, CheckBox, xs          wp   hp  checked%ShowASWIIbuttons%    -border vShowASWIIbuttons    goka, Show Auto Script Writer II buttons (need restart)

Gui 2: Add, Groupbox, xs-10       w345   h150  , Macro File
Gui 2: Add, CheckBox, xs y140 section  w320   h18  checked%TooltipMessage%    -border vTooltipMessage    goka, Append tooltip debug messages
Gui 2: Add, CheckBox, xs ys+20         wp   hp  checked%AppendClass%     -border vAppendClass     goka, Append ClassName to window titles
Gui 2: Add, CheckBox, xs yp+20         wp   hp  checked%RecordasVkSc%    -border vRecordasVkSc    goka, Record keyboards inputs as {VkSc} code
Gui 2: Add, CheckBox, xs yp+20         wp   hp  checked%SplitLines%    -border vSplitLines    goka, Split long keyboard recording lines
Gui 2: Add, CheckBox, xs yp+20         wp   hp  checked%EditAfterRecord%    -border vEditAfterRecord    goka, Show the internal editor after the end of the recording
Gui 2: Add, CheckBox, xs yp+20         wp   hp  checked%CoordMouseWindow%    -border vCoordMouseWindow    goka, Coord Mouse relative to window

Gui 2: Add, button, xs  yp+40 w100   h30   geditini, Advanced options
Gui 2: Add, button, xp+105  yp   h30   greload, Reload



;--Gui 3 ---------------------------------------------------------------------------

Menu, FileMenu, Add, &New, FileNew
Menu, FileMenu, Add, &Import, FileOpen
Menu, FileMenu, Add, &Export, FileSaveAs
Menu, FileMenu, Add, &Save, FileSave
Menu, FileMenu, Add, Save and &Backup, SaveAndBackup
Menu, FileMenu, Add, &Restore Backup, RestoreBackup
Menu, FileMenu, Add, Restore &Last Record, RestoreLastRecord
Menu, FileMenu, Add, &Open External Editor, externaleditor
Menu, FileMenu, Add  ; Separator line.
Menu, FileMenu, Add, E&xit, FileExit


Menu, EditMenu, Add, &Fold all blocs in a function, Fold
Menu, EditMenu, Add, &Shorten all blocs, Short
Menu, EditMenu, Add, Remove &Empty Lines, RemoveEmptyLines
Menu, EditMenu, Add, Remove T&ooltip Lines, RemoveTooltipLines
Menu, EditMenu, Add, Remove &Titles, RemoveTitleLines
Menu, EditMenu, Add, Remove Titles &Class, RemoveTitleClassLines
Menu, EditMenu, Add, Clear E&ditor, FileNew

Menu, HelpMenu, Add, &Shortcuts, Shortcuts
Menu, HelpMenu, Add, &About, HelpAbout

; Create the menu bar by attaching the sub-menus to it:
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Edit, :EditMenu
Menu, MyMenuBar, Add, &Options, setup
Menu, MyMenuBar, Add, &Help, :HelpMenu

; Attach the menu bar to the window:
Gui 3: Menu, MyMenuBar


gui 3: font, s%editorfontsize%, Lucida Console
; Create the main Edit control and display the window:
Gui 3: +Resize  ; Make the window resizable.
Gui 3: Add, tab,, Macro|Temp Edit
Gui 3: Add, Edit, vMainEdit -Wrap HScroll WantTab W640 h500 ;R40

CurrentFileName =  ; Indicate that there is no current file.

gui 3: font, s9, Lucida Console

Gui 3: add, button, gInsertSleep , insert Sleep 200 \n
Gui 3: add, button, gInsertSleepSend , insert sleep 500 send...                    ; insert a sleep then a send command to break long lines of keyboard commands


Gui 3: add, button, gSaveCurrentFileb , Save and exit


gui 3: tab, 2
Gui 3: Add, Edit, vTempEditor -Wrap HScroll WantTab W640 R40


;-------------------------------------------------------------------

if (startmode=1)
 {
  ShowMenu:=1
  Gui 1: Show, NA x0 y60 w1, Macro Record

  if splashscreen
   {
    Progress, B1 ZH0  cw5AEC49,  Unofficial Macro Recorder %ScriptVersion%
    SetTimer, TimeoutTimer, -2500
   }

 }

if (startmode=2)
 {
  ShowMenu:=1
  Gui 1: Show, NA x0 y60 AutoSize, Macro Record

 }

if (startmode=3)  ; start hidden
{
  Gui 1: Show, NA x0 y60 w0, Macro Record
  ShowMenu:=0
  Gui 1: hide

  if splashscreen
   {
    Progress, B1 ZH0, UMR Unofficial Macro Record %ScriptVersion%`n
    SetTimer, TimeoutTimer, -2500
   }
}

;--------------------------------------------------------------------------------------------------

MouseOnGui:=0
SetTimer, GuiMenuShow, 2000
OnMessage(0x200, "WM_MOUSEMOVE")



if ActivateFindtext
gosub, ftext



return



oka:
gui 2: submit, nohide
updateini(,1)
return


setup:
gui 2: show, autosize
return

editini:
run, %Ini_File%
return

reload:
reload
return

ASWII_get:
   if WinExist("AutoScriptWriter II")
    {
      FileDelete, %LogFile%
      ControlGetText, OutputVar , Edit2, AutoScriptWriter II - ( by Larry Keys )


  Loop,parse,OutputVar, `n
   {
    cm := a_loopfield
    If cm contains  WinActivate
     {
      cm:=RegExReplace(cm,"WinActivate","`nWinActivate")
     }

     out .= cm . "`n"
   }
outputvar:=out
out=

      FileAppend, %OutputVar%, %LogFile%
      ;backupfile:= SubStr( LogFile, 1, -3 ) . "bak"
      ;FileDelete, %BackupFile%
      ;FileAppend, %OutputVar%, %backupfile%
      Progress, B1 ZH0, Text transfered from AutoScriptWriter II`n Successfully
      SetTimer, TimeoutTimer, -2000
    }
return

ASWII_record:
if WinExist("AutoScriptWriter II")
{
winactivate, AutoScriptWriter II
sleep, 300
ControlFocus , Button1, AutoScriptWriter II
ControlClick , Button1, AutoScriptWriter II
}
else
{
  IfWinNotExist, AutoScriptWriter II
  ifexist, %AutoScriptWriterPath%
  run, % AutoScriptWriterPath
  WinWaitActive,,,2
  ControlFocus , Button1, AutoScriptWriter II
  ControlClick , Button1, AutoScriptWriter II
}   
      
return


ASWII_clear:
   if WinExist("AutoScriptWriter II")
    {
      ControlSetText , Edit2,, AutoScriptWriter II
    }
return


Run:
Critical
Gui 1: Submit
MouseOnGui:=0
Gui 1: Show, NA x0 y60 w1
if IsLabel(s:=A_GuiControl)
  Goto, %s%
return

Exit:
msgbox,33,Unofficial Macro Recorder %ScriptVersion%, Do you really want to exit?
IfMsgBox, OK
exitapp
return

GuiMenuShow:
ListLines, Off
Gui 1: +AlwaysOnTop
MouseGetPos,,, mouse_id
if (mouse_id=gui_id)!=MouseOnGui
{
  if showmenu
  if (MouseOnGui:=!MouseOnGui)
    Gui 1: Show, NA AutoSize
  else
    Gui 1: Show, NA x0 y60 w1
}
SetTimer, GuiMenuShow, 2000
return

WM_MOUSEMOVE() {
  ListLines, Off
  global MouseOnGui
  if (!MouseOnGui and A_Gui=1)
  {
    MouseOnGui:=1
    Gui 1: Show, NA AutoSize
  }
  SetTimer, GuiMenuShow, 100
}


Record:
gui 3: hide

Suspend, Permit
if (Recording or Playing)
  return

oldtt=
ToolTip, % "  Please Wait  ", 0, 0
sleep, %StartRecordDelay%

if (StartRecordDelay>=1)
if beepsound
Soundbeep


Recording:=1, IsPaused:=0, Logs:="", SetHotkey(1)
ToolTip, % "  Recording  ", 0, 0
SetTimer, CheckWindow, 100
return


toggleMouseRelative:

if (CoordMouseWindow:=!CoordMouseWindow)
 {
  guicontrol,, Relative, 1
  Progress, B1 ZH0, CoordMode Window
  SetTimer, TimeoutTimer, -2000
 }
else
 {
  guicontrol,, Relative, 0
  Progress, B1 ZH0, CoordMode Screen
  SetTimer, TimeoutTimer, -2000
 }
 return


Stop:
Suspend, Permit
if Recording
{
  
  GuiControlGet, Relative
  Logs:=header
    . "`nCoordMode, ToolTip"
    . "`nCoordMode, Mouse, " . (Relative ? "Window":"Screen")
    . "`n`n" . Trim(Logs,"`n")
    . "`n" . footer
 
  if SplitLines
  Logs:=addsleepaftersend(Logs)
   
  FileDelete, %LogFile%
  FileAppend, %Logs%, %LogFile%

  ; save last record
  LastRecordfile:= SubStr( LogFile, 1, -3 ) . "lrc"
  FileDelete, %LastRecordfile%
  FileAppend, %Logs%, %LastRecordfile%
------------------------------------------------------------------------------------------

  SetTimer, CheckWindow, Off
  ToolTip
  SetHotkey(0), Logs:="", Recording:=0,  IsPaused:=0

if beepsound
 {
  soundbeep
  soundbeep
 }

if EditAfterRecord
gosub, edit



  return
}

LoopPlay:=0
SetTitleMatchMode, 2
DetectHiddenWindows, On
SplitPath, LogFile, FileName
WinGet, list, List, %FileName% ahk_class AutoHotkey
Loop, %list%
{
  id:=list%A_Index%
  if (id=A_ScriptHwnd) or !WinExist("ahk_id " id)
    Continue
  WinGet, pid, PID
  WinClose
  WinWaitClose,,, %WinWaitDelay%
  if ErrorLevel
    Process, Close, %pid%
}

return


toggleLoopPlay:

if (LoopPlay:=!LoopPlay)
 {
  guicontrol,, loopplay, 1

  GuiControl,enable,ed_rep

  Progress, B1 ZH0, LoopPlay enabled
  SetTimer, TimeoutTimer, -2000
 }

else
 {
  guicontrol,, loopplay, 0

GuiControl,enable0,ed_rep

  Progress, B1 ZH0, LoopPlay disabled
  SetTimer, TimeoutTimer, -2000
 }
return
 TimeoutTimer:
 Progress, Off
 Return


Play:
if beepsound
  soundbeep

if ShowMenu
Gui 1: Show, NA x0 y60 w1

  GuiControlGet,ed_rep,,repeat

if WinExist("AutoScriptWriter II")
    {
      WinMinimize, AutoScriptWriter II
    }

Suspend, Permit
if Recording
  Gosub, Stop
if !LoopPlay
GuiControlGet, LoopPlay
Playing:=1
ToolTip, % "  Playing  " . ed_rep , 0, 0
Critical, Off
ListLines, Off

if !ed_rep
ed_rep:=1

if !LoopPlay
ed_rep:=1

Loop % ed_rep
    {
     ToolTip, % "  Playing  " . a_index , 0, 0
     RunWait, %A_AhkPath% "%LogFile%"
     if !LoopPlay
     Break
    }

ListLines, On
ToolTip
Playing:=0
return


Edit:
Suspend, Permit
Critical, Off
gosub internaleditor

;Run, %EditorPath% "%LogFile%"
return


Pause:
Suspend, Permit

if Recording
{
  IsPaused:=!IsPaused, SetHotkey(!IsPaused)
  ToolTip, % IsPaused ? "  Record Pause  "
    : "  Recording  ", 0, 0
  return
}

SetTitleMatchMode, 2
DetectHiddenWindows, On
SplitPath, LogFile, FileName
WinGet, list, List, %FileName% ahk_class AutoHotkey
Loop, %list%
{
  id:=list%A_Index%
  if (id=A_ScriptHwnd) or !WinExist("ahk_id " id)
    Continue
  PostMessage, 0x111, 65306
}
return


;========== Function and Label ==========


SetHotkey(f=0)
{
  static AllKeys, ExcludeKeys:="Pause"
  ListLines, Off
  if !Allkeys
  {
    s:="|Control|Alt|Shift||NumpadEnter|Home|End"
      . "|PgUp|PgDn|Left|Right|Up|Down|Del|Ins|"
    Loop, 254
      k:=GetKeyName(Format("VK{:X}", A_Index))
        , s.=InStr(s, "|" k "|") ? "" : k "|"
    For k,v in {Control:"Ctrl", Escape:"Esc"}
      s:=StrReplace(s, k, v)
    AllKeys:=Trim(SubStr(s,InStr(s,"||")),"|")
  }
  ;------------------
  f:=f ? "On":"Off"
  For i,k in StrSplit(AllKeys,"|")
    if k not in %ExcludeKeys%
      Hotkey, ~*%k%, LogKey, %f% UseErrorLevel
  ListLines, On
}

LogKey:
Critical
k:=Trim(A_ThisHotkey,"~*#!+^<>$"), r:=SubStr(k,2)
if r in Win,Alt,Ctrl,Shift,Button
  if IsLabel(k)
    Goto, %k%
; Some input auto completion and send the left or right keys
; for the cursor center, excluding these key records
if (k="NumpadLeft" or k="NumpadRight") and !GetKeyState(k,"P")
  return
if !RecordasVkSc
k:=k="``" ? "``" k : StrLen(k)>1 or k=";" ? "{" k "}" : k

if RecordasVkSc
{
if k contains %ExcludeVkSc%
k:=k="``" ? "``" k : StrLen(k)>1 or k=";" ? "{" k "}" : k
else
k:=Format("{{}vk{1:X}sc{2:X}{}}", GetKeyVK(k), GetKeySC(k))
}


Log(k,1)
return

LWin:
RWin:
LAlt:
RAlt:
LCtrl:  ; Individually press LCtrl to record mouse movement
RCtrl:
LShift:
RShift:
Log("{" k " Down}",1)
Critical, Off
KeyWait, %A_ThisLabel%
Critical
k:=A_ThisLabel
Log("{" k " Up}",1)
;----------------------------
if (k="LCtrl")
  and SubStr(Logs,1-22)="{LCtrl Down}{LCtrl Up}"
{
  Logs:=SubStr(Logs,1-14-22,14)="`nSend, {Blind}"
    ? SubStr(Logs,1,-14-22) : SubStr(Logs,1,-22)
  if Relative
    CoordMode, Mouse, Window
  MouseGetPos, X, Y
  Log("MouseMove, " X ", " Y)
}
return


hide:          ;enable disable menu
  showmenu:=0
  Gui 1: hide
  Progress, B1 ZH0, Menu Disabled `nDouble Right Click or Press F6+F4
  SetTimer, TimeoutTimer, -3000
return


ToggleMenu:

ShowMenu:=!ShowMenu

if ShowMenu
 {
  Gui 1: Show, NA AutoSize
  SetTimer, GuiMenuShow, 1000
 }
else
 {
  Gui 1: hide
  Progress, B1 ZH0, Menu Disabled `nDouble Right Click  or Press F6+F4
  SetTimer, TimeoutTimer, -3000
 }
return


LButton:
IfEqual, MouseOnGui, 1, return
RButton:
MButton:
SetTimer, CheckWindow, On
if CoordMouseWindow
{
  CoordMode, Mouse, Window

winactivate
sleep, 200
MouseGetPos, zx, zy, id
WinGetTitle, title, ahk_id %id%
WinGetClass, class, ahk_id %id%

mevent:=1
}

if !CoordMouseWindow
{
CoordMode, Mouse, Screen
winactivate
sleep, 200
MouseGetPos, msx, msy

mevent:=1
}


return

CheckWindow:


ListLines, Off
Critical
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùù

WinGetTitle, tt, A
WinGetClass, tc, A

if (tt="" and tc="")
  return



if AppendClass
tt:=SubStr(tt,1,50) . (tc ? " ahk_class " . tc:"")



if (tt=oldtt)
{

if mevent
{
    if CoordMouseWindow  
   {
    if Append_to_Click !=
    apm:=Append_to_Click . "`nMouseClick, " . SubStr(k,1,1) . ", " . zx . ", " . zy ""
    else
    apm:="MouseClick, " . SubStr(k,1,1) . ", " . zx . ", " . zy ""
    log(apm)
   }

    if !CoordMouseWindow  
   {
    if Append_to_Click !=
    apm:=Append_to_Click . "`nMouseClick, " . SubStr(k,1,1) . ", " . msx . ", " . msy ""
    else
    apm:="MouseClick, " . SubStr(k,1,1) . ", " . msx . ", " . msy ""
    log(apm)
   }
}

mevent:=0
  return

}
oldtt:=tt



tt:=RegExReplace(Trim(tt), "[;``]", "``$0")
StringReplace, tt, tt, ", "", All

if !CoordMouseWindow 
if tt contains Recording,Macro Record,Progman,Program Manager
return

IfEqual, MouseOnGui, 1, return


if TooltipMessage
  {
      if tt
      {
       tt:="ToolTip, Waiting..."  tt ", 80, 0`n"
       . "WinWait, " . tt . ",`n"
       . "IfWinNotActive, " . tt . ", `n" 
       . "WinActivate, " . tt . ",`n"
       . "WinWaitActive, " . tt ",, " . WinWaitDelay . "`n"
       . "ToolTip" . "`n"
      }  
  }
  
if !TooltipMessage
  {
    if tt
      {
       tt:="WinWait, " . tt . ",`n"
       . "IfWinNotActive, " . tt . ", `n" 
       . "WinActivate, " . tt . ",`n"
       . "WinWaitActive, " . tt ",, " . WinWaitDelay . "`n"
      }
  }
  
r:=SubStr(Logs, i:=InStr(Logs,"`ntt:=",0,0))
if (i) and !InStr(r,"Sleep")
  Logs:=SubStr(Logs,1,i-1)
Log(tt)
return




Log(str="", Keyboard=0, MaxDelay=2000)
{
  global Logs, LastTime, SplitLines
  Delay:=(Time:=A_TickCount)-LastTime, LastTime:=Time

if !SplitLines
delay:=0

  if (Keyboard and Delay<1000)
  {
    if SubStr(Logs,0)!="`n"
    {
      Logs.=str
      return
    }

  }
if keyboard
    str:="`nSend, {Blind}" . str

  t:=A_TickCount, Delay:=(t-LastTime)//2, LastTime:=t
  Delay:=Delay<MaxDelay ? Delay : MaxDelay
  if (Logs!="")
    if Append_to_Click !=
    Logs:=RTrim(Logs,"`n") "`n" . Append_to_Click
    else
      Logs:=RTrim(Logs,"`n")  . "`n"
  Logs.=Keyboard ? str : "`n" . str . "`n"
}


;----------------------------------

;https://autohotkey.com/board/topic/33506-read-ini-file-in-one-go/
updateini( filename = 0, updatemode = 0 )
;
; updates From/To a whole .ini file
; 
; By default the update mode is set to 0 (Read) 
; and creates variables like this:
; %Section%%Key% = %value%
;
; You don't have to state the updatemode when reading, just use
;
; update(filename)
;
; The function can be called to write back updated variables to
; the .ini by setting the updatemode to 1, like this:
;
; update(filename, 1) 
;
{
Local s, c, p, key, k, write

   if not filename
      filename := SubStr( A_ScriptName, 1, -3 ) . "ini"

   FileRead, s, %filename%

   Loop, Parse, s, `n`r, %A_Space%%A_Tab%
   {
      c := SubStr(A_LoopField, 1, 1)
      if (c="[")
         key := SubStr(A_LoopField, 2, -1)
      else if (c=";")
         continue
      else {
         p := InStr(A_LoopField, "=")
         if p {
  	    k := SubStr(A_LoopField, 1, p-1)
	    if updatemode=0
	    	%key%%k% := SubStr(A_LoopField, p+1)
	    if updatemode=1
	    {
	    	write := %key%%k%
	    	IniWrite, %write%, %filename%, %key%, %k% 	
	    }
         }
      }
   }
}





;============ The End =============




ToggleMenuR:

If (A_TimeSincePriorHotkey<400) and (A_PriorHotkey="~RButton") and xmousepos()
{
if !togglemenu
sleep, 120
send, {esc}
gosub, ToggleMenu
}
return
xmousepos()
{
coordmode, mouse, screen
MouseGetPos, outx
if % (outx<3)
return true
}




RemoveEmptyLines:

GuiControlGet, FileUp,, MainEdit
FileUp:=RemoveEmptyLines(FileUp)
GuiControl,,MainEdit, %FileUP% 
return

RemoveTooltipLines:
GuiControlGet, FileUp,, MainEdit
FileUp:=RemoveTooltipLines(FileUp)
GuiControl,,MainEdit, %FileUP% 
return

RemoveTitleLines:
GuiControlGet, FileUp,, MainEdit
FileUp:=RemoveTitleLines(FileUp)
GuiControl,,MainEdit, %FileUP% 
return

RemoveTitleClassLines:
GuiControlGet, FileUp,, MainEdit
FileUp:=RemoveTitleClassLines(FileUp)
GuiControl,,MainEdit, %FileUP% 
return

Fold:
GuiControlGet, FileUp,, MainEdit
FileUp:=Foldblocks(FileUp)
GuiControl,,MainEdit, %FileUP% 
return

short:
GuiControlGet, FileUp,, MainEdit
FileUp:=Shortblocks(FileUp)
GuiControl,,MainEdit, %FileUP% 
return



InsertSleepSend:
guiControl, Focus , MainEdit
Send, {raw}`nSleep, 500`nSend, {Blind}
return


InsertSleep:
guiControl, Focus , MainEdit
sendinput, {end}
Send, {raw}`nSleep, 200
return




RestoreBackup:
if !backupfile
backupfile:= SubStr( LogFile, 1, -3 ) . "bak"

IfExist %BackupFile%
{
FileDelete, %LogFile%
FileRead, FileUp, %backupfile%
FileAppend, %FileUp%, %LogFile%
FileRead, FileUp, %LogFile%
gui 3: default
GuiControl,,MainEdit, %FileUP% 
}
return

RestoreLastRecord:
if !LastRecordFile
LastRecordFile:= SubStr( LogFile, 1, -3 ) . "lrc"

IfExist %LastRecordFile%
{
FileDelete, %LogFile%
FileRead, FileUp, %LastRecordFile%
FileAppend, %FileUp%, %LogFile%
FileRead, FileUp, %LogFile%
gui 3: default
GuiControl,,MainEdit, %FileUP% 
}
return










RemoveTooltipLines(File) {
Loop,parse,file, `n
{
If a_loopfield contains tooltip
continue
Line .= a_loopfield . "`n"
}
   Return line
}
return

ShortBlocks(file)
{
Loop,parse,file, `n
{
If a_loopfield contains WinWait,,,IfWinNotActive
continue
Line .= a_loopfield . "`n"
}
   Return line
}

Foldblocks(File) 
{
 if file contains WinWait(title
  return file

  Loop,parse,file, `n
   {
    If a_loopfield contains IfWinNotActive,WinWait,WinWaitActive,`%tt`%,tooltip,ToolTip,`, `%tt
    continue
    Line .= a_loopfield . "`n"
   }


  Loop,parse,line, `n
   {
    cm := a_loopfield
    If cm contains WinActivate
     {
      cm :=RegExReplace(cm, "Activate, "   , "Wait(""") 
      cm :=RegExReplace(cm, ",`r"   , "`r")
      cm :=RegExReplace(cm, ", `r"   , "`r") 

      cm :=RegExReplace(cm, "`,"   , "`r") 

 
      If cm not contains `r)
      cm :=RegExReplace(cm, "`r"   , """)`r") 
     }
     Lineb .= cm . "`n"
   }

  Loop,parse,lineb, `n
   {
    cm := a_loopfield
    If cm contains tt:=
     {
      cm :=RegExReplace(cm, "tt:="   , "WinWait(")
      If cm not contains )
      cm :=RegExReplace(cm, "$"   , ")") 
     }
     Linec .= cm . "`n"
   }

lineb:=linec


firstline=
(
WinWait(title, text="")
{
  CoordMode, ToolTip
  ToolTip, Waiting... `%title`%, 80, 0
  WinActivate, `%title`%, `%text`%
  WinWaitActive, `%title`%, `%text`%, 3
  if ErrorLevel
  {
    WinWait, `%title`%, `%text`%
    WinActivate
    Sleep, 500
  }
  ToolTip
}
)

  if lineb not contains WinWait(title
   {
    firstline .= "`n" . Lineb 
    Return firstline
   }
  else
   return

}
return





RemoveEmptyLines(File) {
f := RegExReplace(file, "\R+\R", "`r`n")
   Return f
}



RemoveTitleLines(File) {
Loop,parse,file, `n
{
cm := a_loopfield

  If cm contains ahk_class
   {
     cm := RegExReplace(cm,"(?<=,).+?(?= ahk_class)","")
     cm := RegExReplace(cm,"(?<="").+?(?=ahk_class)","")
   }

Line .= cm . "`n"
}
   Return Line
}




RemoveTitleClassLines(File) {
Loop,parse,file, `n
{
cm := a_loopfield

  If cm contains ahk_class
   {
     cm := RegExReplace(cm,"(?= ahk_class).+?(?<=,)" , ",")
     cm := RegExReplace(cm,"(?= ahk_class).+?(?<="")" , """")

   }

Line .= cm . "`n"
}
   Return Line
}




;-------------------------------------------------------------------------------------
addsleepaftersend(file) {
cm := file

     cm := RegExReplace(cm,"(\n|\r)+?Send","`nSleep, 200 `nSend ")
return cm
}


SaveCurrentFileb: 
gui 3:default
GuiControlGet, filedown,, MainEdit
FileDelete, %LogFile%
FileAppend, %filedown%, %LogFile%
filedown=

gui 1:default
gui 3: Hide

return 



internaleditor:
gui 3:show
gui 3:default

readfile:
FileRead, FileUp, %logfile%
GuiControl,,MainEdit, %FileUP% 
return


FileNew:
GuiControl,, MainEdit  ; Clear the Edit control.
return

FileOpen:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, 3,, Open File, Text Documents (*.txt)
if SelectedFileName =  ; No file selected.
    return
Gosub FileRead
return

FileRead:  ; Caller has set the variable SelectedFileName for us.
FileRead, MainEdit, %SelectedFileName%  ; Read the file's contents into the variable.
if ErrorLevel
{
    MsgBox Could not open "%SelectedFileName%".
    return
}
GuiControl,, MainEdit, %MainEdit%  ; Put the text into the control.
;CurrentFileName = %SelectedFileName%
CurrentFileName = %LogFile%
Gui 3: Show,, %CurrentFileName%   ; Show file name in title bar.
return

FileSave:
CurrentFileName = %LogFile%
if CurrentFileName =   ; No filename selected yet, so do Save-As instead.
    Goto FileSaveAs
Gosub SaveCurrentFile
return

FileSaveAs:
Gui +OwnDialogs  ; Force the user to dismiss the FileSelectFile dialog before returning to the main window.
FileSelectFile, SelectedFileName, S16,, Save File, Text Documents (*.txt)
if SelectedFileName =  ; No file selected.
    return
CurrentFileName = %SelectedFileName%
Gosub SaveCurrentFile
return

SaveCurrentFile:  ; Caller has ensured that CurrentFileName is not blank.
IfExist %CurrentFileName%
{
    FileDelete %CurrentFileName%
    if ErrorLevel
    {
        MsgBox The attempt to overwrite "%CurrentFileName%" failed.
        return
    }
}
GuiControlGet, MainEdit  ; Retrieve the contents of the Edit control.
FileAppend, %MainEdit%, %CurrentFileName%  ; Save the contents to the file.
; Upon success, Show file name in title bar (in case we were called by FileSaveAs):
Gui 3: Show,, %CurrentFileName%
return


SaveAndBackup:
gosub, filesave

if !backupfile
backupfile:= SubStr( LogFile, 1, -3 ) . "bak"

IfExist %BackupFile%
{
    FileDelete %BackupFile%
    if ErrorLevel
    {
        MsgBox The attempt to overwrite "%CurrentFileName%" failed.
        return
    }
}
GuiControlGet, MainEdit  ; Retrieve the contents of the Edit control.
FileAppend, %MainEdit%, %BackupFile%  ; Save the contents to the backup file.
return


HelpAbout:
Gui, 4:+owner3  ; Make the main window (Gui #3) the owner of the "about box" (Gui #4).
Gui, 3: +Disabled  ; Disable main window.
Gui, 4:Add, Text,, Unofficial Macro Recorder %ScriptVersion% `nby SpeedMaster `noriginal script by FeiYue
Gui, 4:Add, Text,, https://autohotkey.com//boards/viewtopic.php?f=6&t=34184
Gui, 4:Add, Button, Default, OK
Gui, 4:Show
return

Shortcuts:
Gui, 5:+owner3  ; Make the main window (Gui #3) the owner of the "about box" (Gui #4).
Gui, 3: +Disabled  ; Disable main window.
gui 5: font, s12, Lucida Console
Gui, 5:Add, Text, w420 h250, % Shortcuts
Gui, 5:Add, Button, Default, OK
Gui, 5:Show
return


5ButtonOK:  ; This section is used by the "shortcuts box" above.
5GuiClose:
5GuiEscape:
Gui, 3: -Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui Destroy  ; Destroy the shortcuts box.
return

4ButtonOK:  ; This section is used by the "about box" above.
4GuiClose:
4GuiEscape:
Gui, 3: -Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui Destroy  ; Destroy the about box.
return

GuiDropFiles:  ; Support drag & drop.
Loop, parse, A_GuiEvent, `n
{
    SelectedFileName = %A_LoopField%  ; Get the first file only (in case there's more than one).
    break
}
Gosub FileRead
return

externaleditor:
Run, %EditorPath% "%LogFile%"
return

FileExit:     ; User chose "Exit" from the File menu.
GuiClose:  ; User closed the window.
Gui 3: hide

return


findtext:
gosub, Main_Window


return


/*
===========================================
  FindText - Capture screen image into text and then find it
  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834

  Author  :  FeiYue
  Version :  5.2
  Date    :  2017-06-10

  Usage:
  1. Capture the image to text string.
  2. Test find the text string on full Screen.
  3. When test is successful, you may copy the code
     and paste it into your own script.
     Note: Copy the "FindText()" function and the following
     functions and paste it into your own script Just once.

===========================================
  Introduction of function parameters:

  returnArray := FindText( center point X, center point Y
    , Left and right offset to the center point W
    , Up and down offset to the center point H
    , Character "0" fault-tolerant in percentage
    , Character "_" fault-tolerant in percentage, text )

  parameters of the X,Y is the center of the coordinates,
  and the W,H is the offset distance to the center,
  So the search range is (X-W, Y-H)-->(X+W, Y+H).

  The fault-tolerant parameters allow the loss of specific
  characters, very useful for gray threshold model.

  Text parameters can be a lot of text to find, separated by "|".

  return is a array, contains the X,Y,W,H,Comment results of Each Find.

===========================================
*/
ftext:
#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, Shell32.dll, 23
Menu, Tray, Add
Menu, Tray, Add, Main_Window
Menu, Tray, Default, Main_Window
Menu, Tray, Click, 1
; The capture range can be changed by adjusting the numbers
;----------------------------
  ww:=35, hh:=12
;----------------------------
nW:=2*ww+1, nH:=2*hh+1
Gosub, MakeCaptureWindow
Gosub, MakeMainWindow
Gosub, Load_ToolTip_Text
OnExit, savescr
Gosub, readscr
return


F12::    ; Hotkey --> Reload
SetTitleMatchMode, 2
SplitPath, A_ScriptName,,,, name
IfWinExist, %name%
{
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  Sleep, 500
}
Reload
return


Load_ToolTip_Text:
ToolTip_Text=
(LTrim
Capture   = Initiate Image Capture Sequence
Test      = Test Results of Code
Copy      = Copy Code to Clipboard
AddFunc   = Additional FindText() in Copy
U         = Cut the Upper Edge by 1
U3        = Cut the Upper Edge by 3
L         = Cut the Left Edge by 1
L3        = Cut the Left Edge by 3
R         = Cut the Right Edge by 1
R3        = Cut the Right Edge by 3
D         = Cut the Lower Edge by 1
D3        = Cut the Lower Edge by 3
Auto      = Automatic Cutting Edge`r`nOnly after Color2Two or Gray2Two
Similar   = Adjust color similarity as Equivalent to The Selected Color
SelCol    = Selected Image Color which Determines Black or Pixel White Conversion (Hex of Color)
Gray      = Grayscale Threshold which Determines Black or White Pixel Conversion (0-255)
Color2Two = Converts Image Pixels from Color to Black or White`r`nDepending on Selection Color and Sensitivity
Gray2Two  = Converts Image Pixels from Grays to Black or White`r`nDepending on Gray Threshold
Modify    = Allows for Pixel Cleanup of Black and White Image`r`nOnly After Gray2Two or Color2Two
Reset     = Reset to Original Captured Image
Invert    = Invert Images Black and White`r`nOnly after Color2Two or Gray2Two
Comment   = Optional Comment used to Label Code ( Within <> )
OK        = Create New FindText Code for Testing
Append    = Append Another FindText Search Text into Previously Generated Code
Close     = Close the Window Don't Do Anything
)
return

readscr:
f=%A_Temp%\~scr.tmp
FileRead, s, %f%
GuiControl, Main:, scr, %s%
s=
return

savescr:
f=%A_Temp%\~scr.tmp
GuiControlGet, s, Main:, scr
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

Main_Window:
Gui, Main:Show, Center
return

MakeMainWindow:
Gui, Main:Default
Gui, +AlwaysOnTop +HwndMain_ID
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s6 bold, Verdana
Gui, Add, Edit, xm w660 r25 vMyEdit -Wrap -VScroll
Gui, Font, s12 norm, Verdana
Gui, Add, Button, w220 gMainRun, Capture
Gui, Add, Button, x+0 wp gMainRun, Test
Gui, Add, Button, x+0 wp gMainRun Section, Copy
Gui, Font, s10
Gui, Add, Text, xm, Click Text String to See ASCII Search Text in the Above
Gui, Add, Checkbox, xs yp w220 r1 -Wrap Checked vAddFunc, Additional FindText() in Copy
Gui, Font, s12 cBlue, Verdana
Gui, Add, Edit, xm w660 h350 vscr Hwndhscr -Wrap HScroll
;Gui, Show, NA, Capture Image To Text And Find Text Tool
;---------------------------------------
OnMessage(0x100, "EditEvents1")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents2")  ; WM_LBUTTONDOWN
OnMessage(0x200, "WM_MOUSEMOVE") ; Show ToolTip
return

EditEvents1() {
  ListLines, Off
  if (A_Gui="Main") and (A_GuiControl="scr")
    SetTimer, ShowText, -100
}

EditEvents2() {
  ListLines, Off
  if (A_Gui="Capture")
    WM_LBUTTONDOWN()
  else
    EditEvents1()
}

ShowText:
ListLines, Off
Critical
ControlGet, i, CurrentLine,,, ahk_id %hscr%
ControlGet, s, Line, %i%,, ahk_id %hscr%
s := ASCII(s)
GuiControl, Main:, MyEdit, % Trim(s,"`n")
return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Main_ID%
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, scr
return

Copy:
GuiControlGet, s,, scr
GuiControlGet, AddFunc
if AddFunc != 1
  s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
Clipboard:=StrReplace(s,"`n","`r`n")
s=
return

Capture:
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x08000000
WinSet, Transparent, 100
Gui, Color, Red
Gui, Show, Hide w%nW% h%nH%
;------------------------------
Hotkey, $*LButton, _LButton_Off, On
ListLines, Off
Loop {
  MouseGetPos, px, py
  if GetKeyState("LButton","P")
    Break
  Gui, Show, % "NA x" (px-ww) " y" (py-hh)
  ToolTip, % "The Mouse Pos : " px "," py
    . "`nPlease Move and Click LButton"
  Sleep, 20
}
KeyWait, LButton
Gui, Color, White
Loop {
  MouseGetPos, x, y
  if Abs(px-x)+Abs(py-y)>100
    Break
  Gui, Show, % "NA x" (x-ww) " y" (y-hh)
  ToolTip, Please Move Mouse > 100 Pixels
  Sleep, 20
}
ToolTip
ListLines, On
Hotkey, $*LButton, Off
Gui, Destroy
WinWaitClose
cors:=getc(px,py,ww,hh)
Gui, Capture:Default
GuiControl,, SelCol
GuiControl,, Gray
GuiControl,, Modify, % Modify:=0
GuiControl, Focus, Gray
Gosub, Reset
Gui, Show, Center
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Capture_ID%
_LButton_Off:
return

WM_LBUTTONDOWN() {
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  if !InStr(mclass,"progress")
    return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (Modify and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : WindowColor
        Gosub, SetColor
      }
      else
        GuiControl, Capture:, SelCol, % cors[k]
      return
    }
}

getc(px, py, ww, hh) {
  xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh-y+A_Index-1
    Loop, %nW% {
      i:=px-ww-x+A_Index-1, k++
      if (i>=0 and i<w and j>=0 and j<h)
        c:=NumGet(Scan0+0,i*4+j*Stride,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  cors.left:=Abs(px-ww-x)
  cors.right:=Abs(px+ww-(x+w-1))
  cors.up:=Abs(py-hh-y)
  cors.down:=Abs(py+hh-(y+h-1))
  SetBatchLines, %bch%
  return, cors
}

Test:
GuiControlGet, s, Main:, scr
text=
While RegExMatch(s,"i)Text[.:]=""([^""]+)""",r)
  text.=r1, s:=StrReplace(s,r,"","",1)
if !RegExMatch(s,"i)FindText\(([^)]+)\)",r)
  return
StringSplit, r, r1, `,, ""
if r0<7
  return
t1:=A_TickCount
ok:=FindText(r1,r2,r3,r4,r5,r6,text)
t1:=A_TickCount-t1
X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5
X+=W//2, Y+=H//2
MsgBox, 4096, Tip
  , %   "  Find Result   `t:  " (ok ? "OK":"NO")
  . "`n`n  Find Time     `t:  " t1  " ms`t`t"
  . "`n`n  Find Position `t:  " (ok ? X ", " Y:"")
  . "`n`n  Find Comment  `t:  " Comment
if ok
{
  MouseMove, X, Y
  Sleep, 1000
}
return

MakeCaptureWindow:
WindowColor:="0xCCDDEE"
Gui, Capture:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow +HwndCapture_ID
Gui, Margin, 15, 15
Gui, Color, %WindowColor%
Gui, Font, s14, Verdana
ListLines, Off
w:=800//nW+1, h:=(A_ScreenHeight-300)//nH+1, w:=h<w ? h:w
Loop, % nH*nW {
  j:=A_Index=1 ? "" : Mod(A_Index,nW)=1 ? "xm y+-1" : "x+-1"
  Gui, Add, Progress, w%w% h%w% %j% -Theme
}
ListLines, On
Gui, Add, Button, xm+95  w45 gUpCut Section, U
Gui, Add, Button, x+0    wp gUpCut3, U3
Gui, Add, Text,   xm+310 yp+6 Section, Color Similarity  0
Gui, Add, Slider
  , x+0 w250 vSimilar Page1 NoTicks ToolTip Center, 100
Gui, Add, Text,   x+0, 100
Gui, Add, Button, xm     w45 gLeftCut, L
Gui, Add, Button, x+0    wp gLeftCut3, L3
Gui, Add, Button, x+15   w70 gRun, Auto
Gui, Add, Button, x+15   w45 gRightCut, R
Gui, Add, Button, x+0    wp gRightCut3, R3
Gui, Add, Text,   xs     w160 yp, Selected  Color
Gui, Add, Edit,   x+15   w140 vSelCol
Gui, Add, Button, x+15   w150 gRun, Color2Two
Gui, Add, Button, xm+95  w45 gDownCut, D
Gui, Add, Button, x+0    wp gDownCut3, D3
Gui, Add, Text,   xs     w160 yp, Gray Threshold
Gui, Add, Edit,   x+15   w140 vGray
Gui, Add, Button, x+15   w150 gRun Default, Gray2Two
Gui, Add, Checkbox, xm   y+21 gRun vModify, Modify
Gui, Add, Button, x+5    yp-6 gRun, Reset
Gui, Add, Button, x+15   gRun, Invert
Gui, Add, Text,   x+15   yp+6, Add Comment
Gui, Add, Edit,   x+5    w100 vComment
Gui, Add, Button, x+15   w85 yp-6 gRun, OK
Gui, Add, Button, x+10   gRun, Append
Gui, Add, Button, x+10   gCancel, Close
Gui, Show, Hide, Capture Image To Text
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
return

/*
Run:
Critical
k:=A_GuiControl
if IsLabel(k)
  Goto, %k%
return
*/

Modify:
GuiControlGet, Modify
return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
return

Reset:
if !IsObject(cc)
  cc:=[], gc:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nH*nW {
  cc[++k]:=1, c:=cors[k], gc[k]:=(((c>>16)&0xFF)*299
    +((c>>8)&0xFF)*587+(c&0xFF)*114)//1000
  Gosub, SetColor
}
Loop, % cors.left
  Gosub, LeftCut
Loop, % cors.right
  Gosub, RightCut
Loop, % cors.up
  Gosub, UpCut
Loop, % cors.down
  Gosub, DownCut
return

Color2Two:
GuiControlGet, Similar
GuiControlGet, r,, SelCol
if r=
{
  MsgBox, 4096, Tip
    , `n  Please Select a Color First !  `n, 1
  return
}
Similar:=Round(Similar/100,2), n:=Floor(255*3*(1-Similar))
color:=r "@" Similar, k:=i:=0
rr:=(r>>16)&0xFF, gg:=(r>>8)&0xFF, bb:=r&0xFF
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  c:=cors[k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
  if Abs(r-rr)+Abs(g-gg)+Abs(b-bb)<=n
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

Gray2Two:
GuiControl, Focus, Gray
GuiControlGet, Threshold,, Gray
if Threshold=
{
  Loop, 256
    pp[A_Index-1]:=0
  Loop, % nH*nW
    if (cc[A_Index]!="")
      pp[gc[A_Index]]++
  IP:=IS:=0
  Loop, 256
    k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
  NewThreshold:=Floor(IP/IS)
  Loop, 20 {
    Threshold:=NewThreshold
    IP1:=IS1:=0
    Loop, % Threshold+1
      k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
    IP2:=IP-IP1, IS2:=IS-IS1
    if (IS1!=0 and IS2!=0)
      NewThreshold:=Floor((IP1/IS1+IP2/IS2)/2)
    if (NewThreshold=Threshold)
      Break
  }
  GuiControl,, Gray, %Threshold%
}
color:="*" Threshold, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  if (gc[k]<Threshold+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

gui_del:
cc[k]:="", c:=WindowColor
Gosub, SetColor
return

LeftCut3:
Loop, 3
  Gosub, LeftCut
return

LeftCut:
if (left+right>=nW)
  return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

RightCut3:
Loop, 3
  Gosub, RightCut
return

RightCut:
if (left+right>=nW)
  return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

UpCut3:
Loop, 3
  Gosub, UpCut
return

UpCut:
if (up+down>=nH)
  return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

DownCut3:
Loop, 3
  Gosub, DownCut
return

DownCut:
if (up+down>=nH)
  return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

getwz:
wz=
if bg=
  return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
return

Auto:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
While InStr(wz,bg) {
  if (wz~="^" bg "+\n")
  {
    wz:=RegExReplace(wz,"^" bg "+\n")
    Gosub, UpCut
  }
  else if !(wz~="m`n)[^\n" bg "]$")
  {
    wz:=RegExReplace(wz,"m`n)" bg "$")
    Gosub, RightCut
  }
  else if (wz~="\n" bg "+\n$")
  {
    wz:=RegExReplace(wz,"\n\K" bg "+\n$")
    Gosub, DownCut
  }
  else if !(wz~="m`n)^[^\n" bg "]")
  {
    wz:=RegExReplace(wz,"m`n)^" bg)
    Gosub, LeftCut
  }
  else Break
}
wz=
return

OK:
Append:
Invert:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
if A_ThisLabel=Invert
{
  wz:="", k:=0, bg:=bg="0" ? "_":"0"
  color:=InStr(color,"-") ? StrReplace(color,"-"):"-" color
  Loop, % nH*nW
    if (c:=cc[++k])!=""
    {
      cc[k]:=c="0" ? "_":"0", c:=c="0" ? "White":"Black"
      Gosub, SetColor
    }
  return
}
Gui, Hide
if A_ThisLabel=Append
{
  add(towz(color,wz))
  return
}
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
s:= StrReplace(towz(color,wz),"Text.=","Text:=")
  . "`nif ok:=FindText(" px1 "," py1
  . ",150000,150000,0,0,Text)`n"
  . "{`n  CoordMode, Mouse"
  . "`n  X:=ok.1, Y:=ok.2, W:=ok.3, H:=ok.4, Comment:=ok.5"
  . "`n  MouseMove, X+W//2, Y+H//2`n}`n"
if !A_IsCompiled
{
  FileRead, fs, %A_ScriptFullPath%
  fs:=SubStr(fs,fs~="i)\n[;=]+ Copy The")
}
GuiControl, Main:, scr, %s%`n%fs%
s:=wz:=fs:=""
return

towz(color,wz) {
  global Comment
  GuiControlGet, Comment
  SetFormat, IntegerFast, d
  wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
  wz:=InStr(wz,"`n")-1 . "." . bit2base64(wz)
  return, "`nText.=""|<" Comment ">" color "$" wz """`n"
}

add(s) {
  global hscr
  s:=RegExReplace("`n" s "`n","\R","`r`n")
  ControlGet, i, CurrentCol,,, ahk_id %hscr%
  if i>1
    ControlSend,, {Home}{Down}, ahk_id %hscr%
  Control, EditPaste, %s%,, ahk_id %hscr%
}
/*
WM_MOUSEMOVE()
{
  ListLines, Off
  static CurrControl, PrevControl
  CurrControl := A_GuiControl
  if (CurrControl!=PrevControl)
  {
    PrevControl := CurrControl
    ToolTip
    if CurrControl !=
      SetTimer, DisplayToolTip, -1000
  }
  return


  DisplayToolTip:
  ListLines, Off
  k:="ToolTip_Text"
  TT_:=RegExMatch(%k%,"m`n)^" . CurrControl
    . "\K\s*=.*", r) ? Trim(r,"`t =") : ""
  MouseGetPos,,, k
  WinGetClass, k, ahk_id %k%
  if k = AutoHotkeyGUI
  {
    ToolTip, %TT_%
    SetTimer, RemoveToolTip, -5000
  }
  return

  RemoveToolTip:
  ToolTip
  return
}
*/

;===== Copy The Following Functions To Your Own Code Just once =====


; Note: parameters of the X,Y is the center of the coordinates,
; and the W,H is the offset distance to the center,
; So the search range is (X-W, Y-H)-->(X+W, Y+H).
; err1 is the character "0" fault-tolerant in percentage.
; err0 is the character "_" fault-tolerant in percentage.
; Text can be a lot of text to find, separated by "|".
; ruturn is a array, contains the X,Y,W,H,Comment results of Each Find.

FindText(x,y,w,h,err1,err0,text)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h, arr:=[]
  Loop, 2 {
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    Comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), Comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    ;--------------------------------------------
    if InStr(color,"-")
    {
      r:=e1, e1:=e0, e0:=r, v:=StrReplace(v,"1","_")
      v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    }
    mode:=InStr(color,"*") ? 1:0
    color:=RegExReplace(color,"[*\-]") . "@"
    StringSplit, r, color, @
    color:=Round(r1), n:=Round(r2,2)+(!r2)
    n:=Floor(255*3*(1-n)), k:=StrLen(v)*4
    VarSetCapacity(ss, sw*sh, Asc("0"))
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    VarSetCapacity(rx, 8, 0), VarSetCapacity(ry, 8, 0)
    len1:=len0:=0, j:=sw-w1+1, i:=-j
    ListLines, Off
    Loop, Parse, v
    {
      i:=Mod(A_Index,w1)=1 ? i+j : i+1
      if A_LoopField
        NumPut(i, s1, 4*len1++, "int")
      else
        NumPut(i, s0, 4*len0++, "int")
    }
    ListLines, On
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    ;--------------------------------------------
    if PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,ss,s1,s0,len1,len0,e1,e0,w1,h1,rx,ry)
    {
      rx+=x, ry+=y
      arr.Push(rx,ry,w1,h1,Comment)
    }
  }
  if (arr.MaxIndex())
    Break
  if (A_Index=1 and err1=0 and err0=0)
    err1:=0.05, err0:=0.05
  else Break
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride
  , sx, sy, sw, sh, ByRef ss, ByRef s1, ByRef s0
  , len1, len0, err1, err0, w, h, ByRef rx, ByRef ry)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E583EC408B45200FAF45188B551CC1E20201D08945F"
    . "48B5524B80000000029D0C1E00289C28B451801D08945D8C74"
    . "5F000000000837D08000F85F00000008B450CC1E81025FF000"
    . "0008945D48B450CC1E80825FF0000008945D08B450C25FF000"
    . "0008945CCC745F800000000E9AC000000C745FC00000000E98"
    . "A0000008B45F483C00289C28B451401D00FB6000FB6C02B45D"
    . "48945EC8B45F483C00189C28B451401D00FB6000FB6C02B45D"
    . "08945E88B55F48B451401D00FB6000FB6C02B45CC8945E4837"
    . "DEC007903F75DEC837DE8007903F75DE8837DE4007903F75DE"
    . "48B55EC8B45E801C28B45E401D03B45107F0B8B55F08B452C0"
    . "1D0C600318345FC018345F4048345F0018B45FC3B45240F8C6"
    . "AFFFFFF8345F8018B45D80145F48B45F83B45280F8C48FFFFF"
    . "FE9A30000008B450C83C00169C0E803000089450CC745F8000"
    . "00000EB7FC745FC00000000EB648B45F483C00289C28B45140"
    . "1D00FB6000FB6C069D02B0100008B45F483C00189C18B45140"
    . "1C80FB6000FB6C069C04B0200008D0C028B55F48B451401D00"
    . "FB6000FB6C06BC07201C83B450C730B8B55F08B452C01D0C60"
    . "0318345FC018345F4048345F0018B45FC3B45247C948345F80"
    . "18B45D80145F48B45F83B45280F8C75FFFFFF8B45242B45488"
    . "3C0018945488B45282B454C83C00189454C8B453839453C0F4"
    . "D453C8945D8C745F800000000E9E3000000C745FC00000000E"
    . "9C70000008B45F80FAF452489C28B45FC01D08945F48B45408"
    . "945E08B45448945DCC745F000000000EB708B45F03B45387D2"
    . "E8B45F08D1485000000008B453001D08B108B45F401D089C28"
    . "B452C01D00FB6003C31740A836DE001837DE00078638B45F03"
    . "B453C7D2E8B45F08D1485000000008B453401D08B108B45F40"
    . "1D089C28B452C01D00FB6003C30740A836DDC01837DDC00783"
    . "08345F0018B45F03B45D87C888B551C8B45FC01C28B4550891"
    . "08B55208B45F801C28B45548910B801000000EB2990EB01908"
    . "345FC018B45FC3B45480F8C2DFFFFFF8345F8018B45F83B454"
    . "C0F8C11FFFFFFB800000000C9C25000"
    x64:="554889E54883EC40894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945F48B5548B8000000002"
    . "9D0C1E00289C28B453001D08945D8C745F000000000837D100"
    . "00F85000100008B4518C1E81025FF0000008945D48B4518C1E"
    . "80825FF0000008945D08B451825FF0000008945CCC745F8000"
    . "00000E9BC000000C745FC00000000E99A0000008B45F483C00"
    . "24863D0488B45284801D00FB6000FB6C02B45D48945EC8B45F"
    . "483C0014863D0488B45284801D00FB6000FB6C02B45D08945E"
    . "88B45F44863D0488B45284801D00FB6000FB6C02B45CC8945E"
    . "4837DEC007903F75DEC837DE8007903F75DE8837DE4007903F"
    . "75DE48B55EC8B45E801C28B45E401D03B45207F108B45F0486"
    . "3D0488B45584801D0C600318345FC018345F4048345F0018B4"
    . "5FC3B45480F8C5AFFFFFF8345F8018B45D80145F48B45F83B4"
    . "5500F8C38FFFFFFE9B60000008B451883C00169C0E80300008"
    . "94518C745F800000000E98F000000C745FC00000000EB748B4"
    . "5F483C0024863D0488B45284801D00FB6000FB6C069D02B010"
    . "0008B45F483C0014863C8488B45284801C80FB6000FB6C069C"
    . "04B0200008D0C028B45F44863D0488B45284801D00FB6000FB"
    . "6C06BC07201C83B451873108B45F04863D0488B45584801D0C"
    . "600318345FC018345F4048345F0018B45FC3B45487C848345F"
    . "8018B45D80145F48B45F83B45500F8C65FFFFFF8B45482B859"
    . "000000083C0018985900000008B45502B859800000083C0018"
    . "985980000008B45703945780F4D45788945D8C745F80000000"
    . "0E90B010000C745FC00000000E9EC0000008B45F80FAF45488"
    . "9C28B45FC01D08945F48B85800000008945E08B85880000008"
    . "945DCC745F000000000E9800000008B45F03B45707D368B45F"
    . "04898488D148500000000488B45604801D08B108B45F401D04"
    . "863D0488B45584801D00FB6003C31740A836DE001837DE0007"
    . "8778B45F03B45787D368B45F04898488D148500000000488B4"
    . "5684801D08B108B45F401D04863D0488B45584801D00FB6003"
    . "C30740A836DDC01837DDC00783C8345F0018B45F03B45D80F8"
    . "C74FFFFFF8B55388B45FC01C2488B85A000000089108B55408"
    . "B45F801C2488B85A80000008910B801000000EB2F90EB01908"
    . "345FC018B45FC3B85900000000F8C05FFFFFF8345F8018B45F"
    . "83B85980000000F8CE6FEFFFFB8000000004883C4405DC390"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "ptr",&s1, "ptr",&s0
    , "int",len1, "int",len0, "int",err1, "int",err0
    , "int",w, "int",h, "int*",rx, "int*",ry)
}

xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
{
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits)
{
  VarSetCapacity(bits,w*h*4,0), bpp:=32
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  ;-------------------------
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  ;-------------------------
  if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
  {
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    DllCall("RtlMoveMemory","ptr",Scan0,"ptr",ppvBits,"ptr",Stride*h)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteObject", Ptr,hBM)
  }
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
}

base64tobit(s)
{
  ListLines, Off
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  StringCaseSense, On
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,A_LoopField,v)
  }
  StringCaseSense, Off
  s:=SubStr(s,1,InStr(s,"1",0,0)-1)
  s:=RegExReplace(s,"[^01]+")
  ListLines, On
  return, s
}

bit2base64(s)
{
  ListLines, Off
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,v,A_LoopField)
  }
  ListLines, On
  return, s
}

ASCII(s)
{
  if RegExMatch(s,"(\d+)\.([\w+/]{3,})",r)
  {
    s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return, s
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}

; You can put the text library at the beginning of the script,
; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib
Pic(comments, add_to_Lib=0) {
  static Lib:=[]
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]{3,}"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
        Lib[Trim(r1)]:=r
  }
  else
  {
    text:=""
    Loop, Parse, comments, |
      text.="|" . Lib[Trim(A_LoopField)]
    return, text
  }
}


/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(int mode
  , unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, int * s1, int * s0
  , int len1, int len0, int err1, int err0
  , int w, int h, int * rx, int * ry)
{
  int x, y, o=sy*Stride+sx*4, j=Stride-4*sw, i=0;
  int r, g, b, rr, gg, bb, e1, e0;
  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
        if (r+g+b<=n) ss[i]='1';
      }
  }
  else  // Gray Threshold Mode
  {
    c=(c+1)*1000;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c)
          ss[i]='1';
  }
  w=sw-w+1; h=sh-h+1;
  j=len1>len0 ? len1 : len0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      for (i=0; i<j; i++)
      {
        if (i<len1 && ss[o+s1[i]]!='1' && (--e1)<0)
          goto NoMatch;
        if (i<len0 && ss[o+s0[i]]!='0' && (--e0)<0)
          goto NoMatch;
      }
      rx[0]=sx+x; ry[0]=sy+y;
      return 1;
      NoMatch:
      continue;
    }
  }
  return 0;
}

*/


;================= The End =================

