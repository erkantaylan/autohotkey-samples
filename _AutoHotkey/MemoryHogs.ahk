;Memory Hogs - a script to display a list of processes sorted by RAM usage high to low
;allows CPU Load, Free Disk space, Process RAM use and Process Not Responding to be monitored and logged
;Michael Todd 12/21/16
;Version 1.32

#SingleInstance force
SetFormat,Float,5.1
SetWorkingDir,%A_ScriptDir%
SetTitleMatchMode,2
SetBatchLines,-1
DetectHiddenWindows,On

;set globals
global NumProcesses,Threshold,ThresholdCPU,AlwaysShow=false,CPU,Show=true,ShowD=true,ShowR=true,ShowP=true,version=1.32
global Vertical,Horizontal,DiskSpace,ShowDiskSpaceForPCsNamed,ThresholdDisk,AutoStart=0
global NotRespondingAlert=true,DiskspaceAlert=false,CPUAlert=true,LogAlerts=false,StealthMode=false,PAGEAlert=true,RAMAlert=true
global NotRespondingAlertStatus,DiskspaceAlertStatus,CPUAlertStatus,LogAlertsStatus,PAGEAlertStatus,RAMAlertStatus
global aProcess={},aProcessSeconds,ExcludeProcesses,freeze=false
global UsedRAM,UsedPage,UsedRAMThreshold=90,UsedPageThreshold=90,NumProcUpDown
/* Variable definitions
NumProcesses - the number of processes to show in the list view
Threshold - the RAM memory threshold for processes
ThresholdCPU - the CPU load threshold for Windows
AlwaysShow - causes the program window to stay visible
CPU - the value returned from CPU_Load function
Show - true/false used for Flashing CPU text
ShowD - true/false used for Flashing Diskspace text
ShowR - true/false used for Flashing RAM text
ShowP - true/false used for Flashing Page File text
version - current program version
Vertical - Vertical position of the main window, top or bottom
Horizontal - Horizontal position of the main window, left of right
DiskSpace - threshold or minimum disk space for alerts
ShowDiskSpaceForPCsNamed - enter a PC name or part of a name to 'turn on' display and monitoring of disk space
                         - intended for Virtual Desktops or specialized PCs with little disk storage 10gb or less.
ThresholdDisk - disk space in gigabytes, less than this amount of free space results in alerts and logging
AutoStart - sets/unsets AutoStart in the User's Startup folder
NotRespondingAlert - true/false for monitoring when a process is Not Responding
DiskspaceAlert - true/false for monitoring when diskspace is low
CPUAlert - true/false for monitoring when CPU Load is above the threshold
LogAlerts - true/false for saving each alert event to a CSV file
StealthMode - true/false, if true then all alerts are active, the main window is not shown, no Tray Tips and
              the Tray Icon is hidden. Only Hotstrings can access the program functions in StealthMode.
aProcess - an array of Processes that are Not Responding
aProcessSeconds - the number of seconds a Process must be Not Responding before seeing an alert
ExcludeProcesses - a list separated by | of processes that you do not want to see in Not Responding popups
                   for frequent flyer apps like DesktopInfo, TpAutoConnect, etc.
UsedRAM - Percent of Used RAM
UsedPage - Percent of Used Pagefile
UsedRAMThreshold=90 percent of RAM used threshold
UsedPageThreshold=90 percent of Page file used threshold
NumProcUpDown - used to store value from Up Down control next to Num Processes Edit box
*/

;read INI values
IniRead,NumProcesses,MemoryHogs.ini,settings,ProcessesToShow,5                          ;default to five processes displayed
If NumProcesses =
    NumProcesses = 5
IniRead,Threshold,MemoryHogs.ini,settings,RAM_Threshold,500                             ;default to 500 mb per process
If Threshold =
    Threshold = 500
IniRead,ThresholdCPU,MemoryHogs.ini,settings,CPU_Threshold,90                           ;default to 90% CPU Load
If ThresholdCPU =
    ThresholdCPU = 90
IniRead,Vertical,MemoryHogs.ini,settings,Vertical,bottom                                ;default to bottom of screen
IniRead,Horizontal,MemoryHogs.ini,settings,Horizontal,right                             ;default to right edge of screen
IniRead,ShowDiskSpaceForPCsNamed,MemoryHogs.ini,settings,ShowDiskSpaceForPCsNamed       ;default to VDI named PCs
IniRead,ThresholdDisk,MemoryHogs.ini,settings,Disk_Threshold,1                          ;default to 1gb
IniRead,AutoStart,MemoryHogs.ini,Settings,AutoStart
IniRead,aProcessSeconds,MemoryHogs.ini,settings,aProcessSeconds,9                       ;default to 9 seconds not responding
IniRead,ExcludeProcesses,MemoryHogs.ini,settings,ExcludeProcesses,|                     ;default to exclude None for not responding
IniRead,UsedRAMThreshold,MemoryHogs.ini,settings,UsedRAMThreshold,%UsedRAMThreshold%    ;defaults to 90% RAM, can be changed in INI
IniRead,UsedPageThreshold,MemoryHogs.ini,settings,UsedPageThreshold,%UsedPageThreshold% ;defaults to 90% Pagefile, can be changed in INI
IniRead,NotRespondingAlert,MemoryHogs.ini,settings,NotRespondingAlert,%NotRespondingAlert% 
IniRead,DiskspaceAlert,MemoryHogs.ini,settings,DiskspaceAlert,%DiskspaceAlert%
IniRead,CPUAlert,MemoryHogs.ini,settings,CPUAlert,%CPUAlert%
IniRead,LogAlerts,MemoryHogs.ini,settings,LogAlerts,%LogAlerts%
IniRead,StealthMode,MemoryHogs.ini,settings,StealthMode,%StealthMode%
IniRead,PAGEAlert,MemoryHogs.ini,settings,PAGEAlert,%PAGEAlert%
IniRead,RAMAlert,MemoryHogs.ini,settings,RAMAlert,%RAMAlert%

NumProcesses2:=NumProcesses+1   ;for proper listview height

FileInstall,UpdateMemoryHogs.exe,UpdateMemoryHogs.exe,1                                 ;install web updater

;check for commandline parameter s
numParams = %0%
if (numParams > 0) {
    param = %1%
    ;MsgBox Parameter: %param%
    if (param = "s") or (param = "S")
        StealthMode:=true
}

