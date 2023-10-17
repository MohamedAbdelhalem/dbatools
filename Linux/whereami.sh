mask=$1
net=$(ls /etc/sysconfig/network-scripts/ | grep ifcfg)
net=$(echo $net | cut -d " " -f1)
net=$(echo $net | cut -d "-" -f2)
net=$(ip a | grep $net | grep /$mask)
net=$(echo $net | cut -d " " -f2)
net=$(echo $net | cut -d "/" -f1)
ver=$(cat /etc/os-release | grep PRETTY_NAME)
ver=$(echo $ver | cut -d "=" -f2)
echo $net
echo $ver
