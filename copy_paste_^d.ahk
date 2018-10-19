; #If WindowExists("devenv.exe")

^d::
Send, ^c
Send, ^v

WindowExists(name) {
    If (name = GetActiveWindowProcessName()) {
        return True
    }
    return False
}

GetActiveWindowProcessName() {
    WinGet, Active_ID, ID, A
    WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
    return Active_Process
}