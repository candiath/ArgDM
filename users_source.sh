#!/bin/bash
#USERS SOURCE
# Useful commands:
#       chage -l $user
# https://www.cyberciti.biz/faq/linux-howto-check-user-password-expiration-date-and-time/


#queda pendiente mostrar los datos luego de crear usuario
#generar activador de cchec expiration

# Esta función recibe $name $pass $defaultMagnitude y $isTest y  se encarga de pedir los límites tanto de logins máximos como de tiempo
# y los envía a createUser()
function readLimits() {
   
    #echo "Duración: "
    validity=0
    number=0
    days=0
    hours=0
    minutes=0
    #while [[ $validity == "0" ]]; do
      echo "Ejemplo: 1d 2h 30m (un día, 2 horas y 30 minutos)."
      #echo "Si sólo ingresás números los tomaré como minutos"
      #echo "Ingresá la duración del usuario: "
      #function customTime() {
        
        # read -p 'Ingresá la duración del usuario: '
        read -e -p "Ingresá la duración del usuario:" -i "30" cadena
        # cadena=$REPLY

      # Convierto la entrada a dias, horas y minutos
      for (( i = 0; i < ${#cadena}; i++ )); do
          char=$(echo ${cadena:$i:1})
         # echo "i = $i"
          #echo "char = $char"
          if [[ $char =~ ^[0-9]+$ ]]; then
            number="${number}$char"
            #echo "number tiene $number"
          elif [[ $char == "d" ]]; then
            days=$number
            #echo "hours tiene $hours"
            unset number
        elif [[ $char == "h" ]]; then
            hours=$number
            #echo "hours tiene $hours"
            unset number
          elif [[ $char == "m" ]]; then
            minutes=$number
            #echo "minutes tiene $minutes"
            unset number
          fi
      done

      if [[ $number -gt 0 ]]; then
        echo "number tiene $number"
        case $3 in
          1 )
          days=$number #; validity=1
          ;;
          2 )
          hours=$number #; validity=1
          ;;
          3 )
          minutes=$number #; validity=1
          ;;
        esac
      fi

# echo "CHECK $days days, $hours horas y $minutes minutos."

      # echo "No se ha ingresado una entrada válida."
      # echo "Por favor, ingrese en el formato dias horas minutos"
      # echo "Ejemplo: 1d 5h 15m"
      # holder
      # clear


    #done
    # Establezco entrada sin letras como minutos
    # if [[ ! -z $number ]]; then
    #   minutes=$number
    #   echo "$days days, $hours horas y $minutes minutos."
    # else
    #   echo "$days days, $hours horas y $minutes minutos."
    # fi
    #} 


  # if [ $days = "" ] ; then
  #   $days=30
  #   echo "Duración establecida en 30 minutos por defecto"
  #   sleep 2s
  # fi
  #days=0
  # max_logins=1
  read -e -p "Limite de conexiones:" -i "1" max_logins
  createUser $name $pass $max_logins $days $hours $minutes $isTest
  # else
  #   echo "El usuario ya existe"
  # fi
}



