#!/bin/bash

# user-data network section intentionally left blank, because of odd hickups in setting up tagged vlan interfaces with some switch models.

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/hostValues

for host in "${!hosts[@]}"; do
    if ip addr | grep -q "${hosts[$host]}"; then
        break
    fi
done
curtin in-target --target=/target -- wget -O /etc/netplan/00-installer-config.yaml $(cat /cdrom/boot/grub/grub.cfg |grep s=|cut -d ";" -f 2|cut -d "=" -f 2|tr -d " -")/assets/network-template.yaml
curtin in-target --target=/target -- sed -i "s/192.168.2.222/${IPs[$host]}/" /etc/netplan/00-installer-config.yaml
curtin in-target --target=/target -- sed -i "s/00:00:00:00:00:00/${hosts[$host]}/" /etc/netplan/00-installer-config.yaml
curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hostname
curtin in-target --target=/target -- sed -i "s/premature/$host.$domain/" /etc/hosts

