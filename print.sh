#!/bin/zsh

# Console print library
# https://raw.githubusercontent.com/barabasz/lib/main/print.sh

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

# Print title in frame
function print::title() {
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

# Functions as aliases (for backward compatibility)
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
