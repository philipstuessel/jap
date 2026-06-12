ensureLibrariesFile() {
    if [[ ! -f "$libraries" ]]; then
        echo "Creating libraries file..."
        mkdir -p "$(dirname "$libraries")"
        touch "$libraries"
        echo "https://japzsh.com/library.json" > "$libraries"
    fi
}

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

    ensureLibrariesFile

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

jap_extract_host() {
    local url="$1"
    local host="${url#*://}"

    host="${host%%/*}"
    host="${host%%:*}"
    echo "$host"
}

jap_ping_time_ms() {
    local host="$1"
    local ping_line

    if [[ -z "$host" ]]; then
        echo "-"
        return 0
    fi

    ping_line="$(ping -c 1 "$host" 2>/dev/null | grep -o 'time=[0-9.]*' | head -n 1)"

    if [[ -n "$ping_line" ]]; then
        echo "${ping_line#time=}"
    else
        echo "-"
    fi
}

jap_http_probe() {
    local url="$1"
    local output_file="$2"
    local response
    local http_status
    local total_time

    response="$(curl -L -sS --connect-timeout 5 --max-time 15 -o "$output_file" -w '%{http_code}\t%{time_total}' "$url" 2>/dev/null)"
    http_status="${response%%$'\t'*}"
    total_time="${response#*$'\t'}"

    if [[ -z "$http_status" || "$http_status" == "$response" ]]; then
        http_status="000"
    fi

    if [[ -z "$total_time" || "$total_time" == "$response" ]]; then
        total_time="0"
    fi

    echo "${http_status}\t${total_time}"
}

jap_normalize_plugin_url() {
    local url="${1%/}"

    url="${url%/install.zsh}"
    url="${url%/update.zsh}"

    echo "$url"
}

