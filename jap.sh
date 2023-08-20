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

VERSION="v0.1.1"

jap() {
    if [[ "$1" == "-v" || "$1" == "" ]]; then
         echo "JAP 🍜"
         echo ${VERSION}
    fi
    if [[ "$1" == "help" ]]; then
        echo "Usage: jap [options]"
        echo "Options:"
        echo " help     List the commamds"
        echo " gi       Create the .gitignore file"
        echo " update   Update JAP"
        echo ""
        echo "---- workflow (alias)"
        echo " alias    commands"
        echo ""
        echo " s        source ~/.zshrc"
        echo " q        killall Terminal"
        echo " t        touch"
        echo " apr      apachectl restart"
        echo " aps      apachectl start"
        echo " apstop   apachectl stop"
        echo " o        open ."
        echo " nf       mkdir"
    fi
    if [[ "$1" == "update" ]]; then
           source /Users/$(users)/jap/update.sh
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
}