if Not(StealthMode) {
    DisplayMsg(18, "Please wait...","Loading Process List", "Memory Hogs Startup")
;initial startup instructions
IfNotExist,MemoryHogs.ini
{
AlwaysShow=true
msg =
(
Click OK and set the number of processes displayed, the RAM and CPU thresholds
then click Update or choose Restart Program. The program window is normally
not displayed unless the RAM or CPU Threshold values have been exceeded. If a 
process is Not Responding, you will see a Tray Tip window at the bottom right.

You can right click on the tray icon and choose Always Show to change the values
anytime or edit the MemoryHogs.ini file. Select Memory Hogs Info for additional
instructions.

Use Home, End, PageUp and PageDown keys to move the main window into any corner.
)    
MsgBox,0,BASIC SETUP,%msg%
}
}

;get disk free space
DriveSpaceFree,DiskSpace,c:\
DiskSpace := DiskSpace / 1024

;create Tray menu items
Menu,Alerts,Add,CPU Load,CPUalerts
Menu,Alerts,Add,DISK Space,DISKalerts
Menu,Alerts,Add,NOT Responding,RESPONSEalerts
Menu,Alerts,Add,PAGEFILE Usage,PAGEalerts
Menu,Alerts,Add,RAM Usage,RAMalerts

If (CPUalert)
    Menu,Alerts,Check,CPU Load
else
    Menu,Alerts,UnCheck,CPU Load
if (DiskspaceAlert)
    Menu,Alerts,Check,DISK Space
else
    Menu,Alerts,UnCheck,DISK Space
if (NotRespondingAlert)
    Menu,Alerts,Check,NOT Responding
else
    Menu,Alerts,UnCheck,NOT Responding
if (PAGEalert)
    Menu,Alerts,Check,PAGEFILE Usage
else
    Menu,Alerts,UnCheck,PAGEFILE Usage
if (RAMalert)
    Menu,Alerts,Check,RAM Usage
else
    Menu,Alerts,UnCheck,RAM Usage

Menu,Tray,NoStandard
Menu,Tray,Add,Memory Hogs v%version% Info,Info
Menu,Tray,Add,
Menu,Tray,Add,Always Show / Set Thresholds,AlwaysShow
Menu,Tray,Add,
Menu,Tray,Add,Other Alerts,:Alerts
Menu,Tray,Add,Log All Alerts,LogAlerts
If (LogAlerts)
    Menu,Tray,Check,Log All Alerts
Menu,Tray,Add,
Menu,Tray,Add,View Logs,ViewLogs
Menu,Tray,Add,View Settings,ViewSettings
Menu,Tray,Add,
Menu,Tray,Add,Restart Program,Reload
Menu,Tray,Add,AutoStart,AutoStart
Menu,Tray,Add,
Menu,Tray,Add,Go Stealth Mode,GoStealth
Menu,Tray,Add,Web Update,DoCheckUpdate
Menu,Tray,Add,
Menu,Tray,Add,Quit Program,GuiClose
;Menu,Tray,Check,Always Show / Set Thresholds

;create startup item
If A_IsCompiled and (AutoStart=1)
{
	FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\MemoryHogs.lnk
	Menu,Tray,Check,AutoStart
}
IfExist,%A_Startup%\MemoryHogs.lnk
    Menu,Tray,Check,AutoStart

;check once a day for an update
gosub,CheckForUpdate

;start 3 second timer (may make it user setting)
setTimer,Refresh,3000

Gui, Add, Text,w320 center,(Left double-click a task to stop it or right double-click to go to it.)
Gui, Font,Bold
Gui, Add, Text,xm+60 vAlwaysShow,[Always Show OFF]
Gui, Add, Text,x+5 w120 vCPULoad,[CPU Load: 000.0]
Gui, Add, Text,xm+45 w120 vUsedRAMPercentage,[Used RAM: 000.0]
Gui, Add, Text,x+5 w120 vUsedPageFilePercentage,[Used Page: 000.0]
if StrLen(ShowDiskSpaceForPCsNamed)>0 and InStr(A_ComputerName,ShowDiskSpaceForPCsNamed) {
    Gui, Add, Text,xm w320 center vDiskSpace,Available Disk Space: %DiskSpace% GB
}
Gui, Font,
Gui, Add, Text,xm,Processes`nshown:
Gui, Add, Edit,x+3 w40 Number Limit2 vNumProcesses,%NumProcesses%
Gui, Add, UpDown,vNumProcUpDown Range1-50,%NumProcesses%
Gui, Add, Text,x+3,Process`nThreshold:
Gui, Add, Edit,x+3 w40 Number Limit4 vThreshold,%Threshold%
Gui, Add, Text,x+3 vCPUtxt,CPU`nLoad`%:
Gui, Add, Edit,x+3 w30 Number Limit4 vThresholdCPU,%ThresholdCPU%
Gui, Add, Button,x+5 Default gUpdate,Update
Gui, Add, ListView,xm Checked r%NumProcesses2% w320 Count100 vMyLV gMyListview,Process Name|RAM (MB)|Path|PID|Status

OnMessage(0x404, "AHK_NOTIFYICON") ;routine to handle clicking on the tray icon

gosub,Refresh

;if StealthMode then don't show main window
if (StealthMode) {
    gosub,GoStealth
    Gui, Show, Hide AutoSize,Memory Hogs (ESC to Hide)
}
else
    Gui, Show, AutoSize,Memory Hogs (ESC to Hide)
Gui, +AlwaysOnTop +Resize

;display window on top at bottom right
WinGetPos,X,Y,W,H,Memory Hogs (ESC to Hide)
SnapActiveWindow(Vertical,Horizontal, H, W)
Progress,off
Return
;============== end of start up section =========================

;Use Alt-F to freeze/unfreeze the current list
#IfWinActive,Memory Hog
!f::
#IfWinActive
freeze:=Not(freeze)
if (freeze = false) {
   setTimer,Refresh,3000
   setTimer,FlashGUI,off
   MsgBox,0,THAWED OUT,Display is Active,2
}
return

FlashGUI:
Gui Flash
return

GuiSize:
GuiControl, Move, MyLV, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 75)
return

:*:@mhr::
Reload:
Gui, Submit
IniWrite,%NumProcesses%,MemoryHogs.ini,settings,ProcessesToShow
IniWrite,%Threshold%,MemoryHogs.ini,settings,RAM_Threshold
IniWrite,%ThresholdCPU%,MemoryHogs.ini,settings,CPU_Threshold
IniWrite,%UsedRAMThreshold%,MemoryHogs.ini,settings,UsedRAMThreshold
IniWrite,%UsedPageThreshold%,MemoryHogs.ini,settings,UsedPageThreshold
IniWrite,%NotRespondingAlert%,MemoryHogs.ini,settings,NotRespondingAlert
IniWrite,%DiskspaceAlert%,MemoryHogs.ini,settings,DiskspaceAlert
IniWrite,%CPUAlert%,MemoryHogs.ini,settings,CPUAlert
IniWrite,%LogAlerts%,MemoryHogs.ini,settings,LogAlerts
IniWrite,%StealthMode%,MemoryHogs.ini,settings,StealthMode
IniWrite,%PAGEAlert%,MemoryHogs.ini,settings,PAGEAlert
IniWrite,%RAMAlert%,MemoryHogs.ini,settings,RAMAlert

