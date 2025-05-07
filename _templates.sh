#!/bin/zsh
#
# This is an ARCHIVE.

### FUNCTION TEMPLATE

function _fn_tpl_short() {
### function properties
    local f_name="_fn_tpl_short"
    local f_args="agrument1 argument2" f_args_opt="agrument3"
    local f_info="is a template for functions."
    local f_min_args=1 f_max_args=1
### function strings
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches" compact)"
    local info="$(make_fn_info $header $usage "" compact)" iserror=0
### function args and switches
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == -* ]] && log::error "$name: unknown switch $1" && iserror=1
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" ]] && log::error "$f_name: $args" && iserror=1
    [[ $iserror -ne 0 ]] && echo $usage && return 2
### main function
    echo "This is the output of the $name function."
}

function _fn_tpl() {
### function properties
    local f_name="_fn_tpl"
    local f_file="lib/_templates.sh"
    local f_args="agrument1 argument2"
    local f_args_opt="agrument3"
    local f_switches="info help version"
    local f_info="is a template for functions."
    local f_help="" # content of help
    local f_min_args=1 f_max_args=1
    local f_author="gh/barabasz" f_ver="0.11" f_date="2025-05-06"
### function strings
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches")"
    local errinf="$(make_fn_errinf $name "$f_switches" $f_file)"
    local version="$(make_fn_version $name $f_ver)"
    local footer="$(make_fn_footer $f_author $f_date $version)"
    local info="$(make_fn_info $header $usage $footer)"
    local help="$(make_fn_help $info $f_help)"
    local iserror=0
### function args and switches
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == "--help" || $1 == "-h" ]] && echo "$help" && return 0
    [[ $1 == "--version" || $1 == "-v" ]] && echo "$version" && return 0
    [[ $1 == "--switch" || $1 == "-s" ]] && echo "SWITCH" && shift # example
    [[ $1 == -* ]] && log::error "$name: unknown switch $1" && iserror=1
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" && iserror -eq 0 ]] && log::error "$f_name: $args" && iserror=1
    [[ $iserror -ne 0 ]] && echo $errinf && return 1
### main function
    echo "This is the output of the $name function."
}

