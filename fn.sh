#!/bin/zsh
# The functions below are intended for exclusive use in the Zsh shell.

# fn_make() is a helper function for handling options and arguments.
# It parses the options and arguments of parent function and checks for errors.
# Additionally, it prints usage, help, and version information.
# The associative arrays $f, $a, and $o are passed via dynamic scoping.
# ⚠️ These functions cannot be used standalone.

##############################################
# Function template to be used with fn_make()
##############################################

# Full function template
function fn_template_full() {
    # f = properties, a - arguments, o - options, s - strings, t - this
    local -A f; local -A o; local -A a; local -A s; local -A t
    # Define function properties
    f[info]="Template for functions." # info about the function
    f[version]="0.25" # version of the function
    f[date]="2025-05-20" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    # Define arguments (in order in which they should be passed)
    a[1]="agrument1,r,description of the first argument"
    a[2]="agrument2,r,description of the second argument"
    a[3]="agrument3,o,description of the third argument"
    a[4]="agrument4,o,description of the fourth argument"
    # Define extra options (default are: info, help, version, debug)
    o[verbose]="V,0,enable verbose mode"
    o[something]="s,0,esome other option"
    # Run fn_make() to parse arguments and options
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    ### main function
    echo "This is the output of the $s[name] function."
}

# Minimal function template
function fn_template_short() {
    local -A f; local -A o; local -A a; local -A s; local -A t
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    ### main function
    echo "This is the output of the $s[name] function."
}

##############################################
# Main function
##############################################

function fn_make() {
    fn_load_colors
    # Check if the function is called from a parent function
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "${c}fn_make$x function cannot be called directly"
        return 1
    fi
    # Arguments arrays (name, required flad, help string)
    local -A a_name; local -A a_req; local -A a_help
    # Options arrays (short name, full name, help string)
    local -A o_default; local -A o_short; local -A o_long; local -A o_help
    # Error messages and hints arrays
    local -A e_msg; local -A e_hint
    # Prepare function properties
    fn_set_properties
    # Add default options to the $o array
    fn_add_defaults
    # Parse arguments and options settings arrays, exit on error
    fn_parse_settings && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Parse function arguments
    fn_parse_arguments "$@"
    # Make function strings
    fn_set_strings
    # Save total time
    fn_set_time $time_start
    # Print debug information
    fn_debug && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Options handling (show version, basic info/usage or help)
    fn_handle_options && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Error handling
    fn_handle_errors && [[ -n "${f[return]}" ]] && return "${f[return]}"
}

##############################################
# Helper functions to be used by the make_fn()
##############################################

# Error handling
function fn_handle_errors() {
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} error$plr in $s[name] ${r}arguments:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value" && [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]"
        done
        echo "$s[hint]"
        f[return]=1 && return 1
    fi
}

# Options handling (show version, basic info/usage or help)
function fn_handle_options() {
    if [[ "$o[version]" -eq "1" || "$o[info]" -eq "1" || "$o[help]" -eq "1" ]]; then
        if [[ "$o[version]" -eq "1" ]]; then
            echo $s[version]
        elif [[ "$o[info]" -eq "1" ]]; then
            [[ $f[info] ]] && echo $s[header]
            echo $s[example]
        elif [[ "$o[help]" -eq "1" ]]; then
            [[ $f[info] ]] && echo "\n$s[header]"
            [[ $f[help] ]] && echo $f[help]
            echo "$s[example]\n$s[usage]\n\n$s[footer]\n$s[source]\n"
        fi
        f[return]=0 && return 0
    fi
}

# Prepare function properties
function fn_set_properties() {
    f[time_fnmake_start]=$(fn_get_timestamp)
    f[name]="${funcstack[3]}"
    [[ -z $f[author] ]] && f[author]="gh/barabasz"
    # File with parent function
    f[file_path]="$(whence -v $f[name] | awk '{print $NF}')"
    f[file_dir]="${f[file_path]%/*}"
    f[file_name]="${f[file_path]##*/}"
    # Arguments
    f[args_min]="0" # number of required arguments
    f[args_opt]="0" # number of optional arguments
    f[args_max]="${#a}" # maximum number of arguments
    f[args_count]=0 # number of arguments passed
    f[args_input]="" # string of arguments passed
    # Options
    f[opts_count]=0 # number of options passed
    f[opts_input]="" # string of options passed
    # Return code on error
    f[return]="" # return value
}

