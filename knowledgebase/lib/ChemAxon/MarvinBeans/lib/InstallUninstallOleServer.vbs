' InstallUninstallOleServer.vbs
' VBScript to install/uninstall OLE Server registry settings
' author: Tamas Vertse, Viktor Hamori
' version: 04/20/2010
' since: 12/14/2009
Const HKEY_LOCAL_MACHINE = &H80000002
Const REG_SZ = 1
Const REG_EXPAND_SZ = 2
Const REG_BINARY = 3
Const REG_DWORD = 4
Const REG_MULTI_SZ = 7

Const debugLevel = 0
Dim ArgObj, dmsg
Dim sCommand, sTargetDirectory, sVersion

Set shMain = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Gets arguments
Set ArgObj = WScript.Arguments
If ArgObj.Count < 3 Then
	WScript.Echo "Missing parameter"
    WScript.Echo "Please us it as :  '/I (Install) or /U (Uninstall)' 'Target path' 'Version'" 
	WScript.Quit 1
End If

sCommand = Trim(ArgObj.Item(0))
sTargetDirectory = ArgObj.Item(1)
sVersion = ArgObj.Item(2)

If UCase(sCommand) = "/I" Then
	Call Install()
ElseIf UCase(sCommand) = "/U" Then
	Call Uninstall()
Else
    WScript.Echo "Invalid parameter (" & sCommand & ")"
    WScript.Echo "Please us it as :  '/I (Install) or /U (Uninstall)'" 
    WScript.Quit 1
End If
WScript.Quit 0


'-----------------------------------------------------------------------
' Installation scripts
'-----------------------------------------------------------------------

' Install
Public Function Install()

    Call AddComponentReference()
    Call SetRunningMode()
	Wscript.Quit 0
End Function

' Uninstall
' Check if the program is running or not!
Public Function Uninstall()
	Dim msg
	msg = CheckMarvinProcess()
	debugMsg msg
	If msg <> "" Then
		WScript.Echo "ERROR: Cannot uninstall Marvin because " & msg
		WScript.Quit 1
	End If
    Call DeleteComponentReference()
    Call SetRunningMode()
	
	Wscript.Quit 0
End Function

'--------------------------------------------------------------------------
' 64 bit support
'--------------------------------------------------------------------------
Public Function Is64Bit()
    
Const wbemFlagReturnImmediately = &H10
Const wbemFlagForwardOnly = &H20


Set objWMIService = GetObject("winmgmts:\\" & "." & "\root\CIMV2")
Set colItems = objWMIService.ExecQuery("SELECT AddressWidth FROM Win32_Processor", "WQL", _
wbemFlagReturnImmediately + wbemFlagForwardOnly)

Dim s
For Each objItem In colItems
    s = objItem.AddressWidth
Next

Is64Bit = cBool(CStr(s) = "64")

End Function
'--------------------------------------------------------------------------



'---------------------------------------------------------------------------
' Registry manipulation
'---------------------------------------------------------------------------
Public Function GetReferencePathRootSubkey()
Dim sKey 
   If Is64bit() then
        sKey = "\Wow6432Node\ChemAxon\MarvinOLE"
   Else
        sKey = "\ChemAxon\MarvinOLE"
   End if 
   GetReferencePathRootSubkey = sKey
End Function

Public Function GetHKLMMarvinOLE()
' consider WOW64 bit registry usage
    GetHKLMMarvinOLE = "SOFTWARE\ChemAxon\MarvinOLE"  'GetReferencePathRootSubkey()
End Function

Public Function GetReferenceKey()
    GetReferenceKey = Replace(sTargetDirectory, "\", "/")
End Function

Public Function GetReferencePathRoot()
    GetReferencePathRoot = GetHKLMMarvinOLE() & "\ReferenceFolders"
End Function

Public Function GetReferencePath()
Dim sKey 
   sKey = "HKEY_LOCAL_MACHINE" & "\" & GetReferencePathRoot() & "\" & GetReferenceKey()
   GetReferencePath = sKey 
End Function

Public Function GetRunningModePath()
Dim sKey 
    sKey = "HKEY_LOCAL_MACHINE" & "\" & GetHKLMMarvinOLE() & "\Settings\RunningMode"
    GetRunningModePath = sKey
End Function

Public Function ReadComponentReferenceCount() 
Dim lValue, arrValueNames,  arrValueTypes

   lValue = 0
 
   sComputer = "."

   Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _ 
   sComputer & "\root\default:StdRegProv")

   call oReg.EnumValues( HKEY_LOCAL_MACHINE, GetReferencePathRoot(), arrValueNames, arrValueTypes)
   On error resume next
   lValue = UBound(arrValueNames) - LBound(arrValueNames) + 1

   ReadComponentReferenceCount = lValue
  
End Function

Public Function ReadComponentReference() 
Dim sValue 

   On Error Resume Next
   sValue = ""
   sValue = CStr(shMain.RegRead(GetReferencePath()))
   ReadComponentReference = sValue
  
End Function

Public Sub AddComponentReference()
  
   On error resume next
   if not IsComponentKeyExists() then
      on error goto 0
      Call shMain.RegWrite(GetReferencePath(), sVersion, "REG_SZ")
   end if

End Sub

Public Function DeleteComponentReference()
Dim bRet
    
   On error resume next
   bRet = False
   if (IsComponentKeyExists()) then
      Call shMain.RegDelete(GetReferencePath())
      bRet = True
   end if
   DeleteComponentReference = bRet 
End Function


Public Function IsComponentKeyExists() 
Dim sDummy 
   
   IsComponentKeyExists = CBool(ReadComponentReference() <> "")

End Function

Public Sub SetRunningMode()
Dim lValue
    
    lValue = 0 ' Unknown mode
    if (CLng(ReadComponentReferenceCount()) > 0) then
        lValue = 1 ' JAVA mode        
    end if
    
    Call shMain.RegWrite(GetRunningModePath(), lValue, "REG_DWORD")
    
End Sub 
'-----------------------------------------------------------------------
' Running Process checking
'-----------------------------------------------------------------------

Public Function CheckMarvinProcess()
	Dim objWMIService, objProcess, colProcess
	Dim strComputer

	strComputer = "."

	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
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
		If UCase(objProcess.Name) = UCase("instantjchem.exe") Then
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

