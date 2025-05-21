#!/bin/zsh

# fn_make - a function for handling options and arguments.
# It parses the options and arguments and checks for errors.
# Additionally, it prints usage, help, and version information.

# This function must be called by the parrent function that uses it.
# ⚠️ It is not meant to be used standalone. 

function fn_make2() {
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
