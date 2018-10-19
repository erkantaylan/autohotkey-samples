;Thanks to majkinetor - Common dialog for changing Gui & font colors from http://www.autohotkey.com/forum/viewtopic.php?t=17230
;Thanks to majkinetor, skan & polyethene - Validate Hex Color Code from http://www.autohotkey.com/community/viewtopic.php?f=1&t=13545&start=60 
;Thanks to derRaphael & JustMe for the Color Controls code from http://www.autohotkey.com/forum/topic33777.html and here http://www.autohotkey.com/board/topic/90401-control-colors-by-derraphael/
;All Hex color codes are in the blue-green-red (BGR) format.
#SingleInstance force 
ProgramName = Alex's Color Picker
Version = 2.2
OnMessage(0x0133, "Control_Colors") ;WM_CTLCOLOREDIT = 0x0133, WM_CTLCOLORLISTBOX = 0x0134, ;WM_CTLCOLORSTATIC = 0x0138
OnMessage(0x0138, "Control_Colors")
Gui 1: font, s10 , Verdana
Gui 1: default
Gui 1: Add, Text, x12 y12 w280 h50 , Select a preset color from the drop down list. The Hex-Code will appear in the Edit Box.
Gui 1: Add, DropDownList, x22 y82 w120 vdropdownlist gDropDownList hwndhcbx H400 Sort Choose13,Red|Yellow|Blue|Green|Orange|Black|Silver|Lime|Gray|Olive|White|Maroon|Navy|Purple|Teal|Fuchsia|  
Gui 1: Add, Text, x12 y132 w280 h50 , Press the button "Color Picker" to get the exact color you want. The Hex-Code will appear in the Edit Box.
Gui 1: Add, Button, x22 y202 w120 h30 , Color Picker
Gui 1: Add, Text, x12 y252 w280 h50  , Type a Hex-Code in the Edit Box, and click Apply Color to see that color. 
Gui 1: Add, Button, x22 y322 w120 h30 , Apply Color
Gui 1: Add, Text, x12 y372 w280 h50 , Real Time will put the Hex-Code of the color under your mouse cursor in the Edit Box.
Gui 1: Add, Button, x22 y432 w120 h30 , Real Time
Gui 1: Add, Button, x85 y+25 gCopyToClipboard ,Copy to Clipboard

Gui 1: font, s11 , Verdana
Gui 1: Add, Edit, x152 y82  w130 h30 center veditbox1, 008080
Gui 1: Add, Edit, x152 y202 w130 h30 center veditbox2, 
Gui 1: Add, Edit, x152 y322 w130 h30 center veditbox3 gHexEditBox,
Gui 1: Add, Edit, x152 y432 w130 h30 center veditbox4, 
loop 4
 Control_Colors("Editbox" a_index, "Set", "0xc0c0c0", "0x000000") 

Gui 1: Show, h530 w306, %ProgramName%
winset, AlwaysOnTop, on, %ProgramName%
WinGet,WinTitle2,ID,%ProgramName%
Gui 1: color, c0c0c0
PostMessage, 0x153, -1, 25,, ahk_id %hcbx%  ; Set height of selection field for dropdownlist.
PostMessage, 0x153,  0, 20,, ahk_id %hcbx%  ; Set height of list items for dropdownlist.
SetTimer,PreventFocusOnNoInputEditBoxes,50
Return
PreventFocusOnNoInputEditBoxes: ;prevents user input to editboxes. Disabling 3 out of 4 cause all 4 not to match
ControlGetFocus, OutputVar , ahk_id %WinTitle2%
if OutPutVar = Edit1
 ControlFocus, button4,ahk_id %WinTitle2%
if OutPutVar = Edit2
 ControlFocus, button4,ahk_id %WinTitle2% 
if OutPutVar = Edit4
 ControlFocus, button4,ahk_id %WinTitle2%
return
DropDownList: ;Editbox1
stopbreak = 1 ;just incase Real Time is still looping
Guicontrolget, dropdownlist
Gui 1: font, c000000 s10, Verdana
loop 4
 {
  GuiControl,font,static%A_Index%
  ControlSetText , Edit%a_index%, , %ProgramName% 
 }

if dropdownlist = Red
 ColorCode = ff0000
if dropdownlist = Yellow 
 ColorCode = FFFF00
if dropdownlist = Blue
 ColorCode = 0000FF
if dropdownlist = Green
 ColorCode = 008000
if dropdownlist = Purple
 ColorCode = 800080
if dropdownlist = Orange
 ColorCode = ff8000
if dropdownlist = Silver
 ColorCode = C0C0C0
if dropdownlist = Lime
 ColorCode = 00FF00
if dropdownlist = Gray
 ColorCode = 808080
if dropdownlist = Olive  
 ColorCode = 808000
