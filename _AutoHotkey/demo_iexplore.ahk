IE := ComObjCreate("InternetExplorer.Application")
IE.Visible := true
IE.Navigate(path)
While IE.readyState!=4 || IE.document.readyState!="complete" || IE.busy
	Sleep 50