#!/bin/bash

read -e -p "search:" -i "test" search
for line in $(cat /root/ArgDM/limits); do
	aux=$(echo $line | awk -F : '{print $1}')
	if [[ $search == $aux ]]; then
		echo "line: $line"
		echo "aux: $aux"
		sed -i "/$line/d" /root/ArgDM/limits
	fi
done
