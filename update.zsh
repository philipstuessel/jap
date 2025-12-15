#!/bin/zsh
source ~/.zshrc
echo ${CYAN}"Update JAP 🍜"${NC}
echo ${BLUE}">>>>>>>"${NC}
JAP_FOLDER="$HOME/jap/"

fetch2 ${JAP_FOLDER} https://raw.githubusercontent.com/philipstuessel/jap/main/jap.zsh
echo $(mkdir -p ${JAP_FOLDER}config/.jap) ${MAGENTA}"create: .jap folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}tpl/) ${MAGENTA}"create: tpl folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}plugins/packages/) ${MAGENTA}"create: packages folder"${NC}
echo $(mkdir -p ${JAP_FOLDER}config/) ${MAGENTA}"create: config folder"${NC}
touch "$HOME/jap/config/config.json"
touch "$HOME/jap/config/runs.json"

jap_runs="https://raw.githubusercontent.com/philipstuessel/jap/main/config/runs.json"
jap_conig="https://raw.githubusercontent.com/philipstuessel/jap/main/config/config.json"

if ! test -s "$HOME/jap/config/config.json"; then
    fetch2 "$HOME/jap/config/" $jap_conig
fi

if ! test -s "$HOME/jap/config/runs.json"; then
    fetch2 "$HOME/jap/config/" $jap_runs
fi

updateConfig

source ~/.zshrc
echo ${GREEN}"Done"${NC}