LV_ROOT_STANDARD="root_standard"
LV_ROOT_FIRST="root_one"
LV_ROOT_SECOND="root_two"

CURRENT_ROOT=`mount| egrep "${LV_ROOT_STANDARD}|${LV_ROOT_FIRST}|${LV_ROOT_SECOND}"|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`
if [ "${CURRENT_ROOT}" != "" ]; then
	echo "${CURRENT_ROOT}"
else
	echo "[ERROR]: There isn't required root partition"
	exit
fi