#ENTRADA desde tempUser: $name $pass $max_logins $days $hours $minutes $isTest
function createUser() {
  #Validación pendiente del comando!!!

  #echo "createUser ==> He recibido "$# " parámetros, que son: "$*
  if [[ $(userExist $1) == "0" ]]; then
    useradd -M -s /bin/false $1
    setPwd $1 $2
    #ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   

# VALIDAR PASS NO VACÍA PORQUE ROMPE EL RESTO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Y no es seguro

    # $name $maxLogins $days $hours $minutes $isTest
    setLimits $1 $3 $4 $5 $6 $7
  else
    echo "Ya existe un usuario con el nombre $1"
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

function setLimits() { # $name $maxLogins $days $hours $minutes $isTest
  # $name $days $max_logins
  #echo "setLimits ==> He recibido "$# " parámetros, que son: "$*
  days=$3
  hours=$4
  minutes=$5
  if [[ $days -lt 1 ]]; then
    days=0
  fi
  if [[ $hours -lt 1 ]]; then
    hours=0
  fi
  if [[ $minutes -lt 1 ]]; then
    minutes=0
  fi
  dir=/root/ArgDM 

  if [[ $isTest == "1" ]]; then
    testString=:1
  fi

  #echo "Check ==> He recibido "$# " parámetros, que son: "$*
  if [[ $(grep $1 /root/ArgDM/limits | wc -l) == 0 ]]; then
    # echo "$1:$3:$(date +"%Y%m%d" -d "+ $2 days"):$(date +"%H%M")" >> "$dir/limits"
    echo "$1:$2:$(date  +"%Y%m%d%H%M" -d "+ $days days $hours hours $minutes minutes")$testString" >> "$dir/limits"
    # echo "CHECK+ $3 days $4 hours $5 minutes"
    # read
  else
    sed -i "s/\b$1:.*/$1:$2:$(date  +"%Y%m%d%H%M" -d "+ $days days $hours hours $minutes minutes")$testString/" /root/ArgDM/limits # TESTEAR POSIBLES FALLAS ACÁ!!!!!!!!!
    # echo "CHECK++ $days days $hours hours $minutes minutes"
    #date  +"%Y%m%d%H%M" -d "+ $days days $hours hours $minutes minutes"
  fi

  holder


}

function getLimits() { # max_logins:fecha_expiración
  # echo $(grep $1 /root/ArgDM/limits | awk -F : '{print $2":"$3":"$4}')
  echo $(grep $1 /root/ArgDM/limits | awk -F : '{print $2":"$3}')
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
   # [ $(grep "\b$1:" /etc/passwd | wc -l) -eq 1 ] && echo "1" || echo "0" #echo "existe" || echo "no existe"
   [ $(cat /etc/passwd | awk -F : '{print $1":"}' | grep "\b$1:" | wc -l) -eq 1 ] && echo "1" || echo "0" #echo "existe" || echo "no existe"
   # $(grep pepe /etc/passwd) también puede funcionar

}

function getSystemUserList() {

  for i in $(grep -v nobody /etc/passwd | awk -F : '{if ( $3 > 999 ) print $1}'); do
    echo $i
  done
}

function userListForm() {
  if [[ $(getSystemUserList | wc -l) -gt 0 ]]; then
    espacio=15
    clear
    printf "%-${espacio}s %-${espacio}s %-${espacio}s \n" "Nombre" "Límite" "Expiración"
    for user in $(getSystemUserList); do
      # logins=$(getLogins $user)
      local limits=$(getLimits $user)
      # limits=max_logins:fecha_expiración:hora


      #Ahora
      # limits=max_logins:DATETIME
      local max_logins=$(echo $limits | awk -F : '{print $1}')
      local datetime=$(echo $limits | awk -F : '{print $2}')
      datetime=$(echo "${datetime:0:8} ${datetime:8:4}")
      #echo "datetime es \"$datetime\""

      # local hour=$(echo $limits | awk -F : '{print $3}')
      if [[ $limits == "" ]]; then
        printf "%-${espacio}s%s\n" $user "Desconocido :/"
      else
        #printf "%-${espacio}s %-${espacio}d %-${espacio}s %s \n" $user $max_logins $(date -d $date +"%d/%m/%Y") $(date -d $hour +"%H:%M")
        printf "%-${espacio}s %-${espacio}d%-s %-s\n" $user $max_logins $(date +"%d/%m/%Y %H:%M" -d "$datetime")
        # date -d 20200819T2052 +"%Y/%m/%d:%H:%M"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # date -d 20200819T2052 +"%d/%m/%Y %H:%M"


        #date +"%d/%m/%Y %H:%M" -d $(echo "${str:0:8}T${str:8:4}")


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
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   
#ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   ERROR   

#elimina mal esa cosa
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
  editUser $1 $pass $max_logins $days


  holder
}


function editUser() {
  #Validación pendiente del comando!!!
  if [[ !$(userExist $1) ]]; then
    setPwd $1 $2
    setLimits $1 $3 $4 # $name $maxLogins $days $hours $minutes
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


# function customTime() {
#   unset number
#   unset hours
#   unset minutes
#   read -p 'ingrese el tiempo: '
#   cadena=$REPLY

# for (( i = 0; i < ${#cadena}; i++ )); do
#     char=$(echo ${cadena:$i:1})
#     echo "i = $i"
#     echo "char = $char"
#     if [[ $char =~ ^[0-9]+$ ]]; then
#       number="${number}$char"
#       echo "number tiene $number"
#     elif [[ $char == "h" ]]; then
#       hours=$number
#       echo "hours tiene $hours"
#       unset number
#     elif [[ $char == "m" ]]; then
#       minutes=$number
#       echo "minutes tiene $minutes"
#       unset number
#     fi
# done

# if [[ ! -z $number ]]; then
#   minutes=$number
#   echo "$hours horas y $minutes minutos."
# else
#   echo "$hours horas y $minutes minutos."
# fi
# } 