jap_detect_installed_plugins() {
    local base="$1"
    local d
    local name

    typeset -ga JAP_VALID_PLUGINS JAP_INVALID_PLUGINS
    JAP_VALID_PLUGINS=()
    JAP_INVALID_PLUGINS=()

    [[ -d "$base" ]] || return 0

    for d in "$base"/*(N/); do
        name="$(basename "$d")"
        if [[ -f "$d/$name.zsh" ]]; then
            JAP_VALID_PLUGINS+=("$name")
        else
            JAP_INVALID_PLUGINS+=("$name")
        fi
    done
}

jap_record_library_result() {
    local result_file="$1"
    local kind="$2"
    local field

    shift 2

    {
        printf '%s' "$kind"
        for field in "$@"; do
            printf '\t%s' "$field"
        done
        printf '\n'
    } >> "$result_file"
}

jap_check_library_worker() {
    local liburl="$1"
    local progress_file="$2"
    local result_file="$3"
    local library_body
    local library_probe
    local library_status
    local library_time
    local library_ping
    local plugin_total=0
    local plugin_ok=0
    local plugin_fail=0
    local plugin_index=0

    : > "$result_file"
    library_body="${result_file}.json"
    library_probe="$(jap_http_probe "$liburl" "$library_body")"
    library_status="${library_probe%%$'\t'*}"
    library_time="${library_probe#*$'\t'}"
    library_ping="$(jap_ping_time_ms "$(jap_extract_host "$liburl")")"

    if [[ ! "$library_status" =~ ^2[0-9][0-9]$ ]]; then
        printf '1\t1\n' > "$progress_file"
        jap_record_library_result "$result_file" "summary" "$liburl" "$library_status" "$library_time" "$library_ping" "$plugin_total" "$plugin_ok" "1"
        jap_record_library_result "$result_file" "error" "$liburl returned HTTP $library_status"
        rm -f "$library_body"
        return 0
    fi

    if ! jq -e 'type == "object"' "$library_body" >/dev/null 2>&1; then
        printf '1\t1\n' > "$progress_file"
        jap_record_library_result "$result_file" "summary" "$liburl" "$library_status" "$library_time" "$library_ping" "$plugin_total" "$plugin_ok" "1"
        jap_record_library_result "$result_file" "error" "$liburl did not return a valid JSON object"
        rm -f "$library_body"
        return 0
    fi

    plugin_total="$(jq -r '
        [
            to_entries[]
            | select(
                (.value | type) == "string" or
                (
                    (.value | type) == "object" and
                    (.value.url? // .value.repo? // .value.install?) != null
                )
            )
        ] | length
    ' "$library_body" 2>/dev/null)"

    [[ "$plugin_total" =~ ^[0-9]+$ ]] || plugin_total=0
    printf '1\t%s\n' "$((plugin_total + 1))" > "$progress_file"

    while IFS=$'\t' read -r plugin_name plugin_url; do
        local base_url
        local install_url
        local update_url
        local install_probe
        local update_probe
        local install_status
        local install_time
        local update_status
        local update_time
        local plugin_ping
        local plugin_failed=0

        [[ -z "$plugin_name" || -z "$plugin_url" ]] && continue

        base_url="$(jap_normalize_plugin_url "$plugin_url")"
        install_url="${base_url}/install.zsh"
        update_url="${base_url}/update.zsh"
        install_probe="$(jap_http_probe "$install_url" "/dev/null")"
        update_probe="$(jap_http_probe "$update_url" "/dev/null")"
        install_status="${install_probe%%$'\t'*}"
        install_time="${install_probe#*$'\t'}"
        update_status="${update_probe%%$'\t'*}"
        update_time="${update_probe#*$'\t'}"
        plugin_ping="$(jap_ping_time_ms "$(jap_extract_host "$base_url")")"

        if [[ ! "$install_status" =~ ^2[0-9][0-9]$ ]]; then
            jap_record_library_result "$result_file" "error" "$plugin_name install.zsh -> HTTP $install_status ($install_url)"
            plugin_failed=1
        fi

        if [[ ! "$update_status" =~ ^2[0-9][0-9]$ ]]; then
            jap_record_library_result "$result_file" "error" "$plugin_name update.zsh -> HTTP $update_status ($update_url)"
            plugin_failed=1
        fi

        if (( plugin_failed == 0 )); then
            plugin_ok=$((plugin_ok + 1))
        else
            plugin_fail=$((plugin_fail + 1))
        fi

        jap_record_library_result "$result_file" "plugin" "$plugin_name" "$plugin_ping" "$install_status" "$install_time" "$update_status" "$update_time"

        plugin_index=$((plugin_index + 1))
        printf '%s\t%s\n' "$((plugin_index + 1))" "$((plugin_total + 1))" > "$progress_file"
    done < <(
        jq -r '
            to_entries[]
            | .key as $name
            | (
                if (.value | type) == "string" then .value
                elif (.value | type) == "object" then (.value.url // .value.repo // .value.install // empty)
                else empty
                end
            ) as $url
            | select(($url | type) == "string" and ($url | length) > 0)
            | [$name, $url]
            | @tsv
        ' "$library_body" 2>/dev/null
    )

    jap_record_library_result "$result_file" "summary" "$liburl" "$library_status" "$library_time" "$library_ping" "$plugin_total" "$plugin_ok" "$plugin_fail"
    printf '%s\t%s\n' "$((plugin_total + 1))" "$((plugin_total + 1))" > "$progress_file"
    rm -f "$library_body"
}

jap_render_libraries_progress() {
    local completed_units="$1"
    local total_units="$2"
    local finished_libraries="$3"
    local total_libraries="$4"
    local errors_found="$5"
    local percent=0
    local filled=0
    local empty=20
    local bar=""

    if (( total_units > 0 )); then
        percent=$((completed_units * 100 / total_units))
        filled=$((percent / 5))
        empty=$((20 - filled))
    fi

    bar="$(printf '%*s' "$filled" '' | tr ' ' '#')"
    bar="${bar}$(printf '%*s' "$empty" '' | tr ' ' '-')"

    printf '\r%b[%s]%b %3d%%  Libraries %d/%d  Errors %d' \
        "${CYAN}" "$bar" "${NC}" "$percent" "$finished_libraries" "$total_libraries" "$errors_found"
}

jap_check_libraries() {
    setopt localoptions no_bg_nice no_monitor no_notify typeset_silent

    local tmp_dir
    local -a lib_urls
    local -a progress_files
    local -a result_files
    local -a pids
    local index=1
    local total_libraries
    local completed_units
    local total_units
    local finished_libraries
    local errors_found
    local progress_file
    local result_file

    ensureLibrariesFile

    while IFS= read -r liburl; do
        [[ -z "${liburl// }" ]] && continue
        [[ "$liburl" == \#* ]] && continue
        lib_urls+=("$liburl")
    done < "$libraries"

    total_libraries="${#lib_urls[@]}"

    if (( total_libraries == 0 )); then
        echo -e "${YELLOW}No libraries configured in $libraries${NC}"
        return 0
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}jq is required for 'jap libs'${NC}"
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}curl is required for 'jap libs'${NC}"
        return 1
    fi

    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/jap-libs.XXXXXX")" || return 1

    for liburl in "${lib_urls[@]}"; do
        progress_file="${tmp_dir}/library-${index}.progress"
        result_file="${tmp_dir}/library-${index}.result"
        printf '0\t1\n' > "$progress_file"
        progress_files+=("$progress_file")
        result_files+=("$result_file")
        jap_check_library_worker "$liburl" "$progress_file" "$result_file" &
        pids+=("$!")
        index=$((index + 1))
    done

    while :; do
        completed_units=0
        total_units=0
        finished_libraries=0
        errors_found=0

        for progress_file in "${progress_files[@]}"; do
            local current_units=0
            local max_units=1

            if [[ -f "$progress_file" ]]; then
                current_units="$(awk -F '\t' 'NR==1 {print $1}' "$progress_file" 2>/dev/null)"
                max_units="$(awk -F '\t' 'NR==1 {print $2}' "$progress_file" 2>/dev/null)"
            fi

            [[ "$current_units" =~ ^[0-9]+$ ]] || current_units=0
            [[ "$max_units" =~ ^[0-9]+$ ]] || max_units=1

            completed_units=$((completed_units + current_units))
            total_units=$((total_units + max_units))

            if (( current_units >= max_units )); then
                finished_libraries=$((finished_libraries + 1))
            fi
        done

        for result_file in "${result_files[@]}"; do
            local file_errors=0

            if [[ -f "$result_file" ]]; then
                file_errors="$(grep -c '^error' "$result_file" 2>/dev/null)"
                [[ "$file_errors" =~ ^[0-9]+$ ]] || file_errors=0
                errors_found=$((errors_found + file_errors))
            fi
        done

        jap_render_libraries_progress "$completed_units" "$total_units" "$finished_libraries" "$total_libraries" "$errors_found"

        if (( finished_libraries >= total_libraries )); then
            break
        fi

        sleep 0.2
    done

    for pid in "${pids[@]}"; do
        wait "$pid"
    done

    echo ""
    echo ""
    echo -e "${BOLD}Library check summary${NC}"

    for result_file in "${result_files[@]}"; do
        local summary_line
        local liburl
        local library_status
        local library_time
        local library_ping
        local plugin_total
        local plugin_ok
        local plugin_fail
        local plugin_counts
        local status_color="$GREEN"
        local status_label="OK"

        summary_line="$(grep '^summary' "$result_file" 2>/dev/null | tail -n 1)"
        [[ -z "$summary_line" ]] && continue

        IFS=$'\t' read -r _ liburl library_status library_time library_ping plugin_total plugin_ok plugin_fail <<< "$summary_line"
        plugin_counts="$(awk -F '\t' '
            $1 == "plugin" {
                total++
                if ($4 ~ /^2[0-9][0-9]$/ && $6 ~ /^2[0-9][0-9]$/) {
                    ok++
                }
            }
            END {
                printf "%d\t%d", ok, total
            }
        ' "$result_file" 2>/dev/null)"

        plugin_ok="${plugin_counts%%$'\t'*}"
        plugin_total="${plugin_counts#*$'\t'}"
        [[ "$plugin_ok" =~ ^[0-9]+$ ]] || plugin_ok=0
        [[ "$plugin_total" =~ ^[0-9]+$ ]] || plugin_total=0
        plugin_fail=$((plugin_total - plugin_ok))

        if (( plugin_fail > 0 )) || [[ ! "$library_status" =~ ^2[0-9][0-9]$ ]]; then
            status_color="$RED"
            status_label="FAIL"
        fi

        echo -e "${status_color}${status_label}${NC} ${liburl}"
        echo -e "  library: HTTP ${library_status}, ${library_time}s, ping ${library_ping}ms"
        echo -e "  plugins: ${plugin_ok}/${plugin_total} ok"

        if grep -q '^error' "$result_file" 2>/dev/null; then
            grep '^error' "$result_file" | while IFS=$'\t' read -r _ message; do
                echo -e "  ${RED}${message}${NC}"
            done
        fi

        echo ""
    done

    rm -rf "$tmp_dir"
}

updatePlugin() {
    local base="${JAP_FOLDER}plugins/packages"
    local name
    local notfoundInlibraries=""

    if [[ "$1" == "" ]];then
        jap_detect_installed_plugins "$base"

        if (( ${#JAP_INVALID_PLUGINS[@]} > 0 )); then
            echo -e "${RED}Invalid plugin installations found:${NC}"
            for name in "${JAP_INVALID_PLUGINS[@]}"; do
                echo -e "${YELLOW}- ${name}${NC} is missing ${BOLD}${name}.zsh${NC}"
            done
            return 1
        fi

        if (( ${#JAP_VALID_PLUGINS[@]} == 0 )); then
            echo -e "${RED}No installed plugins found.${NC}"
            return 1
        fi

        echo "Upgrade list:"
        for name in "${JAP_VALID_PLUGINS[@]}"; do
            echo -e "${BLUE}$name${NC}"
        done

        echo ""
        echo "######## Upgrade all plugins ########"
        echo ""
        for name in "${JAP_VALID_PLUGINS[@]}"; do
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
        local KEY="$1"
        local plugin_dir="${base}/${KEY}"

        if [[ ! -d "$plugin_dir" ]]; then
            echo -e "${RED}The plugin \"$KEY\" is not installed${NC}"
            return 1
        fi

        if [[ ! -f "$plugin_dir/$KEY.zsh" ]]; then
            echo -e "${RED}Invalid plugin installation:${NC} ${YELLOW}$KEY${NC} is missing ${BOLD}$KEY.zsh${NC}"
            return 1
        fi

        if searchPlugin "$KEY"; then
            echo "[$FOUND_LIBURL] $FOUND_URL"
            zsh -c "$(curl -fsSL $FOUND_URL/update.zsh)" -- ~/jap
            if [ $? -eq 0 ]; then
                echo -e "Upgrade for '$KEY' completed ${LIGHT_GREEN}successfully.${NC}"
                sourceInclude "${JAP_FOLDER}plugins/packages"
            else
                echo -e "${RED}Upgrade for '$KEY' failed.${NC}"
            fi
        else
            echo -e "${RED}The plugin \"$KEY\" was not found${NC}"
            return 0
        fi
    fi
}

listPlugins() {
    local base="${JAP_FOLDER}plugins/packages"
    local count=0
    local plugins=()

    [[ -d "$base" ]] || {
        echo -e "No plugins installed."
        return 0
    }

    while IFS= read -r d; do
        if [[ -f "$d/$(basename "$d").zsh" ]]; then
            plugins+=("$(basename "$d")")
            ((count++))
        fi
    done < <(find "$base" -mindepth 1 -maxdepth 1 -type d)

    if (( count == 0 )); then
        echo -e "No plugins installed."
    else
        for p in "${plugins[@]}"; do
            echo -e "${BLUE} $p${NC}"
        done
        echo -e "'${BOLD}${count}${NC}' plugin(s) installed"
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
