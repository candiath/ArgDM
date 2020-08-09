#!/bin/bash
#USERS SOURCE
# Useful commands:
#	chage -l $user
# https://www.cyberciti.biz/faq/linux-howto-check-user-password-expiration-date-and-time/
function createUser(){
	#Validación pendiente del comando!!!
	useradd -M -s /bin/false $1 ||
	echo "Se ha producido un error al crear el usuario" &&
	#$mainFuntion
	# Tengo que buscar una mejor manera de volver al menú anterior!!!!!
	# Acabo de notar que no es necesario volver al menú anterior (creo)
	# Tendré que probar cómo funciona bash
}

function setPwd(){
	(echo $2; echo $2)|passwd $1
	# Revisar qué errores pueden producirse acá
}

function setDays(){
	# $name; $days
	expDate=$(date '+%C%y-%m-%d' -d "+ $2 days")
	usermod -e $expDate $1
}

function setLogins(){
	# Active logins: 
	# ps -u $usur |grep sshd |wc -l
	################################################
	# Separador para formar columnas alineadas
	# espacio=30
	# printf "%-${espacio}s%s" uno dos
	# uno                           dosroot@VPS16:~#
	################################################
	
}
