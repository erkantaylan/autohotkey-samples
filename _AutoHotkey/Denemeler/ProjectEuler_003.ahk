; largest prime factor of 600.851.475.143
; autor  erkan taylan
; 2014.Haziran.5 Persembe
;
;
theNumber := 600851475143
kareKoku := sqrt(theNumber)

MsgBox, %IsPrime(17)%


IsPrime(sayi)
{
	if(sayi = 2 or sayi = 3 ) 
	{ return true 
	}
	if(sayi < 2 or mod(sayi,2) = 0 or mod(sayi,3) = 0) 
	{ return false 
	}
	i := 5
	while i < sqrt(sayi) + 1
	{
		if mod(sayi, i) = 0
			return false
	}
	return true
}