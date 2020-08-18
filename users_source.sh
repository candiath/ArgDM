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
    # setDays $1 $3
    # setLogins $1 $4
    setLimits $1 $3 $4
  else
    echo "Ya se existe un usuario con el nombre $1"
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

function setLimits() {
        #usermod -e $(date '+%C%y-%m-%d' -d "+ $2 days") $1
# $name $days $max_logins

  dir=/root/ArgDM 
  echo "Check ==> He recibido "$# " parámetros, que son: "$*
  if [[ $(grep $1 /root/ArgDM/limits | wc -l) == 0 ]]; then
    #echo "$1:$3:$(date +"%Y%m%d%H%M" -d "+ $2 days")" >> "$dir/limits"
    echo "$1:$3:$(date +"%Y%m%d" -d "+ $2 days"):$(date +"%H%M")" >> "$dir/limits"
  else
    sed -i "s/\b$1:.*/$1:$3:$(date +"%Y%m%d" -d "+ $2 days"):$(date +"%H%M")/" /root/ArgDM/limits # TESTEAR POSIBLES FALLAS ACÁ!!!!!!!!!
  fi


}

function getLimits() { # max_logins:fecha_expiración
  echo $(grep $1 /root/ArgDM/limits | awk -F : '{print $2":"$3":"$4}')
}

# function setLogins() {
  
#   # $1 = name
#   # $2 = limit
  
#     # Active logins:
#         # ps -u $usur |grep sshd |wc -l
#         #
#         # Logout ssh users (no dropbear)
#         # pkill -KILL -u pepe

#         ################################################
#         # Separador para formar columnas alineadas
#         # espacio=30
#         # printf "%-${espacio}s%s" uno dos
#         # uno                           dosroot@VPS16:~#
#         ################################################
# }

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
  if [[ $(getSystemUserList | wc -l) -gt 0 ]]; then
    espacio=20
    clear
    printf "%-${espacio}s %-${espacio}s %-${espacio}s \n" "Nombre" "Límite" "Expiración"
    for user in $(getSystemUserList); do
      # logins=$(getLogins $user)
      local limits=$(getLimits $user)
      # limits=max_logins:fecha_expiración:hora
      local max_logins=$(echo $limits | awk -F : '{print $1}')
      local date=$(echo $limits | awk -F : '{print $2}')
      local hour=$(echo $limits | awk -F : '{print $3}')
      if [[ $limits == "" ]]; then
        printf "%-${espacio}s%s\n" $user "Desconocido :/"
      else
        #printf "%-${espacio}s %-${espacio}d %-${espacio}s %s \n" $user $max_logins $(date -d $date +"%d/%m/%Y") $(date -d $hour +"%H:%M")
        printf "%-${espacio}s %-${espacio}d%-s %-s\n" $user $max_logins $(date -d $date +"%d/%m/%Y") $(date -d $hour +"%H:%M")
        # date -d 20200819T2052 +"%Y/%m/%d:%H:%M"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # date -d 20200819T2052 +"%d/%m/%Y %H:%M"


      fi
    done
    echo ""
    holder
  else
    echo "No existen usuarios registrados en el sistema!"
    holder
  fi
    clear
}

function printSystemUserList() {
  #clear
  nextSteep=$1
  if [[ $nextSteep == 1 || $nextSteep == 2 ]]; then
    local i=0
    declare -A userlist
    for item in $(getSystemUserList); do
      i=$(($i + 1))
      userlist[$i]=$item
    done

    if [[ ${#userlist[*]} -gt 0 ]]; then
      for index in ${!userlist[@]}; do
        echo "[$index] ${userlist[$index]}"
      done

      echo "[0] Cancelar operación"
      echo -n "Ingresá un número:"
      read user

      if [[ $user -eq 0 ]]; then
        return 0
      elif [[ ${userlist[$user]} == "" ]]; then
        echo "Ingresaste $user"
        echo "No puedo entender eso :/"
        echo "Por favor, ingresá un número entre 0 y ${#userlist[*]}"
        printSystemUserList $nextSteep
      else
        case $nextSteep in
          1) 
          delUser ${userlist[$user]}
          ;;
          2) 
          editUserForm ${userlist[$user]}
          ;;
        esac
      fi
    else
      echo "No encontré a ningún usuario registrado en el sistema!"
      holder
    fi
  fi
  #holder
}

function delUserForm() {
  # CARGO ARRAY DE USUARIOS
  if [[ $(getSystemUserList | wc -l) -gt 0 ]]; then
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

    if [[ $user == "0" ]]; then
      return 0
    elif [[ ${userlist[$user]} == "" ]]; then
      echo "Ingresaste $user"
      echo "No entiendo eso :/"
      echo "Por favor, ingresá un número entre 1 y ${#userlist[*]}"
      echo "Recordá que con 0 volvés atrás!"
      holder
      delUserForm
    else
      delUser ${userlist[$user]}
      holder
    fi
  else
    echo "No encontré a ningún usuario registrado en el sistema!"
    holder
  fi
}

function delUser() {
  if [[ $(userExist $1) ]]; then
    userdel -f $1 &>/dev/null && echo "Eliminé a $1" &&
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
  #holder
}
function imprimirLogins() {
  #echo "El número de cuentas conectadas es de ${#connections[*]}."
  local espacio=10
  if [[ ${#connections[*]} -gt 0 ]]; then
    for key in ${!connections[*]}; do
      printf "%-${espacio}s%s\n" $key ${connections[$key]}"/$(getLogins $key)"
    done
  else
    echo "No existen usuarios conectados en este momento"  
  fi
  holder
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
  holder
}


function holder() {
  echo "Presioná ENTER para continuar ;)"
  read
}



function editUserForm() {
  #Listar Usuarios
  # Solicitar selección
  # Recuperar info del usuario

  echo "Formulario de edición de $1"
  echo "Nombre: $1"
  echo -n "Nueva contraseña: "; read pass
  echo -n "Duración: "; read days
  echo -n "Límite de conexiones: "; read max_logins
  editUser $1 $pass $days $max_logins


  holder
}


function editUser() {
  #Validación pendiente del comando!!!
  if [[ !$(userExist $1) ]]; then
    setPwd $1 $2
    setLimits $1 $3 $4
  else
    echo "Ops! No pude encontrar a $1."
    echo "Si estás seguro de que "$1" está registrado, por favor comunicate"
    echo "con mi creador porque no sé qué está pasando :|"
  fi
  #$mainFuntion
  # Tengo que buscar una mejor manera de volver al menú anterior!!!!!
  # Acabo de notar que no es necesario volver al menú anterior (creo)
  # Tendré que probar cómo funciona bash
}

function Tu() {
  echo "user funciona"
  holder
}



function getDate() { # AñoMesDiaHoraMinuto
  echo "$(grep "\b$1:" /root/ArgDM/limits | awk -F : '{print $3$4$5}')"
}

function userLockStatus() {
  echo $(passwd -S $1 | awk -F " " '{print $2}')
}