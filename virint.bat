
::Script to paint drawings with colors. Written by DarviL (David Losantos)

@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

::::::Config::::::
set "temp1=%temp%\virint.tmp"
set "wip1=%temp%\virint_wip!random!.tmp"

set ver=2.4.3
set /a build=22

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

::Get the current number of columns on screen.
mode > "!temp1!"
for /f "usebackq skip=4 tokens=2 delims=: " %%G in ("!temp1!") do (
	set /a cols_current=%%G
	goto get-cols-end
)
:get-cols-end


::Check for parameters.
if "%1"=="/?" call :help noLoad & exit /b
if exist %1 set "file_load_input=%1"

if not defined parms_array set "parms_array=%*"
for %%G in (!parms_array!) do (
	if defined tknxt (
		set "!tknxt!=%%G"
		set tknxt=
	) else (
		if /i "%%G"=="/s" set tknxt=canvas_size
		if /i "%%G"=="/l" set tknxt=file_load_input
		if /i "%%G"=="/n" set parm_new=1
		if /i "%%G"=="/c" set parm_compress=1
		if /i "%%G"=="/NoMode" set nomode=1
		if /i "%%G"=="/chkup" goto chkup
		if /i "%%G"=="/NoCompression" set noCompression=1
	)
)
if defined parm_new (
	call :file_create
	if defined invalid exit /b 1
	call :start
	exit /b
)
if defined file_load_input (
	if defined parm_compress set LoadDoCompress=1
	call :file_load
	if defined invalid exit /b 1
	call :start
	exit /b
)





