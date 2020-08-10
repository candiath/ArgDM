#!/bin/bash
#USERS SOURCE
# Useful commands:
#	chage -l $user
# https://www.cyberciti.biz/faq/linux-howto-check-user-password-expiration-date-and-time/


function listarOnlines {
data=( `ps aux | grep -i dropbear | awk '{print $2}'`);

declare -A connections

echo -e "Calculando...\n"
for PID in "${data[@]}"
do
		username=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}')
#		username=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | awk -F "'" '{print $2}')
		# [ "$aux" = "" ]
		# -n significa que la longitud del string no es cero

		# Sumar
		for item in ${username}; do
			if [[ -n "$item"  ]]; then #Verificar si es necesario este paso
				echo "ITEM ES $item"
				[ -n "${connections[$item]}" ] && connections[$item]=$((${connections[$item]} + 1)) || connections[$item]=1
			fi
		done


		#echo "check $PID";
        #NUM1=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l`;
        #echo "el cat es= "$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]")
        #echo "Num es: $NUM1"
        #USER=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}'`;
        #IP=`cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $12}'`;
done

echo -e "Calculado!\n"
echo "El número de usuarios conectados es de ${#connections[*]}."
echo "======================================"
espacio=10



for index in ${!connections[*]}; do
	#echo "$index - ${connections[$index]}\n"
	printf "%-${espacio}s%s\n" $index ${connections[$index]}"/?"
done
}

listarOnlines

function createUser() {
	#Validación pendiente del comando!!!
	useradd -M -s /bin/false $1 ||
	echo "Se ha producido un error al crear el usuario"
	#$mainFuntion
	# Tengo que buscar una mejor manera de volver al menú anterior!!!!!
	# Acabo de notar que no es necesario volver al menú anterior (creo)
	# Tendré que probar cómo funciona bash
}

function setPwd() {
	(echo $2; echo $2)|passwd $1
	# Revisar qué errores pueden producirse acá
}

function setDays() {
	# $name; $days
	expDate=$(date '+%C%y-%m-%d' -d "+ $2 days")
	usermod -e $expDate $1
}

#function setLogins() {
	# Active logins:
	# ps -u $usur |grep sshd |wc -l
	################################################
	# Separador para formar columnas alineadas
	# espacio=30
	# printf "%-${espacio}s%s" uno dos
	# uno                           dosroot@VPS16:~#
	################################################

#}
