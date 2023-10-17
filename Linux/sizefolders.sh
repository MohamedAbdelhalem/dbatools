#by the way all of these lines of code to avoid any error when you have a folder with space like /home/postgres/python scripts/

folder=$1
v=0
size=0
no=($(ls $folder | grep "^d" | wc -l))
folders=($(ls -l $folder | grep "^d"))
detail=""
print=""
toprint=0
sfolde=""
size=""
hh="-"
rr=""
sf=0
for ((c = 0; c < ${#folders[@]}; c++)); do
        if [[ ${folders[$c]} == *"drwx"* ]]; then
                if [ $v == 0 ]; then
                        toprint=0
                else
                        toprint=1
                fi
                print=$detail
                v=1
                detail=${folders[$c]}
        else
                v=$(($v + 1))
                if [[ $v > 10 ]]; then
                        detail=$detail" "${folders[$c]}
                else
                        detail=$detail","${folders[$c]}
                fi
                toprint=0
        fi
        if [ $toprint == 1 ]; then
                sfolder=$(echo $print | cut -d " " -f9)
                if [[ $sfolder == *","* ]]; then
                        sfolder=$(echo $sfolder | tr "," " ")
                        size=$(du -Dh | grep "./$sfolder" | grep "\<$sfolder\>")
                else
                        size=$(du -ch $sfolder | grep total)
                fi
                size=$(echo $size | cut -d " " -f1)
                sf=$(( 20 - ${#size}))
                printf "%s %"$sf"d %s\n" $size "" "$sfolder"
        fi
done
sfolder=$(echo $detail | cut -d " " -f9)
if [[ $sfolder == *","* ]]; then
        sfolder=$(echo $sfolder | tr "," " ")
        size=$(du -Dh | grep "./$sfolder" | grep "\<$sfolder\>")
else
        size=$(du -ch $sfolder | grep total)
fi
size=$(echo $size | cut -d " " -f1)
sf=$(( 20 - ${#size}))
printf "%s %"$sf"d %s\n" $size "" "$sfolder"
