#!/bin/zsh
#
# Development functions

# Start a local HTTP server in the specified directory
# Usage: www <directory> 
function www() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Start a local HTTP server in the specified directory"
    f[help]="If no directory is specified, the current directory will be used."
    f[help]+="\nDefault port is 8080. To supress auto-open, use -n."
    f[args_optional]="directory port"
    f[opts]="debug help info noopen version"
    f[version]="0.35"; f[date]="2025-05-10"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    local cache="-c-1" # disable caching
    [[ $o[n] != 1 ]] && local open="-o"
    if [[ -n "$a[2]" ]]; then
        local port="$a[2]"
    else 
        local port=8080 # default port
    fi

    if [[ "$(isinstalled http-server)" -eq 0 ]]; then
        log::error "http-server is not installed."
        log::info "You can install http-server with: install-httpserver"
        return 127
    fi
    local dir
    if [[ -z "$a[1]" ]]; then
        dir="$(pwd)"
    else
        dir="$(fulldirpath $a[1])"
    fi
    echo "Dir: $dir"
    if [[ $? -eq 0 ]]; then
        if [[ $(isdirservable $dir) -eq 0 ]]; then
            log::error "$dir is empty or contains only hidden files."
            return 1
        else
            http-server "$dir" "$cache" "$open" "-p" "$port"
        fi
    else
        log::error "Folder $a[1] does not exist."
        return 1
    fi
}

