@ECHO OFF
SETLOCAL
REM
REM INSTALLDIR variable is updated by the installer
REM

SET INSTALLDIR="@MARVINBEANSHOME@"
SET W=%CLASSPATH%
IF EXIST "%INSTALLDIR%". (
    SET SETUPBAT="@MARVINBEANSHOME@\bin\setup.bat"
	SET CLASSPATH="@MARVINBEANSHOME@\lib\MarvinBeans.jar;%CLASSPATH%"
	GOTO AFTER_CLASSPATH
)

SET SETUPBAT="..\bin\setup.bat"
SET CLASSPATH="..\lib\MarvinBeans.jar;%CLASSPATH%"

:AFTER_CLASSPATH

SET Z=%JVMPATH%
IF EXIST %SETUPBAT%. (
    CALL %SETUPBAT%
) ELSE (
    SET JVMPATH=java
)

REM Filter JVM parameters
set JVMPARAM=
set JVM_X_PARAM=

:START_JVMPARAM
if [%1]==[] GOTO END_JVMPARAM
:: Remove quotes
set nqparam=%1
   SET nqparam=###%nqparam%###
   SET nqparam=%nqparam:"###=%
   SET nqparam=%nqparam:###"=%
   SET nqparam=%nqparam:###=%
REM check first two characters of the parameter
set pam=%nqparam%
set hpam=%pam:~0,2%
if "%hpam%"=="-X" (
        set JVMPARAM=%JVMPARAM% %1
        set JVM_X_PARAM=%JVM_X_PARAM% %1
        SHIFT
        GOTO START_JVMPARAM
)
if %1==-client (
    set JVMPARAM=%JVMPARAM% %1
    SHIFT
    GOTO START_JVMPARAM
)
if %1==-server (
    set JVMPARAM=%JVMPARAM% %1
    SHIFT
    GOTO START_PARAM
)
:END_JVMPARAM

set JVMPARAM=%JVMPARAM% -classpath %CLASSPATH%

shift
set P1=%0
shift
set P2=%0
shift
set P3=%0
shift
set P4=%0
shift
set P5=%0
shift
set P6=%0
shift
set P7=%0
shift
set P8=%0
shift
set P9=%0
shift
set P10=%0
shift
set P11=%0
shift
set P12=%0
shift
set P13=%0
shift
set P14=%0
shift
set P15=%0
shift
set P16=%0
shift
set P17=%0
shift
set P18=%0
shift
set P19=%0
shift
set P20=%0
shift
set P21=%0
shift
set P22=%0
shift
set P23=%0
shift
set P24=%0
shift
set P25=%0
shift
set P26=%0
shift
set P27=%0
shift
set P28=%0
shift
set P29=%0
shift
set P30=%0
shift
set P31=%0
shift
set P32=%0
shift
set P33=%0
shift
set P34=%0
shift
set P35=%0
shift
set P36=%0
shift
set P37=%0
shift
set P38=%0
shift
set P39=%0
shift
set P40=%0
shift
set ENDTEST=%0
if not _%ENDTEST%==_ goto Error

REM ---------------- End of Marvin batch header -----------------------------


"%JVMPATH%" %JVMPARAM% chemaxon.formats.MdlCompressor %P1% %P2% %P3% %P4% %P5% %P6% %P7% %P8% %P9% %P10% %P11% %P12% %P13% %P14% %P15% %P16% %P17% %P18% %P19% %P20% %P21% %P22% %P23% %P24% %P25% %P26% %P27% %P28% %P29% %P30% %P31% %P32% %P33% %P34% %P35% %P36% %P37% %P38% %P39% %P40%

REM ----------------- Begin of Marvin batch footer --------------------------

goto End

:Error
echo Error: Too many parameters. You are probably not using quotes for parameters
echo that contain more words
:End

REM Environment variables are global in DOS, so we must restore the
REM original CLASSPATH.
SET CLASSPATH=%W%
SET JVMPATH=%Z%
ENDLOCAL

