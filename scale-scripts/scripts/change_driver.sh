#!/bin/bash

CHANGE_FROM="fuel_ipmitool"
CHANGE_TO="ansible_ipmitool"

source ./inc/helpers.sh

function choose_method {
    case ${CHANGE_TO} in
        "fuel_ipmitool")
	    DEP_KERNEL="ironic-deploy-linux"
	    DEP_IRAM="ironic-deploy-initramfs"
            IRONIC_DEPLOY_SQUASHFS=${IRONIC_DEPLOY_SQUASHFS:-$(nova image-list|grep ironic-deploy-squashfs| get_field 1)}
            case ${CHANGE_FROM} in
		"ansible_ipmitool")
		    TO_ADD="driver_info/deploy_squashfs=${IRONIC_DEPLOY_SQUASHFS}"
		    TO_REMOVE="driver_info/deploy_key_file driver_info/deploy_username"
                    ;;
		"agent_ipmitool")
		    TO_ADD="driver_info/deploy_squashfs=${IRONIC_DEPLOY_SQUASHFS}"
		    TO_REMOVE="0"
		    ;;
	    esac
            ;;
        "ansible_ipmitool")
	    DEP_KERNEL="ansible-kernel"
	    DEP_IRAM="ansible-initrd"
            DEPLOY_KEY_FILE='/etc/ironic/deploy_key'
            DEPLOY_USER_NAME='devuser'
            case ${CHANGE_FROM} in
		"fuel_ipmitool")
		    TO_ADD="driver_info/deploy_key_file=${DEPLOY_KEY_FILE} driver_info/deploy_username=${DEPLOY_USER_NAME}"
		    TO_REMOVE="driver_info/deploy_squashfs"
                    ;;
		"agent_ipmitool")
		    TO_ADD="driver_info/deploy_key_file=${DEPLOY_KEY_FILE} driver_info/deploy_username=${DEPLOY_USER_NAME}"
		    TO_REMOVE="0"
		    ;;
	    esac
        ;;
	"agent_ipmitool")
	    DEP_KERNEL="ipa-kernel"
	    DEP_IRAM="ipa-initrd"
            case ${CHANGE_FROM} in
		"fuel_ipmitool")
		    TO_ADD="0"
		    TO_REMOVE="driver_info/deploy_squashfs"
                    ;;
		"ansible_ipmitool")
		    TO_ADD="0"
		    TO_REMOVE="driver_info/deploy_key_file driver_info/deploy_username"
		    ;;
	    esac
	;;
    esac
}

function implement_updates {
IRONIC_KERNEL_IMAGE=$(nova image-list|grep ${DEP_KERNEL}| get_field 1)
IRONIC_DEPLOY_RAMDISK_ID=$(nova image-list|grep ${DEP_IRAM}| get_field 1)
IR_NODES=`ironic node-list|awk '/available/ {print $2}'`
for IR_NODE in ${IR_NODES}
    do
	if [ ${TO_ADD} != "0" ]; then ironic node-update ${IR_NODE} add ${TO_ADD} ; fi
	ironic node-update ${IR_NODE} replace driver=${CHANGE_TO} driver_info/deploy_kernel=${IRONIC_KERNEL_IMAGE} driver_info/deploy_ramdisk=${IRONIC_DEPLOY_RAMDISK_ID}
        if [ ${TO_REMOVE} != "0" ]; then ironic node-update ${IR_NODE} remove ${TO_REMOVE}; fi
    done
}

choose_method
#TEST:
# IRONIC_KERNEL_IMAGE=$(nova image-list|grep ${DEP_KERNEL}| get_field 1)
# IRONIC_DEPLOY_RAMDISK_ID=$(nova image-list|grep ${DEP_IRAM}| get_field 1)
# echo "add ${TO_ADD} "
# echo "replace driver=${CHANGE_TO} driver_info/deploy_kernel=${IRONIC_KERNEL_IMAGE} driver_info/deploy_ramdisk=${IRONIC_DEPLOY_RAMDISK_ID}"
# echo "remove ${TO_REMOVE}"
implement_updates
