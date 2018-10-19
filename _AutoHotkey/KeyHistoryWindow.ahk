; https://autohotkey.com/boards/viewtopic.php?f=6&t=26059

; GUI Legend:
; VK  SC_  _a!u  Elapsed  Key name_________  Extra_info

#NoEnv
#Persistent
#InstallKeybdHook
hHookKeybd := DllCall("SetWindowsHookEx", "int", 13 ; WH_KEYBOARD_LL = 13
    , "ptr", RegisterCallback("Keyboard")
    ; hMod is not required on Win 7, but seems to be required on XP even
    ; though this type of hook is never injected into other processes:
    , "ptr", DllCall("GetModuleHandle", "ptr", 0, "ptr")
    , "uint", 0, "ptr") ; dwThreadId
#KeyHistory(10)

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x100, "WM_KEYDOWN")

Gui, +LastFound -DPIScale
WinSet, Transparent, 200
Gui, +ToolWindow +AlwaysOnTop
Gui, Margin, 10, 10
Gui, Font,, Lucida Console
Gui, Add, Text, vKH, 00  000  ____  1000.00  Browser_Favorites 0xFFFFFFFF
GuiControlGet, KH, Pos
GuiControl,, KH  ; clear dummy sizing text
gosub Resize
return

#MaxThreadsBuffer, On
!WheelUp::
!WheelDown::
#MaxThreadsBuffer, Off
    history_size := #KeyHistory() + ((A_ThisHotkey="!WheelUp") ? +1 : -1)
    #KeyHistory(history_size>0 ? history_size : 1)
    ; Delay resize to improve hotkey responsiveness.
    SetTimer, Resize, -10
return

