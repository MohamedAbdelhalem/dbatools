#and you need to download all or some RPMs automatically
#so you can use the below script 😉
#examples
#
#sh ~/auto_download_rpms.sh download sqlite https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-8-x86_64/
#sh ~/auto_download_rpms.sh download all https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-8-x86_64/
#sh ~/auto_download_rpms.sh view sqlite https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-8-x86_64/
#sh ~/auto_download_rpms.sh view all https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-8-x86_64/

action=$1               #type view or download
search=$2               #all or a name in the packages like SQLite or python3.
dest=$3                 #where you want to download the packages to.
url=$4                  #the original URL https://download.postgresql.org/pub/repos/yum/12/redhat/rhel-8-x86_64/

action=$(echo $action | xargs)
search=$(echo $search | xargs)

dest=$(echo $dest | xargs)
ddest=$(echo ${dest:$((${#dest} - 1 )):1})
if [[ ddest != "/" ]]; then
        dest=$dest"/"
fi

url=$(echo $url | xargs)
durl=$(echo ${url:$((${#url} - 1 )):1})
if [[ durl != "/" ]]; then
        url=$url"/"
fi

postrpms=($(curl $url | grep .rpm))
filesno=$(echo ${#postrpms[@]})
files=()
no=0
#echo $filesno
for ((c=0; c< $filesno; c++)); do
        file=$(echo ${postrpms[$c]} | cut -d ">" -f1)
        file=${file:6:1000}
        if [[ ${file:0:1} != "-" && $file == *".rpm"* ]]; then
                file=$(echo ${file:0:$((${#file}-1))})
                #echo $file
                files[$no]+=$file
                no=$((no + 1))
        fi
done
for ((u=0; u<$(echo ${#files[@]}); u++)); do
        if [[ $search == "all" ]]; then
                if [[ $action == "view" ]]; then
                        echo curl --output $dest${files[$u]} -O $url${files[$u]}
                elif [[ $action == "download" ]]; then
                        curl --output $dest${files[$u]} -O $url${files[$u]}
                fi
        else
                if [[ $action == "view" && $(echo ${files[$u]}) == *"$search"* ]]; then
                        echo curl --output $dest${files[$u]} -O $url${files[$u]}
                elif [[ $action == "download" && $(echo ${files[$u]}) == *"$search"* ]]; then
                        curl --output $dest${files[$u]} -O $url${files[$u]}
                fi
        fi
done
