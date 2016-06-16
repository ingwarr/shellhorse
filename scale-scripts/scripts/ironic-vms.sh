#!/bin/bash -xe
NOVA_SERVER_NAME=$1
NOVA_SERVER_PRIV_IP=$2
#NOVA_SERVER_PUB_IP=$3
#NOVA_SERVER_PASS=${NOVA_SERVER_PASS:-'ububuntu'}
#NOVA_SERVER_USER=${NOVA_SERVER_USER:-'ubuntu'}
VM_PATTERN=${VM_PATTERN:-'clone'}
MAC_PATTERN=${MAC_PATTERN:-'52:54'}
INI_FILE=/tmp/$NOVA_SERVER_NAME.ini

#ssh_exec="ssh -t -t -i /root/ironic_key.pem ${NOVA_SERVER_USER}@${NOVA_SERVER_PRIV_IP}"
virsh_exec="virsh -c qemu+tcp://${NOVA_SERVER_PRIV_IP}/system"

function get_vms_to_ini {
  local vm_names
  local vm_mac
  rm -f $INI_FILE
  vm_names=$(${virsh_exec} list --all|grep $VM_PATTERN | awk '{print $2}')
  for vm_name in ${vm_names}
    do
      vm_mac=$(${virsh_exec} domiflist ${vm_name}|grep ${MAC_PATTERN} |awk '{print $5}')
      echo "[${NOVA_SERVER_NAME}-${vm_name}]" >> $INI_FILE
      echo "mac_address=${vm_mac}" >> $INI_FILE
      echo "libvirt_uri=qemu+tcp://${NOVA_SERVER_PRIV_IP}/system" >> $INI_FILE
      echo '' >> $INI_FILE
  done

}

DEFAULT_CPU_ARCH='x86_64'
DEFAULT_RAM='2048'
DEFAULT_CPU='2'
DEFAULT_DIK='8'
IRONIC_DEPLOY_DRIVER=${IRONIC_DEPLOY_DRIVER:-'ansible_libvirt'}

source ./inc/helpers.sh


DEPLOY_KEY_FILE='/etc/ironic/deploy_key'
DEPLOY_USER_NAME='devuser'
function enrol_vms_to_ironic {
  ironic_nodes=$(iniget_sections "$INI_FILE")
  for node_name in $ironic_nodes; do
    local mac_address
    local cpus
    local memory_mb
    local local_gb
    local cpu_arch
    local libvirt_uri

    case $IRONIC_DEPLOY_DRIVER in
        "fuel_libvirt")
	    DEP_KERNEL="ironic-deploy-linux"
	    DEP_IRAM="ironic-deploy-initramfs"
#	    DEP_SQUA="ironic-deploy-squashfs"
            IRONIC_DEPLOY_SQUASHFS=${IRONIC_DEPLOY_SQUASHFS:-$(nova image-list|grep ironic-deploy-squashfs| get_field 1)}
            node_options=" \
             -i deploy_squashfs=$IRONIC_DEPLOY_SQUASHFS \
            " 
            ;;
        "ansible_libvirt")
            local node_options
	    DEP_KERNEL="ansible-deploy-linux"
	    DEP_IRAM="ansible-deploy-initramfs"
        node_options=" \
          -i deploy_key_file=$DEPLOY_KEY_FILE -i deploy_username=${DEPLOY_USER_NAME}
        "
        ;;
	"ipa_libvirt")
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


    mac_address=$(iniget $INI_FILE $node_name mac_address)
    cpus=$(iniget $INI_FILE $node_name cpus)
    cpu_arch=$(iniget $INI_FILE $node_name cpu_arch)
    memory_mb=$(iniget $INI_FILE $node_name memory_mb)
    local_gb=$(iniget $INI_FILE $node_name local_gb)
    libvirt_uri=$(iniget $INI_FILE $node_name libvirt_uri)

    # Override empty values with defaults
    cpus=${cpus:-${DEFAULT_CPU}}
    cpu_arch=${cpu_arch:-${DEFAULT_CPU_ARCH}}
    memory_mb=${memory_mb:-${DEFAULT_RAM}}
    local_gb=${local_gb:-${DEFAULT_DIK}}

    node_id=$(ironic node-create \
      --driver $IRONIC_DEPLOY_DRIVER \
      --name ${node_name} \
      -p cpus=${cpus} \
      -p memory_mb=${memory_mb} \
      -p local_gb=${local_gb} \
      -p cpu_arch=${cpu_arch} \
      -i deploy_kernel=$IRONIC_DEPLOY_KERNEL_ID \
      -i deploy_ramdisk=$IRONIC_DEPLOY_RAMDISK_ID \
      -i libvirt_uri=${libvirt_uri} \
      $node_options | grep -w "uuid" | get_field 2)
    echo "Created node $node_name [cpus: $cpus, ram: $memory_mb, disk: $local_gb, arch: $cpu_arch]"

    ironic port-create --address $mac_address --node $node_id
    echo "Created port with mac: $mac_address for node $node_name"
  done

}

get_vms_to_ini
enrol_vms_to_ironic
