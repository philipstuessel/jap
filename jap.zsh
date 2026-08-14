#!/bin/zsh

VERSION="v1.0.1"

github_url="https://raw.githubusercontent.com/philipstuessel/jap"

JAP_FOLDER="$HOME/jap/"
JAP_config_Json="${JAP_FOLDER}config/config.json"
JAP_runsJSON="${JAP_FOLDER}config/runs.json"
tempf="${JAP_FOLDER}temp/"
JAP_SPACES="${JAP_FOLDER}spaces/"
lib="${JAP_FOLDER}lib/"
libraries="${JAP_FOLDER}plugins/libraries"
_ZINIT_DECLINED=false

sourceInclude() {
    local base="$1"
    local type="$2"
    [ -d "$base" ] || return 0

    if [[ "$type" == "files" ]]; then
        while IFS= read -r file; do
            [ -f "$file" ] && source "$file"
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type f -name "*.zsh")
    else
        local name file d
        while IFS= read -r d; do
            name=$(basename "$d")
            file="$d/$name.zsh"
            [ -f "$file" ] && source "$file"
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)
    fi
}

sourceIncludeLazy() {
    source "${lib}zinit/zinit.git/zinit.zsh"
    local base="$1"
    local type="$2"
    [ -d "$base" ] || return 0

    if [[ "$type" == "files" ]]; then
        local file
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                zinit ice wait"0" lucid silent
                zinit snippet "$file"
            fi
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type f -name "*.zsh")
    else
        local name file d
        while IFS= read -r d; do
            name=$(basename "$d")
            file="$d/$name.zsh"
            if [ -f "$file" ]; then
                zinit ice wait"0" lucid silent
                zinit snippet "$file"
            fi
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)
    fi
}

IncludeController() {
    local zinit
    zinit="$(jq -r '.zinit' "$JAP_config_Json")"

    if [[ "$zinit" == "true" ]]; then
        local zinit_home="${HOME}/jap/lib/zinit"

        if [[ ! -d "$zinit_home" ]]; then
            echo "Installing zinit..."
            ZINIT_HOME="$zinit_home" NO_INPUT=1 bash -c "$(curl -fsSL https://git.io/zinit-install)"
        fi

        sourceIncludeLazy "$1" "$2"
    else
        sourceInclude "$1" "$2"
    fi
}

source "${JAP_FOLDER}lib/core/init.zsh"
IncludeController "${JAP_FOLDER}plugins/packages"

jap() {
    local command="${1:-}"

    if (( $# > 0 )); then
        shift
    fi

    case "$command" in
        ""|-v|v)
            jap_show_version
            ;;
        help)
            jap_show_help
            ;;
        update)
            jap_self_update
            ;;
        gi)
            jap_create_gitignore "$@"
            ;;
        ha)
            jap_create_htaccess "$@"
            ;;
        i|install)
            installPlugin "$1"
            ;;
        ug|upgrade)
            updatePlugin "$1"
            ;;
        colors)
            color
            ;;
        r|remove|uninstall)
            jap_plugins "r" "$1"
            ;;
        l|list)
            listPlugins
            ;;
        libs|libraries)
            jap_check_libraries
            ;;
        ip)
            jip "$1" "$2"
            ;;
        run)
            jap_run_command "$@"
            ;;
        e|edit)
            jap_edit_config "$1"
            ;;
        sp|space)
            jap_space "$@"
            ;;
    esac
}

if jq -e 'has("START")' "$JAP_runsJSON" >/dev/null;then
    jap run START
fi
