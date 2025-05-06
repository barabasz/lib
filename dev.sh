#!/bin/zsh
#
# Development functions

# Start a local HTTP server in the specified directory
# Usage: www <directory> 
function www() {
### function properties
    local f_name="www" f_file="lib/dev.sh"
    local f_args="directory"
    local f_info="starts a local HTTP server in the specified directory"
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
    [[ $args != "ok" && iserror -eq 0 ]] && log::error "$f_name: $args" && iserror=1
    [[ $iserror -ne 0 ]] && echo $usage && return 1
### main function
    if [[ "$(isinstalled http-server)" -eq 0 ]]; then
        log::error "http-server is not installed."
        log::info "You can install http-server with: install-httpserver"
        return 127
    fi
    local dir
    dir="$(fulldirpath $1)"
    if [[ $? -eq 0 ]]; then
        if [[ $(isdirservable $dir) -eq 0 ]]; then
            log::error "$dir is empty or contains only hidden files."
            return 1
        else
            http-server "$dir" -c-1 -o
        fi
    else
        log::error "Folder $1 does not exist."
        return 1
    fi
}