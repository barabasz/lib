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

# Generate all.sh file (concatenate all files in the lib directory)
make_all_file() {
    output_file="${LIBDIR}/_all.sh"
    : >"$output_file"  # Truncate the output file
    echo "#!/bin/zsh\n" >>"$output_file"
    for f in "$LIBDIR"/*.sh; do
        if [[ -f "$f" && ! "$(basename "$f")" =~ ^_ ]]; then
            echo "#\n# File: $f\n#\n" >>"$output_file"
            cat "$f" >>"$output_file"
            echo "" >>"$output_file"
        fi
    done
}

# Display login files and its order
# login files must have these lines:
#    local thisfile="XXXXX"
#    zsh_files+=("$thisfile")
# where XXXXX is the name of the file
function loginfiles() {
    printf "Login files: "
    if [[ -z $zsh_files ]]; then
        printf "${redi}error${reset}: zsh_files not found"
        return
    else
        i=1; l=${#zsh_files[@]}
        for file in $zsh_files; do
            f=$(basename $file)
            printf "${cyan}${f#.}${reset}"
            [[ i -lt l ]] && printf " ${yellow}→${reset} "
            ((i++))
        done
    fi
    printf "\n"
}

# it was zsh specific
function make_fn_usage() {
    local name=$1 args=$2 argsopt=$3 switches=$4 compact=$5
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    local usage="Usage: $name "
    if [[ $compact == "compact" ]]; then
        usage+="$c"
        [[ -n $args ]] && usage+="$c" && { for s in ${(z)args}; do; usage+="<$s> "; done } && usage+="$r"
        [[ -n $argsopt ]] && usage+="$c" && { for s in ${(z)argsopt}; do; usage+="[$s] "; done } && usage+="$r"
        usage+="$r"
    else
        [[ -n $switches ]] && usage+="${p}[switches]${r} "
        [[ -n $args ]] && usage+="${c}<arguments>${r}"
        [[ -n $switches ]] && usage+="\nSwitches: $p" && { for s in ${(z)switches}; do; usage+="--$s "; done } && usage+="$r"
        [[ -n $switches ]] && usage+="or $p" && { for s in ${(z)switches}; do; usage+="-${s:0:1} "; done } && usage+="$r"
        [[ -n $args || -n $argsopt ]] && usage+="\nArguments: "
        [[ -n $args ]] && usage+="$c" && { for s in ${(z)args}; do; usage+="<$s> "; done } && usage+="$r"
        [[ -n $argsopt ]] && usage+="$c" && { for s in ${(z)argsopt}; do; usage+="[$s] "; done } && usage+="$r"
    fi
    printf "$usage\n"
}

# Generate usage message for functions
# Usage: make_fn_usage <function-name> <function-arguments> [function-switches]
# Returns: usage message
function make_fn_usage_OLD() {
    local name=$1 args=$2 argsopt=$3 switches=$4 compact=$5
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    local usage="Usage: $name "

    # Split the arguments into arrays in a way that works in both bash and zsh
    args_array=()
    for arg in $args; do
        args_array+=("$arg")
    done

    argsopt_array=()
    for arg in $argsopt; do
        argsopt_array+=("$arg")
    done

    switches_array=()
    for switch in $switches; do
        switches_array+=("$switch")
    done

    if [[ $compact == "compact" ]]; then
        if [[ ${#args_array[@]} -ne 0 ]]; then
            usage+="$c"
            for s in "${args_array[@]}"; do 
                usage+="<$s> "
            done
            usage+="$r"
        fi
        if [[ ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="$c"
            for s in "${argsopt_array[@]}"; do 
                usage+="[$s] "
            done
            usage+="$r"
        fi
        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="$p"
            for s in "${switches_array[@]}"; do 
                usage+="[--$s] "
            done
            usage+="$r"
        fi
    else
        [[ ${#switches_array[@]} -ne 0 ]] && usage+="${p}[switches]${r} "
        [[ ${#args_array[@]} -ne 0 ]] && usage+="${c}<arguments>${r}"
        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="\nSwitches: $p"
            for s in "${switches_array[@]}"; do
                usage+="--$s "
            done
            usage+="$r"
            usage+="or $p"
            for s in "${switches_array[@]}"; do
                usage+="-${s:0:1} "
            done
            usage+="$r"
        fi
        if [[ ${#args_array[@]} -ne 0 || ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="\nArguments: "
            [[ ${#args_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${args_array[@]}"; do usage+="<$s> "; done } && usage+="$r"
            [[ ${#argsopt_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${argsopt_array[@]}"; do usage+="[$s] "; done } && usage+="$r"
        fi
    fi
    printf "$usage\n"
}