#!/bin/zsh

# The functions below are intended for exclusive use in the Zsh shell.
# They intentionally leverage Zsh-specific syntax and features for simplicity and seamless integration.
# checkargs() is a helper function that parses arguments and options for other Zsh functions.
# mainfn() is an example function demonstrating how to use checkargs() for argument and option parsing.

# mainfn() is an example function that uses checkargs() to parse arguments and options.
# Arguments and options are defined in this function using the $a[] and $o[] arrays with CSV format.
# Arguments use the format: $a[position]="name,?,description", where "?" is either "r" (required) or "o" (optional).
# Options use the format: $o[fullname]="shortname,default value,description", where the default value is optional.
# Option short names must be exactly one letter; full names must be at least two letters long.
# An additional $f[] array is used to store function properties (e.g., version, args_count, opts_count).
# The associative arrays $f, $a, and $o are passed to checkargs() via Zsh's dynamic scoping feature.
function mainfn() {
    # Declare associative arrays
    local -A f; local -A a; local -A o
    # Define function properties
    f[version]="0.1"
    # Define arguments
    a[1]="target,r,path to the existing target file"
    a[2]="output,r,path to the new output file"
    a[3]="logfile,o,path to the log file"
    # Define options
    o[info]="i,0,show basic info and usage"
    o[help]="h,0,show full help"
    o[version]="v,0,show version"
    o[debug]="d,0,enable debug mode"
    o[verbose]="V,0,enable verbose mode"

    # Run checkargs() to parse arguments and options
    checkargs "$@"
    # if f[return] is set, return with the same value
    [[ -n "${f[return]}" ]] && return "${f[return]}"

    # Show parsed arguments and options
    echo "$f[args_cnt] arguments and $f[opts_cnt] options found."
}

