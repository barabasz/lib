#!/bin/zsh

#
# File: ansi.sh
#

function ansi::info() {
    \cat <<EOF
$(ansi bold yellow)ANSI escape code warper$(ansi reset)
$(ansi bold)Usage$(ansi reset):
  $(ansi yellow)ansi$(ansi reset) help                 show help
  $(ansi yellow)ansi$(ansi reset) info                 show this info
  $(ansi yellow)ansi$(ansi reset) example              show examples
  $(ansi yellow)ansi$(ansi reset) <style>              set style
  $(ansi yellow)ansi$(ansi reset) <foreground>         set foreground color
  $(ansi yellow)ansi$(ansi reset) bg <background>      set background color
  $(ansi yellow)ansi$(ansi reset) reset [option]       reset style
  $(ansi yellow)ansi$(ansi reset) show <command>       only show ANSI code
EOF
}
function ansi::help() {
    ansi::info
    \cat <<EOF
$(ansi bold)Expected arguments order$(ansi reset):
  $(ansi yellow)ansi$(ansi reset) [style] [[bright] <foreground>] [bg <background>] [reset [style]]
$(ansi bold)Style$(ansi reset):
  style:                    ansi $(ansi bold purple)<style>$(ansi reset)
$(ansi bold)Foreground$(ansi reset):
  color:                    $(echo "\e[33mansi\e[39m") $(ansi bold cyan)<color>$(ansi reset)
  bright color:             $(echo "\e[33mansi\e[39m") bright $(ansi bold cyan)<color>$(ansi reset)
  8-bit color:              $(echo "\e[33mansi\e[39m") 8bit {0..255}
  rgb color:                $(echo "\e[33mansi\e[39m") rgb {0..255} {0..255} {0..255}
  default color:            $(echo "\e[33mansi\e[39m") default
$(ansi bold)Background$(ansi reset):
  color:                    $(echo "\e[33mansi\e[39m") bg $(ansi bold cyan)<color>$(ansi reset)
  8-bit color:              $(echo "\e[33mansi\e[39m") bg 8bit {0..255}
  rgb color:                $(echo "\e[33mansi\e[39m") bg rgb {0..255} {0..255} {0..255}
  default color:            $(echo "\e[33mansi\e[39m") bg default
$(ansi bold)Reset$(ansi reset):
  reset style:              $(echo "\e[33mansi\e[39m") reset $(ansi bold purple)<style>$(ansi reset)
  reset all:                $(echo "\e[33mansi\e[39m") reset
$(ansi bold cyan)Colors$(ansi reset):
  black     red     yellow
  white     green   magenta = purple
  default   blue    cyan
$(ansi bold purple)Styles$(ansi reset):
  bold      underline      dim
  italic    strikethrough  blink
  reverse   overline       invisible
$(ansi bold)Examples$(ansi reset):
  printf "\$(ansi bold red)bold red\$(ansi reset) reset"
  echo "\$(ansi yellow)yellow \$(ansi reverse)reverse\$(ansi reset reverse) normal\$(ansi default) default"
EOF
}
function ansi::example() {
    ansi::info
    \cat <<EOF
$(ansi bold)Styles$(ansi reset):
  • $(ansi bold)bold$(ansi reset bold)
  • $(ansi italic)italic$(ansi reset italic)
  • $(ansi reverse)reverse$(ansi reset reverse)
  • $(ansi underline)underline$(ansi reset underline)
  • $(ansi strikethrough)strikethrough$(ansi reset strikethrough)
  • $(ansi overline)overline$(ansi reset overline)
  • $(ansi dim)dim$(ansi reset dim)
  • $(ansi blink)blink$(ansi reset blink)
  • $(ansi invisible)red$(ansi reset invisible) (invisible)
  • $(ansi default)default$(ansi reset)
$(ansi bold)Foreground$(ansi reset):
  • $(ansi red)red$(ansi default)
  • $(ansi bright red)bright red $(ansi default)
  • $(ansi 8bit 196)8bit 196$(ansi default)
  • $(ansi rgb 255 0 0)rgb 255 0 0$(ansi default)
$(ansi bold)Background$(ansi reset)
  • $(ansi bg green)bg green$(ansi bg default)
  • $(ansi bg 8bit 196)bg 8bit 196$(ansi bg default)
  • $(ansi bg rgb 0 0 255)bg rgb 0 0 255$(ansi bg default)
$(ansi bold)Compound expression$(ansi reset):
  • $(ansi bold yellow)bold yellow$(ansi reset)
  • $(ansi italic cyan)italic cyan $(ansi reset)
  • $(ansi bg rgb 0 255 0 red)bg rgb 0 255 red$(ansi reset)
  • $(ansi italic yellow bg blue)italic yellow bg blue$(ansi reset)
EOF
}
function ansi::style() {
    case "$1" in
    regular) mod=0 ;;
    bold) mod=1 ;;
    dim) mod=2 ;;
    italic) mod=3 ;;
    underline) mod=4 ;;
    dunderline) mod=21 ;;
    blink) mod=5 ;;
    fastblink) mod=6 ;;
    reverse) mod=7 ;;
    invisible) mod=8 ;;
    strikethrough) mod=9 ;;
    overline) mod=53 ;;
    esac
}
function ansi::reset() {
    case "$1" in
    all) mod=0 ;;
    bold | dim) mod=22 ;;
    italic) mod=23 ;;
    underline) mod=24 ;;
    blink) mod=25 ;;
    fastblink) mod=26 ;;
    reverse) mod=27 ;;
    invisible) mod=28 ;;
    strikethrough) mod=29 ;;
    overline) mod=55 ;;
    *)
        echo "Invalid reset style: $1"
        return 1
        ;;
    esac
}
function ansi::foreground() {
    shift=1
    case "$1" in
    black) color=30 ;;
    red) color=31 ;;
    green) color=32 ;;
    yellow) color=33 ;;
    blue) color=34 ;;
    magenta | purple) color=35 ;;
    cyan) color=36 ;;
    white) color=37 ;;
    rgb)
        color="38;2;$2;$3;$4"
        shift=4
        ;;
    8bit)
        color="38;5;$2"
        shift=2
        ;;
    default) color=39 ;;
    gray) color=90 ;;
    *)
        echo "Invalid style or foreground color: $1"
        return 1
        ;;
    esac
    shift $shift
}
function ansi::background() {
    shift=1
    case "$1" in
    black) bcolor=40 ;;
    red) bcolor=41 ;;
    green) bcolor=42 ;;
    yellow) bcolor=43 ;;
    blue) bcolor=44 ;;
    magenta | purple) bcolor=45 ;;
    cyan) bcolor=46 ;;
    white) bcolor=47 ;;
    default) bcolor=49 ;;
    rgb)
        bcolor="48;2;$2;$3;$4"
        shift=4
        ;;
    8bit)
        bcolor="48;5;$2"
        shift=2
        ;;
    *)
        echo "Invalid background color: $1"
        return 1
        ;;
    esac
}
function ansi::bright() {
    case "$1" in
    black) color=90 ;;
    red) color=91 ;;
    green) color=92 ;;
    yellow) color=93 ;;
    blue) color=94 ;;
    magenta | purple) color=95 ;;
    cyan) color=96 ;;
    white) color=97 ;;
    *)
        echo "Invalid bright color name: $1"
        return 1
        ;;
    esac
}
function ansi::code() {
    local prefix="\e["
    local suffix="m"
    mod=${mod:+$mod}
    bcolor=${bcolor:+$bcolor}
    color=${color:+$color}
    local sep1="" sep2=""
    if [ -n "$mod" ]; then
        if [ -n "$color" ] || [ -n "$bcolor" ]; then
            sep1=";"
        else
            sep1=""
        fi
    else
        sep1=""
    fi
    if [ -n "$color" ] && [ -n "$bcolor" ]; then
        sep2=";"
    else
        sep2=""
    fi
    local ansi_code="${prefix}${mod}${sep1}${bcolor}${sep2}${color}${suffix}"
    unset mod color bcolor
    if [[ $show -eq 1 ]]; then
        echo -n "\\" && echo "${ansi_code:1}"
    else
        echo -n "$ansi_code"
    fi
}
function ansi::make() {
    if [[ "$*" == "reset"* ]]; then
        shift
        if (($# == 0)); then
            ansi::reset all
        else
            ansi::reset $1
            shift
        fi
    fi
    if (($# > 0)); then
        ansi::style $@
        if [[ -n $mod ]]; then
            shift
        fi
        if [[ "$*" == "bg"* ]]; then
            if [[ $# -eq 1 ]]; then
                echo "Missing background color name"
                return 1
            fi
            shift
            ansi::background $@ || return 1
            shift $shift
            unset shift
        fi
        if [[ "$*" == "bright"* ]]; then
            if [[ $# -eq 1 ]]; then
                echo "Missing bright color name"
                return 1
            fi
            shift
            ansi::bright $@ || return 1
            shift
        else
            if [[ $# -gt 0 ]]; then
                ansi::foreground $@ || return 1
                shift $shift
                unset shift
            fi
        fi
        if [[ "$*" == "bg"* ]]; then
            if [[ $# -eq 1 ]]; then
                echo "Missing background color name"
                return 1
            fi
            shift
            ansi::background $@
            shift $shift
            unset shift
        fi
        if (($# > 0)); then
            echo "Too many arguments: $@"
            return 1
        fi
    fi
}
function ansi::args() {
    unset mod color bcolor show shift
    if [[ $# == 0 || $1 == "info" ]]; then
        ansi::info
        return 0
    elif [[ "$1" == "help" ]]; then
        ansi::help
        return 0
    elif [[ "$1" == "example" ]]; then
        ansi::example
        return 0
    elif [[ "$1" == "show" ]]; then
        show=1
        shift
    fi
    ansi::make "$@" || return 1
    ansi::code
}
function ansi() {
    eval "ansi::args $*"
}

#
# File: dev.sh
#

function www() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Start a local HTTP server in the specified directory"
    f[help]="If no directory is specified, the current directory will be used."
    f[help]+="\nDefault port is 8080. To supress auto-open, use -n."
    f[args_optional]="directory port"
    f[opts]="debug help info noopen version"
    f[version]="0.35"; f[date]="2025-05-10"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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

#
# File: files.sh
#

ftype() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Detects the type of file system object for a given path."
    f[args_required]="path"
    f[opts]="debug help info long version"
    f[version]="0.4"; f[date]="2025-05-15"
    f[help]="Returns type with error code 0 (or 1 for not_found):\n"
    f[help]+=$(ftypeinfo)
    fn_make2 "$@" && [[ -n "$f[return]" ]] && return "$f[return]"
    t[path_org]="$a[1]"
    t[path_abs]="$t[path_org]:a" # :a does not follow symlinks
    if [[ ! -e "$t[path_org]" && ! -L "$t[path_org]" ]]; then
        t[type]="not_found"
        t[not_found]="1"
    fi
    if [[ -L "$t[path_org]" && -z "$t[type]" ]]; then
        t[link]="1"
        t[link_dst]=$(readlink "$t[path_org]")
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
    [[ $o[d] == 1 ]] && fn_debug
    if [[ $o[l] == 1 ]]; then
        echo "$s[type_info]"
    else
        echo "$t[type]"
    fi
    if [[ "$t[not_found]" ]]; then
        return 1
    else
        return 0
    fi
}
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
    local type="$a[1]"
    local -A types
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
    if [[ -z $type ]]; then
        for key value in ${(kv)types}; do
            echo "${(r:10:)key} $y -> $x $value"
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
function rmln() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Removes file or directory only if it is a symbolic link."
    f[args_required]="file_or_dir"
    f[opts]="debug help info version"
    f[version]="0.6"; f[date]="2025-05-07"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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
function lns() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="A better ln command for creating symbolic links."
    f[help]="It creates a symbolic link only if such does not yet exist."
    f[help]+="\nSource and target may be provided as relative or absolute paths."
    f[help]+="\nOption '-f' (force) removes the existing link/file/directory."
    f[args_required]="existing_target new_link"
    f[opts]="debug force help info test version"
    f[version]="0.35"; f[date]="2025-05-09"
    fn_make2 "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
    f[target_input]="$1"
    f[target]="${f[target_input]:A}"
    f[target_parent]="${f[target]:h}"
    f[target_name]="${f[target]:t}"
    f[target_parent_readable]=$(isdirreadable "$f[target_parent]")
    f[link_input]="$2"
    f[link]="${f[link_input]:A}"
    f[link_parent]="${f[link]:h}"
    f[link_parent_writable]=$(isdirwritable "$f[link_parent]")
    f[link_name]="${f[link]:t}"
    f[target_type]=$(ftype "$f[target]")
    f[target_type_info]=$(ftypeinfo "$f[target_type]")
    local src="${1:A}"
    local dst="${2:A}"
    local src_dir="$(dirname "$src")"
    local dst_dir="$(dirname "$dst")"
    local debug=$o[d]
    local force=$o[f]
    local test=$o[t]
    local dst_c="${cyan}$dst${reset}"
    local src_c="${cyan}$src${reset}"
    local src_dir_c="${cyan}$src_dir${reset}"
    local dst_dir_c="${cyan}$dst_dir${reset}"
    local arr="${yellowi}→${reset}"
    if [[ $debug -eq 1 ]]; then
        log::info "$s[name]: source: \t$src_c"
        log::info "$s[name]: source dir: \t$src_dir"
        log::info "$s[name]: target: \t$dst_c"
        log::info "$s[name]: target dir: \t$dst_dir"
    fi
    if [[ ! -e "$dst" ]]; then
        log::error "$s[name]: target $dst_c does not exist."
        return 1
    fi
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
    if [[ "$dst" == "$src" ]]; then
        log::error "$s[name]: target and source cannot be the same."
        return 1
    fi
    if [[ ! -r "$dst" ]]; then
        log::error "$s[name]: target $dst_c is not readable."
        return 1
    fi
    if [[ ! -d "$dst" ]] && [[ ! -f "$dst" ]]; then
        log::error "$s[name]: target $dst_c is neither a directory nor a file."
        return 1
    fi
    if [[ ! -w "$src_dir" ]]; then
        log::error "$s[name]: cannot write to the source's folder $src_dir_c"
        return 1
    fi
    if [[ -L "$src" ]] && [[ "$(readlink "$src")" == "$dst" ]]; then
        log::info "$s[name]: symlink $src_c $arr $dst_c already exists."
        return 0
    fi
    if [[ "$src" == $(realpath "$dst") ]]; then
        log::error "$s[name]: source and target are the same file."
        log::info "$s[name]: check for folder symlinks in file paths."
        return 1
    fi
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
function lnsconfdir() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Creates a symbolic link for configuration dirs using lns."
    f[help]="If the -p optionis used, it will use GHPRIVDIR instead of GHCONFDIR"
    f[args_required]="directory"
    f[opts]="debug help info version example"
    f[version]="0.15"; f[date]="2025-05-06"
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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
function utype() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Universal better type command for bash and zsh."
    f[help]="Returns: 'file', 'alias', 'function', 'keyword', 'builtin' or 'not found'"
    f[args_required]="command"
    f[opts]="debug help info version"
    f[version]="0.2"; f[date]="2025-05-06"
    fn_make2 "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
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
function wheref() {
    local f_name="wheref"
    local f_args="<function_name>"
    local f_switches=("--help" "--version")
    local f_info="finds the file where a function is defined."
    local f_ver="0.1"
    local f_min_args=1
    local f_max_args=1
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi purple) r=$(ansi reset)
    local fname="$g${f_name}$r"
    local fargs="$c${f_args}$r"
    [[ -n $f_switches ]] && fargs+=" ${p}[<switches>...]${r}"
    local finfo="$fname $f_info\n"
    local fusage="Usage: $fname $fargs\n"
    [[ -n $f_switches ]] && fusage="${fusage}Switches: ${p}$f_switches${r}\n"
    local fver="$fname version $f_ver\n"
    local args=$(check_fn_args $f_min_args $f_max_args $#)
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == "--version" ]] && printf "$fver" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
    if [[ $(check_function_name $1) -eq 0 ]]; then
        log::error "$f_name: function name must start with a letter or an underscore."
        return 1
    fi
    echo $1
}

#
# File: fn.sh
#

function fn_template_full() {
    local -A a; local -A f; local -A i; local -A o; local -A s; local -A t
    f[info]="Template for functions." # info about the function
    f[version]="1.05" # version of the function
    f[date]="2025-05-20" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    a[3]="agrument3,o,description of the third argument"
    a[4]="agrument4,o,description of the fourth argument"
    o[something]="s,0,some other option,[0|1|2]"             # Restricts values to only 0, 1, or 2
    o[level]="l,medium,difficulty level,[easy|medium|hard]"   # Only specific predefined values allowed
    o[format]="f,json,output format,[json|xml|csv|text]"      # Only specific format values allowed
    o[name]="n,,custom name"                                  # Empty default value, accepts any user input (no validation)
    o[path]="p,/tmp,file path,[]"                             # Has default value, but accepts any user input (empty brackets)
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}
function fn_template_short() {
    local -A a; local -A f; local -A o; local -A s
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}
function fn_make() {
    fn_load_colors
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "${c}fn_make$x function cannot be called directly"
        return 1
    fi
    if [[ -z $ZSH_VERSION ]]; then
        log::error "${c}fn_make$x function can only be used in Zsh shell"
        return 1
    fi
    local -A a_name; local -A a_req; local -A a_help
    local -A o_default; local -A o_short; local -A o_long; local -A o_help; local -A o_allowed
    local -A e_msg; local -A e_hint; local -A e_dym
    fn_set_properties
    fn_set_info
    fn_add_defaults
    fn_parse_settings && [[ -n "${f[return]}" ]] && return "${f[return]}"
    fn_parse_arguments "$@"
    fn_set_strings
    fn_set_time $time_start
    fn_debug && [[ -n "${f[return]}" ]] && return "${f[return]}"
    fn_handle_options && [[ -n "${f[return]}" ]] && return "${f[return]}"
    fn_handle_errors && [[ -n "${f[return]}" ]] && return "${f[return]}"
}
function fn_handle_errors() {
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} error$plr in $s[name] ${r}arguments:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value"
            [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]" 
            [[ $e_dym[$key] ]] && log::info "$e_dym[$key]"
        done
        echo "$s[hint]"
        f[return]=1 && return 1
    fi
}
function fn_handle_options() {
    if [[ "$o[version]" -eq "1" || "$o[info]" -eq "1" || "$o[help]" -eq "1" ]]; then
        if [[ "$o[version]" -eq "1" ]]; then
            echo $s[version]
        elif [[ "$o[info]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            echo $s[example]
        elif [[ "$o[help]" -eq "1" ]]; then
            [[ $f[info] ]] && echo "\n$s[header]"
            [[ $f[help] ]] && echo $f[help]
            echo "$s[example]\n$s[usage]\n\n$s[footer]\n$s[source]\n"
        fi
        f[return]=0 && return 0
    fi
}
function fn_set_properties() {
    f[time_started]=$(date +"%Y-%m-%d %H:%M:%S")
    (( $+commands[gdate] )) && f[time_fnmake_start]=$(gdate +%s%3N) || f[time_fnmake_start]=$(date +%s)
    f[name]="${funcstack[3]}"
    [[ -z $f[author] ]] && f[author]="gh/barabasz"
    f[file_path]="$(whence -v $f[name] | awk '{print $NF}')"
    f[file_dir]="${f[file_path]%/*}"
    f[file_name]="${f[file_path]##*/}"
    f[args_min]="0" # number of required arguments
    f[args_opt]="0" # number of optional arguments
    f[args_max]="${#a}" # maximum number of arguments
    f[args_count]=0 # number of arguments passed
    f[args_input]="" # string of arguments passed
    f[opts_count]=0 # number of options passed
    f[opts_input]="" # string of options passed
    f[return]="" # return value
}
function fn_set_time() {
    (( $+commands[gdate] )) && local time_end=$(gdate +%s%3N) || local time_end=$(date +%s)
    local time_diff=$((time_end - f[time_fnmake_start]))
    f[time_fnmake]=$time_diff
    unset "f[time_fnmake_start]"
}
function fn_usage() {
    local i=1 usage="\n" max_len=0 a_pad o_pad indent="    "
    if [[ ${#a} -ne 0 ]]; then
        for arg in ${(ok)a}; do
            (( ${#arg} > max_len )) && max_len=${#arg}
        done
    fi
    if [[ ${#o_help} -ne 0 ]]; then
        for oh in ${(ok)o_help}; do
            (( ${#oh} > max_len )) && max_len=${#oh}
        done
    fi
    (( a_pad = max_len + 6 ))
    (( o_pad = max_len + 1 ))
    usage+="${y}Usage details:$x\n$indent$s[name] ${p}[options]${x} "
    if [[ $f[args_min] -eq 1 ]]; then
        usage+="${c}<${a_name[1]}>${x} "
    elif [[ $f[args_min] -ne 0 ]]; then
        usage+="${c}<arguments>${x} "
    fi
    if [[ $f[args_opt] -eq 1 ]]; then
        usage+="${c}[${a_name[1]}]${x}"
    elif [[ $f[args_opt] -ne 0 ]]; then
        usage+="${c}[arguments]${x}"
    fi
    if [[ $f[args_min] -ne 0 ]]; then
        usage+="\n\n${y}Required arguments:$x\n$indent"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "required" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$b→$x $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ $f[args_opt] -ne 0 ]]; then
        usage+="\n${y}Optional arguments:$x\n$indent"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "optional" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$b→$x $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi
    (( ${#a} == 0 )) && usage+="\n"
    usage+="\n${y}Options:$x\n$indent"
    for opt in ${(ok)o_long}; do
        usage+="-$p$o_long[$opt]$x"
        usage+=" or "
        usage+="--${p}${(r:$o_pad:: :)opt}$b→$x $o_help[$opt]"
        if [[ -n "${o_allowed[$opt]}" && "${o_allowed[$opt]}" != "" ]]; then
            usage+=" ${y}[${o_allowed[$opt]}]$x"
        fi
        usage+="\n$indent"
    done
    usage="${usage%\\n\\t}"
    if [[ $f[args_max] -gt 1 ]]; then
        usage+="\n${c}Arguments$x must be provided in the specified sequence."
    fi
    if [[ $f[args_opt] -gt 1 ]]; then
        usage+="\nTo skip an argument, pass an empty value $c\"\"$x (only valid for optional arguments)."
    fi
    (( f[args_max] > 0 )) && usage+=$'\n'
    if [[ $f[opts_max] -gt 0 ]]; then
        usage+="\n${p}Options$x may be submitted in any place and in any order."
        usage+="\nTo pass a value to a supported options, use the syntax ${p}--option=value$x."
        usage+="\nOptions without a value take the default value from the settings."
        usage+="\nTo list option default values, use the ${p}--debug=D$x option."
    fi
    printf "$usage\n"
}
function fn_version() {
    printf "$s[name]"
    [[ -n $f[version] ]] && printf " $y$f[version]$x" || printf " [version unknown]"
    [[ -n $f[date] ]] && printf " ($f[date])"
}
function fn_hint() {
    if [[ $f[info] && $f[help] ]]; then
        log::info "Run $s[name] ${p}-i$x for basic usage or $s[name] ${p}-h$x for help."
    elif [[ $f[info] ]]; then
        log::info "Run $s[name] ${p}-i$x for usage information."
    elif [[ $f[help] ]]; then
        log::info "Run $s[name] ${p}-h$x for help."
    else
        log::info "Check source code for usage information."
        log::comment $s[source]
    fi
}
function fn_source() {
    local file="$f[file_path]"
    local string="${f[name]}() {"
    local line="$(grep -n "$string" "$file" | head -n 1 | cut -d: -f1)"
    echo "This function is defined in $s[path] (line $c$line$x)"
}
function fn_footer() {
    printf "$s[version] copyright © "
    [[ -n $f[date] ]] && printf "$s[year] "
    printf "by $s[author]\n"
    printf "MIT License : https://opensource.org/licenses/MIT"
}
function fn_example() {
    local indent="    "
    [[ $o[help] == 1 ]] && printf "\n"
    printf "${y}Usage example:$x" 
    [[ $o[help] == 1 ]] && printf "\n$indent" || printf " "
    printf "$s[name] "
    if [[ ${#a} -ne 0 ]]; then
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "required" ]]; then
                printf "${c}<${arg}>${x} "
            else
                printf "${c}[$arg]${x} "
            fi
        done | sort | tr -d '\n'
    fi
    [[ $o[info] == 1 ]] && printf "\nRun '$s[name] ${p}-h$x' for more help."
}
function fn_set_strings() {
    s[name]="${g}$f[name]$x"
    s[path]="${c}$f[file_path]$x"
    s[author]="${y}$f[author]$x"
    s[year]="${y}${f[date]:0:4}$x"
    s[header]="$s[name]: $f[info]"
    s[version]="$(fn_version)"
    s[footer]="$(fn_footer)"
    s[example]="$(fn_example)"
    s[source]="$(fn_source)"
    s[usage]="$(fn_usage)"
    s[hint]="$(fn_hint)"
}
function fn_check_args() {
    (( f[args_min] <= f[args_count] && f[args_count] <= f[args_max] )) && return
    local expected="expected $y$f[args_min]$x"
    local given="given $y$f[args_count]$x"
    (( f[args_max] == 0 && f[args_count] > 0 )) && {
        echo "No arguments expected ($given)"
        return
    }
    (( f[args_count] < f[args_min] )) && {
        local msg="Missing required argument"
        (( f[args_min] - f[args_count] > 1 )) && msg+="s"
        echo "$msg ($expected, $given)"
        return
    }
    (( f[args_count] > f[args_max] )) && {
        echo "Too many arguments ($expected to $y$f[args_max]$x, $given)"
        return
    }
}
function fn_parse_arguments() {
    local used_opts=""
    local -A used_opts_full
    local i=0 ai=0 oi=0
    for arg in "$@"; do
        (( i++ ))
        if [[ $arg == -* ]]; then
            (( oi++ ))
            f[opts_input]+="$arg "
            fn_parse_option "$arg" "$i" "$oi"
        else
            (( ai++ ))
            f[args_input]+="'$arg' "
            fn_parse_argument "$arg" "$i" "$ai"
        fi
    done
    f[opts_count]=$oi
    f[args_count]=$ai
    f[opts_input]="${f[opts_input]%" "}"
    f[args_input]="${f[args_input]%" "}"
    if [[ f[args_count] -lt $f[args_min] || $f[args_count] -gt $f[args_max] ]]; then
        e_msg[0]=$(fn_check_args)
    fi
}
function fn_option_suggestion() {
    local error_type="$1"
    local suggestion=""
    case $error_type in
        too_many_dashes_short)
            if [[ -n "${o_short[$name]}" ]]; then
                suggestion="-${name}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
        too_many_dashes_long)
            if [[ " ${(k)o_long} " == *" $name "* ]]; then
                suggestion="--${name}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
        multiple_equals)
            local fixed_value=${arg#*=}; fixed_value=${fixed_value%%=*}
            suggestion="${arg%%=*}=${fixed_value}"
            suggestion="${p}${suggestion}${x}"
            ;;
        long_short)
            local has_short=0
            local has_long=0
            local short_suggest=""
            local long_suggest=""
            if [[ -n "${o_short[${name[1]}]}" ]]; then
                short_suggest="-${name[1]}"
                (( has_value )) && short_suggest+="=$value"
                has_short=1
            fi
            if [[ " ${(k)o_long} " == *" $name "* ]]; then
                long_suggest="--${name}"
                (( has_value )) && long_suggest+="=$value"
                has_long=1
            fi
            if (( has_short && has_long )); then
                suggestion="${p}${short_suggest}${x} or ${p}${long_suggest}${x}"
            elif (( has_short )); then
                suggestion="${p}${short_suggest}${x}"
            elif (( has_long )); then
                suggestion="${p}${long_suggest}${x}"
            fi
            ;;
        short_long)
            local has_short=0
            local has_long=0
            local short_suggestion=""
            local long_suggestion=""
            if [[ -n "${o_short[$name]}" ]]; then
                short_suggestion="-${name}"
                (( has_value )) && short_suggestion+="=$value"
                has_short=1
            fi
            local best_match="" best_score=0
            for key in "${(@k)o_long}"; do
                if [[ ${key:0:1} == ${name} ]]; then
                    if [[ -z "$best_match" || ${#key} < ${#best_match} ]]; then
                        best_match=$key
                        best_score=1
                    fi
                fi
            done
            if [[ -n "$best_match" ]]; then
                long_suggestion="--${best_match}"
                (( has_value )) && long_suggestion+="=$value"
                has_long=1
            fi
            if (( has_short && has_long )); then
                suggestion="${p}${short_suggestion}${x} or ${p}${long_suggestion}${x}"
            elif (( has_short )); then
                suggestion="${p}${short_suggestion}${x}"
            elif (( has_long )); then
                suggestion="${p}${long_suggestion}${x}"
            fi
            ;;
        unknown_short)
            for key val in "${(@kv)o_short}"; do
                if [[ $key == ${name[1]} ]]; then
                    suggestion="-$key"
                    (( has_value )) && suggestion+="=$value"
                    suggestion="${p}${suggestion}${x}"
                    break
                fi
            done
            ;;
        unknown_long)
            local best_match="" best_score=0 namelen=${#name}
            for key in "${(@k)o_long}"; do
                local common_prefix="${name:0:1}"
                for ((j=1; j<$namelen && j<${#key}; j++)); do
                    [[ "${name:0:$j+1}" == "${key:0:$j+1}" ]] && common_prefix="${name:0:$j+1}"
                done
                local score=${#common_prefix}
                (( score > best_score )) && { best_match=$key; best_score=$score; }
            done
            if [[ -n "$best_match" && $best_score -ge 2 ]]; then
                suggestion="--${best_match}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
        empty_with_equals)
            if (( dashes == 1 )); then
                suggestion="Use -o=value format for short options with values"
            else
                suggestion="Use --option=value format for long options with values"
            fi
            ;;
    esac
    if [[ -n "$suggestion" ]]; then
        if [[ "$suggestion" == *"$p"* ]]; then
            dym="Did you mean $suggestion?"
        else
            dym="Did you mean '$suggestion'?"
        fi
        return 0  # Success - we have a suggestion
    else
        dym=""
        return 1  # No suggestion found
    fi
}
function fn_parse_option() {
    local arg="$1" i="$2" oi="$3"
    local oic="$y$oi$x"
    local dym=""  # Will hold "Did you mean" suggestion
    local dashes=${#arg%%[^-]*}
    local has_value=0
    [[ $arg == *=* ]] && has_value=1
    local name="${arg#${(l:$dashes::-:)}}"; name="${name%%=*}"
    local namelen=${#name}
    local value=""
    (( has_value )) && value="${arg#*=}"
    local argnamec="'$p$name$x'"
    local argc="'$p$arg$x'"
    if (( namelen == 0 )); then
        if (( has_value )); then
            e_msg[o$i]="Option $oic has empty name with equals sign in $argc"
            e_hint[o$i]="Options must have a name before the equals sign."
            fn_option_suggestion "empty_with_equals" && e_dym[o$i]="$dym"
        else
            e_msg[o$i]="Option $oic has empty name in $argc"
            e_hint[o$i]="Options must have a name after the dash(es)."
        fi
        return
    elif (( dashes > 2 )); then
        if (( namelen == 1 )); then
            e_msg[o$i]="Option $oic has too many leading dashes in $argc"
            e_hint[o$i]="Option with short name should start with one dash (-)."
            fn_option_suggestion "too_many_dashes_short" && e_dym[o$i]="$dym"
        else
            e_msg[o$i]="Option $oic has too many leading dashes in $argc"
            e_hint[o$i]="Option with long name should start with two dashes (--)."
            fn_option_suggestion "too_many_dashes_long" && e_dym[o$i]="$dym"
        fi
        return
    elif [[ $arg == *=*=* ]]; then
        e_msg[o$i]="Option $oic has multiple equal signs in $argc"
        e_hint[o$i]="Option values must be specified using a single equal sign."
        fn_option_suggestion "multiple_equals" && e_dym[o$i]="$dym"
        return
    elif (( dashes == 1 && namelen > 1 )); then
        e_msg[o$i]="Option $oic name is too long in $argc"
        e_hint[o$i]="Short option names must be a single character."
        fn_option_suggestion "long_short" && e_dym[o$i]="$dym"
        return
    elif (( dashes == 2 && namelen == 1 )); then
        e_msg[o$i]="Option $oic name is too short in $argc"
        e_hint[o$i]="This could be either a short option with an extra dash, or an abbreviated long option."
        fn_option_suggestion "short_long" && e_dym[o$i]="$dym"
        return
    fi
    local canonical_name=""
    if (( dashes == 1 )); then
        if [[ -z "${o_short[$name]}" ]]; then
            e_msg[o$i]="Option $oic short name $argnamec unknown in $argc"
            fn_option_suggestion "unknown_short" && e_dym[o$i]="$dym"
            return
        else
            canonical_name="${o_short[$name]}"
        fi
    elif (( dashes == 2 )); then
        if [[ ! " ${(k)o_long} " == *" $name "* ]]; then
            e_msg[o$i]="Option $oic full name $argnamec unknown in $argc"
            fn_option_suggestion "unknown_long" && e_dym[o$i]="$dym"
            return
        else
            canonical_name="$name"
        fi
    fi
    if [[ $used_opts == *" $canonical_name "* ]]; then
        local previous_usage="${used_opts_full[$canonical_name]}"
        e_msg[o$i]="Option $oic name $argnamec in $argc was already used as "
        e_msg[o$i]+="'$p${previous_usage}$x'"
        return
    fi
    (( has_value == 0 )) && value="${o_default[$canonical_name]}"
    if [[ -n "${o_allowed[$canonical_name]}" && "${o_allowed[$canonical_name]}" != "" && $has_value -eq 1 ]]; then
        local allowed="${o_allowed[$canonical_name]}"
        local valid=0
        if [[ "$canonical_name" == "debug" ]]; then
            valid=1
            for char in ${(s::)value}; do
                if [[ "$allowed" != *"$char"* ]]; then
                    valid=0
                    break
                fi
            done
        else
            local -a allowed_values=(${(s:|:)allowed})
            for allowed_val in "${allowed_values[@]}"; do
                if [[ "$value" == "$allowed_val" ]]; then
                    valid=1
                    break
                fi
            done
        fi
        if [[ $valid -eq 0 ]]; then
            e_msg[o$i]="Option $oic has invalid value '$p$value$x' in $argc"
            e_hint[o$i]="Allowed values for this option are: $allowed"
            return
        fi
    fi
    o[$canonical_name]=$value
    used_opts+=" $canonical_name "  # Add spaces to ensure exact matching
    used_opts_full[$canonical_name]="$arg"
}
function fn_parse_argument() {
    local aic="$y$ai$x"
    if [[ $a_req[$a_name[$ai]] == "required" && -z $arg ]]; then
        e_msg[a$i]="Argument $aic ($y$a_name[$ai]$x) cannot be empty"
    fi
    if [[ $a_name[$ai] ]]; then
        a[$a_name[$ai]]="$arg"
    else
        a[$ai]="$arg"
    fi
}
function fn_load_colors() {
    b=$(ansi blue)          # arrows
    c=$(ansi cyan)          # arguments, url, file path
    g=$(ansi green)         # function name
    p=$(ansi bright purple) # options
    r=$(ansi red)           # errors
    w=$(ansi white)         # plain text
    y=$(ansi yellow)        # highlight
    x=$(ansi reset)         # reset
}
function fn_add_defaults() {
    [[ -z ${o[info]} ]] && o[info]="i,1,show basic info and usage,[0|1]"
    [[ -z ${o[help]} ]] && o[help]="h,1,show full help,[0|1]"
    [[ -z ${o[version]} ]] && o[version]="v,1,show version,[0|1]"
    [[ -z ${o[debug]} ]] && o[debug]="d,f,enable debug mode (use ${p}-d=h$x for help),[a|A|d|D|e|f|h|I|i|o|s|t|V]"
    [[ -z ${o[verbose]} ]] && o[verbose]="V,1,enable verbose mode,[0|1]"
    f[opts_max]="${#o}" # maximum number of options
}
function fn_parse_settings() {
    for key in ${(ok)a}; do
        local value="${a[$key]}"
        local settings=(${(s:,:)value})
        if [[ ${#settings} -ne 3 ]]; then
            e_msg[$key]="Invalid argument $y$key$x format in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have 3 values/2 commas)"
            continue
        fi
        a_name[$key]="${settings[1]}"
        if [[ -n ${a[${settings[1]}]+_} ]]; then
            e_msg[$key]="Argument $y$key$x name '$y${settings[1]}$x' already used before"
            e_hint[$key]="Correct '$y$value$x' by giving a unique name"
            continue
        fi
        if [[ "ro" != *"${settings[2]}"* ]]; then
            e_msg[$key]="Invalid argument $y$key$x type '$y${settings[2]}$x' in '$y$value$x'"
            e_hint[$key]="Argument type must be '${y}r$x' (required) or '${y}o$x' (optional)"
            continue
        fi
        if [[ ${settings[2]} == r ]]; then
            a_req[${settings[1]}]=required
            (( f[args_min]++ ))
        else
            a_req[${settings[1]}]=optional
            (( f[args_opt]++ ))
        fi
        a_help[${settings[1]}]="${settings[3]}"
        unset "a[$key]"
        a[${settings[1]}]=""
    done
    for key in ${(ok)o}; do
        local value="${o[$key]}"
        local settings=(${(s:,:)value})
        if [[ ${#settings} -lt 3 ]]; then
            e_msg[$key]="Invalid settings for option '$y$key$x' in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have at least 3 values/2 commas)"
            continue
        fi
        if [[ -n ${o_short[${settings[1]}]+_} ]]; then
            e_msg[$key]="Option short name '${settings[1]}' already used in '$key' ($value)"
            e_hint[$key]="Each option must have a unique short name and a unique full name."
            continue
        fi
        if [[ ${#settings[1]} -ne 1 ]]; then
            e_msg[$key]="Short option name must be exactly one letter in '$key' ($value)"
            e_hint[$key]="Correct '$key' by using a single letter for the short option name."
            continue
        fi 
        o_default[$key]="${settings[2]}"
        o_short[${settings[1]}]=$key
        o_long[$key]="${settings[1]}"
        o_help[$key]="${settings[3]}"
        if [[ ${#settings} -ge 4 && "${settings[4]}" == \[*\] ]]; then
            local allowed="${settings[4]}"
            allowed="${allowed#\[}" # Remove opening bracket
            allowed="${allowed%\]}" # Remove closing bracket
            o_allowed[$key]="$allowed"
        fi
        unset "o[$key]"
    done
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} fatal error$plr in function $g$f[name]$x ${r}settings:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value" && [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]"
        done
        f[return]=1 && return 1
    fi
}
function fn_debug() {
    local debug="${1:-${o[debug]}}"
    if [[ "$debug" && ! $debug =~ "d" ]]; then
        local max_key_length=15
        local max_value_length=40
        local count
        local q="$y'$x"
        local arr="$b→$x"
        local -A modes=(
            [A]="All possible arrays"
            [a]="Arguments from $y\$a[]$x array"
            [D]="Default values for options"
            [d]="Disable debugging inside ${g}fn_make$x"
            [e]="Exit after debugging"
            [f]="Function properties from $y\$f[]$x array"
            [h]="Help $y(default)$x"
            [I]="Internal ${g}fn_make$x arrays"
            [i]="Information from $y\$i[]$x array"
            [o]="Options from $y\$o[]$x array"
            [s]="Strings from $y\$s[]$x array"
            [t]="This function from $y\$t[]$x array"
            [V]="Validation settings for options (allowed values)"
        )
        if [[ $debug =~ "A" ]]; then
            debug="aDefIiostV"
        fi
        if [[ ! $debug =~ [aDdefhIiostV] ]]; then
            log::info "No valid debug mode set, falling back to help mode."
            debug="h"
        fi
        for key in "${(@k)f}"; do
            if [[ ${#key} -gt $max_key_length ]]; then
                max_key_length=${#key}
            fi
        done
        for key in "${(@k)t}"; do
            if [[ ${#key} -gt $max_key_length ]]; then
                max_key_length=${#key}
            fi
        done
        print::header "${r}Debug mode$x '$debug'"
        if [[ $debug =~ "e" ]]; then
            log::warning "Exit mode enabled: $s[name] will exit after debug."
            f[return]=0
        fi
        if [[ ! $debug =~ "h" ]]; then
            log::info "Use option ${c}-d=h$x to show available debug modes."
        fi
        if [[ $debug =~ "h" ]]; then
            max_key_length=2
            log::info "${y}Debug modes${x} (${#modes}):"
            for key value in "${(@kv)modes}"; do
                echo "    ${(r:$max_key_length:)key} $arr $q$value$q"
            done | sort
            echo "Debug modes can be combined, e.g. $c-d=aof$x of $c--debug=aof$x."
            echo "Debuggin of ${g}fn_make$x internal arrays (${c}i$x mode) works only if ${c}d$x is not set."
        fi
        if [[ $debug =~ "D" ]]; then
            fn_list_array "o_default" "Option default values"
        fi
        if [[ $debug =~ "I" ]]; then
            fn_list_array "a_name" "Argument names"
            fn_list_array "a_req" "Required arguments"
            fn_list_array "a_help" "Argument help strings"
            fn_list_array "o_default" "Option default values"
            fn_list_array "o_short" "Option short names"
            fn_list_array "o_long" "Option full names"
            fn_list_array "o_help" "Option help strings"
            fn_list_array "o_allowed" "Option allowed values"
        fi
        if [[ $debug =~ "V" ]]; then
            fn_list_array "o_allowed" "Option allowed values"
        fi
        [[ $debug =~ "a" ]] && fn_list_array "a" "Arguments"
        [[ $debug =~ "o" ]] && fn_list_array "o" "Options"
        [[ $debug =~ "f" ]] && fn_list_array "f" "Function properties"
        [[ $debug =~ "i" ]] && fn_list_array "i" "Environment information"
        [[ $debug =~ "s" ]] && fn_list_array "s" "Strings"
        [[ $debug =~ "t" ]] && fn_list_array "t" "This function"
        print::footer "${r}Debug end$x"
        [[ $debug =~ "e" ]] && f[return]=0 && return 0
    fi
}
function fn_set_info() {
    if [[ "${(t)i}" == *"association"* ]]; then
        i[arch]=$(uname -m)             # system architecture
        i[brew]=$+commands[brew]        # is Homebrew installed
        i[date]=$(date +"%Y-%m-%d")     # current date
        i[dir]=$PWD                     # current directory
        i[domain]=$(hostname -d)        # domain name
        i[host]=$(hostname -s)          # host name
        i[ip]=$(lanip)                  # local IP address
        i[os]=$(uname -s)               # operating system
        i[time]=$(date +"%H:%M:%S")     # current time
        i[user]=$(whoami)               # current user
        i[zsh]=$(echo $ZSH_VERSION)     # zsh version
        i[git]=$+commands[git]          # is git installed
        i[tty]=$(tty | sed 's|/dev/||') # terminal type
    fi
}
function fn_list_array() {
    local array_name=$1
    local display_name=$2
    local count
    if (( ${(P)#array_name} == 0 )); then
        count="is empty."
    else
        count="(${(P)#array_name}):"
    fi
    log::info "${y}${display_name}${x} ${g}\$${array_name}[]$x $count"
    local key value
    for key value in "${(@Pkv)array_name}"; do
        echo "    ${(r:$max_key_length:)key} $arr $q$value$q"
    done | sort
}

#
# File: helpers.sh
#

function clean_string() {
  local input="$1"
  input="${input//$'\n'/ }"
  input="${input//$'\t'/ }"
  input="${(j: :)${(z)input}}"
  echo "$input"
}
function clean_ansi() {
  local input="$1"
  echo "$input" | sed $'s/\x1b\\[[0-9;]*m//g'
}
function timet() {
    local cmd=$1
    local arg=$2
    echo "$((time (eval $cmd \$$arg)) 2>&1 | awk '/total/ {print $(NF-1)}')"
}
function sourceif() {
    [[ $# -eq 0 ]] && echo "Usage: sourceif <file> [error message]" && return 1
    if [[ $# -eq 1 ]]; then
        script="${redi}sourceif error${reset}"
    else
        script="${redi}sourceif error${reset} in ${yellow}$2${reset}"
    fi
    if [[ -f $1 ]]; then
        source $1
    else
        [[ $# -ge 2 ]] && printf "$1 not found\n" || printf "$2: $1 not found\n"
        printf "$script: ${cyan}$1${reset} not found\n"
        return 1
    fi
}
function source_remote() {
    local url=$1 name=$(basename $1) file_content=""
    file_content=$(wget -q -O - $url)
    [[ $? -ne 0 ]] && { echo "Error getting $name ($url)."; return 1; }
    source /dev/stdin <<< "$file_content"
    [[ $? -ne 0 ]] && { echo "Error sourcing $name."; return 1; }
}
function extscript() {
    /bin/bash -c "$(curl -fsSL $1)"
}
function extsource() {
    source /dev/stdin <<< "$(curl -fsSL $1)"
}
check_function_name() {
    local name=$1
    if [[ $name =~ ^[a-zA-Z_] ]]; then
        echo "1" && return 0
    else
        echo "0" && return 1
    fi
}
utime2iso() {
    local timestamp=$1
    date -r $timestamp -u +"%Y-%m-%dT%H:%M:%SZ"
}
iso2utime() {
    local date=$1
    date -j -f "%Y-%m-%dT%H:%M:%SZ" $date "+%s"
}
extract_url() {
    if [[ $1 =~ (https?://[^ ]+) ]]; then
        echo "${match[1]}" && return 0
    else
        return 1
    fi
}
extract_url2() {
    if [[ "$1" =~ "http[s]?://[^ ]+" ]]; then
        echo "$MATCH" && return 0
    else
        return 1
    fi
}
extract_path() {
    local input_string=$1
    local path
    if [[ $input_string =~ (/[[:alnum:]/._-]+) ]]; then
        path="${match[1]}"
        echo "$path" && return 0
    else
        echo "No path found in the given string." && return 1
    fi
}
extract_version() {
    local input=$1
    local match
    match=$(echo "$input" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)*' | head -n 1)
    if [ -n "$match" ]; then
        echo "$match" && return 0
    else
        echo "No version number found" && return 1
    fi
}
alias extractver=extract_version
alias getver=extract_version
htime() {
    local seconds=$1
    if (( seconds < 60 )); then
        echo "$seconds sec"
    elif (( seconds < 3600 )); then
        local minutes=$(echo "scale=1; $seconds/60" | bc)
        echo "$minutes min"
    elif (( seconds <= 86400 )); then
        local hours=$(echo "scale=1; $seconds/3600" | bc)
        echo "$hours h"
    else
        local days=$(( seconds / 86400 ))
        local remaining_seconds=$(( seconds % 86400 ))
        local remaining_time=$(htime $remaining_seconds)
        if (( days > 1 )); then
            echo "$days days $remaining_time"
        else
            echo "$days day $remaining_time"
        fi
    fi
}
string_to_words() {
    if [[ -n "$ZSH_VERSION" ]]; then
        local -a arr
        read -A arr <<< "$1"
        printf '%s\n' "${arr[@]}"
    else
        local arr=($1)
        printf '%s\n' "${arr[@]}"
    fi
}
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
fulldirpath() {
  local dir="$1"
  dir="${dir:A}"
  dir="${dir%/}"
  [[ ! -d "$dir" ]] && printf "notfound" && return 1
  printf "%s" "$dir" && return 0
}
isdirempty() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    local files=($dir/*(DN))
    if (( ${#files} == 0 )); then
        printf "1" && return 0
    else
        printf "0" && return 1
    fi
}
function isdirservable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    local files=($dir/*(N))
    if (( ${#files} == 0 )); then
        printf "0" && return 1
    else
        printf "1" && return 0
    fi
}
function isdirreadable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    if [[ -r "$dir" ]]; then
        printf "1" && return 0
    else
        printf "0" && return 1
    fi
}
function isdirwritable() {
    local dir="$1"
    dir="$(fulldirpath $dir)"
    [[ $dir == "notfound" ]] && return 2
    if [[ -w "$dir" ]]; then
        printf "1" && return 0
    else
        printf "0" && return 1
    fi
}
function uwhich() {
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

#
# File: info.sh
#

function verinfo() {
    local fargs="<cliname> [appname] [versioncommand]"
    local minargs=0
    local maxargs=3
    local thisf="${funcstack[1]}"
    local error="${redi}$thisf error:${reset}"
    local usage=$(make_fn_usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(check_fn_args $minargs $maxargs $#)
    [[ $args != "ok" ]] && printf "$error $args\n$usage\n" && return 1
    local msg=""
    local apppath=""
    local verstr=""
    local ver=""
    local cliname=""
    local appname=""
    local vercmmd=""
    if [[ -z "$2" ]]; then
        cliname=$1; appname=$1; vercmmd="--version"
    elif [[ -z "$3" ]]; then
        cliname=$1; appname=$2; vercmmd="--version"
    else
        cliname=$1; appname=$2; vercmmd=$3
    fi
    local type=$(utype $cliname)
    if [[ $type == "not found" ]]; then
        printf "$yellow$cliname$reset not found\n"
        return 1
    fi
    if [[ "$(uwhich $cliname)" == /* ]]; then
        msg='is installed in'
        apppath="$(uwhich $cliname)"
        verstr="$($apppath $vercmmd 2>&1)"
        ver=$(getver "$verstr")
        printf "${green}$appname${reset} ${yellow}${ver}${reset} $msg ${cyan}$apppath${reset}\n"
    fi
    if [[ $type = 'alias' ]]; then
        msg='is an alias for'
        definition="$(alias $cliname | sed "s/.*=//")"
        printf "${green}$cliname${reset} $msg ${purple}$definition${reset}\n"
    fi
    if [[ $type = 'function' ]]; then
        msg='is a function in'
        funcpath=$(whence -f $cliname)
        als="${green}$cliname${reset} $msg ${purple}$type${reset}"
        echo -e "$als"
    fi
    if [[ $type = 'keyword' || $type = 'builtin' ]]; then
        msg='is a'
        als="${green}$cliname${reset} $msg ${purple}$type${reset}"
        echo -e "$als"
    fi  
}
function logininfo() {
    local by=$(ansi bright yellow) c=$(ansi cyan) g=$(ansi green) r=$(ansi reset)
    local user=$(whoami)
    local userc=$by$user$r
    local host=$(hostname -s)
    local domain=$(hostname -d)
    [[ -n $domain ]] && host="$host.$domain"
    local hostc=$c$host$r
    local tty_icon="\Uf489 "
    local tty=$(tty | sed 's|/dev/||')
    local ttyc="$tty_icon $g$tty$r"
    local remote=$(who | grep $tty | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)' | tr -d '()')
    [[ -n $remote ]] && local remotec="from $c$remote$r"
    if [[ $(isinstalled ifconfig) -eq 1 ]]; then
        local ip=$g$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2}')$r
    else
        local ip=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1)
    fi
    local ipc=$g$ip$r
    printf "Logged in as $userc@$hostc ($ipc) on $ttyc $remotec\n"
}
function sysinfo() {
    local bw=$(ansi bright white) c=$(ansi cyan) y=$(ansi yellow) by=$(ansi bright yellow) r=$(ansi reset)
    local os_name=$(osname); os_name="$by$os_name$r"
    local os_icon=$(osicon); os_icon="$bw$os_icon$r"
    local os_kernel=$(uname -r)
    local os_shell=$(shellname); os_shell="$y$os_shell$r"
    local os_shell_ver=$(shellver)
    local os_arch=$(uname -m); os_arch="$y$os_arch$r"
    local os_uptime=$(uptimeh); os_uptime="$c$os_uptime$r"
    local os_version=$(osversion)
    local os_codename=$(oscodename)
    printf "This is $os_icon $os_name $os_version ($os_codename) "
    printf "with $os_shell $os_shell_ver running on $os_arch for $os_uptime\n"
}
function argsinfo() {
    local y=$(ansi bright yellow)
    local r=$(ansi reset)
    local j=0
    if [[ $# -eq 0 ]]; then
        log::error "No arguments provided."
        printinfo "Usage: showargs <arg1> <arg2> ... <argN>"
        return 1
    fi
    printf "Number of arguments:$y $# $r\n"
    printf "List of arguments:\n"
    for i in "$@"; do
        echo "$y#$((++j))$r: $i"
    done
}
function shellfiles() {
    local c=$(ansi cyan) g=$(ansi gray) y=$(ansi bright yellow) r=$(ansi reset)
    local error="❌ $(ansi bright red)" arrow="$y→$r " f="" 
    printf "Shell files ($y$ZFILES_COUNT$r): "
    [[ $ZFILE_ENV -eq 1 ]] && f=$c || f=$error
    printf "${f}zshenv$r $arrow"
    [[ $ZFILE_VARS -eq 1 ]] && f=$g || f=$error
    printf "${f}zvars$r $arrow"
    if [[ $(osname) != "macos" ]]; then
        [[ $ZFILE_LINUX -eq 1 ]] && f=$g || f=$error
        printf "${f}zlinux$r $arrow"
    fi
    [[ $ZFILE_LOCALE -eq 1 ]] && f=$g || f=$error
    printf "${f}zlocale$r $arrow"
    [[ $ZFILE_PROFILE -eq 1 ]] && f=$c || f=$error
    printf "${f}zprofile$r $arrow"
    [[ $ZFILE_RC -eq 1 ]] && f=$c || f=$error
    printf "${f}zshrc$r $arrow"
    [[ $ZFILE_ALIASES -eq 1 ]] && f=$g || f=$error
    printf "${f}zaliases$r $arrow"
    [[ $ZFILE_LOGIN -eq 1 ]] && f=$c || f=$error
    printf "${f}zlogin$r"
    printf "\n"
}

#
# File: install.sh
#

function isinstalled() {
    if [[ $(utype $1) == 'file' || "$(uwhich $1)" == /* ]]; then
        echo 1
    else
        echo 0
    fi
}
function isinstalledbybrew() {
    brew list $1 &>/dev/null
    if [ $? -eq 0 ]; then
        echo 1
    else
        echo 1
    fi
}
function aptinstall() {
    [[ $(isinstalled needrestart) -eq 1 ]] && needrestart-quiet
    export NEEDRESTART_MODE=a 
    export DEBIAN_FRONTEND=noninteractive
    aptopt='-qq'
    grpopt='-Eiv'
    filter='^needrestart|^update|^reading|^building|^scanning|^\(|^\s*$'
    sudo apt-get install $aptopt $@ | grep $grpopt $filter
    [[ $(isinstalled needrestart) -eq 1 ]] && needrestart-verbose
}
function installapp() {
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi purple) r=$(ansi reset)
    local f_name="installapp" f_args="<cli-name> <brew-name> <apt-name> <app-name>" f_switches="help ver"
    local f_info="is a script helper function for installing apps via brew or apt."
    f_info+="\nIt is intended to be used by installer scripts ${g}install-*${r} and not run directly."
    local f_min_args=4 f_max_args=5 f_ver="0.1"
    local fname="$g${f_name}$r" fargs="$c${f_args}$r"
    [[ -n $f_switches ]] && fargs+=" ${p}[switch]${r}"
    local finfo="$fname $f_info\n"
    local fusage="$(make_fn_usage "$f_name" "$f_args" "$f_switches")\n"
    local fver="$fname version $f_ver\n"
    local args=$(check_fn_args $f_min_args $f_max_args $#)
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    local cliname=$1
    local brewname=$2
    local aptname=$3
    local appname=$4
    local osname=$(osname)
    local isapp=$(isinstalled $cliname)
    local isbrew=$(isinstalled brew)
    if [[ "$brewname" == "null" && "$aptname" == "null" ]]; then
        log::error "$f_name: no package name provided."
        return 1
    elif [[ "$brewname" == "null" && "$osname" == "macos" ]]; then
        log::info "No brew package name provided."
        log::error "$f_name: $appname is not available for macOS."
        return 1
    elif [[ "$aptname" == "null" && "$brewname" != "null" && "$osname" != "macos" && "$isbrew" -eq 0 ]]; then
        log::error "$f_name: $appname is not available for Linux without brew."
        return 1
    fi
    if [[ "$isapp" -eq 0 ]]; then
        printhead "Installing $appname..."
        if [[ "$osname" == "macos" ]]; then
            brew install -q $brewname
        else
            if [[ "$aptname" != "null" ]]; then
                aptinstall $aptname
            elif [[ "$brewname" != "null" && "$isbrew" -eq 1 ]]; then
                brew install -q $brewname
            else
                log::error "$f_name: Brew is not installed."
                return 1
            fi
        fi
        if [[ $? -eq 0 ]]; then
            log::ok "$f_name: $appname successfully installed.\n"
        else
            log::error "$f_name: failed to install $appname."
            return 1
        fi
    fi
}

#
# File: interactive.sh
#

prompt_continue() {
  while true; do
      if [ -n "$BASH_VERSION" ]; then
          read -p "Do you want to continue? (Y/N): " yn
      else
          read "yn?Do you want to continue? (Y/N): "
      fi
      case $yn in
          [Yy]* ) return 0;;
          [Nn]* ) echo "You chose not to continue."; return 1;;
          * ) echo "Please answer Y/y or N/n.";;
      esac
  done
}

#
# File: lib.sh
#

function relib() {
    local f="" i=0 e=0 n=0 t="" t1="" t2="" tpattern="+%s%3N"
    local c=$(ansi cyan) g=$(ansi green) r=$(ansi reset) y=$(ansi yellow)
    local dir="${LIBDIR:-$HOME/lib}" file="_all.sh"
    [[ $(isinstalled gdate) -eq 1 ]] && alias date=gdate
    [[ $(osname) == "macos" && $(isinstalled gdate) -eq 0 ]] && tpattern="+%s"
    [[ $# -ne 0 ]] && log::warn "${g}relib${r} function does not take any arguments."
    t1=$(date $tpattern)
    source_sh_files $dir
    if [[ $? -ne 0 ]]; then
        log::error "Failed to source all library files."
        log::info "${r}Skipping generating ${c}_all.sh$r file"
        return 1
    else
        n=$source_sh_files_count
        t2=$(date $tpattern) && t=$((t2 - t1))
        log::ok "${r}Sourced $y$n$r library ${c}*.sh$r files from $c$dir$r in $y$t$r ms"
    fi
    t1=$(date $tpattern)
    concatenate_sh_files $dir "$dir/$file"
    if [[ $? -ne 0 ]]; then
        log::error "Failed to concatenate all library files."
        return 1
    else
        n=$concatenate_sh_files_count
        t2=$(date $tpattern) && t=$((t2 - t1))
        log::ok "${r}File $c$dir/$file$r created from $y$n$r files in $y$t$r ms"
    fi
}
function source_sh_files() {
    export source_sh_files_count=0
    local c=$(ansi cyan) r=$(ansi reset) y=$(ansi yellow)
    [[ $# -ne 1 ]] && log::error "${r}Usage: ${g}source_sh_files$r ${c}<directory>$r." && return 1
    local dir="$1" i=0 e=0
    [[ ! -d "$dir" ]] && {
        log::error "Directory $dir does not exist" && return 1
    }
    [[ ! -n $(echo $dir/*.sh(N)) ]] && {
        log::warn "No ${c}.sh$r files found in $c$dir$r" && return 1
    }
    for f in "$dir"/*.sh; do
        if [[ -f "$f" && ! "$(basename "$f")" =~ ^_ ]]; then
            source "$f"
            if [[ $? -ne 0 ]]; then
                log::error "Failed to source $f" && ((e++))
            else ((i++)); fi
        fi
    done
    export source_sh_files_count=$i
    [[ $e -ne 0 ]] && return 1 || return 0
}
concatenate_sh_files() {
    export concatenate_sh_files_count=0
    local dir="${1:A}"
    local output_file="${2:A}"
    local output_dir="${output_file:h}"
    local i=0 sf="" shebang='#!/bin/zsh'
    local c=$(ansi cyan) r=$(ansi reset) g=$(ansi green)
    [[ $# -ne 2 ]] && {
        log::error "${r}Usage: ${g}concatenate_sh_files$r $c<directory> <output_file>$r" && return 1
    }
    [[ -z $1 ]] && {
        log::error "${r}Source directory not provided." && return 1
    }
    [[ -z $2 ]] && {
        log::error "${r}Output file not provided." && return 1
    }
    [[ ! -d "$dir" ]] && {
        log::error "${r}Directory $c$dir$r does not exist" && return 1
    }
    [[ ! -n $(echo $dir/*.sh(N)) ]] && {
        log::warn "No ${c}.sh$r files found in $c$dir$r" && return 1
    }
    [[ ! -w "$output_dir" ]] && {
        log::error "${r}Cannot write output file $c$output_file$r" 
        log::info "${r}Directory $c$output_dir$r is not writable." && return 1
    }
    : >"$output_file"  # Truncate the output file
    echo "$shebang\n" >>"$output_file"
    for f in "$dir"/*.sh; do
        sf=$(basename "$f")
        if [[ -f "$f" && ! "$sf" =~ ^_ ]]; then
            echo "#\n# File: $sf\n#\n" >>"$output_file"
            grep -v '^\s*#' "$f" | grep -v '^\s*$' >>"$output_file"
            echo "" >>"$output_file"
            ((i++))
        fi
    done
    export concatenate_sh_files_count=$i
}

#
# File: linux.sh
#

function set-warsaw-timezone() {
    if [[ "$(osname)" != "macos" ]]; then
        printhead 'Setting timezone...'
        if [[ "$(cat /etc/timezone | grep -o 'Warsaw')" != "Warsaw" ]]; then
            sudo timedatectl set-timezone Europe/Warsaw
            sudo dpkg-reconfigure -f noninteractive tzdata
        else
            echo "Timezone: $(cat /etc/timezone)"
        fi
    fi
}
function needrestart-mod() {
    filename=/etc/needrestart/needrestart.conf
    if [[ -f $filename ]]; then
        sudo sed -i "s/^#\?\s\?\$nrconf{$1}.*/\$nrconf{$1} = $2;/" $filename
    fi
}
function needrestart-quiet() {
    needrestart-mod verbosity 0
    needrestart-mod systemctl_combine 0
    needrestart-mod kernelhints 0
    needrestart-mod ucodehints 0
}
function needrestart-verbose() {
    needrestart-mod verbosity 1
    needrestart-mod systemctl_combine 1
    needrestart-mod kernelhints 1
    needrestart-mod ucodehints 1
}

#
# File: log.sh
#

LOG_SHOW_ICONS=${LOG_SHOW_ICONS:-1}
LOG_EMOJI_ICONS=${LOG_EMOJI_ICONS:-0}
LOG_COLOR_TEXTS=0
log::color() {
    case "$1" in
        comment) echo "gray" ;;
        empty) echo "white" ;;
        error) echo "bright red" ;;
        warning) echo "yellow" ;;
        info) echo "cyan" ;;
        success) echo "green" ;;
        debug) echo "magenta" ;;
        note) echo "bright blue" ;;
        normal) echo "white" ;;
        *) echo "Invalid log name: $1"; return 1 ;;
    esac
}
log::demo() {
    local e_name="Error"
    local w_name="Warning"
    local i_name="Information"
    local s_name="Success"
    local d_name="Debug"
    local n_name="Note"
    local m_name="Normal"
    local c_name="Comment"
    local green=$(ansi green)
    local yellow=$(ansi yellow)
    local reset=$(ansi reset)
    local sep="\t${yellow}→${reset}\t"
    printf "${green}log::error${reset} $e_name message$sep"
        log::error "$e_name message"
    printf "${green}log::warning${reset} $w_name message$sep"
        log::warning "$w_name message"
    printf "${green}log::info${reset} $i_name message$sep"
        log::info "$i_name message"
    printf "${green}log::success${reset} $s_name message$sep"
        log::success "$s_name message"
    printf "${green}log::debug${reset} $d_name message$sep"
        log::debug "$d_name message"
    printf "${green}log::note${reset} $n_name message    $sep"
        log::note "$n_name message"
    printf "${green}log::comment${reset} $c_name message $sep"
        log::comment "$c_name message"
    printf "${green}log::normal${reset} $m_name message    $sep"
        log::normal "$m_name message"
}
log::icon() {
    if (( $LOG_SHOW_ICONS == 0 )); then
        echo ""
    else
        local emoji_prefix=""
        local emoji_suffix=""
        local symbol_prefix="["
        local symbol_suffix="]"
        local ps_color="gray"
        local prefix_color="$(ansi $ps_color)"
        local suffix_color="$(ansi $ps_color)"
        local reset="$(ansi reset)"
        local color=""
        case "$1" in
            comment) color=$(log::color comment) ;;
            empty) color=$(log::color empty) ;;
            error) color=$(log::color error) ;;
            warning) color=$(log::color warning) ;;
            info) color=$(log::color info) ;;
            success) color=$(log::color success) ;;
            debug) color=$(log::color debug) ;;
            note) color=$(log::color note) ;;
            *) echo "Invalid color name: $1"; return 1 ;;
        esac
        color="$(ansi $color)"
        local icon=""
        if (( $LOG_EMOJI_ICONS == 0 )); then
            case "$1" in
                comment) icon='#' ;;
                error) icon='✖' ;;
                warning) icon='▲' ;;
                info) icon='ℹ' ;;
                success) icon='✔' ;;
                debug) icon='❢' ;;
                note) icon='▸' ;;
                *) echo "Invalid icon name: $1"; return 1 ;;
            esac
            local prefix=$prefix_color$symbol_prefix$reset
            local suffix=$suffix_color$symbol_suffix$reset
            icon="$prefix$color$icon$reset$suffix"
        else
            case "$1" in
                error) icon='⛔' ;;
                warning) icon='⚠️' ;;
                info) icon='👉' ;;
                success) icon='✅' ;;
                debug) icon='🔍' ;;
                note) icon='🔹' ;;
                *) echo "Invalid icon name: $1"; return 1 ;;
            esac
            icon="$emoji_prefix$icon$emoji_suffix"
        fi
        echo "$icon "
    fi
}
log::message() {
    if (( $LOG_COLOR_TEXTS == 0 )); then
        shift
        echo "$*"
    else
        local color=""
        case "$1" in
            comment) color=$(log::color comment) ;;
            error) color=$(log::color error) ;;
            warning) color=$(log::color warning) ;;
            info) color=$(log::color info) ;;
            success) color=$(log::color success) ;;
            debug) color=$(log::color debug) ;;
            note) color=$(log::color note) ;;
            normal) color=$(log::color normal) ;;
            *) echo "Invalid color name: $1"; return 1 ;;
        esac
        shift
        echo "$(ansi $color)$*$(ansi reset)"
    fi
}
log::log() {
    local type="$1"; shift
    local message="$*"
    local icon
    if [[ $type != "normal" ]]; then
        icon="$(log::icon $type)"
    else
        icon="    "
    fi
    message="$(log::message $type $message)"
    printf "$icon$message\n"
}
log::comment() { log::log comment "$*"; }
log::error()   { log::log error "$*"; }
log::err()     { log::log error "$*"; }
log::fail()    { log::log error "$*"; }
log::warn()    { log::log warning "$*"; }
log::warning() { log::log warning "$*"; }
log::info()    { log::log info "$*"; }
log::success() { log::log success "$*"; }
log::ok()      { log::log success "$*"; }
log::debug()   { log::log debug "$*"; }
log::note()    { log::log note "$*"; }
log::normal()  { log::log normal "$*"; }
log::msg()     { log::log normal "$*"; }

#
# File: net.sh
#

wanip() {
    local ipv6 verbose timeout=1 ip service
    local -a services_v4 services_v6
    while [[ "$1" == -* ]]; do
        case "$1" in
            -6) ipv6=1 ;;
            -v) verbose=1 ;;
            -t) timeout="$2"; shift ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
        shift
    done
    services_v4=(
        "icanhazip.com:curl -4 -fsS -m $timeout https://icanhazip.com"
        "ifconfig.me:curl -4 -fsS -m $timeout https://ifconfig.me/ip"
        "ipify.org:curl -4 -fsS -m $timeout https://api.ipify.org"
        "ipecho.net:curl -4 -fsS -m $timeout https://ipecho.net/plain"
        "OpenDNS:dig +short -4 myip.opendns.com @resolver1.opendns.com"
        "Akamai:dig +short -4 whoami.akamai.net @ns1-1.akamaitech.net"
    )
    services_v6=(
        "icanhazip.com:curl -6 -fsS -m $timeout https://icanhazip.com"
        "ifconfig.me:curl -6 -fsS -m $timeout https://ifconfig.me/ip"
        "ipify.org:curl -6 -fsS -m $timeout https://api6.ipify.org"
        "ipv6.icanhazip.com:curl -6 -fsS -m $timeout https://ipv6.icanhazip.com"
    )
    local -a services
    if [[ -n "$ipv6" ]]; then
        services=("${services_v6[@]}")
        ip_regex='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^([0-9a-fA-F]{0,4}:){1,7}:[0-9a-fA-F]{0,4}$|^([0-9a-fA-F]{0,4}:){1,7}:$|^:([0-9a-fA-F]{0,4}:){1,7}$|^::$|^::([0-9a-fA-F]{0,4}:){1,7}$|^([0-9a-fA-F]{0,4}:){1,7}::$'
    else
        services=("${services_v4[@]}")
        ip_regex='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
    fi
    for service_info in "${services[@]}"; do
        service_name=${service_info%%:*}
        service_cmd=${service_info#*:}
        ip=$(eval "$service_cmd" 2>/dev/null)
        if [[ $ip =~ $ip_regex ]]; then
            if [[ -n "$verbose" ]]; then
                echo "IP found using $service_name: $ip" >&2
            fi
            echo "$ip"
            return 0
        fi
    done
    [[ -n "$verbose" ]] && echo "Failed to retrieve public IP address" >&2
    return 1
}
lanip() {
    local ipv6 interface all_ips
    local result=""
    while [[ "$1" == -* ]]; do
        case "$1" in
            -6) ipv6=1 ;;
            -i) interface="$2"; shift ;;
            -a) all_ips=1 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
        shift
    done
    local ip_family="inet"
    local localhost_pattern="^127\."
    local ip_cmd_args=""
    if [[ -n "$ipv6" ]]; then
        ip_family="inet6"
        localhost_pattern="^::1"
    fi
    if [[ -n "$interface" ]]; then
        ip_cmd_args="dev $interface"
    fi
    if (( $+commands[ip] )); then
        if [[ -n "$all_ips" ]]; then
            result=$(ip -f $ip_family addr show $ip_cmd_args 2>/dev/null | awk -v pattern="$localhost_pattern" '$1 == "inet" || $1 == "inet6" {gsub(/\/.*$/, "", $2); if ($2 !~ pattern) print $2}')
        else
            result=$(ip -f $ip_family addr show $ip_cmd_args 2>/dev/null | awk -v pattern="$localhost_pattern" '$1 == "inet" || $1 == "inet6" {gsub(/\/.*$/, "", $2); if ($2 !~ pattern) {print $2; exit}}')
        fi
    elif (( $+commands[ifconfig] )); then
        if [[ -n "$interface" ]]; then
            if [[ -n "$all_ips" ]]; then
                result=$(ifconfig "$interface" 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2}')
            else
                result=$(ifconfig "$interface" 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2; exit}')
            fi
        else
            if [[ -n "$all_ips" ]]; then
                result=$(ifconfig 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2}')
            else
                result=$(ifconfig 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2; exit}')
            fi
        fi
    elif (( $+commands[hostname] )); then
        if [[ -n "$ipv6" ]]; then
            result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9a-fA-F:]+$/ && $i !~ /^::1/) print $i}')
            if [[ -n "$all_ips" ]]; then
                :
            else
                result=$(echo "$result" | head -n 1)
            fi
        else
            if [[ -n "$all_ips" ]]; then
                result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i !~ /^127\./) print $i}')
            else
                result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i !~ /^127\./) {print $i; exit}}')
            fi
        fi
    fi
    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

#
# File: omz.sh
#

function omzversion() {
    if [[ "$(isomzinstalled)" -eq "1" ]]; then
        printf "${green}oh-my-zsh ${yellow}$(omz version)$reset is installed in ${purple}$ZSH${reset}\n"
        return 0
    else
        printf "${green}oh-my-zsh$reset is no installed.\n"
        return 1
    fi
}
function isomzinstalled() {
    if [[ -d $ZSH ]] && [[ $(omz version | grep -o 'master' | head -1) = 'master' ]];
    then echo 1; else echo 0; fi
}
function installomzplugin() {
    if [[ "$(isomzinstalled)" -eq "1" ]]; then
        local repo=https://github.com/zsh-users/$1.git
        local pdir=$ZSH_CUSTOM/plugins/$1
        printhead "Installing $1"
        [[ -d $pdir ]] && rm -rf $pdir
        git clone $repo $pdir
    else
        printf "${green}oh-my-zsh$reset is not installed.\n"
        return 1
    fi
}

#
# File: os.sh
#

function osname() {
    local ostype=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ $ostype == 'darwin' ]]; then
        printf "macos"
    elif [[ $ostype == 'linux' ]]; then
        if [[ -f /etc/os-release ]]; then
            local id=$(cat /etc/os-release | grep "^ID=")
            printf "${id#*=}"
        fi
    else
        printf "unknown"
    fi
}
function osName() {
    local osName=""
    case $(osname) in
        macos) echo "macOS" ;;
        ubuntu) echo "Ubuntu" ;;
        debian) echo "Debian" ;;
        *) echo "unknown" ;;
    esac
}
function oscodename() {
    local codename=""
    if [[ $(osname) == 'macos' ]]; then
        codename=$(macosname)
    else
        codename=$(awk -F= '/^VERSION_CODENAME=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
    fi
    echo "${(C)codename}"
}
function macosname() {
    local version=$(sw_vers -productVersion)
    local version="10.5"
    local major=$(echo $version | cut -d. -f1)
    case $major in
        26) printf "Tahoe" ;;
        15) printf "Seqouia" ;;
        14) printf "Sonoma" ;;
        13) printf "Ventura" ;;
        12) printf "Monterey" ;;
        11) printf "Big Sur" ;;
        10) 
            local minor=$(echo $version | cut -d. -f2)
            case $minor in
                16) printf "Big Sur" ;;
                15) printf "Catalina" ;;
                14) printf "Mojave" ;;
                13) printf "High Sierra" ;;
                12) printf "Sierra" ;;
                11) printf "El Capitan" ;;
                10) printf "Yosemite" ;;
                9)  printf "Mavericks" ;;
                8)  printf "Mountain Lion" ;;
                7)  printf "Lion" ;;
                6)  printf "Snow Leopard" ;;
                5)  printf "Leopard" ;;
                *)  printf "Unknown" ;;
            esac
            ;;
        *)  printf "Unknown" ;;
    esac
}
function osversion() {
    local osver=""
    if [[ $(osname) == "macos" ]]; then
        osver=$(sw_vers -productVersion)
    else
        osver=$(awk -F= '/^VERSION_ID=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
    fi
    echo $osver
}
function osicon() {
    case $(osname) in
        macos) printf "\Uf8ff" ;;
        ubuntu) printf "\Uf31b" ;;
        debian) printf "\Uf306" ;;
        redhat) printf "\Uef5d" ;;
        *) printf "" ;;
    esac
}
function uptimeh() {
    local uptime=0 boot_timestamp=0 current_timestamp=0
    if [[ $(osname) == "macos" ]]; then
        boot_timestamp=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
        current_timestamp=$(date +%s)
        uptime=$((current_timestamp - boot_timestamp))
    else
        uptime=$(awk '{printf "%d\n", $1}' /proc/uptime)
    fi
    echo "$(htime $uptime)"
}

