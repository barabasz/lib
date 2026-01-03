#!/usr/bin/env zsh
#
# Filesystem related functions
# zsh-specific functions - requires zsh, will not work in bash

# Check if path exists and is a regular file
is_file() {
    [[ $# -eq 1 && -f "$1" ]]
}

# Check if path exists and is a directory
is_dir() {
    [[ $# -eq 1 && -d "$1" ]]
}

# Check if path exists and is a symbolic link
is_link() {
    [[ $# -eq 1 && -L "$1" ]]
}




# Make directory and change to it
mdcd() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: mdcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Detects the type of file system object for a given path.
# Usage: ftype <path>
# Returns object type or 'not_found'
ftype() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Detects the type of file system object for a given path."
    f[args_required]="path"
    f[opts]="debug help info long version"
    f[version]="0.4"; f[date]="2025-05-15"
    f[help]="Returns type with error code 0 (or 1 for not_found):\n"
    f[help]+=$(ftypeinfo)
    fn_make2 "$@" && [[ -n "$f[return]" ]] && return "$f[return]"
### main function
    t[path_org]="$a[1]"
    t[path_abs]="$t[path_org]:a" # :a does not follow symlinks
    # check if file exists
    if [[ ! -e "$t[path_org]" && ! -L "$t[path_org]" ]]; then
        t[type]="not_found"
        t[not_found]="1"
    fi
    # symlink handling
    if [[ -L "$t[path_org]" && -z "$t[type]" ]]; then
        t[link]="1"
        t[link_dst]=$(readlink "$t[path_org]")
        # Broken symlink
        if [[ ! -e "$t[path_org]" ]]; then
            t[type]="link_broken"
        elif [[ -d "$t[path_org]" ]]; then
            t[type]="link_dir"
        elif [[ -f "$t[path_org]" ]]; then
            t[type]="link_file"
        elif [[ -b "$t[path_org]" ]]; then
            t[type]="link_block"
        elif [[ -c "$t[path_org]" ]]; then
            t[type]="link_char"
        elif [[ -p "$t[path_org]" ]]; then
            t[type]="link_pipe"
        elif [[ -S "$t[path_org]" ]]; then
            t[type]="link_socket"
        else
            t[type]="link_other"
        fi
    fi
    # regular file handling
    if [[ -z "$t[type]" ]]; then
        t[link]="0"
        if [[ -d "$t[path_abs]" ]]; then
            t[type]="dir"
        elif [[ -f "$t[path_abs]" ]]; then
            t[type]="file"
        elif [[ -b "$t[path_abs]" ]]; then
            t[type]="block"
        elif [[ -c "$t[path_abs]" ]]; then
            t[type]="char"
        elif [[ -p "$t[path_abs]" ]]; then
            t[type]="pipe"
        elif [[ -S "$t[path_abs]" ]]; then
            t[type]="socket"
        else
            t[type]="other"
        fi
    fi
    # get type information
    t[type_info]=$(ftypeinfo "$t[type]")
    case $t[type] in
        not_found) s[type_info]="$c$t[path_abs]$x $t[type_info]";;
        other) s[type_info]="$c$t[path_abs]$x is an $t[type_info]";;
        *) s[type_info]="$c$t[path_abs]$x is a $t[type_info]";;
    esac
    if [[ $t[link] == 1 ]]; then
        if [[ $t[type] == "link_broken" ]]; then
            s[type_info]+=" to "
        else
            s[type_info]+=" "
        fi
        s[type_info]+="$c$t[link_dst]$x"
    fi
    # debug output
    [[ $o[d] == 1 ]] && fn_debug
    # print type
    if [[ $o[l] == 1 ]]; then
        echo "$s[type_info]"
    else
        echo "$t[type]"
    fi
    # return error code
    if [[ "$t[not_found]" ]]; then
        return 1
    else
        return 0
    fi
}

# Companion function for ftype to get file type information
# Usage: ftypeinfo <type>
# Returns: description of the file type or an empty string if not found
function ftypeinfo() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    local y="$(ansi yellow)"; local x="$(ansi reset)"
    f[info]="Companion function for ftype() to get file type information."
    f[help]="Returns description of the file type or an empty string if not found."
    f[help]+="\nWithout arguments, it returns a list of all file types."
    f[args_optional]="ftype_type"
    f[opts]="debug help info version"
    f[version]="0.1"; f[date]="2025-05-09"
    fn_make2 "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
### main function
    local type="$a[1]"
    local -A types
    # fill array with types
    types[not_found]="does not exist"
    types[link_broken]="broken symbolic link"
    types[link_dir]="symbolic link to a directory"
    types[link_file]="symbolic link to a regular file"
    types[link_block]="symbolic link to a block special file"
    types[link_char]="symbolic link to a character special file"
    types[link_pipe]="symbolic link to a named pipe (FIFO)"
    types[link_socket]="symbolic link to a socket"
    types[link_other]="symbolic link to another kind of file"
    types[dir]="regular directory"
    types[file]="regular file"
    types[block]="block special file (device)"
    types[char]="character special file (device)"
    types[pipe]="named pipe (FIFO)"
    types[socket]="socket"
    types[other]="other type of file"
    # list all types
    if [[ -z $type ]]; then
        for key value in ${(kv)types}; do
            echo "${(r:10:)key} $y -> $x $value"
        done
        return 0
    fi | sort
    # check if type is in the array
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
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Removes file or directory only if it is a symbolic link."
    f[args_required]="file_or_dir"
    f[opts]="debug help info version"
    f[version]="0.6"; f[date]="2025-05-07"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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

# Create symbolic link safely
# Usage: lns source target
lns() {
    # Validate: exactly two arguments required
    if (( $# != 2 )); then
        print_error "Usage: lns source target"
        return 1
    fi
    
    local source=${1:a}
    local target=${2:a}
    local target_parent_dir=${target:h}
    
    # Validate: source must exist
    if [[ ! -e $source ]]; then
        print_error "Source does not exist: $source"
        return 1
    fi
    
    # Validate: source and target must be different
    if [[ $source == $target ]]; then
        print_error "Source and target are the same: $source"
        return 1
    fi
    
    # Create target's parent directory if needed
    if [[ ! -d $target_parent_dir ]]; then
        mkdir -p $target_parent_dir
    fi
    
    # Validate: target's parent directory must be writable
    if [[ ! -w $target_parent_dir ]]; then
        print_error "Cannot write to directory: $target_parent_dir"
        return 1
    fi
    
    # Handle existing target
    if [[ -L $target ]]; then
        # Target is a symlink - check if it already points to source
        local current=${target:A}
        if [[ $current == $source ]]; then
            return 0  # Already correct, nothing to do
        else
            rm $target  # Points elsewhere, remove and recreate
        fi
    elif [[ -e $target ]]; then
        # Target is a real file/directory - backup before replacing
        mv $target ${target}.bak
    fi
    
    ln -s $source $target
}

# Creates a symbolic link for configuration dirs using lns
# If the first argument is -p, it will use GHPRIVDIR instead of GHCONFDIR
function lnsconfdir() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Creates a symbolic link for configuration dirs using lns."
    f[help]="If the -p optionis used, it will use GHPRIVDIR instead of GHCONFDIR"
    f[args_required]="directory"
    f[opts]="debug help info version example"
    f[version]="0.15"; f[date]="2025-05-06"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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

# utype: universal ultra-fast type detector for bash and zsh
# Returns (stdout + exit 0): one of: file | alias | function | keyword | builtin
# Returns (stdout + exit 1): notfound (command does not exist)
# Returns (no stdout, exit 1): usage / internal error
utype() {
    [[ $# -eq 1 ]] || return 1
    local cmd=$1

    if [[ -n $BASH_VERSION ]]; then
        local result=$(type -t -- "$cmd" 2>/dev/null)
        if [[ -n $result ]]; then
            printf '%s\n' "$result"
            return 0
        else
            printf 'notfound\n'
            return 1
        fi
    elif [[ -n $ZSH_VERSION ]]; then
        case $(whence -w -- "$cmd" 2>/dev/null) in
            (*: alias) printf 'alias\n'; return 0 ;;
            (*: function) printf 'function\n'; return 0 ;;
            (*: builtin) printf 'builtin\n'; return 0 ;;
            (*: command) printf 'file\n'; return 0 ;;
            (*: hashed) printf 'file\n'; return 0 ;;
            (*: reserved) printf 'keyword\n'; return 0 ;;
            (*) printf 'notfound\n'; return 1 ;;
        esac
    fi

    return 1
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

