;1::
a := 0
x := "y"

;MsgBox, %OutputVar% %x%

;Q7790999uq7790999uq7790999UQ7790999q7790999uq7790999uq7790999uq7790999uq7790999uq7790999;uuuUd
while (a = 0)
{
	Input, OutputVar, L1 C V M
	;if OutputVar = "u"
	;{
	;	if x := n
	;	{
	;		MsgBox, %OutputVar% %x%
	;		x := "y"
	;	}
	;	else
	;	{
	;		MsgBox, %OutputVar% %x%
	;		x := "n"
	;	}
	;}

	if x := "y"
	{
		if OutputVar      = R ;Meteor r8990
			Skill(8,9,9)
		else if OutputVar = 3 ; Defening Blast 
			Skill(7,8,9)
		else if OutputVar = 4 ; Sun Trike 29990
			Skill(9,9,9)
		else if OutputVar = Q ; ICE WALL
			Skill(7,7,9)
		else if OutputVar = W ; COLD SNAP 
			Skill(7,7,7)
		else if OutputVar = E ; Forge Spirit
			Skill(7,9,9)
		else if OutputVar = A ; ALACRITY
			Skill(8,8,9)
		else if OutputVar = S ; GHOST WALK
			SkillGetir(7,7,8) ;;;;
		else if OutputVar = F ; TORNADO
			Skill(7,8,8) 
		else if OutputVar = D ; EMP
			Skill(8,8,8)
		else if OutputVar = 5
			QUAS()
		else if OutputVar = 6
			WEX()
	}
}
SkillGetir(x,y,z)
{
	Send, %x%
	;Sleep, 10
	Send, %y%
	;Sleep, 10
	Send, %z%
	;Sleep, 10
	Send, 0
	;EXORT()
	QUAS()
	;Sleep, 10
	Send, 1
}
Skill(x,y,z)
{
	Send, %x%
	;Sleep, 10
	Send, %y%
	;Sleep, 10
	Send, %z%
	;Sleep, 10
	Send, 0
	Send, 1
	EXORT()
}

EXORT()
{
	Send, 9
	Send, 9
	Send, 9
}

QUAS()
{
	Send, 7
	Send, 7
	Send, 7
}

WEX()
{
	Send, 8
	Send, 8
	Send, 8
}
