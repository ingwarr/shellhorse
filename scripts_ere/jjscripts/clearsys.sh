#!/bin/bash


if [ -z ${BUILD_NUMBER+x} ]
then
    tstamp=`date +%F-%H-%M`
else
    tstamp="${BUILD_NUMBER}-${BUILD_USER_ID}"    
fi

cd /opt
# if [ -L "stack" ]
#     then 
#         scroot=`ls -la /opt/stack|awk 'BEGIN{FS="/"}{print $5}'`
#         mkdir -p /opt/backroot/${scroot}
#         rsync -av --delete --exclude "/mnt/*" --exclude "/proc/*" --exclude "/dev/*" --exclude "/sys/*" --exclude "/opt/*" --exclude "/boot/*" / /opt/backroot/${scroot}/
#         rm -f /opt/stack
# fi
if [ -f /opt/laststamp ]
    then
        laststamp=`cat /opt/laststamp`
    else
        laststamp="${tstamp}_old"
fi    


pos_roots="vg0-root_one vg0-root_two"
prefix="/dev/mapper/"
pers="vg0-root_standard"

cur_root=`mount|grep root_|grep remount-ro|awk 'BEGIN{FS="/"}{print $4}'|awk '{print $1}'`
echo "${cur_root}"
if [ "${cur_root}" == "${pers}" ]
    then
        future_root="vg0-root_one"
    else
        if [ $(date +%u) -eq 5 -a $(ls|grep `date +%F`|wc -l) -eq 0 ]
          then
#update in chroot etalon root partition
            mount $prefix$pers /mnt/src
            mount -o bind /dev /mnt/src/dev
            mount -t proc proc /mnt/src/proc
            mount -o bind /boot /mnt/src/boot
            chroot /mnt/src /bin/bash -c "source /etc/profile && apt-get -y update && apt-get -y upgrade"
            sleep 10
            umount /mnt/src/dev
            umount /mnt/src/proc
            umount /mnt/src/boot
            umount /mnt/src
        fi
########################################################################################	
#determine current and future partitions
        for pos_root in ${pos_roots}
        do
            if [ "${pos_root}" == "${cur_root}" ]
               then
        	   echo "It is equal current root is ${prefix}${pos_root}"
               else
        	   future_root=${pos_root}
        	   echo "New root will be ${prefix}${future_root}"
            fi
        done
fi
pers_root_uuid=`blkid ${prefix}${pers}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
cur_root_uuid=`blkid ${prefix}${cur_root}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
future_root_uuid=`blkid ${prefix}${future_root}|awk '{print $2}'| awk 'BEGIN {FS="\""}{print $2}'`
echo "${prefix}${pers} = ${pers_root_uuid} ${prefix}${cur_root} = ${cur_root_uuid} ${prefix}${future_root} =  ${future_root_uuid} "
#creation of new devstack environment
echo "Creating new devstack environment"
sleep 5
mv /opt/stack /opt/stack_${laststamp}
cp -r /opt/skelstack/ /opt/stack/
chown -R stack:stack /opt/stack
mkdir -p /opt/backroot/${laststamp}
rsync -av --delete --exclude "/mnt/*" --exclude "/proc/*" --exclude "/dev/*" --exclude "/sys/*" --exclude "/opt/*" --exclude "/boot/*" / /opt/backroot/${laststamp}/
# mkdir -p /opt/stack-${tstamp}
# chown -R stack:stack /opt/stack-${tstamp}
# rsync -av /opt/skelstack/ /opt/stack-${tstamp}/
# cd /opt
#[ -L "stack" ] && rm -f /opt/stack
#ln -s /opt/stack-${tstamp} /opt/stack

#rsync from standard to new
echo "Creating new rootfs"
sleep 5
mount ${prefix}${pers} /mnt/src
mount ${prefix}${future_root} /mnt/dst
#rsync -av --delete --exclude "/mnt/*" --exclude "/proc/*" --exclude "/dev/*" --exclude "/sys/*" --exclude "/opt/*" --exclude "/boot/*" /mnt/src/ /mnt/dst/
rsync -av --delete /mnt/src/ /mnt/dst/
umount /mnt/src


#change root partition in new /etc/fstab
echo "Changing configuration files"
sleep 5
sed -i "s/${pers}/${future_root}/g" /mnt/dst/etc/fstab
sed -i "s/${cur_root_uuid}/${future_root_uuid}/g" /boot/grub/grub.cfg
sed -i "s/${cur_root}/${future_root}/g" /boot/grub/grub.cfg
umount /mnt/dst
echo "${tstamp}" > /opt/laststamp
reboot
