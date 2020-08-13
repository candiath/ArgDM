#!/bin/bash
#USERS SOURCE
# Useful commands:
#       chage -l $user
# https://www.cyberciti.biz/faq/linux-howto-check-user-password-expiration-date-and-time/


function listarOnlines() {
  local data=( `ps aux | grep -i dropbear | awk '{print $2}'`);
  for PID in "${data[@]}"
  do
  local userlist=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk -F"'" '{print $2}')
  # -n significa que la longitud del string no es cero

  # Sumar
  declare -A connections
  for item in ${userlist}; do
          if [[ -n "$item"  ]]; then #Verificar si es necesario este paso!!!!!!!!!!!!!!!!
                  [ -n "${connections[$item]}" ] && connections[$item]=$((${connections[$item]} + 1)) || connections[$item]=1
          fi
  done
  done
  echo "Check ==> He recibido "$# " parámetros, que son: "$*
  case $1 in
          1 )
          imprimirLogins;;
          2 )
          echo ${#connections[*]};;
          3 )
          countLogins;;
          4 )
          imprimirLogins;;
          #countLogins;;

  esac
  echo "presine algo pra cintinuar"
  read
}


function imprimirLogins() {

        echo "El número de cuentas conectadas es de ${#connections[*]}."
        echo "======================================"
        espacio=10
        for index in ${!connections[*]}; do
                printf "%-${espacio}s%s\n" $index ${connections[$index]}"/?"
        done
}

function countLogins() {
        for item in ${connections[*]}; do
                sum=$(($sum + $item))
        done
        echo "Total de logins es $sum"
}


function monitor() {
	echo "entra monitor"
    listarOnlines 1
}

function userExist() {
        [ $(grep $name /etc/passwd | wc -l) -gt 0 ] && return 1 || return 0 #echo "existe" || echo "no existe"
}

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

function setLogins() {
	dir=/root/ArgDM
	# $1 = name
	# $2 = limit

	grep -v "$1" $dir/limits > $dir/limits
	echo "$1:$2" >> $dir/limits







        # Active logins:
        # ps -u $usur |grep sshd |wc -l
        #
        # Logout ssh users (no dropbear)
        # pkill -KILL -u pepe

        ################################################
        # Separador para formar columnas alineadas
        # espacio=30
        # printf "%-${espacio}s%s" uno dos
        # uno                           dosroot@VPS16:~#
        ################################################

}


function Tu() {
  echo "user funciona"
  sleep 1s
}
