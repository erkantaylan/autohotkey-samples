toplam := 0
Loop, 999
{
	if Mod(A_Index,3) = 0
	{
		toplam += A_Index
	}
	else if Mod(A_Index,5) = 0
	{
		toplam += A_Index
	}
}
MsgBox, %toplam%



