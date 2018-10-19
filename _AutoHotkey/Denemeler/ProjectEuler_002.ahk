; sum of under 4.000.000 even fibo numbers
;
;
;
;

Fibonacci(4000000)

Fibonacci(maxNumber)
{
	fibo1 := 1
	fibo2 := 2
	toplam := 0
	While(fibo1 < maxNumber or fibo2 < maxNumber)
	;While(fibo1 + fibo2 < maxNumber)
	{
		If IsEven(fibo1)
			toplam += fibo1
		fibo1 += fibo2
		
		If IsEven(fibo2)
			toplam += fibo2
		fibo2 += fibo1
	}
	MsgBox, fibo1 = %fibo1% fibo2 = %fibo2% toplam = %toplam%
}

IsEven(myNumber := 0)
{
	if Mod(myNumber, 2) = 0
		return true
	return false
}