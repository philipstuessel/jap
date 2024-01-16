#!/bin/jap

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

VERSION="v0.4.3"

jap() {
    if [[ "$1" == "-v" || "$1" == "v" || "$1" == "" ]]; then
         echo "JAP 🍜"
         echo ${VERSION}
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
        echo " copy [file]         Copy files to clipboard"
        echo " tpl [folder]        Paste the folder contents"
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
           sh -c "$(curl -fsSL https://raw.githubusercontent.com/philipstuessel/jap/main/update.sh)" -- ~/jap
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
    pbcopy < "$1";
    echo $1' was copied into the clipboard 📋'
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
         FILE="/Users/$USER/jap/plugins/plugins.json"
         if [ -f "$FILE" ]; then
             if grep -q "\"${KEY}\"" "$FILE"; then
                 installURL=$(cat "$FILE" | grep "\"${1}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
                 echo ${BOLD}"JAP 🍜 Plugins"${NC}
                 echo ${BOLD}"the ${YELLOW}\"$KEY\"${NC}${BOLD} will now be installed"${NC}
                 echo ${BOLD}"install server: $installURL"${NC}
                 sh -c "$(curl -fsSL $installURL/install.sh)"
                 echo "source /Users/$USER/jap/plugins/packages/$KEY.sh" >> /Users/$USER/jap/plugins/source.sh
                 source /Users/$USER/jap/plugins/source.sh
             else
                 echo ${RED}"the plugin \"$KEY\" was not found"${NC}

             fi
         else
             echo ${RED}"The script \"$FILE\" does not exist"${NC}
         fi
}

updatePlugin() {
FILE="/Users/$USER/jap/plugins/plugins.json"
echo "JAP 🍜 Plugins Update"
if [ -f "$FILE" ]; then
    for KEY in $(cat "$FILE" | sed -n 's/.*"\([^"]*\)".*/\1/p'); do
        installURL=$(cat "$FILE" | grep "\"${KEY}\"" | awk -F ': *' '{print $2}' | tr -d '," ')
        mkdir -p ~/jap/plugins/packages/
        sh -c "$(curl -fsSL $installURL/update.sh)" -- ~/jap
        echo "Installation for \"$KEY\" completed successfully."
        echo ${BLUE}"#############################"${NC}
    done
    echo ${GREEN}"done with updates"${NC}
    source /Users/$USER/jap/plugins/source.sh

else
    echo ${RED}"The script \"$FILE\" does not exist"${NC}
fi
}

source /Users/$USER/jap/plugins/source.sh
