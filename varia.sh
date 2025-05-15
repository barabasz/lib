#!/bin/zsh

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

# Forcing full system update
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

# Minimize login information
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

# Test function for template
function fntest() {
    # $f[] - function properties, $a[] - arguments array, $o[] - options array
    # $s[] - strings array, $t[] - this (main function) variables array
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Template for functions." # info about the function
    f[args_required]="agrument1 argument2" # required arguments
    f[args_optional]="agrument3 agrument4" # optional arguments
    f[opts]="debug help info version example" # optional options
    f[version]="0.2" # version of the function
    f[date]="2025-05-06" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    fn_make "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
### main function
    t[arg1]="${a[1]}" # example argument assignment to this array
    t[this_is_very_long_key_name]="${a[2]}"
    [[ "$o[d]" -eq "1" ]] && fn_debug # show debug info
    echo "This is the output of the $s[name] function."
    echo "This is the first argument: $a[1]"
    echo "This is the secong from this array: $t[this_is_very_long_key_name]"
    echo "This is the path to the function: $s[path]"
    echo "This is 'example' option value: $o[e]"
}

# Super-simple function to test the template
function fntest2() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    f[info]="Super-short function."
    f[opts]="debug help" # optional options
    fn_make "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
### main function
    [[ "$o[d]" -eq "1" ]] && fn_debug # show debug info
    echo "This is the output of the $s[name] function."
}