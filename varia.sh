#!/bin/zsh

# Resource library files
function relib() {
    [[ $(isinstalled gdate) -eq 1 ]] && alias date=gdate

    local f="" i=0 e=0 t="" t1="" t2=""
    local c=$(ansi cyan) r=$(ansi reset) y=$(ansi yellow)
    [[ $(osname) == "macos" && $(isinstalled gdate) -eq 0 ]] && t1=$(date +%s) || t1=$(date +%s%3N)

    for f in "$LIBDIR"/*.sh; do
        if [[ -f "$f" && ! "$(basename "$f")" =~ ^_ ]]; then
            source "$f"
            if [[ $? -ne 0 ]]; then
                log::error "Failed to load $f" && ((e++))
            else ((i++)); fi
        fi
    done

    [[ $(osname) == "macos" &&  $(isinstalled gdate) -eq 0 ]] && t2=$(date +%s) || t2=$(date +%s%3N)
    t=$((t2 - t1))
    log::ok "${r}Sourced $y$i$r library *.sh files from $c$LIBDIR$r in $t ms"

    if [[ $e -ne 0 ]]; then
        log::error "Failed to load $e library files"
        log::info "${r}Skipping generating ${c}_all.sh$r file"
        return 1
    else
        [[ $(osname) == "macos" && $(isinstalled gdate) -eq 0 ]] && t1=$(date +%s) || t1=$(date +%s%3N)
        make_all_file
        [[ $(osname) == "macos" &&  $(isinstalled gdate) -eq 0 ]] && t2=$(date +%s) || t2=$(date +%s%3N)
        t=$((t2 - t1))
        log::ok "${r}File $c$LIBDIR/_all.sh$r created in $t ms"
        return 0
    fi
}

# Generate all.sh file (concatenate all files in the lib directory)
make_all_file() {
    output_file="${LIBDIR}/_all.sh"
    : >"$output_file"  # Truncate the output file
    echo "#!/bin/zsh\n" >>"$output_file"
    for f in "$LIBDIR"/*.sh; do
        sf=$(basename "$f")
        if [[ -f "$f" && ! "$sf" =~ ^_ ]]; then
            echo "#\n# File: $sf\n#\n" >>"$output_file"
            grep -v '^\s*#' "$f" | grep -v '^\s*$' >>"$output_file"
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

# Set Warsaw timezone
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