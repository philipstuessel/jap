pull_check() {
    if [ ! -f "$(pwd)/pull-list.json" ]; then
        echo -e "${RED}pull-list.json File not found${NC}"
        return 1
    fi
    return 0
}

pull_core() {
    if [[ -z "$2" ]]; then
        DIR=$(pwd)
    else
        if [ ! -d "$2" ]; then
            mkdir -p "$2"
        fi
        DIR="$2"
    fi

    fetch2 "$DIR/" "$1"
}

pull() {
    if [[ -z "$1" ]]; then
        echo -e "${RED}Please provide 'all' or a URL to pull.${NC}"
        echo -e "Usage: pull all or pull <URL> [destination_folder]"
        return 1
    fi
    if [[ "$1" == "all" ]]; then
        pull_check
        json=$(cat pull-list.json)
        urls=$(echo "$json" | jq -r 'to_entries[] | .key + " " + .value')
        
        while IFS= read -r url; do
            key=$(echo "$url" | cut -d ' ' -f 1)
            value=$(echo "$url" | cut -d ' ' -f 2)
            pull_core $key $value
        done <<< "$urls"
    else
        pull_core "$1" "$2"
    fi
}