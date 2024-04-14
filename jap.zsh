#!/bin/zsh

# alias
alias s="source ~/.zshrc"
alias q="killall Terminal"
alias t="touch"
alias apr="apachectl restart"
alias apstop="apachectl stop"
alias aps="apachectl start"
alias o="open ."
alias nf="mkdir"
alias cls="clear"
alias home="cd ~"
alias c="code ."
alias py="python3"
alias python="python3"
alias pip="pip3"
alias pwdc="copy pwd"

# cd 
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

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
NC='\033[0m' # No Color

VERSION="v0.5.0"

PLUGIN_URL="https://raw.githubusercontent.com/philipstuessel/jap/main/plugins/plugins.json"

jap() {
    if [[ "$1" == "-v" || "$1" == "v" || "$1" == "" ]]; then
         echo "JAP 🍜"
         echo ${BOLD}${VERSION}${NC}
    fi

    if [[ "$1" == "help" ]]; then
        echo "Usage: jap [options]"
        echo "Options:"
        echo " -v                  Version"
        echo " help                List the commamds"
        echo " gi                  Create the .gitignore file"
        echo " update              Update JAP"
        echo " install [plugin]    install the Plugin"
        echo " plugin update       update all Plugins"
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
        echo " ..4                 cd ../../../../"
        echo ""
    fi

    if [[ "$1" == "update" ]]; then
           zsh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/update.zsh)" -- ~/jap
    fi

    if [[ "$1" == "gi" ]]; then
        if [ ! -f /Users/$USER/jap/.gitignore ]; then
        echo "Create in /Users/$USER/jap/${GREEN}".gitignore"${NC}"
        echo ".DS_Store" > /Users/$USER/jap/.gitignore
        echo "**/.DS_Store" >> /Users/$USER/jap/.gitignore
        fi
        cp /Users/$USER/jap/.gitignore $(pwd)/
        echo $(pwd)"/"${GREEN}".gitignore"${NC}
    fi

    if [[ "$1" == "i" || "$1" == "install" ]]; then
        installPlugin "$2"
    fi

    if [[ "$1" == "pu" || "$1" == "plugins update" ]]; then
        updatePlugin;
    fi
}

copy() {
    if [[ "$1" == "pwd" || "$1" == "p" ]]; then
        if [[ ! "$2" == "" ]]; then
            echo "$(pwd)/$2" | pbcopy
            echo ${BLUE}$(pwd)/"$2"${NC}; 
        else
            pwd | pbcopy && echo ${BLUE}$(pwd)${NC};  
        fi
    else
        pbcopy < "$1" && 
        echo $1' was copied into the clipboard 📋'
    fi 
}

tpl() {
    if [[ "$1" == "o" ]]; then
    open ~/jap/tpl/
    else
    if [[ "$1" == "l" ]]; then
    echo ${UNDERLINE}"---- list all templates ----"${NC}
    find /Users/$USER/jap/tpl/* -maxdepth 0 -type d -exec basename {} \; | while read dir; do echo -e "\033[0;36m$dir\033[0m"; done
    else 
        cp -r ~/jap/tpl/$1/* ./
        echo "The template ${GREEN}$1${NC} was added"
    fi
    fi
}

installPlugin() {
    KEY="${1}"
    if curl -sSL "$PLUGIN_URL" | grep -q "\"${KEY}\""; then
        installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
        echo "${BOLD}JAP 🍜 Plugins${NC}"
        echo "${BOLD}The plugin ${YELLOW}\"$KEY\"${NC}${BOLD} will now be installed${NC}"
        echo "${BOLD}Install URL: $installURL${NC}"
        zsh -c "$(curl -fsSL $installURL/install.zsh)"
        echo "source /Users/$USER/jap/plugins/packages/$KEY.sh" >> /Users/$USER/jap/plugins/source.sh
        source /Users/$USER/jap/plugins/source.sh
    else
        echo "${RED}The plugin \"$KEY\" was not found${NC}"
    fi
}

updatePlugin() {
    echo "JAP 🍜 Plugins Update"
    if curl -sSL "$PLUGIN_URL" >/dev/null 2>&1; then
        for KEY in $(curl -sSL "$PLUGIN_URL" | sed -n 's/.*"\([^"]*\)".*/\1/p'); do
            installURL=$(curl -sSL "$PLUGIN_URL" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
            mkdir -p ~/jap/plugins/packages/
            zsh -c "$(curl -fsSL $installURL/update.zsh)" -- ~/jap
            echo "Installation for \"$KEY\" completed successfully."
            echo ${BLUE}"#############################"${NC}
        done
        echo ${GREEN}"done with updates"${NC}
        source /Users/$USER/jap/plugins/source.sh
    else
        echo ${RED}"Unable to fetch plugin information from \"$PLUGIN_URL\""${NC}
    fi
}

fetch() {
    mkdir -p "$1"
    curl -o "$2" "$3" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "📥 $3"
        return 0
    else
        echo "❌ ${RED}$3${NC}"
        return 1
    fi
}

source /Users/$USER/jap/plugins/source.sh
