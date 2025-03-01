#!/bin/zsh
#
# Helper functions for the script functions

# Source file if exists
function sourceif() {
    [[ $# -eq 0 ]] && echo "Usage: sourceif <file> [error message]" && return 1
    if [[ $# -eq 1 ]]; then
        script="${redi}sourceif error${reset}"
    else
        script="${redi}sourceif error${reset} in ${yellow}$2${reset}"
    fi

    if [[ -f $1 ]]; then
        source $1
    else
        [[ $# -ge 2 ]] && printf "$1 not found\n" || printf "$2: $1 not found\n"
        printf "$script: ${cyan}$1${reset} not found\n"
        return 1
    fi
}

# Execute external script
function extscript() {
    /bin/bash -c "$(curl -fsSL $1)"
}

# Source external file
function extsource() {
    source /dev/stdin <<< "$(curl -fsSL $1)"
}

# Check if the function name starts with an allowed character
# Returns 1 if it does, 0 if it doesn't
check_function_name() {
    local name=$1
    if [[ $name =~ ^[a-zA-Z_] ]]; then
        echo "1" && return 0
    else
        echo "0" && return 1
    fi
}

# Convert unix timestamp to ISO 8601 date
# Returns: ISO 8601 date string in UTC
utime2iso() {
    local timestamp=$1
    date -r $timestamp -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Convert ISO 8601 date to unix timestamp
# Returns: Unix timestamp
iso2utime() {
    local date=$1
    date -j -f "%Y-%m-%dT%H:%M:%SZ" $date "+%s"
}

# Extract URL from a string
# Returns: URL if found, or an error message
extract_url() {
    if [[ $1 =~ (https?://[^ ]+) ]]; then
        echo "${match[1]}" && return 0
    else
        return 1
    fi
}
extract_url2() {
    if [[ "$1" =~ "http[s]?://[^ ]+" ]]; then
        echo "$MATCH" && return 0
    else
        return 1
    fi
}

# Extracts the path from a string
# Returns the path if found, or an error message
extract_path() {
    local input_string=$1
    local path
    if [[ $input_string =~ (/[[:alnum:]/._-]+) ]]; then
        path="${match[1]}"
        echo "$path" && return 0
    else
        echo "No path found in the given string." && return 1
    fi
}

# Extract version number from a string
# Returns: Version number if found, or an error message
extract_version() {
    local input=$1
    local match
    match=$(echo "$input" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)*' | head -n 1)
    if [ -n "$match" ]; then
        echo "$match" && return 0
    else
        echo "No version number found" && return 1
    fi
}
alias extractver=extract_version
alias getver=extract_version

# Human readable time
htime() {
    local seconds=$1
    if (( seconds < 60 )); then
        echo "$seconds sec"
    elif (( seconds < 3600 )); then
        local minutes=$(echo "scale=1; $seconds/60" | bc)
        echo "$minutes min"
    elif (( seconds <= 86400 )); then
        local hours=$(echo "scale=1; $seconds/3600" | bc)
        echo "$hours h"
    else
        local days=$(( seconds / 86400 ))
        local remaining_seconds=$(( seconds % 86400 ))
        local remaining_time=$(htime $remaining_seconds)
        if (( days > 1 )); then
            echo "$days days $remaining_time"
        else
            echo "$days day $remaining_time"
        fi
    fi
}