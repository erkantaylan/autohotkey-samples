;INVOKER
a = 0
while (a = 0)
{
	Input, OutputVar, L1 C V M
	; V harfi yi basabilmesi icin
	; L1 kac harf alacak
	; C, Mqeqep
;qerAQ345
;QERppq7770erq7770Eeq77703456q7770qqqqe

	;GetKeyState, state, CapsLock, D
	;state = A
	;if(state <> D)
	;if(state = A)
	;{pqqeeeRQRQRQRQRP
	if OutputVar = R;Meteor
		SkillGetir(8,9,9)

	else if OutputVar = 3;Cold Snap
		SkillGetir(7,7,7)

	else if OutputVar = 4;Ice Wall
		SkillGetir(7,7,8)

	else if OutputVar = 5;Forge Spirit
		SkillGetir(9,9,8)

	else if OutputVar = 6;Sun Strike
		SkillGetir(9,9,9)

	else if OutputVar = Q;Gost Walk
		SkillGetir(7,7,8)

	else if OutputVar = E;Deafening Blast
		SkillGetir(7,8,9)

	else if OutputVar = T;Alactiry
		SkillGetir(7,7,9)

	else if OutputVar = G;Tornado
		SkillGetir(7,8,8)

	else if OutputVar = Z;EMP
		SkillGetir(8,8,8)

	else if OutputVar = P
	{
		ExitApp
		;Bir donguye sokup Pause olmasi yapilacak
	}
	;}
;
	;else if OutputVar = P
	;{
	;	ExitApp
		;;Bir donguye sokup Pause olmasi yapilacak
	;}
}

;Function without call
SkillGetir(x,y,z)
{
	Send, %x%
	Sleep, 10
	Send, %y%
	Sleep, 10
	Send, %z%
	Sleep, 10
	Send, 0
}

SkillBas(x,y,z)
{
	Send, %x%
	Sleep, 10
	Send, %y%
	Sleep, 10
	Send, %z%
	Sleep, 10
	Send, 0
	Sleep, 10
	Send, 1;Cagrilan skilin otomatik basilmasi icin
}