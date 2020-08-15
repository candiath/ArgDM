#!/bin/bash

source ./users_source.sh

function tryUser() {
  echo "Running user creation test"

  if [[ $(grep "abcdefg" /etc/passwd | wc -l) -eq 0 ]]; then
    createUser abcdefg
    if [[ $(grep "abcdefg" /etc/passwd | wc -l) -eq 1 ]]; then
      echo "User created"
      else
        echo "ERROR: USER CREATION FAILED. \nStopping"
        return 1
    fi
    setPwd abcdefg abcdefg && echo "Password command"
    echo ""
    echo "======================================="
    echo ""
    echo "Trying setDays"
    chage -l abcdefg > /tmp/abcdefg
    if [[ $(grep "Account expires" /tmp/abcdefg | awk -F : '{print $2}') = "never" ]]; then
      setDays abcdefg 5
      chage -l abcdefg > /tmp/abcdefg
      if [[ $(grep "Account expires" /tmp/abcdefg | awk -F : '{print $2}') != "never" ]]; then
        echo "PASSWORD SET COMMAND SUCCESS!!!"
      else
        echo "ERROR: PASSWORD SET COMMAND FAILED. \nStopping" && return 1
      fi
    fi

    echo ""
    echo "Trying SET LOGINS"
    if [[ $(grep abcdefg /root/ArgDM/limits | wc -l) == 0 ]]; then
      setLogins abcdefg 5
      if [[ $(grep abcdefg:5 /root/ArgDM/limits | wc -l) == 1 ]]; then
        echo "SET LOGINS COMMAND SUCCESS!!!"
      else
        echo "ERROR: SET LOGINS COMMAND FAILED. \nStopping"
        echo "Espected result: abcdefg:5"
        echo "Real result: $(grep abcdefg:5 /root/ArgDM/limits)"
        return 1
      fi
    fi


    echo ""
    echo "Trying GET LOGINS"

    if [[ $(getLogins abcdefg) == 5 ]]; then
      echo "GET LOGINS COMMAND SUCCESS!!!"
    else
      echo "ERROR: GET LOGINS COMMAND FAILED. \n Stopping"
      return 1
    fi


    echo ""
    echo "Trying USER EXIST COMMAND"

    if [[ $(userExist abcdefg) == 1 ]]; then
      echo "USER EXIST COMMAND SUCCESS!!!"
    else
      echo "ERROR: USER EXIST COMMAND FAILED. \n Stopping"
      return 1
    fi

    echo ""
    echo ""
    echo "Trying delUser"
    if [[ $(grep "\babcdefg:" /etc/passwd | wc -l) -eq 1 ]]; then
      delUser abcdefg
      if [[ $(grep "\babcdefg:" /etc/passwd | wc -l) -eq 0 ]]; then
        echo "DEL USER COMMAND SUCCESS!!!"
      else
        echo "ERROR: DEL USER COMMAND FAILED. \n Stopping"
      fi
    fi
   else
   	echo "ERROR. USER ALREADY EXISTS. ABORTING"
   fi
}

chmod 777 ./users_source.sh
tryUser
