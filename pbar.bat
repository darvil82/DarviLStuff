::Script to display progress bars easily. Written by DarviL (David Losantos)

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

::::::Config::::::
set "temp1=%temp%\pbar.tmp"
set "save1=%temp%\pbar_save.tmp"


set ver=1.3.0-1
set /a build=23

if /i "%1"=="/?" goto help
if /i "%1"=="/CHKUP" goto chkup
if /i "%1"=="/load" (
	if not exist "!save1!" echo There's no content to load. & exit /b 1
	set /p "parms_array="<"!save1!"
	set parms_array=!parms_array! %*
)

::Process all parameters that the user entered. The parameters that require another value next to them will define the "tknxt" variable with the
::name of the parameter itself, then, in the next loop, we will check if "tknxt" is defined, if so, set a variable with the name of the parameter
::that we set before, with the value that we got in the current loop.
if not defined parms_array set "parms_array=%*"
for %%G in (!parms_array!) do (
	if defined tknxt (
		set "!tknxt!=%%G"
		set tknxt=
	) else (
		if /i "%%G"=="/r" set tknxt=range
		if /i "%%G"=="/t" set tknxt=text
		if /i "%%G"=="/y" set tknxt=drawmode
		if /i "%%G"=="/s" set tknxt=shift
		if /i "%%G"=="/n" set no_percent=1
		if /i "%%G"=="/o" set overwrite=1
		if /i "%%G"=="/p" set show_segments=1
		if /i "%%G"=="/save" set save=1
	)
)

if defined save (
	set save_data=%*
	set save_data=!save_data:/save=!
	echo !save_data! > "!save1!"
	exit /b 1
)

::Get the range value formatted as "n1-n2" and separate it into two different variables.
if defined range (
	echo !range! > "!temp1!"
	for /f "usebackq tokens=1,2 delims=-" %%G in ("!temp1!") do (
		set /a val1=%%G 2> nul
		set /a val2=%%H 2> nul
	)
)

::Get the drawmode value formatted as "n1-n2-n3" and separate it into three different variables.
if defined drawmode (
	echo !drawmode! > "!temp1!"
	for /f "usebackq tokens=1,2,3 delims=-" %%G in ("!temp1!") do (
		set /a style=%%G 2> nul
		set /a theme=%%H 2> nul
		set /a size=%%I 2> nul
	)
)

::Set default values
if not defined val1 set /a val1=0
if not defined val2 set /a val2=1
if not defined size set /a size=20
if not defined theme set theme=1
if not defined style set style=1
if not defined shift set shift=1
set /a shift=!shift! 2> nul
if defined text set text=!text:"=!

if !val1! LSS 0 echo First value in range is below 0 & exit /b 1
if !val2! LSS 0 echo Second value in range is below 0 & exit /b 1
if !val1!==0 if !val2!==0 echo Both values in range are 0 & exit /b 1
if !val1! GTR !val2! echo The first value in range is bigger than the second value & exit /b 1
if !size! LSS 2 echo The size is below 2 & exit /b 1


::Arithmetic operations to get the correct number of segments to display and the percentage.
set /a segments=(val1*100/val2)*(size*10)
set segments=!segments:~0,-3!
set /a segments2=size-segments
set /a percent=(val1*100/val2)