Resize:
    ; Resize label to fit key history.
    gui_h := KHH*(#KeyHistory())
    GuiControl, Move, KH, h%gui_h%
    gui_h += 20

    Gui, +LastFound
    ; Determine visibility.
    WinGet, style, Style
    gui_visible := style & 0x10000000

    ;Gui, Show, % "AutoSize NA " (gui_visible ? "" : "Hide")
    ;** Not used because we need to know the previous height,
    ;   and its simpler to resize manually.
    
    ; Determine current position and height.
    WinGetPos, gui_x, gui_y, , gui_h_old
    ; Use old height to determine if we should reposition, *only when shrinking*.
    ; This way we can move the GUI somewhere else, and the script won't reposition it.
    ;if (gui_h_old < gui_h)
    ;    gui_h_old := gui_h
    ; Determine working area (primary screen size minus taskbar.)
    SysGet, wa_, MonitorWorkArea

    SysGet, twc_h, 51 ; SM_CYSMCAPTION
    SysGet, bdr_h, 8  ; SM_CYFIXEDFRAME
    if (!gui_visible)
    {
        gui_x = 72 ; Initially on the left side.
        gui_y := wa_bottom-(gui_h+twc_h+bdr_h*2+10)
    }
    else
    {   ; Move relative to bottom edge when closer to the bottom.
        if (gui_y+gui_h//2 > (wa_bottom-wa_top)//2)
            gui_y += gui_h_old-(gui_h+twc_h+bdr_h*2)
    }
    Gui, Show, x%gui_x% y%gui_y% h%gui_h% NA, Key History
return


Keyboard(nCode, wParam, lParam) {
    global KeyBuffer
    
    Critical
    
    if KeyHistory(1, vk, sc, flags)
        && NumGet(lParam+0, "uint") = vk
        && NumGet(lParam+4, "uint") = sc
        && NumGet(lParam+8, "uint") = flags
        buf_max := 0 ; Don't show key-repeat.
    else
        buf_max := #KeyHistory()

    if (buf_max > 0)
    {
        ; Push older key events to the back.
        if (buf_max > 1)
            DllCall("RtlMoveMemory", "ptr", &KeyBuffer+16+A_PtrSize, "ptr", &KeyBuffer, "ptr", buf_max*16+A_PtrSize)
        ; Copy current key event to the buffer.
        DllCall("RtlMoveMemory", "ptr", &KeyBuffer, "ptr", lParam, "ptr", 16+A_PtrSize)

        ; "gosub Show" slows down the keyboard hook and causes problems, so use a timer.        
        SetTimer, Show, -10
    }
    
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam, "ptr")
}

KeyHistory(N, ByRef vk, ByRef sc, ByRef flags:=0, ByRef time:=0, ByRef elapsed:=0, ByRef info:=0)
{
    global KeyBuffer
    if N is not integer
        return false
    buf_max := #KeyHistory()
    if (N < 0)
        N += buf_max + 1
    if (N < 1 or N > buf_max)
        return false
    static sz := 16+A_PtrSize
    vk    := NumGet(KeyBuffer, (N-1)*sz, "uint")
    sc    := NumGet(KeyBuffer, (N-1)*sz+4, "uint")
    flags := NumGet(KeyBuffer, (N-1)*sz+8, "uint")
    time  := NumGet(KeyBuffer, (N-1)*sz+12, "uint")
    info  := NumGet(KeyBuffer, (N-1)*sz+16)
    elapsed := time - ((time2 := NumGet(KeyBuffer, N*sz+12, "uint")) ? time2 : time)
    return (vk or sc)
}

#KeyHistory(NewSize="")
{
    global KeyBuffer
    static sz := 16+A_PtrSize
    ; Get current history length.
    if (NewSize="")
        return (cap:=VarSetCapacity(KeyBuffer)//sz)>0 ? cap-1 : 0
    if (NewSize)
    {
        new_cap := (NewSize+1)*sz
        cap := VarSetCapacity(KeyBuffer)
        if (cap > new_cap)
            cap := new_cap
        VarSetCapacity(old_buffer, cap)
        ; Back up previous history.
        DllCall("RtlMoveMemory", "ptr", &old_buffer, "ptr", &KeyBuffer, "ptr", cap)
        
        ; Set new history length.
        VarSetCapacity(KeyBuffer, 0) ; FORCE SHRINK
        VarSetCapacity(KeyBuffer, new_cap, 0)
        
        ; Restore previous history.
        DllCall("RtlMoveMemory", "ptr", &KeyBuffer, "ptr", &old_buffer, "ptr", cap)
        
        ; (Remember N+1 key events to simplify calculation of the Nth key event's elapsed time.)
        ; Put tick count so the initial key event has a meaningful value for "elapsed".
        NumPut(A_TickCount, KeyBuffer, 12, "uint")
    }
    else
    {   ; Clear history entirely.
        VarSetCapacity(KeyBuffer, 0)
    }
}

GetKeyFlagText(flags)
{
    return ((flags & 0x1) ? "e" : " ") ; LLKHF_EXTENDED
        . ((flags & 0x10) ? "a" : " ") ; LLKHF_INJECTED (artificial)
        . ((flags & 0x20) ? "!" : " ") ; LLKHF_ALTDOWN
        . ((flags & 0x80) ? "u" : " ") ; LLKHF_UP (key up)
}

; Gets readable key name, usually identical to the name in KeyHistory.
GetKeyNameText(vkCode, scanCode, isExtendedKey)
{
    return GetKeyName(format("vk{1:02x}sc{3}{2:02x}", vkCode, scanCode, isExtendedKey))
    /* ; For older versions of AutoHotkey:
    ; My Right Shift key shows as vk161 sc54 isExtendedKey=true.  For some
    ; reason GetKeyNameText only returns a name for it if isExtendedKey=false.
    if vkCode = 161
        return "Right Shift"

    VarSetCapacity(buffer, 32, 0)
    DllCall("GetKeyNameText"
        , "UInt", (scanCode & 0xFF) << 16 | (isExtendedKey ? 1<<24 : 0) ;| 1<<25
        , "Str", buffer
        , "Int", 32)

    return buffer
    */
}

Show:
    SetFormat, FloatFast, .2
    SetFormat, IntegerFast, H
    text =
    buf_size := #KeyHistory()
    Loop, % buf_size
    {
        if (KeyHistory(buf_size-A_Index, vk, sc, flags, time, elapsed, info))
        {
            keytext := GetKeyNameText(vk, sc, flags & 0x1)
            
            if (elapsed < 0)
                elapsed := "#err#"
            else
                dt := elapsed/1000.0
            
            ; AHK-style SC
            sc_a := sc
            if (flags & 1)
                sc_a |= 0x100, flags &= ~1
            sc_a := SubStr("000" SubStr(sc_a, 3), -2)
            vk_a := SubStr(vk+0, 3)
            if (StrLen(vk_a)<2)
                vk_a = 0%vk_a%
            StringUpper, vk_a, vk_a
            StringUpper, sc_a, sc_a
            
            flags := GetKeyFlagText(flags & ~0x1)
            
            text .= vk_a "  " sc_a "  " flags "  " SubStr("      " dt, -6) "  "
                . SubStr(keytext "                ", 1, 17) " " info "`n"
        }
    }
    GuiControl,, KH, % text
Return

GuiClose:
ExitApp

WM_KEYDOWN()
{
    if A_Gui
        return true
}

WM_LBUTTONDOWN(wParam, lParam)
{
    global text
    StringReplace, Clipboard, text, `n, `r`n, All
}
