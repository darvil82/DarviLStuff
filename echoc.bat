::Script to display text in one line with different colors. Can also print lines of files. Written by DarviL. (David Losantos)

@echo off
setlocal EnableDelayedExpansion

set ver=2.6.1-2
set /a build=25

set parm1=%1
set parm2=%2
set parm3=%3
set parm4=%4
set parm5=%5
set parm6=%6

set color_fg=
set color_bg=
set color_new=




if /i "!parm1!"=="/S" (
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

if /i "!parm1!"=="/F" (
	if not defined parm2 call :error-parm filename & exit /b
	set filename=!parm2:"=!
	set /a count=0
	if not exist "!filename!" call :display red "The file '!filename!' doesn't exist." & exit /b 1
	if defined parm3 (
		call ::color-trans !parm3! bg
		set color_bg=!color_new!
	)
	if defined parm4 (
		call ::color-trans !parm4! fg
		set color_fg=!color_new!
	)
	if not !invalid!==1 (
		if defined parm5 (
			if /i "!parm5!"=="/a" (
				if not defined color_bg if not defined color_fg type "!filename!" & exit /b 0
				for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
					set "text=%%G"
					call :display
				)
			) else (
				if /i "!parm6!"=="/a" (
					for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
						if !parm5!==!count! exit /b 0
						set /a count+=1
						set "text=%%G"
						call :display
					)
				) else (
					< nul set /p"=!color_bg!!color_fg!" > "%temp%\.tmp"
					for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
						if !parm5!==!count! (
							< nul set /p"=[0m" >> "%temp%\.tmp"
							type "%temp%\.tmp"
							exit /b
						)
						set /a count+=1
						echo %%G >> "%temp%\.tmp"
					)
				)
			)
		) else (
			< nul set /p"=!color_bg!!color_fg!" > "%temp%\.tmp"
			type "!filename!" >> "%temp%\.tmp"
			< nul set /p"=[0m" >> "%temp%\.tmp"
			type "%temp%\.tmp"
		)
	)
	exit /b 0
)

if /i "!parm1!"=="/T" (
	if defined parm2 (
		if /i "!parm2!"=="/r" < nul set /p"=[0m" & exit /b 0
		call ::color-trans !parm2! bg
		set color_bg=!color_new!
	) else call :error-parm color-bg
	if defined parm3 (
		call ::color-trans !parm3! fg
		set color_fg=!color_new!
	) else call :error-parm color-fg
	if not !invalid!==1 (
		if defined color_bg < nul set /p"=!color_bg!!color_fg!" & exit /b 0
		if defined color_fg < nul set /p"=!color_bg!!color_fg!" & exit /b 0
	)
	exit /b 1
)

