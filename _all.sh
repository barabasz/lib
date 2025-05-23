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

function fn_make() {
    fn_load_colors
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "${c}fn_make$x function cannot be called directly"
        return 1
    fi
    local -A a_name; local -A a_req; local -A a_help
    local -A o_default; local -A o_short; local -A o_long; local -A o_help
    local -A e_msg; local -A e_hint
    fn_set_properties
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
            log::error "$value" && [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]"
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
    f[time_fnmake_start]=$(fn_get_timestamp)
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
function fn_get_timestamp() {
    if which gdate >/dev/null 2>&1; then
        echo $(gdate +%s%3N)
    else
        echo $(date +%s)
    fi
}
function fn_set_time() {
    local time_end=$(fn_get_timestamp)
    local time_diff=$((time_end - f[time_fnmake_start]))
    f[time_fnmake]=$time_diff
    unset "f[time_fnmake_start]"
}
function fn_usage() {
    local i=1 usage=""
    usage+="${y}Usage details:$x\n\t$s[name] "
    if [[ ${#a} -ne 0 ]]; then
        usage+="${p}[options]${x} "
    fi
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
        usage+="\n${y}Required arguments:$x\n\t"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "required" ]]; then
                usage+="$i: $c$arg$x\t- $a_help[$arg]\n\t";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ $f[args_opt] -ne 0 ]]; then
        usage+="\n${y}Optional arguments:$x\n\t"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "optional" ]]; then
                usage+="$i: $c$arg$x\t- $a_help[$arg]\n\t";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ $f[opts_max] -ne 0 && ${#o_long} -ne 0 && ${#o_help} -ne 0 ]]; then
        usage+="\n${y}Options:$x\n\t"
        for opt in ${(ok)o_long}; do
            usage+="-$p$o_long[$opt]$x or ${p}--${opt}$x\t- $o_help[$opt]\n\t";
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ ${#arr_opts[@]} -ne 0 ]]; then
        usage+="\n${y}Options:$x\n\t"
        for opt in "${arr_opts[@]}"; do
            usage+="$p-$opt[1,1]$x or $p--$opt$x\n\t";
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ $f[args_max] -gt 1 ]]; then
        usage+="\n\nArguments must be provided in the specified sequence."
    fi
    if [[ $f[args_opt] -gt 1 ]]; then
        usage+="\nTo skip an argument, pass an empty value $c\"\"$x (only valid for optional arguments)."
    fi
    if [[ $f[opts_max] -gt 0 ]]; then
        usage+="\nOptions may be submitted in any place and in any order."
        usage+="\nTo pass a value to a supported options, use the syntax ${p}option=value$x."
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
    [[ $o[help] == 1 ]] && printf "\n"
    printf "${y}Usage example:$x" 
    [[ $o[help] == 1 ]] && printf "\n\t" || printf " "
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
    local expected
    if [[ $f[args_min] -eq $f[args_max] ]]; then
        expected="expected $f[args_min]"
    else
        expected="expected $f[args_min] to $f[args_max]"
    fi
    local given="given $f[args_count]"
    if [[ $f[args_max] -eq 0 && $f[args_count] -gt 0 ]]; then
        echo "No arguments expected ($given)"
        f[err_arg]=1 && f[err_arg_type]=1
    elif [[ $f[args_count] -eq 0 && $f[args_max] -eq 1 ]]; then
        echo "Missing required argument ($expected)"
        f[err_arg]=1 && f[err_arg_type]=
    elif [[ $f[args_count] -eq 0 ]]; then
        echo "Missing required arguments ($expected)"
        f[err_arg]=1 && f[err_arg_type]=2
    elif [[ $f[args_count] -lt $f[args_min] ]]; then
        echo "Not enough required arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=3
    elif [[ $f[args_count] -gt $f[args_max] ]]; then
        echo "Too many arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=4
    fi
}
function fn_parse_arguments() {
    local used_opts="" # List of used options
    local i=0 ai=0 oi=0
    for arg in "$@"; do
        ((i++))
        local argc="'$y$arg$x'"
        local argname="${arg//-}" && argname="${argname%%=*}"
        local argnamec="$y$argname$x"
        if [[ $arg == -* ]]; then
            ((oi++)); local oic="$y$oi$x"
            f[opts_input]+="$arg "
            local dashes=${#arg%%[![-]*}
            if [[ $dashes -gt 2 ]]; then
                e_msg[o$i]="Option $oic has too many leading dashes in $argc"
                if [[ ${#argname} == 1 ]]; then
                    e_hint[o$i]="Short option name must be preceded by one dash."
                    e_hint[o$i]+=" Did you mean '${y}-${argname}$x'?"
                else
                    e_hint[o$i]="Full option name must be preceded by two dashes."
                    e_hint[o$i]+=" Did you mean '${y}--${argname}$x'?"
                fi
                ((i++))
            fi
            local equals=${#arg//[^=]/}
            if [[ $equals -gt 1 ]]; then
                e_msg[o$i]="Option $oic has too many equal signs in $argc"
                e_hint[o$i]="Optional value must be passed in the form of '${y}--option=value$x' or '${y}-o=value$x'"
                ((i++))
            fi
            local namelen=${#${${arg##*-}%%=*}}
            if [[ $namelen -eq 0 ]]; then
                e_msg[o$i]="Option $oic has empty name in $argc"
                ((i++))
            fi
            if [[ $dashes -eq 2 && $namelen -eq 1 ]]; then
                e_msg[o$i]="Option $oic name must be longer than 1 character in $argc"
                e_hint[o$i]="Two dashes must be followed by full option name. Did you mean '${y}-${arg[-1]}$x'"
                if [[ $o_short[${arg[-1]}] ]]; then
                    e_hint[o$i]+=" or '--$o_short[${arg[-1]}]'"
                fi
                e_hint[o$i]+="?"
                ((i++))
            fi
            if [[ $dashes -eq 1 && $namelen -gt 1 ]]; then
                e_msg[o$i]="Option $oic name is too long in $argc"
                e_hint[o$i]="Short names must be exactly 1 character long. Did you mean '-${arg:1:1}'?"
                continue
            fi
            arg="${arg//-}"
            local name="${arg%%=*}"
            if [[ $dashes -eq 1 ]]; then
                if [[ -z "${o_short[$name]}" ]]; then
                    e_msg[o$i]="Option $oic short name $y$name$x unknown in $argc"
                    continue
                else
                    name="${o_short[$name]}"
                fi
            fi
            if [[ $dashes -eq 2 ]]; then
                if [[ -z "${o[$name]}" ]]; then
                    e_msg[o$i]="Option $oic full name $y$name$x unknown in $argc"
                    continue
                fi
            fi
            if [[ $arg == *"="* ]]; then
                value="${arg#*=}"
            else
                value=$o_default[$name]
            fi
            if [[ ${#argname} != 0 && $used_opts == *"$name"* ]]; then
                e_msg[o$i]="Option $oic name '$argnamec' in $argc was already used as "
                if [[ ${#argname} -eq 1 ]]; then
                    e_msg[o$i]+="'${y}--$o_short[$argname]$x'"
                else
                    e_msg[o$i]+="'${y}-$o_long[$argname]$x'"
                fi
                continue
            fi
            o[$name]=$value
            used_opts+="$name "
        else
            ((ai++)); local aic="$y$ai$x"
            f[args_input]+="'$arg' "
            if [[ $a_req[$a_name[$ai]] == "required" && -z $arg ]]; then
                e_msg[a$i]="Argument $aic ($y$a_name[$ai]$x) cannot be empty"
            fi
            if [[ $a_name[$ai] ]]; then
                a[$a_name[$ai]]="$arg"
            else
                a[$ai]="$arg"
            fi
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
function fn_load_colors() {
    b=$(ansi blue)
    c=$(ansi cyan)
    g=$(ansi green)
    p=$(ansi bright purple)
    r=$(ansi red)
    w=$(ansi white)
    y=$(ansi yellow)
    x=$(ansi reset)
}
function fn_add_defaults() {
    [[ -z ${o[info]} ]] && o[info]="i,1,show basic info and usage"
    [[ -z ${o[help]} ]] && o[help]="h,1,show full help"
    [[ -z ${o[version]} ]] && o[version]="v,1,show version"
    [[ -z ${o[debug]} ]] && o[debug]="d,f,enable debug mode (use ${c}-d=h$x for help)"
    [[ -z ${o[verbose]} ]] && o[verbose]="V,1,enable verbose mode"
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
            ((f[args_min]++))
        else
            a_req[${settings[1]}]=optional
            ((f[args_opt]++))
        fi
        a_help[${settings[1]}]="${settings[3]}"
        unset "a[$key]"
        a[${settings[1]}]=""
    done
    for key in ${(ok)o}; do
        local value="${o[$key]}"
        local settings=(${(s:,:)value})
        if [[ ${#settings} -ne 3 ]]; then
            e_msg[$key]="Invalid settings for option '$y$key$x' in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have 3 values/2 commas)"
            continue
        fi
        if [[ -n ${o_short[${settings[1]}]+_} ]]; then
            echo "Error: Option short name '${settings[1]}' already used in '$key' ($value)"
            f[return]=1 && return 1
        fi
        if [[ ${#settings[1]} -ne 1 ]]; then
            echo "Error: Short option name must be exactly one letter in '$key' ($value)"
            f[return]=1 && return 1
        fi 
        o_default[$key]="${settings[2]}"
        o_short[${settings[1]}]=$key
        o_long[$key]="${settings[1]}"
        o_help[$key]="${settings[3]}"
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
    local debug=$o[debug]
    if [[ "$debug" && ! $debug =~ "d" ]]; then
        local max_key_length=15
        local max_value_length=40
        local count
        local q="$y'$x"
        local -A modes=(
            [a]="Arguments from $y\$a[]$x array"
            [d]="Disable debugging inside ${g}fn_make$x"
            [D]="Default values for options"
            [e]="Exit after debugging"
            [f]="Function properties from $y\$f[]$x array"
            [h]="Help $y(default)$x"
            [i]="Internal ${g}fn_make$x arrays"
            [o]="Options from $y\$o[]$x array"
            [s]="Strings from $y\$s[]$x array"
            [t]="This function from $y\$t[]$x array"
        )
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
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            echo "Debug modes can be combined, e.g. $c-d=aof$x of $c--debug=aof$x."
            echo "Debuggin of ${g}fn_make$x internal arrays (${c}i$x mode) works only if ${c}d$x is not set."
        fi
        if [[ $debug =~ "D" ]]; then
            [[ ${#o_default} -eq 0 ]] && count="is empty." || count="(${#o_default}):"
            log::info "${y}Options default values${x} from ${g}\$o_default[]$x $count"
            for key value in "${(@kv)o_default}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        if [[ $debug =~ "i" ]]; then
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_name[]$x $count"
            for key value in "${(@kv)a_name}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_req[]$x $count"
            for key value in "${(@kv)a_req}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_help[]$x $count"
            for key value in "${(@kv)a_help}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#o_default} -eq 0 ]] && count="is empty." || count="(${#o_default}):"
            log::info "${y}Options${x} ${g}\$o_default[]$x $count"
            for key value in "${(@kv)o_default}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_short[]$x $count"
            for key value in "${(@kv)o_short}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_long[]$x $count"
            for key value in "${(@kv)o_long}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_help[]$x $count"
            for key value in "${(@kv)o_help}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        if [[ $debug =~ "a" ]]; then
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a[]$x $count"
            for key value in "${(@kv)a}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        if [[ $debug =~ "o" ]]; then
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o[]$x $count"
            for key value in "${(@kv)o}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        if [[ $debug =~ "f" ]]; then
            [[ ${#f} -eq 0 ]] && count="is empty." || count="(${#f}):"
            log::info "${y}Function properties${x} ${g}\$f[]$x $count"
            for key value in "${(@kv)f}"; do
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort
        fi
        if [[ $debug =~ "s" ]]; then
            [[ ${#s} -eq 0 ]] && count="is empty." || count="(${#s}):"
            log::info "${y}Strings${x} ${g}\$s[]$x $count"
            for key value in "${(@kv)s}"; do
                value=$(clean_ansi "$value")
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort
        fi
        if [[ $debug =~ "t" ]]; then
            [[ ${#t} -eq 0 ]] && count="is empty." || count="(${#t}):"
            log::info "${y}This function${x} ${g}\$t[]$x $count"
            for key value in "${(@kv)t}"; do
                value=$(clean_ansi "$value")
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort 
        fi
        print::footer "${r}Debug end$x"
    fi
}

#
# File: fn2.sh
#

function fn_make2() {
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "fn_make must be called from a function"
        return 1
    fi
    local arr_args_required=( $(string_to_words "$f[args_required]") )
    local arr_args_optional=( $(string_to_words "$f[args_optional]") )
    local arr_opts=( $(string_to_words "$f[opts]") )
    f[name]="${funcstack[2]}"
    [[ -z $f[author] ]] && f[author]="gh/barabasz"
    f[file_path]="$(whence -v $f[name] | awk '{print $NF}')"
    f[file_dir]="${f[file_path]%/*}"
    f[file_name]="${f[file_path]##*/}"
    f[args_min]=${#arr_args_required}
    f[args_max]=$(($f[args_min]+${#arr_args_optional}))
    f[opts_max]="${#arr_opts}"
    f[args_count]=0
    f[opts_input]=""
    f[opts_count]=0
    f[return]=""
    for opt in $arr_opts; do
        o[$opt[1,1]]=0
    done
    local i=1
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            f[opts_input]+="$arg "
            opt_long="${arg#${arg%%[^-]*}}"
            opt=${opt_long[1,1]}
            if [[ $arr_opts =~ $opt_long ]]; then
                o[$opt]=1
            else
                [[ -z "$f[err_opt_value]" ]] && f[err_opt_value]=$arg
            fi
            f[opts_count]=$(( f[opts_count] + 1 ))
        else
            f[args_count]=$(( f[args_count] + 1 ))
            a[$i]=$arg
            ((i++))
        fi
    done
    f[opts_input]="${f[opts_input]%" "}"
    [[ $f[err_opt_value] ]] && f[err_opt]=1
    [[ f[args_count] -lt $f[args_min] || $f[args_count] -gt $f[args_max] ]] && f[err_arg]=1
    fn_load_colors
    s[name]="${g}$f[name]$x"
    s[path]="${c}$f[file_path]$x"
    s[author]="${y}$f[author]$x"
    s[year]="${y}${f[date]:0:4}$x"
    [[ $f[err_opt] ]] && s[err_opt]="unknown option $p$f[err_opt_value]$x"
    [[ $f[err_arg] ]] && s[err_arg]="$(fn_check_args)"
    [[ $f[info] ]] && s[header]="$s[name]: $f[info]"
    s[version]="$(fn_version)"
    s[footer]="$(fn_footer)"
    s[example]="$(fn_example)"
    s[source]="$(fn_source)"
    s[usage]="$(fn_usage)"
    s[hint]="$(fn_hint)"
    if [[ "$o[v]" -eq "1" || "$o[i]" -eq "1" || "$o[h]" -eq "1" ]]; then
        if [[ "$o[v]" -eq "1" ]]; then
            echo $s[version]
        elif [[ "$o[i]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            echo $s[example]
        elif [[ "$o[h]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            [[ $f[help] ]] && echo $f[help]
            echo "$s[example]\n$s[usage]\n\n$s[footer]\n$s[source]"
        fi
        f[return]=0 && return 0
    fi
    local err_msg="$x$s[name] error:"
    if [[ $f[err_opt] || $f[err_arg] ]]; then
        [[ $f[err_opt] ]] && log::error "$err_msg $s[err_opt]"
        [[ $f[err_arg] ]] && log::error "$err_msg $s[err_arg]"
        echo "$s[hint]"
        f[return]=2 && return 0
    fi
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
    local major=$(echo $version | cut -d. -f1)
    case $major in
        15) printf "Seqouia" ;;
        14) printf "Sonoma" ;;
        13) printf "Ventura" ;;
        12) printf "Monterey" ;;
        11) printf "Big Sur" ;;
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
function fn_test() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Template for functions." # info about the function
    f[version]="0.25" # version of the function
    f[date]="2025-05-20" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    a[3]="agrument3,o,description of the third argument"
    a[4]="agrument4,o,description of the fourth argument"
    o[verbose]="V,0,enable verbose mode"
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}
function fn_test2() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}
function fn_test_assoc() {
    local -A my_array1
    my_array1=(
        [ala_ma_kota]="Ala ma kota"
        [2]=23
        [key_3]="<div>test</div>"
        [4]="<div>test</div>"
        [cytat]="Litwo, ojczyzno moja! ty jesteś jak zdrowie; ile cię trzeba cenić, ten tylko się dowie, kto cię stracił."
    )
    local my_array2=(
        "Ala ma kota"
        "A kot ma Alę"
        "Ala go kocha"
        "a kot ją wcale"
    )
    print::arr "$(typeset -p my_array1)"
    print::arr "$(typeset -p my_array2)"
}

