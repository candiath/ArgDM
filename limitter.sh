#!/bin/bash

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
      activeConnections=$(echo $temp | awk -F"'" '{print $2}')

  # Sumar
      declare -A connections # connections[USERNAME]:NumberOfActiveConnections
      for item in ${activeConnections}; do
          if [[ -n "$item"  ]]; then #Verificar si es necesario este paso!!!!!!!!!!!!!!!!
                  #echo "en if ITEM vale $item"
                  [ -n "${connections[$item]}" ] && connections[$item]=$((${connections[$item]} + 1)) || connections[$item]=1
          fi
      done
    done

  # Leo limites
      declare -A loginLimits
      for line in $(cat $dir/limits); do
        loginLimits[$(echo $line | awk -F : '{print $1}')]=$(echo $line | awk -F : '{print $2}')
      done
      #test
      # for item in ${!loginLimits[@]}; do echo "$item - ${loginLimits[$item]}"; done

      for user in ${!connections[@]}
      do
        #echo "en FOr es $user"
        #echo "============================================="
        #echo "connections[user] es ${connections[$user]} y login[user] es ${loginLimits[$user]}"
        #echo "============================================="
        if [[ ((${connections[$user]} -gt ${loginLimits[$user]})) ]]; then # Si exedió el limite
        # Parece que sin los dobles corchetes se hace la comparación caracter a caracter
        # porque según esto 2 es mayor que 10
          echo "$user excede limite!!!!!!!!!!!!!!!!!!!!!!"
          echo "${connections[$user]} -gt ${loginLimits[$user]}"
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
