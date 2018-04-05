#!/bin/bash
#---------------------------------------------------------------------------
#--- test_official_account
#---
#--- Usage: Send the msg to wechat user automatically.
#---
#--- Info: eg. hey shanewa
#---           hey handle=shanewa
#---           hey upi=CV0038147 -h
#---------------------------------------------------------------------------
#--- Developed by Shane Wang (shane.wang@alcatel-lucent.com)
#--- Date: 2017.11.17
#--------------------------------------------------------------------------
#--- Issue Notes:
#--- version1: 2017.11.17  Shane: developed the base functionalities
#---------------------------------------------------------------------------

# Define the wechat local path of token file
_token_file="/home/shanewa/wechat/alarm/shane/wechat_accesstoken"

# Local message file
queue_file="/home/shanewa/wechat/alarm/shane/shane_alarm.msg"

# Wechat public appID/appsecret
appID=xxx
appsecret=xxxxx

# To user wechat open id
open_id="o5tS-01ZjRAsRiaWjQoVVFpZtxz4"
url="https://www.baidu.com"
level="HIGH"
name="重要时间节点提醒"

#Wechat messgae template
tpl_id=xxxx

# eg.
# {{name.DATA}} 
#
# 紧急程度：{{level.DATA}} 
# 提醒时间：{{date.DATA}} 
#
# {{description.DATA}}

# Get and save the AccessToken
function getAccessToken {
    if [ -f "$_token_file" ]; then
        access_token=`cat $_token_file | awk -F":" '{print $1}'`
        expires_in=`cat $_token_file | awk -F":" '{print $2}'`
        time=`cat $_token_file | awk -F":" '{print $3}'`
            if [ -z $access_token ] || [ -z $expires_in ] || [ -z $time ]; then
            rm -f $_token_file
            getAccessToken 
        fi
    else
        content=$(curl "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=$appID&secret=$appsecret")
        echo "get content: $content"
        access_token=`echo $content | awk -F "\"" '{print $4}'`
        expires_in=`echo $content | awk -F "\"" '{print $7}' | cut -d"}" -f1|cut -c2-`
        echo "access_token = $access_token"
        echo "expires_in = $expires_in"
        time=$(date +%s)
        echo "$access_token:$expires_in:$time" > $_token_file

        if [ -z $access_token ] || [ -z $expires_in ] || [ -z $time ]; then
                    echo "not get access_token"
                    exit 0
        fi
        fi

    remain=$[$(date +%s) - $time]
    limit=$[$expires_in - 60]
    if [ $remain -gt $limit ]; then
        rm -f $_token_file
        getAccessToken
    fi
}

# Send the message
function sendMessage {
    # Construct the json message structure
    message=`cat << EOF
    {
    "touser":"$open_id",
    "template_id":"$tpl_id",
    "url":"$url",
    "data":{
            "name": {
                    "value":"$name",
                    "color":"#FF0000"
            },
            "level":{
                    "value":"$level",
                    "color":"#173177"
            },      
            "date": {
                    "value":"$date",
                    "color":"#173177"
            },
            "description":{
                    "value":"$description",
                    "color":"#FF0000"
            }
    }
     }
EOF
`
   echo "send message : $message"
   curl -X POST -H "Content-Type: application/json"  https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=$access_token -d "$message" 
}


# Main
# Dead loop
while :
do 
    # Parse the message
    if [[ -f $queue_file && `cat $queue_file` != "" ]]; then {
        # Get the alarm description
        description=`cat $queue_file`
        
        # Set the date
	date=`date +%Y%m%d_%T`
        
        # Get the access token
        getAccessToken

        # Send the alarm message to the test public account        
        sendMessage
        
        # Clear the message queue
        > $queue_file
    }
    fi
    
    # Only check the message queue in every 10 seconds
    sleep 10    
done
