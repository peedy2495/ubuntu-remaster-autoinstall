#!/bin/bash

exePath="$(dirname -- "${BASH_SOURCE[0]}")"

source $exePath/hostValues

for host in "${!hosts[@]}"; do
    if ip addr | grep -q "${hosts[$host]}"; then
        break
    fi
done

curtin in-target --target=/target -- sed -i "s/192.168.2.222/${IPs[$host]}/" /etc/netplan/00-installer-config.yaml
curtin in-target --target=/target -- sed -i "s/node-0/$host.$domain/" /etc/hostname
curtin in-target --target=/target -- sed -i "s/node-0/$host.$domain/" /etc/hosts