pressedKeys := ""

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
nameList.Insert("LOCK")

pathList := Object()
pathList.Insert("C:\Users\kivi\Desktop\Fridge\7zip.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\ders.pdf")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\firefox.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\phpstorm.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\skype.lnk")
pathList.Insert("C:\Users\kivi\Desktop\Fridge\spotify.lnk")
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
pathList.Insert("C:\Users\kivi\Desktop\Fridge\ScreenLock.ahk")

Loop 
{
    if GetKeyState("CapsLock", "T") = 1
    {
        Input, inputValue, L1 C M
        if GetKeyState("CapsLock", "T") = 1
        {
            pressedKeys := pressedKeys . inputValue
            index := FindIndexArray(pressedKeys, nameList)

            ToolTip, % pressedKeys . ":" . index
            SetTimer, RemoveToolTip, 1000

            IfNotEqual, index, -1
            {
                pressedKeys := ""
                RunProgram(pathList[index])
            }
        }
        else
        {
            Send, a
            pressedKeys := ""
        }
    }
}

RunProgram(name) 
{
    Run, % name
}


RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return


FindIndexArray(keyword, list) {
    For index, key in list
    {
        If InStr(keyword, key)
        {
            return index
        }
    }
    return -1
}