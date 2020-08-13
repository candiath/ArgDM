#!/bin/bash
# -*- coding: utf-8 -*-
#SOURCES
source ./users_source.sh
source ./limitter_source.sh



mainFuntion=main
# Defino la función
barra="========================================"
# Menú usuarios

function limitterMENU() {
	echo "LIMITANDO======================================================================"
dir=/root/ArgDM
while [[ true ]]; do
    declare -a PIDs
    PIDs=(`ps aux | grep -i dropbear | awk '{print $2}'`)
    #echo > /tmp/monitor # Cambiar por Touch!!!!!!!!!!!!!!!!!!!
    cat /dev/null > /tmp/monitor
    for PID in "${PIDs[@]}" # Por cada proceso de DropBear
    do
      temp=$(cat /var/log/auth.log | grep "Password auth succeeded" | grep "dropbear\[$PID\]")
      echo $temp >> /tmp/monitor
      local activeConnections=$(echo $temp | awk -F"'" '{print $2}')

  # Sumar
      declare -A connections # connections[USERNAME]:NumberOfActiveConnections
      for item in ${activeConnections}; do
          if [[ -n "$item"  ]]; then #Verificar si es necesario este paso!!!!!!!!!!!!!!!!
                  echo "en if ITEM vale $item"
                  [ -n "${connections[$item]}" ] && connections[$item]=$((${connections[$item]} + 1)) || connections[$item]=1
          fi
      done
    done

  # Leo limites
      declare -A loginLimits
      for line in $(cat $dir/limits); do
        loginLimits[$(echo $line | awk -F : '{print $1}')]=$(echo $line | awk -F : '{print $2}')
      done

      for user in ${!connections[@]}
      do
        
        if [[ ${connections[$user]} > ${loginLimits[$user]} ]]; then # Si exedió el limite
          echo "$user excede limite!!!!!!!!!!!!!!!!!!!!!!"
          for item in $(grep $user /tmp/monitor | awk -F '[][]' '{print $2}') # por cada conexion del usuario
          do
            echo "MUERE a $item     =================================="
            process=$(echo $item) # Mato la conexión
            kill $process 2> "$errDir/kill \"$process\" $(date +"%F--%T")"
          done
  # Quería pendiente bloquear el usuario por algunos segundos
        fi
      done
      unset user
  unset connections
  unset loginLimits
  sleep 5s
done
}


function limitterEnabler() {
  echo "soy el limitador"
  #[ ! getLimitterStatus ] && screen -d -m -t Limitter limitter && return 1 || return 0
  #if [[ ! getLimitterStatus ]]; then
    screen -d -m -t Limitter ./limitest
		limitter
    echo "activado!"
    sleep 2s
  #fi
}

function limitterDisabler() {
  result=0
  for item in $(ps x | grep -i "limitter" | grep -i "screen" | awk '{print $1}'); do
    kill $item
    result=1
  done
  return $result
}

function getLimitterStatus() {
  if [[ $(ps x | grep -i "limitter" | grep -i "screen") ]]; then
    return 1
  else
    return 0
  fi
}

function users_mgr() {
	while [[ : ]]; do
	clear
	echo -e "========================================"
	echo -e "             Menú Usuarios"
	echo -e "========================================"
	echo -e "[1] Crear usuario"
	echo -e "[2] !Modificar usuario"
	echo -e "[3] !Eliminar usuario"
	echo -e "[4] !Crear prueba"
	echo -e "[5] Listar todos los usuarios"
	echo -e "[6] Listar usuarios conectados"
	echo -e "[7] Iniciar limitador de conexiones!"
	#	echo -e "[8]"
	#	echo -e "[9]"
	#	echo -e "[10]"
	echo -e "[0] Atrás"
	echo -n "Elija una opción: "
	read choice

	case $choice in
		1 )
		newUser
		;;
		2 )
		echo "eligió servicios"
		sleep 1s
		;;
		3 )
		dropUser
		;;
		4 )
		tempUser
		;;
		5 )
		echo "eligió 5"
		sleep 1s
		;;
		6 )
		monitorear
		;;
		7 )
		listarOnlines
		;;
		0 )
		clear
		main
		;;
	esac
	done
}

function monitorear {
	monitor
}

