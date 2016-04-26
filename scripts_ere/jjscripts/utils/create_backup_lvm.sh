LV_ROOT_STANDARD="root_standard"
LV_ROOT_FIRST="root_one"
LV_ROOT_SECOND="root_two"
VG="vg0"
HOSTNAME=`hostname`
USER_ID="shadoff"
BASE_DIR="/home/work/multi-root/shellhorse/scripts_ere/jjscripts"


if [ -z ${BUILD_NUMBER+x} ]
then
    JOBSTAMP=`date +%F-%H-%M`
else
    JOBSTAMP="${BUILD_NUMBER}"
fi

BACKUP_FULL_PATH="${BASE_DIR}/backups/${HOSTNAME}_${USER_ID}_${JOBSTAMP}"

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

echo "[INFO]: Creating new backup of DevStack environment"
mkdir -p "${BACKUP_FULL_PATH}"
mount "${LV_CURRENT_ROOT}" "$BASE_DIR/mnt/source_fs"
rsync -av --delete --exclude "/dev/*" "$BASE_DIR/mnt/source_fs/" "${BACKUP_FULL_PATH}/"
mv /opt/stack "${BACKUP_FULL_PATH}_stack"
umount "$BASE_DIR/mnt/source_fs/"

cp -r /opt/skelstack/ /opt/stack/
chown -R stack:stack /opt/stack

