echo "Please give us the below info to add the new disk to extend the swap size."
echo -n "disk (sdb): "
read -r disk

isempty=0
if [[ -z "$disk" ]]; then
   isempty=$((isempty+1))
fi
echo "Please fill all required parameters"

if [[ $isempty -eq 0 ]]; then
disk=sdc
s=$(ls /dev/mapper -l | grep swap)
swap=$(echo $s | cut -d ' '  -f9)
swap_vg=$(echo $(lvs | grep swap) | cut -d' ' -f2)
swapoff -v /dev/mapper/$swap

pvcreate /dev/$disk
vgextend ol /dev/$disk
vgchange -ay
lvextend -l +100%free /dev/$swap_vg/swap 
swapon -va
fi