if dropdownlist = Maroon 
 ColorCode = 800000
if dropdownlist = Purple
 ColorCode = 800080
if dropdownlist = Teal
 ColorCode = 008080   
if dropdownlist = Fuchsia
 ColorCode = FF00FF
if dropdownlist = White
 ColorCode = FFFFFF
if dropdownlist = Navy
 ColorCode = 000080
if dropdownlist = Black
 {
  ColorCode = 000000
  Gui 1: font, cFFFFFF , Verdana
  loop 4
    GuiControl,font,static%A_Index% 
 } 
 
Gui 1: color, %colorcode%,
ControlSetText , Edit1, %ColorCode%, %ProgramName%
StringSplit,Digit,ColorCode
ColorCode := ( Digit5 Digit6 Digit3 Digit4 Digit1 Digit2)
loop 4
 {
  Control_Colors("Editbox" a_index, "Set", "0x" ColorCode, "0x000000")
  WinSet,Redraw,,%ProgramName%
 }
return

ButtonColorPicker: ;Editbox2
stopbreak = 1 ;just incase Real Time is still looping
Gui 1: font, c000000 s10, Verdana
loop 4
 {
  GuiControl,font,static%A_Index%
  ControlSetText , Edit%a_index%, , %ProgramName% 
 }
CmnDlg_Color( color:=0000FF)
if color = 
 Return
Gui 1: Color, %Color%
StringTrimleft, color, color, 2
ControlSetText , Edit2, %color%, %ProgramName% 
StringSplit,Digit,Color
Color := ( Digit5 Digit6 Digit3 Digit4 Digit1 Digit2)
loop 4
 {
  Control_Colors("Editbox" a_index, "Set", "0x" Color, "0x000000")
  WinSet,Redraw,,%ProgramName%
 }
Return

ButtonApplyColor: ;Editbox3
stopbreak = 1 ;just incase Real Time is still looping
NotAValidColor1 = 0
NotAValidColor2 = 0
ControlGettext,Value,Edit3,%ProgramName%
gosub ValidateHexColorCode
  if ( NotAValidColor1 = 0 and NotAValidColor2 = 0 )
   {
    Gui 1: font, c000000 s10, Verdana
    StringSplit,Digit,Value
    Color := ( Digit5 Digit6 Digit3 Digit4 Digit1 Digit2)
    loop 4
     {
      GuiControl,font,static%A_Index%
      Control_Colors("Editbox" a_index, "Set", "0x" color, "0x000000")
      WinSet,Redraw,,%ProgramName%
      if A_index <> 3
       ControlSetText , Edit%a_index%, , %ProgramName% 
     }  
    Gui 1: Color, %Value%
   }
Return
HexEditBox: ;clears Edit1,2, and 4 if anything is typed in Editbox3
If RealTimeIsRunning = 1
 return
ControlSettext, Edit1,,%ProgramName% 
ControlSettext, Edit2,,%ProgramName%
ControlSettext, Edit4,,%ProgramName%
return

ButtonRealTime: ;Editbox 4
Control, disable, , ComboBox1, %ProgramName%
Control, disable, , Button1, %ProgramName%
Control, disable, , Button2, %ProgramName%
Control, disable, , Button3, %ProgramName%
Control, disable, , Button4, %ProgramName%
RealTimeIsRunning = 1 ;stop HexEditBox label glabel from running when ControlSetText is executed
stopbreak = 0

gui 1: font, c000000 s10 , Verdana
loop 4
 GuiControl,font,static%A_Index% 
ControlSetText , Edit1, , %ProgramName% 
ControlSetText , Edit2, , %ProgramName% 
ControlSetText , Edit3, , %ProgramName% 

ToolTip,Press Ctrl e to stop Real Time
Loop
 {
  MouseGetPos , xpos, ypos, WinTitle1, ControlID,
  PixelGetColor , color, %xpos%, %ypos%, rgb
  StringSplit,Digit,Color
  ControlColor := (Digit1 Digit2 Digit7 Digit8 Digit5 Digit6 Digit3 Digit4)
  if ( Color1 <> Color and WinTitle1 <> WinTitle2 )
   {
    StringTrimLeft,Color,Color,2
    controlsettext, edit4, %Color%, %ProgramName%
    Gui 1: Color, %Color%
    loop 4
     Control_Colors("Editbox" a_index, "Set", ControlColor, "0x000000")
    Color1 = %Color%
   }
  if stopbreak = 1
   {
    RealTimeIsRunning = 0
    Control, enable, , ComboBox1, %ProgramName%
    Control, enable, , Button1, %ProgramName%
    Control, enable, , Button2, %ProgramName%
    Control, enable, , Button3, %ProgramName%
    Control, enable, , Button4, %ProgramName%
    ToolTip
    break
   }
 }
