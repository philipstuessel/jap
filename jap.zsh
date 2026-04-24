#!/bin/zsh

VERSION="v0.12.0"

github_url="https://raw.githubusercontent.com/philipstuessel/jap"

JAP_FOLDER="$HOME/jap/"
JAP_config_Json="${JAP_FOLDER}config/config.json"
JAP_runsJSON="${JAP_FOLDER}config/runs.json"
tempf="${JAP_FOLDER}temp/"
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
    if [[ "$1" == "-v" || "$1" == "v" || "$1" == "" ]]; then
         echo ""
         echo -e "${YELLOW}      ██╗ █████╗ ██████╗ ${NC}"
         echo -e "${YELLOW}      ██║██╔══██╗██╔══██╗${NC}"
         echo -e "${YELLOW}      ██║███████║██████╔╝${NC}"
         echo -e "${YELLOW} ██   ██║██╔══██║██╔═══╝ ${NC}"
         echo -e "${YELLOW} ╚█████╔╝██║  ██║██║     ${NC}"
         echo -e "${YELLOW}  ╚════╝ ╚═╝  ╚═╝╚═╝     ${NC}"
         echo ""
         echo -e "JAP 🍜 | ${BOLD}${VERSION}${NC}"
    fi

    if [[ "$1" == "help" ]]; then
        zsh "${lib}docs/help"
    fi

    if [[ "$1" == "update" ]]; then
           zsh -c "$(curl -fsSL $github_url/main/update.zsh)" -- ~/jap
           source ~/.zshrc
    fi

    if [[ "$1" == "gi" ]]; then
        if [ ! -f $HOME/jap/.gitignore ]; then
        echo -e "Create in $HOME/jap/${GREEN}".gitignore"${NC}"
        echo ".DS_Store" > $HOME/jap/.gitignore
        echo "**/.DS_Store" >> $HOME/jap/.gitignore
        fi
        cp $HOME/jap/.gitignore $(pwd)/
        echo -e $(pwd)"/"${GREEN}".gitignore"${NC}
    fi

    if [[ "$1" == "ha" ]];then
        if [ -e "$(pwd)/.htaccess" ];then
            if [[ "$2" == "-y" ]];then
                t "$(pwd)/.htaccess"
                echo -e $(pwd)"/"${GREEN}".htaccess"${NC}
            else
                echo -e $RED"There is already a .htaccess in the folder.$NC"
                echo "Then type '-y' at the end of the command to confirm the selection"
            fi
        else
            t "$(pwd)/.htaccess"
            echo -e $(pwd)"/"${GREEN}".htaccess"${NC}
        fi
    fi

    if [[ "$1" == "i" || "$1" == "install" ]]; then
        installPlugin "$2"
    fi

    if [[ "$1" == "ug" || "$1" == "upgrade" ]]; then
        updatePlugin "$2"
    fi

    if [[ "$1" == "colors" ]]; then
        color
    fi

    if [[ "$1" == "r" || "$1" == "remove" || "$1" == "uninstall" ]];then
        jap_plugins "r" "$2"
    fi

    if [[ "$1" == "l" || "$1" == "list" ]];then
        base="${JAP_FOLDER}plugins/packages"
        [[ -d "$base" ]] || return 0

        while IFS= read -r d; do
            local name=$(basename "$d")
            file="$d/$name.zsh"
            [ -f "$file" ] && echo -e $BLUE" $name"$NC
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)
    fi

    if [[ "$1" == "ip" ]];then
        jip "$2" "$3"
    fi

    if [[ "$1" == "run" ]];then
        local runJson="${JAP_FOLDER}config/runs.json"
        local list=0
        if [[ "$2" == "local" ]];then
            local local_jsuns="$(pwd)/runs.json"
            if [[ -f "$local_jsuns" ]];then
                runJson="$local_jsuns"
            else
                echo -e "${RED}Local runs.json not found.${NC}"
                return 1
            fi

            if [[ "$3" == "l" || "$3" == "list" ]];then
                list=1
            fi
        fi

        if [[ "$2" == "l" || "$2" == "list" || $list == 1 ]];then
             echo "Available categories and their commands in '$runJson':"
             echo ""

            for category in $(jq 'keys[]' $runJson); do
                category=$(echo $category | tr -d '"')
                echo -e "${BLUE}Categories:${NC} ${LIGHT_GREEN}$category${NC}"
                    jq -r ".${category}[]" $runJson | while read cmd; do
                    echo -e "${BOLD}> $cmd${NC}"
                done
                echo ""
            done
        else
            category="$2"
            add=${@:3}
            if [[ "$2" == "local" ]];then
                category="$3"
                add=${@:4}
            fi
            if ! jq -e ". | has(\"$category\")" "$runJson" > /dev/null; then
                echo -e "${RED}Error:${NC} category '${category}' not found in ${runJson}"
                return 1
            fi

            echo -e ">${LIGHT_GREEN} $category${NC} is running:"

            jq -r ".${category}[]" "$runJson" | while IFS= read -r cmd; do
                echo "> $cmd" 
                echo ""
                eval "$cmd $add"
            done

        fi
    fi

    if [[ "$1" == "e" || "$1" == "edit" ]];then
        file="$2"
        runJson="${JAP_FOLDER}config/runs.json"
        e="$(jq -r '.editor' $JAP_config_Json)"

        if [[ $file == "runs" ]];then
            $e $runJson
        fi

        if [[ $file == "config" ]];then
            $e $JAP_config_Json
        fi
    fi
}

