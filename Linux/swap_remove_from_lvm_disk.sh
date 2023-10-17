lvreduce --size 100Mb /dev/ol/swap 
vgreduce ol /dev/sdc
pvremove /dev/sdc
lvextend -l +100%free /dev/ol/swap 
