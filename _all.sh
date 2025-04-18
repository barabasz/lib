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
# File: colors.sh
#

function showcolors() {
    printh "Standard colors"
    printf "${red}red${reset}, ${green}green${reset}, ${yellow}yellow${reset}, ${blue}blue${reset}, ${purple}purple${reset}, ${cyan}cyan${reset}, ${white}white${reset}"
    printh "Intensive colors"
    printf "${redi}red${reset}, ${greeni}green${reset}, ${yellowi}yellow${reset}, ${bluei}blue${reset}, ${purplei}purple${reset}, ${cyani}cyan${reset}, ${whitei}white${reset}"
    printh "Bold colors"
    printf "${redb}red${reset}, ${greenb}green${reset}, ${yellowb}yellow${reset}, ${blueb}blue${reset}, ${purpleb}purple${reset}, ${cyanb}cyan${reset}, ${whiteb}white${reset}"
    printh "Background colors"
    printf "${bgred}   ${reset}, ${bggreen}     ${reset}, ${bgyellow}yellow${reset}, ${bgblue}blue${reset}, ${bgpurple}purple${reset}, ${bgcyan}cyan${reset}, ${bgwhite}white${reset}"
    printh "Intensive background colors"
    printf "${bgredi}red${reset}, ${bggreeni}green${reset}, ${bgyellowi}yellow${reset}, ${bgbluei}blue${reset}, ${bgpurplei}purple${reset}, ${bgcyani}cyan${reset}, ${bgwhitei}white${reset}"
    printf "\n"
}
function showcolors256() {
    printh "256 colors"
    for code in {0..255}
        do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
    done
}
clear='\e[0m'
reset='\e[0m'
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'
blackb='\e[1;30m'
redb='\e[1;31m'
greenb='\e[1;32m'
yellowb='\e[1;33m'
blueb='\e[1;34m'
purpleb='\e[1;35m'
cyanb='\e[1;36m'
whiteb='\e[1;37m'
blacki='\e[0;90m'
redi='\e[0;91m'
greeni='\e[0;92m'
yellowi='\e[0;93m'
bluei='\e[0;94m'
purplei='\e[0;95m'
cyani='\e[0;96m'
whitei='\e[0;97m'
blackbi='\e[1;90m'
redbi='\e[1;91m'
greenbi='\e[1;92m'
yellowbi='\e[1;93m'
bluebi='\e[1;94m'
purplebi='\e[1;95m'
cyanbi='\e[1;96m'
whitebi='\e[1;97m'
bgblack='\e[40m'
bgred='\e[41m'
bggreen='\e[42m'
bgyellow='\e[43m'
bgblue='\e[44m'
bgpurple='\e[45m'
bgcyan='\e[46m'
bgwhite='\e[47m'
bgblacki='\e[0;100m'
bgredi='\e[0;101m'
bggreeni='\e[0;102m'
bgyellowi='\e[0;103m'
bgbluei='\e[0;104m'
bgpurplei='\e[0;105m'
bgcyani='\e[0;106m'
bgwhitei='\e[0;107m'

#
# File: files.sh
#

