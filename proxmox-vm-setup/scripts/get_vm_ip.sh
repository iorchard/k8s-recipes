#!/usr/bin/env bash

usage() {
  echo "$(basename $0) VM"
}

get_vm_id() {
  sudo qm list | awk '/'"${1}"'/ { print $1 }'	
}

get_vm_mac_addr() {
  sudo qm config "$1" | awk '/net0/ { print tolower($2) }' | \
    sed -r 's/virtio=(.*),.*/\1/g'
}

get_ip_from_mac_arp() {
  /usr/sbin/arp -an | awk '/'"$1"'/ { print $2 }' | sed 's/(\(.*\))/\1/g'
}

if [[ -z "$1" ]]
then
  usage
  exit 2
fi

case "$1" in
  -h|--help|help)
    usage
    exit 0
esac

VM_ID=$(get_vm_id $1)

if [[ -z "$VM_ID" ]]
then
  echo "Could not determine VM ID for $1"
  exit 3
fi

VM_MAC_ADDR=$(get_vm_mac_addr "$VM_ID")

if [[ -z "$VM_MAC_ADDR" ]]
then
  echo "Could not determine VM MAC address for $1 ($VM_ID)"
  exit 3
fi

get_ip_from_mac_arp "$VM_MAC_ADDR"

# vim: set et ts=2 sw=2 ft=bash :
