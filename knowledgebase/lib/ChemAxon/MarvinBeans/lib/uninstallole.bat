@ECHO OFF

REM
REM Uninstall OLE server
REM Without parameter, display error message in popup
REM /c Run in silent/console mode, error messages are printed to the console
REM /w Run in silent/window mode, error messages are printed to the console

FOR %%I in (%0) do cd /D %%~dpI

if "%1" == "/w" (
	wscript.exe //NoLogo InstallUninstallOleServer.vbs /U %2 %3
) else if "%1" == "/c" (
	cscript.exe //NoLogo InstallUninstallOleServer.vbs /U %2 %3
)

