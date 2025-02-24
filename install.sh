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
        printinfo "Usage: installapp <cli-name> [brew-name] [pkg-name] [app-name]"
        return 1
    elif [[ $# -gt 4 ]]; then
        log::error "Too many arguments."
        printinfo "Usage: installapp <cli-name> [brew-name] [pkg-name] [app-name]"
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