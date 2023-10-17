echo "Please give us the below info to create the new LVM"
echo -n "disk (sdb): "
read -r disk
echo -n "partition no (1): "
read -r part_no
echo -n "volume group (vg_data): "
read -r vg
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
if [[ -z "$mount_point" ]]; then
   mount_point_empty=1
fi
echo "Please fill all required parameters"

if [[ $isempty -eq 0 ]]; then
umount $mount_point
lvchange -an /dev/$vg
lvremove /dev/$vg
vgremove $vg
pvremove /dev/$disk$disk_number
(
echo d
echo w
) | fdisk /dev/$disk
fi
