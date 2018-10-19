CreateScript(script){
  static mScript
  StrReplace,script,%script%,`n,`r`n
  StrReplace,script,%script%,`r`r,`r
  If RegExMatch(script,"m)^[^:]+:[^:]+|[a-zA-Z0-9#_@]+\{}$"){
    If !(mScript){
      If (A_IsCompiled){
         lib := DllCall("GetModuleHandle", "ptr", 0, "ptr")
        If !(res := DllCall("FindResource", "ptr", lib, "str", ">AUTOHOTKEY SCRIPT<", "ptr", Type:=10, "ptr"))
          If !(res := DllCall("FindResource", "ptr", lib, "str", ">AHK WITH ICON<", "ptr", Type:=10, "ptr")){
            MsgBox Could not extract script!
            return
          }
        DataSize := DllCall("SizeofResource", "ptr", lib, "ptr", res, "uint")
        hresdata := DllCall("LoadResource", "ptr", lib, "ptr", res, "ptr")
        pData := DllCall("LockResource", "ptr", hresdata, "ptr")
        If (DataSize){
          mScript:=StrGet(pData,"UTF-8")
          StrReplace,mScript,%mScript%,`n,`r`n
          StrReplace,mScript,%mScript%,`r`r,`r
          StrReplace,mScript,%mScript%,`r`r,`r
          StrReplace,mScript,%mScript%,`n`n,`n
          mScript .="`r`n"
        }
      } else {
        FileRead,mScript,%A_ScriptFullPath%
        StrReplace,mScript,%mScript%,`n,`r`n
        StrReplace,mScript,%mScript%,`r`r,`r
        mScript .= "`r`n"
        LoopParse,%mScript%,`n,`r
        {
          If A_Index=1
            mScript:=""
          If RegExMatch(A_LoopField,"i)^\s*#include"){
            temp:=RegExReplace(A_LoopField,"i)^\s*#include[\s+|,]")
            If InStr(temp,"`%"){
              LoopParse,%temp%,`%
              {
                If (A_Index=1)
                  temp:=A_LoopField
                else if !Mod(A_Index,2)
                  _temp:=A_LoopField
                else {
                  _temp:=%_temp%
                  temp.=_temp A_LoopField
                  _temp:=""
                }
              }
            }
            If (SubStr(temp,1,1) . SubStr(temp,-1) = "<>")
              temp:=SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",1,0)) "lib\" trim(temp,"<>") ".ahk"
            FileRead,_temp,%temp%
            mScript.= _temp "`r`n"
          } else mScript.=A_LoopField "`r`n"
        }
      }
    }
    LoopParse,%script%,`n,`r
    {
      If A_Index=1
        script:=""
      else If (A_LoopField="")
        Continue
      If (RegExMatch(A_LoopField,"^[^:\s]+:[^:\s=]+$")){
        StrSplit,label,%A_LoopField%,:
        If (label.MaxIndex()=2 and IsLabel(label.1) and IsLabel(label.2)){
          script .=SubStr(mScript
            , h:=InStr(mScript,"`r`n" label.1 ":`r`n")
            , InStr(mScript,"`r`n" label.2 ":`r`n")-h) . "`r`n"
        }
      } else if RegExMatch(A_LoopField,"^[^\{}\s]+\{}$"){
        label := SubStr(A_LoopField,1,-2)
        script .= SubStr(mScript
          , h:=RegExMatch(mScript,"i)\n" label "\([^\\)\n]*\)\n?\s*\{")
          , RegExMatch(mScript,"\n}\s*\K\n",1,h)-h) . "`r`n"
      } else
        script .= A_LoopField "`r`n"
    }
  }
  StrReplace,script,%script%,`r`n,`n
  Return Script
}