#!/bin/bash
#===============================================================================
#
#          FILE:  multi-root-main.sh
#
#         USAGE:  ./multi-root-main.sh --conf <path to configuration file>
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Vitalii Nogin	vnogin@mirantis.com
#       COMPANY:  Mirantis Inc.
#       VERSION:  1.0
#       CREATED:  20/04/2016 14:31:01 PM MDT
#      REVISION:  ---
#===============================================================================

usage ()
{
  echo 'Usage : ./multi-root-main.sh' 
  echo '		--conf 		<path to configuration file> '
  exit
}

config_error()
{
  echo "ERROR. Please check your configuration file as it seems something hasn't been defined."
  exit
}


let AMOUNT_INPUT_PARAMS=$#

if [ "${AMOUNT_INPUT_PARAMS}" -lt 2 ]
then
  usage
fi

if [ "${AMOUNT_INPUT_PARAMS}" -gt 3 ]
then
  usage
fi

while [ "$1" != "" ]; do
    case $1 in
        --conf-file )       shift
                       CONFIG_FILE=$1
                       ;;
    esac
    shift
done

# Empty parameter validation 
if [ "${CONFIG_FILE}" = "" ]
then
    usage
fi

# File exists check
if [ -s "${CONFIG_FILE}" ]
then
	CONFIG_OPTIONS=`cat ${CONFIG_FILE}`
else
	echo "Please provide correct path to the configuration file as ${CONFIG_FILE} file doesn't exist or empty"
fi

source ${CONFIG_FILE}

#Mandatory parameters are defined in configuration file

if [ "${USER_ID}" = "" ]
then
    config_error
fi

if [ "${JOB_MODE}" = "" ]
then
    config_error
fi

case ${JOB_MODE} in
  upgrade)
		echo "Running upgrade mode"
		;;
  backup)
                echo "Running backup mode"
                ;;
  list)
                echo "Running list mode"
                ;;
  restore)
                echo "Running restore mode"
                ;;
  standart)
                echo "Running standart mode"
                ;;
  deploy)
                echo "Running deploy mode"
                ;;
  *)  
      echo "ERROR: ${JOB_MODE} mode isn't supported. Please check your configuration file." 
      exit
      ;; 
esac


echo "USER-ID from config is ${USER_ID} JOB_MODE=${JOB_MODE} GIT_LINK=${GIT_LINK} IF_DEPLOYMENT_FAIL_JOB=${IF_DEPLOYMENT_FAIL_JOB}"
echo "CONFIG FILE = ${CONFIG_FILE}"























