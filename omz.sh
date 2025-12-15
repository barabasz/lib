#!/bin/zsh
#
# Functions for oh-my-zsh
# zsh-specific functions - requires zsh, will not work in bash

# Display oh-my-zsh version
function omzversion() {
    if [[ "$(isomzinstalled)" -eq "1" ]]; then
        printf "${green}oh-my-zsh ${yellow}$(omz version)$reset is installed in ${purple}$ZSH${reset}\n"
        return 0
    else
        printf "${green}oh-my-zsh$reset is no installed.\n"
        return 1
    fi
}

# Check if oh-my-zsh is installed
function isomzinstalled() {
    if [[ -d $ZSH ]] && [[ $(omz version | grep -o 'master' | head -1) = 'master' ]];
    then echo 1; else echo 0; fi
}

# Install oh-my-zsh plugin
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
