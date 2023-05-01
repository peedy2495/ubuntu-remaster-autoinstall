#!/bin/bash

# find data disks by matching pattern(s) from arguments: xfs format and create entries in /etc/fstab  
# inspect your target disks in /dev/disks/by-id
# example prepDataDisks.sh scsi-SATA_CT scsi-SATA_Samsung_SSD_860 

id=0
for pattern in $@; do
    for devpath in /dev/disk/by-id/*$pattern*; do
        dev=`basename $devpath`
        if ! grep -q "$dev" /etc/fstab; then
            echo "found new storage device: $dev"
            mkfs.xfs -f $devpath
            if [ ! -d "/media/data-$id" ]; then
                mkdir /media/data-$id
                chmod 777 /media/data-$id
            fi
            echo -e "$devpath\t/media/data-$id\txfs relatime,nodev,nosuid,noexec 0 1" >>/target/etc/fstab
            echo "$dev prepared for mounting target: /media/data-$id"
        fi
        ((id=id+1))
    done
done
