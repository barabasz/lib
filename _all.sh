#!/bin/zsh

#
# File: /Users/barabasz/lib/ansi.sh
#

#!/bin/zsh
#
# ANSI escape code warper
# https://raw.githubusercontent.com/barabasz/lib/main/ansi.sh
#
# SGR (Select Graphic Rendition) parameters of ANSI escape codes
# man: https://man7.org/linux/man-pages/man4/console_codes.4.html

# Function to display information about the script
ansi::info() {
    \cat << EOF
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

# Function to display help information
ansi::help() {
    ansi::info
    \cat << EOF
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

# Function to display examples
ansi::example() {
    ansi::info
    \cat << EOF
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

# Function to set style
ansi::style() {
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

# Function to reset style
ansi::reset() {
    case "$1" in
        all) mod=0 ;;
        bold|dim) mod=22 ;;
        italic) mod=23 ;;
        underline) mod=24 ;;
        blink) mod=25 ;;
        fastblink) mod=26 ;;
        reverse) mod=27 ;;
        invisible) mod=28 ;;
        strikethrough) mod=29 ;;
        overline) mod=55 ;;
        *) echo "Invalid reset style: $1"; return 1 ;;
    esac
}

# Function to set foreground color {30..37}
ansi::foreground() {
    shift=1
    case "$1" in
        black) color=30 ;;
        red) color=31 ;;
        green) color=32 ;;
        yellow) color=33 ;;
        blue) color=34 ;;
        magenta|purple) color=35 ;;
        cyan) color=36 ;;
        white) color=37 ;;
        rgb) color="38;2;$2;$3;$4"; shift=4 ;;
        8bit) color="38;5;$2"; shift=2 ;;
        default) color=39 ;;
        gray) color=90 ;;
        *) echo "Invalid style or foreground color: $1"; return 1 ;;
    esac
    shift $shift
}

# Function to set background color {40..47}
ansi::background() {
    shift=1
    case "$1" in
        black) bcolor=40 ;;
        red) bcolor=41 ;;
        green) bcolor=42 ;;
        yellow) bcolor=43 ;;
        blue) bcolor=44 ;;
        magenta|purple) bcolor=45 ;;
        cyan) bcolor=46 ;;
        white) bcolor=47 ;;
        default) bcolor=49 ;;
        rgb) bcolor="48;2;$2;$3;$4"; shift=4 ;;
        8bit) bcolor="48;5;$2"; shift=2 ;;
        *) echo "Invalid background color: $1"; return 1 ;;
    esac
}

# Function to set bright foreground color {90..97}
ansi::bright() {
    case "$1" in
        black) color=90 ;;
        red) color=91 ;;
        green) color=92 ;;
        yellow) color=93 ;;
        blue) color=94 ;;
        magenta|purple) color=95 ;;
        cyan) color=96 ;;
        white) color=97 ;;
        *) echo "Invalid bright color name: $1"; return 1 ;;
    esac
}

# Function to generate ANSI code
ansi::code() {
    # ANSI escape code prefix and suffix
    local prefix="\e["
    local suffix="m"

    # ANSI code components
    mod=${mod:+$mod}
    bcolor=${bcolor:+$bcolor}
    color=${color:+$color}

    # Determine the separator for each component
    local sep1=${mod:+${${color:-${bcolor:+;}}:+;}}
    local sep2=${color:+${bcolor:+;}}
    
    # Output the ANSI code
    local ansi_code="${prefix}${mod}${sep1}${bcolor}${sep2}${color}${suffix}"
    unset mod color bcolor
    if [[ $show -eq 1 ]]; then
        echo -n "\\" && echo "${ansi_code:1}"
    else
        echo -n "$ansi_code"
    fi
}

