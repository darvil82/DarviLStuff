::Script to paint drawings with colors. Written by DarviL (David Losantos)

@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion


::::::Config::::::
set "temp1=%temp%\virint.tmp"
set "wip1=%temp%\virint_wip.tmp"


set ver=1.1
set /a build=5

if not defined parms_array set "parms_array=%*"
for %%G in (!parms_array!) do (
	if /i "%%G"=="/nomode" set nomode=1
	if /i "%%G"=="/chkup" goto chkup
)

::Setting default values.
set /a brush_X=5
set /a brush_Y=5
set "space=​"

set brush_color=[97m
set brush_color2=[97m
set brush_type=██
set /a canvas_X=32
set /a canvas_Y=24
set draw_filename_state=


::Start menu.
echo [96mVIRINT !ver![0m
echo Select an option:
echo   1: Create new canvas.
echo   2: Load file.
choice /c 12 /n >nul
set start_input=!errorlevel!
if !start_input!==1 call :file_create
if !start_input!==2 call :file_load
if defined invalid exit /b

::Set required variables for drawing the UI.
set /a draw_barh_size=canvas_X+2
set /a draw_barv_size=canvas_Y+6
set /a draw_barv_long=(canvas_X*2)+7
set /a draw_options_offset=draw_barv_size+1
for /l %%G in (1,1,!draw_barh_size!) do set draw_barh_done=!draw_barh_done!░░




::Main loop routine.
:MAIN
call :draw
call :collide
call :getkey
if not defined run_exit (goto MAIN) else (exit /b)



::Draw the entire UI.
:draw
set /a draw_cursor_X=(brush_X-2)/2
set /a draw_cursor_Y=brush_Y-4

::Info bar
<nul set /p "=[H[96mVIRINT !ver! - !draw_filename_state!'!draw_filename!'[0m[K"
<nul set /p "=[2;1fColor A: !brush_color!██[0m   Color B: !brush_color2!██[0m   X: !draw_cursor_X!/!canvas_X! Y: !draw_cursor_Y!/!canvas_Y![K"

::Horizontal top
<nul set /p =[3;1f▓▓!draw_barh_done!▓▓
<nul set /p =[3;!brush_X!f▄▄

::Vertical left
for /l %%G in (4,1,!draw_barv_size!) do <nul set /p =[%%G;1f░░
echo [!brush_Y!;1f █

::Vertical right
for /l %%G in (4,1,!draw_barv_size!) do <nul set /p =[%%G;!draw_barv_long!f░░
echo [!brush_Y!;!draw_barv_long!f█ 

::Horizontal bottom
<nul set /p =[!draw_barv_size!;1f▓▓!draw_barh_done!▓▓
<nul set /p =[!draw_barv_size!;!brush_X!f▀▀

::Status bar
<nul set /p =[!draw_barv_size!;1f
echo:
if defined brushToggle (<nul set /p "=[7mBrush: B[0m  |  ") else (<nul set /p "=Brush: B  |  ")
if defined brushErase (<nul set /p "=[7mErase: E[0m  |  ") else (<nul set /p "=Erase: E  |  ")
<nul set /p ="Color: C  |  Toggle Color: T  |  Coord: F  |  Fill: X  |  Save: V  |  Exit: M"
echo [J



::Draw brush on screen, and save the position in screen, the color, and the brush type to a temporary file.
if defined brushToggle (
	echo [!brush_Y!;!brush_X!f!brush_color!!brush_type![0m
	if not defined brushErase (echo !brush_Y!:!brush_X!:!brush_color!:!brush_type!>> "!wip1!") else (echo !brush_Y!:!brush_X!::!brush_type!>> "!wip1!")
	set draw_filename_state=*
)
exit /b




::Detect if the cursor is getting close to the boundaries, and deny it's movement.
:collide
set /a canvas_limitX=(canvas_X*2)+5
set /a canvas_limitY=canvas_Y+6
set /a brush_X_next=brush_X+2
set /a brush_X_prev=brush_X-2
set /a brush_Y_next=brush_Y+2
set /a brush_Y_prev=brush_Y-2
if !brush_X_prev! LEQ 3 (set brush_leftq=0) else (set brush_leftq=1)
if !brush_X_next! GEQ !canvas_limitX! (set brush_rightq=0) else (set brush_rightq=1)
if !brush_Y_prev! LEQ 3 (set brush_upq=0) else (set brush_upq=1)
if !brush_Y_next! GEQ !canvas_limitY! (set brush_downq=0) else (set brush_downq=1)
exit /b




::Get the key that the user presses. The script won't continue until the user presses any key.
:getkey
choice /c wasdbectfxmv /n >nul
set getkey_input=!errorlevel!

if !getkey_input!==1 if !brush_upq!==1 set /a brush_Y-=1
if !getkey_input!==3 if !brush_downq!==1 set /a brush_Y+=1
if !getkey_input!==2 if !brush_leftq!==1 set /a brush_X-=2
if !getkey_input!==4 if !brush_rightq!==1 set /a brush_X+=2
if !getkey_input!==5 if not defined brushToggle (set brushToggle=1) else (set brushToggle=)
if !getkey_input!==6 if not defined brushErase (
		set brushErase=1
		set brush_type=!space!!space!
	) else (
		set brushErase=
		set brush_type=██
	)
if !getkey_input!==7 call :option_color_select
if !getkey_input!==8 (
	set tmp=!brush_color!
	set brush_color=!brush_color2!
	set brush_color2=!tmp!
)
if !getkey_input!==9 call :option_coord_select
if !getkey_input!==10 call :option_canvas_fill
if !getkey_input!==11 call :option_exit
if !getkey_input!==12 call :file_save
exit /b








::Let the user select one of the default colors, or specify a RGB value.
:option_color_select
echo [!draw_options_offset!;1f[7mSelect a color:[0m[J
echo:
echo [7m[34m 1 [32m 2 [36m 3 [31m 4 [35m 5 [33m 6 [37m 7 [90m 8 [94m 9 [92m A [96m B [91m C [95m D [93m E [97m F [0m
echo  G: Pick RGB.

choice /c 123456789abcdefg /n >nul
set brush_color2=!brush_color!

if !errorlevel!==1 set brush_color=[34m
if !errorlevel!==2 set brush_color=[32m
if !errorlevel!==3 set brush_color=[36m
if !errorlevel!==4 set brush_color=[31m
if !errorlevel!==5 set brush_color=[35m
if !errorlevel!==6 set brush_color=[33m
if !errorlevel!==7 set brush_color=[37m
if !errorlevel!==8 set brush_color=[90m
if !errorlevel!==9 set brush_color=[94m
if !errorlevel!==10 set brush_color=[92m
if !errorlevel!==11 set brush_color=[96m
if !errorlevel!==12 set brush_color=[91m
if !errorlevel!==13 set brush_color=[95m
if !errorlevel!==14 set brush_color=[93m
if !errorlevel!==15 set brush_color=[97m
if !errorlevel!==16 (
	set option_color_select_input=
	set /p option_color_select_input=[!draw_options_offset!;1f[7mSelect a color value [255-255-255]:[0m[J 
	if not defined option_color_select_input set brush_color=[97m& exit /b
	echo !option_color_select_input! > "!temp1!"
	for /f "usebackq tokens=1-3 delims=-" %%G in ("!temp1!") do (
		set /a option_color_select_R=%%G 2> nul
		set /a option_color_select_G=%%H 2> nul
		set /a option_color_select_B=%%I 2> nul
	)
	set brush_color=[38;2;!option_color_select_R!;!option_color_select_G!;!option_color_select_B!m
)
exit /b




::Select the coordinates of the cursor to move. Check if the user is trying to get out of bounds.
:option_coord_select
set /p option_coord_input=[!draw_options_offset!;1f[7mSelect the coordinates [1-1]:[0m[J 
if defined option_coord_input (
	echo !option_coord_input! > "!temp1!"
	for /f "usebackq tokens=1-2 delims=-" %%G in ("!temp1!") do (
		set /a option_coord_X=%%G 2>nul
		set /a option_coord_Y=%%H 2>nul
	)
	set option_coord_input=
) else (
	set /a option_coord_X=1
	set /a option_coord_Y=1
)
if !option_coord_X! GTR !canvas_X! call :display_message "ERROR: Cursor out of bounds." red &exit /b
if !option_coord_X! LSS 1 call :display_message "ERROR: Cursor out of bounds." red &exit /b
if !option_coord_Y! GTR !canvas_Y! call :display_message "ERROR: Cursor out of bounds." red &exit /b
if !option_coord_Y! LSS 1 call :display_message "ERROR: Cursor out of bounds." red &exit /b

set /a brush_X=((option_coord_X+2)*2)-1
set /a brush_Y=option_coord_Y+4
exit /b



::Fill the canvas with the current color. If Erase is on, just do cls and clear the file.
:option_canvas_fill
echo [!draw_options_offset!;1f[91m[7mFill canvas with current brush options? [Y/N][0m[J
choice /c yn /n >nul
if !errorlevel!==1 (
	echo !build!:!canvas_X!:!canvas_Y!:VIRINTFile> "!wip1!"
	set option_canvas_fill_brush=
	if not defined brushErase (
		for /l %%G in (1,1,!canvas_X!) do (set option_canvas_fill_brush=!brush_type!!option_canvas_fill_brush!)
		for /l %%G in (1,1,!canvas_Y!) do (
			set /a option_canvas_fill_Y=%%G+4 2>nul
			echo [!option_canvas_fill_Y!;5f!brush_color!!option_canvas_fill_brush![0m
			echo !option_canvas_fill_Y!:5:!brush_color!:!option_canvas_fill_brush!>> "!wip1!"
		)
	) else cls
	set draw_filename_state=*
	exit /b
)
if !errorlevel!==2 exit /b





::Exit option.
:option_exit
echo [!draw_options_offset!;1f[91m[7mExit VIRINT? All unsaved changes will be lost. [Y/N][0m[J
choice /c yn /n >nul
if !errorlevel!==1 set run_exit=1 & exit /b
if !errorlevel!==2 exit /b



::Loading file function. This will parse all the the data inside the saved file to display it on screen. First, it will check the header,
::which is the first line of the file, it contains the build where the file was created, sets the size of the window to fit the canvas.
::Lastly, it reads every line that contains a pixel in the canvas.
:file_load
echo:
set /p file_load_input="Select a file to load: "
if not defined file_load_input echo Invalid filename. &set invalid=1 &exit /b
set file_load_input=!file_load_input:"=!

for %%G in ("!file_load_input!") do set file_load_input=%%~fG
if not exist "!file_load_input!" echo File '!file_load_input!' does not exist. &set invalid=1 &exit /b

set /p load_header=<"!file_load_input!"
echo !load_header!>"!temp1!"
for /f "usebackq tokens=1-4 delims=:" %%G in ("!temp1!") do (
	set /a file_build=%%G 2> nul
	set /a canvas_X=%%H 2> nul
	set /a canvas_Y=%%I 2> nul
	set header_mark=%%J
)
if not "!header_mark!"=="VIRINTFile" echo Invalid file structure. &set invalid=1 &exit /b
REM if !file_build! LSS !build! (
	REM echo This file has been edited in an older version of VIRINT. Proceed? [Y/N]
	REM choice /c yn /n >nul
	REM if !errorlevel!==2 set invalid=1 & exit /b
REM )

call :checksize
if defined invalid exit /b
echo [HLoading file. Please wait...
for /f "usebackq skip=1 tokens=1-4 delims=:" %%G in ("!file_load_input!") do (
	<nul set /p =[%%G;%%Hf%%I%%J[0m
	REM ping localhost -n 1 >nul
)
set draw_filename=!file_load_input!
copy "!file_load_input!" "!wip1!">nul
exit /b




::Create a new file. Basically builds the header of the file, containing the build and the size of the canvas. All stored in a temp file.
:file_create
echo:
set /p canvas_size="Select a size for the canvas [32x24]: "
if defined canvas_size (
	echo !canvas_size! > "!temp1!"
	for /f "usebackq tokens=1-2 delims=x" %%G in ("!temp1!") do (
		set /a canvas_X=%%G 2>nul
		set /a canvas_Y=%%H 2>nul
	)
)
call :checksize
set draw_filename=Untitled
echo !build!:!canvas_X!:!canvas_Y!:VIRINTFile> "!wip1!"
exit /b



::Save a file. Basically copying the temp file where all the data is stored, to the path that the user specified.
:file_save
set file_save_input=
set /p file_save_input=[!draw_options_offset!;1f[7mFilename [!draw_filename!]:[0m[J 
if not defined file_save_input set file_save_input="!draw_filename!"
set file_save_input=!file_save_input:"=!
for %%G in ("!file_save_input!") do set file_save_input=%%~fG

if exist "!file_save_input!" (
	echo [!draw_options_offset!;1f[7mFound file '!file_save_input!'. Overwrite? [Y/N][0m[J 
	choice /c yn /n >nul
	if !errorlevel!==2 exit /b
)
copy "!wip1!" "!file_save_input!">nul
set draw_filename=!file_save_input!
set draw_filename_state=
call :display_message "File saved succesfully as '!file_save_input!'." green
exit /b




::Check if the canvas size is valid, and calculate the number of columns and lines for MODE.
:checksize
if !canvas_X! LSS 20 echo Invalid canvas size. &set invalid=1 & exit /b
if !canvas_X! GTR 128 echo Invalid canvas size. &set invalid=1 & exit /b
if !canvas_Y! LSS 20 echo Invalid canvas size. &set invalid=1 & exit /b
if !canvas_Y! GTR 128 echo Invalid canvas size. &set invalid=1 & exit /b

set /a window_cols="(canvas_X+4)*2"
set /a window_lines=canvas_Y+12

cls
if not defined nomode mode con cols=!window_cols! lines=!window_lines!
exit /b




::Display a message under the canvas.
:display_message
set display_message_msg=%1
set display_message_msg=!display_message_msg:"=!
if %2==red set display_message_color=[91m
if %2==green set display_message_color=[92m
echo [!draw_options_offset!;1f!display_message_color![7m!display_message_msg![0m[J
timeout /t 2 >nul
exit /b





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


::Check for updates.
<nul set /p =Checking for new versions of VIRINT... 
ping github.com /n 1 > nul
if %errorlevel% == 1 echo Unable to connect to GitHub. & exit /b 1
bitsadmin /transfer /download "https://raw.githubusercontent.com/L89David/DarviLStuff/master/versions" "!temp1!" > nul
find "virint" "!temp1!" > "!temp1!2"
for /f "skip=2 tokens=3* usebackq" %%G in ("!temp1!2") do set /a build_gh=%%G
if !build_gh! GTR !build! (
	echo Found a new version. ^(Using build: !build!. Latest build: !build_gh!^)
	echo:
	choice /c YN /m "Do you want to open the repository where VIRINT is located?"
	if !errorlevel!==1 start https://github.com/L89David/DarviLStuff/blob/master/virint.bat
	if !errorlevel!==2 exit /b
) else echo Using latest build.
exit /b 0