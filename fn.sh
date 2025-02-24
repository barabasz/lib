#!/bin/zsh
#
# Helper functions for the script functions

### FUNCTION TEMPLATE
function __TEMPLATE() {
### function header
    local f_name="tmp" f_args="<agrument>" f_switches=("--help" "--version")
    local f_info="is a template for functions."
    local f_min_args=1 f_max_args=1 f_ver="0.1"
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi purple) r=$(ansi reset)
    local fname="$g${f_name}$r" fargs="$c${f_args}$r"
    [[ -n $f_switches ]] && fargs+=" ${p}[<switches>...]${r}"
    local finfo="$fname $f_info\n" fusage="Usage: $fname $fargs\n"
    [[ -n $f_switches ]] && fusage="${fusage}Switches: ${p}$f_switches${r}\n"
    local fver="$fname version $f_ver\n"
    local args=$(checkargs $f_min_args $f_max_args $#)
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == "--version" ]] && printf "$fver" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
### main function
    echo $1
}

# Check number of parameters
function checkargs() {
    if [[ $# -ne 3 ]]; then
        printf "${redi}checkargs error${reset}: not enough arguments (expected 3, given $#)\n"
        printf "checkargs usage: ${yellow}checkargs${reset} ${green}<min> <max> <actual>${reset}\n"
        return 1
    fi

    local min=$1
    local max=$2
    local given=$3
    local msg1=""; local msg2=""

    if [[ $min -gt $max ]]; then
        echo "checkargs: min number of arguments cannot be greater than max"
        return 1
    elif [[ $given -lt 0 ]]; then
        echo "checkargs: actual number of arguments cannot be negative"
        return 1
    fi

    if [[ $given -eq 0 ]]; then
        msg1="no arguments given"
    elif [[ $given -lt $min ]]; then
        msg1="not enough arguments"
    elif [[ $given -gt $max ]]; then
        msg1="too many arguments"
    fi

    if [[ $given -lt $min || $given -gt $max ]]; then
        if [[ $1 == $2 ]]; then
            msg2="expected $min"
        else
            msg2="expected $min to $max"
        fi
        echo "$msg1 ($msg2, given $given)"
        return 1
    fi

    echo "ok"
    return 0
}

# Usage message for functions
function usage() {
    local fname=$1 fargs=$2
    printf "$1 usage: ${yellow}$1${reset} ${green}$2${reset}\n"
}