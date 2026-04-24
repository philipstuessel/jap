jip () {
    if [[ "$1" == "-r" ]];then
        if [[ "$2" == "local" ]];then
            echo "$(ifconfig | grep 'inet ' | grep -v 'inet6' | awk '{print $2}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^127\.0\.0\.1$' | grep -v '^$')"
            return 0
        fi

        if [[ "$2" == "ping" ]];then
            url="$3"
            if [[ "$url" =~ ^https?:// ]]; then
                host=$(echo $url | sed -n 's,^\(https*://\)\([^/]*\).*,\2,p' | cut -d':' -f1)
            else
                host=$(echo $url | cut -d':' -f1)
            fi
    
            ip=$(ping -c 1 $host | grep PING | awk '{print $3}')
    
            ip_cleaned=$(echo $ip | tr -d '()')
            ip_cleaned=$(echo $ip_cleaned | tr -d ':')
    
            echo $ip_cleaned
            return 0
        fi
    fi

    if [[ "$1" == "my" || "$1" == "local" ]];then
        if [[ "$2" == "all" ]];then
            ifconfig | grep inet | awk '{print $2}'
        else
            localip="$(ifconfig | grep 'inet ' | grep -v 'inet6' | awk '{print $2}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '^127\.0\.0\.1$' | grep -v '^$')"
            if [[ "$2" == "c" || "$2" == "copy" ]];then
                copy_to_clipboard $localip
            fi
            echo -e "${MAGENTA}${BOLD}$localip${NC}"
        fi
    elif [[ ! "$1" == "" ]];then
        url="$1"
        if [[ "$url" =~ ^https?:// ]]; then
            host=$(echo $url | sed -n 's,^\(https*://\)\([^/]*\).*,\2,p' | cut -d':' -f1)
        else
            host=$(echo $url | cut -d':' -f1)
        fi

        ip=$(ping -c 1 $host | grep PING | awk '{print $3}')

        ip_cleaned=$(echo $ip | tr -d '()')
        ip_cleaned=$(echo $ip_cleaned | tr -d ':')

        copy_to_clipboard $ip_cleaned
        echo -e "${BLUE}${BOLD}${ip_cleaned}${NC}"
    fi
}