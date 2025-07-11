#!/bin/zsh
# alias
alias s="source ~/.zshrc"
alias sb="source ~/.bashrc"
alias q="killall Terminal"
alias l="ls -lah"
alias o="open ."
alias cls="clear"
alias home="cd ~"
alias c="code ."
alias py="python3"
alias python="python3"
alias pyv="py --version  && echo "" && which python3"
alias pip="pip3"
alias pwdc="copy pwd"
alias e="edit"
alias run="jap run"
alias install="spm i"
alias update="spm u"
alias md="mkdir"
alias rd="cd /"
alias dc="docker-compose"
alias ec="edit -clear"
alias phpv="php -v && echo "" && which php"
alias RIP="sudo shutdown now"
alias restart="sudo reboot"

alias .="cd ."
alias ..="cd .."
alias ...="cd ..."
alias .4="cd ...."
alias .5="cd ....."

#color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_MAGENTA='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
LIGHT_WHITE='\033[1;37m'

BRED='\e[0;41m'
BGREEN='\e[0;42m'
BYELLOW='\e[0;43m'
BBLUE='\e[0;44m'
BMAGENTA='\e[0;45m'
BCYAN='\e[0;46m'
BWHITE='\e[0;47m'

NC='\033[0m' # No Color

VERSION="v0.10.0"

PLUGIN_URL="https://raw.githubusercontent.com/philipstuessel/jap/main/plugins/plugins.json"

JAP_FOLDER="$HOME/jap/"
JAP_config_Json="${JAP_FOLDER}config/config.json"
JAP_runsJSON="${JAP_FOLDER}config/runs.json"
tempf="${JAP_FOLDER}temp/"

source $HOME/jap/plugins/source.sh