Reload
return

:*:@mhi::
Info:
Info =
(
Memory Hogs v%version%:

A small program that lists processes when one or more of them 
are using more memory than a desired threshold. If the process
is run away or frozen, left double-click it to close it. Right
double-clicking will open the folder the process is running from.
You can set the number of processes to list, alert values for the 
Process threshold RAM and also CPU Load `% then Refresh the window.
The Home, End, PageUp and PageDown keys may be used to move the 
window quickly to any corner. You may also right-click on the 
program icon and choose Always Show to have the window remain 
visible even when no processes are over the threshold.
The processes are updated every 3 seconds.

Recent changes:

v1.32 -
Added second download site to check during updates.

v1.31 -
Save changes after each Alert is turned on or off.

v1.30 -
Fixed some typos, not all Alerts were saving/retrieving correctly when 
exiting and restarting the program. Shortened Change Log also for updates.

v1.29 -
Pressing ALF-F at the Main window will Freeze it so you can make
changes to the numbers and double-click any processes to Exclude them
from or Include them into the Not Responding alerts. Click Update then
press ALT-F when you are finished to "Thaw" the display.

v1.28 -
Added two more Memory alerts to the main window, Used Physical
RAM percentage and Used Pagefile percentage.

v1.27 - 
Pass a parameter, either s or S, to the program and it starts in 
Stealth Mode.

v1.26 -
Changed Refresh button to Update. Now you can change the values then
click Update to see the effect without the program restarting.
Pressing ESCape key hides the window and set AlwaysShow OFF.

v1.25 -
For processes that frequently go Not Responding you can Exclude them
from showing alerts by double-clicking them and choosing EXCLUDE. They
will be displayed as gray or highlighted color to denote Excluded. If
your double-click them again you can choose INCLUDE and they will
alert on Not Responding. Processes that go over the RAM Threshold 
displayed with a checkmark.

v1.24 -
Users can click on the Tray icon to Show or Hide the main window now.

v1.23 -
Added a limiter for Not Responding processes called aProcessSeconds.
It defaults to 9 seconds a process has to be hung to display an alert.
This is three times through the normal 3 second scan interval.
This can be added to MemoryHogs.ini and changed there (i.e.
aProcessSeconds=12 would be 12 seconds before an alert). This is to
cut down on very brief Not Responding periods for processes which
caused a lot of flashing popup messages in the system tray area. This
number should be a multiple of 3 since the refresh cycle is 3 seconds
between redisplaying the processes.

v1.22 -
Added auto updater code

v1.21 -
Added Stealth Mode to hide the program completely but log all types
of activity. Previous Alert statuses are saved when going to and
from Stealth Mode. You can type @mhoff to turn off Stealth Mode.

v1.20 -

Added Hotstring commands to augment right-click menu for keyboarders.

 @mhs   - Show On/Off
 @mhh   - Hide (Show Off) or press ESCape
 @mhi   - Show Program Info
 @mhr   - Restart/Refresh
 @mhca  - CPU Alerts On/Off
 @mhda  - DISK Space Alerts On/Off
 @mhnra - NOT Responding Tray Tip Alerts On/Off
 @mhra  - Used RAM Alerts On/Off
 @mhpa  - PAGE File Alerts On/Off
 @mhvl  - View Logs
 @mhvs  - View Settings file
 @mhas  - AutoStart On/Off
 @mhex  - Exit/Quit Program
 @mhon  - Stealth On
 @mhoff - Stealth Off

v1.19 -
Use View Log Files to pull up each file into Notepad

v1.18 -
Added Log All Alerts option to the menu. If on, then CPU, Disk and
Not Responding Alerts are logged into three separate CSV files
under c:\temp. 

MHOG-CPU.csv, MHOG-Diskspace.csv and MHOG-NotResponding.csv

v1.17 -
Program always alerts on Memory Hog processes but now has a menu for
CPU, Disk and Not Responding Alerts that can be turned on and off.

v1.16 -
Program has an AutoStart menu option now.

v1.15 -
Some menu item name changes.

v1.14 - 
Optionally, if you set a PC name in the MemoryHogs.Ini file, the
program will track free disk space and alert when it is too low.
Set or add ShowDiskSpaceForPCsNamed to your computer name and you
will see the window displayed if your PC has less than the desired
diskspace.

v1.13 -
Process Status is now displayed. Background (window less) processes
are no longer shown. Active is good, Not Responding is bad if it
persists.

v1.12 - 
The program starts in Always Show mode to set your initial values.

v1.11 - 
An additional alert has been added for CPU. If the CPU is 90 percent
loaded then the window will be displayed and the CPU percent will 
flash. You can set the CPU Load as you like. Some text formatting
changes have also been made. CPU Load is shown when the mouse 
is over the program tray icon.

Still under development!
)
gui,2:new
gui,2:add,edit,w400 r40 ReadOnly vInfo,%Info%
gui,2:add,button,xm w400 center gDone,DONE
gui,2:show,AutoSize Center,Memory Hogs Info
send ^{Home}
return

Done:
gui,2:destroy
return

:*:@mhon::   ;Stealth On
GoStealth:
StealthMode:=true
LogAlertsStatus:=LogAlerts
LogAlerts:=true
CPUAlertStatus:=CPUAlert
CPUAlert:=true
DiskspaceAlertStatus:=DiskspaceAlert
DiskspaceAlert:=true
NotRespondingAlertStatus:=NotRespondingAlert
NotRespondingAlert:=true
AlwaysShowStatus:=AlwaysShow
AlwaysShow:=false
RAMAlertStatus:=RAMAlert
RAMAlert:=true
PAGEAlertStatus:=PAGEAlert
PAGEAlert:=true
Menu,Tray,NoIcon
return

:*:@mhoff::   ;Stealth Off
StealthMode:=false
LogAlerts:=LogAlertsStatus
CPUAlert:=CPUAlertStatus
DiskspaceAlert:=DiskspaceAlertStatus
NotRespondingAlert:=NotRespondingAlertStatus
AlwaysShow:=AlwaysShowStatus
RAMAlert:=RAMAlertsStatus
PAGEAlert:=PAGEAlertStatus
Menu,Tray,Icon
return

:*:@mhs::
AlwaysShow:
AlwaysShow:=Not(AlwaysShow)
Menu,Tray,ToggleCheck,Always Show / Set Thresholds
return

:*:@mhh::
GuiEscape:
AlwaysShow:=false
Menu,Tray,UnCheck,Always Show / Set Thresholds
return

:*:@mhl::
LogAlerts:
LogAlerts:=Not(LogAlerts)
Menu,Tray,ToggleCheck,Log All Alerts
if (LogAlerts)
    MsgBox,0,LOGGING,Logging ON,1
else
    MsgBox,0,LOGGING,Logging OFF,1
return

:*:@mhca::
CPUalerts:
CPUAlert:=Not(CPUAlert)
if (CPUAlert) {
    Menu,Alerts,Check,CPU Load
    MsgBox,0,LOGGING,CPU Alerts ON,1
}
else {
    Menu,Alerts,UnCheck,CPU Load
    MsgBox,0,LOGGING,CPU Alerts OFF,1
}
IniWrite,%CPUAlert%,MemoryHogs.ini,settings,CPUAlert
return

:*:@mhda::
DISKalerts:
DiskspaceAlert:=not(DiskspaceAlert)
if (DiskspaceAlert) {
    Menu,Alerts,Check,DISK Space
    MsgBox,0,LOGGING,DISK Alerts ON,1
}
else {
    Menu,Alerts,UnCheck,DISK Space
    MsgBox,0,LOGGING,DISK Alerts OFF,1
}
IniWrite,%DiskspaceAlert%,MemoryHogs.ini,settings,DiskspaceAlert
return

:*:@mhnra::
RESPONSEalerts:
NotRespondingAlert:=not(NotRespondingAlert)
if (NotRespondingAlert) {
    Menu,Alerts,Check,NOT Responding
    MsgBox,0,LOGGING,NOT Responding Alerts ON,1
}
else {
    Menu,Alerts,UnCheck,NOT Responding
    MsgBox,0,LOGGING,NOT Responding Alerts OFF,1
}
IniWrite,%NotRespondingAlert%,MemoryHogs.ini,settings,NotRespondingAlert
return

:*:@mhra::
RAMalerts:
RAMAlert:=not(RAMAlert)
if (RAMAlert) {
    Menu,Alerts,Check,RAM Usage
    MsgBox,0,LOGGING,RAM Alerts ON,1
}
else {
    Menu,Alerts,UnCheck,RAM Usage
    MsgBox,0,LOGGING,RAM Alerts OFF,1
}
IniWrite,%RAMAlert%,MemoryHogs.ini,settings,RAMAlert
return

:*:@mhpa::
PAGEalerts:
PAGEAlert:=not(PAGEAlert)
if (PAGEAlert) {
    Menu,Alerts,Check,PAGEFILE Usage
    MsgBox,0,LOGGING,PAGEFILE Alerts ON,1
}
else {
    Menu,Alerts,UnCheck,PAGEFILE Usage
    MsgBox,0,LOGGING,PAGEFILE Alerts OFF,1
}
IniWrite,%PAGEAlert%,MemoryHogs.ini,settings,PAGEAlert
return

:*:@mhvs::
ViewSettings:
run,notepad MemoryHogs.ini
return

:*:@mhvl::
ViewLogs:
IfExist,c:\temp\MHOG-NotResponding.csv
{
    run,notepad c:\temp\MHOG-NotResponding.csv
    WinWait,MHOG-NotResponding.csv
}
IfExist,c:\temp\MHOG-CPU.csv
{
    run,notepad c:\temp\MHOG-CPU.csv
    WinWait,MHOG-CPU.csv
    IfWinExist,MHOG-NotResponding.csv
    {
        WinGetPos,XX,YY,WW,HH,MHOG-NotResponding.csv
        WinMove,A,,% XX+30,% YY+30
    }
}
IfExist,c:\temp\MHOG-Diskspace.csv
{
    WinGetActiveTitle,activeTitle
    run,notepad c:\temp\MHOG-Diskspace.csv
    WinWait,MHOG-Diskspace.csv
    IfWinExist,%activeTitle%
    {
        WinGetPos,XX,YY,WW,HH,%activeTitle%
        WinMove,A,,% XX+30,% YY+30
    }
}
IfExist,c:\temp\MHOG-UsedRAM.csv
{
    WinGetActiveTitle,activeTitle
    run,notepad c:\temp\MHOG-UsedRAM.csv
    WinWait,MHOG-UsedRAM.csv
    IfWinExist,%activeTitle%
    {
        WinGetPos,XX,YY,WW,HH,%activeTitle%
        WinMove,A,,% XX+30,% YY+30
    }
}
IfExist,c:\temp\MHOG-UsedPAGE.csv
{
    WinGetActiveTitle,activeTitle
    run,notepad c:\temp\MHOG-UsedPAGE.csv
    WinWait,MHOG-UsedPAGE.csv
    IfWinExist,%activeTitle%
    {
        WinGetPos,XX,YY,WW,HH,%activeTitle%
        WinMove,A,,% XX+30,% YY+30
    }
}
return

Update:
Gui,Submit,NoHide
GuiControl,,NumProcesses,%NumProcUpDown%
return

Refresh:
TrayTip

gosub,UpdateMemory  ;update Used RAM and PageFile

FocusedRowNumber := LV_GetNext(0, "F")
If ImageListID
  IL_Destroy(ImageListID)

ImageListID := IL_Create(100)  ; Create an ImageList to hold 100 small icons.
LV_SetImageList(ImageListID,1)  ; Assign the above ImageList to the current ListView.
none:=IL_Add(ImageListID, "shell32.dll", 3)
;get all current processes
proc:=[]        ;define proc array
newBiggest:=0   ;used for determining biggest RAM user
newName=
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa394372(v=vs.85).aspx#properties
For objProcess in ComObjGet("winmgmts:\\.\root\cimv2").ExecQuery("Select * From Win32_Process")
{
	FullPath := objProcess.ExecutablePath
	Stringtrimright, ProcessPathShort, FullPath, StrLen(objProcess.Name)+1
	  icon:=IL_Add(ImageListID, objProcess.ExecutablePath, 1)
	  ,proc.Insert( {icon:icon?icon:none,name:objProcess.Name,WorkingSetSize:round(objProcess.WorkingSetSize/1048576,1)
					  ,PageFileUsage:round(objProcess.PageFileUsage/1024,1),processID:objProcess.processID
					  ,ModeTime:round((objProcess.KernelModeTime + objProcess.UserModeTime)/10000000,1)
					  ,Path:ProcessPathShort})
}

GuiControl, -Redraw, MyLV
Gui,-Enabled
LV_Delete()

for k,v in proc
{
    ;always save biggest process during this loop
	if (v.WorkingSetSize > newBiggest) {
		newBiggest := v.WorkingSetSize
		newName := v.Name
	}
    State := GetState(v.ProcessID)
    pName := v.Name
    StringTrimRight,pName,pName,4
    if (State <> "Background")  ;if not a windowless background process then add to the listview
        LV_Add("Icon" v.icon,v.Name,v.WorkingSetSize,v.Path,v.ProcessID,State)
    if (State = "Not Responding") and (State <> "Background") and (NotRespondingAlert=true) and (InStr(ExcludeProcesses,pName)=0) {
        if (StealthMode=false) {
            if (aProcess[pName] = "")   ;save process TickCount if no previous value exists
                aProcess[pName]:=A_TickCount
            else
            {
                if ((A_TickCount - aProcess[pName])/1000 >= aProcessSeconds) {
                    ;if more than aProcessSeconds seconds apart then resave process TickCount and display TrayTip
                    aProcess[pName]:=A_TickCount
                    TrayTip,%pName%,Not Responding...
                }
            }
        }
        if (LogAlerts)  ;log Not Responding every 3 seconds
            FileAppend,%A_Now%`,%pName%`r`n,c:\temp\MHOG-NotResponding.csv
    }
    else
    {
        ;clear process from Not Responding array if it went back to Active since the last Refresh 3 seconds ago
        if aProcess[pName] <> ""
            aProcess.delete(pName)
    }
}
;update Tray Tip
;Menu,Tray,Tip,MEMORY HOGS v%version%`nThresholds:`n[RAM %Threshold%MB -- CPU %ThresholdCPU%`%]`n`nCPU Load: %CPU%`%`nTop Hog: %newName% - %newBiggest%MB
Menu,Tray,Tip,MEMORY HOGS v%version%`nThresholds:`n[PRAM %Threshold%MB -- CPU %ThresholdCPU%`%]`n[URAM %UsedRAMThreshold%`% -- PAGE %UsedPageThreshold%`%]`n`nCPU: %CPU%`%`nHOG: %newName% - %newBiggest%MB

;keep only NumProcesses, delete the rest
LV_ModifyCol(2,"SortDesc Float")	;sort descending by WorkingSet memory used
Bottom := LV_GetCount()
Top := NumProcesses
while Bottom > Top
{
    LV_Delete(Bottom)
    Bottom--
}

;format columns
LV_ModifyCol()	;adjust column widths
loop,5
    LV_ModifyCol(A_Index,"AutoHdr")
LV_ModifyCol(3,10)	;hide Path Column

;use Checks for processes over RAM Threshold and Select for processes that are Excluded from Not Responding
Loop,% LV_GetCount()
{
    LV_GetText(RAMval,A_Index,2)
    if (RAMval > Threshold)
        LV_Modify(A_Index,"Check")
    LV_GetText(FileName,A_Index,1)
    StringTrimRight,FileName2,FileName,4
    if InStr(ExcludeProcesses,Filename2)
        LV_Modify(A_Index,"Select")
}
GuiControl, +Redraw, MyLV
Gui,+Enabled

;get disk free space
DriveSpaceFree,DiskSpace,c:\
DiskSpace := DiskSpace / 1024

;test CPU and DISK thresholds
LV_GetText(FileName,1,1)
LV_GetText(Biggest,1,2)
CPU:=CPULoad()

if (CPU > ThresholdCPU) and (CPUAlert) {
    if (CPU > 95)
        Gui,Font,cRed bold
    else
        Gui,Font,cBlue bold
    GuiControl,Font,CPULoad
    if (LogAlerts)
        FileAppend,%A_Now%`,%CPU%`r`n,c:\temp\MHOG-CPU.csv
    setTimer,FlashCPU,500
}
else {
    Gui,Font,cGreen bold
    GuiControl,Font,CPULoad
    setTimer,FlashCPU,off
    GuiControl,Show,CPULoad
}
;test disk only if matching PC name which defaults to names containing VDI
if InStr(A_ComputerName,ShowDiskSpaceForPCsNamed) and (DiskSpace < ThresholdDisk) and (DiskspaceAlert) {
    Gui,Font,cRed bold
    GuiControl,Font,DiskSpace
    if (LogAlerts)
        FileAppend,%A_Now%`,%DiskSpace%`r`n,c:\temp\MHOG-Diskspace.csv
    setTimer,FlashDisk,1000
}
else {
    Gui,Font,cGreen bold
    GuiControl,Font,DiskSpace
    setTimer,FlashDisk,off
    GuiControl,Show,DiskSpace
}

;used Physical RAM percentage
if (UsedRAM >= UsedRAMThreshold) and (RAMAlert) {
    Gui,Font,cRed bold
    GuiControl,Font,UsedRAMPercentage
    setTimer,FlashRAM,1000
    if (LogAlerts)
        FileAppend,%A_Now%`,%UsedRAM%`r`n,c:\temp\MHOG-UsedRAM.csv
}
else
{
    Gui,Font,cBlack bold
    GuiControl,Font,UsedRAMPercentage
    GuiControl,Show,UsedRAMPercentage
    setTimer,FlashRAM,off
}
;used Page File percentage
if (UsedPage >= UsedPageThreshold) and (PAGEAlert) {
    Gui,Font,cRed bold
    GuiControl,Font,UsedPageFilePercentage
    setTimer,FlashPageFile,1000
    if (LogAlerts)
        FileAppend,%A_Now%`,%UsedPage%`r`n,c:\temp\MHOG-UsedPAGE.csv
}
else
{
    Gui,Font,cBlack bold
    setTimer,FlashPageFile,off
    GuiControl,Font,UsedPageFilePercentage
    GuiControl,Show,UsedPageFilePercentage
}

;update upper window stats
GuiControl,,CPULoad,[CPU Load: %CPU%`%]
GuiControl,,DiskSpace,Available Disk Space: %DiskSpace% GB

