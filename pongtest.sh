#!/bin/bash
#Written by David Losantos.

ver=1.1.1
[[ -f "log" ]] && rm log



function Help {
	echo -e "pongtest.sh [-s num] [-n] [--debug]\n"
	echo -e "-s\t\tSelect max random delay. Default is 40."
	echo -e "-n\t\tDo not clear the screen when colliding."
	echo -e "--debug\t\tDebug mode. Displays coordinates and creates a log file.\n"
	echo "Written by David Losantos (DarviL). Version $ver."
}




function displayMsg {
	case $1 in
		"red" ) color=91;;
		"green" ) color=92;;
		"yellow" ) color=33;;
	esac
	echo -e "\e[${color}m$2"
}





#Process the parameters that the user entered.
while [ "$1" ]; do
	case "$1" in
		"--debug" )
			show_debug=1
		;;
		"-s" )
			maxSpeed="$2"
		;;
		"-n" )
			noClear=1
		;;
		"--help" | "-h" )
			Help
			exit
		;;
	esac
	shift
done



[[ -z $maxSpeed ]] && maxSpeed=40







#Select a random color from 0 to 14.
#It also selects a random delay, apart from clearing the screen (if enabled).
function Collide {
	case `expr $RANDOM % 14` in
		0)	color="[34m";;
		1)	color="[32m";;
		2)	color="[36m";;
		3)	color="[31m";;
		4)	color="[35m";;
		5)	color="[33m";;
		6)	color="[37m";;
		7)	color="[90m";;
		8)	color="[94m";;
		9)	color="[92m";;
		10)	color="[96m";;
		11)	color="[91m";;
		12)	color="[95m";;
		13)	color="[93m";;
		14)	color="[97m";;
	esac

	let delay=`expr $RANDOM % $maxSpeed`
	[[ -n $show_debug ]] && echo "${color}Collision! Setting delay to $delay.[0m" >> log
	[[ ! -n $noClear ]] && clear
}




clear
mode_Y="+"
mode_X="+"
color="[97m"
let cursor_X=-1

while true; do
	#Get the current size of the window.
	let window_lines=`tput lines`
	let window_cols=`tput cols`-2

	#Add or subtract to the current coordinates. (The 'mode' variable can contain '+' or '-')
	let cursor_X${mode_X}=2
	let cursor_Y${mode_Y}=1

	#Check if the cursor is colliding with the borders of the window.
	#Change the type of operation to do in the next loop, depending on where the cursor collided.
	#Also calls the 'Collide' function for every time there's a collision.
	[[ $cursor_Y -ge $window_lines ]] && { mode_Y="-"; Collide; }
	[[ $cursor_Y -le 1 ]] && { mode_Y="+"; Collide; }
	[[ $cursor_X -ge $window_cols ]] && { mode_X="-"; Collide; }
	[[ $cursor_X -le 1 ]] && { mode_X="+"; Collide; }

	#Show the sprite on screen with the color and coordinates processed.
	[[ -n $show_debug ]] && echo "[0m[7m[HPOS: X$cursor_X Y$cursor_Y[0m[K"
	printf "$color[$cursor_Y;${cursor_X}f██"

	#Realizar una pequeña espera por cada vuelta al bucle.
	for x in `seq 0 $delay`; do
		ping localhost -c 1 > /dev/null
	done
done
