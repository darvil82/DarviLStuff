::Script to display text in one line with different colors. Can also print lines of files. Written by DarviL. (David Losantos)

@echo off
setlocal EnableDelayedExpansion

set ver=2.11.5-2
set /a build=52

if /i "%1"=="/?" goto help

set /a parm_count=1
for %%G in (%*) do (
	set parm!parm_count!=%%G
	set /a parm_count+=1
)




if /i "!parm1!"=="/S" (
	if not defined parm2 call :error-parm string
	if defined parm3 (
		call :color-trans !parm3! bg
		set color_bg=!color_new!
	)
	if defined parm4 (
		call :color-trans !parm4! fg
		set color_fg=!color_new!
	)
	set "text=!parm2:"=!"
	if /i "!parm5!"=="/u" set text=[4m!text!
	call :display
	exit /b
)

if /i "!parm1!"=="/F" (
	if not defined parm2 call :error-parm filename & exit /b
	set filename=!parm2:"=!
	set /a count=0
	if not exist "!filename!" call :display red "The file '!filename!' doesn't exist." & exit /b 1
	if defined parm3 (
		call :color-trans !parm3! bg
		set color_bg=!color_new!
	)
	if defined parm4 (
		call :color-trans !parm4! fg
		set color_fg=!color_new!
	)
	
	
	if not !invalid!==1 (
		set t_extra=
		for %%G in (!parm5! !parm6! !parm7! !parm8!) do (
			if /i "%%G"=="/u" set t_extra=[4m!t_extra!
			if /i "%%G"=="/l" set show_lines=1
			if /i "%%G"=="/a" set process_all=1
			if /i "%%G"=="/v" set verbose=1
			
			set /a file_lines=%%G 2> nul
		)
		
		if defined process_all (
			if defined file_lines (
				for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
					if !file_lines!==!count! exit /b 0
					set /a count+=1
					if defined show_lines (set "text=!count!:	!t_extra!%%G") else (set "text=!t_extra!%%G")
					call :display
				)
				exit /b 0
				
			) else (
				for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
					set /a count+=1
					if defined show_lines (set "text=!count!:	!t_extra!%%G") else (set "text=!t_extra!%%G")
					call :display
				)
				exit /b 0
			)
		) else (
			if defined file_lines (
				if defined verbose < nul set /p"=Processing lines"
				< nul set /p"=!t_extra!!color_bg!!color_fg!" > "%temp%\.tmp"
				for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
					if !file_lines!==!count! (
						if defined verbose < nul set /p"=Done" & echo: & echo:
						
						< nul set /p"=[0m" >> "%temp%\.tmp"
						type "%temp%\.tmp"
						exit /b 0
					)
					set /a count+=1
					if defined show_lines (echo !count!:	!t_extra!%%G >> "%temp%\.tmp") else (echo !t_extra!%%G >> "%temp%\.tmp")
					
					if defined verbose < nul set /p"=."
				)
				if defined verbose < nul set /p"=Done" & echo: & echo:
				
				< nul set /p"=[0m" >> "%temp%\.tmp"
				type "%temp%\.tmp"
				exit /b 0
				
			) else (
				if defined show_lines (
					if defined verbose < nul set /p"=Processing lines"
					< nul set /p"=!t_extra!!color_bg!!color_fg!" > "%temp%\.tmp"
					for /f "delims= tokens=1* usebackq" %%G in ("!filename!") do (
						set /a count+=1
						echo !count!:	!t_extra!%%G >> "%temp%\.tmp"
						
						if defined verbose < nul set /p"=."
					)
					if defined verbose < nul set /p"=Done" & echo: & echo:
				
					< nul set /p"=[0m" >> "%temp%\.tmp"
					type "%temp%\.tmp"
					exit /b 0
				) else (
					< nul set /p"=!t_extra!!color_bg!!color_fg!" > "%temp%\.tmp"
					type "!filename!" >> "%temp%\.tmp"
					< nul set /p"=[0m" >> "%temp%\.tmp"
					type "%temp%\.tmp"
					exit /b 0
				)
			)
		)
	)
	exit /b 1
)

