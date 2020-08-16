#!/bin/bash
#USERS SOURCE
# Useful commands:
#       chage -l $user
# https://www.cyberciti.biz/faq/linux-howto-check-user-password-expiration-date-and-time/


function createUser() { 
  #Validación pendiente del comando!!!
  if [[ !$(userExist $1) ]]; then
    useradd -M -s /bin/false $1
    setPwd $1 $2
    #setDays $1 $3
    setLogins $1 $4
  else
    echo "Ya se ha registrado un usuario con el nombre $1"
  fi
  #$mainFuntion
  # Tengo que buscar una mejor manera de volver al menú anterior!!!!!
  # Acabo de notar que no es necesario volver al menú anterior (creo)
  # Tendré que probar cómo funciona bash      
}

function setPwd() {
        (echo $2; echo $2)|passwd $1 2>/dev/null
        if [[ $? -ne 0 ]]; then
          echo "ERROR en setPwd con user $1 y pass $2 | $(date +'%F--%T')" >> /root/ArgDM/autolog.log
        fi
        #echo "EXIT IS $?"
        # Revisar qué errores pueden producirse acá
}
function setDays() {
        usermod -e $(date '+%C%y-%m-%d' -d "+ $2 days") $1
        #SERÁ MEJOR USAR CRON PARA BLOQUEAR ESTO
}

function setLogins() {
  dir=/root/ArgDM
  # $1 = name
  # $2 = limit
  echo "Check ==> He recibido "$# " parámetros, que son: "$*
  if [[ $(grep $1 /root/ArgDM/limits | wc -l) == 0 ]]; then
    echo "$1:$2" >> "$dir/limits"
  else
    sed -i "s/$1:.*/$1:$2/" /root/ArgDM/limits
  fi
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

function getLogins() {
  echo "$(grep "\b$1:" /root/ArgDM/limits | awk -F : '{print $2}')"
}

function userExist() {
   [ $(grep "\b$1:" /etc/passwd | wc -l) -eq 1 ] && echo "1" || echo "0" #echo "existe" || echo "no existe"
   # $(grep pepe /etc/passwd) también puede funcionar
}

function getSystemUserList() {
   
  for i in $(grep -v nobody /etc/passwd | awk -F : '{if ( $3 > 999 ) print $1}'); do
    echo $i
  done
}

function userListForm() {
  clear
  espacio=20
  printf "%-${espacio}s%s\n" "Nombre" "límite";
  
  for item in $(getSystemUserList); do
    local logins
    logins=$(getLogins $item)
    if [[ $logins == "" ]]; then
      printf "%-${espacio}s%s\n" $item "Desconocido :/"
    else
      printf "%-${espacio}s%s\n" $item "$logins"
    fi
  done
  echo ""
  holder
}


function delUserForm() {
  # CARGO ARRAY DE USUARIOS
  declare -A userlist
  local i=0
  for item in $(getSystemUserList); do
    i=$(($i + 1))
    userlist[$i]=$item
  done

  # IMPRIMO UN NUMERO POR CADA USUARIO
  for index in ${!userlist[@]}; do
    echo "[$index] ${userlist[$index]}"
  done

  echo "[0] Cancelar operación"
  echo -n "Ingresá un número:"
  read user
  echo \""${userlist[$user]}\""
  if [[ $user -eq 0 ]]; then
    return 0
  elif [[ ${userlist[$user]} == "" ]]; then
    echo " ${userlist[$user]} "
    echo "No pude entender eso :/"
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  else
    delUser ${userlist[$user]}
  fi
  holder
}

function delUser() {
  if [[ $(userExist $1) ]]; then
    userdel -f $1 ## && echo "Eliminé a $1!"
    sed -i "/$1/d" /root/ArgDM/limits #!!!!!!!!!!!!!!!!!!!!!!!!!!!
  else
    echo "O-Oh! Parece que el usuario ya no existe!"
  fi
}

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
  #echo "Check ==> He recibido "$# " parámetros, que son: "$*
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
  holder
}
function imprimirLogins() {
  #echo "El número de cuentas conectadas es de ${#connections[*]}."
  local espacio=10
  for key in ${!connections[*]}; do
    printf "%-${espacio}s%s\n" $key ${connections[$key]}"/$(getLogins $key)"
  done
}

function countLogins() {
  for item in ${connections[*]}; do
    sum=$(($sum + $item))
  done
  echo "$sum"
}


function monitor() {
  echo "monitor"
  listarOnlines 1
}





function Tu() {
  echo "user funciona"
  holder
}

function holder() {
  echo "Presioná ENTER para continuar ;)"
  read
}