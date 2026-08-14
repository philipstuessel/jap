replace() {
    local content=""

    if [[ $# -lt 3 ]]; then
        echo -e "${RED}[replace] Error: Not enough arguments.$NC" >&2
        echo -e "[replace] Usage: replace <content> -a '{\"key\": \"value\", ...}'" >&2
        return 1
    fi

    content="$1"
    shift

    if [[ "$1" != "-a" ]]; then
        echo -e "${RED}[replace] Error: Expected flag '-a' but got '$1'.$NC" >&2
        return 1
    fi
    shift

    if [[ -z "$1" ]]; then
        echo -e "${RED}[replace] Error: Missing JSON map after '-a'.$NC" >&2
        return 1
    fi

    local json="$1"

    if command -v jq &>/dev/null; then
        if ! jq -e . <<< "$json" &>/dev/null; then
            echo -e "${RED}[replace] Error: Invalid JSON: $json $NC" >&2
            return 1
        fi

        local result="$content"
        while IFS=$'\t' read -r key value; do
            result="${result//"$key"/"$value"}"
        done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' <<< "$json")

        echo "$result"
    else
        local -A replacements
        local first="${json:0:1}"
        local len="${#json}"
        local last="${json:$((len - 1)):1}"

        if [[ "$first" != "{" ]] || [[ "$last" != "}" ]]; then
            echo -e "${RED}[replace] Error: Invalid format. Map must be wrapped in '{}'.$NC" >&2
            return 1
        fi

        json="${json:1:$((len - 2))}"

        local trimmed="${json//[[:space:]]/}"
        if [[ -z "$trimmed" ]]; then
            echo -e "${RED}[replace] Error: Map is empty.$NC" >&2
            return 1
        fi

        local parsed=0
        while [[ "$json" =~ \"([^\"]+)\":[[:space:]]*\"([^\"]*)\"(.*) ]]; do
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            replacements["$key"]="$value"
            json="${BASH_REMATCH[3]}"
            json="${json#,}"
            json="${json#"${json%%[! ]*}"}"
            (( parsed++ ))
        done

        if [[ $parsed -eq 0 ]]; then
            echo -e "${RED}[replace] Error: Could not parse any key-value pairs.$NC" >&2
            return 1
        fi

        local result="$content"
        for key in "${!replacements[@]}"; do
            result="${result//"$key"/"${replacements[$key]}"}"
        done

        echo "$result"
    fi
}