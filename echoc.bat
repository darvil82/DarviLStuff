::function to display text in one line with different colors. Can also print files. By DarviL.

@echo off
setlocal EnableDelayedExpansion

set ver=1.4

set parm1=%1
set parm2=%2
set parm3=%3
set parm4=%4
set parm5=%5

set color_fg=
set color_bg=
set color_new=

if not exist "%temp%/echoc_pschecked" (
	reg query HKLM\SOFTWARE\Microsoft\PowerShell\1 /v Install | find "Install    REG_DWORD    0x1" >nul
	if !errorlevel!==1 (
		echo PowerShell isn't installed. ECHOC requires PS to work.
		exit /b
	) else type nul > "%temp%/echoc_pschecked"
)





if /i "%parm1%"=="-s" (
	if not defined parm2 call :error-parm CONTENT

	if defined parm3 (
		call ::color-trans %parm3%
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans %parm4%
		set color_fg=!color_new!
	)
	set text=%parm2%

	call :display
	exit /b
)

if /i "%parm1%"=="-f" (
	if not defined parm2 call :error-parm CONTENT
	
	if not exist "%parm2%" set invalid=1
	if defined parm3 (
		call ::color-trans %parm3%
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans %parm4%
		set color_fg=!color_new!
	)
	if defined parm5 set /a count=0
	set filename=%parm2%
	for /f "tokens=1* usebackq" %%G in (!filename!) do (
		if defined parm5 (
			if !parm5!==!count! exit /b
			set /a count=!count!+1
		)
		set text=%%G %%H
		call :display
	)
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






::Call powershell to display the line. All the colors has been converted so write-host can read it properly.
:display
if "%invalid%"=="1" exit /b
::Escape special characters
set text=%text:(=`(%
set text=%text:)=`)%

if defined color_bg (
	set display_color_bg=-back %color_bg%
) else set "display_color_bg="

if defined color_fg (
	set display_color_fg=-fore %color_fg%
) else set "display_color_fg="


powershell write-host %display_color_bg% %display_color_fg% %text%
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
if /i "%1"=="-" (
	set color_new=
	exit /b
)
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
echo Displays text in one line with different colors. Can also print files.
echo By DarviL. Using version %ver%.
echo:
echo ECHOC TYPE CONTENT [COLOR-BG] [COLOR-FG] [LINES]
echo:
echo   TYPE       -s : Displays a normal string.
echo              -f : Displays a file's content.
echo:
echo   CONTENT       : Select the file/string to be displayed.
echo:
echo   [COLOR]    BG : Select the color to be displayed on the background
echo                   of the line.
echo                   Using "-" or nothing will display the current color of the background.
echo:
echo              FG : Select the color to be displayed on the foreground
echo                   of the line. (color of the text)
echo                   Using "-" or nothing will display the current color of the foreground.
echo:
echo   [LINES]       : Only useful when displaying files. Select the number of text lines to be
echo                   displayed on screen.
echo:
echo:
echo:
echo   Examples      : 'echoc -s "Hello, how are you?" - 3'
echo                   Display the string "Hello, how are you?" using the current color
echo                   of the background, and using aquamarine color for the foreground.
echo:
echo                   'echoc -f "./test/notes.txt" 0 a 32'
echo                   Display the first 32 lines of the file "./test/notes.txt" using a
echo                   black color for the background and a green color for the foreground.
echo:
echo:
echo   - To see all the available colors, check 'color /?'.
echo   - This function uses Windows PowerShell 'write-host' module in order to work.
echo   - It is possible that at the first time it will take more time due to the delay
echo     that PowerShell has.
echo   - Use 'cmd /c' before this command if used in a batch file.
exit /b
