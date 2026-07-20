jap_space_encode() {
    local path="$1"
    echo "${path//\//-}"
}

jap_project_root() {
    local dir="${1:-$(pwd)}"

    while [[ "$dir" != "/" && -n "$dir" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    echo "${1:-$(pwd)}"
}

jap_space_root_for() {
    local project="$1"
    echo "${JAP_SPACES}$(jap_space_encode "$project")"
}

jap_space_dir() {
    local project space

    project="$(jap_project_root)"
    space="$(jap_space_root_for "$project")"

    if [[ ! -d "$space" ]]; then
        mkdir -p "$space"
    fi

    if [[ ! -f "$space/space.json" ]]; then
        jq -n \
            --arg project "$project" \
            --arg name "$(basename "$project")" \
            --arg created "$(date +%Y-%m-%dT%H:%M:%S)" \
            '{project: $project, name: $name, created: $created}' \
            > "$space/space.json"
    fi

    echo "$space"
}

jap_space_runs() {
    echo "$(jap_space_dir)/runs.json"
}

jap_space() {
    local sub="${1:-}"
    local space project

    case "$sub" in
        path)
            jap_space_dir
            ;;
        ls|list)
            if [[ ! -d "$JAP_SPACES" ]]; then
                echo -e "${YELLOW}No workspaces yet${NC}"
                return 0
            fi
            local d proj
            for d in "$JAP_SPACES"*(N/); do
                if [[ -f "$d/space.json" ]]; then
                    proj="$(jq -r '.project' "$d/space.json")"
                else
                    proj="?"
                fi
                echo -e "${BLUE}$(basename "$d")${NC}  ${proj}"
            done
            ;;
        cd)
            space="$(jap_space_dir)"
            JAP_SPACE_RETURN="$PWD"
            cd "$space" || return 1
            ;;
        exit|back)
            if [[ -z "$JAP_SPACE_RETURN" ]]; then
                echo -e "${YELLOW}No previous location${NC}"
                return 1
            fi
            if [[ ! -d "$JAP_SPACE_RETURN" ]]; then
                echo -e "${RED}Previous location no longer exists:${NC} $JAP_SPACE_RETURN"
                unset JAP_SPACE_RETURN
                return 1
            fi
            cd "$JAP_SPACE_RETURN" || return 1
            unset JAP_SPACE_RETURN
            ;;
        open|o)
            space="$(jap_space_dir)"
            if command -v open >/dev/null 2>&1; then
                open "$space"
            else
                edit "$space"
            fi
            ;;
        rm)
            project="$(jap_project_root)"
            space="$(jap_space_root_for "$project")"
            if [[ ! -d "$space" ]]; then
                echo -e "${RED}No workspace for${NC} $project"
                return 1
            fi
            echo -n "Delete workspace '$space'? (y/n): "
            read option
            if [[ "$option" == "y" ]]; then
                rm -r "$space"
                echo -e "${BGREEN}workspace deleted${NC} 🗑️"
            fi
            ;;
        ""|.)
            space="$(jap_space_dir)"
            echo -e "${BOLD}Workspace:${NC} ${GREEN}${space}${NC}"
            if [[ -f "$space/space.json" ]]; then
                echo -e "  project: $(jq -r '.project' "$space/space.json")"
                echo -e "  created: $(jq -r '.created' "$space/space.json")"
            fi
            ;;
        *)
            echo -e "${RED}Error:${NC} unknown space command '$sub'"
            return 1
            ;;
    esac
}
