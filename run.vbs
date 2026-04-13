Set ws = CreateObject("WScript.Shell")
dir = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\") - 1)
ws.Run "powershell -NoExit -ExecutionPolicy Bypass -File """ & dir & "\run.ps1""", 1, False
