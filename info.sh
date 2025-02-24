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
        als="${green}$cliname${reset} $msg ${purple}$(alias $cliname | sed "s/.*=//")${reset}"
        echo -e "$als"
    fi
    if [[ $type = 'function' || $type = 'keyword' || $type = 'builtin' ]]; then
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