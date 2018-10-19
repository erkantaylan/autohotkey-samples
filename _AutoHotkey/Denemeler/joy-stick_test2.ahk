/*Loop
{
	Input, OutputVar, L1 C V M
	MsgBox, %OutputVar%
}



*/

; July 6, 2005: Added auto-detection of joystick number.
; May 8, 2005 : Fixed: JoyAxes is no longer queried as a means of
; detecting whether the joystick is connected.  Some joysticks are
; gamepads and don't have even a single axis.

; If you want to unconditionally use a specific joystick number, change
; the following value from 0 to the number of the joystick (1-16).
; A value of 0 causes the joystick number to be auto-detected:
JoystickNumber = 0

; END OF CONFIG SECTION. Do not make changes below this point unless
; you wish to alter the basic functionality of the script.

; Auto-detect the joystick number if called for:
if JoystickNumber <= 0
{
    Loop 16  ; Query each joystick number to find out which ones exist.
    {
        GetKeyState, JoyName, %A_Index%JoyName
        if JoyName <>
        {
            JoystickNumber = %A_Index%
            break
        }
    }
    if JoystickNumber <= 0
    {
        MsgBox The system does not appear to have any joysticks.
        ExitApp
    }
}


#SingleInstance
SetFormat, float, 03  ; Omit decimal point from axis position percentages.
GetKeyState, joy_buttons, %JoystickNumber%JoyButtons
GetKeyState, joy_name, %JoystickNumber%JoyName
GetKeyState, joy_info, %JoystickNumber%JoyInfo
Loop
{
    buttons_down =
    Loop, %joy_buttons%
    {
        GetKeyState, joy%a_index%, %JoystickNumber%joy%a_index%
        if joy%a_index% = D
            buttons_down = %buttons_down%%a_space%%a_index%
    }
    
    GetKeyState, joyx, %JoystickNumber%JoyX
    axis_info = X%joyx%
    GetKeyState, joyy, %JoystickNumber%JoyY
    axis_info = %axis_info%%a_space%%a_space%Y%joyy%
    IfInString, joy_info, Z
    {
        GetKeyState, joyz, %JoystickNumber%JoyZ
        axis_info = %axis_info%%a_space%%a_space%Z%joyz%
    }
    IfInString, joy_info, R
    {
        GetKeyState, joyr, %JoystickNumber%JoyR
        axis_info = %axis_info%%a_space%%a_space%R%joyr%
    }
    IfInString, joy_info, U
    {
        GetKeyState, joyu, %JoystickNumber%JoyU
        axis_info = %axis_info%%a_space%%a_space%U%joyu%
    }
    IfInString, joy_info, V
    {
        GetKeyState, joyv, %JoystickNumber%JoyV
        axis_info = %axis_info%%a_space%%a_space%V%joyv%
    }
    IfInString, joy_info, P
    {
        GetKeyState, joyp, %JoystickNumber%JoyPOV
        axis_info = %axis_info%%a_space%%a_space%POV%joyp%
    }
;;;;;;;;;;;;;;;;;
	;MsgBox, %joy_info%
	array_info := StrSplit(axis_info," ")
	;MsgBox,%array_info0%
	IfEqual, array_info0, X000
	{
		;sola
		; Move the mouse slowly (speed 50 vs. 2) by 20 pixels to the right and 30 pixels down
		; from its current location:
		MouseMove, -50, 0, 50, R
		MsgBox, test
	}
	IfEqual, array_info0, X100
	{
		;saga
		MouseMove, 50, 0, 50, R
	}
	IfEqual, array_info1, Y000
	{
		;yukari
		MouseMove, 0, -50, 50, R
	}
	IfEqual, array_info1, Y100
	{
		;asagi
		MouseMove, 0, 50, 50, R
	}
	sonuc := SubStr(axis_info,1,4)
	Send, %sonuc%`n
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ToolTip, %joy_name% (#%JoystickNumber%):`n%axis_info%`nButtons Down: %buttons_down%`n`n(right-click the tray icon to exit)
    Sleep, 100
}
return
