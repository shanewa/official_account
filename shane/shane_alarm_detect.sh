#!/usr/bin/bash
#---------------------------------------------------------------------------
#--- lerro_alarm.sh
#---
#--- Usage:
#---
#--- Info:
#---------------------------------------------------------------------------
#--- Developed by Shane Wang (shane.wang@alcatel-lucent.com)
#--- Date: 2017.11.17
#--------------------------------------------------------------------------
#--- Issue Notes:
#--- version1: 2017.11.17  Shane: Developed the base functionalities
#---------------------------------------------------------------------------

queue_file="/home/shanewa/wechat/alarm/shane/shane_alarm.msg"
cnfg_file="/home/shanewa/wechat/alarm/alarm.cnfg"
to_user="shane"


function ck_timer {
    _name=`eval echo '$'"$1"`
    _time=`eval echo '$'"$1"_time`
	
    echo $_name  
    echo $_time

    if [[ `echo $global_now | grep "$_time$"` != "" ]]; then {
        echo -e "$_name" >> $queue_file
    }
    fi
}


# Dead loop
while :
do 
    # Load the message defination file
    . $cnfg_file

    # Get the current system time. Format: month:day:weekly:hour:minute.
    # eg. 11:18:6:11:57 <=> 11.18, Sat, 11:57
    global_now=`date +%m:%d:%u:%H:%M`

    # Get the check points for this user
    cat $cnfg_file | grep -e "^$to_user" -e "^common" | grep -v "_time" | cut -d "=" -f 1 | while read points 
	do
            ck_timer $points
	done
    
	# Only check once in one minute
        sleep 60
done