function rmln() {
    local f_name="rmln" f_file="lib/better.sh"
    local f_args="file_or_dir" f_switches="info"
    local f_info="removes a symbolic link."
    local f_min_args=1 f_max_args=1
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches" compact)"
    local info="$(make_fn_info $header $usage "" compact)" iserror=0
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == -* ]] && log::error "$name: unknown switch $1" && iserror=1
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" && iserror -eq 0 ]] && log::error "$f_name: $args" && iserror=1
    [[ $iserror -ne 0 ]] && echo $usage && return 1
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
function lns() {
    local f_name="lns" f_file="better/_templates.sh"
    local f_args="destination source"
    local f_switches="force info"
    local f_info="creates a symbolic link if such does not yet exist."
    local f_min_args=2 f_max_args=2
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches" compact)"
    local info="$(make_fn_info $header $usage "" compact)"
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == "--force" || $1 == "-f" ]] && local force=1 && shift
    [[ $1 == -* ]] && log::error "$name: unknown switch $purple$1$reset" && return 1
    local args="$(check_fn_args $f_min_args $f_max_args $#)"
    [[ $args != "ok" ]] && log::error "$f_name: $args" && echo $usage && return 1
    local dst="$1"
    local src="$2"
    local dst_c="${cyan}$dst${reset}"
    local src_c="${cyan}$src${reset}"
    local src_dir="$(dirname "$src")"
    local src_dir_c="${cyan}$src_dir${reset}"
    local arr="${yellowi}→${reset}"
    if [[ "$dst" != /* ]]; then
        log::error "$name: the destination $dst_c must be an absolute path."
        return 1
    fi
    if [[ "$src" != /* ]]; then
        log::error "$name: the source $src_c must be an absolute path."
        return 1
    fi
    if [[ "$dst" == "$src" ]]; then
        log::error "$name: destination and source cannot be the same."
        return 1
    fi
    if [[ ! -e "$dst" ]]; then
        log::error "$name: destination $dst_c does not exist."
        return 1
    fi
    if [[ ! -r "$dst" ]]; then
        log::error "$name: destination $dst_c is not readable."
        return 1
    fi
    if [[ ! -d "$dst" ]] && [[ ! -f "$dst" ]]; then
        log::error "$name: destination $dst_c is neither a directory nor a file."
        return 1
    fi
    if [[ ! -w "$src_dir" ]]; then
        log::error "$name: cannot write to the source's folder $src_dir_c"
        return 1
    fi
    if [[ -L "$src" ]] && [[ "$(readlink "$src")" == "$dst" ]]; then
        log::info "$name: symlink $src_c $arr $dst_c already exists."
        return 0
    fi
    if [[ $(realpath "$src") == $(realpath "$dst") ]]; then
        log::error "$name: source and destination are the same file."
        log::info "$name: check for folder symlinks in file paths."
        return 1
    fi
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
    ln -s "$dst" "$src"
    if [[ $? != 0 ]]; then
        log::error "$name: failed to create symbolic link (error rissed by ln).\n"
        return 1
    else
        log::info "$name: symbolic link $src_c $arr $dst_c created.\n"
        return 0
    fi
}
function lnsconfdir() {
    [[ -z $CONFDIR ]] && log::error "CONFDIR is not set" && return 1
    [[ -z $GHCONFDIR ]] && log::error "GHCONFDIR is not set" && return 1
    [[ -z $1 ]] && log::error "No directory provided" && return 1
    lns "$GHCONFDIR/$1" "$CONFDIR/$1"
}
alias makeconfln=lnsconfdir
function utype() {
    local fargs="<command>"
    local minargs=0
    local maxargs=1
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
function uwhich() {
    local fargs="<command>"
    local minargs=0
    local maxargs=1
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

function make_fn_name() {
    local name=$1
    echo "$(ansi green)$name$(ansi reset)"
}
function make_fn_footer() {
    local author=$1 date=$2 version=$3
    echo "$version copyright © 1999-${date:0:4} $(ansi yellow)$author$(ansi reset)"
    echo "MIT License : https://opensource.org/licenses/MIT"
}
function make_fn_errinf() {
    local name=$1 switches=$2 file=$3 c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    [[ "$switches" == *"info"* ]] && echo -n "Run $name ${p}--info$r for usage information." && return 0
    [[ "$switches" == *"help"* ]] && echo -n "Run $name ${p}--help$r for usage information." && return 0
    echo "Check source code for usage information ($c$file$r)."
}
function make_fn_info() {
    local title=$1 usage=$2 footer=$3 compact=$4
    if [[ $compact == "compact" ]]; then
        echo "$title\n$usage"
    else
        echo "$title\n\n$usage\n\n$footer"
    fi
}
function make_fn_version() {
    local name=$1 ver=$2
    printf "$name ver. $(ansi yellow)$ver$(ansi reset)\n\n"
}
function make_fn_header() {
    local name=$1 info=$2
    echo "$name $info"
}
function make_fn_help() {
    local info=$1 help=$2
    [[ -z $help ]] && help="$(ansi red)No help available.$(ansi reset)"
    echo "$info\n\n$help"
}
function make_fn_usage() {
    local name=$1 args=$2 argsopt=$3 switches=$4 compact=$5
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    local usage="Usage: $name "
    args_array=( $(string_to_words "$args") )
    argsopt_array=( $(string_to_words "$argsopt") )
    switches_array=( $(string_to_words "$switches") )
    if [[ $compact == "compact" ]]; then
        if [[ ${#args_array[@]} -ne 0 ]]; then
            usage+="$c"
            for s in "${args_array[@]}"; do 
                usage+="<$s> "
            done
            usage+="$r"
        fi
        if [[ ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="$c"
            for s in "${argsopt_array[@]}"; do 
                usage+="[$s] "
            done
            usage+="$r"
        fi
        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="$p"
            for s in "${switches_array[@]}"; do 
                usage+="[--$s] "
            done
            usage+="$r"
        fi
    else
        [[ ${#switches_array[@]} -ne 0 ]] && usage+="${p}[switches]${r} "
        [[ ${#args_array[@]} -ne 0 ]] && usage+="${c}<arguments>${r}"
        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="\nSwitches: "
            for s in "${switches_array[@]}"; do
                usage+="$p--$s ${r}or$p -${s:0:1}$r, "
            done
            usage="${usage%??}"
        fi
        if [[ ${#args_array[@]} -ne 0 || ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="\nArguments: "
            [[ ${#args_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${args_array[@]}"; do usage+="<$s> "; done } && usage+="$r"
            [[ ${#argsopt_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${argsopt_array[@]}"; do usage+="[$s] "; done } && usage+="$r"
        fi
    fi
    printf "$usage\n"
}
function check_fn_args() {
    [[ $# -ne 3 ]] && log::error "check_fn_args: not enough arguments (expected 3, given $#)" && return 1
    local min=$1
    local max=$2
    local given=$3
    local msg1=""; local msg2=""
    if [[ $min -gt $max ]]; then
        echo "check_fn_args: min number of arguments cannot be greater than max"
        return 1
    elif [[ $given -lt 0 ]]; then
        echo "check_fn_args: actual number of arguments cannot be negative"
        return 1
    fi
    if [[ $given -eq 0 ]]; then
        msg1="no arguments given"
    elif [[ $given -lt $min ]]; then
        msg1="not enough arguments"
    elif [[ $given -gt $max ]]; then
        msg1="too many arguments"
    fi
    if [[ $given -lt $min || $given -gt $max ]]; then
        if [[ $1 == $2 ]]; then
            msg2="expected $min"
        else
            msg2="expected $min to $max"
        fi
        echo "$msg1 ($msg2, given $given)"
        return 1
    fi
    echo "ok"
    return 0
}

#
# File: helpers.sh
#

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
    local dir="$1" output_file="$2" output_dir=$(dirname "$output_file")
    local i=0 sf="" shebang='#!/bin/zsh'
    local c=$(ansi cyan) r=$(ansi reset) g=$(ansi green)
    [[ ! "$dir" = /* ]] && dir="$(pwd)/$dir" # Convert to absolute path if necessary
    [[ ! "$output_dir" = /* ]] && output_dir="$(pwd)/$output_dir"
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
LOG_COLOR_TEXTS=${LOG_COLOR_TEXTS:-1}
log::color() {
    case "$1" in
        error) echo "bright red" ;;
        warning) echo "yellow" ;;
        info) echo "cyan" ;;
        success) echo "green" ;;
        debug) echo "magenta" ;;
        note) echo "bright blue" ;;
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
            error) color=$(log::color error) ;;
            warning) color=$(log::color warning) ;;
            info) color=$(log::color info) ;;
            success) color=$(log::color success) ;;
            debug) color=$(log::color debug) ;;
            note) color=$(log::color note) ;;
            *) echo "Invalid color name: $1"; return 1 ;;
        esac
        shift
        echo "$(ansi $color)$*$(ansi reset)"
    fi
}
log::log() {
    local type="$1"; shift
    local message="$*"
    local icon="$(log::icon $type)"
    message="$(log::message $type $message)"
    printf "$icon$message\n"
}
log::error()    { log::log error "$*"; }
log::err()      { log::log error "$*"; }
log::fail()     { log::log error "$*"; }
log::warn()     { log::log warning "$*"; }
log::warning()  { log::log warning "$*"; }
log::info()     { log::log info "$*"; }
log::success()  { log::log success "$*"; }
log::ok()       { log::log success "$*"; }
log::debug()    { log::log debug "$*"; }
log::note()     { log::log note "$*"; }

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

function print::header() {
    printf "\n$(ansi bold white)%s$(ansi reset)\n" "$(print::line "$*")";
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

