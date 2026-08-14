fetch() {
    mkdir -p "$1"
    curl -o "$2" "$3" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "📥 $3"
        return 1
    else
        echo -e "❌ ${RED}$3${NC}"
        return 0
    fi
}

fetch2() {
    local dest="$1"
    local url="$2"

    mkdir -p "$dest"
    file="$dest$(basename "$url")"

    if ! curl -fsI "$url" >/dev/null; then
        echo -e "${RED}URL not reachable${NC}: $url"
        return 1
    fi

    echo -e "${YELLOW}Downloading$NC: $url"
    curl -L --progress-bar "$url" -o "$file"
    if [ $? -eq 0 ]; then
        echo -ne "\033[1A\033[2K"
        echo -ne "\033[1A\033[2K"
        echo -e "${GREEN}Download completed${NC}: $url"
    else
        echo -ne "\033[1A\033[2K"
        echo -e "${RED}Error downloading file: $2${NC}"
        return 0
    fi
}