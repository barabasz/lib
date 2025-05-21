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


# Full function template
function fn_test() {
    # f = properties, a - arguments, o - options, s - strings, t - this
    local -A f; local -A o; local -A a; local -A s; local -A t
    # Define function properties
    f[info]="Template for functions." # info about the function
    f[version]="0.25" # version of the function
    f[date]="2025-05-20" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    # Define arguments (in order in which they should be passed)
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    a[3]="agrument3,o,description of the third argument"
    a[4]="agrument4,o,description of the fourth argument"
    # Define extra options (default are: info, help, version, debug)
    o[verbose]="V,0,enable verbose mode"
    # Run fn_make() to parse arguments and options
    fn_make "$@"
    [[ "$o[debug]" == "1" ]] && fn_debug # show debug info
    [[ -n "${f[return]}" ]] && return "${f[return]}"
### main function
    echo "This is the output of the $s[name] function."
}

# Full function template
function fn_test2() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
### main function
    echo "This is the output of the $s[name] function."
}