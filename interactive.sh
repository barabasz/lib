#!/bin/bash

# Function to prompt the user for continuation
# Usage: prompt_continue ["Custom question?"]
prompt_continue() {
    local prompt="${1:-Do you want to continue?}"
    local yn
    
    while true; do
        if [[ -n "$BASH_VERSION" ]]; then
            read -r -p "$prompt (Y/N): " yn
        else
            read -r "yn?$prompt (Y/N): "
        fi
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) echo "Aborted."; return 1 ;;
            "") ;;
            *) echo "Please answer Y or N." ;;
        esac
    done
}
