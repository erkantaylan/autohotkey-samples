nameList := Object()
nameList.Insert("7ZIP")
nameList.Insert("DERS")
nameList.Insert("FIREFOX")
nameList.Insert("PHPSTORM")
nameList.Insert("SKYPE")
nameList.Insert("SPOTIFY")
nameList.Insert("SUBLIME")
nameList.Insert("WINSCP")
nameList.Insert("CMDER")
nameList.Insert("DISCORT")
nameList.Insert("JULIA")
nameList.Insert("RAPIDEE")
nameList.Insert("SLACK")
nameList.Insert("SPOTIFYLYRICS")
nameList.Insert("TODO")
nameList.Insert("WPNXM")

pathList := Object()
pathList.Insert("C:\Users\kivi\Desktop\Fridge\7zip.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\ders.pdf")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\firefox.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\phpstorm.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\skype.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\spotify.lnkd")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\sublime.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\winscp.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\cmder.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\discort.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\julia.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\rapidee.exe")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\slack.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\spotifylyrics.exe")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\todo.bat")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\wpnxm.ln")


index := FindIndexArray("DERS", nameList)
MsgBox, % index


FindIndexArray(keyword, list) {
    For index, key in list
    {
    	MsgBox, % index . ";" . key ""
        If InStr(key, keyword)
        {

            return index
        }
    }
    return -1
}