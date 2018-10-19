#NoEnv

~^C:: DoublePress()

DoublePress() {
	static pressed1 = 0
	if pressed1 and A_TimeSincePriorHotkey <= 200
	{
		pressed1 = 0
		result := GoogleTranslate(Clipboard, "tr")
		ToolTip, % result
	}
	else
	pressed1 = 1
}

GoogleTranslate(phrase, to) {
	base := "https://translate.google.com/#auto/tr"
	path := base . "/" . phrase
	IE := ComObjCreate("InternetExplorer.Application")
	IE.Visible := false
	IE.Navigate(path)

	While IE.readyState!=4 || IE.document.readyState!="complete" || IE.busy
		Sleep 50

	Result := IE.document.all.result_box.innertext
	IE.Quit
	return Result
}

~LButton::
ToolTip
return

