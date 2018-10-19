sayi := 325363848
basamakSayisi := basamakLar(sayi)
MsgBox, %basamakSayisi%

basamakLar(n)
{
	if n <> 1 
	{
		return basamakLar(n/2) + 1
	}
	else
	{
		return 1
	}
}