pressed = 0


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
    ;if pressed <> %buttons_down%
    ;{
    pressed = %buttons_down%
    Send, %buttons_down%
    Sleep, 100
    ;}
}

