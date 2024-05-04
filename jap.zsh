#!/bin/zsh

# alias
alias s="source ~/.zshrc"
alias q="killall Terminal"
alias l="ls -lah"
alias o="open ."
alias cls="clear"
alias home="cd ~"
alias c="code ."
alias py="python3"
alias python="python3"
alias pip="pip3"
alias pwdc="copy pwd"
alias install="sudo apt install"
alias update="sudo apt update"
alias md="mkdir"

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

BRED='\e[0;41m'
BGREEN='\e[0;42m'
BYELLOW='\e[0;43m'
BBLUE='\e[0;44m'
BMAGENTA='\e[0;45m'
BCYAN='\e[0;46m'
BWHITE='\e[0;47m'

NC='\033[0m' # No Color

VERSION="v0.6.3"

PLUGIN_URL="https://raw.githubusercontent.com/philipstuessel/jap/main/plugins/plugins.json"

JAP_FOLDER="$HOME/jap/"

source $HOME/jap/plugins/source.sh

jap() {
    if [[ "$1" == "-v" || "$1" == "v" || "$1" == "" ]]; then
         echo "JAP 🍜"
         echo -e ${BOLD}${VERSION}${NC}
    fi

    if [[ "$1" == "help" ]]; then
        echo "Usage: jap [options]"
        echo "Options:"
        echo " -v                  version"
        echo " help                list the commamds"
        echo " gi                  create the .gitignore file"
        echo " update              update JAP"
        echo " install [plugin]    install the Plugin"
        echo " upgrade             upgrade all Plugins"
        echo "  ↳ [plugin name]    upgrade only this Plugin"
        echo ""
        echo "------------- commands -------------"
        echo " copy [file]         File contents to clipboard"
        echo " copy"
        echo "  ↳ pwd / p          Copy this path to the clipboard"
        echo "  ↳ pwd / p [file]   Copy this file path to the clipboard"
        echo ""
        echo " tpl [folder]        Paste the folder contents"
        echo " tpl"
        echo "  ↳ tpl l            List all folder template"
        echo "  ↳ tpl o            Open the tpl folder"
        echo ""
        echo " ziper [zip file]    unzip and pack ZIP or with url-zip"
        echo ""
        echo "--------- workflow (alias) ---------"
        echo " alias               commands"
        echo ""
        echo " s                   source ~/.zshrc"
        echo " q                   killall Terminal"
        echo " t                   touch"
        echo " apr                 apachectl restart"
        echo " aps                 apachectl start"
        echo " apstop              apachectl stop"
        echo " o                   open ."
        echo " nf                  mkdir"
        echo " cls                 clear"
        echo " py                  python3"
        echo " pip                 pip3"
        echo " c                   code ."
        echo " home                cd ~"
        echo ""
    fi

    if [[ "$1" == "update" ]]; then
           zsh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/update.zsh)" -- ~/jap
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

    if [[ "$1" == "i" || "$1" == "install" ]]; then
        installPlugin "$2"
    fi

    if [[ "$1" == "ug" || "$1" == "upgrade" ]]; then
        updatePlugin "$2"
    fi

    if [[ "$1" == "colors" ]]; then
        color
    fi

    if [[ "$1" == "r" || "$1" == "remove" ]];then
        jap_plugins "r" "$2"
    fi

    if [[ "$1" == "l" || "$1" == "list" ]];then
    plugins_file="${JAP_FOLDER}config/.jap/plugins.json"
    echo "List of installed JAP plugins"
    echo "-------------------"
    printf -- "-${BLUE} %s${NC}\n" $(jq -r 'keys[]' $plugins_file)
    echo "-------------------"
    fi
}

copy() {
    if [[ "$1" == "pwd" || "$1" == "p" ]]; then
        if [[ ! "$2" == "" ]]; then
            echo "$(pwd)/$2" | pbcopy
            echo -e ${BLUE}$(pwd)/"$2"${NC}; 
        else
            pwd | pbcopy && echo ${BLUE}$(pwd)${NC};  
        fi
    else
        pbcopy < "$1" && 
        echo $1' was copied into the clipboard 📋'
    fi 
}

t() {
    folder="$(dirname "$1")"
    mkdir -p "$(pwd)/$folder"
    touch "$1"
}

ziper() {
    select="$1"
    folder="$2"
    name="$(basename "$1")"
    filename="${name%.*}"
    if [[ $folder == "" ]];then
        folder="$(pwd)"
    fi

    if file -b "$select" | grep -q 'Zip archive'; then
          if [[ ! $folder == "" ]];then
            unzip $select -d $folder
            return 0;
          fi
          unzip $select
          return 0
    fi

    if [ -d $select ]; then
        zip -r $select $folder
    else
    if [[ ! -d $folder ]];then
        mkdir $folder
    fi
        zip $filename".zip" $select $folder
    fi
}

color() {
     echo "----------- Colors"
     echo -e "${RED}- RED${NC}"
     echo -e ${GREEN}"- GREEN"${NC}
     echo -e ${YELLOW}"- YELLOW"${NC}
     echo -e ${BLUE}"- BLUE"${NC}
     echo -e ${MAGENTA}"- MAGENTA"${NC}
     echo -e ${CYAN}"- CYAN"${NC}
     echo -e ${BOLD}"- BOLD"${NC}
     echo -e ${UNDERLINE}"- UNDERLINE"${NC}
     echo "----------- Backgrounds"
     echo -e ${BRED}"- BRED"${NC}
     echo -e ${BGREEN}"- BGREEN"${NC}
     echo -e ${BYELLOW}"- BYELLOW"${NC}
     echo -e ${BBLUE}"- BBLUE"${NC}
     echo -e ${BMAGENTA}"- BMAGENTA"${NC}
     echo -e ${BCYAN}"- BCYAN"${NC}
     echo -e ${BWHITE}"- BCYAN"${NC}
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
        while IFS= read -r key; do
            installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${key}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
            zsh -c "$(curl -fsSL $installURL/update.zsh)" -- ~/jap
            echo -e "Upgrade for '${BOLD}${key}${NC}' completed successfully."
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