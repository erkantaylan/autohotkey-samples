^d::



If GetActiveWindowProcessName() = "devenv.exe"
{
    MsgBox, yes
    Return
}
Else
{
    MsgBox, no
}


GetActiveWindowProcessName() {
    WinGet, Active_ID, ID, A
    WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
    return Active_Process
}