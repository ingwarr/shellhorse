#!/bin/bash

if [ -z ${BUILD_NUMBER+x} ]
then
    tstamp=`date +%F-%H-%M`
else
    tstamp="${BUILD_NUMBER}-${BUILD_USER_ID}"    
fi


if [ -f /opt/laststamp_back ]
    then
        laststamp=`cat /opt/laststamp_back`
    else
        laststamp="${tstamp}_old"
fi    


pos_roots="vg0-root_one vg0-root_two"
prefix="/dev/mapper/"
pers="vg0-root_standard"

cur_root=`mount|grep root_|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`

mkdir -p /opt/backroot/${laststamp}_back
mount ${prefix}${cur_root} /mnt/src
rsync -av --delete --exclude "/dev/*" /mnt/src/ /opt/backroot/${laststamp}_back/
cp -r /opt/stack /opt/stack_${laststamp}_back
chown -R stack:stack /opt/stack_${laststamp}_back
umount /mnt/src
echo $laststamp > /opt/laststamp_back
echo "Backup finished to dirs ${laststamp}_back (rootfs) and /opt/stack_${laststamp}_back (stack's) home"