::Set the elements to draw depending on the selected theme.
set "space=​"
set draw_bar_shift=[!shift!C

::bar_draw_empty
::bar_draw_full
::bar_draw_corner1
::bar_draw_corner2
::bar_draw_corner3
::bar_draw_corner4
::bar_draw_vert
::bar_draw_horiz
::bar_draw_overwrite

if !theme!==1 (
	set "bar_draw_empty=░"
	set "bar_draw_full=█"
	set "bar_draw_corner1=┌"
	set "bar_draw_corner2=┐"
	set "bar_draw_corner3=└"
	set "bar_draw_corner4=┘"
	set "bar_draw_vert=│"
	set "bar_draw_horiz=─"
	set "bar_draw_overwrite=4"
	
) else if !theme!==2 (
	set "bar_draw_empty=!space!"
	set "bar_draw_full=#"
	set "bar_draw_vert=|"
	set "bar_draw_overwrite=2"
	
) else if !theme!==3 (
	set "bar_draw_empty=░"
	set "bar_draw_full=█"
	set "bar_draw_overwrite=2"

) else if !theme!==4 (
	set "bar_draw_empty=○"
	set "bar_draw_full=●"
	set "bar_draw_overwrite=2"
	
) else if !theme!==5 (
	set "bar_draw_empty=[31m█"
	set "bar_draw_full=[92m█"
	set "bar_draw_vert=[0m"
	set "bar_draw_overwrite=2"
	
) else echo Theme '!theme!' doesn't exist. & exit /b 1


set bar_info=
if not defined no_percent set "bar_info=!bar_info!!percent!%% "
if defined show_segments set "bar_info=!bar_info!!val1!/!val2! "
if defined text set "bar_info=!bar_info!!text!"
if defined overwrite set "bar_info=!bar_info![0K"


::Draw the progress bar.
::The style 1 will draw the bar horizontally.
if !style!==1 (
	if defined overwrite echo [!bar_draw_overwrite!A
	if defined bar_draw_corner1 < nul set /p "=!draw_bar_shift!!bar_draw_corner1!"
	if defined bar_draw_horiz for /l %%G in (-1,1,!size!) do < nul set /p "=!bar_draw_horiz!"
	if defined bar_draw_corner2 echo !bar_draw_corner2!
	< nul set /p "=!draw_bar_shift!!bar_draw_vert! "

	for /l %%G in (1,1,!segments!) do < nul set /p "=!bar_draw_full!"
	for /l %%G in (1,1,!segments2!) do < nul set /p "=!bar_draw_empty!"

	echo !space!!bar_draw_vert! !bar_info!

	if defined bar_draw_corner3 < nul set /p "=!draw_bar_shift!!bar_draw_corner3!"
	if defined bar_draw_horiz for /l %%G in (-1,1,!size!) do < nul set /p "=!bar_draw_horiz!"
	if defined bar_draw_corner4 echo !bar_draw_corner4!
	
	exit /b 0

	rem The style 2 will draw the bar vertically.
) else if !style!==2 (
	if defined overwrite (
		set /a overwrite=size+4
		echo [!overwrite!A
	)
	echo !draw_bar_shift!!bar_draw_corner1!!bar_draw_horiz!!bar_draw_horiz!!bar_draw_corner2!!space!
	for /l %%G in (1,1,!segments2!) do echo !draw_bar_shift!!bar_draw_vert!!bar_draw_empty!!bar_draw_empty!!bar_draw_vert!
	for /l %%G in (1,1,!segments!) do echo !draw_bar_shift!!bar_draw_vert!!bar_draw_full!!bar_draw_full!!bar_draw_vert!
	echo !draw_bar_shift!!bar_draw_corner3!!bar_draw_horiz!!bar_draw_horiz!!bar_draw_corner4!!space!
	if defined bar_info echo !draw_bar_shift!!bar_info!
	
	exit /b 0
	
) else echo Style '!style!' doesn't exist. & exit /b 1





:chkup
::Check if the user is using windows 1909 at least
<nul set /p =Checking Windows build... 
ver > "!temp1!"
for /f "usebackq skip=1 tokens=4,6 delims=[]. " %%G in ("!temp1!") do (
	set /a ver_windows=%%G
	set /a build_windows=%%H
)
if !ver_windows!==10 (
	if !build_windows! GEQ 17763 (
		echo Using Windows 10 !build_windows!, with ANSI escape codes support.
	) else echo Windows 10 1909 or higher is required for displaying ANSI escape codes.
) else echo Windows 10 1909 or higher is required for displaying ANSI escape codes.


::Check for updates of PBAR.
<nul set /p =Checking for new versions of PBAR... 
ping github.com /n 1 > nul
if %errorlevel% == 1 echo Unable to connect to GitHub. & exit /b 1
bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/versions" "!temp1!" > nul
find "pbar" "!temp1!" > "!temp1!2"
for /f "skip=2 tokens=3* usebackq" %%G in ("!temp1!2") do set /a build_gh=%%G
if !build_gh! GTR !build! (
	echo Found a new version. ^(Using build: !build!. Latest build: !build_gh!^)
	echo:
	choice /c YN /m "Do you want to open the repository where PBAR is located?"
	if !errorlevel!==1 start https://github.com/L89David/DarviLStuff/blob/master/pbar.bat
	if !errorlevel!==2 exit /b
) else echo Using latest build.
exit /b 0





:help
echo Script that allows the user to display progress bars easily.
echo Written by DarviL (David Losantos) in batch. Using version !ver! (Build !build!)
echo Repository available at: "https://github.com/L89David/DarviLStuff"
echo:
echo PBAR [/LOAD] [/R n1-n2] [/T "string"] [/Y n1-n2-n3] [/S number] [/N] [/O] [/P] [/SAVE]
echo:
echo   /R : Select a range of two values to display in the progress bar.
echo   /T : Select a string to be displayed at the end of the progress bar.
echo   /Y : Select the draw mode of the progress bar. The first number (n1) indicates the style of the bar,
echo        (horizontal or vertical). The second number (n2) sets the set of characters to use for it.
echo        The last number (n3) specifies the size of the progress bar. Default values are '1-1-20'.
echo   /S : Shift the progress bar the number of characters specified. Using negative numbers will
echo        shift it to the left. Default value is '1'.
echo   /N : Do not display the percentage at the end of the progress bar.
echo   /O : Overwrite content when displaying the bar, use this in scripts.
echo   /P : Display the range specified with '/R' at the end of the progress bar.
echo   /SAVE : Save all the parameters used in a temporary file. The progress bar won't be displayed.
echo   /LOAD : Load all the parameters previously stored with '/SAVE'. If being used, this parameter must
echo           be the first one in use. If another parameter of the ones above is specified, it will be added
echo           to the current bar, and if it is already defined by the save, it will be overwritten.
echo:
echo   Examples      : 'PBAR /r 4-13 /t "Loading..." /y 1-3-10'
echo                      Display a horizontal progress bar with a range of 4-13, with the custom text
echo                      'Loading...', with a size of 10 segments, and with the third theme.
echo:
echo   - 'PBAR /CHKUP' will check if you are using the minimum necessary Windows build for ANSI escape codes
echo     and the newest versions of PBAR.
echo   - Use 'CMD /C' before this script if used in a batch file.
echo   - More help available at 'https://github.com/L89David/DarviLStuff/wiki/PBAR'

exit /b 0