function tempUser {
	arr=( [1]='Nombre de usuario: ' [2]="Clave: " [3]="Duración (días): " [4]="Límite de conexiones: " [5]= "IP: " [6]= "Fecha de expiración: ")
	echo -n ${arr[1]}
	read name
	echo "TEST name => $name"
	if [ $(grep $name /etc/passwd) ] ; then
		clear
		echo "El usuario \"$name\" ya existe"
		echo "Por favor, ingrese otro nombre de usuario"
		tempUser
	fi
	echo -n ${arr[2]}
	read pass
	echo -n ${arr[3]}
	read days
	if [ $days = "" ] ; then
		$days=30
		echo "Duración establecida en 30 minutos por defecto"
		sleep 2s
	fi
	CreateUser $name $pass $days
}

# CreateUser COMMIT
function CreateUser {
	name=$1
	pass=$2
	days=$3
	useradd -M -s /bin/false $name &&
#	(echo $pass; echo $pass)|passwd $name #2>/dev/null
	(echo $pass; echo $pass)|passwd $name 			 ||
	echo "Se ha producido un error al crear el usuario" &&
	$mainFuntion
}

function dropUser {
	back=users_mgr
	arr=( [1]='Nombre de usuario: ' [2]="Clave: " [3]="Duración (días): " [4]="Límite de conexiones: " [5]= "IP: " [6]= "Fecha de expiración: ")
	echo -n ${arr[1]}
	read name
	if [ !$(grep $name /etc/passwd) ] ; then
		DeleteUser $name && echo "Usuario eliminado" && sleep 2s || echo -e "ERROR FATAL!\n Saliendo..." && sleep 3s && exit
	fi
}

# DeleteUser COMMIT
function DeleteUser {
	name=$1
	userdel --force $name
}


function newUser {
	clear		#backtick mezclado con comillas dobles!!!!
	arr=( [1]='Nombre de usuario: ' [2]="Clave: " [3]="Duración (días): " [4]="Límite de conexiones: " [5]= "IP: " [6]= "Fecha de expiración: ")
	echo -n ${arr[1]}
	read name
	if (( $(grep $name /etc/passwd | wc -l) == 0 )); then
		echo -n ${arr[2]}
		read pass
		echo -n ${arr[3]}
		read days
		echo -n ${arr[4]}
		read max_logins
		create_user $name $pass $days $max_logins
	else
		echo "EL USUARIO YA EXISTE"
		echo -n "Presione enter para regresar"
		read
		break
	fi


	#createUser $name
	#setPwd $name $pass
	#setDays $name $days
	#setLogins $max_logins

}



function create_user {
	clear
	if (( $(grep $name /etc/passwd | wc -l) == 0 )); then
		createUser $name
		setPwd $name $pass
		setDays $name $days
		#setLogins
		echo "Usuario creado!"
		echo ${arr[1]}$name
		echo ${arr[2]}$pass
		echo ${arr[3]}$days
		echo ${arr[4]}$max_logins
		echo ${arr[5]}"<IP DE MI SERVIDOR>"
		echo -n "Presione enter para continuar"
		read
		users_mgr
	fi
}

# PROGRAMA PRINCIPAL
function main {
	while [[ : ]]; do
		clear
		echo -e "========================================"
		echo -e "            Menú principal"
		echo -e "========================================"
		echo -e "[1] Administrar usuarios"
		echo -e "[2] Administrar servicios"
		echo -e "[3] Configuraciones"
		echo -e "[4] "
		echo -e "[5] Activar LIMITADOR DE CONEXIONES"
		echo -e "[6] Desactivar LIMITADOR DE CONEXIONES"
	#	echo -e "[7]"
	#	echo -e "[8]"
	#	echo -e "[9]"
	#	echo -e "[10]"
		echo -e "[0] Salir"
		echo -n "Elija una opción: "
		read choice

		case $choice in
			1 )
			users_mgr
			;;
			2 )
			services
			;;
			3 )
			echo "configuraciones"
			sleep 1s
			;;
			4 )
			echo "eligió 4"
			sleep 1s
			;;
			5 )
			limitterEnabler
			;;
			6 )
			limitterDisabler
			;;
			0 )
			clear
			echo "Hasta pronto!"
			exit 0
			;;
		esac
	done
}

main


function services {
	while [[ : ]]; do
		clear
		echo -e "========================================"
		echo -e "            Menú servicios"
		echo -e "========================================"
		echo -e "[1] Instalar Dropbear"
		echo -e "[0] Atrás"
		echo -n "Elija una opción: "
		read choice

		case $choice in
			1 )
			dropbear_install
}

function dropbear_install {
	echo "instalando dropbear" && sleep 1s
	apt install dropbear -y

}


Tl
Tu