stopbreak = 0
Return

CopyToClipboard:
NotAValidColor1 = 0
NotAValidColor2 = 0
FoundEditBox3Value = 0
Loop 4
 {
  ControlGettext,Value,Edit%a_index%,%ProgramName%
  FoundEditBoxValue = %a_index% ;need to know if EditBox3 is the one with contents so it can be checked with gosub ValidateHexColorCode below
  if Value <>
   break
 }
 
 if FoundEditBoxValue = 3
  gosub ValidateHexColorCode ;sets NotAValidColor1 and/or NotAValidColor2 to 1 if EditBox3 color hex code is not a valid color code
 
 If ( NotAValidColor1 = 0 and NotAValidColor2 = 0 )
  Clipboard = %Value%
 return 

ValidateHexColorCode:
if Value <>
 {
  Value2 = %Value%
  StringLen,Len,Value 
  if (Len > 6)
   {                                                                                                         
    TempCount := ( Len - 2 )
    StringTrimRight,1st2CharsOnLeft,Value2, %TempCount%
    if ( 1st2CharsOnLeft <> "0x" )
     NotAValidColor1 = 1
    else
     StringTrimLeft,Value,Value,2
   }
  var := RegExMatch(Value, "i)^[0-9a-fA-F]+$") ;thanks to majkinetor, skan and polyethene, code found here ;http://www.autohotkey.com/community/viewtopic.php?f=1&t=13545&start=60 
  if ( Var = 0 or NotAValidColor1 = 1 or NotAValidColor2 = 1 or ( Len <> 6 and Len <> 8) or Len > 8 )
   {
    Gui 1: +Disabled 
    Gui 2: -MinimizeBox
    Gui 2: font, s12, Verdana
    Gui 2: add, text,, "%Value2%" is not a valid color code
    Gui 2: show,autosize, Invalid Entry
    Gui 2: color, DAC69F
    winset, AlwaysOnTop, On, Invalid Entry
    WinWaitClose,Invalid Entry
    NotAValidColor2 = 1
   }
 }
else
 NotAValidColor1 = 1
return

^e::
stopbreak=1 
return

GuiClose:
ExitApp

2GuiClose:
Gui 1: -Disabled
Gui 2: destroy
return

 ;color function returns user choise in var color
;usage   CmnDlg_Color( color:=0000FF)
CmnDlg_Color(ByRef pColor, hGui=0){ 
  ;covert from rgb
    clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF) 

    VarSetCapacity(sCHOOSECOLOR, 0x24, 0) 
    VarSetCapacity(aChooseColor, 64, 0) 

    NumPut(0x24,		 sCHOOSECOLOR, 0)      ; DWORD lStructSize 
    NumPut(hGui,		 sCHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
    NumPut(clr,			 sCHOOSECOLOR, 12)     ; clr.rgbResult 
    NumPut(&aChooseColor,sCHOOSECOLOR, 16)     ; COLORREF *lpCustColors 
    NumPut(0x00000103,	 sCHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 

    nRC := DllCall("comdlg32\ChooseColorA", str, sCHOOSECOLOR)  ; Display the dialog. 
    if (errorlevel <> 0) || (nRC = 0) 
       return  false 

  
    clr := NumGet(sCHOOSECOLOR, 12) 
    
    oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

 ;convert to rgb 
    pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
    StringTrimLeft, pColor, pColor, 2 
    loop, % 6-strlen(pColor) 
		pColor=0%pColor% 
    pColor=0x%pColor% 
    SetFormat, integer, %oldFormat% 

	return true
}
;Control_Colors--------------------------------------------------------
Control_Colors(wParam, lParam, Msg, Hwnd) {
    Static Controls := {}
   If (lParam = "Set") {
      If !(CtlHwnd := wParam + 0)
         GuiControlGet, CtlHwnd, Hwnd, %wParam%
      If !(CtlHwnd + 0)
         Return False
      Controls[CtlHwnd, "CBG"] := Msg + 0
      Controls[CtlHwnd, "CTX"] := Hwnd + 0
      Return True
   }
   ; Critical
   If (Msg = 0x0133 Or Msg = 0x0134 Or Msg = 0x0138) {
      If Controls.HasKey(lParam) {
         If (Controls[lParam].CTX >= 0)
            DllCall("Gdi32.dll\SetTextColor", "Ptr", wParam, "UInt", Controls[lParam].CTX)
         DllCall("Gdi32.dll\SetBkColor", "Ptr", wParam, "UInt", Controls[lParam].CBG)
         Return DllCall("Gdi32.dll\CreateSolidBrush", "UInt", Controls[lParam].CBG)
      }
   }
 }
;----------------------------------------------------------------------
