IfWinExist, SpotifyController
{
	;Play
	^F11::
	WinActivate, SpotifyController
	SendEvent, {Click 40, 40}
	Return

	;Pause
	^F12::
	WinActivate, SpotifyController
	SendEvent, {Click 160, 40}
	Return
}