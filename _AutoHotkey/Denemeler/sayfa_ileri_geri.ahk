;XButton1 Browser_Back
;XButton2 Browser_Forward

Loop
{
	Transform, CtrlC, Chr, 3 ; Store the character for Ctrl-C in the CtrlC var. 
	Input, OutputVar, L1 M
	;if OutputVar = %XButton1%
	MsgBox, You pressed %OutputVar%.
	
}




;Send, {XButton1}asdf