if /i "!parm1!"=="/T" (
	if defined parm2 (
		if /i "!parm2!"=="/r" < nul set /p"=[0m" & exit /b 0
		call :color-trans !parm2! bg
		set color_bg=!color_new!
	) else call :error-parm color-bg & exit /b 1
	if defined parm3 (
		call :color-trans !parm3! fg
		set color_fg=!color_new!
	) else call :error-parm color-fg & exit /b 1
	
	if /i "!parm4!"=="/u" set t_extra=[4m
	< nul set /p"=!t_extra!!color_bg!!color_fg!" & exit /b 0
	exit /b 1
)

if /i "!parm1!"=="/P" (
	if not defined parm2 call :error-parm string
	if defined parm3 (
		call :color-trans !parm3! ps
		set color_bg=!color_new!
	)
	if defined parm4 (
		call :color-trans !parm4! ps
		set color_fg=!color_new!
	)
	set "text=!parm2!"
	call :display ps
	exit /b
)

if /i "!parm1!"=="/Z" (
	if not defined parm2 call :error-parm string & exit /b 1
	set text=!parm2:"=!
	set text=!text:\\={BACKSLASH}!
	set text=!text:\r=[0m!
	set text=!text:\u=[4m!
	set text=!text:\nu=[24m!
	
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
	::Check if the user is using windows 1909 at least
	<nul set /p =Checking Windows build... 
	ver > "%temp%\.tmp"
	for /f "usebackq skip=1 tokens=4 delims=[]. " %%G in ("%temp%\.tmp") do set /a ver_windows=%%G
	wmic os get BuildNumber | sort /r > "%temp%\.tmp"
	for /f "skip=1 tokens=1* usebackq" %%G in ("%temp%\.tmp") do set /a build_windows=%%G 2> nul
	
	if !ver_windows!==10 (
		if !build_windows! GEQ 1909 (
			call :display green "Using Windows 10 !build_windows!, with color support."
		) else echo Windows 10 1909 or higher is required for using this script.
	) else echo Windows 10 1909 or higher is required for using this script.
	
	
	::Check if the user has PowerShell installed.
	<nul set /p =Checking PowerShell... 
	powershell $PSVersionTable.PSVersion > nul
	if not !errorlevel!==0 (
		call :display red "PowerShell isn't installed. Altough, it isn't required."
	) else call :display green "PowerShell is installed."
	

	::Check for updates of ECHOC.
	<nul set /p =Checking for new versions of ECHOC... 
	ping github.com /n 1 > nul
	if %errorlevel% == 1 call :display red "Unable to connect to GitHub." & exit /b 1
	bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/versions" "%temp%\.tmp" > nul
	find "echoc" "%temp%\.tmp" > "%temp%\.tmp2"
	for /f "skip=2 tokens=3* usebackq" %%G in ("%temp%\.tmp2") do set /a build_gh=%%G
	if !build_gh! GTR !build! (
		call :display red "Found a new version. (Using build: !build!. Latest build: !build_gh!)"
		echo:
		set /p "chkup_in=Select a destination folder to download ECHOC in. ['%~d0%~p0'] "
		if not defined chkup_in set chkup_in=%~d0%~p0
		set chkup_in=!chkup_in:"=!
		set chkup_in=!chkup_in:/=\!
		
		<nul set /p =Downloading... 
		if not exist "!chkup_in!\" (
			call :display red "The folder '!chkup_in!' doesn't exist. Download aborted."
			exit /b 1
		) else (
			bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/echoc.bat" "!chkup_in!\echoc.bat" > nul
			if not !errorlevel! == 0 call :display red "An error occurred while trying to download ECHOC." & exit /b 1
			call :display green "Downloaded ECHOC succesfully in '!chkup_in!'."
			exit /b 0
		)
	) else call :display green "Using latest build."
	exit /b 0
)

if not defined parm1 call :display red "No arguments were defined." & echo Use "ECHOC /?" to read the help. & exit /b 1
set parm1=!parm1:"=!
call :display red "Unexpected '!parm1!' argument." & echo Use "ECHOC /?" to read the help. & exit /b 1

:error-parm
call :display red "Argument [%1] is not defined."
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
	set text=!text:"=!
	set color_fg=[91m
	set color_bg=
)
if "%1"=="green" (
	set text=%2
	set text=!text:"=!
	set color_fg=[92m
	set color_bg=
)


echo !color_bg!!color_fg!!text![0m
exit /b 0





::Transform the hex value of the color into the corresponding ANSI escape code.
:color-trans
set ct_P1=%1
set ct_P2=%2
set ct_P1=!ct_P1:"=!
set ct_P2=!ct_P2:"=!

if "!ct_P2!"=="fg" (
	if /i "!ct_P1!"=="-" set color_new=&				exit /b
	if /i "!ct_P1!"=="0" set color_new=[30m&			exit /b
	if /i "!ct_P1!"=="1" set color_new=[34m&			exit /b
	if /i "!ct_P1!"=="2" set color_new=[32m&			exit /b
	if /i "!ct_P1!"=="3" set color_new=[36m&			exit /b
	if /i "!ct_P1!"=="4" set color_new=[31m&			exit /b
	if /i "!ct_P1!"=="5" set color_new=[35m&			exit /b
	if /i "!ct_P1!"=="6" set color_new=[33m&			exit /b
	if /i "!ct_P1!"=="7" set color_new=[37m&			exit /b
	if /i "!ct_P1!"=="8" set color_new=[90m&			exit /b
	if /i "!ct_P1!"=="9" set color_new=[94m&			exit /b
	if /i "!ct_P1!"=="a" set color_new=[92m&			exit /b
	if /i "!ct_P1!"=="b" set color_new=[96m&			exit /b
	if /i "!ct_P1!"=="c" set color_new=[91m&			exit /b
	if /i "!ct_P1!"=="d" set color_new=[95m&			exit /b
	if /i "!ct_P1!"=="e" set color_new=[93m&			exit /b
	if /i "!ct_P1!"=="f" set color_new=[97m&			exit /b
) else if "!ct_P2!"=="bg" (
	if /i "!ct_P1!"=="-" set color_new=&				exit /b
	if /i "!ct_P1!"=="0" set color_new=[40m&			exit /b
	if /i "!ct_P1!"=="1" set color_new=[44m&			exit /b
	if /i "!ct_P1!"=="2" set color_new=[42m&			exit /b
	if /i "!ct_P1!"=="3" set color_new=[46m&			exit /b
	if /i "!ct_P1!"=="4" set color_new=[41m&			exit /b
	if /i "!ct_P1!"=="5" set color_new=[45m&			exit /b
	if /i "!ct_P1!"=="6" set color_new=[43m&			exit /b
	if /i "!ct_P1!"=="7" set color_new=[47m&			exit /b
	if /i "!ct_P1!"=="8" set color_new=[100m&		exit /b
	if /i "!ct_P1!"=="9" set color_new=[104m&		exit /b
	if /i "!ct_P1!"=="a" set color_new=[102m&		exit /b
	if /i "!ct_P1!"=="b" set color_new=[106m&		exit /b
	if /i "!ct_P1!"=="c" set color_new=[101m&		exit /b
	if /i "!ct_P1!"=="d" set color_new=[105m&		exit /b
	if /i "!ct_P1!"=="e" set color_new=[103m&		exit /b
	if /i "!ct_P1!"=="f" set color_new=[107m&		exit /b
) else if "!ct_P2!"=="ps" (
	if /i "!ct_P1!"=="-" set color_new=&				exit /b
	if /i "!ct_P1!"=="0" set color_new=Black&			exit /b
	if /i "!ct_P1!"=="1" set color_new=DarkBlue&		exit /b
	if /i "!ct_P1!"=="2" set color_new=DarkGreen&		exit /b
	if /i "!ct_P1!"=="3" set color_new=DarkCyan&		exit /b
	if /i "!ct_P1!"=="4" set color_new=DarkRed&			exit /b
	if /i "!ct_P1!"=="5" set color_new=DarkMagenta&		exit /b
	if /i "!ct_P1!"=="6" set color_new=DarkYellow&		exit /b
	if /i "!ct_P1!"=="7" set color_new=Gray&			exit /b
	if /i "!ct_P1!"=="8" set color_new=DarkGray&		exit /b
	if /i "!ct_P1!"=="9" set color_new=Blue&			exit /b
	if /i "!ct_P1!"=="a" set color_new=Green&			exit /b
	if /i "!ct_P1!"=="b" set color_new=Cyan&			exit /b
	if /i "!ct_P1!"=="c" set color_new=Red&				exit /b
	if /i "!ct_P1!"=="d" set color_new=Magenta&			exit /b
	if /i "!ct_P1!"=="e" set color_new=Yellow&			exit /b
	if /i "!ct_P1!"=="f" set color_new=White&			exit /b
)

call :display red "'!ct_P1!' is not a valid color value."
set invalid=1
exit /b 1





:help
echo Script that allows the user to display more than 2 different colors on the screen
echo ^(foreground and background^), supporting displaying normal strings, content of files, and also changing
echo the colors that the CLI is using at the moment.
echo [90mWritten by DarviL (David Losantos) in batch. Using version !ver! (Build !build!)
echo Repository available at: "[4mhttps://github.com/L89David/DarviLStuff[24m"[0m
echo:
echo [96mECHOC[0m [33m/S [93mstring [COLOR] [/U] [0m^| [33m/F [93mfilename [COLOR] [LINES] [/A] [/U] [/V] [/L] [0m^| [33m/T [93m(COLOR [/U] ^| /R) [0m^| 
echo       [33m/P [93mstring [COLOR] [0m^| [33m/Z [93mstring[0m 
echo:
echo   [33m/S :[0m Displays the following selected string. If '[93m/U[0m' is specified after selecting the color, an underline
echo        will be applied.
echo   [33m/F :[0m Displays the content of the following file specified. Specifying the [93m[LINES][0m value will select
echo        the number of lines that will be displayed. If '[93m/A[0m' is specified, every line of the file will be
echo        processed, meaning that it will take more time to process, but it will apply colors to only text,
echo        and not empty characters. Mostly useful when displaying background colors. If '[93m/V[0m' is specified when
echo        having a [93m[LINES][0m value set, a dot will appear for every line of the file that has been processed.
echo        '[93m/L[0m' will show the number of every line displayed.
echo   [33m/T :[0m Toggles the color that is being used at the moment. Not recommended for the background. If '[93m/U[0m' is
echo        specified after the color value, an underline will be applied. Using '[93m/R[0m' instead a color will reset the
echo        current colors back to normal.
echo   [33m/P :[0m Uses PowerShell instead of ANSI escape codes. Especial characters must be escaped.
echo   [33m/Z :[0m Use the advanced formatted mode for displaying strings, which allows multi-colored lines. In order
echo        to change the colors, use the custom escape character set like so: '[93m\f^<fg_HEX^>[0m' ^(foreground^) or
echo        '[93m\b^<bg_HEX^>[0m' ^(background^). More special characters:
echo            [93m\u  =[0m Starts drawing an underline.
echo            [93m\nu =[0m Stops drawing an underline.
echo            [93m\r  =[0m Resets all the colors in the string. (They are automatically resetted at the end)
echo            [93m\\  =[0m Escape a backslash.
echo:
echo:
echo   [93mCOLOR      BG :[0m Select the color to be displayed on the background of the line in hex.
echo                   Using "-" will display the current color of the background.
echo              [93mFG :[0m Select the color to be displayed on the foreground of the line in hex. (color of the text)
echo                   Using "-" will display the current color of the foreground.
echo              [93mAvailable color values:[0m
echo              0 1 2 3 4 5 6 7 8 9 a b c d e f -
echo              [40m[30m  [44m[34m  [42m[32m  [46m[36m  [41m[31m  [45m[35m  [43m[33m  [47m[37m  [100m[90m  [94m[104m  [102m[92m  [96m[106m  [101m[91m  [105m[95m  [103m[93m  [107m[97m  [40m[30m[0m
echo:
echo:
echo   Examples      : '[96mECHOC [33m/S [93m"What's up?" - 3 /u'[0m
echo                      Display the string "What's up?" using the current color of the background, 
echo                      using aquamarine color for the foreground, and drawing an underline.
echo                 : '[96mECHOC [33m/F [93m"./test/notes.txt" 0 a /a 32 /u'[0m
echo                      Display the first 32 lines of the file "./test/notes.txt" using a black color 
echo                      for the background of the lines, a green color for the foreground, and an underline.
echo                 : '[96mECHOC [33m/Z [93m"\fcThis text is red, \b1and this background is blue."'[0m
echo                      Display "This text is red," with a red foreground, and "and this background is blue."
echo                      with a dark blue background.
echo:
echo   - '[96mECHOC [33m/CHKUP[0m' will check if you are using the minimun necessary Windows build, your PowerShell installation,
echo     and the newest versions of ECHOC. If it finds a newer version of it, it will ask for a folder to download
echo     ECHOC in. Pressing ENTER without entering a path will select the default option, which is the folder that
echo     contains the currently running script, overriding the old version.
echo   - Use 'CMD /C' before this script if used in a batch file.
exit /b 0