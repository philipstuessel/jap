#!/bin/zsh
source ~/.zshrc
echo ${CYAN}"Update JAP 🍜"${NC}
echo ${BLUE}">>>>>>>"${NC}
JAP_FOLDER="$HOME/jap/"

jap_install_url='https://raw.githubusercontent.com/philipstuessel/jap/main/'

echo "==> Updating JAP 🍜"
echo -e "${MAGENTA}==> Fetching latest version${NC}"
fetch2 ${JAP_FOLDER} ${jap_install_url}jap.zsh
if [[ ! -e "${JAP_FOLDER}tpl/" ]];then 
    echo $(mkdir -p ${JAP_FOLDER}tpl/) ${MAGENTA}"create: tpl folder"${NC}
fi

if [[ ! -e "${JAP_FOLDER}plugins/packages/" ]];then 
    echo $(mkdir -p ${JAP_FOLDER}plugins/packages/) ${MAGENTA}"create: packages folder"${NC}
fi

if [[ ! -e "${JAP_FOLDER}config/" ]];then 
    echo $(mkdir -p ${JAP_FOLDER}config/) ${MAGENTA}"create: config folder"${NC}
fi

echo -e "${MAGENTA}==> Updating configuration files${NC}"

touch "$HOME/jap/config/config.json"
touch "$HOME/jap/config/runs.json"

jap_runs="${jap_install_url}config/runs.json"
jap_conig="${jap_install_url}config/config.json"

if ! test -s "$HOME/jap/config/config.json"; then
    fetch2 "$HOME/jap/config/" $jap_conig
fi

if ! test -s "$HOME/jap/config/runs.json"; then
    fetch2 "$HOME/jap/config/" $jap_runs
fi

echo -e "${MAGENTA}==> Updating libraries${NC}"
fetch2 ${JAP_FOLDER}lib/docs/ ${jap_install_url}lib/docs/help
fetch2 ${JAP_FOLDER}lib/docs/ ${jap_install_url}lib/docs/colors

updateConfig

echo -e "${MAGENTA}==> Updating ~/.zshrc${NC}"
source ~/.zshrc
echo -e "${GREEN}✔ JAP is up to date${NC}"