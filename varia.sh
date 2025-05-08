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

function fntest() {
### function properties
    local f_name="_fn_tpl" # name of the function
    local f_info="is a template for functions." # info about the function
    local f_type="" # empty for normal or "compact"
    local f_file="lib/_templates.sh" # file where the function is defined
    local f_args="agrument1 argument2" # required arguments
    local f_args_opt="agrument3 agrument4" # optional arguments
    local f_switches="debug help info version" # available switches
    local f_author="gh/barabasz" f_ver="0.2" f_date="2025-05-06"
    local f_help="" # content of help
### function strings
    local name="$(make_fn_name $f_name)"
    local header="$(make_fn_header $name $f_info)"
    local usage="$(make_fn_usage $name "$f_args" "$f_args_opt" "$f_switches" $f_type)"
    local errinf="$(make_fn_errinf $name "$f_switches" $f_file)"
    local version="$(make_fn_version $name $f_ver $f_date)"
    local footer="$(make_fn_footer $f_author $f_date $version)"
    local info="$(make_fn_info $header $usage $footer $f_file $f_type)"
    local help="$(make_fn_help $info $f_help)"
    local args="$(check_fn_args $f_args $f_args_opt $#)"
    local iserror=0
### function args and switches
    [[ $1 == "--info" || $1 == "-i" ]] && echo "$info" && return 0
    [[ $1 == "--help" || $1 == "-h" ]] && echo "$help" && return 0
    [[ $1 == "--version" || $1 == "-v" ]] && echo "$version" && return 0
    [[ $1 == "--switch1" || $1 == "-s" ]] && local switch1=1 && shift # example
    [[ $1 == -* ]] && log::error "$name: unknown switch $1" && iserror=1
    [[ $args != "ok" && iserror -eq 0 ]] && log::error "$f_name: $args" && iserror=1
    [[ $iserror -ne 0 ]] && echo $errinf && return 1
### main function
    echo "This is the output of the $name function."
}

function fntest2() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="is a template for functions." # info about the function
    f[args_required]="agrument1" # argument2" # required arguments
    #f[args_optional]="agrument3 agrument4" # optional arguments
    f[opts]="debug help info version example" # optional options
    f[version]="0.2" # version of the function
    f[date]="2025-05-06" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    make_fn "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[options_count]"
### main function
    echo "This is the output of the $s[name] function."
    echo "This is the path to the function: $s[path]"
    echo "This is the first argument: $a[1]"
    echo "This is 'example' option value: $o[e]"
}