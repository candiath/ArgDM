#!/bin/bash
source ./users_source.sh
for user in $(getSystemUserList); do
  #echo "user $user"
  actualLogins=$(ps -u $user | grep sshd | wc -l)
  #echo "actual: $actualLogins"
  allowedLogins=$(getLogins $user)
  #echo "allowed $allowedLogins"



  if [[ $actualLogins -gt $allowedLogins ]]; then
    pkill -KILL -u $user
    echo "mato $user"
  fi
done
