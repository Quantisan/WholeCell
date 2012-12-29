' ChechMarvinRun.vbs
' Investigates whether Marvin applications or marvinOLEServer.exe are running.
' Returns with 1 if Marvin is still running else does nothing
' author: Tamas Vertse
' version: 01/11/2010
' since: 01/11/2010
Dim ArgObj, argCommand, dmsg
Dim msg

msg = CheckMarvinProcess()
debugMsg msg
If msg <> "" Then
	WScript.Echo msg
	WScript.Quit 1
End If

Public Function CheckMarvinProcess()
	Dim objWMIService, objProcess, colProcess
	Dim strComputer

	strComputer = "."

	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" _ 
& strComputer & "\root\cimv2") 

	Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process")
	CheckMarvinProcess = ""
	For Each objProcess in colProcess
		If UCase(objProcess.Name) = "MARVIN~1.EXE" Then
			CheckMarvinProcess = "MARVIN~1.EXE is still running."
			Exit For
		End If
		If UCase(objProcess.Name) = UCase("marvinOLEServer.exe") Then
			CheckMarvinProcess = "marvinOLEServer.exe is still running."
			Exit For
		End If
		If UCase(objProcess.Name) = "MARVINVIEW.EXE" Then
			CheckMarvinProcess = "MarvinView.exe is still running."
			Exit For
		End If
		If UCase(objProcess.Name) = "MARVINSKETCH.EXE" Then
			CheckMarvinProcess = "MarvinSketch.exe is still running."
			Exit For
		End If
		If UCase(objProcess.Name) = "MARVINSPACE.EXE" Then
			CheckMarvinProcess = "MarvinSpace.exe is still running."
			Exit For
		End If
		If UCase(objProcess.Name) = "LICENSEMANAGER.EXE" Then
			CheckMarvinProcess = "LicenseManager.exe is still running."
			Exit For
		End If
		If Ucase(objProcess.Name) = UCase("instantjchem.exe") Then
			CheckMarvinProcess = "instantjchem.exe is still running."
			Exit For
		End If
	Next
End Function

' Print debug messages
' msg the debug message
Public Function debugMsg(ByVal msg)
	If (debugLevel > 0) Then
		Wscript.Echo "[DEBUG]: " & msg
	End If
End Function
WScript.Quit 0