jap() {
    if [[ "$1" == "-v" || "$1" == "v" || "$1" == "" ]]; then
         echo ""
         echo -e "${YELLOW}      ██╗ █████╗ ██████╗ ${NC}"
         echo -e "${YELLOW}      ██║██╔══██╗██╔══██╗${NC}"
         echo -e "${YELLOW}      ██║███████║██████╔╝${NC}"
         echo -e "${YELLOW} ██   ██║██╔══██║██╔═══╝ ${NC}"
         echo -e "${YELLOW} ╚█████╔╝██║  ██║██║     ${NC}"
         echo -e "${YELLOW}  ╚════╝ ╚═╝  ╚═╝╚═╝     ${NC}"
         echo ""
         echo -e "JAP 🍜 | ${BOLD}${VERSION}${NC}"
    fi

    if [[ "$1" == "help" ]]; then
        echo "Usage: jap [options]"
        echo "Options:"
        echo " -v                     version"
        echo " help                   list the commamds"
        echo " gi                     create the .gitignore file"
        echo " ha                     create the .htaccess file"
        echo " ip                     "
        echo "  ↳ [url]               give ip from this domain"
        echo "  ↳  my / local         give my ip"
        echo ""   
        echo " update                 update JAP"
        echo " install [plugin]       install the Plugin"
        echo " upgrade                upgrade all Plugins"
        echo "  ↳ [plugin name]       upgrade only this Plugin"
        echo ""   
        echo " edit [file]            edit JAP files 'config' or 'runs'"
        echo " run"   
        echo "  ↳ [key]               run this key"
        echo "  ↳ l                   list all runs"
        echo ""
        echo "------------- commands -------------"
        echo " copy [file]            File contents to clipboard"
        echo " copy"      
        echo "  ↳ pwd / p             Copy this path to the clipboard"
        echo "  ↳ pwd / p [file]      Copy this file path to the clipboard"
        echo "  ↳ ssh                 Copy id_rsa"
        echo "  ↳ ssh -pub            Copy id_rsa.pub"
        echo "  ↳ ssh -id [id]        Copy a special id"
        echo ""   
        echo " paste                  Create the file with copy content"
        echo " paste"     
        echo "   ↳ [file]             Paste the copy content in this file"
        echo ""   
        echo " tpl [folder]           Paste the folder contents"
        echo " tpl"   
        echo "  ↳ l                   List all folder template"
        echo "  ↳ o                   Open the tpl folder"
        echo ""   
        echo " ziper [zip file]       Unzip and pack ZIP or with url-zip"
        echo " edit / e [file]        Edit this file"
        echo " undo                   Undo file contents"
        echo ""
        echo " nrq                    Needs Reboot Query"
        echo " jip                    Get the IP from a domain or local"
        echo " var [option] [value]   Get the value of an option"
        echo ""
        echo "--------- workflow (alias) ---------"
        echo " alias                  commands"
        echo ""   
        echo " ..                     cd .."
        echo " q                      killall Terminal"
        echo " t                      touch"
        echo " o                      open ."
        echo " c                      code ."
        echo " l                      ls -lah"
        echo " s                      source ~/.zshrc"
        echo " e                      edit"
        echo " ec                     clear and edit"
        echo " sb                     source ~/.bashrc"
        echo " py                     python3"
        echo " rd                     cd /"
        echo " md                     mkdir"
        echo " dc                     docker-compose"
        echo " run                    jap run"
        echo " cls                    clear"
        echo " RIP                    sudo shutdown now"
        echo " pyv                    python3 --version"
        echo " pip                    pip3"
        echo " phpv                   php -v"
        echo " home                   cd ~"
        echo " update                 apt / brew update"
        echo " upgrade                apt / brew upgrade"
        echo " install                apt / brew install"
        echo " restart                sudo reboot"
        echo ""
    fi

    if [[ "$1" == "update" ]]; then
           zsh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/update.zsh)" -- ~/jap
           source ~/.zshrc
    fi

    if [[ "$1" == "gi" ]]; then
        if [ ! -f $HOME/jap/.gitignore ]; then
        echo -e "Create in $HOME/jap/${GREEN}".gitignore"${NC}"
        echo ".DS_Store" > $HOME/jap/.gitignore
        echo "**/.DS_Store" >> $HOME/jap/.gitignore
        fi
        cp $HOME/jap/.gitignore $(pwd)/
        echo -e $(pwd)"/"${GREEN}".gitignore"${NC}
    fi

    if [[ "$1" == "ha" ]];then
        if [ -e "$(pwd)/.htaccess" ];then
            if [[ "$2" == "-y" ]];then
                t "$(pwd)/.htaccess"
                echo -e $(pwd)"/"${GREEN}".htaccess"${NC}
            else
                echo -e $RED"There is already a .htaccess in the folder.$NC"
                echo "Then type '-y' at the end of the command to confirm the selection"
            fi
        else
            t "$(pwd)/.htaccess"
            echo -e $(pwd)"/"${GREEN}".htaccess"${NC}
        fi
    fi

    if [[ "$1" == "i" || "$1" == "install" ]]; then
        installPlugin "$2"
    fi

    if [[ "$1" == "ug" || "$1" == "upgrade" ]]; then
        updatePlugin "$2"
    fi

    if [[ "$1" == "colors" ]]; then
        color
    fi

    if [[ "$1" == "r" || "$1" == "remove" || "$1" == "uninstall" ]];then
        jap_plugins "r" "$2"
    fi

    if [[ "$1" == "l" || "$1" == "list" ]];then
        plugins_file="${JAP_FOLDER}config/.jap/plugins.json"
        echo "List of installed JAP plugins"
        echo "-------------------"
        printf -- "-${BLUE} %s${NC}\n" $(jq -r 'keys[]' $plugins_file)
        echo "-------------------"
    fi

    if [[ "$1" == "ip" ]];then
        jip "$2" "$3"
    fi

    if [[ "$1" == "run" ]];then
        runJson="${JAP_FOLDER}config/runs.json"
        if [[ "$2" == "l" || "$2" == "list" ]];then
             echo "Available categories and their commands in '$runJson':"
             echo ""

            for category in $(jq 'keys[]' $runJson); do
                category=$(echo $category | tr -d '"')
                echo "Categories: ${BOLD}$category${NC}"
                    jq -r ".${category}[]" $runJson | while read cmd; do
                    echo "  > $cmd"
                done
                echo ""
            done
        else
            category="$2"
            echo -e "${BOLD}'$category'${NC} is runig: "
            echo ""
            jq -r ".${category}[]" "$runJson" | while IFS= read -r cmd; do
                eval "$cmd"
            done

        fi
    fi

    if [[ "$1" == "e" || "$1" == "edit" ]];then
        file="$2"
        runJson="${JAP_FOLDER}config/runs.json"
        e="$(jq -r '.editor' $JAP_config_Json)"

        if [[ $file == "runs" ]];then
            $e $runJson
        fi

        if [[ $file == "config" ]];then
            $e $JAP_config_Json
        fi
    fi
}

