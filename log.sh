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
LOG_COLOR_TEXTS=0

# Log colors
log::color() {
    case "$1" in
        comment) echo "gray" ;;
        empty) echo "white" ;;
        error) echo "bright red" ;;
        warning) echo "yellow" ;;
        info) echo "cyan" ;;
        success) echo "green" ;;
        debug) echo "magenta" ;;
        note) echo "bright blue" ;;
        normal) echo "white" ;;
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
    local m_name="Normal"
    local c_name="Comment"

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
    printf "${green}log::comment${reset} $c_name message $sep"
        log::comment "$c_name message"
    printf "${green}log::normal${reset} $m_name message    $sep"
        log::normal "$m_name message"
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
            comment) color=$(log::color comment) ;;
            empty) color=$(log::color empty) ;;
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
                comment) icon='#' ;;
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
            comment) color=$(log::color comment) ;;
            error) color=$(log::color error) ;;
            warning) color=$(log::color warning) ;;
            info) color=$(log::color info) ;;
            success) color=$(log::color success) ;;
            debug) color=$(log::color debug) ;;
            note) color=$(log::color note) ;;
            normal) color=$(log::color normal) ;;
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
    local icon
    if [[ $type != "normal" ]]; then
        icon="$(log::icon $type)"
    else
        icon="    "
    fi
    message="$(log::message $type $message)"
    printf "$icon$message\n"
}

# External functions
log::comment() { log::log comment "$*"; }
log::error()   { log::log error "$*"; }
log::err()     { log::log error "$*"; }
log::fail()    { log::log error "$*"; }
log::warn()    { log::log warning "$*"; }
log::warning() { log::log warning "$*"; }
log::info()    { log::log info "$*"; }
log::success() { log::log success "$*"; }
log::ok()      { log::log success "$*"; }
log::debug()   { log::log debug "$*"; }
log::note()    { log::log note "$*"; }
log::normal()  { log::log normal "$*"; }
log::msg()     { log::log normal "$*"; }
