#!/bin/zsh
#
# Helper functions for the script functions

# Generate usage message for functions
# Usage: make_fn_usage <function-name> <function-arguments> [function-switches]
# Returns: usage message
# It is intended to be used by other scripts and not run directly
function make_fn_usage() {
    local fname=$1 fargs=$2 fswitches=$3
    local g=$(ansi bold green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    local usage="Usage: $g$fname$r "
    [[ -n $fswitches ]] && usage+="${p}[switches]${r}"
    [[ -n $fargs ]] && usage+=" $c$fargs$r"
    [[ -n $fswitches ]] && usage+="\nSwitches: $p" && { for s in ${(z)fswitches}; do; usage+="--$s "; done } && usage+="$r"
    printf "$usage\n"
}

# Check number of parameters
# Usage: check_fn_args <min> <max> <actual>
# Returns: "ok" if actual is within min and max, else an error message
# It is intended to be used by other scripts and not run directly
function check_fn_args() {
    [[ $# -ne 3 ]] && log::error "check_fn_args: not enough arguments (expected 3, given $#)" && return 1
    local min=$1
    local max=$2
    local given=$3
    local msg1=""; local msg2=""

    if [[ $min -gt $max ]]; then
        echo "check_fn_args: min number of arguments cannot be greater than max"
        return 1
    elif [[ $given -lt 0 ]]; then
        echo "check_fn_args: actual number of arguments cannot be negative"
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

