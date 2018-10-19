^b::
a = 0
while a == 0
{
	Input, OutputVar, L1 C V M

	if OutputVar = P
	{
		if x = 0
		{
			x = 1
		}
		else
		{
			x = 0
		}
	}
	if x = 1
	{
		Send, NNNNN
		Sleep, 1300
	}
}