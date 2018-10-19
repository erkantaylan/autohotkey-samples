a = GetKeyState(KeyName [, "P" or "T"])
a = 0
while a = 0
{
	;KeyWait, F1

	;if(KeyWait, F1, D)
	;{
	;	MsgBox, 4,, %x%? 

	;}	

	;Transform, CtrlC, Chr, 3 ; Store the character for Ctrl-C in the CtrlC var. 
	Input, OutputVar, L1 C V M
	MsgBox, %OutputVar%

	if OutputVar = 1
	{
		Send, 1
	}
	;if OutputVar = %CtrlC%
    ;MsgBox, You pressed Control-C.
}
;	MsgBox, 4,, %a%? sadfg1231123aqQ1111