if /i "!parm1!"=="/P" (
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

if /i "!parm1!"=="/Z" (
	if not defined parm2 call :error-parm string & exit /b 1
	set text=!parm2:"=!
	set text=!text:\\={BACKSLASH}!
	set text=!text:\r=[0m!
	
	::Parse foreground
	set text=!text:\f0=[30m!
	set text=!text:\f1=[34m!
	set text=!text:\f2=[32m!
	set text=!text:\f3=[36m!
	set text=!text:\f4=[31m!
	set text=!text:\f5=[35m!
	set text=!text:\f6=[33m!
	set text=!text:\f7=[37m!
	set text=!text:\f8=[90m!
	set text=!text:\f9=[94m!
	set text=!text:\fa=[92m!
	set text=!text:\fb=[96m!
	set text=!text:\fc=[91m!
	set text=!text:\fd=[95m!
	set text=!text:\fe=[93m!
	set text=!text:\ff=[97m!
	::Parse background
	set text=!text:\b0=[40m!
	set text=!text:\b1=[44m!
	set text=!text:\b2=[42m!
	set text=!text:\b3=[46m!
	set text=!text:\b4=[41m!
	set text=!text:\b5=[45m!
	set text=!text:\b6=[43m!
	set text=!text:\b7=[47m!
	set text=!text:\b8=[100m!
	set text=!text:\b9=[104m!
	set text=!text:\ba=[102m!
	set text=!text:\bb=[106m!
	set text=!text:\bc=[101m!
	set text=!text:\bd=[105m!
	set text=!text:\be=[103m!
	set text=!text:\bf=[107m!
	
	set text=!text:{BACKSLASH}=\!
	
	echo !text![0m
	exit /b 0
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
		set /p "chkup_in=Select a destination folder to download ECHOC in. ['%~d1%~p0'] "
		if not defined chkup_in set chkup_in=%~d1%~p0
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
set parm1=!parm1:"=!
call :display red "Unexpected '!parm1!' parameter." & echo Use "echoc /?" to read the help. & exit /b 1

:error-parm
call :display red "Parameter [%1] is not defined."
set invalid=1
exit /b 1




::Build the echo command to display the formatted text line. 'red' and 'green' conditionals are just for self calls.
:display
if "!invalid!"=="1" exit /b 1

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
echo Script that allows the user to display more than 2 different colors on the screen
echo ^(foreground and background^), supporting displaying normal strings, content of files, and also changing
echo the colors that the CLI is using at the moment.
echo [90mWritten by DarviL (David Losantos) in batch. Using version !ver! (Build !build!)[0m
echo:
echo [96mECHOC[0m [33m/S [93mstring [COLOR] [0m^| [33m/F [93mfilename [COLOR] [LINES] [/A] [0m^| [33m/T [93mCOLOR [/R] [0m^| [33m/P [93mstring [COLOR] [0m^|
echo       [33m/Z [93mstring[0m
echo:
echo   [33m/S :[0m Displays the following selected string.
echo   [33m/F :[0m Displays the content of the following file specified. Specifying the [93m[LINES][0m value will select
echo        the number of lines that will be displayed. If '[93m/A[0m' is specified, every line of the file will be
echo        processed, meaning that it will take more time to process, but it will apply colors to only text,
echo        and not empty characters. Mostly useful when displaying background colors.
echo   [33m/T :[0m Toggles the color that is being used at the moment. Not recommended for the background.
echo        Following this parameter with '[93m/R[0m' will reset the current colors back to normal.
echo   [33m/P :[0m Uses PowerShell instead of ANSI escape codes. Especial characters must be escaped.
echo   [33m/Z :[0m Use the advanced formatted mode for displaying strings. In order to change the colors, use the
echo        custom escape character like so: '[93m\f^<fg_HEX^>[0m' ^(foreground^) or '[93m\b^<bg_HEX^>[0m' ^(background^). You can
echo        also use '[93m\R[0m' to reset it, although, it is automatically resetted at the end. Use a double
echo        backslash ^(\\^) in case it is needed to escape it. This mode allows the use of multi-colored lines.
echo:
echo:
echo   [93mCOLOR      BG :[0m Select the color to be displayed on the background of the line in hex.
echo                   Using "-" or nothing will display the current color of the background.
echo              [93mFG :[0m Select the color to be displayed on the foreground of the line in hex. (color of the text)
echo                   Using "-" or nothing will display the current color of the foreground.
echo:
echo:
echo:
echo   Examples      : '[96mECHOC [33m/S [93m"What's up?" - 3'[0m
echo                      Display the string "What's up?" using the current color
echo                      of the background, and using aquamarine color for the foreground.
echo                 : '[96mECHOC [33m/F [93m"./test/notes.txt" 0 a 32'[0m
echo                      Display the first 32 lines of the file "./test/notes.txt" using a black color 
echo                      for the background and a green color for the foreground.
echo                 : '[96mECHOC [33m/Z [93m"\fcThis text is red, \b1and this background is blue."'[0m
echo                      Display "This text is red," with a red foreground, and "and this background is blue."
echo                      with a dark blue background.
echo:
echo   - Available color values:
echo     - 0 1 2 3 4 5 6 7 8 9 a b c d e f
echo       [40m[30m  [44m[34m  [42m[32m  [46m[36m  [41m[31m  [45m[35m  [43m[33m  [47m[37m  [100m[90m  [94m[104m  [102m[92m  [96m[106m  [101m[91m  [105m[95m  [103m[93m  [107m[97m  [40m[30m[0m
echo   - '[96mECHOC [33m/CHKUP[0m' will check for updates. If it finds a newer version, it will ask for a folder to
echo     download ECHOC in. Pressing ENTER without entering a path will select the default option, wich is the
echo     folder that contains the currently running script, overriding the old version.
echo   - Use 'CMD /C' before this script if used in a batch file.
exit /b 0