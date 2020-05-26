@echo off
title Autobackup
chcp 65001
set /a iteration=0
cls

:select_file_original
set file_original_path=%1
echo:
if not defined file_original_path echo No file has been dragged to this program. Press any key to exit. &pause >Nul &exit
echo File added succesfully.


:select_backup_delay
echo:
echo Enter the delay per backup (In minutes):
set /p backup_delay_input=
if not defined backup_delay_input echo Incorrect argument. &goto select_backup_delay
set /a backup_delay=%backup_delay_input%*60


:select_file_name
echo:
echo Enter the name of the file (including extension):
set /p select_file_name=
if not defined select_file_name echo Incorrect argument. &goto select_file_name


:pre_start
if exist "backups/b1-%select_file_name%" (
	echo:
	echo Detected backup from another period. Press any key to remove every backup and start a new backup process.
	pause>nul
	del "backups" /f /q
	goto pre_start
) else (
	if not exist "backups" mkdir "backups"
	(
	echo Autobackup - DarviL
	echo:
	echo File selected: %file_original_path%
	echo Delay selected: %backup_delay_input% minutes.
	echo Start time: %time%
	echo ________________________________________
	echo:
	) > "backups/log.txt"

	cls
	echo File selected: %file_original_path%
	echo Delay selected: %backup_delay_input% minutes.
	echo ________________________________________
)


:start
echo:
echo Backing up file...

set /a iteration=1+%iteration%
set /a iteration_last=%iteration%-1
copy %file_original_path% "backups" >nul
ren "backups\%select_file_name%" "b%iteration%-%select_file_name%"

echo File has been backed up. [Nº%iteration%]
echo File has been backed up. [Nº%iteration%] [%time%] >> backups/log.txt
timeout "%backup_delay%" /nobreak >nul
goto start