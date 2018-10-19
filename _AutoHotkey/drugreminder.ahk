hour := 4
minsinHour := 60
secondsinMin := 60
milisecondsinSecond = 1000
Loop {
	MsgBox, TAKE YOUR DRUG!!
	total := hour * minsinHour * secondsinMin * milisecondsinSecond
	Sleep, %total%
}