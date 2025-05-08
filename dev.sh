#!/bin/zsh
#
# Development functions

# Start a local HTTP server in the specified directory
# Usage: www <directory> 
function www() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Start a local HTTP server in the specified directory"
    f[help]="If no directory is specified, the current directory will be used."
    f[args_optional]="directory"
    f[opts]="debug help info version"
    f[version]="0.3"; f[date]="2025-05-09"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    if [[ "$(isinstalled http-server)" -eq 0 ]]; then
        log::error "http-server is not installed."
        log::info "You can install http-server with: install-httpserver"
        return 127
    fi
    local dir
    if [[ -z "$1" ]]; then
        dir="$(pwd)"
    else
        dir="$(fulldirpath $1)"
    fi
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