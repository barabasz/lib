#!/bin/zsh

# fn_make - a function for handling options and arguments.
# It parses the options and arguments and checks for errors.
# Additionally, it prints usage, help, and version information.

# This function must be called by the parrent function that uses it.
# ⚠️ It is not meant to be used standalone. 

function fn_make() {
### check if the function is called from a function
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "fn_make must be called from a function"
        return 1
    fi

### argunments and options arrays
    local arr_args_required=( $(string_to_words "$f[args_required]") )
    local arr_args_optional=( $(string_to_words "$f[args_optional]") )
    local arr_opts=( $(string_to_words "$f[opts]") )

### prepare function properties
    f[name]="${funcstack[2]}"
    [[ -z $f[author] ]] && f[author]="gh/barabasz"
    f[file_path]="$(whence -v $f[name] | awk '{print $NF}')"
    f[file_dir]="${f[file_path]%/*}"
    f[file_name]="${f[file_path]##*/}"
    f[args_min]=${#arr_args_required}
    f[args_max]=$(($f[args_min]+${#arr_args_optional}))
    f[opts_max]="${#arr_opts}"
    f[args_count]=0
    f[opts_input]=""
    f[opts_count]=0
    f[return]=""
    
### parse options and arguments
    # create options array
    for opt in $arr_opts; do
        o[$opt[1,1]]=0
    done
    # loop through arguments
    local i=1
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            f[opts_input]+="$arg "
            opt_long="${arg#${arg%%[^-]*}}"
            opt=${opt_long[1,1]}
            if [[ $arr_opts =~ $opt_long ]]; then
                o[$opt]=1
            else
                [[ -z "$f[err_opt_value]" ]] && f[err_opt_value]=$arg
            fi
            f[opts_count]=$(( f[opts_count] + 1 ))
        else
            f[args_count]=$(( f[args_count] + 1 ))
            a[$i]=$arg
            ((i++))
        fi
    done
    f[opts_input]="${f[opts_input]%" "}"
    [[ $f[err_opt_value] ]] && f[err_opt]=1
    [[ f[args_count] -lt $f[args_min] || $f[args_count] -gt $f[args_max] ]] && f[err_arg]=1

### function strings
    fn_load_colors
    s[name]="${g}$f[name]$x"
    s[path]="${c}$f[file_path]$x"
    s[author]="${y}$f[author]$x"
    s[year]="${y}${f[date]:0:4}$x"
    [[ $f[err_opt] ]] && s[err_opt]="unknown option $p$f[err_opt_value]$x"
    [[ $f[err_arg] ]] && s[err_arg]="$(fn_check_args)"
    [[ $f[info] ]] && s[header]="$s[name]: $f[info]"
    s[version]="$(fn_version)"
    s[footer]="$(fn_footer)"
    s[example]="$(fn_example)"
    s[source]="$(fn_source)"
    s[usage]="$(fn_usage)"
    s[hint]="$(fn_hint)"

### options handling
    # show version, basic info (usage) or help
    if [[ "$o[v]" -eq "1" || "$o[i]" -eq "1" || "$o[h]" -eq "1" ]]; then
        if [[ "$o[v]" -eq "1" ]]; then
            echo $s[version]
        elif [[ "$o[i]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            echo $s[example]
        elif [[ "$o[h]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            [[ $f[help] ]] && echo $f[help]
            echo "$s[example]\n$s[usage]\n\n$s[footer]\n$s[source]"
        fi
        f[return]=0 && return 0
    fi
    # error handling
    local err_msg="$x$s[name] error:"
    if [[ $f[err_opt] || $f[err_arg] ]]; then
        [[ $f[err_opt] ]] && log::error "$err_msg $s[err_opt]"
        [[ $f[err_arg] ]] && log::error "$err_msg $s[err_arg]"
        echo "$s[hint]"
        f[return]=2 && return 0
    fi
}

# Helper functions to be used by the make_fn.
# These functions shouldn't be used standalone.

# check if the number of arguments is correct
function fn_check_args() {
    local expected
    if [[ $f[args_min] -eq $f[args_max] ]]; then
        expected="expected $f[args_min]"
    else
        expected="expected $f[args_min] to $f[args_max]"
    fi
    local given="given $f[args_count]"

    if [[ $f[args_max] -eq 0 && $f[args_count] -gt 0 ]]; then
        echo "no arguments expected ($given)"
        f[err_arg]=1 && f[err_arg_type]=1
    elif [[ $f[args_count] -eq 0 && $f[args_max] -eq 1 ]]; then
        echo "missing argument ($expected)"
        f[err_arg]=1 && f[err_arg_type]=
    elif [[ $f[args_count] -eq 0 ]]; then
        echo "missing arguments ($expected)"
        f[err_arg]=1 && f[err_arg_type]=2
    elif [[ $f[args_count] -lt $f[args_min] ]]; then
        echo "not enough arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=3
    elif [[ $f[args_count] -gt $f[args_max] ]]; then
        echo "too many arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=4
    fi
}

# prepare the version string
function fn_version() {
    printf "$s[name]"
    [[ -n $f[version] ]] && printf " $y$f[version]$x" || printf " [version unknown]"
    [[ -n $f[date] ]] && printf " ($f[date])"
}

# prepare the hint string
function fn_hint() {
    if [[ $o[i] && $o[h] ]]; then
        log::info "Run $s[name] ${p}-i$x for basic usage or $s[name] ${p}-h$x for help."
    elif [[ $o[i] ]]; then
        log::info "Run $s[name] ${p}-i$x for usage information."
    elif [[ $o[h] ]]; then
        log::info "Run $s[name] ${p}-h$x for help."
    else
        log::info "Check source code for usage information."
        log::comment $s[source]
    fi
}

function fn_source() {
    local file="$f[file_path]"
    local string="${f[name]}() {"
    local line="$(grep -n "$string" "$file" | head -n 1 | cut -d: -f1)"
    echo "This function is defined in $s[path] (line $c$line$x)"
}

# prepare the footer string
function fn_footer() {
    printf "$s[version] copyright © "
    [[ -n $f[date] ]] && printf "$s[year] "
    printf "by $s[author]\n"
    printf "MIT License : https://opensource.org/licenses/MIT"
}

# prepare the example string
function fn_example() {
    [[ $o[h] == 1 ]] && printf "\n"
    printf "Usage example:" 
    [[ $o[h] == 1 ]] && printf "\n\t" || printf " "
    printf "$s[name] "
    if [[ ${#arr_args_required[@]} -ne 0 ]]; then
        for a in "${arr_args_required[@]}"; do
            printf "${c}<$a>${x} "
        done | sort | tr -d '\n'
    elif [[ ${#arr_args_optional[@]} -ne 0 ]]; then
        for a in "${arr_args_optional[@]}"; do
            printf "${c}[$a]${x} "
        done | sort | tr -d '\n'
    fi
    [[ $o[i] == 1 ]] && printf "\nRun '$s[name] ${p}-h$x' for more help."
}

# prepare the full usage information
function fn_usage() {
    local i=1
    local usage="Usage details:\n\t$s[name] "
    if [[ ${#arr_opts[@]} -ne 0 ]]; then
        usage+="${p}[options]${x} "
    fi
    if [[ ${#arr_args_required[@]} -eq 1 ]]; then
        usage+="${c}<${arr_args_required[1]}>${x}"
    elif [[ ${#arr_args_required[@]} -ne 0 ]]; then
        usage+="${c}<arguments>${x}"
    elif [[ ${#arr_args_optional[@]} -eq 1 ]]; then
        usage+="${c}[${arr_args_optional[1]}]${x}"
    elif [[ ${#arr_args_optional[@]} -ne 0 ]]; then
        usage+="${c}[arguments]${x}"
    fi
    if [[ ${#arr_opts[@]} -ne 0 ]]; then
        usage+="\nOptions:\n\t"
        for opt in "${arr_opts[@]}"; do
            usage+="$p-$opt[1,1]$x or $p--$opt$x\n\t";
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ ${#arr_args_required[@]} -ne 0 ]]; then
        usage+="\nRequired arguments:\n\t"
        for arg in "${arr_args_required[@]}"; do
            usage+="$i: $c<$arg>$x\n\t";
            ((i++))
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ ${#arr_args_optional[@]} -ne 0 ]]; then
        usage+="\nOptional arguments:\n\t"
        for arg in "${arr_args_optional[@]}"; do
            usage+="$i: ${c}[${arg}]$x\n\t";
            ((i++))
        done
        usage="${usage%\\n\\t}"
    fi
    if [[ $f[args_max] -gt 1 ]]; then
        usage+="\nArguments must be passed in the above oreder."
        usage+="\nTo skip an argument, pass an empty value: \"\""
    fi
    printf "$usage\n"
}

# load base colors
function fn_load_colors() {
    b=$(ansi blue)
    c=$(ansi cyan)
    g=$(ansi green)
    p=$(ansi bright purple)
    r=$(ansi red)
    w=$(ansi white)
    y=$(ansi yellow)
    x=$(ansi reset)
}

# print debug information
function fn_debug() {
    local max_key_length=15
    local max_value_length=40
    local q="$y'$x"
# find the longest key
    for key in "${(@k)f}"; do
        if [[ ${#key} -gt $max_key_length ]]; then
            max_key_length=${#key}
        fi
    done
# list arguments $a[]
    print::header "${r}Debug info$x"
    log::info "${y}Arguments${x}:"
    for key value in "${(@kv)a}"; do
        echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
    done | sort
# list options $o[]
    log::info "${y}Options${x}:"
    for key value in "${(@kv)o}"; do
        echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
    done | sort
# list properties $f[]
    log::info "${y}Function properties${x}:"
    for key value in "${(@kv)f}"; do
        value=$(clean_string "$value")
        echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
        [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
    done | sort
# list strings $s[]
    log::info "${y}Function strings${x}:"
    for key value in "${(@kv)s}"; do
        value=$(clean_ansi "$value")
        value=$(clean_string "$value")
        echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
        [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
    done | sort
    echo
}