#!/bin/bash
#Written by David Losantos.
#Version 1.0

[[ -n $1 ]] && parm1=$1 || read parm1



#Usage: displayMsg color "string".
function displayMsg {
	case $1 in
		"red" ) color=91;;
		"green" ) color=92;;
		"yellow" ) color=33;;
	esac
	echo "[${color}m$2[0m"
}



#Display help.
function showHelp {
    echo "IPv4 class and type detector."
    echo -e "A valid IPv4 address must be specified as a parameter or as a console input,\nsuch as pipe redirection. Usage:\n"
    echo -e "ipclass.sh --self | xxx.xxx.xxx.xxx\n"
    echo -e "Examples:\n\t- ipclass.sh 172.23.10.1\n\t- echo 10.23.1.2 | ipclass.sh\n\t- ipclass.sh --self"
}



#Split the IP Address in $1 into 4 variables named "byteN".
function splitAddress {
    [[ ! $1 =~ ^.*\. ]] && displayMsg red "ERROR: Invalid IPv4 syntax." && exit
    for x in `seq 1 4`; do
        currentByte=`cut -d"." -f$x <<< $1`
        [[ ! -n $currentByte ]] && displayMsg red "ERROR: Missing byte $x." && exit
        if [[ ! $currentByte =~ ^[0-9]*$ ]] || [[ $currentByte -gt 255 ]] || [[ $currentByte -lt 0 ]]; then
            displayMsg red "ERROR: Invalid value '$currentByte' at byte $x."
            exit
        else let byte$x=$currentByte
        fi
    done
}



#Show the result that we got styled.
function displayResult {
    case $class in
        1) msgclass="A";;
        2) msgclass="B";;
        3) msgclass="C";;
        4) msgclass="D";;
        5) msgclass="E";;
    esac

    case $type in
        0) msgtype="Public";;
        1) msgtype="Private";;
    esac
    displayMsg yellow "IP Address: $byte1.$byte2.$byte3.$byte4"
    displayMsg green "Class: $msgclass"
    displayMsg green "Type: $msgtype"
}





[[ $parm1 == "--help" ]] && showHelp && exit
[[ $parm1 == "--self" ]] && parm1=`ifconfig eno1 | grep "inet " | cut -d" " -f10`

splitAddress $parm1

#Calculate the classes and types.
type=0
if [[ $byte1 -lt 128 ]]; then
    class=1
    [[ $byte1 -eq 10 ]] && type=1
elif [[ $byte1 -lt 192 ]]; then
    class=2
    if [[ $byte1 -eq 172 ]]; then
        if [[ $byte2 -ge 16 ]] && [[ $byte2 -le 31 ]]; then
            type=1
        fi
    fi
elif [[ $byte1 -lt 224 ]]; then
    class=3
    if [[ $byte1 -eq 192 ]]; then
        if [[ $byte2 -eq 168 ]]; then
            type=1
        fi
    fi
elif [[ $byte1 -lt 240 ]]; then
    class=4
else
    class=5
fi

displayResult