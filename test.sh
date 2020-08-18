#!/bin/bash

source ./users_source.sh

function tryUser() {

nameTry=nameTry

  if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 0 ]]; then
    createUser $nameTry $nameTry 5 5
    if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 1 ]]; then
      echo -e "User creation \e[32mSUCCESS! \e[0m"
      else
        echo -e "\e[31mERROR: USER CREATION FAILED.\e[0m \nStopping"
        return 1
    fi
    #setPwd $nameTry $nameTry && echo "Password command"
   
    chage -l $nameTry > /tmp/$nameTry
    if [[ $(grep "Account expires" /tmp/$nameTry | awk -F : '{print $2}') = " never" ]]; then
      setDays $nameTry 5;
      chage -l $nameTry > /tmp/$nameTry;
      if [[ $(grep "Account expires" /tmp/$nameTry | awk -F : '{print $2}') != "never" ]]; then
        echo -e "PASSWORD SET COMMAND \e[32mSUCCESS! \e[0m";
      else
        echo -e "\e[31mERROR: PASSWORD SET COMMAND FAILED. \e[0m \nStopping" && return 1;
      fi
    fi

   
    if [[ $(grep $nameTry /root/ArgDM/limits | wc -l) == 0 ]]; then
      setLogins $nameTry 5
    else
      if [[ $(grep "$nameTry:5" /root/ArgDM/limits | wc -l) != 0 ]]; then
        echo -e "SET LOGINS COMMAND \e[32mSUCCESS! \e[0m"
      else
        echo -e "\e[31mERROR: SET LOGINS COMMAND FAILED. \e[0m \nStopping"
        echo "Espected result: $nameTry:5"
        echo "Real result: $(grep $nameTry /root/ArgDM/limits)"
        return 1
      fi
    fi


   

    if [[ $(getLogins $nameTry) == "5" ]]; then
      echo -e "GET LOGINS COMMAND \e[32mSUCCESS! \e[0m"
    else
      echo -e "\e[31mERROR: GET LOGINS COMMAND FAILED. \e[0m \nStopping"
      echo "Login espected 5"
      echo "Login received $(getLogins $nameTry)"
      return 1
    fi



    if [[ $(userExist $nameTry) == 1 ]]; then
      echo -e "USER EXIST COMMAND \e[32mSUCCESS! \e[0m"
    else
      echo -e "\e[31mERROR: USER EXIST COMMAND FAILED.\e[0m \nStopping"
      return 1
    fi

  
    if [[ $(grep "\b$nameTry:" /etc/passwd | wc -l) -eq 1 ]]; then
      delUser $nameTry
      if [[ $(grep "\b$nameTry:" /etc/passwd | wc -l) -eq 0 ]]; then
        echo -e "DEL USER COMMAND \e[32mSUCCESS! \e[0m"
      else
        echo -e "\e[31mERROR: DEL USER COMMAND FAILED.\e[0m \nStopping"
      fi
    fi
  
  else
    echo -e "\e[93mEnvironment not in conditions. Trying to repair it \e[0m"
    if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 1 ]]; then
      userdel -f $nameTry
      sed -i '/$nameTry/d' /root/ArgDM/limits
      if [[ $(grep "$nameTry" /etc/passwd | wc -l) -eq 0 ]]; then
        echo -e "\e[32mRepair DONE!"
        echo -e "Restarting test"
        echo -e "\e[0m"
        sleep 3s
        tryUser
      fi

    fi
  fi
  holder
}

chmod 777 ./users_source.sh


