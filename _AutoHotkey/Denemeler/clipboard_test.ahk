Gui, Add, Custom, ClassSysIPAddress32 r1 w150 hwndhIPControl gIPControlEvent
Gui, Add, Button, Default, OK
IPCtrlSetAddress(hIPControl, A_IPAddress1)
Gui, Show
return

GuiClose:
ExitApp

ButtonOK:
Gui, Hide
ToolTip
MsgBox % "You chose " IPCtrlGetAddress(hIPControl)
ExitApp

IPControlEvent:
if A_GuiEvent = Normal
{
    ; WM_COMMAND was received.

    if (A_EventInfo = 0x0300)  ; EN_CHANGE
        ToolTip Control changed!
}
else if A_GuiEvent = N
{
    ; WM_NOTIFY was received.

    ; Get the notification code. Normally this field is UInt but the IP address
    ; control uses negative codes, so for convenience we read it as a signed int.
    nmhdr_code := NumGet(A_EventInfo + 2*A_PtrSize, "int")
    if (nmhdr_code != -860)  ; IPN_FIELDCHANGED
        return

    ; Extract info from the NMIPADDRESS structure
    iField := NumGet(A_EventInfo + 2*A_PtrSize + 4, "int")
    iValue := NumGet(A_EventInfo + 2*A_PtrSize + 8, "int")
    if iValue >= 0
        ToolTip Field #%iField% modified: %iValue%
    else
        ToolTip Field #%iField% left empty
}
return

IPCtrlSetAddress(hControl, ipaddress)
{
    static WM_USER := 0x400
    static IPM_SETADDRESS := WM_USER + 101

    ; Pack the IP address into a 32-bit word for use with SendMessage.
    ipaddrword := 0
    Loop, Parse, ipaddress, .
        ipaddrword := (ipaddrword * 256) + A_LoopField
    SendMessage IPM_SETADDRESS, 0, ipaddrword,, ahk_id %hControl%
}

IPCtrlGetAddress(hControl)
{
    static WM_USER := 0x400
    static IPM_GETADDRESS := WM_USER + 102

    VarSetCapacity(addrword, 4)
    SendMessage IPM_GETADDRESS, 0, &addrword,, ahk_id %hControl%
    return NumGet(addrword, 3, "UChar") "." NumGet(addrword, 2, "UChar") "." NumGet(addrword, 1, "UChar") "." NumGet(addrword, 0, "UChar")
}