# Function to process styling arguments
ansi::make() {
    # reset
    if [[ "$*" == "reset"* ]]; then
        shift
        if (( $# == 0 )); then
            ansi::reset all
        else
            ansi::reset $1
            shift
        fi
    fi
    # set style or color
    if (( $# > 0 )); then
        # style
        ansi::style $@
        if [[ -n $mod ]]; then
            shift
        fi

        # background
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

        # foreground
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
 
        # background again (when set with foreground)
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

        if (( $# > 0 )); then
            echo "Too many arguments: $@"
            return 1
        fi
    fi
}

# Function process main arguments
ansi::args() {
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

# Main function to handle user input
ansi() {
    eval "ansi::args $*"
}
#
# File: /Users/barabasz/lib/better.sh
#

#!/bin/zsh
#
# Better versions of some functions
# Unless otherwise noted, they work with both bash and zsh

# Better ln command for creating symbolic links
function lns() {
    
    # function properties
    local fname="lns"
    local fargs="<destination> <source>"
    local finfo="$fname info:"
    local ferror="$fname error:"
    local fusage=$(usage $fname $fargs)
    local minargs=2
    local maxargs=2
    
    # argument check
    local args=$(checkargs $minargs $maxargs $#)
    [[ $args != "ok" ]] && log::error $ferror $args && log::info $fusage && return 1

    #main
    local dst="$1"
    local src="$2"
    local dst_c="${cyan}$dst${reset}"
    local src_c="${cyan}$src${reset}"
    local src_dir="$(dirname "$src")"
    local src_dir_c="${cyan}$src_dir${reset}"
    local arr="${yellowi}→${reset}"
    local errors=0

    # Check if both the destination and source are provided as absolute paths.
    if [[ "$dst" != /* ]]; then
        printf "${error} the destination $dst_c must be an absolute path.\n"
        ((errors+=1))
    fi
    if [[ "$src" != /* ]]; then
        printf "${error} the source $src_c must be an absolute path.\n"
        ((errors+=1))
    fi

    # Check if the destination is different from the source
    if [[ "$dst" == "$src" ]]; then
        printf "${error} destination and source cannot be the same.\n"
        ((errors+=1))
    fi

    # Check if the destination exists
    if [[ ! -e "$dst" ]]; then
        printf "${error} destination $dst_c does not exist.\n"
        ((errors+=1))
    fi

    # Check if the destination is readable
    if [[ ! -r "$dst" ]]; then
        printf "${error} destination $dst_c is not readable.\n"
        ((errors+=1))
    fi

    # Check if the destination is a folder or file
    if [[ ! -d "$dst" ]] && [[ ! -f "$dst" ]]; then
        printf "${error} destination $dst_c is neither a directory nor a file.\n"
        ((errors+=1))
    fi

    # Check if the current process can write to the source's folder
    if [[ ! -w "$src_dir" ]]; then
        printf "${error} cannot write to the source's folder $src_dir_c\n"
        ((errors+=1))
    fi

    # Exit if there are errors
    if [[ $errors > 0 ]]; then
        return 1
    fi
    
    # Check if exactly such a symbolic link does not already exist
    if [[ -L "$src" ]] && [[ "$(readlink "$src")" == "$dst" ]]; then
        printf "${info} symbolic link $src_c $arr $dst_c already exists.\n"
        return 0
    fi

    # Remove the existing source (file, folder, or wrong symbolic link)
    if [[ -e "$src" ]]; then
        rm -rf "$src"
        if [[ $? -ne 0 ]]; then
            printf "${error} failed while rmoving $src_c (error rissed by rm).\n"
            return 1
        else
             printf "${info} removed existing source $src_c.\n"
        fi
    fi

    # Create the symbolic link
    ln -s "$dst" "$src"
    if [[ $? != 0 ]]; then
        printf "${error} failed to create symbolic link (error rissed by ln).\n"
        return 1
    else
        printf "${info} created symbolic link: $src_c $arr $dst_c\n"
        return 0
    fi

}

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
    local usage=$(usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(checkargs $minargs $maxargs $#)
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
    local usage=$(usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(checkargs $minargs $maxargs $#)
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
    local args=$(checkargs $f_min_args $f_max_args $#)
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

    if [[ $(osname) == "macos" ]]; then
        
    fi

    echo $1
    return 0
}
#
# File: /Users/barabasz/lib/colors.sh
#

#!/bin/zsh

# ANSI colors for functions
# https://raw.githubusercontent.com/barabasz/lib/main/colors.sh
#
# ⛔ THIS LIB IS OBSOLETE, USE lib/ansi.sh INSTEAD
#

# http://jafrog.com/2013/11/23/colors-in-terminal.html
# https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124

# To list all colors available in 256 color mode with their codes run
# 256-color mode — foreground: ESC[38;5;#m   background: ESC[48;5;#m
# for code in {0..255}
#     do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
# done

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

## clear all
clear='\e[0m'
reset='\e[0m'

## text standard
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'

## text bold
blackb='\e[1;30m'
redb='\e[1;31m'
greenb='\e[1;32m'
yellowb='\e[1;33m'
blueb='\e[1;34m'
purpleb='\e[1;35m'
cyanb='\e[1;36m'
whiteb='\e[1;37m'

## text intensive
blacki='\e[0;90m'
redi='\e[0;91m'
greeni='\e[0;92m'
yellowi='\e[0;93m'
bluei='\e[0;94m'
purplei='\e[0;95m'
cyani='\e[0;96m'
whitei='\e[0;97m'

## text bold intensive
blackbi='\e[1;90m'
redbi='\e[1;91m'
greenbi='\e[1;92m'
yellowbi='\e[1;93m'
bluebi='\e[1;94m'
purplebi='\e[1;95m'
cyanbi='\e[1;96m'
whitebi='\e[1;97m'

## background standard
bgblack='\e[40m'
bgred='\e[41m'
bggreen='\e[42m'
bgyellow='\e[43m'
bgblue='\e[44m'
bgpurple='\e[45m'
bgcyan='\e[46m'
bgwhite='\e[47m'

## background intensive
bgblacki='\e[0;100m'
bgredi='\e[0;101m'
bggreeni='\e[0;102m'
bgyellowi='\e[0;103m'
bgbluei='\e[0;104m'
bgpurplei='\e[0;105m'
bgcyani='\e[0;106m'
bgwhitei='\e[0;107m'

#
# File: /Users/barabasz/lib/fn.sh
#

#!/bin/zsh
#
# Helper functions for the script functions

### FUNCTION TEMPLATE
function __TEMPLATE() {
### function header
    local f_name="tmp" f_args="<agrument>" f_switches=("--help" "--version")
    local f_info="is a template for functions."
    local f_min_args=1 f_max_args=1 f_ver="0.1"
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi purple) r=$(ansi reset)
    local fname="$g${f_name}$r" fargs="$c${f_args}$r"
    [[ -n $f_switches ]] && fargs+=" ${p}[<switches>...]${r}"
    local finfo="$fname $f_info\n" fusage="Usage: $fname $fargs\n"
    [[ -n $f_switches ]] && fusage="${fusage}Switches: ${p}$f_switches${r}\n"
    local fver="$fname version $f_ver\n"
    local args=$(checkargs $f_min_args $f_max_args $#)
    [[ $args != "ok" ]] && log::error "$f_name: $args" && printf $fusage && return 1
    [[ $1 == "--help" ]] && printf "$finfo" && printf "$fusage" && return 0
    [[ $1 == "--version" ]] && printf "$fver" && return 0
    [[ $1 == --* ]] && log::error "$f_name: unknown switch $1" && return 1
### main function
    echo $1
}

# Check number of parameters
function checkargs() {
    if [[ $# -ne 3 ]]; then
        printf "${redi}checkargs error${reset}: not enough arguments (expected 3, given $#)\n"
        printf "checkargs usage: ${yellow}checkargs${reset} ${green}<min> <max> <actual>${reset}\n"
        return 1
    fi

    local min=$1
    local max=$2
    local given=$3
    local msg1=""; local msg2=""

    if [[ $min -gt $max ]]; then
        echo "checkargs: min number of arguments cannot be greater than max"
        return 1
    elif [[ $given -lt 0 ]]; then
        echo "checkargs: actual number of arguments cannot be negative"
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

# Usage message for functions
function usage() {
    local fname=$1 fargs=$2
    printf "$1 usage: ${yellow}$1${reset} ${green}$2${reset}\n"
}
#
# File: /Users/barabasz/lib/helpers.sh
#

#!/bin/zsh
#
# Helper functions for the script functions

# Source file if exists
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

# Display OS name
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

# Get shell name
function shellname() {
    case "$(ps -p $$ -o comm=)" in
        *zsh) echo "zsh" ;;
        *bash) echo "bash" ;;
        *) echo "unknown" ;;
    esac
}

# Execute external script
function extscript() {
    /bin/bash -c "$(curl -fsSL $1)"
}

# Source external file
function extsource() {
    source /dev/stdin <<< "$(curl -fsSL $1)"
}

# Check if the function name starts with an allowed character
# Returns 1 if it does, 0 if it doesn't
check_function_name() {
    local name=$1
    if [[ $name =~ ^[a-zA-Z_] ]]; then
        echo "1" && return 0
    else
        echo "0" && return 1
    fi
}

# Convert unix timestamp to ISO 8601 date
# Returns: ISO 8601 date string in UTC
utime2iso() {
    local timestamp=$1
    date -r $timestamp -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Convert ISO 8601 date to unix timestamp
# Returns: Unix timestamp
iso2utime() {
    local date=$1
    date -j -f "%Y-%m-%dT%H:%M:%SZ" $date "+%s"
}

# Extract URL from a string
# Returns: URL if found, or an error message
extract_url() {
    local input_string=$1
    local url
    if [[ $input_string =~ (https?://[^ ]+) ]]; then
        url="${match[1]}"
        echo "$url" && return 0
    else
        echo "No URL found in the given string." && return 1
    fi
}

# Extracts the path from a string
# Returns the path if found, or an error message
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

# Extract version number from a string
# Returns: Version number if found, or an error message
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

#
# File: /Users/barabasz/lib/info.sh
#

#!/bin/zsh
#
# Functions for information

# Short version info, usage: verinfo cliname appname versioncommand
# Example: verinfo gzip "GNU Zip" --version
function verinfo() {
    # function properties
    local fargs="<cliname> [appname] [versioncommand]"
    local minargs=0
    local maxargs=3
    # argument check
    local thisf="${funcstack[1]}"
    local error="${redi}$thisf error:${reset}"
    local usage=$(usage $thisf $fargs)
    [[ $# -eq 0 ]] && printf "$usage\n" && return 1
    local args=$(checkargs $minargs $maxargs $#)
    [[ $args != "ok" ]] && printf "$error $args\n$usage\n" && return 1

    # check if the command is the same as the last one
    [[ "$1" == "$verinfo_lastcmd" ]] && return 0

    export verinfo_lastcmd="$1"
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
        definition="${definition//[\'\"]}" # remove quotes
        definition="${definition%% *}"     # remove everything after space
        verinfo "$definition"
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

# Display login information
function logininfo() {
    local user=$(whoami)
    local userc=$yellow$user$reset
    local host=$(hostname -s)
    local domain=$(hostname -d)
    [[ -n $domain ]] && host="$host.$domain"
    local hostc=$cyan$host$reset
    local tty=$(tty | sed 's|/dev/||')
    local ttyc="$green$tty$reset"
    local remote=$(who | grep $tty | grep -oE '\([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\)' | tr -d '()')
    [[ -n $remote ]] && local remotec="from $cyan$remote$reset"
    if [[ $(isinstalled ifconfig) -eq 1 ]]; then
        local ip=$green$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2}')$reset
    else
        local ip=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1)
    fi
    local ipc=$green$ip$reset
    printf "Logged in as $userc@$hostc ($ipc) on $ttyc $remotec\n"
}

# Display system info
function sysinfo() {
    local os_kernel=$(uname -r)
    local os_shell=$(shellname)
    local os_shell_ver=$(shellver)
    local os_arch=$(uname -m)
    local os_uptime=$(uptimeh)

    if [[ $(osname) == "macos" ]]; then
        local os_name="macOS"
        local os_version=$(sw_vers -productVersion)
        local os_codename=$(macosname)
    else
        local os_name=$(awk -F= '/^NAME=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
        local os_version=$(awk -F= '/^VERSION_ID=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
        local os_codename=$(awk -F= '/^VERSION_CODENAME=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
    fi
    printf "This is ${yellowi}$os_name${reset} $os_version (${(C)os_codename}) with ${yellow}$os_shell${reset} $os_shell_ver running on ${yellow}$os_arch${reset} for $os_uptime hrs\n"
}

# Show arguments with numbers
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

# Display login files and its order
function loginfiles() {
    printf "Login files: "
    if [[ -z $zsh_files ]]; then
        printf "${redi}error${reset}: zsh_files not found"
        return
    else
        i=1; l=${#zsh_files[@]}
        for file in $zsh_files; do
            f=$(basename $file)
            printf "${cyan}${f#.}${reset}"
            [[ i -lt l ]] && printf " ${yellow}→${reset} "
            ((i++))
        done
    fi
    printf "\n"
}

# Calculate uptime in hours
function uptimeh() {
    if [[ $(osname) == "macos" ]]; then
        boot_timestamp=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
        current_timestamp=$(date +%s)
        uptime_seconds=$((current_timestamp - boot_timestamp))
        printf "%.2f\n" $(echo "$uptime_seconds / 3600" | bc -l)
    else
        printf $(awk '{printf "%.2f\n", $1/3600}' /proc/uptime)
    fi
}
#
# File: /Users/barabasz/lib/install.sh
#

#!/bin/zsh
#
# Functions for installing applications

# Check if programm is installed
function isinstalled() {
    if [[ $(utype $1) == 'file' || "$(uwhich $1)" == /* ]]; then
        echo 1
    else
        echo 0
    fi
}

# Check if package is installed by Brew
function isinstalledbybrew() {
    brew list $1 &>/dev/null
    if [ $? -eq 0 ]; then
        echo 1
    else
        echo 1
    fi
}

# Check if oh-my-zsh is installed
function isomzinstalled() {
    if [[ -d $ZSH ]] && [[ $(omz version | grep -o 'master' | head -1) = 'master' ]];
    then echo 1; else echo 0; fi
}

# Install oh-my-zsh plugin
function installomzplugin() {
    local repo=https://github.com/zsh-users/$1.git
    local pdir=$ZSH_CUSTOM/plugins/$1
    printhead "Installing $1"
    [[ -d $pdir ]] && rm -rf $pdir
    git clone $repo $pdir
}

# apt unattended quiet install
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

# Create symbolic link to config file
function makeconfln() {
    local source=$GHCONFDIR/$1
    local target=$CONFDIR/$1
    local source_c="${cyan}$source${reset}"
    local target_c="${cyan}$target${reset}"
    local arrow="${yellow}→${reset}"
    if [[ -L $target ]] && [[ "$(readlink $target)" = "$source" ]]; then
        echo "symlink $target_c $arrow $source_c exists"
    else
        if [[ -a $target ]]; then
            if [[ -d $target ]]; then
                echo "removing folder $target_c"
            else
                echo "removing file $target_c"
            fi
            rm -r $target
        fi
        ln -sfF $source $target
        echo "symlink $target_c $arrow $source_c created"
    fi
}

# Install application
function installapp() {
    if [[ -z $1 ]]; then
        log::error "No arguments provided."
        printi "Usage: installapp <cli-name> [brew-name] [pkg-name] [app-name]"
        return 1
    elif [[ $# -gt 4 ]]; then
        log::error "Too many arguments."
        printi "Usage: installapp <cli-name> [brew-name] [pkg-name] [app-name]"
        return 1
    fi

    cliname=$1
    brewname=${2:-$1}
    aptname=${3:-$1}
    appname=${4:-$1}
    osname=$(osname)
    isapp=$(isinstalled $cliname)
    isbrew=$(isinstalled brew)

    if [[ "$brewname" == "null" && "$aptname" == "null" ]]; then
        log::error "No package name provided."
        return 1
    elif [[ "$brewname" == "null" && "$osname" == "macos" ]]; then
        log::info "No brew package name provided."
        log::error "$appname is not available for macOS."
        return 1
    elif [[ "$aptname" == "null" && "$brewname" != "null" && "$osname" != "macos" && "$isbrew" -eq 0 ]]; then
        log::error "$appname is not available for Linux without brew."
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
                log::error "Brew is not installed."
                return 1
            fi
        fi
        if [[ $? -eq 0 ]]; then
            log::ok "$appname successfully installed."
        else
            log::error "Failed to install $appname."
            return 1
        fi
    else
        log::info "$appname is already installed."
    fi

    verinfo $cliname
}
#
# File: /Users/barabasz/lib/interactive.sh
#

#!/bin/bash

# Function to prompt the user for continuation
# https://raw.githubusercontent.com/barabasz/lib/main/prompt_continue.sh

prompt_continue() {
  while true; do
      read "yn?Do you want to continue? (Y/N): "
      case $yn in
          [Yy]* ) echo "You chose to continue."; return 0;;
          [Nn]* ) echo "You chose not to continue."; return 1;;
          * ) echo "Please answer Y/y or N/n.";;
      esac
  done
}

#
# File: /Users/barabasz/lib/log.sh
#

#!/bin/zsh

# Simple log library for stdrout
# https://raw.githubusercontent.com/barabasz/lib/main/log.sh

# Color and icon assignments
#
# 1. Error:          red     - critical issues that need immediate attention
# 2. Warning:        yellow  - potential issues that should be noted
# 3. Information:    cyan    - general information or updates
# 4. Success:        green   - successful operations or confirmations
# 5. Debug:          magenta - debugging information
# 6. Note (general): blue    - status updates or non-critical messages
#
# Required: ansi.sh library
#
# Usage: log::success "Success message"
#        log::error "Error message"
#        log::warning "Warning message"
#        log::info "Info message"
#        log::note "Note message"
#        log::demo

# Configuration
LOG_SHOW_ICONS=${LOG_SHOW_ICONS:-1}
LOG_EMOJI_ICONS=${LOG_EMOJI_ICONS:-0}
LOG_COLOR_TEXTS=${LOG_COLOR_TEXTS:-1}

# Log colors
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

# Log demo
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

# Prepare log icon
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

# Prepare log message
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

# Main function
log::log() {
    local type="$1"; shift
    local message="$*"
    local icon="$(log::icon $type)"
    message="$(log::message $type $message)"
    printf "$icon$message\n"
}

# External functions
log::error() {
    log::log error "$*"
}
log::warning() {
    log::log warning "$*"
}
log::info() {
    log::log info "$*"
}
log::success() {
    log::log success "$*"
}
log::debug() {
    log::log debug "$*"
}
log::note() {
    log::log note "$*"
}

# Aliases
alias log::ok=log::success
alias log::err=log::error
alias log::fail=log::error
alias log::warn=log::warning

#
# File: /Users/barabasz/lib/os.sh
#

#!/bin/zsh
#
# Functions for OS detection and shell information

# Display macOS codename
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

# Get shell version
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

# Forcing full system update
function sysupdate() {
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
}
#
# File: /Users/barabasz/lib/print.sh
#

#!/bin/zsh

# Print library
# https://raw.githubusercontent.com/barabasz/lib/main/print.sh

hs='─'        # header
hc='white'    # header
print::header() {
    printf "\n$(ansi bold $hc)%s$(ansi reset)\n" "$(print::line "$*")";
}
print::line() {
    local TOTAL_CHARS=60
    local total=$TOTAL_CHARS-2
    local size=${#1}
    local left=$((($total - $size) / 2))
    local right=$(($total - $size - $left))
    printf "%${left}s" '' | tr ' ' $hs
    printf " $1 "
    printf "%${right}s" '' | tr ' ' $hs
}

# Print title in frame
function printt() {
    local str=$1; local len=${#str}; local lc="─"
    local tl="┌──"; local tr="──┐";
    local ml="│  "; local mr="  │"
    local bl="└──"; local br="──┘";
    local ll=$(printf "%${len}s" | sed "s/ /${lc}/g")
    printf "$tl$ll$tr\n$ml$redi$str$reset$mr\n$bl$ll$br\n"
}

# Print yellow header
function printh() {
    output="\n${yellowb}"$*"${reset}\n"
    printf "$output"
}

function printh2() {
    printf "\n$(ansi bold bright yellow)%s$(ansi reset)\n" "$*";
}

# Print red error
function printe() {
    output="${redb}"$*"${reset}\n"
    printf "$output"
}

# Print cyan info
function printc() {
    output="${cyani}"$*"${reset}\n"
    printf "$output"
}

# Print blue info
function printb() {
    output="${bluei}"$*"${reset}\n"
    printf "$output"
}

# Print green info
function printi() {
    output="${greeni}"$*"${reset}\n"
    printf "$output"
}

# Print purple info
function printp() {
    output="${purplei}"$*"${reset}\n"
    printf "$output"
}

# Print white info
function printw() {
    output="${whitei}"$*"${reset}\n"
    printf "$output"
}

# Print red info
function printr() {
    output="${redi}"$*"${reset}\n"
    printf "$output"
}

# Print yellow info
function printy() {
    output="${yellowi}"$*"${reset}\n"
    printf "$output"
}

alias printhead=printh
alias printtitle=printt
alias printinfo=printi
alias printerror=printe

#
# File: /Users/barabasz/lib/varia.sh
#

#!/bin/zsh

# Resource library files
function relib() {
    local f="" i=0 e=0 t="" t1=$(date +%s%3N) t2=""
    for f in "$LIBDIR"/*.sh; do
        if [[ -f "$f" && ! "$(basename "$f")" =~ ^_ ]]; then
            source "$f"
            if [[ $? -ne 0 ]]; then
                log::error "Failed to load $f" && ((e++))
            else ((i++)); fi
        fi
    done
    t2=$(date +%s%3N)
    t=$((t2 - t1))
    log::info "Loaded $i library *.sh files from $LIBDIR in $t ms"
    [[ $e -ne 0 ]] && return 1 || make_all_file && return 0
}

make_all_file() {
    output_file="${LIBDIR}/_all.sh"
    : >"$output_file"  # Truncate the output file
    echo "#!/bin/zsh\n" >>"$output_file"
    for f in "$LIBDIR"/*.sh; do
        if [[ -f "$f" && ! "$(basename "$f")" =~ ^_ ]]; then
            echo "#\n# File: $f\n#\n" >>"$output_file"
            cat "$f" >>"$output_file"
            echo "" >>"$output_file"
        fi
    done
}

# Search man with fzf
function fman() {
    man -k . | fzf -q "$1" --prompt='man> ' --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
}

# Download and unzip file from URL
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

