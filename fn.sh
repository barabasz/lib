#!/bin/zsh
#
# Helper functions for the script functions
# ⚠️ These functions are intended to be used by other scripts and not run directly

# Generate colored function name
# Usage: make_fn_name <function-name>
# Returns: colored function name
function make_fn_name() {
    local name=$1
    echo "$(ansi green)$name$(ansi reset)"
}

# Generate colored function footer
# Usage: make_fn_footer <function-author> <function-date> <function-version>
# Returns: colored function footer
function make_fn_footer() {
    local author=$1 date=$2 version=$3
    echo "$version copyright © 1999-${date:0:4} $(ansi yellow)$author$(ansi reset)"
    echo "MIT License : https://opensource.org/licenses/MIT"
}

# Generate colored function error information
# Usage: make_fn_errinf <function-name> <function-switches>
# Returns: colored function error information if --info switch is present
function make_fn_errinf() {
    local name=$1 switches=$2 file=$3 c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    [[ "$switches" == *"info"* ]] && echo -n "Run $name ${p}--info$r for usage information." && return 0
    [[ "$switches" == *"help"* ]] && echo -n "Run $name ${p}--help$r for usage information." && return 0
    echo "Check source code for usage information ($c$file$r)."
}

# Generate colored function info
# Usage: make_fn_info <function-name> <function-info> <function-usage>
# Returns: colored function info
function make_fn_info() {
    local title=$1 usage=$2 footer=$3 compact=$4
    if [[ $compact == "compact" ]]; then
        echo "$title\n$usage"
    else
        echo "$title\n\n$usage\n\n$footer"
    fi
}

# Generate colored function version
# Usage: make_fn_version <function-name> <function-version>
# Returns: colored function version
function make_fn_version() {
    local name=$1 ver=$2
    printf "$name ver. $(ansi yellow)$ver$(ansi reset)\n\n"
}

# Generate colored function header
# Usage: make_fn_header <function-name> <function-info>
# Returns: colored function header
function make_fn_header() {
    local name=$1 info=$2
    echo "$name $info"
}

# Generate colored function help
# Usage: make_fn_help <function-info> <function-help>
# Returns: colored function help
function make_fn_help() {
    local info=$1 help=$2
    [[ -z $help ]] && help="$(ansi red)No help available.$(ansi reset)"
    echo "$info\n\n$help"
}

# Generate usage message for functions
# Usage: make_fn_usage <function-name> <function-arguments> [function-switches]
# Returns: usage message
function make_fn_usage() {
    local name=$1 args=$2 argsopt=$3 switches=$4 compact=$5
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    local usage="Usage: $name "
    if [[ $compact == "compact" ]]; then
        usage+="$c"
        [[ -n $args ]] && usage+="$c" && { for s in ${(z)args}; do; usage+="<$s> "; done } && usage+="$r"
        [[ -n $argsopt ]] && usage+="$c" && { for s in ${(z)argsopt}; do; usage+="[$s] "; done } && usage+="$r"
        usage+="$r"
    else
        [[ -n $switches ]] && usage+="${p}[switches]${r} "
        [[ -n $args ]] && usage+="${c}<arguments>${r}"
        [[ -n $switches ]] && usage+="\nSwitches: $p" && { for s in ${(z)switches}; do; usage+="--$s "; done } && usage+="$r"
        [[ -n $switches ]] && usage+="or $p" && { for s in ${(z)switches}; do; usage+="-${s:0:1} "; done } && usage+="$r"
        [[ -n $args || -n $argsopt ]] && usage+="\nArguments: "
        [[ -n $args ]] && usage+="$c" && { for s in ${(z)args}; do; usage+="<$s> "; done } && usage+="$r"
        [[ -n $argsopt ]] && usage+="$c" && { for s in ${(z)argsopt}; do; usage+="[$s] "; done } && usage+="$r"
    fi
    printf "$usage\n"
}

# Check number of parameters
# Usage: check_fn_args <min> <max> <actual>
# Returns: "ok" if actual is within min and max, else an error message
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

