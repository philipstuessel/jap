installPlugin() {
    KEY="${1}"
    if [[  -e "${JAP_FOLDER}plugins/packages/$KEY" ]]; then
        echo "Plugin already installed"
        return 0
    fi
    if searchPlugin "$KEY";then
        installURL=$FOUND_URL
        echo "found in the library: $FOUND_LIBURL"
        echo -e "${BOLD}The plugin ${YELLOW}\"$KEY\"${NC}${BOLD} will now be installed${NC}"
        echo -e "${BOLD}Install URL: $installURL${NC}"
        zsh -c "$(curl -fsSL $installURL/install.zsh)"
        if [[ $? -eq 0 ]]; then
            sourceInclude "${JAP_FOLDER}plugins/packages"
            return 0
        else
            echo -e "${RED}Installation failed${NC}"
            return 1
        fi
    else
        echo -e "${RED}The plugin \"$KEY\" was not found${NC}"
        return 0
    fi
}

searchPlugin() {
    KEY="$1"
    FOUND_URL=""
    FOUND_LIBURL=""

    if [[ ! -f "$libraries" ]]; then
        echo "Creating libraries file..."
        mkdir -p "$(dirname "$libraries")"
        touch "$libraries"
        echo "https://japzsh.com/library.json" > "$libraries"
    fi

    for liburl in $(cat "$libraries"); do
        url=$(curl -fs "$liburl" </dev/null | \
              grep -o "\"$KEY\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | \
              sed 's/.*: "\(.*\)"/\1/')
        if [[ -n "$url" ]]; then
            FOUND_URL="$url"
            FOUND_LIBURL="$liburl"
            return 0
        fi
    done
    return 1
}

updatePlugin() {
    base="$HOME/jap/plugins/packages"
    if [[ "$1" == "" ]];then
        echo "Upgrade list:"
        for d in "$base"/*; do
            name=$(basename "$d")
            if [[ -f "$d/$name.zsh" ]]; then
                echo -e "${BLUE}$name${NC}"
            fi
        done
        notfoundInlibraries=""
        echo ""
        echo "######## Upgrade all plugins ########"
        echo ""
        for d in "$base"/*; do
            name=$(basename "$d")
                if searchPlugin "$name"; then
                    echo "[$FOUND_LIBURL] $FOUND_URL"
                    zsh -c "$(curl -fsSL $FOUND_URL/update.zsh)" -- ~/jap
                    if [ $? -eq 0 ]; then
                        echo -e "Upgrade for '$name' completed ${LIGHT_GREEN}successfully.${NC}"
                        echo -e ${BLUE}"##########################################################"${NC}
                    else
                        echo -e "${RED}Upgrade for '$name' failed.${NC}"
                    fi
                else
                    notfoundInlibraries="${notfoundInlibraries}${YELLOW}Plugin '$name' not found in libraries${NC}\n"
                fi
        done
        echo -e "$notfoundInlibraries"
        echo -e ${GREEN}"done with updates"${NC}
        sourceInclude "${JAP_FOLDER}plugins/packages"
        return 0
    else
        KEY="$1"
        if searchPlugin "$KEY"; then
            echo "[$FOUND_LIBURL] $FOUND_URL"
            zsh -c "$(curl -fsSL $FOUND_URL/update.zsh)" -- ~/jap
            if [ $? -eq 0 ]; then
                echo -e "Upgrade for '$KEY' completed ${LIGHT_GREEN}successfully.${NC}"
            else
                echo -e "${RED}Upgrade for '$KEY' failed.${NC}"
            fi
        else
            echo -e "${RED}The plugin \"$KEY\" was not found${NC}"
            return 0
        fi
    fi
}

jap_plugins() {
    if [[ "$1" == "r" ]]; then
        pname="$2"
        if [[ -d "${JAP_FOLDER}plugins/packages/${pname}" ]]; then
            rm -r "${JAP_FOLDER}plugins/packages/${pname}"
            sourceInclude "${JAP_FOLDER}plugins/packages"
            echo -e "${BGREEN}the plugin '$2' has been deleted${NC} 🗑️"
        else
            echo -e "${RED}Plugin not found${NC}"
        fi
    fi
}
