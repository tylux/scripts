#!/bin/bash

usage=$(
cat <<EOF
$0 [OPTION]
usage example: ntp_check.sh -h 192.168.1.99 -u root -w 5 -c 10 -b 172.20.90.1
-b specify the expected backup NTP server
-w specify the NTP offset warning threshold, defaults to 4 seconds
-c specify the NTP offset critical threshold, defaults to 5 seconds
-h specify hostname of server you want to check
-u specify the username of the server you want to check
-s specify a NTP server that you want to check
-r set this to 1 if you want this to run over ssh this works best if you are using ssh key authentication
EOF
)

#Defaults
WARNING=4
CRITICAL=5
SERVER="localhost"
SSH=

while getopts :b:w:c:h:u:s:r: OPTION
do
     case $OPTION in
        b)BACKUP=$OPTARG;;
        w)WARNING=$OPTARG;;
        c)CRITICAL=$OPTARG;;
        h)HOST=$OPTARG;;
        u)USERNAME=$OPTARG;;
        s)SERVER=$OPTARG;;
        r)SSH=$OPTARG;;
        *)
          echo "unrecognized option"
          echo "$usage";;
     esac
done

if [ -z "$SSH" ]
then
  COMMAND=$(ntpdc -pn | grep -F '*' | awk '{print $1}' | cut -d "*" -f 2)
  SECONDARY=$(ntpdc -pn | grep -F '=' | awk '{print $1}' | cut -d "=" -f 2 | xargs)
  OFFSET=$(ntpdc -pn | grep -F '*' | awk '{print $7}' | xargs)
  F=${OFFSET#-}
else
  COMMAND=$(ssh $USERNAME@$HOST ntpdc -pn | grep -F '*' | awk '{print $1}' | cut -d "*" -f 2)
  SECONDARY=$(ssh $USERNAME@$HOST ntpdc -pn | grep -F '=' | awk '{print $1}' | cut -d "=" -f 2 | xargs)
  OFFSET=$(ssh $USERNAME@$HOST ntpdc -pn | grep -F '*' | awk '{print $7}' | xargs)
  F=${OFFSET#-}
fi

main_function ()
{
  if [ -z "$COMMAND" ]
  then
          echo "No synchronization with the time server, is ntpd running?"
          exit 3

  elif (( $(echo "$1 $CRITICAL" | awk '{print ($1 > $2)}') ))
  then
          echo "$1 $CRITICAL" | awk '{printf "Offset is critical " sprintf("%.9f", $1) " critical threshold is set to " $2 "\n"; }'
          exit 2

  elif (( $(echo "$1 $WARNING" | awk '{print ($1 > $2)}') ))
  then
          echo "$1 $WARNING" | awk '{printf "Offset is warning " sprintf("%.9f", $1) " warning threshold is set to " $2 "\n"; }'
          exit 1
  else
          echo "$COMMAND $2" | awk '{printf "Synchronized with the server " $1 " Offset " sprintf("%.9f", $2) "\n"; }'
          exit 0
  fi
}

secondary_fuction ()
{
  echo "Backup NTP server does not match the backup NTP server you specified, secondary:"$SECONDARY", specified:"$BACKUP""
  exit 1
}

sever_specified ()
{
  if [ -z "$SSH" ]
  then
    SECONDARY_OFFSET=$(ntpdate -q $SERVER | awk '{print +$6}' | head -1 | sed 's/,*$//g')
    SECONDARY_F=${SECONDARY_OFFSET#-}
  else
    SECONDARY_OFFSET=$(ssh $USERNAME@$HOST ntpdate -q $SERVER | awk '{print +$6}' | head -1 | sed 's/,*$//g')
    SECONDARY_F=${SECONDARY_OFFSET#-}
  fi

  # If specified bacup option is null then call main_function with secondary_offset parameter
  if [[ -z "$BACKUP" ]]
  then
     main_function $SECONDARY_F $SECONDARY_OFFSET
  elif [[ -n "$BACKUP" && ( "$BACKUP" != "$SECONDARY" ) ]]
  then
    secondary_fuction
  else
    main_function $SECONDARY_F $SECONDARY_OFFSET
  fi
}

#Make Calls to functions
# If specified server option (-s) expected and backup option (-b) are not set then call main function as is.
if [[ -z "$SERVER" && -z "$BACKUP" ]]
then
   main_function $F $OFFSET
# If there is a value for server option (-s) call server_specified function
elif [ -n "$SERVER" ]
then
  sever_specified
# If there is a value for backup option (-b) call secondary function
elif [ "$BACKUP" != "$BACKUP" ]
then
  secondary_fuction
# Else call main_fuction
else
  main_function $F $OFFSET
fi

