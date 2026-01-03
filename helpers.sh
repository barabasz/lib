#!/bin/zsh
#
# Helper functions for the script functions
# zsh-specific functions - requires zsh, will not work in bash

# Clean a string (normalize whitespace)
# collapse multiple spaces/tabs/newlines into single spaces
clean_string() {
    if [[ $# -ne 1 ]]; then
        print -u2 "clean_string: requires exactly one argument, given $#"
        return 1
    fi
    print -r -- "${(j: :)${=1}}"
}

# Clean a string by removing ANSI escape codes
clean_ansi() {
  local input="$1"
  echo "$input" | sed $'s/\x1b\\[[0-9;]*m//g'
}

# Get total time taken by a command with optional arguments
function timet() {
    local cmd=$1
    local arg=$2
    echo "$((time (eval $cmd \$$arg)) 2>&1 | awk '/total/ {print $(NF-1)}')"
}

# Source file if it exists, silently skip otherwise
sourceif() {
    [[ $# -eq 1 ]] && is_file "$1" && source "$1"
}

# Source file or report error
sourcefile() {
    [[ $# -eq 1 ]] || return 1
    if is_file "$1"; then
        source "$1"
    else
        print -u2 "$1 not found"
        return 1
    fi
}

# Function to source remote files
# Usage: source_remote <url>
# Compatible with both bash and zsh
source_remote() {
    if [[ $# -ne 1 ]]; then
        echo "${r}source_remote: requires exactly one argument, given $#${x}"
        return 1
    fi
    local url=$1 name file_content=""
    name=$(basename "$1")
    
    # Check if the file is accessible
    wget -q --spider "$url" || { echo "${r}Error: $name is not accessible ($url).${x}"; return 1; }
    
    file_content=$(wget -q -O - "$url")
    [[ $? -ne 0 ]] && { echo "${r}Error getting $name ($url).${x}"; return 1; }
    
    source /dev/stdin <<< "$file_content"
    [[ $? -ne 0 ]] && { echo "${r}Error sourcing $name.${x}"; return 1; }
    
    echo "$name successfully loaded."
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
    if [[ $# -ne 1 ]]; then
        print -u2 "utime2iso: requires exactly one argument, given $#"
        return 1
    fi
    if [[ ! $1 =~ ^[0-9]+$ ]]; then
        print -u2 "utime2iso: argument must be a positive integer"
        return 1
    fi
    command date -r "$1" -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Convert ISO 8601 date to unix timestamp
# Returns: Unix timestamp
iso2utime() {
    if [[ $# -ne 1 ]]; then
        print -u2 "iso2utime: requires exactly one argument, given $#"
        return 1
    fi
    if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
        print -u2 "iso2utime: argument must be ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)"
        return 1
    fi
    command date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$1" "+%s"
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

# Function to convert a string to a list in both zsh and bash
string_to_words() {
    # Determine the shell and split accordingly
    if [[ -n "$ZSH_VERSION" ]]; then
        # For Zsh: use array assignment with word splitting
        local -a arr
        read -A arr <<< "$1"
        printf '%s\n' "${arr[@]}"
    else
        # For Bash: use word splitting
        local arr=($1)
        printf '%s\n' "${arr[@]}"
    fi
}

# Function that returns full path of target
# Usage: fullpath <target>
# Returns: full path of target or "notfound" if the target doesn't exist
getfullpath() {
    local target="$1"
    if [[ ! -e "$target" ]]; then
        printf "notfound"
        return 1
    fi
    local abs_path="${target:A}"
    abs_path="${abs_path%/}"
    printf "%s" "$abs_path"
    return 0
}

# Function to get absolute path
# Usage: fulldirpath <path>
# Returns: Absolute path or "notfound" if the path doesn't exist
fulldirpath() {
  local dir="$1"
  # dir:A is better than dir:P because it resolves symlinks
  dir="${dir:A}"
  dir="${dir%/}"
  [[ ! -d "$dir" ]] && printf "notfound" && return 1
  printf "%s" "$dir" && return 0
}

# Function to check if a directory is empty
# Usage: isdirempty <path>
# Returns: "1" and code 0 if the directory is empty
isdirempty() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    
    # Create an array with all files (including hidden ones)
    local files=($dir/*(DN))
    
    if (( ${#files} == 0 )); then
        # dir is completely empty
        printf "1" && return 0
    else
        # dir is not empty
        printf "0" && return 1
    fi
}

# Function to check if a directory has any non-hidden files to be served
# Usage: isdirservable <path>
# Returns: "1" and code 0 if the directory has at least one non-hidden file
function isdirservable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    # Create an array with all files excluding hidden ones
    local files=($dir/*(N))
    
    if (( ${#files} == 0 )); then
        # dir is completely empty
        printf "0" && return 1
    else
        # dir is not empty
        printf "1" && return 0
    fi
}

function isdirreadable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    # Check if the directory is readable
    if [[ -r "$dir" ]]; then
        printf "1" && return 0
    else
        printf "0" && return 1
    fi
}

function isdirwritable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    # Check if the directory is writable
    if [[ -w "$dir" ]]; then
        printf "1" && return 0
    else
        printf "0" && return 1
    fi
}

# uwhich: find executable path, even if shadowed by alias/function
# Returns (stdout + exit 0): absolute path to executable
# Returns (stdout + exit 1): info message (not a file or not found)
uwhich() {
    [[ $# -eq 1 ]] || return 1
    local cmd=$1
    local cmd_type=$(utype "$cmd")

    case $cmd_type in
        file|alias)
            if [[ -n $ZSH_VERSION ]]; then
                whence -p -- "$cmd"
            else
                type -P -- "$cmd"
            fi
            ;;
        notfound)
            printf '%s: not found\n' "$cmd"
            return 1
            ;;
        *)
            printf '%s is a %s\n' "$cmd" "$cmd_type"
            return 1
            ;;
    esac
}