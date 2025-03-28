#!/bin/zsh
#
# Better versions of some functions
# Unless otherwise noted, they work with both bash and zsh

# Function to remover file or directory only if it is a symbolic link
function rmln() {
### function properties
    local f_name="rmln" f_file="lib/better.sh"
    local f_args="file_or_dir" f_switches="info"
    local f_info="removes a symbolic link."
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
    local file="$1" c="${cyan}" r="${reset}"
    if [[ ! -e $file ]]; then
        log::error "$f_name: $c$file$r does not exist.\n"
        return 1
    else
        local file_full_path="$(pwd)/$file"
        if [[ -L $file ]]; then
            rm -f $file
            if [[ $? -eq 0 ]]; then
                log::ok "$name: symbolic link $c$file_full_path$r removed.\n"
            else
                log::error "$name: failed to remove symbolic link $c$file_full_path$r.\n"
                return 1
            fi
        else
            log::error "$name: $c$file_full_path$r is not a symbolic link.\n"
            return 1
        fi
    fi
}

# Better ln command for creating symbolic links
function lns() {
### function properties
    local f_name="lns" f_file="better/_templates.sh"
    local f_args="destination source"
    local f_switches="force info"
    local f_info="creates a symbolic link if such does not yet exist."
    local f_min_args=2 f_max_args=2
### function strings
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches" compact)"
    local info="$(make_fn_info $header $usage "" compact)"
### function args and switches
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == "--force" || $1 == "-f" ]] && local force=1 && shift
    [[ $1 == -* ]] && log::error "$name: unknown switch $purple$1$reset" && return 1
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" ]] && log::error "$f_name: $args" && echo $usage && return 1
### main
    local dst="$1"
    local src="$2"
    local dst_c="${cyan}$dst${reset}"
    local src_c="${cyan}$src${reset}"
    local src_dir="$(dirname "$src")"
    local src_dir_c="${cyan}$src_dir${reset}"
    local arr="${yellowi}→${reset}"

    # Check if both the destination and source are provided as absolute paths.
    if [[ "$dst" != /* ]]; then
        log::error "$name: the destination $dst_c must be an absolute path."
        return 1
    fi
    if [[ "$src" != /* ]]; then
        log::error "$name: the source $src_c must be an absolute path."
        return 1
    fi

    # Check if the destination is different from the source
    if [[ "$dst" == "$src" ]]; then
        log::error "$name: destination and source cannot be the same."
        return 1
    fi

    # Check if the destination exists
    if [[ ! -e "$dst" ]]; then
        log::error "$name: destination $dst_c does not exist."
        return 1
    fi

    # Check if the destination is readable
    if [[ ! -r "$dst" ]]; then
        log::error "$name: destination $dst_c is not readable."
        return 1
    fi

    # Check if the destination is a folder or file
    if [[ ! -d "$dst" ]] && [[ ! -f "$dst" ]]; then
        log::error "$name: destination $dst_c is neither a directory nor a file."
        return 1
    fi

    # Check if the current process can write to the source's folder
    if [[ ! -w "$src_dir" ]]; then
        log::error "$name: cannot write to the source's folder $src_dir_c"
        return 1
    fi

    # Check if exactly such a symbolic link does not already exist
    if [[ -L "$src" ]] && [[ "$(readlink "$src")" == "$dst" ]]; then
        log::info "$name: symlink $src_c $arr $dst_c already exists."
        return 0
    fi

    # Check if source and target are pointing to the same file
    if [[ $(realpath "$src") == $(realpath "$dst") ]]; then
        log::error "$name: source and destination are the same file."
        log::info "$name: check for folder symlinks in file paths."
        return 1
    fi

    # Remove the existing source (file, folder, or wrong symbolic link)
    if [[ -e "$src" ]]; then
        if [[ $force -eq 1 ]]; then
            rm -rf "$src"
            if [[ $? -ne 0 ]]; then
                log::error "$name: failed while rmoving $src_c (error rissed by rm)."
                return 1
            else
                log::info "$name: removed existing source $src_c."
            fi
        else
            log::error "$name: source $src_c already exists."
            log::info "$name: to override use the $purple--force$reset switch."
            return 1
        fi
    fi

    # Create the symbolic link
    ln -s "$dst" "$src"
    if [[ $? != 0 ]]; then
        log::error "$name: failed to create symbolic link (error rissed by ln).\n"
        return 1
    else
        log::info "$name: symbolic link $src_c $arr $dst_c created.\n"
        return 0
    fi
}

# Creates a symbolic link for configuration dirs using lns
function lnsconfdir() {
    [[ -z $CONFDIR ]] && log::error "CONFDIR is not set" && return 1
    [[ -z $GHCONFDIR ]] && log::error "GHCONFDIR is not set" && return 1
    [[ -z $1 ]] && log::error "No directory provided" && return 1
    lns "$GHCONFDIR/$1" "$CONFDIR/$1"
}
alias makeconfln=lnsconfdir

# Universal better type command for bash and zsh
# returns: 'file', 'alias', 'function', 'keyword', 'builtin' or 'not found'
function utype() {
    # function properties
    local fargs="<command>"
    local minargs=0
    local maxargs=1
    # argument check
    local thisf="${funcstack[1]}"
    local error="${redi}$thisf error:${reset}"
    local usage=$(make_fn_usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(check_fn_args $minargs $maxargs $#)
    [[ $args != "ok" ]] && printf "$error $args\n$usage\n" && return 1

    if [[ $(shellname) == 'bash' ]]; then
        output=$(type -t $1)
        if [[ -z $output ]]; then
            echo "not found"
            return 1
        fi
    elif [[ $(shellname) == 'zsh' ]]; then
        tp=$(type $1)
        if [[ $(echo $tp | \grep -o 'not found') ]]; then
            echo "not found"
            return 1
        elif [[ $(echo $tp | \grep -o 'is /') ]]; then
            output='file'
        elif [[ $(echo $tp | \grep -o 'alias') ]]; then
            output='alias'
        elif [[ $(echo $tp | \grep -o 'shell function') ]]; then
            output='function'
        elif [[ $(echo $tp | \grep -o 'reserved') ]]; then
            output='keyword'
        elif [[ $(echo $tp | \grep -o 'builtin') ]]; then
            output='builtin'
        fi
    else
        echo "utype: unsupported shell"
        return 1
    fi

    echo $output
}

# Universal better which command for bash and zsh
function uwhich() {
    # function properties
    local fargs="<command>"
    local minargs=0
    local maxargs=1
    # argument check
    local thisf="${funcstack[1]}"
    local error="${redi}$thisf error:${reset}"
    local usage=$(make_fn_usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(check_fn_args $minargs $maxargs $#)
    [[ $args != "ok" ]] && printf "$error $args\n$usage\n" && return 1

    local type=$(utype $1)
    if [[ $type == "file" ]]; then
        echo $(which $1)
    elif [[ $type == "alias" ]]; then
        if [[ $(shellname) = "zsh" ]]; then
            echo $(whence -p $1)
        else
            echo $(which $1)
        fi
    elif [[ $type == "not found" ]]; then
        echo "${yellow}$1${reset} $type"
        return 1
    else
        echo "${yellow}$1${reset} is a ${green}$type${reset}"
        return 1
    fi
}

# Finds the file where a function is defined
# Returns absolute path, 'not a function' or 'not found'
function wheref() {
    ### function header
    # function properties
    local f_name="wheref"
    local f_args="<function_name>"
    local f_switches=("--help" "--version")
    local f_info="finds the file where a function is defined."
    local f_ver="0.1"
    local f_min_args=1
    local f_max_args=1
    # ansi colors
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi purple) r=$(ansi reset)
    # strings
    local fname="$g${f_name}$r"
    local fargs="$c${f_args}$r"
    [[ -n $f_switches ]] && fargs+=" ${p}[<switches>...]${r}"
    local finfo="$fname $f_info\n"
    local fusage="Usage: $fname $fargs\n"
    [[ -n $f_switches ]] && fusage="${fusage}Switches: ${p}$f_switches${r}\n"
    local fver="$fname version $f_ver\n"
    # argument check
    local args=$(check_fn_args $f_min_args $f_max_args $#)
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    # handle switches
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == "--version" ]] && printf "$fver" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
    ### end of function header

    ### main function

    # chech if function name is valid
    if [[ $(check_function_name $1) -eq 0 ]]; then
        log::error "$f_name: function name must start with a letter or an underscore."
        return 1
    fi
    echo $1
}