#
# File: print.sh
#

function print::arr() {
    local input="$1"
    if [[ ! $input == *"typeset -"[aA]* ]]; then
        print -u2 "Error: Unsupported array serialization type."
        return 1
    fi
    local array_type="${${input#*typeset -}%% *}"
    local array_name="${${input#*typeset -[aA] }%%=*}"
    local array_content="${${${input#*=}#\(}%\)}"
    [[ "$array_content" =~ ^[[:space:]]*$ ]] && array_content=""
    if [[ $array_type == "A" ]]; then
        local -A arr
        local array_desc="associative array"
    else
        local -a arr
        local array_desc="indexed array"
    fi
    if [[ -n $array_content ]]; then
        eval "arr=($array_content)" 2>/dev/null || {
            print -u2 "Error: Failed to deserialize the $array_desc."
            return 1
        }
        if [[ $array_type == "a" ]]; then
            local -a arr_temp=("${arr[@]}")
            unset arr
            local -A arr
            for i in {1..$#arr_temp}; do
                arr[$i]=${arr_temp[i]}
            done
        fi 
    fi
    local array_len=${#arr}
    print "Array name: $array_name"
    print "Array type: $array_desc"
    print "Array length: $array_len"
    for key in ${(ko)arr}; do
        print "$key: ${arr[$key]}"
    done
}
function print::header() {
    printf "\n$(ansi bold white)%s$(ansi reset)\n" "$(print::line "$*")";
}
function print::footer() {
    printf "$(ansi bold white)%s$(ansi reset)\n\n" "$(print::line "$*")";
}
function print::line() {
    local TOTAL_CHARS=60
    local total=$TOTAL_CHARS-2
    local size=${#1}
    local left=$((($total - $size) / 2))
    local right=$(($total - $size - $left))
    local hs='─' # header symbol
    printf "%${left}s" '' | tr ' ' $hs
    printf " $1 "
    printf "%${right}s" '' | tr ' ' $hs
}
function print::title() {
    local str=$1; local len=${#str}; local lc="─"
    local tl="┌──"; local tr="──┐";
    local ml="│  "; local mr="  │"
    local bl="└──"; local br="──┘";
    local ll=$(printf "%${len}s" | sed "s/ /${lc}/g")
    printf "$tl$ll$tr\n$ml$redi$str$reset$mr\n$bl$ll$br\n"
}
function printh() {
    output="\n${yellowb}"$*"${reset}\n"
    printf "$output"
}
function printh2() {
    printf "\n$(ansi bold bright yellow)%s$(ansi reset)\n" "$*";
}
function printe() {
    output="${redb}"$*"${reset}\n"
    printf "$output"
}
function printc() {
    output="${cyani}"$*"${reset}\n"
    printf "$output"
}
function printb() {
    output="${bluei}"$*"${reset}\n"
    printf "$output"
}
function printi() {
    output="${greeni}"$*"${reset}\n"
    printf "$output"
}
function printp() {
    output="${purplei}"$*"${reset}\n"
    printf "$output"
}
function printw() {
    output="${whitei}"$*"${reset}\n"
    printf "$output"
}
function printr() {
    output="${redi}"$*"${reset}\n"
    printf "$output"
}
function printy() {
    output="${yellowi}"$*"${reset}\n"
    printf "$output"
}
printhead() {
    printh "$@"
}
printtitle() {
    print::title "$@"
}
printinfo() {
    printi "$@"
}
printerror() {
    printe "$@"
}

#
# File: shell.sh
#

function shellname() {
    case "$(ps -p $$ -o comm=)" in
    *zsh) echo "zsh" ;;
    *bash) echo "bash" ;;
    *) echo "unknown" ;;
    esac
}
function shellver() {
    if [[ $(shellname) == 'zsh' ]]; then
        local version=$(zsh --version)
    elif [[ $(shellname) == 'bash' ]]; then
        local version=$(bash --version)
        version="${version#*version }"
    else
        echo "extractver: unknown shell"
        return 1
    fi
    echo $(extract_version $version)
}
function get_default_shell() {
    if [[ "$(uname)" = "Darwin" ]]; then
        USER_SHELL=$(dscl . -read /Users/$(whoami) UserShell | awk '{print $2}')
    else
        USER_SHELL=$(getent passwd $(whoami) | awk -F: '{print $7}')
    fi
    echo $(basename $USER_SHELL)
}
function set_default_shell() {
    local shell=$1 shell_path=$(uwhich $1)
    [[ -z $1 ]] && echo "No shell name provided" && return 1
    [[ ! -x "$shell_path" ]] && echo "Shell '$shell' not found or not executable" && return 1
    [[ "$(get_default_shell)" = "$shell" ]] && echo "Shell '$shell' is already the default shell" && return 1
    if [[ "$(uname)" = "Darwin" ]]; then
        sudo dscl . -create /Users/$(whoami) UserShell $shell_path
    else
        sudo usermod -s $shell_path $(whoami)
    fi
}

#
# File: test.sh
#

function test_print_arr() {
    local podstawowa_tablica
    podstawowa_tablica=("Pierwszy element" "Drugi element" "Trzeci element")
    log::info "Podstawowa zwykła tablica"
    print::arr "$(typeset -p podstawowa_tablica)"
    local -A dane_osobowe
    dane_osobowe[imie]="Anna"
    dane_osobowe[nazwisko]="Kowalska"
    dane_osobowe[wiek]="25"
    dane_osobowe[miasto]="Kraków"
    log::info "\nPodstawowa tablica asocjacyjna:"
    print::arr "$(typeset -p dane_osobowe)"
    local pusta_zwykla=()
    log::info "\nPusta zwykła tablica:"
    print::arr "$(typeset -p pusta_zwykla)"
    local -A pusta_asocjacyjna=()
    log::info "\nPusta tablica asocjacyjna:"
    print::arr "$(typeset -p pusta_asocjacyjna)"
}
function fn_template_bad() {
    local -A a; local -A f; local -A o; local -A s
    o[something]="s,0,some other option"
    o[something2]="ss,0,some other option"
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}

#
# File: text.sh
#

text::lower() {
    [[ -z "$1" ]] && echo "Usage: to_lower <string>" && return 1
    echo "$(echo "$1" | tr '[:upper:]' '[:lower:]')"
}
alias to_lower=text::lower
text::upper() {
    [[ -z "$1" ]] && echo "Usage: to_upper <string>" && return 1
    echo "$(echo "$1" | tr '[:lower:]' '[:upper:]')"
}
alias to_upper=text::upper
text::alphanumeric() {
    [[ -z "$1" ]] && echo "Usage: remove_symbols <string>" && return 1
    echo "$1" | tr -d '[:punct:][:space:]' | tr '[:upper:]' '[:lower:]'
}
alias remove_symbols=text::alphanumeric

#
# File: varia.sh
#

function fman() {
    man -k . | fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}
function dlunzip() {
    if [ $# -ne 2 ]; then
        echo "dlunzip (download and extract)"
        echo "Usage: dlunzip <url> <folder>"
        return 1
    fi
    url="$1"
    folder="$2"
    [[ ! $folder == /* ]] && folder="$(pwd)/$folder"
    [[ -z "$TEMP" ]] && tempdir="$HOME/.temp" || tempdir="$DLDIR"
    filename=$(basename "$url")
    tempfile="$tempdir/$filename"
    extdir="${folder}/$(basename $filename .zip)"
    mkdir -p "$folder"
    mkdir -p "$tempdir" && cd $_
    wget -q $url
    if [ $? -ne 0 ]; then
        echo "Failed to download $url"
        return 1
    fi
    unzip -q $tempfile -d $folder
    if [ $? -ne 0 ]; then
        echo "Failed to extract $tempfile to $folder"
        return 1
    fi
    rm $tempfile
    echo $extdir
}
function sysupdate() {
    printhead "Updating system..."
    if [[ ! "$(osname)" == "macos" ]]; then
        envopt="NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive"
        aptopt="-qq"
        filter1='^Hit|^Get'
        filter2='^NEEDRESTART|^update|Reading'
        sudo apt-get update | grep -Ev $filter1
        sudo $envopt apt-get $aptopt upgrade | grep -Ev $filter2
        sudo $envopt apt-get $aptopt dist-upgrade
        sudo apt-get $aptopt clean
        sudo apt-get $aptopt autoclean
        sudo apt-get $aptopt autoremove
        sudo sync
    fi
    if [[ $(isinstalled brew) -eq 1 ]]; then
        brew update --auto-update
        brew upgrade
        brew cleanup
    fi
    log::info "System updated."
}
function minimize-login-info() {
    if [[ "$(osname)" != "macos" ]]; then
        if [[ "$(osname)" == "ubuntu" ]]; then
            sudo chmod -x /etc/update-motd.d/00-header
            sudo chmod -x /etc/update-motd.d/10-help-text
            sudo chmod -x /etc/update-motd.d/50-motd-news
        elif [[ "$(osname)" == "debian" ]]; then
            sudo chmod -x /etc/update-motd.d/10-uname
        fi
        sudo ln -sf ~/GitHub/config/motd/05-header /etc/update-motd.d
    fi
    touch "$HOME/.hushlogin"
}