if jq -e 'has("START")' $JAP_runsJSON >/dev/null;then
    jap run START
fi

updateConfig() {
    url="https://raw.githubusercontent.com/philipstuessel/jap/main/config/config.json"
    local_file=$JAP_config_Json 
    temp_file="${tempf}up9383.json"
    if [ ! -d "${JAP_FOLDER}temp/" ];then
        md "${JAP_FOLDER}temp/"
    fi

    merged="${tempf}merged.json"
    curl -s $url -o $temp_file
    if ! test -s $local_file; then
        fetch2 "$HOME/jap/config/" $url
    fi

    jq -s '.[0] * .[1]' $temp_file $local_file > $merged
    echo $(cat $merged) > $local_file
    rm -r $merged
    rm -r $temp_file
    echo "Config Synchronization completed."
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

spm() {
    local os=$(uname)
    if [ "$os" = "Darwin" ];then
        if [[ "$1" == "i" ]];then
            brew install "$2"
        fi
        if [[ "$1" == "u" ]];then
            brew update
        fi
        if [[ "$1" == "ug" ]];then
            brew upgrade
        fi
    elif [ "$os" = "Linux" ];then
        if [[ "$1" == "i" ]];then
            sudo apt install "$2"
        fi
        if [[ "$1" == "u" ]];then
            sudo apt update
        fi
        if [[ "$1" == "ug" ]];then
            sudo apt upgrade
        fi
    fi
}

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
                echo "X11 läuft – Desktop vorhanden"
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
                echo -e "${LIGHT_BLUE}Copy $key.pub"
                copy_to_clipboard "$(cat "$HOME/.ssh/$key.pub")"
            else
                echo -e "${LIGHT_BLUE}Copy $key"
                copy_to_clipboard "$(cat "$HOME/.ssh/$key")"
            fi
        else
            if [[ -e "$HOME/.ssh/id_rsa" ]];then
                if [[ $(var "pub" "$@") != 0 ]];then
                    echo -e "${LIGHT_BLUE}Copy id_rsa.pub"
                    copy_to_clipboard "$(cat "$HOME/.ssh/id_rsa.pub")"
                else
                    echo -e "${LIGHT_BLUE}Copy id_rsa"
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
    name="$(basename "$1")"
    echo "$(pwd)/$name" > "${tempf}undo.txt" 
    cat "$1" >> "${tempf}undo.txt"
}

