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
echo $(mkdir -p ~/jap && curl -o ~/jap/jap.sh https://raw.githubusercontent.com/philip-stuessel/jap/main/jap.sh)
echo ${MAGENTA}"update: jap.sh"${NC}
echo $(mkdir -p ~/jap/tpl/) ${MAGENTA}"create: tpl folder"${NC}
echo $(source ~/.zshrc)
echo ${GREEN}"Done"${NC}