if jq -e 'has("START")' $JAP_runsJSON >/dev/null;then
    jap run START
fi

updateConfig() {
    url="${github_url}/main/config/config.json"
    local_file=$JAP_config_Json 
    temp_file="${tempf}up9383.json"
    if [ ! -d "${JAP_FOLDER}temp/" ];then
        md "${JAP_FOLDER}temp/"
    fi

    merged="${tempf}merged.json"
    curl -s $url -o $temp_file
    if ! test -s $local_file; then
        fetch2 "$HOME/jap/config/" $url
    fi

    jq -s '.[0] * .[1]' $temp_file $local_file > $merged
    echo $(cat $merged) > $local_file
    rm -r $merged
    rm -r $temp_file
    echo "Config Synchronization completed."
}

spm() {
    local os=$(uname)
    if [ "$os" = "Darwin" ];then
        if [[ "$1" == "i" ]];then
            brew install "$2"
        fi
        if [[ "$1" == "u" ]];then
            brew update
        fi
        if [[ "$1" == "ug" ]];then
            brew upgrade
        fi
    elif [ "$os" = "Linux" ];then
        if [[ "$1" == "i" ]];then
            sudo apt install "$2"
        fi
        if [[ "$1" == "u" ]];then
            sudo apt update
        fi
        if [[ "$1" == "ug" ]];then
            sudo apt upgrade
        fi
    fi
}

upgrade() {
    if jq -e 'has("UPGRADE")' $JAP_runsJSON >/dev/null;then
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
    else
    if [[ "$1" == "l" ]]; then
    echo -e ${UNDERLINE}"---- list all templates ----"${NC}
    find $HOME/jap/tpl/* -maxdepth 0 -type d -exec basename {} \; | while read dir; do echo -e "\033[0;36m$dir\033[0m"; done
    else 
        cp -r ~/jap/tpl/$1/* ./
        echo -e "The template ${GREEN}$1${NC} was added"
    fi
    fi
}

var() {
  local option="$1"
  local value="$2"
  if [[ -z "$value" ]]; then
    echo 0
    return
  fi
  if [[ " $@ " == *" -$option "* ]]; then
    local option_value=$(echo "$@" | awk -v option="-$option" '{for(i=1;i<=NF;i++) if ($i == option) print $(i+1)}')
    echo "$option_value"
  else
    echo 0 
  fi
}

# Needs Reboot Query
nrq() {
	if [ -f /var/run/reboot-required ]; then
        echo -e "${RED}Reboot required${NC}"
	else
        echo -e "${GREEN}No reboot needed${NC}"
	fi
}