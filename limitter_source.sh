#!/bin/bash
#screen -r -S "bot_plus" -X quit

function limitterEnabler() {
  echo "soy el enabler"
  echo $(getLimitterStatus)
  [ $(getLimitterStatus) -eq 0 ] && screen -dmS dropbearLimitter ./limitter.sh #&& return 1 || return 0
    echo "screen enabled (supuestamente)!"
    sleep 2s
  #fi
}

function limitterDisabler() {
  result=0
  for item in $(ps x | grep -i "limitter" | grep -i "screen" | awk '{print $1}'); do
    kill $item
    echo "kill $item"
    sleep 2s
    result=1
  done
  return $result
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
