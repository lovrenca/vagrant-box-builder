#!/bin/bash
#Welcome to Kendu-BOX autobuilder

set -e

###############################---VARIABLES---##################################

BOXNAME="kendubox"                 #Name ofthe virtual machine
BOXDIRECTORY="$(pwd)"
VBOXUNAME="vagrant"
VBOXKEYFILE="keys/id_rsa"
NEWDISK=~/VirtualBox\ VMs/${BOXNAME}/${BOXNAME}-disk1.vdi
OLDDISK=~/VirtualBox\ VMs/${BOXNAME}/${BOXNAME}-disk2.vmdk
BOXPATH="/opt/web/vagrant"

################################################################################

###############################---FUNCTIONS---##################################

function import() {
    #Import vm and ormat diskfile to vdi
    echo " > Importing virtual machine"
    vboxmanage import "${BOXNAME}.ova"
    echo " > Converting VM HD to .vdi"
    vboxmanage clonehd --format VDI \
        "${OLDDISK}" \
        "${NEWDISK}"
    echo " > registering new disk"
    vboxmanage storageattach ${BOXNAME} --storagectl SATA --port 0 --type hdd --medium "${NEWDISK}"
}

function start() {
    #Set port forward to make ssh accessible, and start the vm.
    echo " > Setting NAT rule"
    vboxmanage modifyvm ${BOXNAME} --natpf1 "ssh, tcp,,22222,,22" || true
    echo " > Starting virtualmachine ${BOXNAME}"
    vboxmanage startvm --type headless ${BOXNAME}
    counter=1;
    while true
    do
         ssh -p 22222 vagrant@localhost \
            -o UserKnownHostsFile=/dev/null \
            -o StrictHostKeyChecking=no \
            -o ConnectTimeout=1 \
            -i ${VBOXKEYFILE} \
            true >> /dev/null && \
         echo " > VM started sucsesfully" && \
         break || echo "."
         echo "* Probing VM, attempt $counter"
         sleep 1
         counter=$((counter+1))
         if [ "$counter" -gt "30" ]
         then
            exit 1
        fi
    done
}

function setup() {
    #Install all necessary opackets and update all
    echo " > Setting up th box"
    scp -P 22222 -i ${VBOXKEYFILE} setup.sh vagrant@localhost:
    ssh -p 22222 vagrant@localhost -i ${VBOXKEYFILE} chmod +x setup.sh
    ssh -p 22222 vagrant@localhost -i ${VBOXKEYFILE} sudo ./setup.sh
    ssh -p 22222 vagrant@localhost -i ${VBOXKEYFILE} rm setup.sh
}

function zerofree() {
    #Zero free space
    echo " > Zerofreing space"
    ssh -p 22222 -i ${VBOXKEYFILE} vagrant@localhost  sudo dd if=/dev/zero of=/void bs=1M || true
    ssh -p 22222 -i ${VBOXKEYFILE} vagrant@localhost  sudo rm /void
}

function shrinkdisk() {
    #Shrink disk
    echo " > Shrinking disk"
    vboxmanage modifyhd "${NEWDISK}" --compact
}

function package() {
    echo " > Packaging box"
    vagrant package --base ${BOXNAME}
}

function deploy() {
    echo " > deploying new build"
    mv "${BOXPATH}/${BOXNAME}.box" "${BOXPATH}/${BOXNAME}.old"
    mv package.box "${BOXPATH}/${BOXNAME}.box"
}

function stop() {
    echo " > Stopping VM"
    VBoxManage controlvm ${BOXNAME} poweroff
    vboxmanage modifyvm ${BOXNAME} --natpf1 delete ssh
}

function delete() {
    echo " > Deleting VM"
    vboxmanage unregistervm ${BOXNAME} --delete
}

################################################################################

###############################----ACTION-----##################################

import
start
setup
zerofree
stop
shrinkdisk
package
deploy
delete

################################################################################
