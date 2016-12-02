#!/bin/bash

block_count=2048
block_size=512

for drive in `lshw -class disk|awk '/logical / {print $3}'`
    do
        part_per_disk=`sfdisk -l|grep "^${drive}"|wc -l`
        echo ${part_per_disk}
        echo "$i"
        for pcount in `seq 1 ${part_per_disk}`
            do
                echo ${drive}${pcount}
                fields=`sfdisk -l "${drive}"|grep "^${drive}${pcount}"|awk '{print $2" "$3 }'`
                f_num=0
                for field in ${fields}
                    do
                        let "f_num += 1"
		        if [ ${f_num} -eq 1 ]
                            then
                                seek_offset=${field}     
			    else
			        let "seek_offset = field - block_count"
                                f_num=0
                        fi
                        echo "dd if=/dev/zero of=${drive} bs=${block_size} seek=${seek_offset} count=${block_count}"
                    done
	    done
    done

