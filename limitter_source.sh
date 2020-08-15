#!/bin/bash
#screen -r -S "bot_plus" -X quit

function limitterEnabler() {
  echo "soy el enabler"
  echo $(getLimitterStatus)
  [ $(getLimitterStatus) -eq 0 ] && screen -dmS dropbearLimitter ./limitter.sh #&& return 1 || return 0
    if [[ $(getLimitterStatus) == 0 ]]; then
      echo "ERROR!"
      sleep 3s
    fi
}

function limitterDisabler() {
  for item in $(ps x | grep -i "limitter" | grep -i "screen" | awk '{print $1}'); do
    kill $item
  done
  if [[ $(getLimitterStatus) == 1 ]]; then
      echo "ERROR!"
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
