;-------------------------------------------------------------------------------
; No Mouse Today! 0.20
; A Numpad Mouse Replacement (for days without a mouse...)
;-------------------------------------------------------------------------------
;
;   • Disable Numlock to Activate
;   +------------+------------+------------+------------+
;   | Numlock    | / (Toggle) | *          | -          |
;   | Off        | Drag       |            | Center Win |
;   +------------+------------+------------+------------+
;   | 7          | 8          | 9          | +          |
;   | Wheel Up   | Up         | Navgat Fwd | Right Clik |
;   +------------+------------+------------+            |
;   | 4          | 5          | 6          |            |
;   | Left       | Click      | Right      |            |
;   +------------+------------+------------+------------+
;   | 1          | 2          | 3          | Enter      |
;   | Wheel Down | Down       | Navgat Bck | Dbl Click  |
;   +------------+------------+------------+            |
;   | 0 (Hold)                | .          |            |
;   | Constant Move Speed     | Clockwise  |            |
;   +-------------------------+------------+------------+
;   • Hold down Shift while moving for one pixel movement 
;   • Hold down Alt for 2468 to act like mouse wheel scroll (4 directions)
;   • Pressing two movement keys together will move diagonally
;   • Pressing Ctrl, Alt or Shift while clicking or mousewheeling works the same 
;     as with a normal mouse
;   • Pressing NumpadDot will move the mouse through the four quarters of the
;     screen (clockwise)   
;   
;-------------------------------------------------------------------------------
#SingleInstance Force
#HotkeyInterval 1000
#MaxHotkeysPerInterval 1000
CoordMode Mouse, Screen
SendMode InputThenPlay			; If not working, try: SendMode Input

; --- GENERAL CONFIGURATION ----------------------------------------------------
ConstantSpeed := 2      ; Pixels to move when Numpad0 is held down
MinSpeed      := 1      ; Pixels to move at the beginning of the movement
MaxSpeed      := 4      ; Pixels to move at the fastest inertia
Inertia       := 0.00001    ; How fast should we increase speed (higher=faster, 0=none)
InertiaDelay  := 0      ; Number of movements to wait before starting inertia
WheelSleep    := 80     ; MSeconds to sleep between wheel sends

; --- KEYBOARD CONFIGURATION ---------------------------------------------------
RightKey      := "NumpadRight"
DownKey       := "NumpadDown"
UpKey         := "NumpadUp"
LeftKey       := "NumpadLeft"

ClickKey      := "NumpadClear"	; Clear is 5 in the numpad
DoubleClickKey:= "NumpadEnter"	; Double click cn also be done by double tapping the click key
RightClickKey := "NumpadAdd"
ForwardKey    := "NumpadPgUp"	
BackKey       := "NumpadPgDn"

WheelUpKey    := "NumpadHome"
WheelDownKey  := "NumpadEnd"

CornerKey     := "NumpadDel"		; Moves the mouse between the 4 quarters of the screen
CenterKey     := "NumpadSub"		; Centers the mouse on the screen
DragKey       := "NumpadDiv"		; Toggle to start/stop dragging  
ConstantKey   := "NumpadIns"		; Hold while moving to ignore inertia

; --- END OF CONFIGURATION -----------------------------------------------------

Menu Tray, NoStandard
Menu Tray, Add, Exit No Mouse Today!, Exit

SysGet ScreenW, 78
SysGet ScreenH, 79

; • Mouse Moves •
Hotkey *%RightKey%, MouseRight
Hotkey *%DownKey%, MouseDown
Hotkey *%UpKey%, MouseUp
Hotkey *%LeftKey%, MouseLeft
Hotkey %ConstantKey%, MouseConstant

; • Mouse Clicks •
Hotkey *%ClickKey%, MouseClickHandler
Hotkey *%ForwardKey%, MouseForward
Hotkey *%BackKey%, MouseBack
Hotkey $*%DoubleClickKey%, MouseDoubleClick
Hotkey $*%RightClickKey%, MouseRightClick

; • Special Functions •
Hotkey $*%DragKey%, MouseDrag
Hotkey $%CenterKey%, CenterMouse
Hotkey $%CornerKey%, CornerMouse

; • Mouse Wheel •
Hotkey *%WheelUpKey%, MouseWheelUp
Hotkey *%WheelDownKey%, MouseWheelDown

Return

;
; This routine handles the 2468 keys: Mouse moves, or mouse wheel emulation
;
MouseMoveHandler:
ControlGetFocus, fcontrol, A