::Start menu.
echo [96mVIRINT !ver![0m
echo Select an option:
echo   [94m1)[0m Create new canvas.
echo   [94m2)[0m Load file.
echo:
echo   [91m3)[0m Exit.
choice /c 123 /n >nul
set start_input=!errorlevel!
if !start_input!==1 echo: & set /p canvas_size="Select a size for the canvas [32x24]: " & call :file_create
if !start_input!==2 echo: & set /p file_load_input="Select a file to load: " & call :file_load
if !start_input!==3 exit /b
if defined invalid exit /b 1



:start
::Set required variables for drawing the UI.
set /a draw_barh_size=canvas_X+2
set /a draw_barh_offset=canvas_Y+6
set /a draw_barv_size=canvas_Y+5
set /a draw_barv_offset=(canvas_X*2)+7
set /a draw_options_offset=draw_barh_offset+1
for /l %%G in (1,1,!draw_barh_size!) do set draw_barh_done=!draw_barh_done!░░
for /l %%G in (4,1,!draw_barv_size!) do (set draw_barv_done=!draw_barv_done![%%G;1f░░& set draw_barv2_done=!draw_barv2_done![%%G;!draw_barv_offset!f░░)



::Main loop routine.
:MAIN
call :draw
call :collide
call :getkey
if not defined run_exit (
	goto MAIN
) else (
	if not defined NoMode (
		cls
		mode con cols=!cols_current!
	)
	del /q "!wip1!"
	exit /b 0
)



::Draw the entire UI.
:draw
set /a draw_cursor_X=(brush_X-2)/2
set /a draw_cursor_Y=brush_Y-4

::Info bar
<nul set /p "=[H[96mVIRINT !ver! - [!draw_filename_state!'!draw_filename!'][0m[K"
<nul set /p "=[2;1fColor A: !brush_color!██[0m   Color B: !brush_color2!██[0m   X: !draw_cursor_X!/!canvas_X! Y: !draw_cursor_Y!/!canvas_Y![K"

::Horizontal top
<nul set /p =[3;1f▓▓!draw_barh_done!▓▓
<nul set /p =[3;!brush_X!f▄▄

::Vertical left
<nul set /p =!draw_barv_done!
echo [!brush_Y!;1f █

::Vertical right
<nul set /p =!draw_barv2_done!
echo [!brush_Y!;!draw_barv_offset!f█ 

::Horizontal bottom
<nul set /p =[!draw_barh_offset!;1f▓▓!draw_barh_done!▓▓
<nul set /p =[!draw_barh_offset!;!brush_X!f▀▀

::Status bar
<nul set /p =[!draw_barh_offset!;1f
echo:
<nul set /p ="[96mMove: WASD  |  "
if defined brushToggle (<nul set /p "=[7mBrush: B[27m  |  ") else (<nul set /p "=Brush: B  |  ")
if defined brushErase (<nul set /p "=[7mErase: E[27m  |  ") else (<nul set /p "=Erase: E  |  ")
<nul set /p ="Color: C  |  Toggle Color: T  |  Coord: F  |  Fill: X  |  [95mSave: V  |  Exit: M[0m"
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
set /a brush_Y_prev=brush_Y-1
if !brush_X_prev! LEQ 4 (set brush_leftq=0) else (set brush_leftq=1)
if !brush_X_next! GEQ !canvas_limitX! (set brush_rightq=0) else (set brush_rightq=1)
if !brush_Y_prev! LEQ 4 (set brush_upq=0) else (set brush_upq=1)
if !brush_Y_next! GEQ !canvas_limitY! (set brush_downq=0) else (set brush_downq=1)
exit /b




::Get the key that the user presses. The script won't continue until the user presses any key.
:getkey
choice /c WASDBECTFXMVHR /n >nul
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
if !getkey_input!==11 (
	if "!draw_filename_state!"=="*" (
		call :display_message "Exit VIRINT? All unsaved changes will be lost. [Y/N]" red
		choice /c yn /n >nul
		if !errorlevel!==1 set run_exit=1
		exit /b
	)
	set run_exit=1 & exit /b
)
if !getkey_input!==12 call :file_save
if !getkey_input!==13 call :help
if !getkey_input!==14 call :file_reload
exit /b


















::Let the user select one of the default colors, or specify a RGB value.
:option_color_select
call :display_message "Select a color:" white
echo:&echo:
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
	call :display_message "Select a color value [255-255-255]:" white
	set /p option_color_select_input=
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
call :display_message "Select the coordinate [1-1]:" white
set /p option_coord_input=
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
if !option_coord_X! GTR !canvas_X! call :display_message "ERROR: Cursor out of bounds." red wait &exit /b
if !option_coord_X! LSS 1 call :display_message "ERROR: Cursor out of bounds." red wait &exit /b
if !option_coord_Y! GTR !canvas_Y! call :display_message "ERROR: Cursor out of bounds." red wait &exit /b
if !option_coord_Y! LSS 1 call :display_message "ERROR: Cursor out of bounds." red wait &exit /b

set /a brush_X=((option_coord_X+2)*2)-1
set /a brush_Y=option_coord_Y+4
exit /b





::Fill the canvas with the current color. If Erase is on, just do cls and clear the file. Here it types XX:XX as the X and Y coords to the
::file because we don't need to store every single line. The file_reload function will parse it correctly to draw it on screen.
:option_canvas_fill
call :display_message "Fill canvas with current brush options? [Y/N]" red
choice /c yn /n >nul
if !errorlevel!==1 (
	echo VIRINTFile > "!wip1!"
	set option_canvas_fill_brush=
	if not defined brushErase (
		for /l %%G in (1,1,!canvas_X!) do (set option_canvas_fill_brush=!brush_type!!option_canvas_fill_brush!)
		for /l %%G in (1,1,!canvas_Y!) do (
			set /a option_canvas_fill_Y=%%G+4 2>nul
			echo [!option_canvas_fill_Y!;5f!brush_color!!option_canvas_fill_brush![0m
		)
		echo XX:XX:!brush_color!:!brush_type!>> "!wip1!"
	) else cls
	set draw_filename_state=*
	exit /b
)
if !errorlevel!==2 exit /b





::Loading file function. This will parse all the the data in the header, which constains the script version number, the canvas size
::in the X and Y axis, the brush position in the X and Y axis, the brush colors A and B, and a mark that is just 'VIRINTFile'.
:file_load
if not defined file_load_input call :display_message "ERROR: Invalid filename." red newline &set invalid=1 &exit /b
set file_load_input=!file_load_input:"=!

for %%G in ("!file_load_input!") do set file_load_input=%%~fG
if exist "!file_load_input!\*" call :display_message "ERROR: File '!file_load_input!' is a directory." red newline &set invalid=1 &exit /b
if not exist "!file_load_input!" call :display_message "ERROR: File '!file_load_input!' does not exist." red newline &set invalid=1 &exit /b

set /p load_header=<"!file_load_input!"
echo !load_header!>"!temp1!"
for /f "usebackq tokens=1-8 delims=:" %%G in ("!temp1!") do (
	set /a file_build=%%G 2> nul
	set /a canvas_X=%%H 2> nul
	set /a canvas_Y=%%I 2> nul
	set /a brush_X=%%J 2> nul
	set /a brush_Y=%%K 2> nul
	set brush_color=%%L
	set brush_color2=%%M
	set header_mark=%%N
)
if not "!header_mark!"=="VIRINTFile" call :display_message "ERROR: Invalid file structure." red newline &set invalid=1 &exit /b
if !file_build! LSS !build! (
	echo This file has been edited in an older version of VIRINT. Proceed? [Y/N]
	choice /c yn /n >nul
	if !errorlevel!==2 set invalid=1 & exit /b
)

if defined LoadDoCompress (
	copy "!file_load_input!" "!temp1!" >nul
	call :file_compress
	copy "!temp1!" "!file_load_input!" >nul
	exit /b
)

call :checksize
if defined invalid exit /b
copy "!file_load_input!" "!wip1!" >nul
call :file_reload
set draw_filename=!file_load_input!
exit /b






::Parse the picture data inside the file. It basically reads every line to get the coordinates, color, and brush type to draw on screen.
::If it finds a line containing XX:XX as the coordinates, it fills up the entire screen with the color and brush type.
:file_reload
call :checksize
call :display_message "[HLoading, please wait..." yellow newline
findstr /r /c:"^^XX:XX:.*$" "!wip1!" > "!temp1!"
if !errorlevel!==0 (
	set file_load_full=
	for /f "usebackq tokens=3-4 delims=:" %%A in ("!temp1!") do (
		for /l %%G in (1,1,!canvas_X!) do (set file_load_full=!file_load_full!%%B)
		for /l %%G in (1,1,!canvas_Y!) do (
			set /a option_canvas_fill_Y=%%G+4 2>nul
			echo [!option_canvas_fill_Y!;5f%%A!file_load_full![0m
		)
	)
	for /f "usebackq skip=2 tokens=1-4 delims=:" %%G in ("!wip1!") do (
		<nul set /p =[%%G;%%Hf%%I%%J[0m
	)
) else (
	for /f "usebackq skip=1 tokens=1-4 delims=:" %%G in ("!wip1!") do (
		<nul set /p =[%%G;%%Hf%%I%%J[0m
	)
)
exit /b






::Changes the size of the screen to match the selected canvas size. It also changes the filename to 'Untitled', and clears up the wip file.
:file_create
if defined canvas_size (
	echo !canvas_size! > "!temp1!"
	for /f "usebackq tokens=1-2 delims=x" %%G in ("!temp1!") do (
		set /a canvas_X=%%G 2>nul
		set /a canvas_Y=%%H 2>nul
	)
)
call :checksize
set draw_filename=Untitled
echo VIRINTFile > "!wip1!"
exit /b






::Save a file. Copies the temp file where all the data is stored to the path that the user specified. It also builds the header that
::file_load can understand.
:file_save
set file_save_input=
call :display_message "Select a filename [!draw_filename!]:" white
set /p file_save_input=
if not defined file_save_input set file_save_input="!draw_filename!"
set file_save_input=!file_save_input:"=!
if /i "!file_save_input!"=="con" call :display_message "ERROR: Invalid filename." red wait & exit /b 1
for %%G in ("!file_save_input!") do set "file_save_input=%%~fG"

if exist "!file_save_input!" (
	call :display_message "Found file '!file_save_input!'. Overwrite? [Y/N]" white
	choice /c yn /n >nul
	if !errorlevel!==2 exit /b
)

findstr /v "VIRINTFile" "!wip1!" > "!temp1!"

if not defined noCompression (
	call :display_message "Applying compression. Please, wait..." yellow
	call :file_compress
)

echo !build!:!canvas_X!:!canvas_Y!:!brush_X!:!brush_Y!:!brush_color!:!brush_color2!:VIRINTFile> "!wip1!"
type "!temp1!" >> "!wip1!"
copy "!wip1!" "!file_save_input!" >nul

if exist "!file_save_input!" (
	call :display_message "File saved succesfully as '!file_save_input!'." green wait
	set draw_filename=!file_save_input!
	set draw_filename_state=
) else call :display_message "ERROR: An error occurred while trying to save the file as '!file_save_input!'." red wait
call :file_reload
exit /b





::Compression algorithm for making virint files smaller. Takes the content of the file !tmp1! (WITHOUT HEADER), and applies a search
::for any duplicated X or Y value. If it finds duplicates, it will only save the last occurence. This is done for every single line in the file.
::After finishing, it outputs the compressed file in !temp1!
:file_compress
if defined LoadDoCompress (
	echo Applying compression. Please wait... ^(Started at !time!^)
	for /f "usebackq" %%G in ("!temp1!") do set /a file_compress_lines1+=1
)
for /f "usebackq tokens=1-2 delims=:" %%G in ("!temp1!") do (
	set /a file_compress_counter=0
	findstr /r /c:"^^%%G:%%H:.*$" "!temp1!" > "!temp1!2"
	for /f "usebackq" %%G in ("!temp1!2") do (
		set /a file_compress_counter+=1
		set file_save_lastLine=%%G
	)
	if !file_compress_counter! GTR 1 (
		findstr /v /r /c:"^^%%G:%%H:.*$" "!temp1!" > "!temp1!3"
		echo !file_save_lastLine!>> "!temp1!3"
		type "!temp1!3" > "!temp1!"
	)
)
if defined LoadDoCompress (
	for /f "usebackq" %%G in ("!temp1!") do set /a file_compress_lines2+=1
	set /a file_compress_result=file_compress_lines1-file_compress_lines2
	call :display_message "Done. !file_compress_result! lines removed. [!file_compress_lines1! ^> !file_compress_lines2!^] ^(Finished at !time!^)" green newline
	rem Here we set invalid to 1 because we don't want to load the file on screen.
	set invalid=1
)
exit /b





::Check if the canvas size is valid, and calculate the number of columns and lines for MODE.
:checksize
if !canvas_X! LSS 20 call :display_message "ERROR: Exceeded minimum canvas horizontal size." red newline &set invalid=1 & exit /b
if !canvas_X! GTR 128 call :display_message "ERROR: Exceeded maximun canvas horizontal size." red newline &set invalid=1 & exit /b
if !canvas_Y! LSS 20 call :display_message "ERROR: Exceeded minimum canvas vertical size." red newline &set invalid=1 & exit /b
if !canvas_Y! GTR 128 call :display_message "ERROR: Exceeded maximun canvas vertical size." red newline &set invalid=1 & exit /b

set /a window_cols="(canvas_X+4)*2"
set /a window_lines=canvas_Y+12

cls
if not defined nomode mode con cols=!window_cols! lines=!window_lines!
exit /b





::Display a message under the canvas. [red green yellow white] [wait/newline]
:display_message
set display_message_msg=%1
set display_message_msg=!display_message_msg:"=!
if "%2"=="red" set display_message_color=[91m
if "%2"=="green" set display_message_color=[92m
if "%2"=="yellow" set display_message_color=[33m
if "%2"=="white" set display_message_color=[97m
if "%3"=="newline" (echo !display_message_color!!display_message_msg![0m) else (<nul set /p =[!draw_options_offset!;1f!display_message_color![7m!display_message_msg![0m [J)
if "%3"=="wait" timeout /t 3 >nul
exit /b





::Display help on screen. [noLoad]
:help
if not "%1"=="noLoad" (
	cls
	if not defined nomode mode con cols=120 lines=40
)
echo [96mVIRINT !ver! - Help[0m[K
echo Script that allows the user to paint on a canvas on the Windows console with different colors.
echo Supporting the ability to save and load files generated by this script.
echo [90mWritten by DarviL (David Losantos) in batch. Using version !ver! (Build !build!)
echo Repository available at: "[4mhttps://github.com/L89David/DarviLStuff[24m"[0m
echo:
echo [96mVIRINT [/N] [/S NxN] [/L file] [/C][0m
echo:
echo   [96m/N :[0m Create a new canvas.
echo   [96m/S :[0m Select the size of the canvas to create. (Only useful when creating a new canvas)
echo   [96m/L :[0m Load the specified file.
echo   [96m/C :[0m Compress the specified file.
echo:
echo The script shows a quick menu if it is launched normally, so using the parameters above is not necessary.
echo:
echo   [96m/NoCompression :[0m Disables the file compression algorithm. This will make file saving much faster,
echo                    but files will be much bigger, and they will take more time to load.
echo   [96m/NoMode :[0m Stops resizing the window automatically.
echo   [96m/CHKUP :[0m Check if you are using the minimum necessary Windows build for ANSI escape codes
echo            and the newest versions of VIRINT.
echo:
echo [94mTools provided for working on the canvas:
echo   - Brush (B) :[0m Toggle the brush. Enabling it will start painting on the canvas with the current
echo                 color selected (Color A).
echo   [94m- Erase (E) :[0m Toggle the eraser. Enabling it will start erasing content on the canvas. This
echo                 tool only works when used with the Brush tool.
echo   [94m- Color (C) :[0m Select a color from the list, or select a custom RGB value. After selecting a
echo                 color, it will be displayed at the Info bar (Color A). If you select a new color,
echo                 The previously selected color will be saved in Color B.
echo   [94m- Toggle Color (T) :[0m Toggle between the primary and secundary selected colors (Color A and B).
echo   [94m- Coord (F) :[0m Select a coordinate to move the cursor on the canvas (x-y).
echo   [94m- Fill (X) :[0m Fill the current canvas with the Color A. If the Erase tool is enabled, the entire
echo                canvas will be cleared.
echo:
echo Pressing 'R' will reload the UI (Useful if the canvas ended up getting messy). You can open this help page
echo from the canvas pressing 'H'. Dragging a file onto the script will make VIRINT attempt to load it.

if not "%1"=="noLoad" (
	pause>nul
	call :file_reload
)
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