' launch-hidden.vbs
' Launches a program with SW_HIDE so scheduled tasks don't flash a
' console on startup. Intended to wrap the existing action of a Windows
' scheduled task via:
'
'     Execute:   wscript.exe
'     Arguments: "<this file>" "<original exe>" [original args...]
'
' WshShell.Run with showStyle=0 hides the process window, and wait=False
' lets wscript exit immediately so the scheduled task records a clean
' success code even when the wrapped program is a long-running service.

Option Explicit

If WScript.Arguments.Count < 1 Then
    WScript.Quit 1
End If

Dim sh, cmd, i
Set sh = CreateObject("WScript.Shell")

cmd = QuoteArg(WScript.Arguments.Item(0))
For i = 1 To WScript.Arguments.Count - 1
    cmd = cmd & " " & QuoteArg(WScript.Arguments.Item(i))
Next

sh.Run cmd, 0, False

' Wrap an argument in double quotes, escaping any embedded " as \" per
' the Windows MSVCRT command-line convention. Required so tasks whose
' original args contain quoted substrings (bash -c "..." and similar)
' round-trip correctly through wscript back into the target process.
Function QuoteArg(a)
    QuoteArg = """" & Replace(a, """", "\""") & """"
End Function
