#!/bin/bash

source ./users_source.sh

function tryUser() {

nameTry=nameTry

  if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 0 ]]; then
    createUser $nameTry $nameTry 5 5
    if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 1 ]]; then
      echo "User creation SUCCESS!"
      else
        echo "ERROR: USER CREATION FAILED. \nStopping"
        return 1
    fi
    #setPwd $nameTry $nameTry && echo "Password command"
   
    chage -l $nameTry > /tmp/$nameTry
    if [[ $(grep "Account expires" /tmp/$nameTry | awk -F : '{print $2}') = " never" ]]; then
      setDays $nameTry 5;
      chage -l $nameTry > /tmp/$nameTry;
      if [[ $(grep "Account expires" /tmp/$nameTry | awk -F : '{print $2}') != "never" ]]; then
        echo "PASSWORD SET COMMAND SUCCESS!";
      else
        echo "ERROR: PASSWORD SET COMMAND FAILED. \nStopping" && return 1;
      fi
    fi

   
    if [[ $(grep $nameTry /root/ArgDM/limits | wc -l) == 0 ]]; then
      setLogins $nameTry 5
    else
      if [[ $(grep "$nameTry:5" /root/ArgDM/limits | wc -l) != 0 ]]; then
        echo "SET LOGINS COMMAND SUCCESS!"
      else
        echo "ERROR: SET LOGINS COMMAND FAILED. \nStopping"
        echo "Espected result: $nameTry:5"
        echo "Real result: $(grep $nameTry /root/ArgDM/limits)"
        return 1
      fi
    fi


   

    if [[ $(getLogins $nameTry) == "5" ]]; then
      echo "GET LOGINS COMMAND SUCCESS!"
    else
      echo "ERROR: GET LOGINS COMMAND FAILED. \n Stopping"
      echo "Login espected 5"
      echo "Login received $(getLogins $nameTry)"
      return 1
    fi



    if [[ $(userExist $nameTry) == 1 ]]; then
      echo "USER EXIST COMMAND SUCCESS!"
    else
      echo "ERROR: USER EXIST COMMAND FAILED. \n Stopping"
      return 1
    fi

  
    if [[ $(grep "\b$nameTry:" /etc/passwd | wc -l) -eq 1 ]]; then
      delUser $nameTry
      if [[ $(grep "\b$nameTry:" /etc/passwd | wc -l) -eq 0 ]]; then
        echo "DEL USER COMMAND SUCCESS!"
      else
        echo "ERROR: DEL USER COMMAND FAILED. \n Stopping"
      fi
    fi
  
  else
    echo "Environment not in conditions. Trying to repair it"
    if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 1 ]]; then
      userdel -f $nameTry
      sed -i '/$nameTry/d' /root/ArgDM/limits
      if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 0 ]]; then
        echo "Repair DONE!"
        echo "Restarting test"
        echo ""
        tryUser
      fi

    fi
  fi

}

chmod 777 ./users_source.sh

