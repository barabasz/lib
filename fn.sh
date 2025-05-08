#!/bin/zsh

# make_fn - a function for nahdling options and arguments.
# It will parse the options and arguments and check for errors.
# This function must be called by the main function that uses it.
# ⚠️ It is not meant to be used standalone. 

function make_fn() {
    local arr_args_required=( $(string_to_words "$f[args_required]") )
    local arr_args_optional=( $(string_to_words "$f[args_optional]") )
    local arr_opts=( $(string_to_words "$f[opts]") )
### colors
    local c=$(ansi cyan)
    local g=$(ansi green)
    local p=$(ansi bright purple)
    local y=$(ansi yellow)
    local r=$(ansi reset)
### function properties
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
    # create options array
    for opt in $arr_opts; do
        o[$opt[1,1]]=0
    done
    # parse options and arguments
    local i=1
    for arg in "$@"; do
        if [[ $arg == -* ]]; then
            f[opts_input]+="$arg "
            opt="${${arg#${arg%%[^-]*}}[1,1]}"
            if [[ $o[$opt] ]]; then
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
    s[name]="${g}$f[name]$r"
    s[path]="${c}$f[file_path]$r"
    s[author]="${y}$f[author]$r"
    s[year]="${y}${f[date]:0:4}$r"
    [[ $f[err_opt] ]] && s[err_opt]="unknown option $p$f[err_opt_value]$r"
    [[ $f[err_arg] ]] && s[err_arg]="$(make_fn_err_arg)"
    [[ $f[info] ]] && s[header]="$s[name] $f[info]"
    s[version]=$(make_fn_version)
    s[footer]=$(make_fn_footer)
    s[example]="$(make_fn_example)"
    s[source]="This function is defined in $s[path]"
    s[usage]="$(make_fn_usage)"
    s[hint]="$(make_fn_hint)"

### options handling
    # show debug infromation
    [[ "$o[d]" -eq "1" ]] && make_fn_debug
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
            echo "$s[usage]\n\n$s[footer]\n$s[source]"
        fi
        f[return]=0 && return 0
    fi
    # error handling
    local err_msg="$r$s[name] error:"
    if [[ $f[err_opt] || $f[err_arg] ]]; then
        [[ $f[err_opt] ]] && log::error "$err_msg $s[err_opt]"
        [[ $f[err_arg] ]] && log::error "$err_msg $s[err_arg]"
        echo "$s[hint]"
        f[return]=2 && return 0
    fi
}

function make_fn_err_arg() {
    if [[ $f[args_max] -eq 0 && $f[args_count] -gt 0 ]]; then
        #s[err_arg]="no arguments expected"
        echo "no arguments expected ($f[args_count] given)"
        f[err_arg]=1 && f[err_arg_type]=1
    elif [[ $f[args_count] -eq 0 ]]; then
        #s[err_arg]="no arguments given"
        echo "no arguments given (expected $f[args_min] to $f[args_max])"
        f[err_arg]=1 && f[err_arg_type]=2
    elif [[ $f[args_count] -lt $f[args_min] ]]; then
        #s[err_arg]="not enough arguments"
        echo "not enough arguments (expected $f[args_min] to $f[args_max], given $f[args_count])"
        f[err_arg]=1 && f[err_arg_type]=3
    elif [[ $f[args_count] -gt $f[args_max] ]]; then
        #s[err_arg]="too many arguments"
        echo "too many arguments (expected $f[args_min] to $f[args_max], given $f[args_count])"
        f[err_arg]=1 && f[err_arg_type]=4
    fi
}

# Helper functions that are only to be used by the make_fn function.
# ⚠️ These functions cannot be used standalone.

function make_fn_version() {
    printf "$s[name]"
    [[ -n $f[version] ]] && printf " $y$f[version]$r" || printf " [version unknown]"
    [[ -n $f[date] ]] && printf " ($f[date])"
}

function make_fn_hint() {
    if [[ $o[i] && $o[h] ]]; then
        log::info "Run $s[name] ${p}-i$r for usage or $s[name] ${p}-h$r for help."
    elif [[ $o[i] ]]; then
        log::info "Run $s[name] ${p}--info$r or $s[name] ${p}-i$r for usage information."
    elif [[ $o[h] ]]; then
        log::info "Run $s[name] ${p}--help$r or $s[name] ${p}-h$r for help."
    else
        log::info "Check source code for usage information."
        log::comment $s[source]
    fi
}

function make_fn_footer() {
    printf "$s[version] copyright © "
    [[ -n $f[date] ]] && printf "$s[year] "
    printf "by $s[author]\n"
    printf "MIT License : https://opensource.org/licenses/MIT"
}

function make_fn_example() {
    printf "Usage example: $s[name] "
    if [[ ${#arr_args_required[@]} -ne 0 ]]; then
        for a in "${arr_args_required[@]}"; do
            printf "${c}<$a>${r} "
        done | sort | tr -d '\n'
    elif [[ ${#arr_args_optional[@]} -ne 0 ]]; then
        for a in "${arr_args_optional[@]}"; do
            printf "${c}[$a]${r} "
        done | sort | tr -d '\n'
    fi
    if [[ $o[h] ]]; then
        printf "\nRun $s[name] ${p}-h$r for more help."
    else
        printf "\n"
    fi
}

    #if [[ ${#switches_array[@]} -ne 0 ]]; then
    #    usage+="\nSwitches: "
    #    for s in "${switches_array[@]}"; do
    #        usage+="$p--$s ${r}or$p -${s:0:1}$r, "
    #    done
    #    usage="${usage%??}"
    #fi
    #if [[ ${#args_array[@]} -ne 0 ]]; then
    #    usage+="\nRequired arguments: "
    #    [[ ${#args_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${args_array[@]}"; do usage+="<$s> "; done } && usage+="$r"
    #fi
    #if [[ ${#argsopt_array[@]} -ne 0 ]]; then
    #    usage+="\nOptional arguments: "
    #    [[ ${#argsopt_array[@]} -ne 0 ]] && usage+="$c" && { for s in "${argsopt_array[@]}"; do usage+="[$s] "; done } && usage+="$r"
    #fi

function make_fn_usage() {
    printf "Usage: $s[name] "
    if [[ ${#arr_opts[@]} -ne 0 ]]; then
        printf "${p}[options]${r} "
    fi
    if [[ ${#arr_args_required[@]} -ne 0 ]]; then
        printf "${c}<arguments>${r}"
    elif [[ ${#arr_args_optional[@]} -ne 0 ]]; then
        printf "${c}[arguments]${r}"
    fi
}

function make_fn_debug() {
    log::warning "Debug mode is on."
    log::info "Arguments:"
    for key value in "${(@kv)a}"; do
        echo "    ${(r:15:)key} -> '$value'"
    done | sort
    log::info "Options:"
    for key value in "${(@kv)o}"; do
        echo "    ${(r:15:)key} -> '$value'"
    done | sort
    log::info "Function properties:"
    local value_temp=""
    for key value in "${(@kv)f}"; do
        echo "    ${(r:15:)key} -> '$value'"
    done | sort
    log::info "Function strings:"
    for key value in "${(@kv)s}"; do
        echo -En "    ${(r:15:)key} -> '${value:0:60}'"
        [[ ${#value} -gt 60 ]] && echo "$r..." || echo "$r"
    done | sort
}