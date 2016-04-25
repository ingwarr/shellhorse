LV_ROOT_STANDARD="root_standard"
LV_ROOT_FIRST="root_one"
LV_ROOT_SECOND="root_two"
VG="vg0"

LV_POSITIONAL_ROOTS="${VG}-${LV_ROOT_FIRST} ${VG}-${LV_ROOT_SECOND}"
LV_CURRENT_ROOT=`mount| egrep "${VG}-${LV_ROOT_STANDARD}|${VG}-${LV_ROOT_FIRST}|${VG}-${LV_ROOT_SECOND}"|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`
if [ "${LV_CURRENT_ROOT}" != "" ]; then
	echo "[INFO]: Current root file system is ${LV_CURRENT_ROOT}"
else
	echo "[ERROR]: There isn't required root partition"
	exit
fi

#Determine current and future partitions
if [ "${LV_CURRENT_ROOT}" == "${VG}-${LV_ROOT_STANDARD}" ]; then
        LV_FUTURE_ROOT="${VG}-${LV_ROOT_FIRST}"
else
	for LV_POSITIONAL_ROOT in ${LV_POSITIONAL_ROOTS}
        do
           if [ "${LV_POSITIONAL_ROOT}" != "${LV_CURRENT_ROOT}" ]; then
               LV_FUTURE_ROOT=${LV_POSITIONAL_ROOT}
               echo "[INFO]: New root will be ${LV_FUTURE_ROOT}"
           fi
        done
fi

