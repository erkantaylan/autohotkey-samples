;--------------------------------------------------
; Translate text using translate.google.com 
; after Google Translate API deprecation
;
; Ctrl+C, Ctrl+C
; Author: Mikhail Kuropyatnikov (micdelt@mail.ru), 
;       Volgograd, Russia
;--------------------------------------------------
#NoEnv

~^C:: DoublePress()

DoublePress()
{
   static pressed1 = 0
   if pressed1 and A_TimeSincePriorHotkey <= 200
   {
      pressed1 = 0
	  ; Translate from any language to Russian and from Russian to English if source was in Russian
      Translate("tr","en") 
   }
   else
      pressed1 = 1
   
}

; translate to "to" language,
; if source language is "to" 
; translate to "anti" language

Translate(To,Anti)
{
   UseAnti = 0
   TranslateTo := To
   if Clipboard = 
       return

   UriCli := UriEncode(Clipboard)

anti_translate:
   Url := "http://translate.google.com/translate_a/t?client=x&text="
            . UriCli . "&tl=" . TranslateTo

   ; Simulate Google Chrome
   JsonTrans := UrlDownloadToVar(Url,"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/18.6.872.0 Safari/535.2")

   ; thanks to Grey (http://forum.script-coding.com/profile.php?id=25792)
   StringReplace, JsonTrans, JsonTrans, \r\n,`r`n, All
   StringReplace, JsonTrans, JsonTrans, \", ", All
   FromLang:=JSON(JsonTrans, "src")
   ElapsedTime:=JSON(JsonTrans, "server_time")

   if (FromLang == To and TranslateTo <> Anti)
   {
      TranslateTo := Anti
      ;MsgBox % FromLang . " " . To . " " TranslateTo . " " . Anti
      goto anti_translate
   }

   Loop
   {
     Sentence:=JSON(JsonTrans, "sentences["(A_Index-1)"].trans")
     If Sentence
       TransText.=Sentence
     Else
       Break
   }
   
   ; Convert To UTF-8
   BaseFileEnc := A_FileEncoding
   FileEncoding
   FileDelete, %A_ScriptDir%\Convert.html 
   FileAppend, %TransText%, %A_ScriptDir%\Convert.html 
   FileEncoding, UTF-8
   FileRead TransText, %A_ScriptDir%\Convert.html 
   FileEncoding, %BaseFileEnc%
   
   ; split long line to smaller lines about 40-50 symbols length
   t := RegExReplace(transText,".{40,50}(\s)","$0`n")
   
   ToolTip %FromLang%: %t%
   ; copy result to clipboard
   clipboard := t
   
}



~LButton::
ToolTip
return



UrlDownloadToVar(URL, UserAgent = "", Proxy = "", ProxyBypass = "") {
    ; Requires Windows Vista, Windows XP, Windows 2000 Professional, Windows NT Workstation 4.0,
    ; Windows Me, Windows 98, or Windows 95.
    ; Requires Internet Explorer 3.0 or later.
    pFix:=a_isunicode ? "W" : "A"
    hModule := DllCall("LoadLibrary", "Str", "wininet.dll")

    AccessType := Proxy != "" ? 3 : 1
    ;INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
    ;INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
    ;INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
    ;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

    io := DllCall("wininet\InternetOpen" . pFix
    , "Str", UserAgent ;lpszAgent
    , "UInt", AccessType
    , "Str", Proxy
    , "Str", ProxyBypass
    , "UInt", 0) ;dwFlags

    iou := DllCall("wininet\InternetOpenUrl" . pFix
    , "UInt", io
    , "Str", url
    , "Str", "" ;lpszHeaders
    , "UInt", 0 ;dwHeadersLength
    , "UInt", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
    , "UInt", 0) ;dwContext

    If (ErrorLevel != 0 or iou = 0) {
        DllCall("FreeLibrary", "UInt", hModule)
        return 0
    }

    VarSetCapacity(buffer, 10240, 0)
    VarSetCapacity(BytesRead, 4, 0)

    Loop
    {
        ;http://msdn.microsoft.com/library/en-us/wininet/wininet/internetreadfile.asp
        irf := DllCall("wininet\InternetReadFile", "UInt", iou, "UInt", &buffer, "UInt", 10240, "UInt", &BytesRead)
        VarSetCapacity(buffer, -1) ;to update the variable's internally-stored length

        BytesRead_ = 0 ; reset
        Loop, 4  ; Build the integer by adding up its bytes. (From ExtractInteger-function)
            BytesRead_ += *(&BytesRead + A_Index-1) << 8*(A_Index-1) ;Bytes read in this very DllCall

        ; To ensure all data is retrieved, an application must continue to call the
        ; InternetReadFile function until the function returns TRUE and the lpdwNumberOfBytesRead parameter equals zero.
        If (irf = 1 and BytesRead_ = 0)
            break
        Else ; append the buffer's contents
        {
            a_isunicode ? buffer:=StrGet(&buffer, "CP0")
            Result .= SubStr(buffer, 1, BytesRead_ * (a_isunicode ? 2 : 1))
        }

        /* optional: retrieve only a part of the file
        BytesReadTotal += BytesRead_
        If (BytesReadTotal >= 30000) ; only read the first x bytes
        break                      ; (will be a multiple of the buffer size, if the file is not smaller; trim if neccessary)
        */
    }

    DllCall("wininet\InternetCloseHandle",  "UInt", iou)
    DllCall("wininet\InternetCloseHandle",  "UInt", io)
    DllCall("FreeLibrary", "UInt", hModule)
   Return Result
}

JSON(ByRef js, s, v = "") {
   j = %js%
   Loop, Parse, s, .
   {
      p = 2
      RegExMatch(A_LoopField, "([+\-]?)([^[]+)((?:\[\d+\])*)", q)
      Loop {
         If (!p := RegExMatch(j, "(?<!\\)(""|')([^\1]+?)(?<!\\)(?-1)\s*:\s*((\{(?:[^{}]++|(?-1))*\})|(\[(?:[^[\]]++|(?-1))*\])|"
            . "(?<!\\)(""|')[^\7]*?(?<!\\)(?-1)|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
            Return
         Else If (x2 == q2 or q2 == "*") {
            j = %x3%
            z += p + StrLen(x2) - 2
            If (q3 != "" and InStr(j, "[") == 1) {
               StringTrimRight, q3, q3, 1
               Loop, Parse, q3, ], [
               {
                  z += 1 + RegExMatch(SubStr(j, 2, -1), "^(?:\s*((\[(?:[^[\]]++|(?-1))*\])|(\{(?:[^{\}]++|(?-1))*\})|[^,]*?)\s*(?:,|$)){" . SubStr(A_LoopField, 1) + 1 . "}", x)
                  j = %x1%
               }
            }
            Break
         }
         Else p += StrLen(x)
      }
   }
   If v !=
   {
      vs = "
      If (RegExMatch(v, "^\s*(?:""|')*\s*([+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:""|')*\s*$", vx)
         and (vx1 + 0 or vx1 == 0 or vx1 == "true" or vx1 == "false" or vx1 == "null" or vx1 == "nul"))
         vs := "", v := vx1
      StringReplace, v, v, ", \", All
      js := SubStr(js, 1, z := RegExMatch(js, ":\s*", zx, z) + StrLen(zx) - 1) . vs . v . vs . SubStr(js, z + StrLen(x3) + 1)
   }
   Return, j == "false" ? 0 : j == "true" ? 1 : j == "null" or j == "nul"
      ? "" : SubStr(j, 1, 1) == """" ? SubStr(j, 2, -1) : j
}

;-------------------------------------------------
; HTML encode/decode
;------------------------------------------------

StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    SizeInBytes := VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    StrPut(string, &var, encoding)
   Return SizeInBytes 
}

UriEncode(str) 
{ 
   b_Format := A_FormatInteger 
   data := "" 
   SetFormat,Integer,H 
   SizeInBytes := StrPutVar(str,var,"utf-8")
   Loop, %SizeInBytes%
   {
   ch := NumGet(var,A_Index-1,"UChar")
   If (ch=0)
      Break
   if ((ch>0x7f) || (ch<0x30) || (ch=0x3d))
      s .= "%" . ((StrLen(c:=SubStr(ch,3))<2) ? "0" . c : c)
   Else
      s .= Chr(ch)
   }   
   SetFormat,Integer,%b_format% 
   return s 
} 