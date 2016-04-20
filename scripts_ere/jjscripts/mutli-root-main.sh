#!/bin/bash
usage ()
{
  echo 'Usage : ./multi-root-main.sh' 
  echo '		--user 		<user name> '
  echo '		--job-mode 	<job mode (create backup/restore from the backup/cetera)> '
  echo '                --conf-file 	<path to the local.conf file> '
  echo '		--git 		<link to relevant github, for instance https://github.com/ingwarr/shellhorse.git>'
  exit
}

#let AMOUNT_INPUT_PARAMS=$#

#if [ "$AMOUNT_INPUT_PARAMS" -ge 4 ]
#then
#  usage
#fi

while [ "$1" != "" ]; do
case $1 in
        --user )       shift
                       USER_ID=$1
                       ;;
        --job-mode )   shift
                       JOB_MODE=$1
                       ;;
        --conf-file )  shift
                       CONF_FILE=$1
                       ;;
        --git )        shift
                       GIT_LINK=$1
                       ;;
    esac
    shift
done

# extra validation 
#if [ "$USER_ID" = "" ]
#then
#    usage
#fi

#if [ "$JOB_MODE" = "" ]
#then
#    usage
#fi

#if [ "$CONF_FILE" = "" ]
#then
#    usage
#fi

#if [ "$GIT_LINK" = "" ]
#then
#    usage
#fi

echo "USER = $USER_ID, JOB_MODE = $JOB_MODE, CONF_FILE = $CONF_FILE, GIT_LINK = $GIT_LINK"
