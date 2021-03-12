#!/bin/bash
#Written by David Losantos.
#Version 1.0

[[ -f "log" ]] && rm log



function Help {
	echo "	-s : Select max random delay. Default is 40."
	echo "	--debug : Debug mode."
}




function displayMsg {
	case $1 in
		"red" ) color=91;;
		"green" ) color=92;;
		"yellow" ) color=33;;
	esac
	echo "[${color}m$2"
}





#Procesar los parámetros introducidos por el usuario.
for param in $@; do
	case $param in
		"--debug" )
			show_debug=1
		;;
		"-s" )
			shift 1
			maxSpeed=$1
		;;
		"--help" | "-h" )
			Help
			exit
		;;
	esac
done

[[ ! -n $maxSpeed ]] && maxSpeed=40







#Selección de color aleatorio. Selecciona un color aleatorio desde 0 a 14.
#También selecciona una velocidad aleatoria, además de limpiar la pantalla.
function collide {
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
	[[ -n $show_debug ]] && echo "${color}Colisión! Estableciendo retraso a $delay.[0m" >> log
	clear
}





mode_Y="+"
mode_X="+"
color="[97m"
let cursor_X=-1

while [ True ]; do
	#Obtener el tamaño de la ventana.
	let window_lines=`tput lines`
	let window_cols=`tput cols`-2

	#Sumar o restar 1 a las coordenadas del cursor actuales. (La variable 'mode' puede contener '+' o '-')
	let cursor_X${mode_X}=2
	let cursor_Y${mode_Y}=1

	#Comprobar si el cursor se encuentra colisionando con uno de los bordes de la ventana. Cambiar el tipo de
	#operación para que sea una resta o una suma, y además llamar a la función 'collide'.
	[[ $cursor_Y -ge $window_lines ]] && { mode_Y="-"; collide; }
	[[ $cursor_Y -le 1 ]] && { mode_Y="+"; collide; }
	[[ $cursor_X -ge $window_cols ]] && { mode_X="-"; collide; }
	[[ $cursor_X -le 1 ]] && { mode_X="+"; collide; }

	#Mostrar el gráfico en pantalla con las coordenadas y color calculados.
	[[ -n $show_debug ]] && echo "[0m[K[7m[HPOS: X$cursor_X Y$cursor_Y[0m"
	printf "$color[$cursor_Y;${cursor_X}f██"

	#Realizar una pequeña espera por cada vuelta al bucle.
	for x in `seq 0 $delay`; do
		ping localhost -c 1 > /dev/null
	done
done

