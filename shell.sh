#!/bin/zsh
#
# Functions for shell detection and information

# Get shell name
function shellname() {
    case "$(ps -p $$ -o comm=)" in
        *zsh) echo "zsh" ;;
        *bash) echo "bash" ;;
        *) echo "unknown" ;;
    esac
}

# Get shell version
function shellver() {
    if [[ $(shellname) == 'zsh' ]]; then
        local version=$(zsh --version)
    elif [[ $(shellname) == 'bash' ]]; then
        local version=$(bash --version)
        version="${version#*version }"
    else
        echo "extractver: unknown shell"
        return 1
    fi
    echo $(extract_version $version)
}

