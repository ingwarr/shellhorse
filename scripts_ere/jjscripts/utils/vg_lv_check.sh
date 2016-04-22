#DELETE!!!!!!!!!!!
# ADD FLAG for mandotory LV
#
VG="vg0"
LV_PARTITIONS_LIST="root_standard root_one root_two opt_vol"
# Check free space in volume group

VG_FREE_SPACE=`vgs ${VG} --units b -o vg_free --noheadings --nosuffix 2>/dev/null | sed 's/^[ ]*//'`

if [ ! -z ${VG_FREE_SPACE} ]; then
	echo "[INFO]: There is ${VG_FREE_SPACE} free space in ${VG}"
else
	echo "[ERROR]: There isn't ${VG} volume group"
	exit
fi

LV_LIST=`lvs ${VG} -o lv_name --noheadings | sed 's/^[ ]*//'`

#if [ ! -z ${LV_LIST} ]; then
if [ "${LV_LIST}" != "" ]; then
	MANDATORY_STATE="true"
	for MANDATORY_LV in ${LV_PARTITIONS_LIST} 
       	  do
	 	LV_STATE="false"
		for CURRENT_LV in ${LV_LIST}
		  do
			if [ ${CURRENT_LV} == ${MANDATORY_LV} ] ; then
				LV_STATE="true"
			fi
		  done
		if [ ${LV_STATE} == "false" ] ; then
			echo "[ERROR]: Please create ${MANDATORY_LV} partition"	
			MANDATORY_STATE='false'
		fi
	  done
	  if [ ${MANDATORY_STATE} == "false" ] ; then
		echo "[ERROR]: Please create mandatory partitions mentioned the above."
		exit
	  else
		echo "[INFO]: All mandatory partitions are OK."
	  fi
else
	echo "[ERROR]: There isn't any logical partition in ${VG} volume group. Please create them."
fi
