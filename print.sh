#!/bin/zsh

# Console print library
# https://raw.githubusercontent.com/barabasz/lib/main/print.sh

# Pretty print serialized array (indexed or associative)
# Usage: print::arr <serialized_array>
# Example: print::arr "$(typeset -p my_array)"
function print::arr() {
    local input="$1"
    # Check if input is valid array serialization
    if [[ ! $input == *"typeset -"[aA]* ]]; then
        print -u2 "Error: Unsupported array serialization type."
        return 1
    fi
    # Get array type, name and content
    local array_type="${${input#*typeset -}%% *}"
    local array_name="${${input#*typeset -[aA] }%%=*}"
    local array_content="${${${input#*=}#\(}%\)}"
    [[ "$array_content" =~ ^[[:space:]]*$ ]] && array_content=""
    # Set array type and description
    if [[ $array_type == "A" ]]; then
        local -A arr
        local array_desc="associative array"
    else
        local -a arr
        local array_desc="indexed array"
    fi
    # Fill the array with content
    if [[ -n $array_content ]]; then
        eval "arr=($array_content)" 2>/dev/null || {
            print -u2 "Error: Failed to deserialize the $array_desc."
            return 1
        }
        # Convert indexed array to associative array
        if [[ $array_type == "a" ]]; then
            local -a arr_temp=("${arr[@]}")
            unset arr
            local -A arr
            for i in {1..$#arr_temp}; do
                arr[$i]=${arr_temp[i]}
            done
        fi 
    fi
    local array_len=${#arr}
    # Print the array
    print "Array name: $array_name"
    print "Array type: $array_desc"
    print "Array length: $array_len"
    for key in ${(ko)arr}; do
        print "$key: ${arr[$key]}"
    done
}

function print::header() {
    printf "\n$(ansi bold white)%s$(ansi reset)\n" "$(print::line "$*")";
}

function print::footer() {
    printf "$(ansi bold white)%s$(ansi reset)\n\n" "$(print::line "$*")";
}

function print::line() {
    local TOTAL_CHARS=60
    local total=$TOTAL_CHARS-2
    local size=${#1}
    local left=$((($total - $size) / 2))
    local right=$(($total - $size - $left))
    local hs='─' # header symbol
    printf "%${left}s" '' | tr ' ' $hs
    printf " $1 "
    printf "%${right}s" '' | tr ' ' $hs
}

# Print title in frame
function print::title() {
    local str=$1; local len=${#str}; local lc="─"
    local tl="┌──"; local tr="──┐";
    local ml="│  "; local mr="  │"
    local bl="└──"; local br="──┘";
    local ll=$(printf "%${len}s" | sed "s/ /${lc}/g")
    printf "$tl$ll$tr\n$ml$redi$str$reset$mr\n$bl$ll$br\n"
}

# Print yellow header
function printh() {
    output="\n${yellowb}"$*"${reset}\n"
    printf "$output"
}

function printh2() {
    printf "\n$(ansi bold bright yellow)%s$(ansi reset)\n" "$*";
}

# Print red error
function printe() {
    output="${redb}"$*"${reset}\n"
    printf "$output"
}

# Print cyan info
function printc() {
    output="${cyani}"$*"${reset}\n"
    printf "$output"
}

# Print blue info
function printb() {
    output="${bluei}"$*"${reset}\n"
    printf "$output"
}

# Print green info
function printi() {
    output="${greeni}"$*"${reset}\n"
    printf "$output"
}

# Print purple info
function printp() {
    output="${purplei}"$*"${reset}\n"
    printf "$output"
}

# Print white info
function printw() {
    output="${whitei}"$*"${reset}\n"
    printf "$output"
}

# Print red info
function printr() {
    output="${redi}"$*"${reset}\n"
    printf "$output"
}

# Print yellow info
function printy() {
    output="${yellowi}"$*"${reset}\n"
    printf "$output"
}

# Functions as aliases (for backward compatibility)
printhead() {
    printh "$@"
}
printtitle() {
    print::title "$@"
}
printinfo() {
    printi "$@"
}
printerror() {
    printe "$@"
}
