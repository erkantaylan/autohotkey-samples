;{Up} Up-arrow key on main keyboard 
;{Down} Down-arrow down key on main keyboard 
;{Left} Left-arrow key on main keyboard 
;{Right} Right-arrow key on main keyboard 
;{Home} Home key on main keyboard 
;{End} End key on main keyboard 
;{PgUp} 
t::
Loop, 3
{
	Send, {AppsKey}
	Sleep, 111
	Send, {UP}{UP}
	;Send, X
	Sleep, 111
	Send, {ENTER}
	Sleep, 333
	Send, {ENTER}
	Sleep, 111
	Send, {DOWN}
	Sleep, 111
}
