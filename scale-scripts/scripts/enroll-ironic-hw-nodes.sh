#!/bin/bash

HARDWARE_NODES_FILE=${HARDWARE_NODES_FILE:-'/root/hardware-nodes.ini'}
DEFAULT_CPU_ARCH='x86_64'
DEFAULT_RAM='32768'
DEFAULT_CPU='12'
DEFAULT_DIK='128'
DEFAULT_IPMI_USERNAME='ironic'
IRONIC_DEPLOY_DRIVER='fuel_ipmitool'

source ./inc/helpers.sh

IRONIC_DEPLOY_DRIVER=${IRONIC_DEPLOY_DRIVER:-'fuel_ipmitool'}
DEPLOY_KEY_FILE='/etc/ironic/deploy_key'
DEPLOY_USER_NAME='devuser'

function enroll_nodes {
  ironic_nodes=$(iniget_sections "${HARDWARE_NODES_FILE}")
  for node_name in ${ironic_nodes}; do
    local mac_address
    local cpus
    local memory_mb
    local local_gb
    local cpu_arch
    local ipmi_address
    local ipmi_username
    local ipmi_password
    case ${IRONIC_DEPLOY_DRIVER} in
        "fuel_ipmitool")
	    DEP_KERNEL="ironic-deploy-linux"
	    DEP_IRAM="ironic-deploy-initramfs"
            IRONIC_DEPLOY_SQUASHFS=${IRONIC_DEPLOY_SQUASHFS:-$(nova image-list|grep ironic-deploy-squashfs| get_field 1)}
            driver_options=" \
             -i deploy_squashfs=${IRONIC_DEPLOY_SQUASHFS} \
            " 
            ;;
        "ansible_ipmitool")
            local node_options
	    DEP_KERNEL="ansible-deploy-linux"
	    DEP_IRAM="ansible-deploy-initramfs"
        driver_options=" \
          -i deploy_key_file=${DEPLOY_KEY_FILE} -i deploy_username=${DEPLOY_USER_NAME}
        "
        ;;
	"agent_ipmitool")
#            local node_options
	    DEP_KERNEL="ipa-deploy-linux"
	    DEP_IRAM="ipa-deploy-initramfs"
#        node_options=" \
#          -i deploy_key_file=$DEPLOY_KEY_FILE
#        "
	;;
    esac

    IRONIC_DEPLOY_KERNEL_ID=${IRONIC_DEPLOY_KERNEL_ID:-$(nova image-list|grep ${DEP_KERNEL}| get_field 1)}
    IRONIC_DEPLOY_RAMDISK_ID=${IRONIC_DEPLOY_RAMDISK_ID:-$(nova image-list|grep ${DEP_IRAM}| get_field 1)}

    # Common parameters for VM and HW nodes
    mac_address=$(iniget ${HARDWARE_NODES_FILE} ${node_name} mac_address)
    cpus=$(iniget ${HARDWARE_NODES_FILE} ${node_name} cpus)
    cpu_arch=$(iniget ${HARDWARE_NODES_FILE} ${node_name} cpu_arch)
    memory_mb=$(iniget ${HARDWARE_NODES_FILE} ${node_name} memory_mb)
    local_gb=$(iniget ${HARDWARE_NODES_FILE} ${node_name} local_gb)

    ipmi_address=$(iniget ${HARDWARE_NODES_FILE} ${node_name} ipmi_address)
    ipmi_username=$(iniget ${HARDWARE_NODES_FILE} ${node_name} ipmi_username)
    ipmi_password=$(iniget ${HARDWARE_NODES_FILE} ${node_name} ipmi_password)

    # Override empty values with defaults
    cpus=${cpus:-${DEFAULT_CPU}}
    cpu_arch=${cpu_arch:-${DEFAULT_CPU_ARCH}}
    memory_mb=${memory_mb:-${DEFAULT_RAM}}
    local_gb=${local_gb:-${DEFAULT_DIK}}
    ipmi_username=${ipmi_username:-${DEFAULT_IPMI_USERNAME}}
    
    local node_options="\
      -i ipmi_address=${ipmi_address} \
      -i ipmi_password=${ipmi_password} \
      -i ipmi_username=${ipmi_username}"

    node_id=$(ironic node-create $standalone_node_uuid \
      --driver $IRONIC_DEPLOY_DRIVER \
      --name ${node_name} \
      -p cpus=${cpus} \
      -p memory_mb=${memory_mb} \
      -p local_gb=${local_gb} \
      -p cpu_arch=${cpu_arch} \
      -i deploy_kernel=${IRONIC_DEPLOY_KERNEL_ID} \
      -i deploy_ramdisk=${IRONIC_DEPLOY_RAMDISK_ID} \
      -i deploy_squashfs=${IRONIC_DEPLOY_SQUASHFS} \
      ${node_options} ${driver_options}| grep -w "uuid" | get_field 2)
    echo "Created node ${node_name} [cpus: ${cpus}, ram: ${memory_mb}, disk: ${local_gb}, arch: ${cpu_arch}]"

    ironic port-create --address ${mac_address} --node ${node_id}
    echo "Created port with mac: ${mac_address} for node ${node_name}"

  done
}

enroll_nodes
