#!/bin/bash
#screen -r -S "bot_plus" -X quit

function Tl() {
  echo "limiter funciona"
}


function limitter() {
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
        #echo "en FOr es $user"
        #echo "============================================="
        #echo "connections[user] es ${connections[$user]} y login[user] es ${loginLimits[$user]}"
        #echo "============================================="
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
    #screen -d -m -t Limitter limitter
    screen -dmS limitter run
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
