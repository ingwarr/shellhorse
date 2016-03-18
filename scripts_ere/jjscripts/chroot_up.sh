#!/bin/bash

prefix="/dev/mapper/"
pers="vg0-root_standard"
#update in chroot etalon root partition
            mount $prefix$pers /mnt/src
            mount -o bind /dev /mnt/src/dev
            mount -t proc proc /mnt/src/proc
            mount -o bind /boot /mnt/src/boot
            mount -o bind /run /mnt/src/run
            chroot /mnt/src /bin/bash -c "source /etc/profile && apt-get -y --force-yes update && apt-get -y --force-yes upgrade"
            sleep 10
            umount /mnt/src/dev
            umount /mnt/src/proc
            umount /mnt/src/boot
	    umount /mnt/src/run
            umount /mnt/src

echo "Standard ubuntu partition updated..."
