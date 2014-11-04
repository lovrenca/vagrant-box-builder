#!/bin/bash
#Welcome to Kendu-BOX autobuilder

###############################---VARIABLES---##################################

BOXNAME="kendubox"                 #Name ofthe virtual machine
BOXDIRECTORY="$(pwd)"
BOXSERIAL="001"
NEWBOXNAME="${BOXNAME}-${BOXSERIAL}"
VBOXUNAME="vagrant"
VBOXKEYFILE="keys/id_rsa"
BOXDISK="${BOXDIRECTORY}/${NEWBOXNAME}/${NEWBOXNAME}-disk1.vdi"

################################################################################

###############################---FUNCTIONS---##################################

function clone(){
    echo " > Cloning image ${BOXNAME}: creating ${NEWBOXNAME}"
    mkdir -p "${BOXDIRECTORY}/${NEWBOXNAME}"
    vboxmanage clonevm \
        --name ${NEWBOXNAME} \
        --basefolder "${BOXDIRECTORY}" \
        --mode machine \
        --register \
        ${BOXNAME}

}

function start() {
    echo " > Starting virtualmachine ${NEWBOXNAME}"
    vboxmanage modifyvm ${NEWBOXNAME} --natpf1 delete ssh
    vboxmanage modifyvm ${NEWBOXNAME} --natpf1 "ssh, tcp,,22222,,22"
    vboxmanage startvm --type headless kendubox-001
}

function setup() {
    echo " > Setting up th box"
    scp -P 22222 -i ${VBOXKEYFILE} setup.sh vagrant@localhost:
    ssh -p 22222 vagrant@localhost -i ${VBOXKEYFILE} sudo ./setup.sh
    ssh -p 22222 vagrant@localhost -i ${VBOXKEYFILE} rm setup.sh
}

function zerofree() {
    #Zero free space
    echo " > Zerofreing space"
    ssh -p 22222 -i ${VBOXKEYFILE} vagrant@localhost  sudo dd if=/dev/zero of=/void bs=1M
    ssh -p 22222 -i ${VBOXKEYFILE} vagrant@localhost  sudo rm /void
}

function shrinkdisk() {
    #Shrink disk
    vboxmanage modifyhd ${BOXDISK} --compact
}

function package() {
    echo " > packaging the box"
    vagrant package --base ${NEWBOXNAME}
}
function deploy() {
    echo " > deploying new build"
}

function stop() {
    VBoxManage controlvm ${NEWBOXNAME} poweroff
}
#get ip
#vboxmanage guestproperty get ${NEWBOXNAME} /VirtualBox/GuestInfo/Net/0/V4/IP

################################################################################

###############################----ACTION-----##################################


################################################################################

$1