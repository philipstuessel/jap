ziper() {
    select="$1"
    folder="$2"
    name="$(basename "$1")"
    filename="${name%.*}"
    if [[ $folder == "" ]];then
        folder="./"
    fi

    if file -b "$select" | grep -q 'Zip archive'; then
          if [[ "$2" == "" ]];then
                unzip $select
                return 0;
            else
                unzip $select -d $folder
                return 0
          fi
    fi

    if [ -d $select ]; then
        zip -r $filename".zip" $select
    else
    if [[ ! -d $folder ]];then
        mkdir $folder
    fi
        zip -r $filename".zip" $select
    fi
}
