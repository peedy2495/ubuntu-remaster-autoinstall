#!/bin/bash

# use this script with native image url as argument
WDIR=`cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P`
ISOURL="$1"

[[ -d $WDIR/iso/base ]]       || mkdir -p $WDIR/iso/base
[[ -d $WDIR/iso/ol ]]         || mkdir -p $WDIR/iso/ol
[[ -d $WDIR/iso/upper ]]      || mkdir -p $WDIR/iso/upper
[[ -d $WDIR/iso/work ]]       || mkdir -p $WDIR/iso/work
[[ -d $WDIR/images ]]         || mkdir -p $WDIR/images
[[ -d $WDIR/squashfs/base ]]  || mkdir -p $WDIR/squashfs/base
[[ -d $WDIR/squashfs/ol ]]    || mkdir -p $WDIR/squashfs/ol
[[ -d $WDIR/squashfs/upper ]] || mkdir -p $WDIR/squashfs/upper
[[ -d $WDIR/squashfs/work ]]  || mkdir -p $WDIR/squashfs/work

wget $ISOURL -N -P $WDIR/images/

ISO_FILEPATH="$WDIR/images/${ISOURL##*/}"
ISO_FILENAME="${ISOURL##*/}"
ISO_FILENAME="${ISO_FILENAME%.iso}"

GENISO_LABEL="Ubuntu22.04LTS server remastered" # max 32 chars
GENISO_FILENAME="$ISO_FILENAME-remastered-`date +%Y%m%d%H%M%S`.iso"
GENISO_BOOTIMG="boot/grub/i386-pc/eltorito.img"
GENISO_BOOTCATALOG="/boot.catalog"
GENISO_START_SECTOR=`sudo fdisk -l $ISO_FILEPATH |grep iso2 | cut -d' ' -f2`
GENISO_END_SECTOR=`sudo fdisk -l $ISO_FILEPATH |grep iso2 | cut -d' ' -f3`

# mount iso and overlayfs for interfering custom files
sudo mount $ISO_FILEPATH iso/base
sudo mount -t overlay -o lowerdir=iso/base,upperdir=iso/upper,workdir=iso/work non iso/ol

# mount squashfs file from iso and overlayfs for interfering custom files
sudo mount $WDIR/iso/base/casper/ubuntu-server-minimal.ubuntu-server.installer.squashfs $WDIR/squashfs/base -t squashfs -o loop
sudo mount -t overlay -o lowerdir=squashfs/base,upperdir=squashfs/upper,workdir=squashfs/work overlay squashfs/ol

# create new squashfs image in iso
sudo mkdir $WDIR/iso/upper/casper
sudo mksquashfs $WDIR/squashfs/ol $WDIR/iso/upper/casper/ubuntu-server-minimal.ubuntu-server.installer.squashfs

# squashfs operations finished - unmount
sudo umount $WDIR/squashfs/ol
sudo umount $WDIR/squashfs/base

# create new iso image containing all custum ingredients
sudo xorriso -as mkisofs -volid "$GENISO_LABEL" \
-output $WDIR/images/$GENISO_FILENAME \
-eltorito-boot $GENISO_BOOTIMG \
-eltorito-catalog $GENISO_BOOTCATALOG -no-emul-boot \
-boot-load-size 4 -boot-info-table -eltorito-alt-boot \
-no-emul-boot -isohybrid-gpt-basdat \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:$GENISO_START_SECTOR\d-$GENISO_END_SECTOR\d::$ISO_FILEPATH \
-e '--interval:appended_partition_2_start_1782357s_size_8496d:all::' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:$ISO_FILEPATH \
./iso/ol

sudo umount $WDIR/iso/ol
sudo umount $WDIR/iso/base
