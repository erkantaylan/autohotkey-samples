/* 
This idea of storing settings in the script itself is stolen from emmanuel d
http://www.autohotkey.com/community/viewtopic.php?f=2&t=75381

[Settings]              ; The script doesn't see this line.  The ini sees a new section heading.
 */
PassChar = z            ; Use any character you like
PassWord = ofg41DC         ; Same for password
/* 
[EndSettings]           ; The ini sees the lines above as keys and values.  The script sees values assigned to variables.
 */
 
F12::                   ; Lock everything
    ; **************************************************************
    ; *** A single press of PassChar immediately unlocks computer ***
    ; *** Any other key pressed requires full password           ***
    ; **************************************************************        
    WinMinimizeAll                      ; Hide what's on screen
    Hotkey !Tab, NULL                   ; Disable alt-tab
    BlockInput, MouseMove               ; Disable mousemoves
    Input, SingleKey, L1                ; Wait for user to type something.
    If (SingleKey <> PassChar)          ; PassChar?
        {                               ; No, so demand full password
            String :=
            While String <> PassWord
                InputBox String, Computer is locked!, Password:, HIDE, 250, 150
        }
    SoundPlay c:\Windows\Media\B6.WAV   ; Play sound to announce computer successfully unlocked
    Hotkey !Tab, Off                    ; Restore alt-tab
    BlockInput MouseMoveOff             ; Restore mouse moves
    WinMinimizeAllUndo                  ; Restore screen
Return    

NULL:                                   ; Dummy routine for alt-tab (does nothing)
Return