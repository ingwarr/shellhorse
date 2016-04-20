check_lvm2_centos()
{
# LVM2 package is installed check 
LVM2_PACKAGE_STATE=`rpm -qa | grep lvm2 | grep -v libs | cut -d'-' -f1`
# LVM2 module is loaded check
LVM2_MODULE_STATE=`lsmod | grep dm_mod | cut -d' ' -f1`

if [ "${LVM2_PACKAGE_STATE}" == "lvm2" ]
then
	echo "[INFO]: ${LVM2_PACKAGE_STATE} package is installed."
else
	echo "[ERROR]: ${LVM2_PACKAGE_STATE} package isn't installed."
	exit
fi

if [ "${LVM2_MODULE_STATE}" == "dm_mod" ]
then
        echo "[INFO]: ${LVM2_MODULE_STATE} module is loaded."
else
	echo "[ERROR]: ${LVM2_MODULE_STATE} module isn't loaded."
	exit
fi
}
