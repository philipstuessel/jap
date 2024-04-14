#!/bin/zsh
source ~/.zshrc
echo ${CYAN}"Update JAP 🍜"${NC}
echo ${BLUE}">>>>>>>"${NC}
fetch ~/jap ~/jap/jap.zsh https://raw.githubusercontent.com/philipstuessel/jap/main/jap.zsh
echo $(mkdir -p ~/jap/tpl/) ${MAGENTA}"create: tpl folder"${NC}
echo $(mkdir -p ~/jap/plugins/) ${MAGENTA}"create: plugins folder"${NC}
echo $(mkdir -p ~/jap/plugins/packages/) ${MAGENTA}"create: packages folder"${NC}
source="/Users/$USER/jap/plugins/source.sh"
if [ ! -f "$source" ]; then
    touch "$source"
    echo ${MAGENTA}"create: source.sh"${NC}
fi
source ~/.zshrc
echo ${GREEN}"Done"${NC}