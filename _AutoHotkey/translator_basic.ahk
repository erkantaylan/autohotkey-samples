phrase := "一隻狐狸正在追捕一隻兔子"
from   := "zh-CN"
to     := "en"
msgbox % GoogleTranslate(phrase, from, to)

GoogleTranslate(phrase, from, to) {
	base := "https://translate.google.com.tw/?hl=en&tab=wT#"
	path := base . from . "/" . to . "/" . phrase
	IE := ComObjCreate("InternetExplorer.Application")
	;~ IE.Visible := true
	IE.Navigate(path)

	While IE.readyState!=4 || IE.document.readyState!="complete" || IE.busy
	        Sleep 50

	Result := IE.document.all.result_box.innertext
	IE.Quit
	return Result
}