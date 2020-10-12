::function to display text in one line with different colors. Can also print files. By DarviL.

@echo off
setlocal EnableDelayedExpansion

set ver=1.1

set parm1=%1
set parm2=%2
set parm3=%3
set parm4=%4

set color_fg=
set color_bg=
set color_new=




if "%parm1%"=="-s" (
	if not defined parm2 (
		call :error-parm CONTENT
	)
	if not defined parm3 (
		call :error-parm COLOR-BG
	)
	if not defined parm4 (
		call :error-parm COLOR-FG
	)
	call ::build %parm2% %parm3% %parm4% str
	exit /b
)
if "%parm1%"=="-f" (
	if not defined parm2 (
		call :error-parm CONTENT
	)
	if not defined parm3 (
		call :error-parm COLOR-BG
	)
	if not defined parm4 (
		call :error-parm COLOR-FG
	)
	call ::build %parm2% %parm3% %parm4% file
	exit /b
)
if /i "%parm1%"=="/?" goto help
if /i "%parm1%"=="-?" goto help
if /i "%parm1%"=="-h" goto help
if not defined parm1 call :display-red "No parameters were defined."&exit /b

call :display-red "Unexpected `'%parm1%`' parameter."
exit /b

:error-parm
call :display-red "Parameter [%1] is not defined."
set invalid=1
exit /b





::Build all the required variables for ::display. For files, set the text variable to be the content of a file.
:build
if "%4"=="str" (
	call ::color-trans %2
	set color_bg=!color_new!
	call ::color-trans %3
	set color_fg=!color_new!
	set text=%1

	call ::display
)
if "%4"=="file" (
	if not exist %1 set invalid=1
	call ::color-trans %2
	set color_bg=!color_new!
	call ::color-trans %3
	set color_fg=!color_new!
	set filename=%1
	for /f "tokens=1* usebackq" %%G in (!filename!) do (
		set text=%%G %%H
		call :display
	)
)
exit /b




::Call powershell to display the line. All the colors has been converted so write-host can read it properly.
:display
if "%invalid%"=="1" exit /b
powershell write-host -back %color_bg% -fore %color_fg% %text%
exit /b

::Cheap ones used for simple self calls.
:display-red
powershell write-host -back Black -fore Red %1
exit /b

:display-yellow
powershell write-host -back Black -fore Yellow %1
exit /b





::Transform the hex value of the color into a valid value for write-host.
:color-trans
if /i "%1"=="0" (
	set color_new=Black
	exit /b
)
if /i "%1"=="1" (
	set color_new=DarkBlue
	exit /b
)
if /i "%1"=="2" (
	set color_new=DarkGreen
	exit /b
)
if /i "%1"=="3" (
	set color_new=DarkCyan
	exit /b
)
if /i "%1"=="4" (
	set color_new=DarkRed
	exit /b
)
if /i "%1"=="5" (
	set color_new=DarkMagenta
	exit /b
)
if /i "%1"=="6" (
	set color_new=DarkYellow
	exit /b
)
if /i "%1"=="7" (
	set color_new=Gray
	exit /b
)
if /i "%1"=="8" (
	set color_new=DarkGray
	exit /b
)
if /i "%1"=="9" (
	set color_new=Blue
	exit /b
)
if /i "%1"=="a" (
	set color_new=Green
	exit /b
)
if /i "%1"=="b" (
	set color_new=Cyan
	exit /b
)
if /i "%1"=="c" (
	set color_new=Red
	exit /b
)
if /i "%1"=="d" (
	set color_new=Magenta
	exit /b
)
if /i "%1"=="e" (
	set color_new=Yellow
	exit /b
)
if /i "%1"=="f" (
	set color_new=White
	exit /b
)
call :display-red "`'%1`' is not a valid color value."
set invalid=1
exit /b 1





:help
echo:
call :display-red "-------------------------------------------------------------------------------------------"
call :display-yellow "Displays text in one line with different colors. Can also print files."
call :display-yellow "By DarviL. Using version %ver%."
echo:
call :display-yellow "ECHOC [TYPE] [CONTENT] [COLOR-BG] [COLOR-FG]"
echo:
echo   TYPE       -s : Displays a normal string.
echo              -f : Displays a file's content.
echo:
echo   CONTENT       : Select the file/string to be displayed.
echo:
echo   COLOR      BG : Select the color to be displayed on the background
echo                   of the line. [0-F]
echo              FG : Select the color to be displayed on the foreground
echo                   of the line (color of the text). [0-F]
echo:
echo:
echo   - To see all the available colors, check 'color /?'.
echo   - This function uses Windows PowerShell 'write-host' module in order to work.
echo   - It is possible that at the first time it will take more time due to the delay
echo     that PowerShell has.
echo   - Remember to use 'cmd /c' before this command if used in a batch file.
call :display-red "-------------------------------------------------------------------------------------------"
exit /b