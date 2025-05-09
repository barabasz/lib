#!/bin/zsh
#
# Better versions of some functions
# Unless otherwise noted, they work with both bash and zsh

# ftype()
# Detects the type of file system object for a given path.
# Usage: ftype <path>
# Prints one of:
# not_found      - destination does not exist or no input (returns 1)
# unreadable     - file exists but cannot be tested
# link_broken    - broken symbolic link
# link_dir       - symlink to directory
# link_file      - symlink to regular file
# link_block     - symlink to block special file
# link_char      - symlink to character special file
# link_pipe      - symlink to named pipe (FIFO)
# link_socket    - symlink to socket
# link_other     - symlink to any other file
# hardlink       - hardlink to a file (link count > 1)
# dir            - regular directory
# file           - regular file
# block          - block special file
# char           - character special file
# pipe           - named pipe (FIFO)
# socket         - socket
# other          - any other file
# Returns 0 for all except not_found or unreadable (returns 1)

ftype() {
    local orig_path="$1"
    local abs_path nlinks

    if [[ "$orig_path" == "--help" ]]; then
        echo "Usage: ftype <path>"
        return 0
    fi

    if [[ -z "$orig_path" ]]; then
        echo "not_found"
        return 1
    fi

    # Existence (even if symlink)
    if [[ ! -e "$orig_path" && ! -L "$orig_path" ]]; then
        echo "not_found"
        return 1
    fi

    # Symlink handling
    if [[ -L "$orig_path" ]]; then
        if [[ ! -e "$orig_path" ]]; then
            echo "link_broken"
            return 0
        fi

        if [[ -d "$orig_path" ]]; then
            echo "link_dir"
        elif [[ -f "$orig_path" ]]; then
            echo "link_file"
        elif [[ -b "$orig_path" ]]; then
            echo "link_block"
        elif [[ -c "$orig_path" ]]; then
            echo "link_char"
        elif [[ -p "$orig_path" ]]; then
            echo "link_pipe"
        elif [[ -S "$orig_path" ]]; then
            echo "link_socket"
        else
            echo "link_other"
        fi
        return 0
    fi

    abs_path="${orig_path:A}"

    if [[ -d "$abs_path" ]]; then
        echo "dir"
    elif [[ -f "$abs_path" ]]; then
        nlinks=$(stat -c %h -- "$abs_path" 2>/dev/null)
        if [[ -z "$nlinks" ]]; then
            nlinks=$(stat -f %l -- "$abs_path" 2>/dev/null)
        fi
        if [[ -z "$nlinks" ]]; then
            echo "unreadable"
            return 1
        fi
        if [[ "$nlinks" -gt 1 ]]; then
            echo "hardlink"
        else
            echo "file"
        fi
    elif [[ -b "$abs_path" ]]; then
        echo "block"
    elif [[ -c "$abs_path" ]]; then
        echo "char"
    elif [[ -p "$abs_path" ]]; then
        echo "pipe"
    elif [[ -S "$abs_path" ]]; then
        echo "socket"
    else
        echo "other"
    fi
    return 0
}

# Companion function for ftype to get file type information
# Usage: ftypeinfo <type>
# Returns: description of the file type or an empty string if not found
function ftypeinfo() {
    local -A f; local -A o; local -A a; local -A s
    local y="$(ansi yellow)"; local r="$(ansi reset)"
    f[info]="Companion function for ftype() to get file type information."
    f[help]="Returns description of the file type or an empty string if not found."
    f[help]+="\nWithout arguments, it returns a list of all file types."
    f[args_optional]="ftype_type"
    f[opts]="debug help info version"
    f[version]="0.1"; f[date]="2025-05-09"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    local type="$1"
    local -A types
    # fill array with types
    types[not_found]="destination does not exist"
    types[unreadable]="file exists but cannot be tested (permission denied or stat error)"
    types[link_broken]="broken symbolic link"
    types[link_dir]="symbolic link to a directory"
    types[link_file]="symbolic link to a regular file"
    types[link_block]="symbolic link to a block special file"
    types[link_char]="symbolic link to a character special file"
    types[link_pipe]="symbolic link to a named pipe (FIFO)"
    types[link_socket]="symbolic link to a socket"
    types[link_other]="symbolic link to another kind of file"
    types[hardlink]="regular file with more than one hard link"
    types[dir]="regular directory"
    types[file]="regular file"
    types[block]="block special file (device)"
    types[char]="character special file (device)"
    types[pipe]="named pipe (FIFO)"
    types[socket]="socket"
    types[other]="other type of file"

    if [[ -z $type ]]; then
        for key value in ${(kv)types}; do
            echo "${(r:10:)key} $y -> $r $value"
        done
        return 0
    fi | sort

    if [[ -n ${types[$type]-} ]]; then
        echo "${types[$type]}"
        return 0
    else
        echo ""
        return 1
    fi
}


