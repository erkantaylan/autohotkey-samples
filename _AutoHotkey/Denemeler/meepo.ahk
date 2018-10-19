Input, OutputVar, L1 C V M
If, OutputVar = "A"
{
	meepoSayisi := 4
	Loop, meepoSayisi
	{
		Send, {TAB}
		Sleep, 50
		Send, W
		Click, Left
	}
}