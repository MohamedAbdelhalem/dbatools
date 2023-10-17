echo "Please give us the below info to create the new LVM"
echo -n "disk (sdb): "
read -r disk
echo -n "volume group (vg_data): "
read -r vg
echo -n "partition no (1): "
read -r part_no
echo -n "LVM (lv_data01): "
read -r lv
echo -n "mount point (/u01 or /data): "
read -r mount_point

isempty=0
if [[ -z "$disk" ]]; then
   isempty=$((isempty+1))
fi
if [[ -z "$vg" ]]; then
   isempty=$((isempty+1))
fi
if [[ -z "$part_no" ]]; then
   part_no_empty=1
fi
if [[ -z "$lv" ]]; then
   lv_empty=1
fi
if [[ -z "$mount_point" ]]; then
   mount_point_empty=1
fi
echo "Please fill all required parameters"

if [[ $isempty -eq 0 ]]; then
(
echo o # Create a new empty DOS partition table
echo n # Add a new partition
echo p # Primary partition
echo $part_no # Partition number
echo   # First sector (Accept default: 1)
echo   # Last sector (Accept default: varies)
echo t # Write changes
echo 8e # Write changes
echo w # Write changes
) | fdisk /dev/$disk

#wc=$(lsblk | grep $disk | wc)
#part=$(echo $wc| cut -d' ' -f 1) - 1
pvcreate /dev/$disk$part_no
vgcreate $vg /dev/$disk$part_no
lvcreate --name $lv -l 100%FREE $vg
mkfs.ext4 /dev/$vg/$lv
mkdir -p $mount_point
mount /dev/$vg/$lv $mount_point
echo /dev/$vg/$lv  $mount_point ext4 defaults 0 0 >> /etc/fstab
fi