If (AlwaysShow) {
    if (StealthMode=false)
        WinShow,Memory Hogs (ESC to Hide)
    GuiControl,,AlwaysShow,[Always Show ON]
}
else if (Biggest > Threshold) or ((CPU > ThresholdCPU) and CPUAlert) or ((DiskSpace < ThresholdDisk) and DiskAlert) or ((UsedPage >= UsedPageThreshold) and (PAGEAlert)) or ((UsedRAM >= UsedRAMThreshold) and (RAMAlert)) {
    if (StealthMode=false)
        WinShow,Memory Hogs (ESC to Hide)
    GuiControl,,AlwaysShow,[Always Show OFF]
}
else {
    GuiControl,,AlwaysShow,[Always Show OFF]
	WinHide,Memory Hogs (ESC to Hide)
}

if (freeze) {
    setTimer,Refresh,off
    setTimer,FlashGUI,1000
    MsgBox,0,FROZEN UP,Display is Frozen,2
}

Return

MyListView: ;process double clicks
if A_GuiEvent = DoubleClick
{
    setTimer,Refresh,off
	LV_GetText(FileName, A_EventInfo, 1)
    StringTrimRight,FileName2,FileName,4
    if (FileName2="Process ") {
        MsgBox,0,TRY AGAIN,Double Click not registered properly.,2
        gosub,Refresh
        setTimer,Refresh,3000
        return
    }
    LV_GetText(PID, A_EventInfo, 4)
	Gui, -AlwaysOnTop
	;MsgBox,68,KILL TASK,Stop the current Process - %FileName% (%PID%)?
    if (InStr(ExcludeProcesses,FileName2)=0)
        Pressed := CMsgBox("ACTION TO TAKE","Do you wish to STOP " . FileName2 . " or EXCLUDE it from Not Responding alerts?","STOP Task|EXCLUDE Task|Cancel",,1)
    else
        Pressed := CMsgBox("ACTION TO TAKE","Do you wish to STOP " . FileName2 . " or INCLUDE it in Not Responding alerts?","STOP Task|INCLUDE Task|Cancel",,1)
    Gui, +AlwaysOnTop
	If (Pressed = "Cancel")
    {
        gosub,Refresh
        setTimer,Refresh,3000
		return
    }
   	If (Pressed = "STOP Task")
    {
        setTimer,Refresh,3000    
        Process,Close,%PID%
        Process,WaitClose,%PID%,10
        if (ErrorLevel <> 0) 
        {
            MsgBox,48,ERROR,Process was not stopped. Now trying Task Kill.,2
            RunWait,%comspec% /c taskkill /PID %PID% /f /t,,hide
            if (ErrorLevel = 0)
                MsgBox,0,TASK STOPPED,Task (%PID%) was stopped.,2
            else
                MsgBox,48,TASK STILL RUNNING,Task (%PID%) was not stopped.
        }
        return
    }
    If (Pressed = "EXCLUDE Task")
    {
        if InStr(ExcludeProcesses,Filename2)=0 {
            ExcludeProcesses .= Filename2 . "|"
            IniWrite,%ExcludeProcesses%,MemoryHogs.ini,settings,ExcludeProcesses
        }
        gosub,Refresh
        setTimer,Refresh,3000 
        return
    }
    If (Pressed = "INCLUDE Task")
    {
        StringReplace,ExcludeProcesses,ExcludeProcesses,%Filename2%|,,All
        IniWrite,%ExcludeProcesses%,MemoryHogs.ini,settings,ExcludeProcesses
        gosub,Refresh
        setTimer,Refresh,3000 
        return
    }
}
if A_GuiEvent = R  ;Double Right click
{
	LV_GetText(FilePath, A_EventInfo, 3)
	LV_GetText(FileName, A_EventInfo, 1)
    DisplayMsg(18, "Please wait...","Locating the File", "BROWSING...")
	Run %COMSPEC% /c explorer.exe /select`, "%FilePath%\%FileName%",, Hide
	Progress, Off
}
return

:*:@mhex::
GuiClose:   ;close the window and the program
Gui,Submit
IniWrite,%NumProcesses%,MemoryHogs.ini,settings,ProcessesToShow
IniWrite,%Threshold%,MemoryHogs.ini,settings,RAM_Threshold
IniWrite,%ThresholdCPU%,MemoryHogs.ini,settings,CPU_Threshold
IniWrite,%UsedRAMThreshold%,MemoryHogs.ini,settings,UsedRAMThreshold
IniWrite,%UsedPageThreshold%,MemoryHogs.ini,settings,UsedPageThreshold
IniWrite,%NotRespondingAlert%,MemoryHogs.ini,settings,NotRespondingAlert
IniWrite,%DiskspaceAlert%,MemoryHogs.ini,settings,DiskspaceAlert
IniWrite,%CPUAlert%,MemoryHogs.ini,settings,CPUAlert
IniWrite,%LogAlerts%,MemoryHogs.ini,settings,LogAlerts
IniWrite,%StealthMode%,MemoryHogs.ini,settings,StealthMode
IniWrite,%PAGEAlert%,MemoryHogs.ini,settings,PAGEAlert
IniWrite,%RAMAlert%,MemoryHogs.ini,settings,RAMAlert
ExitApp

FlashCPU:   ;show/hide the CPU value if it is over the CPU Threshold
Show := !Show
GuiControl, Show%Show%, CPULoad
return

FlashDisk:   ;show/hide the CPU value if it is over the CPU Threshold
ShowD := !ShowD
GuiControl, Show%ShowD%, DiskSpace
return

FlashRAM:   ;show/hide the RAM value if it is over 95%
ShowR := !ShowR
GuiControl, Show%ShowR%, UsedRAMPercentage
return

FlashPageFile:   ;show/hide the Page File value if it is over 95%
ShowP := !ShowP
GuiControl, Show%ShowR%, UsedPageFilePercentage
return

;window positioning keys
#IfWinActive,Memory Hogs (ESC to Hide)
PGUP::
WinGetPos,X,Y,W,H,Memory Hogs (ESC to Hide)
SnapActiveWindow("top", "right", H, W)
return
PGDN::
WinGetPos,X,Y,W,H,Memory Hogs (ESC to Hide)
SnapActiveWindow("bottom", "right", H, W)
return
Home::
WinGetPos,X,Y,W,H,Memory Hogs (ESC to Hide)
SnapActiveWindow("top", "left", H, W)
return
End::
WinGetPos,X,Y,W,H,Memory Hogs (ESC to Hide)
SnapActiveWindow("bottom", "left", H, W)
return
#IfWinActive

:*:@mhas::
AutoStart:
If A_IsCompiled {
	IfNotExist, %A_Startup%\MemoryHogs.lnk
	{
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\MemoryHogs.lnk
		Menu,Tray,Check,AutoStart
        MsgBox,,,Added to Startup,1
		AutoStart := 1
		IniWrite,%AutoStart%,MemoryHogs.ini,Settings,AutoStart
	}
	else 
		gosub, RemoveFromStartup
}
return

;remove startup item
RemoveFromStartup:
If A_IsCompiled {
	IfExist, %A_Startup%\Exercises.lnk
	{
		FileDelete, %A_Startup%\MemoryHogs.lnk
		Menu,Tray,UnCheck,AutoStart
		MsgBox,,,Removed from Startup,1
		AutoStart := 0
		IniWrite,%AutoStart%,MemoryHogs.ini,Settings,AutoStart
	}
}
return

;===============================================================================
SnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight, winSizeWidth) {
	WinGetActiveTitle,T
	if (T <> "Memory Hogs (ESC to Hide)")
		return
    WinGet activeWin, ID, Memory Hogs (ESC to Hide)
    activeMon := GetMonitorIndexFromWindow(activeWin)
    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%
    if (winPlaceHorizontal == "left") 
        posX  := MonitorWorkAreaLeft
	if (winPlaceHorizontal == "right") 
        posX  := MonitorWorkAreaRight - winSizeWidth
    if (winPlaceVertical == "bottom") {
        posY := MonitorWorkAreaBottom - winSizeHeight
    } else if (winPlaceVertical == "middle") {
        posY := (MonitorWorkAreaBottom - MonitorWorkAreaTop - winSizeHeight) / 2
    } else {
        posY := MonitorWorkAreaTop
    }
    WinMove,Memory Hogs (ESC to Hide),,%posX%,%posY%,%winSizeWidth%,%winSizeHeight%
    IniWrite,%winPlaceVertical%,MemoryHogs.ini,settings,Vertical
    IniWrite,%winPlaceHorizontal%,MemoryHogs.ini,settings,Horizontal
    IniWrite,%NumProcesses%,MemoryHogs.ini,settings,ProcessesToShow
    IniWrite,%Threshold%,MemoryHogs.ini,settings,RAM_Threshold
    IniWrite,%ThresholdCPU%,MemoryHogs.ini,settings,CPU_Threshold
}

/**
 * GetMonitorIndexFromWindow retrieves the HWND (unique ID) of a given window.
 * @param {Uint} windowHandle
 * @author shinywong
 * @link http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/?p=440355
 */
GetMonitorIndexFromWindow(windowHandle) {
    ; Starts with 1.
    monitorIndex := 1
    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)
    if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2))
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) {
        monitorLeft   := NumGet(monitorInfo,  4, "Int")
        monitorTop    := NumGet(monitorInfo,  8, "Int")
        monitorRight  := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")
        workLeft      := NumGet(monitorInfo, 20, "Int")
        workTop       := NumGet(monitorInfo, 24, "Int")
        workRight     := NumGet(monitorInfo, 28, "Int")
        workBottom    := NumGet(monitorInfo, 32, "Int")
        isPrimary     := NumGet(monitorInfo, 36, "Int") & 1
        SysGet, monitorCount, MonitorCount
        Loop, %monitorCount% {
            SysGet, tempMon, Monitor, %A_Index%
            ; Compare location to determine the monitor index.
            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom)) {
                monitorIndex := A_Index
                break
            }
        }
    }
    return %monitorIndex%
}

CPULoad() { ; By SKAN, CD:22-Apr-2014 / MD:05-May-2014. Thanks to ejor, Codeproject: http://goo.gl/epYnkO
Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
} 

GetState(PID) {
;  * SendMessageTimeout values
; 
; #define SMTO_NORMAL         0x0000
; #define SMTO_BLOCK          0x0001
; #define SMTO_ABORTIFHUNG    0x0002
; #if(WINVER >= 0x0500)
; #define SMTO_NOTIMEOUTIFNOTHUNG 0x0008
; #endif /* WINVER >= 0x0500 */
; #endif /* !NONCMESSAGES */
; 
; SendMessageTimeout(
;     __in HWND hWnd,
;     __in UINT Msg,
;     __in WPARAM wParam,
;     __in LPARAM lParam,
;     __in UINT fuFlags,
;     __in UINT uTimeout,
;     __out_opt PDWORD_PTR lpdwResult);

NR_temp =0 ; init
TimeOut = 100 ; milliseconds to wait before deciding it is not responding - 100 ms seems reliable under 100% usage
; WM_NULL =0x0000
; SMTO_ABORTIFHUNG =0x0002
WinGet, wid, ID, ahk_pid %PID%
Responding := DllCall("SendMessageTimeout", "UInt", wid, "UInt", 0x0000, "Int", 0, "Int", 0, "UInt", 0x0002, "UInt", TimeOut, "UInt *", NR_temp)
If (wid="")
    return "Background"
If (Responding = 1) ; 1= responding, 0 = Not Responding
    return "Active"
If (Responding = 0)
    return "Not Responding"
}

ForceCheckForUpdate:
forceUpdate := 1
CheckForUpdate:
;check once for update once a day
IniRead,UpdateChecked,MemoryHogs.ini,settings,UpdateChecked,0000000
if SubStr(UpdateChecked,A_WDay,1) = 0 
{
	if (A_WDay = 1) 
		UpdateChecked = 1000000
	if (A_WDay = 2) 
		UpdateChecked = 0100000
	if (A_WDay = 3) 
		UpdateChecked = 0010000
	if (A_WDay = 4) 
		UpdateChecked = 0001000
	if (A_WDay = 5) 
		UpdateChecked = 0000100
	if (A_WDay = 6) 
		UpdateChecked = 0000010
	if (A_WDay = 7) 
		UpdateChecked = 0000001
	IniWrite,%UpdateChecked%,MemoryHogs.ini,settings,UpdateChecked
	goto,DoCheckUpdate
}
if forceUpdate
{
	goto,DoCheckUpdate
}
return

DoCheckUpdate:
SplashTextOn,300,30,UPDATE CHECKER,Checking for a software update.
if not(Check_Network_Alive("www.yahoo.com")) ;test for network connection
{
	SplashTextOff
	MsgBox,0,NO CONNECTION,There is currently no internet connection.,1
	return
}

URLDownloadToFile,http://s355751075.onlinehome.us/wp-content/uploads/HogVersion.txt,hogversion.txt
if (ErrorLevel <> 0)
    URLDownloadToFile,http://michaels-tech-notes.info/app/download/3930622/HogVersion.txt,hogversion.txt
SplashTextOff
FileReadLine,V,hogversion.txt,1
;if no connection or file not found then inform the user
If (ErrorLevel <> 0) or InStr(V,"html") {
    Progress,off
	MsgBox,0,CANNOT RETRIEVE VERSION INFO,Unable to download version information. Please try again later.,2
	return
}
if (V = version) {
    Progress,off
	MsgBox,0,NO PROGRAM UPDATE,You have the latest version.,1
}
else {
	URLDownloadToFile,http://s355751075.onlinehome.us/wp-content/uploads/hogchanges.txt,hogchanges.txt
    if (ErrorLevel <> 0)
        URLDownloadToFile,http://michaels-tech-notes.info/app/download/3930619/HogChanges.txt,hogchanges.txt
	FileRead,chg,hogchanges.txt
    Progress,off
    StringTrimRight,chg2,chg,% StrLen(chg)-InStr(chg,"***")+1
	if (V > version) {
		MsgBox,4,NEWER VERSION ONLINE,You are running version %version%.`n`nVersion %V% is available for download.`n`nClick Yes to update now or No to update later.`n`n%chg2%
		IfMsgBox,Yes
			gosub,DownloadMemoryHogs
	}
	if (V < version)
		MsgBox,0,OLDER VERSION ONLINE,You are running a newer version %version%.`n`nVersion %V% is available for download.`n`nYou will need to upload this version soon.,5
}
return

;call script to download then update the Memory Hogs app
DownloadMemoryHogs:
Run,UpdateMemoryHogs.exe
ExitApp
return

;use Windows Ping
Check_Network_Alive(_PingHost)
{
	RunWait, %comspec% /c ping -n 1 -w 1000 %_PingHost% | find "TTL=",,hide
	if ErrorLevel
		return 0
	else
		return 1
}

;==============================

;routine to check for mouse clicks on the Tray Icon
AHK_NOTIFYICON(wParam,lParam)
{  if lParam = 0x202            ; WM_LBUTTONUP
      gosub,AlwaysShow
   else if lParam = 0x203       ; WM_LBUTTONDBLCLK
      gosub,AlwaysShow
   else if lParam = 0x205       ; WM_RBUTTONUP
      Menu, Tray, Show          ; Show the tray menu
   Return true
}


;-------------------------------------------------------------------------------
; Custom Msgbox
; Filename: cmsgbox.ahk
; Author  : Danny Ben Shitrit (aka Icarus)
;-------------------------------------------------------------------------------
; Copy this script or include it in your script (without the tester on top).
;
; Usage:
;   Answer := CMsgBox( title, text, buttons, icon="", owner=0 )
;   Where:
;     title   = The title of the message box.
;     text    = The text to display.
;     buttons = Pipe-separated list of buttons. Putting an asterisk in front of 
;               a button will make it the default.
;     icon    = If blank, we will use an info icon.
;               If a number, we will take this icon from Shell32.dll
;               If a letter ("I", "E" or "Q") we will use some predefined icons
;               from Shell32.dll (Info, Error or Question).
;     owner   = If 0, this will be a standalone dialog. If you want this dialog
;               to be owned by another GUI, place its number here.
;
;-------------------------------------------------------------------------------
CMsgBox( title, text, buttons, icon="", owner=0 ) {
  Global _CMsg_Result
  GuiID := 9      ; If you change, also change the subroutines below
  StringSplit Button, buttons, |
  If( owner <> 0 ) {
    Gui %owner%:+Disabled
    Gui %GuiID%:+Owner%owner%
  }
  Gui %GuiID%:+Toolwindow +AlwaysOnTop
  MyIcon := ( icon = "I" ) or ( icon = "" ) ? 222 : icon = "Q" ? 24 : icon = "E" ? 110 : icon
  Gui %GuiID%:Add, Picture, Icon%MyIcon% , Shell32.dll
  Gui %GuiID%:Add, Text, x+12 yp w180 r8 section , %text%
  Loop %Button0% 
    Gui %GuiID%:Add, Button, % ( A_Index=1 ? "x+12 ys " : "xp y+3 " ) . ( InStr( Button%A_Index%, "*" ) ? "Default " : " " ) . "w100 gCMsgButton", % RegExReplace( Button%A_Index%, "\*" )
  Gui %GuiID%:Show,,%title%
  Loop 
    If( _CMsg_Result )
      Break
  If( owner <> 0 )
    Gui %owner%:-Disabled
  Gui %GuiID%:Destroy
  Result := _CMsg_Result
  _CMsg_Result := ""
  Return Result
}

9GuiEscape:
9GuiClose:
  _CMsg_Result := "Close"
Return

CMsgButton:
  StringReplace _CMsg_Result, A_GuiControl, &,, All
Return

;use to display messages with the Progress function 
DisplayMsg(size, body, heading, title) {
	Progress, zh0 fs%size%, %body%, %heading%, %title%
	sleep, 500
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Excerpt from htopmini v0.8.3
; by jNizM
; http://ahkscript.org/boards/viewtopic.php?f=6&t=254
; https://github.com/jNizM/htopmini/blob/master/src/htopmini.ahk
UpdateMemory:
GMSEx := GlobalMemoryStatusEx()
GMSExM01 := Round(GMSEx[2] / 1024**2, 1)            ; Total Physical Memory in MB
GMSExM02 := Round(GMSEx[3] / 1024**2, 1)            ; Available Physical Memory in MB
GMSExM03 := Round(GMSExM01 - GMSExM02, 1)           ; Used Physical Memory in MB
GMSExM04 := Round(GMSExM03 / GMSExM01 * 100, 1)     ; Used Physical Memory in %
GMSExS01 := Round(GMSEx[4] / 1024**2, 1)            ; Total PageFile in MB
GMSExS02 := Round(GMSEx[5] / 1024**2, 1)            ; Available PageFile in MB
GMSExS03 := Round(GMSExS01 - GMSExS02, 1)           ; Used PageFile in MB
GMSExS04 := Round(GMSExS03 / GMSExS01 * 100, 1)     ; Used PageFile in %
UsedRAM := GMSExM04                                 ; save used RAM
UsedPage := GMSExS04                                ; save used Page
GuiControl,,UsedRAMPercentage,[Used RAM: %GMSExM04%`%]
GuiControl,,UsedPageFilePercentage,[Used Page: %GMSExS04%`%]
return

GlobalMemoryStatusEx() {
    static MEMORYSTATUSEX, init := VarSetCapacity(MEMORYSTATUSEX, 64, 0) && NumPut(64, MEMORYSTATUSEX, "UInt")
    if (DllCall("Kernel32.dll\GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX))
    {
        return { 2 : NumGet(MEMORYSTATUSEX, 8, "UInt64")
        , 3 : NumGet(MEMORYSTATUSEX, 16, "UInt64")
        , 4 : NumGet(MEMORYSTATUSEX, 24, "UInt64")
        , 5 : NumGet(MEMORYSTATUSEX, 32, "UInt64") }
    }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
