#!/bin/bash
#screen -r -S "bot_plus" -X quit

function limitterEnabler() {
  #echo "soy el enabler"
  echo $(getLimitterStatus)
  [ $(getLimitterStatus) -eq 0 ] && screen -dmS dropbearLimitter ./limitter.sh #&& return 1 || return 0
    if [[ $(getLimitterStatus) == 0 ]]; then
      echo "ERROR! No se ha podido habilitar el limitador"
      sleep 3s
    fi
}

function limitterDisabler() {
  for item in $(ps x | grep -i "limitter" | grep -i "screen" | awk '{print $1}'); do
    kill $item
  done
  if [[ $(getLimitterStatus) == 1 ]]; then
    echo -e "ERROR! No se pudo deshabilitar el limitador \n
    Proceso: $item\n
    PS: $(ps x | grep -i "limitter" | grep -i "screen")\n 
    Fecha: $(date +'%F') \n
    Hora: $(date +'%T') " 2> "$errDir/dropBearLimitter $(date +'%F--%T')"
    # PROBAR ESTO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


    
    echo -e "\e[31mERROR! \e[0mAlgo impide deshabilitar el limitador."
    echo -e "Por favor, reintentá después de reiniciar el servidor con "
    echo -e "el comando \e[4msudo reboot\e[0m"
    sleep 3s
  fi
}

function getLimitterStatus() {
  if [[ $(ps x | grep -i "limitter" | grep -i "screen") ]]; then
    echo "1"
  else
    echo "0"
  fi
}



function Tl() {
  echo "limiter funciona"
  sleep 1s
}
