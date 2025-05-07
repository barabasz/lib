#!/bin/zsh
#
# Helper functions for the script functions
# ⚠️ These functions are intended to be used by other scripts and not run directly

# Generate colored function name
# Usage: make_fn_name <function-name>
# Returns: colored function name
function make_fn_name() {
    local name=$1
    echo "$(ansi green)$name$(ansi reset)"
}

# Generate colored function footer
# Usage: make_fn_footer <function-author> <function-date> <function-version>
# Returns: colored function footer
function make_fn_footer() {
    local author=$1 date=$2 version=$3
    echo "$version copyright © 1999-${date:0:4} $(ansi yellow)$author$(ansi reset)"
    echo "MIT License : https://opensource.org/licenses/MIT"
}

# Generate colored function error information
# Usage: make_fn_errinf <function-name> <function-switches>
# Returns: colored function error information if --info switch is present
function make_fn_errinf() {
    local name=$1 switches=$2 file=$3 c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset)
    if [[ "$switches" == *"info"* && "$switches" == *"help"* ]]; then
        echo "Run $name ${p}-i$r for usage or $name ${p}-h$r for help."
    elif [[ "$switches" == *"info"* ]]; then
        echo "Run $name ${p}--info$r or $name ${p}-i$r for usage information."
    elif [[ "$switches" == *"help"* ]]; then
        echo "Run $name ${p}--help$r or $name ${p}-h$r for help."
    else
        echo "Check source code for usage information."
        echo "This function is defined in $c$file$r"
    fi
}

# Generate colored function info
# Usage: make_fn_info <function-name> <function-info> <function-usage>
# Returns: colored function info
function make_fn_info() {
    local title=$1 usage=$2 footer=$3 file=$4 type=$5
    file="This function is defined in $(ansi cyan)$file$(ansi reset)"
    if [[ $type == "compact" ]]; then
        echo "$title\n$usage\n$file"
    else
        echo "$title\n\n$usage\n\n$file\n$footer"
    fi
}

# Generate colored function version
# Usage: make_fn_version <function-name> <function-version>
# Returns: colored function version
function make_fn_version() {
    local name=$1 ver=$2 date=$3
    printf "$name $(ansi yellow)$ver$(ansi reset)"
    [[ -n $date ]] && printf " ($date)"
    printf "\n"
}

# Generate colored function header
# Usage: make_fn_header <function-name> <function-info>
# Returns: colored function header
function make_fn_header() {
    local name=$1 info=$2
    echo "$name $info"
}

# Generate colored function help
# Usage: make_fn_help <function-info> <function-help>
# Returns: colored function help
function make_fn_help() {
    local info=$1 help=$2
    [[ -z $help ]] && help="$(log::error No help available.)"
    echo "$info\n\n$help"
}

# Generate usage message for functions
# Usage: make_fn_usage <name> <arguments> [optional-arguments] [switches] ?[compact]
# Returns: usage message
function make_fn_usage() {
    local name=$1 args=$2 argsopt=$3 switches=$4 compact=$5
    local g=$(ansi green) c=$(ansi cyan) p=$(ansi bright purple) r=$(ansi reset) y=$(ansi yellow)
    local usage="Usage: $name "

    args_array=( $(string_to_words "$args") )
    argsopt_array=( $(string_to_words "$argsopt") )
    switches_array=( $(string_to_words "$switches") )

    if [[ $compact == "compact" ]]; then
        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="$p"
            for s in "${switches_array[@]}"; do 
                usage+="[--$s] "
            done
            usage+="$r"
        fi
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
    else
        [[ ${#switches_array[@]} -ne 0 ]] && usage+="${p}[switches]${r} "
        
        if [[ ${#args_array[@]} -ne 0 ]]; then
            usage+="${c}<arguments>${r}"
        elif [[ ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="${c}[arguments]${r}"
        fi

        if [[ ${#switches_array[@]} -ne 0 ]]; then
            usage+="\nSwitches: "
            for s in "${switches_array[@]}"; do
                usage+="$p--$s ${r}or$p -${s:0:1}$r, "
            done
            usage="${usage%??}"
        fi
        if [[ ${#args_array[@]} -ne 0 ]]; then
            usage+="\nRequired arguments: "
            [[ ${#args_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${args_array[@]}"; do usage+="<$s> "; done } && usage+="$r"
        fi
        if [[ ${#argsopt_array[@]} -ne 0 ]]; then
            usage+="\nOptional arguments: "
            [[ ${#argsopt_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${argsopt_array[@]}"; do usage+="[$s] "; done } && usage+="$r"
        fi
    fi
    printf "$usage\n"
}

# Check number of parameters
# Usage: check_fn_args <req_args_list> <opt_args_list> <actual_args_count>
# Returns: "ok" if the number of arguments is correct, otherwise an error message
function check_fn_args() {
    [[ $# -ne 3 ]] && return 2
    
    local req_args=$1
    local req_args_tbl=( ${=req_args} )
    local req_args_count=${#req_args_tbl}

    local opt_args=$2
    local opt_args_tbl=( ${=opt_args} )
    local opt_args_count=${#opt_args_tbl}

    local min=$req_args_count
    local max=$((req_args_count + opt_args_count))
    local given=$3
    local msg1="" msg2=""

    if [[ $min -gt $max ]]; then
        echo "check_fn_args: min number of arguments cannot be greater than max"
        return 1
    elif [[ $given -lt 0 ]]; then
        echo "check_fn_args: actual number of arguments cannot be negative"
        return 1
    fi

    if [[ $max -eq 0 && $given -gt 0 ]]; then
        msg1="no arguments expected"
    elif [[ $given -eq 0 ]]; then
        msg1="no arguments given"
    elif [[ $given -lt $min ]]; then
        msg1="not enough arguments"
    elif [[ $given -gt $max ]]; then
        msg1="too many arguments"
    fi

    if [[ $given -lt $min || $given -gt $max ]]; then
        if [[ $1 == $2 ]]; then
            msg2="expected $min"
        else
            msg2="expected $min to $max"
        fi
        echo "$msg1 ($msg2, given $given)"
        return 1
    fi

    echo "ok" && return 0
}

function make_fns() {
    local -n fns=$1
    local fn=$2 fi=$3 ft=$4 ff=$5 fr=$6 fo=$7 fs=$8 fa=$9 fv=${10} fd=${11} fh=${12}
    fns[name]=$(make_fn_name "$fn")
    fns[info]=$(make_fn_info "$fn" "$fi" "$ff" "$ft")
    fns[usage]=$(make_fn_usage "$fn" "$fr" "$fo" "$fs" "$ft")
    fns[errinf]=$(make_fn_errinf "$fn" "$fs" "$ff")
    fns[version]=$(make_fn_version "$fn" "$fv" "$fd")
    fns[footer]=$(make_fn_footer "$fa" "$fd" "$fv")
    fns[help]=$(make_fn_help "${fns[info]}" "${fh}")

    # nazwa pliku z funkcją: whence -v "fntest"
    # local filename=$(echo $function_source | awk '{print $NF}')
    # awk '{print $NF}' przetwarza ten wynik i zwraca ostatnie pole (NF to liczba pól w aktualnym wierszu), które jest ścieżką do pliku

    # sprawdzić, czy są tylko dozwolone switche
    # [[ $1 == -* ]] && echo "${fns[errswitch]}" && iserror=1
}