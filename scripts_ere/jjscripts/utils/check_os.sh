#===============================================================================
#
#          FILE:  check_os.sh
#
#         USAGE:  ./check_os.sh
#
#   DESCRIPTION:  Supported operation systems check
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Vitalii Nogin vnogin@mirantis.com
#       COMPANY:  Mirantis Inc.
#       VERSION:  1.0
#       CREATED:  20/04/2016 15:26:01 PM MDT
#      REVISION:  ---
#===============================================================================

OS_TYPE=`cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2`

case ${OS_TYPE} in

  "Ubuntu 14.04.4 LTS")
		echo "INFO: ${OS_TYPE} is supported OS."
		;;
  "CentOS Linux 7 (Core)")
                echo "INFO: ${OS_TYPE} is supported OS."
                ;;
  *) 
		echo "ERROR: ${OS_TYPE} isn't supported OS."
		exit
		;;
esac
