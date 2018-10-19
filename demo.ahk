F7::
MsgBox, F8:Yurtiçi Kargo`nF9:9860008925`nF10:bugunun tarihi`nF11:https://magaza.alternet.com.tr`nF12:İlaç tarif yazılımı 4691 sayılı kanuna istinaden KDV'den ve Kurumlar vergisinden muaftır.

F8::
Send, Yurtiçi Kargo
return

F9::
Send, 9860008925
return

F10::
FormatTime, TimeString, , dd/MM/yyyy
Send, %TimeString%
return

F11::
Send, https://magaza.alternet.com.tr
return

F12::
Send, İlaç tarif yazılımı 4691 sayılı kanuna istinaden KDV'den ve Kurumlar vergisinden muaftır.
return