# checkargs() iterates over the provided arguments, separating them into options and positional arguments.
# This function cannot be used standalone; it must be called from a parent function like mainfn().
# The associative arrays $f, $a, and $o are passed via dynamic scoping.
# Arguments must not start with a dash and are stored in the order they are passed.
# Options must start with a single dash for one-letter options (short names) or a double dash for full names.
# Options can be followed by an equal sign to provide a value (e.g., --option=value).
# Only the --fullname=value or -o=value (short name) formats are allowed for security reasons.
# If an option is not followed by a value, it is assigned a default value of 1.
# checkargs() replaces the initial settings values from $a[] and $o[] with the actual values from arguments.
function checkargs() {
    # Create argument names array
    local -A a_name
    # Create required arguments array (to check if all required arguments are passed)
    local -A a_req
    # Create arguments help array (to generate help - for future use)
    local -A a_help

    # Parse $a arguments array
    local args_min=0 args_opt=0
    for key value in "${(@kv)a}"; do
        # Split CSV value into settings
        local settings=(${(s:,:)value})
        # Check if there are exactly 3 non-empty settings values
        if [[ ${#settings} -ne 3 ]]; then
            echo "Error: Invalid argument '$key' format in '$value' (missing comma or empty value?)"
            f[return]=1 && return 1
        fi
        a_name[$key]="${settings[1]}"
        # Check if argument type is either "r" (required) or "o" (optional)
        if [[ "ro" != *"${settings[2]}"* ]]; then
            echo "Error: Invalid argument '$key' type '${settings[2]}' (must be 'r' or 'o')"
            continue
        fi
        # Check if the argument is required
        if [[ ${settings[2]} == r ]]; then
            a_req[${settings[1]}]=required
            ((args_min++))
        else
            a_req[${settings[1]}]=optional
            ((args_opt++))
        fi
        # Get help value
        a_help[${settings[1]}]="${settings[3]}"
        # Unset original $a array value
        unset "a[$key]"
        # Add to $a array the argument name with an empty value
        a[${settings[1]}]=""
    done
    f[args_min]=$args_min
    f[args_opt]=$args_opt
    f[args_max]=$((args_min + args_opt))

    # Create short options array (to resolve short option names to long ones)
    local -A o_short
    # Create options help array (to generate help - for future use)
    local -A o_help
    
    # Parse $o options array
    local opts_max=0
    for key value in "${(@kv)o}"; do
        # Split CSV value into settings
        local settings=(${(s:,:)value})
        # Check if there are exactly 3 non-empty settings values
        if [[ ${#settings} -ne 3 ]]; then
            echo "Error: Invalid option '$key' format in '$value' (missing comma or empty value?)"
            f[return]=1 && return 1
        fi
        # Check if the short option name is exactly one letter
        if [[ ${#settings[1]} -ne 1 ]]; then
            echo "Error: Short option name must be exactly one letter in '$key' ($value)"
            f[return]=1 && return 1
        else 
            o_short[${settings[1]}]=$key
        fi
        # Replace original $o array value with only default value
        o[$key]="${settings[2]}"
        # Get help value
        o_help[$key]="${settings[3]}"
        ((opts_max++))
    done
    f[opts_max]=$opts_max

    # Declare indexes
    local i=0 # Index for arguments
    local j=0 # Index for options
    local used_opts="" # List of used options

    # Main loop - iterate over all arguments
    for arg in "$@"; do
        # Check if the argument starts with a dash (then it is an option)
        if [[ $arg == -* ]]; then

            # Get number of leading dashes
            local dashes=${#arg%%[![-]*}
            
            # Check that there are no more than 2 leading dashes
            if [[ $dashes -gt 2 ]]; then
                echo "Error: Too many leading dashes in $arg"
                continue
            fi
            
            # Get number of equal signs
            local equals=${#arg//[^=]/}
            
            # Check that there is no more than one equal sign
            if [[ $equals -gt 1 ]]; then
                echo "Error: Too many equal signs in $arg"
                continue
            fi

            # Get the length of the option name without leading dashes
            local namelen=${#${${arg##*-}%%=*}}

            # Check if option name is not empty
            if [[ $namelen -eq 0 ]]; then
                echo "Error: Option name is empty in $arg"
                continue
            fi

            # Check if there are two leading dashes but a one-letter option name
            if [[ $dashes -eq 2 && $namelen -eq 1 ]]; then
                echo "Error: Long option names must be longer than 1 character in $arg"
                echo -n "Hint: Did you mean '-${arg[-1]}'"
                if [[ $o_short[${arg[-1]}] ]]; then
                    echo -n " or '--$o_short[${arg[-1]}]'"
                fi
                echo "?"
                continue
            fi

            # Check if there is exactly one leading dash but the option name is longer than 1 character
            if [[ $dashes -eq 1 && $namelen -gt 1 ]]; then
                echo "Error: Short option names must be exactly 1 character in '$arg'"
                echo "Hint: Did you mean '-${arg:1:1}'?"
                continue
            fi

            # Remove all leading dashes (leave only name or pair name=value)
            arg="${arg//-}"
            # Get the option name (or pair name=value)
            local name="${arg%%=*}"

            # Check if the short option name (with one leading dash) is in the $o_short options array
            if [[ $dashes -eq 1 ]]; then
                if [[ -z "${o_short[$name]}" ]]; then
                    echo "Error: Unknown short option $arg"
                    continue
                else
                    # Replace short option name with long one
                    name="${o_short[$name]}"
                fi
            fi

            # Check if the long option name (with two leading dashes) is in the $o options array
            if [[ $dashes -eq 2 ]]; then
                if [[ -z "${o[$name]}" ]]; then
                    echo "Error: Unknown long option $arg"
                    continue
                fi
            fi

            # Check if it is a pair name=value
            if [[ $arg == *"="* ]]; then
                # Get the value (after the equal sign)
                value="${arg#*=}"
            # Otherwise, it is a standalone option without a value
            else
                value="1"
            fi

            # Check if the option is already used
            if [[ $used_opts == *"$name"* ]]; then
                echo "Error: Option '$name' was already used"
                continue
            fi

            # Replace default value in $o array with the new one
            o[$name]=$value
            used_opts+="$name "
            ((j++))
        
        # When there are no leading dashes, it is an argument
        else
            local index=$((i + 1))
            # Check if the argument is required
            if [[ $a_req[$a_name[$index]] == "required" && -z $arg ]]; then
                echo "Error: argument $index ($a_name[$index]) is required"
            fi
            if [[ $a_name[$index] ]]; then
                a[$a_name[$index]]="$arg"
            else
                a[$index]="$arg"
            fi
            ((i++))
        fi
    done

    # Save the number of arguments and options
    f[args_cnt]=$i
    f[opts_cnt]=$j
}