# Function to remove file or directory only if it is a symbolic link
function rmln() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Removes file or directory only if it is a symbolic link."
    f[args_required]="file_or_dir"
    f[opts]="debug help info version"
    f[version]="0.6"; f[date]="2025-05-07"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
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
                log::ok "$s[name]: symbolic link $c$file_full_path$r removed.\n"
            else
                log::error "$s[name]: failed to remove symbolic link $c$file_full_path$r.\n"
                return 1
            fi
        else
            log::error "$s[name]: $c$file_full_path$r is not a symbolic link.\n"
            return 1
        fi
    fi
}

# Better ln command for creating symbolic links
function lns() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="A better ln command for creating symbolic links."
    f[help]="It creates a symbolic link only if such does not yet exist."
    f[help]+="\nSource and target may be provided as relative or absolute paths."
    f[help]+="\nOption '-f' (force) removes the existing link/file/directory."
    f[args_required]="existing_target new_link"
    f[opts]="debug force help info test version"
    f[version]="0.35"; f[date]="2025-05-09"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    # target (existing file or directory)
    f[target_input]="$1"
    f[target]="${f[target_input]:A}"
    f[target_parent]="$f[target:h]"
    f[target_name]="$f[target:t]"
    f[target_parent_readable]=$(isdirreadable "$f[target_parent]")
    # link (new symbolic link)
    f[link_input]="$2"
    f[link]="${f[link_input]:A}"
    f[link_parent]="$f[link:h]"
    f[link_parent_writable]=$(isdirwritable "$f[link_parent]")
    f[link_name]="$f[link:t]"
    f[target_type]=$(ftype "$f[target]")
    f[target_type_info]=$(ftypeinfo "$f[target_type]")




    # get absolute paths
    local src="${1:A}"
    local dst="${2:A}"
    # get parent dirs
    local src_dir="$(dirname "$src")"
    local dst_dir="$(dirname "$dst")"
    # get options
    local debug=$o[d]
    local force=$o[f]
    local test=$o[t]
    # prepare strings
    local dst_c="${cyan}$dst${reset}"
    local src_c="${cyan}$src${reset}"
    local src_dir_c="${cyan}$src_dir${reset}"
    local dst_dir_c="${cyan}$dst_dir${reset}"
    local arr="${yellowi}→${reset}"

    # Print debug information if debug is enabled
    if [[ $debug -eq 1 ]]; then
        log::info "$s[name]: source: \t$src_c"
        log::info "$s[name]: source dir: \t$src_dir"
        log::info "$s[name]: target: \t$dst_c"
        log::info "$s[name]: target dir: \t$dst_dir"
    fi

    # Check if the destination exists
    if [[ ! -e "$dst" ]]; then
        log::error "$s[name]: target $dst_c does not exist."
        return 1
    fi

    # Check if the source exists
    if [[ -d "$src" ]]; then
        log::error "$s[name]: source $src_c already exists."
        log::info "$src_c is a directory."
        return 1
    elif [[ -f "$src" ]]; then
        log::error "$s[name]: source $src_c already exists."
        log::info "$src_c is a file."
        return 1
    elif [[ -L "$src" ]]; then
        log::error "$s[name]: source $src_c already exists."
        log::info "$src_c is a symbolic link."
        return 1
    fi



    # Check if the destination is different from the source
    if [[ "$dst" == "$src" ]]; then
        log::error "$s[name]: target and source cannot be the same."
        return 1
    fi

    # Check if the destination is readable
    if [[ ! -r "$dst" ]]; then
        log::error "$s[name]: target $dst_c is not readable."
        return 1
    fi

    # Check if the destination is a folder or file
    if [[ ! -d "$dst" ]] && [[ ! -f "$dst" ]]; then
        log::error "$s[name]: target $dst_c is neither a directory nor a file."
        return 1
    fi

    # Check if the current process can write to the source's folder
    if [[ ! -w "$src_dir" ]]; then
        log::error "$s[name]: cannot write to the source's folder $src_dir_c"
        return 1
    fi

    # Check if exactly such a symbolic link does not already exist
    if [[ -L "$src" ]] && [[ "$(readlink "$src")" == "$dst" ]]; then
        log::info "$s[name]: symlink $src_c $arr $dst_c already exists."
        return 0
    fi

    # Check if source and target are pointing to the same file
    if [[ "$src" == $(realpath "$dst") ]]; then
        log::error "$s[name]: source and target are the same file."
        log::info "$s[name]: check for folder symlinks in file paths."
        return 1
    fi

    # Remove the existing source (file, folder, or wrong symbolic link)
    if [[ -e "$src" ]]; then
        if [[ $force -eq 1 ]]; then
            rm -rf "$src"
            if [[ $? -ne 0 ]]; then
                log::error "$s[name]: failed while rmoving $src_c (error rissed by rm)."
                return 1
            else
                log::info "$s[name]: removed existing source $src_c."
            fi
        else
            log::error "$s[name]: source $src_c already exists."
            log::info "$s[name]: to override use the $purple--force$reset switch."
            return 1
        fi
    fi

    # Create the symbolic link
    if [[ $test -eq 1 ]]; then
        log::info "$s[name]: test mode: not creating symbolic link."
        return 0
    else
        ln -s "$dst" "$src"
        if [[ $? != 0 ]]; then
            log::error "$s[name]: failed to create symbolic link (error rissed by ln).\n"
            return 1
        else
            log::info "$s[name]: symbolic link $src_c $arr $dst_c created.\n"
            return 0
        fi
    fi
}

