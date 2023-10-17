#[root@localhost ~]# sh increase_swap.sh Swap 1
#1024+0 records in
#1024+0 records out
#1073741824 bytes (1.1 GB) copied, 1.19677 s, 897 MB/s
#Setting up swapspace version 1, size = 1048572 KiB
#no label, UUID=598033bc-a829-4dd8-8bb9-de95e196d7df
#Mem:           974M        109M         63M        6.6M        800M        706M
#Swap:            9G          0B          9G
###################################################################################
#copy the below script into your sh file
###################################################################################
dir=$1          #parameter1 means the directory /swap
siz=$2          #parameter2 means the swap file size = 1GB
swaparr=()
nofiles=()
siz=$((siz * 1024))
query=$(ls / | grep "\<$dir\>")
exist=${#query}
if [[ $exist -gt 0 ]]; then
        swaparr=($(ls /$dir | grep swapfile))
        for ((c=0; $c<${#swaparr[@]}; c++)); do
                file=$(echo ${swaparr[$c]} | cut -d " " -f9-)
                nofiles=(${file:8:3})
        done
	curr=$(($(echo "${nofiles[*]}" | sort -nr | head -n1) + 1))
else
	mkdir /$dir
	curr=1
fi

dd if=/dev/zero of=/$dir/swapfile$curr bs=1M count=$siz
mkswap /$dir/swapfile$curr
chmod 600 /$dir/swapfile$curr
chown -R root:root /$dir/swapfile$curr
echo "/$dir/swapfile$curr         swap                    swap    defaults        0 0" >> /etc/fstab
swapon -a
swapon -s
free -h
