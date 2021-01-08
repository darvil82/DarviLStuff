::Script to display progress bars easily. Written by DarviL (David Losantos)

@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul

::::::Config:::::::
set "temp1=%temp%\pbar.tmp"


set ver=0.3
set /a build=8

if /i "%1"=="/?" goto help
if /i "%1"=="/CHKUP" goto chkup


::Process all parameters that the user entered. The parameters that require another value next to them will define the "tknxt" variable with the
::name of the parameter itself, then, in the next loop, we will check if "tknxt" is defined, if so, set a variable with the name of the parameter
::that we set before, with the value that we got in the current loop.
for %%G in (%*) do (
	if defined tknxt (
		set "!tknxt!=%%G"
		set tknxt=
	) else (
		if /i "%%G"=="/r" set tknxt=range
		if /i "%%G"=="/t" set tknxt=text
		if /i "%%G"=="/s" set tknxt=size
		if /i "%%G"=="/y" set tknxt=style
		if /i "%%G"=="/n" set no_percent=1
		if /i "%%G"=="/o" set overwrite=1
		if /i "%%G"=="/p" set show_segments=1
	)
)

::Get the range value formatted as "n1-n2" and separate it into two different variables.
if defined range (
	echo !range! > "!temp1!"
	for /f "usebackq tokens=1,2 delims=-" %%G in ("!temp1!") do (
		set /a val1=%%G 2> nul
		set /a val2=%%H 2> nul
	)
)

if not defined val1 set /a val1=0
if not defined val2 set /a val2=1
if not defined size set /a size=2
if not defined style set style=1
if defined text set text=!text:"=!

if !val1! LSS 0 echo First value in range is below 0 & exit /b 1
if !val2! LSS 0 echo Second value in range is below 0 & exit /b 1
if !val1!==0 if !val2!==0 echo Both values in range are 0 & exit /b 1
if !val1! GTR !val2! echo The first value in range is bigger than the second value & exit /b 1
if !size! LSS 1 echo The size is below 1 & exit /b 1


set /a size2=size*10
set /a segments=(val1*100/val2)*(size)
set segments=!segments:~0,-1!
set /a segments2=size2-segments
set /a percent=(val1*100/val2)


::Display the progress bar. Set the elements to draw depending on the selected style.

::bar_draw_empty
::bar_draw_full
::bar_draw_corner1
::bar_draw_corner2
::bar_draw_corner3
::bar_draw_corner4
::bar_draw_vert
::bar_draw_horiz
::bar_draw_overwrite

if !style!==1 (
	set "bar_draw_empty=░"
	set "bar_draw_full=█"
	set "bar_draw_corner1=┌"
	set "bar_draw_corner2=┐"
	set "bar_draw_corner3=└"
	set "bar_draw_corner4=┘"
	set "bar_draw_vert=│"
	set "bar_draw_horiz=─"
	set "bar_draw_overwrite=4"
	
) else if !style!==2 (
	set "bar_draw_empty=-"
	set "bar_draw_full=X"
	set "bar_draw_vert=|"
	set "bar_draw_overwrite=2"
	
) else if !style!==3 (
	set "bar_draw_empty=░"
	set "bar_draw_full=█"
	set "bar_draw_overwrite=2"
	
) else set "bar_draw_overwrite=2"


set bar_info=
if not defined no_percent set "bar_info=!bar_info!!percent!%% "
if defined show_segments set "bar_info=!bar_info!!val1!/!val2! "
if defined text set "bar_info=!bar_info!!text![0K"

::Draw it.
set "space= "
if defined overwrite echo [!bar_draw_overwrite!A

if defined bar_draw_corner1 < nul set /p "=!bar_draw_corner1!"
if defined bar_draw_horiz for /l %%G in (-1,1,!size2!) do < nul set /p "=!bar_draw_horiz!"
if defined bar_draw_corner2 echo !bar_draw_corner2!
< nul set /p "=!bar_draw_vert! "

for /l %%G in (1,1,!segments!) do < nul set /p "=!bar_draw_full!"
for /l %%G in (1,1,!segments2!) do < nul set /p "=!bar_draw_empty!"

echo !space!!bar_draw_vert! !bar_info!

if defined bar_draw_corner3 < nul set /p "=!bar_draw_corner3!"
if defined bar_draw_horiz for /l %%G in (-1,1,!size2!) do < nul set /p "=!bar_draw_horiz!"
if defined bar_draw_corner4 echo !bar_draw_corner4!

exit /b 0




:chkup
::Check if the user is using windows 1909 at least
<nul set /p =Checking Windows build... 
ver > "%temp%\.tmp"
for /f "usebackq skip=1 tokens=4,6 delims=[]. " %%G in ("%temp%\.tmp") do (
	set /a ver_windows=%%G
	set /a build_windows=%%H
)
if !ver_windows!==10 (
	if !build_windows! GEQ 1909 (
		echo Using Windows 10 !build_windows!, with ANSI escape codes support.
	) else echo Windows 10 1909 or higher is required for displaying ANSI escape codes.
) else echo Windows 10 1909 or higher is required for displaying ANSI escape codes.


::Check for updates of PBAR.
<nul set /p =Checking for new versions of PBAR... 
ping github.com /n 1 > nul
if %errorlevel% == 1 echo Unable to connect to GitHub. & exit /b 1
bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/versions" "%temp%\.tmp" > nul
find "pbar" "%temp%\.tmp" > "%temp%\.tmp2"
for /f "skip=2 tokens=3* usebackq" %%G in ("%temp%\.tmp2") do set /a build_gh=%%G
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
echo PBAR [/R value1-value2] [/T "string"] [/S number] [/Y number] [/N] [/O]
echo:
echo   /R : Select a range of two values separated by "-" to display in the progress bar.
echo   /T : Select a string to be displayed at the end of the progress bar.
echo   /S : Select the horizontal size of the progress bar. Default is 2.
echo   /Y : Select one of the 3 styles for the progress bar. Default is 1.
echo   /N : Do not display the percentage at the end of the progress bar.
echo   /O : Overwrite content when displaying the bar, use this in scripts.
echo:
echo   - 'PBAR /CHKUP' will check if you are using the minimun necessary Windows build for ANSI escape codes,
echo     and the newest versions of PBAR.
echo   - Use 'CMD /C' before this script if used in a batch file.

exit /b 0