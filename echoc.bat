::Script to display text in one line with different colors. Can also print lines of files. Written by DarviL. (David Losantos)

@echo off
setlocal EnableDelayedExpansion

set ver=2.4.1
set /a build=15

set parm1=%1
set parm2=%2
set parm3=%3
set parm4=%4
set parm5=%5

set color_fg=
set color_bg=
set color_new=




if /i "!parm1!"=="/s" (
	if not defined parm2 call :error-parm string
	if defined parm3 (
		call ::color-trans !parm3! bg
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans !parm4! fg
		set color_fg=!color_new!
	)
	set text=!parm2!

	call :display
	exit /b
)

if /i "!parm1!"=="/f" (
	if not defined parm2 call :error-parm filename & exit /b
	set filename=!parm2:"=!
	if not exist "!filename!" call :display red "The file '!filename!' doesn't exist." & exit /b 1
	if defined parm3 (
		call ::color-trans !parm3! bg
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans !parm4! fg
		set color_fg=!color_new!
	)
	if defined parm5 set /a count=0
	for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
		if defined parm5 (
			if !parm5!==!count! exit /b
			set /a count+=1
		)
		set "text=%%G %%H"
		call :display
	)
	exit /b
)

if /i "!parm1!"=="/t" (
	if defined parm2 (
		if /i "!parm2!"=="/r" <nul set /p"=[0m" & exit /b 0
		call ::color-trans !parm2! bg
		set color_bg=!color_new!
	) else call :error-parm color-bg
	if defined parm3 (
		call ::color-trans !parm3! fg
		set color_fg=!color_new!
	) else call :error-parm color-fg
	if not !invalid!==1 (
		if defined color_bg <nul set /p"=!color_bg!!color_fg!" & exit /b 0
		if defined color_fg <nul set /p"=!color_bg!!color_fg!" & exit /b 0
	)
	exit /b 1
)

if /i "!parm1!"=="/p" (
	if not defined parm2 call :error-parm string
	if defined parm3 (
		call ::color-trans !parm3! ps
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans !parm4! ps
		set color_fg=!color_new!
	)
	set text=!parm2!

	call :display ps
	exit /b
)

if /i "!parm1!"=="/CHKUP" (
	echo Checking for new updates...
	ping github.com /n 1 > nul
	if %errorlevel% == 1 call :display red "Unable to connect to GitHub." & exit /b 1
	bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/versions" "%temp%\versions" > nul
	find "echoc" "%temp%\versions" > "%temp%\versions_s"
	for /f "skip=2 tokens=3* usebackq" %%G in ("%temp%\versions_s") do set /a build_gh=%%G
	if !build_gh! GTR !build! (
		call :display green "Found a new version."
		echo   Using build: !build!
		echo   Latest build: !build_gh!
		echo:
		set /p "chkup_in=Select a destination folder to download ECHOC in. (ENTER to select the current directory) "
		if not defined chkup_in set chkup_in=!cd!
		set chkup_in=!chkup_in:"=!
		set chkup_in=!chkup_in:/=\!
		if not exist "!chkup_in!\" (
			call :display red "The folder '!chkup_in!' doesn't exist. Download aborted."
			exit /b 1
		) else (
			echo Downloading...
			bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/echoc.bat" "!chkup_in!\echoc.bat" > nul
			if not !errorlevel! == 0 call :display red "An error occurred while trying to download ECHOC." & exit /b 1
			call :display green "Downloaded ECHOC succesfully in '!chkup_in!'."
			exit /b 0
		)
	) else call :display green "Using latest version."
	exit /b 0
)

if /i "!parm1!"=="/?" goto help

if not defined parm1 call :display red "No parameters were defined." & echo Use "echoc /?" to read the help. & exit /b 1
call :display red "Unexpected '!parm1!' parameter." & echo Use "echoc /?" to read the help. & exit /b 1

:error-parm
call :display red "Parameter [%1] is not defined."
set invalid=1
exit /b 1




::Build the echo command to display the formatted text line. 'red' and 'green' conditionals are just for self calls.
:display
if "!invalid!"=="1" (
	if not defined err_shown (
		echo An error occurred while trying to display the line. & echo Use "echoc /?" to read the help.
		set err_shown=1
		exit /b 1
	)
	exit /b 1
)

if "%1"=="ps" (
	if not defined color_bg (
		set cfg1=
	) else set cfg1=-back !color_bg!
	if not defined color_fg (
		set cfg2=
	) else set cfg2=-fore !color_fg!
	powershell write-host !cfg1! !cfg2! !text!
	exit /b 0
)

