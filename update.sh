#!/bin/zsh
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

echo ${CYAN}"Update JAP 🍜"${NC}
echo ${BLUE}">>>>>>>"${NC}
echo $(mkdir -p ~/jap && curl -o ~/jap/jap.sh https://raw.githubusercontent.com/philipstuessel/jap/main/jap.sh)
echo ${MAGENTA}"update: jap.sh"${NC}
echo $(mkdir -p ~/jap/tpl/) ${MAGENTA}"create: tpl folder"${NC}
echo $(mkdir -p ~/jap/plugins/) ${MAGENTA}"create: plugins folder"${NC}
echo $(mkdir -p ~/jap/plugins/packages/) ${MAGENTA}"create: packages folder"${NC}
source="/Users/$USER/jap/plugins/source.sh"
if [ ! -f "$source" ]; then
    touch "$source"
    echo ${MAGENTA}"create: source.sh"${NC}
fi
echo $(mkdir -p ~/jap/plugins && curl -o ~/jap/plugins/plugins.json https://raw.githubusercontent.com/philipstuessel/jap/main/plugins/plugins.json)
echo ${MAGENTA}"install: plugins.json"${NC}
echo $(source ~/.zshrc)
echo ${GREEN}"Done"${NC}