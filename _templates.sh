#!/bin/zsh
#
# This is an ARCHIVE.

### FUNCTION TEMPLATE

function __TEMPLATE2() {  # without switches
### function header
    local f_name="tmp"
    local f_args="agrument1 argument2"
    local f_args_opt="agrument3"
    local f_switches="help version"
    local f_info="is a template for functions."
    local f_min_args=1 f_max_args=1 f_ver="0.1"
### function properties
    local name="$(make_fn_name $f_name)"
    local usage="$(make_fn_usage $f_name $f_args $f_args_opt $f_switches)"
    local info="$(make_fn_info $f_name $f_info)\n$usage"
    local version="$(make_fn_version $f_name $f_ver)"
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" ]] && log::error "$name: $args" && printf $info && return 1
### main function
    echo $1
}

function __TEMPLATE2() {
### function header
    local f_name="tmp"
    local f_args="agrument1 argument2"
    local f_args_opt="agrument3"
    local f_switches="help version"
    local f_info="is a template for functions."
    local f_min_args=1 f_max_args=1 f_ver="0.1"

    local name="$(make_fn_name $f_name)"
    local usage="$(make_fn_usage $f_name $f_args $f_args_opt $f_switches)"
    local info="$(make_fn_info $f_name $f_info)\n$usage"
    local help=""
    local version="$(make_fn_version $f_name $f_ver)"
    local args="$(check_fn_args $f_min_args $f_max_args $#)"

    
    [[ $1 == "--help" ]] && printf "$help" && shift
    [[ $1 == "--version" ]] && printf "$version" && shift
    [[ $1 == --* ]] && log::error "$name: unknown switch $1" && return 1
    [[ $args != "ok" ]] && log::error "$name: $args" && printf $fusage && return 1
### main function
    echo $1
}

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
    local args=$(check_fn_args $f_min_args $f_max_args $#)
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == "--version" ]] && printf "$fver" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
### main function
    echo $1
}