if "%1"=="red" (
	set text=%2
	set color_fg=[91m
	set color_bg=
)
if "%1"=="green" (
	set text=%2
	set color_fg=[92m
	set color_bg=
)


::Escape special characters.
set text=%text:"=%
set text=%text:(=^(%
set text=%text:)=^)%

echo !color_bg!!color_fg!!text![0m
exit /b 0





::Transform the hex value of the color into the corresponding ANSI escape code.
:color-trans
if "%2"=="fg" (
	if /i "%1"=="-" set color_new=&				exit /b
	if /i "%1"=="0" set color_new=[30m&		exit /b
	if /i "%1"=="1" set color_new=[34m&		exit /b
	if /i "%1"=="2" set color_new=[32m&		exit /b
	if /i "%1"=="3" set color_new=[36m&		exit /b
	if /i "%1"=="4" set color_new=[31m&		exit /b
	if /i "%1"=="5" set color_new=[35m&		exit /b
	if /i "%1"=="6" set color_new=[33m&		exit /b
	if /i "%1"=="7" set color_new=[37m&		exit /b
	if /i "%1"=="8" set color_new=[90m&		exit /b
	if /i "%1"=="9" set color_new=[94m&		exit /b
	if /i "%1"=="a" set color_new=[92m&		exit /b
	if /i "%1"=="b" set color_new=[96m&		exit /b
	if /i "%1"=="c" set color_new=[91m&		exit /b
	if /i "%1"=="d" set color_new=[95m&		exit /b
	if /i "%1"=="e" set color_new=[93m&		exit /b
	if /i "%1"=="f" set color_new=[97m&		exit /b
) else if "%2"=="bg" (
	if /i "%1"=="-" set color_new=&				exit /b
	if /i "%1"=="0" set color_new=[40m&		exit /b
	if /i "%1"=="1" set color_new=[44m&		exit /b
	if /i "%1"=="2" set color_new=[42m&		exit /b
	if /i "%1"=="3" set color_new=[46m&		exit /b
	if /i "%1"=="4" set color_new=[41m&		exit /b
	if /i "%1"=="5" set color_new=[45m&		exit /b
	if /i "%1"=="6" set color_new=[43m&		exit /b
	if /i "%1"=="7" set color_new=[47m&		exit /b
	if /i "%1"=="8" set color_new=[100m&		exit /b
	if /i "%1"=="9" set color_new=[104m&		exit /b
	if /i "%1"=="a" set color_new=[102m&		exit /b
	if /i "%1"=="b" set color_new=[106m&		exit /b
	if /i "%1"=="c" set color_new=[101m&		exit /b
	if /i "%1"=="d" set color_new=[105m&		exit /b
	if /i "%1"=="e" set color_new=[103m&		exit /b
	if /i "%1"=="f" set color_new=[107m&		exit /b
) else if "%2"=="ps" (
	if /i "%1"=="-" set color_new=&				exit /b
	if /i "%1"=="0" set color_new=Black&		exit /b
	if /i "%1"=="1" set color_new=DarkBlue&		exit /b
	if /i "%1"=="2" set color_new=DarkGreen&	exit /b
	if /i "%1"=="3" set color_new=DarkCyan&		exit /b
	if /i "%1"=="4" set color_new=DarkRed&		exit /b
	if /i "%1"=="5" set color_new=DarkMagenta&	exit /b
	if /i "%1"=="6" set color_new=DarkYellow&	exit /b
	if /i "%1"=="7" set color_new=Gray&			exit /b
	if /i "%1"=="8" set color_new=DarkGray&		exit /b
	if /i "%1"=="9" set color_new=Blue&			exit /b
	if /i "%1"=="a" set color_new=Green&		exit /b
	if /i "%1"=="b" set color_new=Cyan&			exit /b
	if /i "%1"=="c" set color_new=Red&			exit /b
	if /i "%1"=="d" set color_new=Magenta&		exit /b
	if /i "%1"=="e" set color_new=Yellow&		exit /b
	if /i "%1"=="f" set color_new=White&		exit /b
)

call :display red "'%1' is not a valid color value."
set invalid=1
exit /b 1





:help
echo Script that displays text in one line with different colors. Can also print the content of files.
echo This is done by using ANSI color escape codes, and using them in various ways for displaying content.
echo Written by DarviL (David Losantos) in batch. Using version !ver! (Build !build!)
echo:
echo ECHOC /S string [COLOR] ^| /F filename [COLOR] [LINES] ^| /T COLOR [/R] ^| /P string [COLOR]
echo:
echo   /S : Displays the following selected string.
echo   /F : Displays the content of the following file specified.
echo   /T : Toggles the color that is being used at the moment. Not recommended for the background.
echo        Following this parameter with '/R' will reset the current colors back to normal.
echo   /P : Uses PowerShell instead of ANSI escape codes. Especial characters must be escaped.
echo:
echo:
echo   COLOR      BG : Select the color to be displayed on the background of the line in hex.
echo                   Using "-" or nothing will display the current color of the background.
echo              FG : Select the color to be displayed on the foreground of the line in hex. (color of the text)
echo                   Using "-" or nothing will display the current color of the foreground.
echo:
echo   [LINES]       : Only useful when displaying files. Select the number of text lines to be
echo                   displayed on screen.
echo:
echo:
echo:
echo   Examples      : 'echoc /s "What's up?" - 3'
echo                   Display the string "What's up?" using the current color
echo                   of the background, and using aquamarine color for the foreground.
echo                 : 'echoc /f "./test/notes.txt" 0 a 32'
echo                   Display the first 32 lines of the file "./test/notes.txt" using a
echo                   black color for the background and a green color for the foreground.
echo                 : 'echoc /t - b'
echo                   Toggles the color of the text in the CLI to bright aquamarine.
echo:
echo   - Available color values:
echo     - 0 1 2 3 4 5 6 7 8 9 a b c d e f
echo       [40m[30m  [44m[34m  [42m[32m  [46m[36m  [41m[31m  [45m[35m  [43m[33m  [47m[37m  [100m[90m  [94m[104m  [102m[92m  [96m[106m  [101m[91m  [105m[95m  [103m[93m  [107m[97m  [40m[30m[0m
echo   - 'echoc /CHKUP' will check for updates. If it finds a newer version, it will ask for a
echo     folder to download it in.
echo   - Use 'cmd /c' before this command if used in a batch file.
exit /b 0