#!/bin/bash

# use this script with native image url as argument
WDIR=`cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P`
ISOURL="$1"

[[ -d $WDIR/content/base ]]  || mkdir -p $WDIR/content/base
[[ -d $WDIR/content/ol ]]    || mkdir -p $WDIR/content/ol
[[ -d $WDIR/content/upper ]] || mkdir -p $WDIR/content/upper
[[ -d $WDIR/content/work ]]  || mkdir -p $WDIR/content/work
[[ -d $WDIR/images ]]        || mkdir -p $WDIR/images

wget $ISOURL -N -P $WDIR/images/

ISO_FILENAME="$WDIR/images/${ISOURL##*/}"

GENISO_LABEL="Ubuntu22.04LTS server remastered" # max 32 chars
GENISO_FILENAME="${ISOURL##*/}-remastered-`date +%Y%m%d%H%M%S`.iso"
GENISO_BOOTIMG="boot/grub/i386-pc/eltorito.img"
GENISO_BOOTCATALOG="/boot.catalog"
GENISO_START_SECTOR=`sudo fdisk -l $ISO_FILENAME |grep iso2 | cut -d' ' -f2`
GENISO_END_SECTOR=`sudo fdisk -l $ISO_FILENAME |grep iso2 | cut -d' ' -f3`

sudo mount $ISO_FILENAME content/base
sudo mount -t overlay -o lowerdir=content/base,upperdir=content/upper,workdir=content/work non content/ol

sudo xorriso -as mkisofs -volid "$GENISO_LABEL" \
-output $WDIR/images/$GENISO_FILENAME \
-eltorito-boot $GENISO_BOOTIMG \
-eltorito-catalog $GENISO_BOOTCATALOG -no-emul-boot \
-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
-no-emul-boot -isohybrid-gpt-basdat \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$GENISO_START_SECTOR\d-$GENISO_END_SECTOR\d::$ISO_FILENAME \
-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:$ISO_FILENAME \
./content/ol

sudo umount $PWD/content/ol
sudo umount $PWD/content/base