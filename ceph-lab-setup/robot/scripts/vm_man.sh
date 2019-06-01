#!/bin/bash
# vm_man.sh: VM image manipulation script.
#

VIRTC="/usr/bin/virt-customize"

# Check if the script is run by root.
if [ ${UID} -eq 0 ]
then
    echo "Error) Do not run this script as root."
    exit 1
fi

USAGE() {
    echo "Usage: $0 -f <qcow2_image_file> [-u <userid_to_add>] [-h <hostname>]" 1>&2
    exit 1
}
# Check arguments.
while getopts f:u:h: opt
do
    case "${opt}" in
        f)
            IMGFILE="${OPTARG}"
            ;;
        u)
            USERID="${OPTARG}"
            ;;
        h)
            HOSTN="${OPTARG}"
            ;;
        \?)
            USAGE
            exit 1
            ;;
    esac
done

# Check if virt-customize exists.
if [ ! -x ${VIRTC} ]
then
    echo "Error) There is no virt-customize commmand."
    exit 1
fi

# Check if all the necessary options got.
if [ x"$IMGFILE" == x ]
then
    USAGE
    exit 1
fi
# If $HOSTN is empty, set it to $IMGFILE without extension
if [ x"$HOSTN" == x ]
then
    HOSTN=$(basename "$IMGFILE" | cut -f1 -d'.')
fi
# Check if $IMGFILE exists.
if [ ! -f "$IMGFILE" ]
then
    echo "$IMGFILE does not exists."
    exit 1
fi

# Edit the following variables until "Do not edit below!!!"
# packages to install
IPKGS="less,sudo,vim,man-db,dnsutils,telnet,curl,sshpass,python3-apt"
# packages to remove
RPKGS="vim-tiny,nano,joe"
# DNS server
DNSSERVER="164.124.101.2"
# Do not edit below!!!

if [ x"$USERID" != x ]
then
    # read USERPW
    if [ -z ${USERPW+x} ]
    then
        echo "USERPW variable is unset."
        exit 1
    fi
fi
echo

$VIRTC -a ${IMGFILE} \
    --hostname ${HOSTN} \
    --update \
    --install ${IPKGS} \
    --uninstall ${RPKGS} \
    --root-password locked:disabled \
    --run-command "dpkg-reconfigure openssh-server" \
    --run-command "adduser --disabled-password --gecos '' ${USERID}" \
    --run-command "gpasswd -a ${USERID} sudo" \
    --password ${USERID}:password:${USERPW} \
    --copy-in /etc/hosts:/etc \
    --copy-in /tmp/interfaces:/etc/network \
    --copy-in data/grub:/etc/default \
    --run-command "update-grub" \
    --firstboot-command "resize2fs -f /dev/vda1" \
    --firstboot-command "echo nameserver ${DNSSERVER} > /etc/resolv.conf" \
    --run-command "apt-get purge --autoremove -y cloud-init" 