# Creates a symbolic link for configuration dirs using lns
# If the first argument is -p, it will use GHPRIVDIR instead of GHCONFDIR
function lnsconfdir() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Creates a symbolic link for configuration dirs using lns."
    f[help]="If the -p optionis used, it will use GHPRIVDIR instead of GHCONFDIR"
    f[args_required]="directory"
    f[opts]="debug help info version example"
    f[version]="0.15"; f[date]="2025-05-06"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    [[ $o[p] == 1 ]] && local priv=1
    [[ -z $1 ]] && log::error "No config directory provided" && return 1
    [[ -z $CONFDIR ]] && log::error "CONFDIR is not set" && return 1
    if [[ $priv -eq 1 ]]; then
        [[ -z $GHPRIVDIR ]] && log::error "GHPRIVDIR is not set" && return 1
        lns "$CONFDIR/$1" "$GHPRIVDIR/$1"
    else
        [[ -z $GHCONFDIR ]] && log::error "GHCONFDIR is not set" && return 1
        lns "$CONFDIR/$1" "$GHCONFDIR/$1"
    fi
}

# Universal better type command for bash and zsh
# returns: 'file', 'alias', 'function', 'keyword', 'builtin' or 'not found'
function utype() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Universal better type command for bash and zsh."
    f[help]="Returns: 'file', 'alias', 'function', 'keyword', 'builtin' or 'not found'"
    f[args_required]="command"
    f[opts]="debug help info version"
    f[version]="0.2"; f[date]="2025-05-06"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    local output
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

# Function that returns full path of target
# Usage: fullpath <target>
# Returns: full path of target or "notfound" if the target doesn't exist
getfullpath() {
    local target="$1"
    if [[ ! -e "$target" ]]; then
        printf "notfound"
        return 1
    fi
    local abs_path="${target:A}"
    abs_path="${abs_path%/}"
    printf "%s" "$abs_path"
    return 0
}