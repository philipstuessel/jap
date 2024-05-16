#!/bin/zsh
source ~/.zshrc
echo ${CYAN}"Update JAP 🍜"${NC}
echo ${BLUE}">>>>>>>"${NC}
JAP_FOLDER="$HOME/jap/"

fetch ${JAP_FOLDER} ${JAP_FOLDER}/jap.zsh https://raw.githubusercontent.com/philipstuessel/jap/main/jap.zsh
echo $(mkdir -p ${JAP_FOLDER}config/.jap) ${MAGENTA}"create: .jap folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}tpl/) ${MAGENTA}"create: tpl folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}plugins/packages/) ${MAGENTA}"create: packages folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}/config/) ${MAGENTA}"create: config folder"${NC}
touch "$HOME/jap/config/config.json"

jap_runs="https://raw.githubusercontent.com/philipstuessel/jap/main/config/runs.json"
if ! test -s $jap_runs; then
    fetch2 "$HOME/jap/config/" $jap_runs
fi
updateConfig

source="${JAP_FOLDER}plugins/source.sh"
if [ ! -f "$source" ]; then
    touch "$source"
    echo ${MAGENTA}"create: source.sh"${NC}
fi

source ~/.zshrc
echo ${GREEN}"Done"${NC}