#!/bin/zsh
#
# This is an ARCHIVE.
# These functions are no longer used in the project.
# They are kept here for reference and history.

# Get shell name
# UNRELIABLE - Use 'shellname' instead
function get_shell() {
    echo $SHELL | xargs basename
}

# Chech if command exists
# UNRELIABLE - Use 'isinstalled' instead
function command_exists() {
   type "$1" &>/dev/null
}

# Information about function parameters
# REPLACED - Use 'argsinfo' instead
function params() {
    echo "Number of parameters: $#"
    echo "Parameters: $@"
    echo "First parameter: $1"
    echo "Second parameter: $2"
    echo "Last parameter: ${@: -1}"
}

# Extract version number from string
# REPLACED - Use 'extract_version' instead
function getver() {
    local verstr=$1
    verstr=$(echo "$verstr" | sed 's/^[^0-9]*//')
    verstr=$(echo "$verstr" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
    echo "$verstr"
}