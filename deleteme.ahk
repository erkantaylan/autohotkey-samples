z::
Send {a down} ; this holds the space key down
KeyWait, z ; waits for you to release z
KeyWait, z, D ; waits for you to press Down z again
Send {a up}
KeyWait, z ; waits for you to release z
return