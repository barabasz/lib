#!/bin/zsh

# Search man with fzf
function fman() {
    man -k . | fzf -q "$1" --prompt='man> '  --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
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