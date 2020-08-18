#!/bin/bash
source ./users_source.sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
echo "check : $(date +'%F-%T')" >> "/root/ArgDM/lockerLOG"
for user in $(getSystemUserList); do
	#getDate $item
	if [[ $(getDate $user) -lt  $(date +"%Y%m%d%H%M") ]]; then
		if [[ $(userLockStatus $user) == "P" ]]; then
	  		usermod -L $user # &>>/root/ArgDM/lockerLOG
	  		echo "LOCKED USER $user: $(date +'%F-%T')" >> "/root/ArgDM/lockerLOG"
		fi
  		#disconectUser $user
	fi
done