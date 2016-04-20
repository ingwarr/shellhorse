#!/bin/bash                                                                                                                                                                    

used_cpus=0
used_memory=0
st_pools=`virsh pool-list|awk '/active/ {print $1}'`
mem_total=`virsh nodememstats|awk '/total/ {print $3}'`
gt_cpus=`cat /proc/cpuinfo |grep processor|wc -l`
let "total_vcpus = gt_cpus * 3"
#list of actual vms                                                                                                                                                            
running_vms=`virsh list|awk '/running/ { print $2}'`
echo "Calculating"
#Calculate used memory and cpus                                                                                                                                                
for vm in $running_vms
    do
         vm_mem=`virsh dumpxml ${vm}|awk -F "<|>" '/memory/ {print $3}'`
       	 vm_cpus=`virsh dumpxml ${vm}|awk -F "<|>" '/vcpu/ {print $3}'`
         let "used_memory += vm_mem"
         let "used_cpus += vm_cpus"
    done
let "freemem = (mem_total - used_memory) / 1024"
let "used_memory /= 1024"
let "freecpus = total_vcpus - used_cpus"
echo "${used_cpus} vcpus used"
echo "${used_memory}MB of memory used"
echo "${freemem}MB of memory free"
echo "${freecpus} vcpus free"

#Available space in pools                                                                                                                                                      
for st_pool in ${st_pools}
    do
      pool_path=`virsh pool-dumpxml ${st_pool} |awk 'BEGIN {FS="<|>"} /path/ {print $3}'`
      free_space=`df --output=avail ${pool_path}|grep -v Avail`
      let "free_space /= 1024"
      echo "Free space in ${st_pool} pool is ${free_space} MB"
    done
