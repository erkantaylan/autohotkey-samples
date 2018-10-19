/*FormatTime, TimeString
MsgBox The current time and date (time first) is %TimeString%.

FormatTime, TimeString, R
MsgBox The current time and date (date first) is %TimeString%.

FormatTime, TimeString,, Time
MsgBox The current time is %TimeString%.

FormatTime, TimeString, T12, Time
MsgBox The current 24-hour time is %TimeString%.

FormatTime, TimeString,, LongDate
MsgBox The current date (long format) is %TimeString%.
*/

; FormatTime, TimeString, , dd/MM/yyyy
; MsgBox The specified date and time, when formatted, is %TimeString%.

/*FormatTime, TimeString, 200504, 'Month Name': MMMM`n'Day Name': dddd

FormatTime, YearWeek, 20050101, YWeek
MsgBox %TimeString%
*/

F1::
FormatTime, TimeString, , yyyy_MM_dd_hh_mm_ss
Send, % TimeString