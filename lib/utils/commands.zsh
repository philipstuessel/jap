jap_show_version() {
    echo ""
    echo -e "${YELLOW}      ██╗ █████╗ ██████╗ ${NC}"
    echo -e "${YELLOW}      ██║██╔══██╗██╔══██╗${NC}"
    echo -e "${YELLOW}      ██║███████║██████╔╝${NC}"
    echo -e "${YELLOW} ██   ██║██╔══██║██╔═══╝ ${NC}"
    echo -e "${YELLOW} ╚█████╔╝██║  ██║██║     ${NC}"
    echo -e "${YELLOW}  ╚════╝ ╚═╝  ╚═╝╚═╝     ${NC}"
    echo ""
    echo -e "JAP 🍜 | ${BOLD}${VERSION}${NC}"
}

jap_show_help() {
    zsh "${lib}docs/help"
}

jap_self_update() {
    zsh -c "$(curl -fsSL "${github_url}/main/update.zsh")" -- ~/jap
    source ~/.zshrc
}

jap_create_gitignore() {
    local gitignore_path="${HOME}/jap/.gitignore"

    if [[ ! -f "$gitignore_path" ]]; then
        echo -e "Create in ${HOME}/jap/${GREEN}.gitignore${NC}"
        {
            echo ".DS_Store"
            echo "**/.DS_Store"
        } > "$gitignore_path"
    fi

    cp "$gitignore_path" "$(pwd)/"
    echo -e "$(pwd)/${GREEN}/.gitignore${NC}"
}

jap_create_htaccess() {
    local target_file="$(pwd)/.htaccess"

    if [[ -e "$target_file" && "$1" != "-y" ]]; then
        echo -e "${RED}There is already a .htaccess in the folder.${NC}"
        echo "Then type '-y' at the end of the command to confirm the selection"
        return 1
    fi

    t "$target_file"
    echo -e "$(pwd)/${GREEN}/.htaccess${NC}"
}

jap_run_command() {
    local run_json="$JAP_runsJSON"
    local list=0
    local category=""
    local add=""

    if [[ "$1" == "local" ]]; then
        local local_runs_json="$(pwd)/runs.json"

        if [[ -f "$local_runs_json" ]]; then
            run_json="$local_runs_json"
        else
            echo -e "${RED}Local runs.json not found.${NC}"
            return 1
        fi

        shift

        if [[ "$1" == "l" || "$1" == "list" ]]; then
            list=1
        fi
    fi

    if [[ "$1" == "l" || "$1" == "list" || $list -eq 1 ]]; then
        echo "Available categories and their commands in '$run_json':"
        echo ""

        jq -r 'keys[]' "$run_json" | while IFS= read -r current_category; do
            echo -e "${BLUE}Categories:${NC} ${LIGHT_GREEN}${current_category}${NC}"
            jq -r --arg category "$current_category" '.[$category][]' "$run_json" | while IFS= read -r cmd; do
                echo -e "${BOLD}> $cmd${NC}"
            done
            echo ""
        done
        return 0
    fi

    category="$1"
    if (( $# > 0 )); then
        shift
    fi

    if [[ -z "$category" ]]; then
        echo -e "${RED}Error:${NC} missing run category"
        return 1
    fi

    if ! jq -e --arg category "$category" '. | has($category)' "$run_json" > /dev/null; then
        echo -e "${RED}Error:${NC} category '${category}' not found in ${run_json}"
        return 1
    fi

    if (( $# > 0 )); then
        add=" ${(q)@}"
    fi

    echo -e ">${LIGHT_GREEN} ${category}${NC} is running:"

    jq -r --arg category "$category" '.[$category][]' "$run_json" | while IFS= read -r cmd; do
        echo "> $cmd"
        echo ""
        eval "$cmd$add"
    done
}

jap_edit_config() {
    local file="$1"
    local editor
    local -a editor_cmd

    editor="$(jq -r '.editor' "$JAP_config_Json")"
    editor_cmd=(${=editor})

    if [[ "$file" == "runs" ]]; then
        "${editor_cmd[@]}" "$JAP_runsJSON"
        return 0
    fi

    if [[ "$file" == "config" ]]; then
        "${editor_cmd[@]}" "$JAP_config_Json"
        return 0
    fi

    echo -e "${RED}Error:${NC} only 'runs' or 'config' can be edited here"
    return 1
}

updateConfig() {
    local url="${github_url}/main/config/config.json"
    local local_file="$JAP_config_Json"
    local temp_dir="${tempf}"
    local temp_file="${temp_dir}up9383.json"
    local merged="${temp_dir}merged.json"

    mkdir -p "${JAP_FOLDER}temp/"

    curl -s "$url" -o "$temp_file"

    if ! test -s "$local_file"; then
        fetch2 "$HOME/jap/config/" "$url"
    fi

    jq -s '.[0] * .[1]' "$temp_file" "$local_file" > "$merged"
    mv "$merged" "$local_file"
    rm -f "$temp_file"
    echo "Config Synchronization completed."
}

spm() {
    local os
    os="$(uname)"

    if [[ "$os" == "Darwin" ]]; then
        if [[ "$1" == "i" ]]; then
            brew install "$2"
        fi

        if [[ "$1" == "u" ]]; then
            brew update
        fi

        if [[ "$1" == "ug" ]]; then
            brew upgrade
        fi
    elif [[ "$os" == "Linux" ]]; then
        if [[ "$1" == "i" ]]; then
            sudo apt install "$2"
        fi

        if [[ "$1" == "u" ]]; then
            sudo apt update
        fi

        if [[ "$1" == "ug" ]]; then
            sudo apt upgrade
        fi
    fi
}

upgrade() {
    if jq -e 'has("UPGRADE")' "$JAP_runsJSON" >/dev/null; then
        jap run UPGRADE
    else
        spm ug
    fi
}

color() {
    source "${lib}docs/colors"
    docsColors
}

tpl() {
    if [[ "$1" == "o" ]]; then
        open ~/jap/tpl/
        return 0
    fi

    if [[ "$1" == "l" ]]; then
        echo -e "${UNDERLINE}---- list all templates ----${NC}"
        find "$HOME/jap/tpl/" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | while IFS= read -r dir; do
            echo -e "\033[0;36m${dir}\033[0m"
        done
        return 0
    fi

    cp -r "$HOME/jap/tpl/$1/"* ./
    echo -e "The template ${GREEN}$1${NC} was added"
}

var() {
    local option="$1"

    if (( $# > 0 )); then
        shift
    fi

    if [[ -z "$option" || $# -eq 0 ]]; then
        echo 0
        return 0
    fi

    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "-${option}" ]]; then
            shift

            if [[ $# -gt 0 ]]; then
                echo "$1"
            else
                echo 0
            fi
            return 0
        fi

        shift
    done

    echo 0
}

nrq() {
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "${RED}Reboot required${NC}"
    else
        echo -e "${GREEN}No reboot needed${NC}"
    fi
}
