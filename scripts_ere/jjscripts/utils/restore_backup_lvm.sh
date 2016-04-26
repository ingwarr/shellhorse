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
