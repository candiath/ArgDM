#!/bin/bash
# -*- coding: utf-8 -*-
#SOURCES
source ./users_source.sh
source ./limitter_source.sh
source ./test.sh

check=1
echo -e "\e[0m"
mainViewFuntion=mainView
# Defino la función
barra="========================================"
# Menú usuarios


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


function dropUser {
	back=userView
	arr=( [1]='Nombre de usuario: ' [2]="Clave: " [3]="Duración (días): " [4]="Límite de conexiones: " [5]= "IP: " [6]= "Fecha de expiración: ")
	echo -n ${arr[1]}
	read name
	if [ !$(grep $name /etc/passwd) ] ; then
		DeleteUser $name && echo "Usuario eliminado" &&
		sed -i "s/$name:.*/$name:0/" /root/ArgDM/limits &&
		sleep 2s || echo -e "ERROR FATAL!\n Saliendo..." && sleep 3s && exit
	fi
}
# DeleteUser COMMIT
function DeleteUser {
	name=$1
	userdel --force $name
	# Borrar clave en archivo
}
function newUserForm {
	clear		#backtick mezclado con comillas dobles!!!!
	echo -e "\e[2mAcordate de que en cualquier momento podés cancelar la \e[0m"
	echo -e "\e[2moperación actual con ctrl + c \e[0m "
	arr=( [1]='Nombre de usuario: ' [2]="Clave: " [3]="Duración (días): " [4]="Límite de conexiones: " [5]= "IP: " [6]= "Fecha de expiración: ")
	echo -n ${arr[1]}
	read name
	if (( $(userExist $name) == 0 )); then
		echo -n ${arr[2]}
		read pass
		echo -n ${arr[3]}
		read days
		echo -n ${arr[4]}
		read max_logins
		createUser $name $pass $days $max_logins
	else
		echo "EL USUARIO YA EXISTE"
		echo -n "Presioná ENTER para volver a intentarlo"
		holder
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
		if [[ $(grep $name /root/ArgDM/limits | wc -l) == 0 ]]; then
			setLogins $name $max_logins
		else
			sed -i "s/$name:.*/$name:$max_logins/" /root/ArgDM/limits
		fi

		echo "Usuario creado!"
		echo ${arr[1]}$name
		echo ${arr[2]}$pass
		echo ${arr[3]}$days
		echo ${arr[4]}$max_logins
		echo ${arr[5]}$(hostname -I)
		echo -n "Presione enter para continuar"
		read
		userView
	fi
}
# function setPwd() {
# 	(echo $pass; echo $pass)|passwd $name 2>/dev/null
# }
# function setDays() {
# 	usermod -e $(date '+%C%y-%m-%d' -d "+ $2 days") $1
	# queda pendiente remover las contras del archivo!!!!!!!!!!!!!!!!!!!
#}
# function setLogins() {
# 	#$dir="/root/ArgDM"
# 	echo "$1:$2" >> /root/ArgDM/limits
# }
# PROGRAMA PRINCIPAL


function services() {
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
			;;
		esac
  done
}
function dropbear_install {
	echo "instalando dropbear" && sleep 1s
	apt install dropbear -y

}
# VIEWS
function mainView {
	while [[ : ]]; do
		clear
		[ $(getLimitterStatus) -eq 1 ] && echo -e "Limitador \e[32mON\e[39m" || echo -e "Limitador \e[5m\e[31mOFF\e[39m\e[25m"
		echo -e "\e[36m=========================================\e[39m"
		echo -e "\e[97m=================\e[40;38;5;226m ArgDM \e[97m=================\e[39m"
		echo -e "\e[36m=========================================\e[39m"
		echo -e "[1] Administrar usuarios"
		echo -e "[2] Administrar servicios"
		echo -e "[3] Configuraciones"
		echo -e "[4] "
		echo -e "[5] Activar LIMITADOR DE CONEXIONES"
		echo -e "[6] Desactivar LIMITADOR DE CONEXIONES"
		echo -e "[7] TEST conn limitter"
		echo -e "[8] TEST conn usuarios"
		echo -e "[9] INCIAR TEST GENERAL"
	#	echo -e "[10]"
		echo -e "[0] Salir"
		echo -n "Elija una opción: "
		read choice

		case $choice in
			1 )
			userView
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
			7 )
			Tl
			;;
			8 )
			Tu
			;;
			9 )
			tryUser
			;;
			0 )
			clear
			echo "Hasta pronto!"
			exit 0
			;;
		esac
	done
}
function userView() {
	while [[ : ]]; do
	clear
	echo -e "\e[36m========================================\e[39m"
	echo -e "\e[97m===============\e[40;38;5;226m Usuarios\e[97m ===============\e[39m"
	echo -e "\e[36m========================================\e[39m"
	echo -e "[1] Crear usuario"
	echo -e "[2] !Modificar usuario"
	echo -e "[3] Eliminar usuario"
	echo -e "[4] !Crear prueba"
	echo -e "[5] Listar todos los usuarios"
	echo -e "[6] Listar usuarios conectados"
	#echo -e "[7] Iniciar limitador de conexiones!"
	#	echo -e "[8]"
	#	echo -e "[9]"
	#	echo -e "[10]"
	echo -e "[0] Atrás"
	echo -n "Elija una opción: "
	read choice

	case $choice in
		1 )
		newUserForm
		;;
		2 )
		echo "eligió servicios"
		sleep 1s
		;;
		3 )
		delUserForm
		;;
		4 )
		tempUser
		;;
		5 )
		userListForm
		;;
		6 )
		listarOnlines 1
		;;
		7 )
		listarOnlines
		;;
		0 )
		clear
		mainView
		;;
	esac
	done
}


mainView