# Get timestamp from gdate (in milliseconds) or date (on macOS in seconds)
function fn_get_timestamp() {
    if which gdate >/dev/null 2>&1; then
        echo $(gdate +%s%3N)
    else
        echo $(date +%s)
    fi
}

# Set time difference
function fn_set_time() {
    local time_end=$(fn_get_timestamp)
    local time_diff=$((time_end - f[time_fnmake_start]))
    f[time_fnmake]=$time_diff
    unset "f[time_fnmake_start]"
}

# Prepare the full usage information
function fn_usage() {
    local i=1 usage="\n" max_len=0 a_pad o_pad indent="    "
    
    # Find maximum length of argument and option names
    if [[ ${#a} -ne 0 ]]; then
        for arg in ${(ok)a}; do
            (( ${#arg} > max_len )) && max_len=${#arg}
        done
    fi
    if [[ ${#o_help} -ne 0 ]]; then
        for oh in ${(ok)o_help}; do
            (( ${#oh} > max_len )) && max_len=${#oh}
        done
    fi
    # Set a_pad (argument padding) and o_pad (option padding)
    (( a_pad = max_len + 6 ))
    (( o_pad = max_len + 1 ))

    usage+="${y}Usage details:$x\n$indent$s[name] "
    if [[ ${#a} -ne 0 ]]; then
        usage+="${p}[options]${x} "
    fi

    if [[ $f[args_min] -eq 1 ]]; then
        usage+="${c}<${a_name[1]}>${x} "
    elif [[ $f[args_min] -ne 0 ]]; then
        usage+="${c}<arguments>${x} "
    fi

    if [[ $f[args_opt] -eq 1 ]]; then
        usage+="${c}[${a_name[1]}]${x}"
    elif [[ $f[args_opt] -ne 0 ]]; then
        usage+="${c}[arguments]${x}"
    fi

    if [[ $f[args_min] -ne 0 ]]; then
        usage+="\n\n${y}Required arguments:$x\n$indent"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "required" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$b→$x $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi

    if [[ $f[args_opt] -ne 0 ]]; then
        usage+="\n${y}Optional arguments:$x\n$indent"
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "optional" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$b→$x $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi

    if [[ $f[opts_max] -ne 0 && ${#o_long} -ne 0 && ${#o_help} -ne 0 ]]; then
        usage+="\n${y}Options:$x\n$indent"
        for opt in ${(ok)o_long}; do
            usage+="-$p$o_long[$opt]$x"
            usage+=" or "
            usage+="--${p}${(r:$o_pad:: :)opt}$b→$x $o_help[$opt]\n$indent"
        done
        usage="${usage%\\n\\t}"
    fi

    if [[ ${#arr_opts[@]} -ne 0 ]]; then
        usage+="\n${y}Options:$x\n\t"
        for opt in "${arr_opts[@]}"; do
            usage+="$p-$opt[1,1]$x or $p--$opt$x\n\t";
        done
        usage="${usage%\\n\\t}"
    fi

    if [[ $f[args_max] -gt 1 ]]; then
        usage+="\n${c}Arguments$x must be provided in the specified sequence."
    fi

    if [[ $f[args_opt] -gt 1 ]]; then
        usage+="\nTo skip an argument, pass an empty value $c\"\"$x (only valid for optional arguments)."
    fi

    (( f[args_max] > 0 )) && usage+=$'\n'

    if [[ $f[opts_max] -gt 0 ]]; then
        usage+="\n${p}Options$x may be submitted in any place and in any order."
        usage+="\nTo pass a value to a supported options, use the syntax ${p}--option=value$x."
        usage+="\nOptions without a value take the default value from the settings."
        usage+="\nTo list option default values, use the ${p}--debug=D$x option."
    fi
    printf "$usage\n"
}

# Prepare the version string
function fn_version() {
    printf "$s[name]"
    [[ -n $f[version] ]] && printf " $y$f[version]$x" || printf " [version unknown]"
    [[ -n $f[date] ]] && printf " ($f[date])"
}

# Prepare the hint string
function fn_hint() {
    if [[ $f[info] && $f[help] ]]; then
        log::info "Run $s[name] ${p}-i$x for basic usage or $s[name] ${p}-h$x for help."
    elif [[ $f[info] ]]; then
        log::info "Run $s[name] ${p}-i$x for usage information."
    elif [[ $f[help] ]]; then
        log::info "Run $s[name] ${p}-h$x for help."
    else
        log::info "Check source code for usage information."
        log::comment $s[source]
    fi
}

# Prepare source code location string
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
    local indent="    "
    [[ $o[help] == 1 ]] && printf "\n"
    printf "${y}Usage example:$x" 
    [[ $o[help] == 1 ]] && printf "\n$indent" || printf " "
    printf "$s[name] "
    if [[ ${#a} -ne 0 ]]; then
        for arg in ${(ok)a}; do
            if [[ $a_req[$arg] == "required" ]]; then
                printf "${c}<${arg}>${x} "
            else
                printf "${c}[$arg]${x} "
            fi
        done | sort | tr -d '\n'
    fi
    [[ $o[info] == 1 ]] && printf "\nRun '$s[name] ${p}-h$x' for more help."
}

# Warpper function to set all strings
function fn_set_strings() {
    s[name]="${g}$f[name]$x"
    s[path]="${c}$f[file_path]$x"
    s[author]="${y}$f[author]$x"
    s[year]="${y}${f[date]:0:4}$x"
    s[header]="$s[name]: $f[info]"
    s[version]="$(fn_version)"
    s[footer]="$(fn_footer)"
    s[example]="$(fn_example)"
    s[source]="$(fn_source)"
    s[usage]="$(fn_usage)"
    s[hint]="$(fn_hint)"
}

# Check if the number of arguments is correct
function fn_check_args() {
    local expected
    if [[ $f[args_min] -eq $f[args_max] ]]; then
        expected="expected $f[args_min]"
    else
        expected="expected $f[args_min] to $f[args_max]"
    fi
    local given="given $f[args_count]"

    if [[ $f[args_max] -eq 0 && $f[args_count] -gt 0 ]]; then
        echo "No arguments expected ($given)"
        f[err_arg]=1 && f[err_arg_type]=1
    elif [[ $f[args_count] -eq 0 && $f[args_max] -eq 1 ]]; then
        echo "Missing required argument ($expected)"
        f[err_arg]=1 && f[err_arg_type]=
    elif [[ $f[args_count] -eq 0 ]]; then
        echo "Missing required arguments ($expected)"
        f[err_arg]=1 && f[err_arg_type]=2
    elif [[ $f[args_count] -lt $f[args_min] ]]; then
        echo "Not enough required arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=3
    elif [[ $f[args_count] -gt $f[args_max] ]]; then
        echo "Too many arguments ($expected, $given)"
        f[err_arg]=1 && f[err_arg_type]=4
    fi
}

# Main parsing loop to iterate over all arguments
function fn_parse_arguments() {
    local used_opts="" # List of used options
    # Indexes for input position, arguments and options
    local i=0 ai=0 oi=0
    for arg in "$@"; do
        ((i++))
        local argc="'$y$arg$x'"
        local argname="${arg//-}" && argname="${argname%%=*}"
        local argnamec="$y$argname$x"
        # Check if the argument starts with a dash (then it is an option)
        if [[ $arg == -* ]]; then
            ((oi++)); local oic="$y$oi$x"
            # Add current option to the options list
            f[opts_input]+="$arg "
            # Get number of leading dashes
            local dashes=${#arg%%[![-]*}
            
            # Check that there are no more than 2 leading dashes
            if [[ $dashes -gt 2 ]]; then
                e_msg[o$i]="Option $oic has too many leading dashes in $argc"
                
                if [[ ${#argname} == 1 ]]; then
                    e_hint[o$i]="Short option name must be preceded by one dash."
                    e_hint[o$i]+=" Did you mean '${y}-${argname}$x'?"
                else
                    e_hint[o$i]="Full option name must be preceded by two dashes."
                    e_hint[o$i]+=" Did you mean '${y}--${argname}$x'?"
                fi
                #continue
                ((i++))
            fi
            
            # Get number of equal signs
            local equals=${#arg//[^=]/}
            
            # Check that there is no more than one equal sign
            if [[ $equals -gt 1 ]]; then
                e_msg[o$i]="Option $oic has too many equal signs in $argc"
                e_hint[o$i]="Optional value must be passed in the form of '${y}--option=value$x' or '${y}-o=value$x'"
                #continue
                ((i++))
            fi

            # Get the length of the option name without leading dashes
            local namelen=${#${${arg##*-}%%=*}}

            # Check if option name is not empty
            if [[ $namelen -eq 0 ]]; then
                e_msg[o$i]="Option $oic has empty name in $argc"
                #continue
                ((i++))
            fi

            # Check if there are two leading dashes but a one-letter option name
            if [[ $dashes -eq 2 && $namelen -eq 1 ]]; then
                e_msg[o$i]="Option $oic name must be longer than 1 character in $argc"
                e_hint[o$i]="Two dashes must be followed by full option name. Did you mean '${y}-${arg[-1]}$x'"
                if [[ $o_short[${arg[-1]}] ]]; then
                    e_hint[o$i]+=" or '--$o_short[${arg[-1]}]'"
                fi
                e_hint[o$i]+="?"
                #continue
                ((i++))
            fi

            # Check if there is exactly one leading dash but the option name is longer than 1 character
            if [[ $dashes -eq 1 && $namelen -gt 1 ]]; then
                e_msg[o$i]="Option $oic name is too long in $argc"
                e_hint[o$i]="Short names must be exactly 1 character long. Did you mean '-${arg:1:1}'?"
                continue
            fi

            # Remove all leading dashes (leave only name or pair name=value)
            arg="${arg//-}"
            # Get the option name (or pair name=value)
            local name="${arg%%=*}"

            # Check if the short option name (with one leading dash) is in the $o_short options array
            if [[ $dashes -eq 1 ]]; then
                if [[ -z "${o_short[$name]}" ]]; then
                    e_msg[o$i]="Option $oic short name $y$name$x unknown in $argc"
                    continue
                else
                    # Replace short option name with long one
                    name="${o_short[$name]}"
                fi
            fi

            # Check if the long option name (with two leading dashes) is in the $o options array
            if [[ $dashes -eq 2 ]]; then
                if [[ -z "${o[$name]}" ]]; then
                    e_msg[o$i]="Option $oic full name $y$name$x unknown in $argc"
                    continue
                fi
            fi

            # Check if it is a pair name=value
            if [[ $arg == *"="* ]]; then
                # Get the value (after the equal sign)
                value="${arg#*=}"
            # Otherwise, it is a standalone option without a value
            else
                value=$o_default[$name]
            fi

            # Check if the option is already used
            if [[ ${#argname} != 0 && $used_opts == *"$name"* ]]; then
                e_msg[o$i]="Option $oic name '$argnamec' in $argc was already used as "
                if [[ ${#argname} -eq 1 ]]; then
                    e_msg[o$i]+="'${y}--$o_short[$argname]$x'"
                    
                else
                    e_msg[o$i]+="'${y}-$o_long[$argname]$x'"
                fi
                continue
            fi

            # Replace default value in $o array with the new one
            o[$name]=$value
            used_opts+="$name "
        
        # When there are no leading dashes, it is an argument
        else
            ((ai++)); local aic="$y$ai$x"
            # Add the argument to the arguments list
            f[args_input]+="'$arg' "
            # Check if the argument is required
            if [[ $a_req[$a_name[$ai]] == "required" && -z $arg ]]; then
                e_msg[a$i]="Argument $aic ($y$a_name[$ai]$x) cannot be empty"
            fi
            if [[ $a_name[$ai] ]]; then
                a[$a_name[$ai]]="$arg"
            else
                a[$ai]="$arg"
            fi
        fi
    done
    f[opts_count]=$oi
    f[args_count]=$ai
    # Remove trailing spaces from the input strings
    f[opts_input]="${f[opts_input]%" "}"
    f[args_input]="${f[args_input]%" "}"
    # Get arguments count information
    if [[ f[args_count] -lt $f[args_min] || $f[args_count] -gt $f[args_max] ]]; then
        e_msg[0]=$(fn_check_args)
    fi
}

# Load base colors
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

# Add default options to the $o array
function fn_add_defaults() {
    # Add default options to the list
    [[ -z ${o[info]} ]] && o[info]="i,1,show basic info and usage"
    [[ -z ${o[help]} ]] && o[help]="h,1,show full help"
    [[ -z ${o[version]} ]] && o[version]="v,1,show version"
    [[ -z ${o[debug]} ]] && o[debug]="d,f,enable debug mode (use ${p}-d=h$x for help)"
    [[ -z ${o[verbose]} ]] && o[verbose]="V,1,enable verbose mode"
    f[opts_max]="${#o}" # maximum number of options
}

# Parse arguments and options settings arrays
function fn_parse_settings() {
    ### Parse $a arguments array
    for key in ${(ok)a}; do
        local value="${a[$key]}"
        # Split CSV value into settings
        local settings=(${(s:,:)value})
        # Check if there are exactly 3 non-empty settings values
        if [[ ${#settings} -ne 3 ]]; then
            e_msg[$key]="Invalid argument $y$key$x format in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have 3 values/2 commas)"
            continue
        fi
        a_name[$key]="${settings[1]}"
        # Check if the argument name wasn't already used
        if [[ -n ${a[${settings[1]}]+_} ]]; then
            e_msg[$key]="Argument $y$key$x name '$y${settings[1]}$x' already used before"
            e_hint[$key]="Correct '$y$value$x' by giving a unique name"
            continue
        fi
        # Check if argument type is either "r" (required) or "o" (optional)
        if [[ "ro" != *"${settings[2]}"* ]]; then
            e_msg[$key]="Invalid argument $y$key$x type '$y${settings[2]}$x' in '$y$value$x'"
            e_hint[$key]="Argument type must be '${y}r$x' (required) or '${y}o$x' (optional)"
            continue
        fi
        # Check if the argument is required
        if [[ ${settings[2]} == r ]]; then
            a_req[${settings[1]}]=required
            ((f[args_min]++))
        else
            a_req[${settings[1]}]=optional
            ((f[args_opt]++))
        fi
        # Get help value
        a_help[${settings[1]}]="${settings[3]}"
        # Unset original $a array value
        unset "a[$key]"
        # Add to $a array the argument name with an empty value
        a[${settings[1]}]=""
    done

    ### Parse $o options array
    for key in ${(ok)o}; do
        local value="${o[$key]}"
        # Split CSV value into settings
        local settings=(${(s:,:)value})
        # Check if there are exactly 3 non-empty settings values
        if [[ ${#settings} -ne 3 ]]; then
            e_msg[$key]="Invalid settings for option '$y$key$x' in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have 3 values/2 commas)"
            continue
        fi
        # Check if the optoion short name wasn't already used
        if [[ -n ${o_short[${settings[1]}]+_} ]]; then
            echo "Error: Option short name '${settings[1]}' already used in '$key' ($value)"
            f[return]=1 && return 1
        fi
        # Check if the short option name is exactly one letter
        if [[ ${#settings[1]} -ne 1 ]]; then
            echo "Error: Short option name must be exactly one letter in '$key' ($value)"
            f[return]=1 && return 1
        fi 
        # Fill internal helper arrays
        o_default[$key]="${settings[2]}"
        o_short[${settings[1]}]=$key
        o_long[$key]="${settings[1]}"
        o_help[$key]="${settings[3]}"
        # Unset original $o array value
        unset "o[$key]"
    done
    # Print error messages if any and exit
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} fatal error$plr in function $g$f[name]$x ${r}settings:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value" && [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]"
        done
        f[return]=1 && return 1
    fi
}

# Print debug information
function fn_debug() {
    local debug=$o[debug]
    if [[ "$debug" && ! $debug =~ "d" ]]; then
        local max_key_length=15
        local max_value_length=40
        local count
        local q="$y'$x"
        # Debug modes
        local -A modes=(
            [a]="Arguments from $y\$a[]$x array"
            [d]="Disable debugging inside ${g}fn_make$x"
            [D]="Default values for options"
            [e]="Exit after debugging"
            [f]="Function properties from $y\$f[]$x array"
            [h]="Help $y(default)$x"
            [i]="Internal ${g}fn_make$x arrays"
            [o]="Options from $y\$o[]$x array"
            [s]="Strings from $y\$s[]$x array"
            [t]="This function from $y\$t[]$x array"
        )

        # find the longest key
        for key in "${(@k)f}"; do
            if [[ ${#key} -gt $max_key_length ]]; then
                max_key_length=${#key}
            fi
        done
        for key in "${(@k)t}"; do
            if [[ ${#key} -gt $max_key_length ]]; then
                max_key_length=${#key}
            fi
        done
        # debug header
        print::header "${r}Debug mode$x '$debug'"
        # show info when debug mode is not set to 'h'
        if [[ $debug =~ "e" ]]; then
            log::warning "Exit mode enabled: $s[name] will exit after debug."
            f[return]=0
        fi
        # show info when debug mode is not set to 'h'
        if [[ ! $debug =~ "h" ]]; then
            log::info "Use option ${c}-d=h$x to show available debug modes."
        fi
        # list modes
        if [[ $debug =~ "h" ]]; then
            max_key_length=2
            log::info "${y}Debug modes${x} (${#modes}):"
            for key value in "${(@kv)modes}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            echo "Debug modes can be combined, e.g. $c-d=aof$x of $c--debug=aof$x."
            echo "Debuggin of ${g}fn_make$x internal arrays (${c}i$x mode) works only if ${c}d$x is not set."
        fi
        if [[ $debug =~ "D" ]]; then
        # List internal $o_default[] array (options default values)
            [[ ${#o_default} -eq 0 ]] && count="is empty." || count="(${#o_default}):"
            log::info "${y}Options default values${x} from ${g}\$o_default[]$x $count"
            for key value in "${(@kv)o_default}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        # List all internal fn_make() arrays
        if [[ $debug =~ "i" ]]; then
            # list $a_name[]
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_name[]$x $count"
            for key value in "${(@kv)a_name}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $a_req[]
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_req[]$x $count"
            for key value in "${(@kv)a_req}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $a_help[]
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a_help[]$x $count"
            for key value in "${(@kv)a_help}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $o_default[]
            [[ ${#o_default} -eq 0 ]] && count="is empty." || count="(${#o_default}):"
            log::info "${y}Options${x} ${g}\$o_default[]$x $count"
            for key value in "${(@kv)o_default}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $o_short[]
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_short[]$x $count"
            for key value in "${(@kv)o_short}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $o_long[]
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_long[]$x $count"
            for key value in "${(@kv)o_long}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
            # list $o_help[]
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o_help[]$x $count"
            for key value in "${(@kv)o_help}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        # list arguments $a[]
        if [[ $debug =~ "a" ]]; then
            [[ ${#a} -eq 0 ]] && count="is empty." || count="(${#a}):"
            log::info "${y}Arguments${x} ${g}\$a[]$x $count"
            for key value in "${(@kv)a}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        # list options $o[]
        if [[ $debug =~ "o" ]]; then
            [[ ${#o} -eq 0 ]] && count="is empty." || count="(${#o}):"
            log::info "${y}Options${x} ${g}\$o[]$x $count"
            for key value in "${(@kv)o}"; do
                echo "    ${(r:$max_key_length:)key} $y->$x $q$value$q"
            done | sort
        fi
        # list properties $f[]
        if [[ $debug =~ "f" ]]; then
            [[ ${#f} -eq 0 ]] && count="is empty." || count="(${#f}):"
            log::info "${y}Function properties${x} ${g}\$f[]$x $count"
            for key value in "${(@kv)f}"; do
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort
        fi
        # list strings $s[]
        if [[ $debug =~ "s" ]]; then
            [[ ${#s} -eq 0 ]] && count="is empty." || count="(${#s}):"
            log::info "${y}Strings${x} ${g}\$s[]$x $count"
            for key value in "${(@kv)s}"; do
                value=$(clean_ansi "$value")
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort
        fi
        # list this function values $t[]
        if [[ $debug =~ "t" ]]; then
            [[ ${#t} -eq 0 ]] && count="is empty." || count="(${#t}):"
            log::info "${y}This function${x} ${g}\$t[]$x $count"
            for key value in "${(@kv)t}"; do
                value=$(clean_ansi "$value")
                value=$(clean_string "$value")
                echo -n "    ${(r:$max_key_length:)key} $y->$x $q${value:0:$max_value_length}$q"
                [[ ${#value} -gt $max_value_length ]] && echo "$y...$x" || echo
            done | sort 
        fi
        # debug footer
        print::footer "${r}Debug end$x"
        # exit if debug mode is set to 'e'
        # [[ $debug =~ "e" ]] && exit
    fi
}