Counter := 0
Loop {
	If( GetKeyState( "Alt", "P" ) ) {    ; Wheel Emulation through Ctrl+2468

		WX := ( GetKeyState( RightKey, "P" ) ? 1 : GetKeyState( LeftKey, "P" ) ? 0 : -1 )
		WY := ( GetKeyState( DownKey , "P" ) ? "WheelDown" : GetKeyState( UpKey, "P" )  ? "WheelUp" : -1 )

		If( WX<>-1 )
		SendMessage, 0x114, %WX%, 0, %fcontrol%, A  ; 0x114 is WM_HSCROLL and the 0 after it is SB_LINERIGHT.

		If( WY<>-1 )
		SendInput {%WY%}

		Sleep %WheelSleep%
	}
	Else {    ; Mouse moves
		InsPressed := GetKeyState( ConstantKey, "P" )
		Speed := InsPressed ? ConstantSpeed : Counter>InertiaDelay ? MinSpeed+(Counter-InertiaDelay)*Inertia : MinSpeed
		Speed := Speed > MaxSpeed ? MaxSpeed : Speed
		Counter := InsPressed ? 0 : Counter+1		; Reset Inertia 

		X := Speed * ( GetKeyState( RightKey, "P" ) ? 1 : GetKeyState( LeftKey, "P" ) ? -1 : 0 )
		Y := Speed * ( GetKeyState( DownKey , "P" ) ? 1 : GetKeyState( UpKey, "P" )   ? -1 : 0 )

		If( X or Y ) {
			MouseMove %X%,%Y%,,R
			If( GetKeyState( "Shift" , "P" ) )
			Break
		}
		Else 
		Break
	}
}
Return

;
; This routine handles the 17 keys: mouse wheel
;
MouseWheelHandler:
Loop {
	WUp  := GetKeyState( WheelUpKey, "P" ) 
	WDn  := GetKeyState( WheelDownKey, "P" )  

	If( WUp ) or ( WDn ) {
		SendEvent % GetModifier() . ( WUp ? "{WheelUp}" : "{WheelDown}" )
		Sleep %WheelSleep%
	}   
	Else
	Break
}
Return

;
; Hotkeys
; These functions are called when the hotkeys are pressed.
; For each one, if the numlock is off, we will emulate mouse functions, 
; otherwise, we will echo the pressed key back to the OS.
;
MouseLeft:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseMoveHandler
Else
SendInput % GetModifier() . "{" . LeftKey . "}"
Return

MouseRight:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseMoveHandler
Else
SendInput % GetModifier() . "{" . RightKey . "}"
Return

MouseUp:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseMoveHandler
Else
SendInput % GetModifier() . "{" . UpKey . "}"
Return

MouseDown:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseMoveHandler
Else
SendInput % GetModifier() . "{" . DownKey . "}"
Return

MouseConstant:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseMoveHandler
Else
SendInput % GetModifier() . "{" . ConstantKey . "}"
Return

MouseWheelDown:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseWheelHandler
Else
SendInput % GetModifier() . "{" . WheelDownKey . "}"
Return

MouseWheelUp:
If( Not GetKeyState( "Numlock", "T" ) ) 
Gosub MouseWheelHandler
Else
SendInput % GetModifier() . "{" . WheelUpKey . "}"
Return




MouseClickHandler:
If( Not GetKeyState( "Numlock", "T" ) ) 
SendInput % GetModifier() . "{Click}"
Else
SendInput % GetModifier() . "{" . ClickKey . "}"
Return

MouseForward:
If( Not GetKeyState( "Numlock", "T" ) ) 
SendEvent {XButton2}
Else
SendInput % GetModifier() . "{" . ForwardKey . "}"
Return

MouseBack:
If( Not GetKeyState( "Numlock", "T" ) ) 
SendEvent {XButton1}
Else
SendInput % GetModifier() . "{" . BackKey . "}"
Return

MouseDoubleClick:
If( Not GetKeyState( "Numlock", "T" ) )
Click 2
Else
SendInput % GetModifier() . "{" . DoubleClickKey . "}"
Return

MouseRightClick:
If( Not GetKeyState( "Numlock", "T" ) )
SendInput % GetModifier() . "{RButton}"
Else
SendInput % GetModifier() . "{" . RightClickKey . "}"
Return

MouseDrag:
If( Not GetKeyState( "Numlock", "T" ) ) {
	SendInput % "{LButton " . ( _Drag ? "Up}" : "Down}" )
	_Drag := Not _Drag
}     
Else
SendInput % GetModifier() . "{" . DragKey . "}"
Return

CenterMouse:
If( Not GetKeyState( "Numlock", "T" ) ) {
	WinGetPos X,Y,W,H,A
	MouseMove % X+W/2, % Y+H/2
}
Else
SendInput % GetModifier() . "{" . CenterKey . "}"
Return

CornerMouse:
If( Not GetKeyState( "Numlock", "T" ) ) {
	MouseGetPos MX, MY
	NewX := ( MY < ScreenH/2 ) ? ScreenW/4*3 : ScreenW/4 
	NewY := ( MX > ScreenW/2 ) ? ScreenH/4*3 : ScreenH/4 
	MouseMove %NewX%, %NewY%
}
Else
SendInput % GetModifier() . "{" . CornerKey . "}"
Return


GetModifier() {
	Return GetKeyState( "Ctrl", "P" ) ? "^" : GetKeyState( "Alt", "P" ) ? "!" : GetKeyState( "Shift", "P" ) ? "+" : ""
}

Exit:
ExitApp
Return

^ESC::ExitApp