undo() {
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

upgrade() {
    if jq -e 'has("UPGRADE")' $JAP_runsJSON >/dev/null;then
        jap run UPGRADE
    else
        spm ug
    fi
}

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

color() {
     echo "----------- Colors"
     echo -e ${RED}- RED${NC}
     echo -e ${GREEN}"- GREEN"${NC}
     echo -e ${YELLOW}"- YELLOW"${NC}
     echo -e ${BLUE}"- BLUE"${NC}
     echo -e ${MAGENTA}"- MAGENTA"${NC}
     echo -e ${CYAN}"- CYAN"${NC}
     echo -e ${BOLD}"- BOLD"${NC}
     echo -e ${UNDERLINE}"- UNDERLINE"${NC}
     echo "----------- Light Colors"
     echo -e "${LIGHT_RED}- LIGHT_RED${NC}"
     echo -e "${LIGHT_GREEN}- LIGHT_GREEN${NC}"
     echo -e "${LIGHT_YELLOW}- LIGHT_YELLOW${NC}"
     echo -e "${LIGHT_BLUE}- LIGHT_BLUE${NC}"
     echo -e "${LIGHT_MAGENTA}- LIGHT_MAGENTA${NC}"
     echo -e "${LIGHT_CYAN}- LIGHT_CYAN${NC}"
     echo -e "${LIGHT_WHITE}- LIGHT_WHITE${NC}"
     echo "----------- Backgrounds"
     echo -e ${BRED}"- BRED"${NC}
     echo -e ${BGREEN}"- BGREEN"${NC}
     echo -e ${BYELLOW}"- BYELLOW"${NC}
     echo -e ${BBLUE}"- BBLUE"${NC}
     echo -e ${BMAGENTA}"- BMAGENTA"${NC}
     echo -e ${BCYAN}"- BCYAN"${NC}
     echo -e ${BWHITE}"- WHITE"${NC}
     echo "end with NC"
}

tpl() {
    if [[ "$1" == "o" ]]; then
    open ~/jap/tpl/
    else
    if [[ "$1" == "l" ]]; then
    echo -e ${UNDERLINE}"---- list all templates ----"${NC}
    find $HOME/jap/tpl/* -maxdepth 0 -type d -exec basename {} \; | while read dir; do echo -e "\033[0;36m$dir\033[0m"; done
    else 
        cp -r ~/jap/tpl/$1/* ./
        echo -e "The template ${GREEN}$1${NC} was added"
    fi
    fi
}

installPlugin() {
    KEY="${1}"
    if curl -sSL "$PLUGIN_URL" | grep -q "\"${KEY}\""; then
        installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
        echo -e "${BOLD}JAP 🍜 Plugins${NC}"
        echo -e "${BOLD}The plugin ${YELLOW}\"$KEY\"${NC}${BOLD} will now be installed${NC}"
        echo -e "${BOLD}Install URL: $installURL${NC}"
        zsh -c "$(curl -fsSL $installURL/install.zsh)"
        echo "source $HOME/jap/plugins/packages/$KEY/$KEY.zsh" >> $HOME/jap/plugins/source.sh
        source $HOME/jap/plugins/source.sh
        jap_plugins "add" $KEY "$KEY.zsh"
    else
        echo -e "${RED}The plugin \"$KEY\" was not found${NC}"
    fi
}

updatePlugin() {
    plugins_file="${JAP_FOLDER}config/.jap/plugins.json"
    if curl -sSL "$PLUGIN_URL" >/dev/null 2>&1; then
        if [[ "$1" == "" ]];then
        echo "JAP 🍜 Upgrade Plugins"
        keys=$(jq -r 'keys[]' $plugins_file)
        while IFS= read -r KEY; do
            installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
            zsh -c "$(curl -fsSL $installURL/update.zsh)" -- ~/jap
            echo -e "Upgrade for '${BOLD}${KEY}${NC}' completed successfully."
            echo -e ${BLUE}"#############################"${NC}
        done <<< "$keys"
        echo -e ${GREEN}"done with updates"${NC}
        source $HOME/jap/plugins/source.sh
        else
            KEY="$1"
            if ! jq -e --arg key "$KEY" 'has($key)' $plugins_file >/dev/null; then
                echo -e "${RED}No plugins with the name '${KEY}' found${NC}"
                return 0
            fi
            echo "JAP 🍜 Upgrade '${KEY}'"
            installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
            if [ -z "$installURL" ]; then
                echo -e "${RED}Install error (${installURL})${NC}"
                return 0
            fi
            zsh -c "$(curl -fsSL $installURL/update.zsh)" -- ~/jap
            echo -e "Upgrade for '${BOLD}${KEY}${NC}' completed successfully."
            echo -e ${GREEN}"${BOLD}${KEY}${NC}${GREEN} has been updated"${NC}
            source $HOME/jap/plugins/source.sh
        fi
    else
        echo -e ${RED}"Unable to fetch plugin information from \"$PLUGIN_URL\""${NC}
    fi
}

fetch() {
    mkdir -p "$1"
    curl -o "$2" "$3" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "📥 $3"
        return 1
    else
        echo -e "❌ ${RED}$3${NC}"
        return 0
    fi
}

fetch2() {
    mkdir -p "$1"
    file="$1/$(basename "$2")"
    curl -o "$file" "$2" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "📥 $2"
        return 1
    else
        echo -e "❌ ${RED}$2${NC}"
        return 0
    fi
}

jap_plugins() {
    plugins_file="${JAP_FOLDER}config/.jap/plugins.json"
    if [[ "$1" == "add" ]];then
        jq --arg key "$2" --arg val "$3" '. += { ($key): $val }' $plugins_file > temp && mv temp $plugins_file
    fi
    if [[ "$1" == "r" ]]; then
            pname="$2"
            file=$(jq ".$2" $plugins_file | tr -d '"')
            if [[ ! $file == null ]]; then
                echo -e "${BOLD}Plugin ${BRED}$2${NC}${BOLD} will be removed${NC}"
                file_source="${JAP_FOLDER}plugins/source.sh"
                value_source="${JAP_FOLDER}plugins/packages/${pname}/${file}"
                echo "---------------------------------------------------------"
                grep -v "source $value_source" $file_source > temp && mv temp $file_source
                echo "🗑️  Plugins have been removed from source.sh"
                echo "---------------------------------------------------------"
                rm -r "${JAP_FOLDER}plugins/packages/${pname}/"
                echo "🗑️  $value_source have been removed from 'packages'"
                echo "---------------------------------------------------------"
                jq --arg key "$pname" 'del(.[$key])' "$plugins_file" > temp && mv temp "$plugins_file"
                echo "🗑️  $2 have been removed from plugins.json"
                echo "---------------------------------------------------------"
                echo -e "${BGREEN}the plugin '$2' has been deleted${NC}"
            else
                echo -e "${RED}Is not in plugins.json${NC}"
                echo -e "${RED}Error in: $plugins_file${NC}"
            fi
    fi
}

jip () {
    if [[ "$1" == "-r" ]];then
        if [[ "$2" == "local" ]];then
            echo "$(ifconfig | grep 'inet ' | grep -v 'inet6' | awk '{print $2}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^127\.0\.0\.1$' | grep -v '^$')"
            return 0
        fi

        if [[ "$2" == "ping" ]];then
            url="$3"
            if [[ "$url" =~ ^https?:// ]]; then
                host=$(echo $url | sed -n 's,^\(https*://\)\([^/]*\).*,\2,p' | cut -d':' -f1)
            else
                host=$(echo $url | cut -d':' -f1)
            fi
    
            ip=$(ping -c 1 $host | grep PING | awk '{print $3}')
    
            ip_cleaned=$(echo $ip | tr -d '()')
            ip_cleaned=$(echo $ip_cleaned | tr -d ':')
    
            echo $ip_cleaned
            return 0
        fi
    fi

    if [[ "$1" == "my" || "$1" == "local" ]];then
        if [[ "$2" == "all" ]];then
            ifconfig | grep inet | awk '{print $2}'
        else
            localip="$(ifconfig | grep 'inet ' | grep -v 'inet6' | awk '{print $2}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^127\.0\.0\.1$' | grep -v '^$')"
            if [[ "$2" == "c" || "$2" == "copy" ]];then
                copy_to_clipboard $localip
            fi
            echo -e "${MAGENTA}${BOLD}$localip${NC}"
        fi
    elif [[ ! "$1" == "" ]];then
        url="$1"
        if [[ "$url" =~ ^https?:// ]]; then
            host=$(echo $url | sed -n 's,^\(https*://\)\([^/]*\).*,\2,p' | cut -d':' -f1)
        else
            host=$(echo $url | cut -d':' -f1)
        fi

        ip=$(ping -c 1 $host | grep PING | awk '{print $3}')

        ip_cleaned=$(echo $ip | tr -d '()')
        ip_cleaned=$(echo $ip_cleaned | tr -d ':')

        copy_to_clipboard $ip_cleaned
        echo -e "${BLUE}${BOLD}${ip_cleaned}${NC}"
    fi
}

var() {
  local option="$1"
  local value="$2"
  if [[ -z "$value" ]]; then
    echo 0
    return
  fi
  if [[ " $@ " == *" -$option "* ]]; then
    local option_value=$(echo "$@" | awk -v option="-$option" '{for(i=1;i<=NF;i++) if ($i == option) print $(i+1)}')
    echo "$option_value"
  else
    echo 0 
  fi
}

# Needs Reboot Query
nrq() {
	if [ -f /var/run/reboot-required ]; then
    echo -e "${RED}Reboot required${NC}"
	else
    echo -e "${GREEN}No reboot needed${NC}"
	fi
}