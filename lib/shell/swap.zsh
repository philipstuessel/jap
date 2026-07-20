copy_to_clipboard() {
    local os=$(uname)
    local clipboard_content="$1"
    
    if [ "$os" = "Darwin" ]; then
        # for macOS
        echo "$clipboard_content" | pbcopy

    elif [ "$os" = "Linux" ]; then
        # for Linux
        if command -v xclip &> /dev/null; then
            if [ ! -z "$DISPLAY" ]; then
                echo "$clipboard_content" | xclip -selection clipboard
            fi
        else
            if xset q >/dev/null 2>&1; then
                echo -e "${RED}xclip is not installed. Please install it using:${NC}"
                echo "sudo apt-get install xclip"
            fi
        fi
    else
        echo "Unsupported OS"
    fi
}

copy() {
    if [[ "$1" == "ssh" ]]; then
        if [[ $(var "id" "$@") != 0 ]];then
            key=$(var "id" "$@")
            if [[ ! -e "$HOME/.ssh/$key" ]];then
                echo -e "${RED}SSH key not found${NC}"
                return 1
            fi
            if [[ $(var "pub" "$@") != 0 ]];then
                echo -e "${LIGHT_BLUE}Copy $key.pub${NC}"
                copy_to_clipboard "$(cat "$HOME/.ssh/$key.pub")"
            else
                echo -e "${LIGHT_BLUE}Copy $key${NC}"
                copy_to_clipboard "$(cat "$HOME/.ssh/$key")"
            fi
        else
            if [[ -e "$HOME/.ssh/id_rsa" ]];then
                if [[ $(var "pub" "$@") != 0 ]];then
                    echo -e "${LIGHT_BLUE}Copy id_rsa.pub${NC}"
                    copy_to_clipboard "$(cat "$HOME/.ssh/id_rsa.pub")"
                else
                    echo -e "${LIGHT_BLUE}Copy id_rsa${NC}"
                    copy_to_clipboard "$(cat "$HOME/.ssh/id_rsa")"
                fi
            else
                echo -e "${RED}SSH key not found${NC}"
                return 1
            fi
        fi
        return 0
    fi
    if [[ "$1" == "pwd" || "$1" == "p" ]]; then
        if [[ ! "$2" == "" ]]; then
            copy_to_clipboard "$(pwd)/$2"
            if [[ ! $? == null ]]; then
                echo -e ${BLUE}$(pwd)/"$2"${NC}; 
            fi
        else
            copy_to_clipboard "$(pwd)"
            if [[ ! $? == null ]]; then
                echo -e ${BLUE}$(pwd)${NC}
            fi
        fi
    else
        if [[ ! -e "$1"  ]]; then
            echo -e "${RED}File '$1' does not exist!${NC}"
            return 1
        fi

        if [[ ! -f "$1" ]]; then
            echo -e "${RED}The path '$1' is not a file!${NC}"
            return 1
        fi
        copy_to_clipboard "$(cat "$1")"
         if [[ ! $? == null ]]; then
            copy_temp "$1"
            echo -e "${LIGHT_WHITE}${1}${NC} was copied into the clipboard 📋"
        fi
    fi
}

copy_temp() {
    : "${tempf:=$HOME/jap/temp/}"
    file="$1"
    if [ ! -e $tempf"copy.txt" ];then
        t "${tempf}copy.txt"
    fi
    cat $file > "${tempf}copy.txt" 
    filepath="$(readlink -f "$1")"
    if [ ! -e $tempf"copypath.txt" ];then
        t "${tempf}copypath.txt"
    fi
    echo "$filepath" > "${tempf}copypath.txt"
}

paste() {
    : "${tempf:=$HOME/jap/temp/}"
    if [ ! -e $tempf"undo.txt" ];then
        t "${tempf}undo.txt"
    fi
    if [[ $(var "v" "$@") != 0 ]];then
        echo -e "path: ${BOLD}$(cat $tempf"copypath.txt")${NC}"
        echo ""
        echo -e "content: ${BOLD}$(cat $tempf"copy.txt")${NC}"
        return 1
    fi
    if [[ "$1" == "" && -e $tempf"copypath.txt" || "$1" == "-y" ]];then
        copypath=$(cat $tempf"copypath.txt")
        name="$(basename "$copypath")"
        if [[ -e "$(pwd)/$name" && ! "$1" == "-y" ]];then
            echo -n "This file already exists, do you want to overwrite it (y/n): "
            read option
            if [[ "$option" == "n" ]]; then
                echo ""
                return 1
            fi
        fi
        t $name
        cat "${tempf}copy.txt" > "$name" 
        echo "was added to the $name 📋"
    else
        name="$(basename "$1")"
        echo "$(pwd)/$name" > "${tempf}undo.txt" 
        cat "$1" >> "${tempf}undo.txt" 
        cat "${tempf}copy.txt" > "$1" 
        echo "was added to the $name 📋"
    fi
}

create_undo() {
    : "${tempf:=$HOME/jap/temp/}"
    name="$(basename "$1")"
    echo "$(pwd)/$name" > "${tempf}undo.txt" 
    cat "$1" >> "${tempf}undo.txt"
}

undo() {
    : "${tempf:=$HOME/jap/temp/}"
    pathundo=$(awk 'NR==1' "${tempf}undo.txt")
    if [[ -e "$pathundo" ]];then
        $(awk 'NR > 1' "${tempf}undo.txt" > "$pathundo")
        copypath=$(cat $tempf"copypath.txt")
        echo "The file ($pathundo) have been restored"
    else
        echo "Error: File '$pathundo' does not exist!"
    fi
}

t() {
    folder="$(dirname "$1")"
    start="${folder:0:1}"
    if [[ $start == "/" ]];then
        mkdir -p "$folder"
        touch "$1"
    else    
        mkdir -p "$(pwd)/$folder"
        touch "$1"
    fi
}

edit() {
    file="$1"
    if [[ "$1" == "-clear" ]];then
        file="$2"
        if [[ -f "$file" ]];then
            create_undo "$file"
        fi
        echo "" > "$file"
    fi
    editor=$(jq -r .editor $JAP_config_Json)
    if [[ "$1" == "" ]];then
        $editor "."
    else
        $editor $file
    fi
}