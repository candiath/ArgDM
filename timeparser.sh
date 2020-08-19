#!/bin/bash


for char in "1h 30m"; do
	if [[ : ]]; then
		if [[ $char =~ ^[0-9]+$ ]]; then
			number="${1}$char"
		elif [[ $char == "h" ]]; then
				hours=$number
				unset number
		elif [[ $char == "m" ]]; then
				minutes=$number
				unset number
		fi
	fi

done
echo "$hours horas y $minutes minutos."