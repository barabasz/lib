#!/bin/zsh
# The functions below can only be used in the Zsh shell.
#
# fn_make() is a helper function for handling options and arguments.
# It parses the options and arguments of parent function and checks for errors.
# Additionally, it prints usage, help, and version information.
#
# fn_make() uses associative arrays passed via dynamic scoping:
#   f[] - function properties (always required, it carries return code)
#   a[] - arguments array (required when the function uses arguments)
#   o[] - options array (optional, required to access options and their values)
#   s[] - strings array (optional, used to store function strings)
#   i[] - information array (optional, used to store environment info)
#   t[] - this array (optional, used to store function-specific data)
#
# Public API:
#   - fn_make()
#   - fn_debug() - can only be called after fn_make()
# All other functions are private and should not be called directly.
# Internal fn.sh functions rely on dynamic scoping to access the above arrays.
# See the examples at the end of this file for usage.
#
# TOC
#   Main public function
#       fn_make() - main function
#   Helper private functions
#       fn_set_properties() - prepare function properties
#       fn_add_defaults() - add default options to the $o array
#       fn_parse_settings() - parse arguments and options settings arrays
#       fn_parse_settings_args() - parse arguments settings array
#       fn_parse_settings_opts() - parse options settings array
#       fn_parse_arguments() - main parsing loop to iterate over all arguments
#       fn_parse_option() - parse a single option
#       fn_option_suggestion() - generate option suggestion based on error type
#       fn_parse_argument() - parse a single argument
#       fn_usage() - prepare the full usage information
#       fn_version() - prepare the version string
#       fn_hint() - prepare the hint string
#       fn_source() - prepare source code location string
#       fn_footer() - prepare footer string
#       fn_example() - prepare example string
#       fn_set_strings() - prepare function strings
#       fn_check_args() - check arguments count and return error message if needed
#       fn_set_info() - gather basic environment information
#       fn_handle_options() - options handling (show version, info, help, etc.)
#       fn_set_time() - save total time
#       fn_handle_errors() - print error messages if any
#   Debugging functions
#       fn_debug() - print debug information
#   Auxiliary functions
#       fn_load_colors() - load variables for colored output (ANSI colors)
#       fn_list_arrays() - list all associative arrays used by fn_make()
#       fn_how_long_it_took() - print milliseconds from $timestamp
#   Function examples and templates
#       fn_example_basic() - basic example function
#       fn_example_args() - example function with arguments
#       fn_example_opts() - example function with options
#
# fn_make ver. 1.39 (2025-09-22) by gh/barabasz, MIT License

##########################################################
# Main function
##########################################################

function fn_make() {
    # Load variables for colored output (ANSI colors)
    fn_load_colors
    # Check if the function is running in Zsh
    if [[ -z $ZSH_VERSION ]]; then
        log::error "${c}fn_make$x function can only be used in Zsh shell"
        return 1
    fi
    # Check if the function is called from a parent function
    if ! typeset -p f &>/dev/null || [[ ${funcstack[2]} == "" ]]; then
        log::error "${c}fn_make$x function cannot be called directly"
        return 1
    fi
    # Check if $f[] array is provided
    if [[ "${(t)f}" != *association* ]]; then
        log::error "${c}fn_make$x function requires an initialized f[] array"
        return 1
    fi
    # Create a flag that fn_make() is running
    f[run]=1

    # Arguments arrays (name, required flag, help string)
    local -A a_name; local -A a_req; local -A a_help
    # Options arrays (default values, short names, full names, help string, allowed values)
    local -A o_default; local -A o_short; local -A o_long; local -A o_help; local -A o_allowed
    # Error messages, hints and suggestions arrays
    local -A e_msg; local -A e_hint; local -A e_dym

    # Prepare function properties
    fn_set_properties
    # Gather basic environment information if i[] array is initialized
    [[ "${(t)i}" == *"association"* ]] &&  fn_set_info
    # Initialize o[] options associative array if not already
    [[ "${(t)o}" != *association* ]] && local -A o
    # Add default options to the $o array
    fn_add_defaults
    # Initialize a[] arguments associative array if not already
    [[ "${(t)a}" != *association* ]] && local -A a
    # Initialize s[] associative array if not already
    [[ "${(t)s}" != *association* ]] && local -A s
    # Parse arguments and options settings arrays, exit on error
    fn_parse_settings && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Parse function arguments
    fn_parse_arguments "$@"
    # Make function strings
    fn_set_strings
    # Save total time
    fn_set_time
    # Print debug information
    fn_debug && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Options handling (show version, basic info/usage or help)
    fn_handle_options && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Error handling
    fn_handle_errors && [[ -n "${f[return]}" ]] && return "${f[return]}"
    # Destroy a flag that fn_make() is running
    unset "f[run]"
}

##########################################################
# Helper functions to be used exclusively by the make_fn()
##########################################################

# Prepare function properties
function fn_set_properties() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    f[time_started]=$(date +"%Y-%m-%d %H:%M:%S")
    # Get timestamp from gdate (in milliseconds) or date (on macOS in seconds)
    (( $+commands[gdate] )) && f[time_fnmake_start]=$(gdate +%s%3N) || f[time_fnmake_start]=$(date +%s)
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

# Add default options to the $o array
function fn_add_defaults() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # Add default options to the list
    [[ -z ${o[info]} ]] && o[info]="i,1,show basic info and usage,[0|1]"
    [[ -z ${o[help]} ]] && o[help]="h,1,show full help,[0|1]"
    [[ -z ${o[version]} ]] && o[version]="v,1,show version,[0|1]"
    [[ -z ${o[debug]} ]] && o[debug]="d,f,enable debug mode (use ${p}-d=h$x for help),[a|A|d|D|e|E|f|h|I|i|o|O|s|t]"
    [[ -z ${o[verbose]} ]] && o[verbose]="V,1,enable verbose mode,[0|1]"
    f[opts_max]="${#o}" # maximum number of options
}

# Parse arguments and options settings arrays
function fn_parse_settings() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # Parse $a arguments array if is not empty
    if (( ${#a} != 0 )); then
        fn_parse_settings_args
    fi
    # Parse $o options array (it is always non-empty due to built-in options)
    fn_parse_settings_opts
    # Print error messages if any and exit
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} fatal error$plr in function $g$f[name]$x ${r}settings:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value" && [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]"
        done
        # Destroy a flag that fn_make() is running
        unset "f[run]"
        f[return]=1 && return 1
    fi
}

# Parse arguments settings array
function fn_parse_settings_args() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # Iterate over all arguments in the $a array
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
            (( f[args_min]++ ))
        else
            a_req[${settings[1]}]=optional
            (( f[args_opt]++ ))
        fi
        
        # Get help value
        a_help[${settings[1]}]="${settings[3]}"
        
        # Unset original $a array value
        unset "a[$key]"
        
        # Add to $a array the argument name with an empty value
        a[${settings[1]}]=""
    done
}

# Parse options settings array
function fn_parse_settings_opts() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # Iterate over all options in the $o array
    for key in ${(ok)o}; do
        local value="${o[$key]}"
        
        # Check minimum number of commas
        local comma_count=${value//[^,]/}
        if [[ ${#comma_count} -lt 2 ]]; then
            e_msg[$key]="Invalid settings for option '$y$key$x' in '$y$value$x'"
            e_hint[$key]="Missing comma or empty value in settings string (must have at least 3 values/2 commas)"
            continue
        fi
        
        # Get first two parts - short name and default value
        local parts=("${(@s:,:)value}")
        local short_name="${parts[1]:-}"
        local default_value="${parts[2]:-}"
        
        # Extract the validation part and clean description
        local orig_value="$value"
        local validation=""
        local description=""
        
        # Check if there's a validation pattern at the end
        if [[ "$orig_value" =~ ',\[[^]]*\]$' ]]; then
            # Find where the validation starts
            local validation_start=${orig_value%%,\[*}
            validation_start=$((${#validation_start}))
            
            # Extract validation (including leading comma and brackets)
            validation=${orig_value:$validation_start}
            
            # Remove validation from original value to get raw parts
            orig_value=${orig_value:0:$validation_start}
        fi
        
        # Get description (everything after the second comma)
        if [[ ${#parts} -gt 2 ]]; then
            # Extract only description part (removing validation part)
            local desc_parts=("${(@s:,:)orig_value}")
            # Join all elements from index 3 onwards with comma
            description="${(j:,:)desc_parts[3,-1]}"
        fi
        
        # Extract allowed values from validation if present
        local allowed_values=""
        if [[ -n "$validation" && "$validation" =~ ',\[(.*)\]' ]]; then
            allowed_values="${match[1]}"
        fi
        
        # Check if short_name is already used
        if [[ -n ${o_short[$short_name]+_} ]]; then
            e_msg[$key]="Option short name '$short_name' already used in '$key' ($value)"
            e_hint[$key]="Each option must have a unique short name and a unique full name."
            continue
        fi
        
        # Check if short_name is exactly one letter
        if [[ ${#short_name} -ne 1 ]]; then
            e_msg[$key]="Short option name must be exactly one letter in '$key' ($value)"
            e_hint[$key]="Correct '$key' by using a single letter for the short option name."
            continue
        fi 
        
        # Fill arrays
        o_default[$key]="$default_value"
        o_short[$short_name]=$key
        o_long[$key]="$short_name"
        o_help[$key]="$description"
        
        # Add validation if found
        if [[ -n "$allowed_values" ]]; then
            o_allowed[$key]="$allowed_values"
        fi
        
        # Unset original option value
        unset "o[$key]"
    done
}

# Main parsing loop to iterate over all arguments
function fn_parse_arguments() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # List of used options (only long names)
    local used_opts=""
    # List of used options (full arguments)
    local -A used_opts_full

    # Indexes for input position, arguments and options
    local i=0 ai=0 oi=0
    # Iterate over all input arguments
    for arg in "$@"; do
        (( i++ ))
        # Add current argument to the appropriate list
        if [[ $arg == -* ]]; then
            # If starts with a dash, it is an option
            (( oi++ ))
            f[opts_input]+="$arg "
            fn_parse_option "$arg" "$i" "$oi"
        else
            # Otherwise, it is a regular argument
            (( ai++ ))
            f[args_input]+="'$arg' "
            fn_parse_argument "$arg" "$i" "$ai"
        fi
    done
    
    f[opts_count]=$oi
    f[args_count]=$ai
    # Remove trailing spaces from the input strings
    f[opts_input]="${f[opts_input]%" "}"
    f[args_input]="${f[args_input]%" "}"
    # Get arguments count information
    if (( f[args_count] < f[args_min] || f[args_count] > f[args_max] )); then
        fn_check_args
    fi
}

# Parse a single option
function fn_parse_option() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local arg="$1" i="$2" oi="$3"
    local oic="$y$oi$x"
    local dym=""  # Will hold "Did you mean" suggestion
    
    # Extract option components
    local dashes=${#arg%%[^-]*}
    local has_value=0
    [[ $arg == *=* ]] && has_value=1
    local name="${arg#${(l:$dashes::-:)}}"; name="${name%%=*}"
    local namelen=${#name}
    local value=""
    (( has_value )) && value="${arg#*=}"
    
    # For error messages
    local argnamec="'$p$name$x'"
    local argc="'$p$arg$x'"
    
    # Basic format validation - check for common errors
    if (( namelen == 0 )); then
        # Empty option name
        if (( has_value )); then
            # Empty name with equals sign (-=value or --=value)
            e_msg[o$i]="Option $oic has empty name with equals sign in $argc"
            e_hint[o$i]="Options must have a name before the equals sign."
            fn_option_suggestion "empty_with_equals" && e_dym[o$i]="$dym"
        else
            # Just empty name (- or --)
            e_msg[o$i]="Option $oic has empty name in $argc"
            e_hint[o$i]="Options must have a name after the dash(es)."
        fi
        return
    elif (( dashes > 2 )); then
        # Too many dashes - distinguish between short and long option intent
        if (( namelen == 1 )); then
            # Single character suggests short option intent
            e_msg[o$i]="Option $oic has too many leading dashes in $argc"
            e_hint[o$i]="Option with short name should start with one dash (-)."
            fn_option_suggestion "too_many_dashes_short" && e_dym[o$i]="$dym"
        else
            # Multiple characters suggests long option intent
            e_msg[o$i]="Option $oic has too many leading dashes in $argc"
            e_hint[o$i]="Option with long name should start with two dashes (--)."
            fn_option_suggestion "too_many_dashes_long" && e_dym[o$i]="$dym"
        fi
        return
    elif [[ $arg == *=*=* ]]; then
        # Multiple equal signs
        e_msg[o$i]="Option $oic has multiple equal signs in $argc"
        e_hint[o$i]="Option values must be specified using a single equal sign."
        fn_option_suggestion "multiple_equals" && e_dym[o$i]="$dym"
        return
    elif (( dashes == 1 && namelen > 1 )); then
        # Long name with single dash
        e_msg[o$i]="Option $oic name is too long in $argc"
        e_hint[o$i]="Short option names must be a single character."
        fn_option_suggestion "long_short" && e_dym[o$i]="$dym"
        return
    elif (( dashes == 2 && namelen == 1 )); then
        # Single character with double dash - ambiguous case
        e_msg[o$i]="Option $oic name is too short in $argc"
        e_hint[o$i]="This could be either a short option with an extra dash, or an abbreviated long option."
        fn_option_suggestion "short_long" && e_dym[o$i]="$dym"
        return
    fi
    
    # Find the canonical option name (long form)
    local canonical_name=""
    
    # For short options, get the long name
    if (( dashes == 1 )); then
        if [[ -z "${o_short[$name]}" ]]; then
            # Unknown short option
            e_msg[o$i]="Option $oic short name $argnamec unknown in $argc"
            fn_option_suggestion "unknown_short" && e_dym[o$i]="$dym"
            return
        else
            # Set canonical name to the long form
            canonical_name="${o_short[$name]}"
        fi
    # For long options, verify they exist
    elif (( dashes == 2 )); then
        if [[ ! " ${(k)o_long} " == *" $name "* ]]; then
            # Unknown long option
            e_msg[o$i]="Option $oic full name $argnamec unknown in $argc"
            fn_option_suggestion "unknown_long" && e_dym[o$i]="$dym"
            return
        else
            # Set canonical name to the current name (already long form)
            canonical_name="$name"
        fi
    fi
    
    # Now check if this canonical option was already used
    if [[ $used_opts == *" $canonical_name "* ]]; then
        # Check if it was used with short or long name
        local previous_usage="${used_opts_full[$canonical_name]}"
        
        # Create appropriate error message
        e_msg[o$i]="Option $oic name $argnamec in $argc was already used as "
        e_msg[o$i]+="'$p${previous_usage}$x'"
        return
    fi
    
    # Set value and update tracking variables
    (( has_value == 0 )) && value="${o_default[$canonical_name]}"
    
    # Validate option value against allowed values if defined
    if [[ -n "${o_allowed[$canonical_name]}" && "${o_allowed[$canonical_name]}" != "" && $has_value -eq 1 ]]; then
        local allowed="${o_allowed[$canonical_name]}"
        local valid=0
        
        # Special case for debug option - allow any combination of allowed characters
        if [[ "$canonical_name" == "debug" ]]; then
            valid=1
            # Use Zsh-friendly method to iterate through characters
            for char in ${(s::)value}; do
                if [[ "$allowed" != *"$char"* ]]; then
                    valid=0
                    break
                fi
            done
        else
            # Create array of allowed values by splitting on pipe character
            local -a allowed_values=(${(s:|:)allowed})
            
            # Check if the provided value matches any allowed value
            for allowed_val in "${allowed_values[@]}"; do
                if [[ "$value" == "$allowed_val" ]]; then
                    valid=1
                    break
                fi
            done
        fi
        
        # If value is not valid, create error message
        if [[ $valid -eq 0 ]]; then
            e_msg[o$i]="Option $oic has invalid value '$p$value$x' in $argc"
            e_hint[o$i]="Allowed values for this option are: ${y}[$allowed]$x"
            return
        fi
    fi
    
    o[$canonical_name]=$value
    used_opts+=" $canonical_name "  # Add spaces to ensure exact matching
    used_opts_full[$canonical_name]="$arg"
}

# Generate option suggestion based on error type
function fn_option_suggestion() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local error_type="$1"
    local suggestion=""
    
    case $error_type in
        too_many_dashes_short)
            # Too many dashes for short option (single character)
            # Only suggest if short option exists
            if [[ -n "${o_short[$name]}" ]]; then
                suggestion="-${name}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
            
        too_many_dashes_long)
            # Too many dashes for long option (multiple characters)
            # Only suggest if long option exists
            if [[ " ${(k)o_long} " == *" $name "* ]]; then
                suggestion="--${name}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
            
        multiple_equals)
            # Keep only the first equals sign and value
            local fixed_value=${arg#*=}; fixed_value=${fixed_value%%=*}
            suggestion="${arg%%=*}=${fixed_value}"
            suggestion="${p}${suggestion}${x}"
            ;;
            
        long_short)
            # Either single character with single dash or full name with double dash
            local has_short=0
            local has_long=0
            local short_suggest=""
            local long_suggest=""
            
            # Check if short option exists
            if [[ -n "${o_short[${name[1]}]}" ]]; then
                short_suggest="-${name[1]}"
                (( has_value )) && short_suggest+="=$value"
                has_short=1
            fi
            
            # Check if long option exists
            if [[ " ${(k)o_long} " == *" $name "* ]]; then
                long_suggest="--${name}"
                (( has_value )) && long_suggest+="=$value"
                has_long=1
            fi
            
            # Build suggestion based on what exists
            if (( has_short && has_long )); then
                suggestion="${p}${short_suggest}${x} or ${p}${long_suggest}${x}"
            elif (( has_short )); then
                suggestion="${p}${short_suggest}${x}"
            elif (( has_long )); then
                suggestion="${p}${long_suggest}${x}"
            fi
            ;;
            
        short_long)
            # Could be either:
            # 1. Short option with extra dash (--s → -s)
            # 2. Abbreviated long option (--s → --something)
            
            local has_short=0
            local has_long=0
            local short_suggestion=""
            local long_suggestion=""
            
            # Check if short option exists
            if [[ -n "${o_short[$name]}" ]]; then
                short_suggestion="-${name}"
                (( has_value )) && short_suggestion+="=$value"
                has_short=1
            fi
            
            # Look for possible long option matches
            local best_match="" best_score=0
            
            # Look for long options starting with this character
            for key in "${(@k)o_long}"; do
                if [[ ${key:0:1} == ${name} ]]; then
                    # Found a long option starting with this character
                    if [[ -z "$best_match" || ${#key} < ${#best_match} ]]; then
                        # Either first match or shorter than previous best
                        best_match=$key
                        best_score=1
                    fi
                fi
            done
            
            if [[ -n "$best_match" ]]; then
                long_suggestion="--${best_match}"
                (( has_value )) && long_suggestion+="=$value"
                has_long=1
            fi
            
            # Build suggestion based on what exists
            if (( has_short && has_long )); then
                suggestion="${p}${short_suggestion}${x} or ${p}${long_suggestion}${x}"
            elif (( has_short )); then
                suggestion="${p}${short_suggestion}${x}"
            elif (( has_long )); then
                suggestion="${p}${long_suggestion}${x}"
            fi
            ;;
            
        unknown_short)
            # Try to find similar short option
            for key val in "${(@kv)o_short}"; do
                if [[ $key == ${name[1]} ]]; then
                    suggestion="-$key"
                    (( has_value )) && suggestion+="=$value"
                    suggestion="${p}${suggestion}${x}"
                    break
                fi
            done
            ;;
            
        unknown_long)
            # Try to find similar long option using prefix matching
            local best_match="" best_score=0 namelen=${#name}
            
            for key in "${(@k)o_long}"; do
                # Simple similarity method - common prefix
                local common_prefix="${name:0:1}"
                for ((j=1; j<$namelen && j<${#key}; j++)); do
                    [[ "${name:0:$j+1}" == "${key:0:$j+1}" ]] && common_prefix="${name:0:$j+1}"
                done
                
                local score=${#common_prefix}
                (( score > best_score )) && { best_match=$key; best_score=$score; }
            done
            
            if [[ -n "$best_match" && $best_score -ge 2 ]]; then
                suggestion="--${best_match}"
                (( has_value )) && suggestion+="=$value"
                suggestion="${p}${suggestion}${x}"
            fi
            ;;
            
        empty_with_equals)
            # Empty name with equals sign (-=value or --=value)
            if (( dashes == 1 )); then
                # For short option format
                suggestion="Use -o=value format for short options with values"
            else
                # For long option format
                suggestion="Use --option=value format for long options with values"
            fi
            ;;
    esac
    
    # Set the formatted "Did you mean" message in the parent scope's dym variable
    if [[ -n "$suggestion" ]]; then
        # If suggestion is already formatted with colors
        if [[ "$suggestion" == *"$p"* ]]; then
            dym="Did you mean $suggestion?"
        else
            dym="Did you mean '$suggestion'?"
        fi
        return 0  # Success - we have a suggestion
    else
        dym=""
        return 1  # No suggestion found
    fi
}

# Parse a single argument
function fn_parse_argument() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local aic="$y$ai$x"
    
    # Check if the argument is required and not empty
    if [[ $a_req[$a_name[$ai]] == "required" && -z $arg ]]; then
        e_msg[a$i]="Argument $aic ($y$a_name[$ai]$x) cannot be empty"
    fi
    
    # Add to arguments array
    if [[ $a_name[$ai] ]]; then
        a[$a_name[$ai]]="$arg"
    else
        a[$ai]="$arg"
    fi
}

# Prepare the full usage information
function fn_usage() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local i=1
    local usage="\n"
    local max_len=0
    local indent="    "
    local arr="$b→$x"
    local a_pad o_pad
    
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
    (( o_pad = max_len + 2 ))

    usage+="${y}Usage details:$x\n$indent$s[name] ${p}[options]${x} "
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

    # List required arguments
    if [[ $f[args_min] -ne 0 ]]; then
        usage+="\n\n${y}Required arguments:$x\n$indent"
        for arg_pos in ${(ok)a_name}; do
            local arg="${a_name[$arg_pos]}"
            if [[ $a_req[$arg] == "required" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$arr $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi

    # List optional arguments
    if [[ $f[args_opt] -ne 0 ]]; then
        usage+="\n${y}Optional arguments:$x\n$indent"
        for arg_pos in ${(ok)a_name}; do
            local arg="${a_name[$arg_pos]}"
            if [[ $a_req[$arg] == "optional" ]]; then
                usage+="$i: $c${(r:$a_pad:: :)arg}$arr $a_help[$arg]\n$indent";
                ((i++))
            fi
        done
        usage="${usage%\\n\\t}"
    fi

    # List options
    (( ${#a} == 0 )) && usage+="\n"
    usage+="\n${y}Options:$x\n$indent"
    for opt in ${(ok)o_long}; do
        usage+="-$p$o_long[$opt]$x or --${p}${(r:$o_pad:: :)opt}$arr $o_help[$opt]"
        # Display allowed values if defined and not empty
        if [[ -n "${o_allowed[$opt]}" && ! "debug info version verbose help" == *"$opt"* ]]; then
            usage+=": "
            local allowed="${o_allowed[$opt]}"
            if [[ -n "${o_default[$opt]}" && "${o_default[$opt]}" != "" ]]; then
                local default="${o_default[$opt]}"
                local default_c="$y${o_default[$opt]}$x"
                allowed="${allowed//$default/$default_c}"
            fi
            local replace="$x,$p "
            allowed="$p${allowed//|/$replace}$x"
            usage+="$allowed"
        fi
        usage+="\n$indent"
    done
    usage="${usage%\\n\\t}"

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
        usage+="\n${p}Options$x without a value take the ${y}default$x value from the settings."
        usage+="\nTo list option default values, use the ${p}--debug=D$x option."
    fi
    s[usage]="$usage\n"
}

# Prepare the version string
function fn_version() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local version="$s[name]"
    [[ -n $f[version] ]] && version+=" $y$f[version]$x" || version+=" [version unknown]"
    [[ -n $f[date] ]] && version+=" ($f[date])"
    s[version]="$version"
}

# Prepare the hint string
function fn_hint() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    if [[ $f[info] && $f[help] ]]; then
        log::info "Run $s[name] ${p}-i$x for basic usage or $s[name] ${p}-h$x for help."
    elif [[ $f[info] ]]; then
        log::info "Run $s[name] ${p}-i$x for usage information."
    elif [[ $f[help] ]]; then
        log::info "Run $s[name] ${p}-h$x for help."
    else
        log::info "Check source code for usage information."
        fn_source
        log::comment $s[source]
    fi
}

# Prepare source code location string
function fn_source() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local file="$f[file_path]"
    local string="${f[name]}() {"
    local line="$(grep -n "$string" "$file" | head -n 1 | cut -d: -f1)"
    s[source]="This function is defined in $s[path] (line $c$line$x)"
}

# Prepare the footer string
function fn_footer() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local footer=""
    footer+="$s[version] copyright © "
    [[ -n $f[date] ]] && footer+="$s[year] "
    footer+="by $s[author]\n"
    footer+="MIT License : https://opensource.org/licenses/MIT"
    s[footer]="$footer"
}

# Prepare the example string
function fn_example() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local indent="    " arg_pos arg_name example=""
    [[ $o[help] == 1 ]] && example+="\n"
    example+="${y}Usage example:$x" 
    [[ $o[help] == 1 ]] && example+="\n$indent" || example+=" "
    example+="$s[name] "
    if [[ ${#a} -ne 0 ]]; then
        for arg_pos in ${(ok)a_name}; do
            arg_name="${a_name[$arg_pos]}"
            if [[ $a_req[$arg_name] == "required" ]]; then
                example+="${c}<${arg_name}>${x} "
            else
                example+="${c}[$arg_name]${x} "
            fi
        done
    fi
    [[ $o[info] == 1 ]] && example+="\nRun '$s[name] ${p}-h$x' for more help."
    s[example]="$example"
}

# Warpper function to set all strings
function fn_set_strings() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    s[name]="${g}$f[name]$x"
    s[path]="${c}$f[file_path]$x"
    s[author]="${y}$f[author]$x"
    s[year]="${y}${f[date]:0:4}$x"
    s[header]="$s[name]: $f[info]"
    
    if (( o[version] == 1 )); then
        fn_version
    fi    

    if (( o[help] == 1 || o[info] == 1 )); then
        fn_example
    fi

    if (( o[help] == 1 )); then
        fn_version
        fn_usage
        fn_footer
        fn_source
    fi
}

# Check if the number of arguments is correct
function fn_check_args() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local expected="expected $y$f[args_min]$x"
    local given="given $y$f[args_count]$x"

    (( f[args_max] == 0 && f[args_count] > 0 )) && {
        e_msg[0]="No arguments expected ($given)"
        return 1
    }
    
    (( f[args_count] < f[args_min] )) && {
        local msg="Missing required argument"
        (( f[args_min] - f[args_count] > 1 )) && msg+="s"
        e_msg[0]="$msg ($expected, $given)"
        return 1
    }
    
    (( f[args_count] > f[args_max] )) && {
        e_msg[0]="Too many arguments ($expected to $y$f[args_max]$x, $given)"
        return 1
    }

}

# Gather basic ennvironment information
function fn_set_info() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    if [[ "${(t)i}" == *"association"* ]]; then
        i[arch]=$(uname -m)             # system architecture
        i[brew]=$+commands[brew]        # is Homebrew installed
        i[date]=$(date +"%Y-%m-%d")     # current date
        i[dir]=$PWD                     # current directory
        i[domain]=$(hostname -d)        # domain name
        i[host]=$(hostname -s)          # host name
        i[ip]=$(lanip)                  # local IP address
        i[os]=$(uname -s)               # operating system
        i[time]=$(date +"%H:%M:%S")     # current time
        i[user]=$(whoami)               # current user
        i[zsh]=$(echo $ZSH_VERSION)     # zsh version
        i[git]=$+commands[git]          # is git installed
        i[tty]=$(tty | sed 's|/dev/||') # terminal type
    fi
}

# Options handling (show version, basic info/usage or help)
function fn_handle_options() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    if (( o[version] == 1 || o[info] == 1 || o[help] == 1 )); then
        if (( o[version] == 1 )); then
            echo $s[version]
        elif (( o[info] == 1 )); then
            [[ $f[info] ]] && echo $s[header]
            echo $s[example]
        elif (( o[help] == 1 )); then
            [[ $f[info] ]] && echo "\n$s[header]"
            [[ $f[help] ]] && echo $f[help]
            echo "$s[example]\n$s[usage]\n$s[footer]\n$s[source]\n"
        fi
        # Destroy a flag that fn_make() is running
        unset "f[run]"
        f[return]=0 && return 0
    fi
}

# Set time difference
function fn_set_time() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    # Get timestamp from gdate (in milliseconds) or date (on macOS in seconds)
    (( $+commands[gdate] )) && local time_end=$(gdate +%s%3N) || local time_end=$(date +%s)
    local time_diff=$((time_end - f[time_fnmake_start]))
    f[time_fnmake]=$time_diff
    unset "f[time_fnmake_start]"
}

# Error handling
function fn_handle_errors() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    if [[ ${#e_msg} != 0 ]]; then
        [[ ${#e_msg} -gt 1 ]] && local plr="s" || local plr=""
        log::debug "$r${#e_msg} error$plr in $s[name] ${r}arguments:$x"
        for key in ${(ok)e_msg}; do
            local value="${e_msg[$key]}"
            log::error "$value"
            [[ $e_hint[$key] ]] && log::normal "$e_hint[$key]" 
            [[ $e_dym[$key] ]] && log::info "$e_dym[$key]"
        done
        fn_hint
        # Destroy a flag that fn_make() is running
        unset "f[run]"
        f[return]=1 && return 1
    else
        f[return]="" && return 0
    fi
}

##########################################################
# Debugging function
##########################################################

# Print debug information
function fn_debug() {
    # Check if fn_make() was called before
    (( ! f[run] )) && log::error "This function cannot be called directly." && return 1
    local debug="${1:-${o[debug]}}"
    if [[ "$debug" && ! $debug =~ "d" ]]; then
        local max_key_length=15
        local max_value_length=40
        local count
        local q="$y'$x"
        local arr="$b→$x"
        # Debug modes
        local -A modes=(
            [A]="Internal $y\$a_*[]$x argument arrays"
            [a]="Arguments from $y\$a[]$x array"
            [D]="Default values for options"
            [d]="Disable debugging inside ${g}fn_make$x"
            [e]="Exit after debugging"
            [E]="Internal $y\$e_*[]$x error arrays"
            [f]="Function properties from $y\$f[]$x array"
            [h]="Help $y(default)$x"
            [I]="All internal arrays"
            [i]="Information from $y\$i[]$x array"
            [O]="Internal $y\$o_*[]$x option arrays"
            [o]="Options from $y\$o[]$x array"
            [s]="Strings from $y\$s[]$x array"
            [t]="This function from $y\$t[]$x array"
        )

        # If no valid mode is set, show help
        if [[ ! $debug =~ [AaDdeEfhIiOost] ]]; then
            log::info "No valid debug mode set, falling back to help mode."
            debug="h"
        fi

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
        
        # show exit_mode info when debug mode is not set to 'e'
        if [[ $debug =~ "e" ]]; then
            log::warning "Exit mode enabled: $s[name] will exit after debug."
            f[return]=0
        fi
        # show debug modes when debug mode is not set to 'h'
        if [[ ! $debug =~ "h" ]]; then
            log::info "Use option ${c}-d=h$x to show available debug modes."
        fi

        # list modes
        if [[ $debug =~ "h" ]]; then
            max_key_length=2
            log::info "${y}Debug modes${x} (${#modes}):"
            for key value in "${(@kv)modes}"; do
                echo "    ${(r:$max_key_length:)key} $arr $q$value$q"
            done | sort
            echo "Debug modes can be combined, e.g. $c-d=aof$x of $c--debug=aof$x."
            echo "Debuggin of ${g}fn_make$x internal arrays (${c}i$x mode) works only if ${c}d$x is not set."
        fi

        # List internal $o_default[] array (options default values)
        if [[ $debug =~ "D" ]]; then
            fn_list_array "o_default" "Option default values"
        fi

        # List internal argument arrays
        if [[ $debug =~ "A" ]]; then
            fn_list_array "a_name" "Argument names"
            fn_list_array "a_req" "Required arguments"
            fn_list_array "a_help" "Argument help strings"
        fi

        # List internal option arrays
        if [[ $debug =~ "O" ]]; then
            fn_list_array "o_long" "Option long names"
            fn_list_array "o_short" "Option short names"
            fn_list_array "o_help" "Option help strings"
            fn_list_array "o_allowed" "Option allowed values"
            fn_list_array "o_default" "Option default values"
        fi

        # List internal error arrays
        if [[ $debug =~ "E" ]]; then
            fn_list_array "e_msg" "Error messages"
            fn_list_array "e_hint" "Error hints"
            fn_list_array "e_dym" "Error suggestions"
        fi

        # list arguments $a[]
        [[ $debug =~ "a" ]] && fn_list_array "a" "Arguments"
        # list options $o[]
        [[ $debug =~ "o" ]] && fn_list_array "o" "Options"
        # list properties $f[]
        [[ $debug =~ "f" ]] && fn_list_array "f" "Function properties"
        # list info $i[]
        [[ $debug =~ "i" ]] && fn_list_array "i" "Environment information"
        # list strings $s[]
        [[ $debug =~ "s" ]] && fn_list_array "s" "Strings"
        # list this function values $t[]
        [[ $debug =~ "t" ]] && fn_list_array "t" "This function"
        # Debug footer
        print::footer "${r}Debug end$x"
        # Exit if debug mode is set to 'e' and destroy a flag that fn_make() is running
        [[ $debug =~ "e" ]] && unset "f[run]" && f[return]=0 && return 0
    fi
}

##########################################################
# Auxiliary functions
##########################################################

# Load base colors (ANSI escape codes)
function fn_load_colors() {
    b=$(ansi blue)          # arrows
    c=$(ansi cyan)          # arguments, url, file path
    g=$(ansi green)         # function name
    p=$(ansi bright purple) # options
    r=$(ansi red)           # errors
    w=$(ansi white)         # plain text
    y=$(ansi yellow)        # highlight
    x=$(ansi reset)         # reset
}

# List associative array contents
function fn_list_array() {
    setopt localoptions extended_glob
    local array_name=$1
    local display_name=$2
    local array_msg="${y}${display_name}${x} ${g}\$${array_name}[]$x"
    local mvl=45 # max value length
    local indent="    " # left indent
    
    # Check if array exists
    if [[ ! ${(P)array_name+set} ]]; then
        log::info "$array_msg was not initialized."
        return 1
    fi

    # Check if it is an associative array
    if [[ "${(Pt)array_name}" != *association* ]]; then
        log::info "$array_msg is not an associative array."
        return 1
    fi

    # Check if array is empty
    if [[ -z ${(P)array_name} ]]; then
        log::info "$array_msg is empty."
        return 0
    fi

    # Print array contents
    log::info "$array_msg (${(P)#array_name}):"
    # Iterate through array elements
    local key value
    for key value in "${(@Pkv)array_name}"; do
        # Clean up value for display
        value=${value//$'\n'/} && value=${value//$'\r'/}
        value=${value//   / } && value=${value//  / }
        value=${value//$'\e'(\[[0-9;]##[[:alpha:]])/}
        (( ${#value} > mvl )) && value="${value[1,mvl]}$y...$x"
        echo "$indent${(r:$max_key_length:)key} $arr $q$value$q"
    done | sort
    return 0
}

# Print milliseconds from timestamp=$(gdate +%s%3N 2>/dev/null)
function fn_how_long_it_took() {
    local r=$(ansi bright red)
    local x=$(ansi reset)
    local stage="$1"
    local start=$timestamp
    local now=$(gdate +%s%3N 2>/dev/null)
    local diff=$((now - start))
    print -- "${r}[${(l:4:: :)diff} ms]${x} $stage"
}

##########################################################
# Self-test function
##########################################################

# Self-test harness (internal) – public entry point: fn_self_test()
function fn_self_test() {
    local self_test_started=$(gdate +%s%3N 2>/dev/null)
    setopt localoptions extended_glob
    fn_load_colors
    local quiet=0
    [[ "$1" == "-q" ]] && quiet=1

    local -i total=0 pass=0 fail=0
    local -a failed_names
    local FORBIDDEN_PHRASE="function cannot be called directly"

    # Strip ANSI escape sequences
    _fst_strip_ansi() {
        setopt localoptions extended_glob
        local s="$1"
        print -- "${s//$'\e'(\[[0-9;]##[[:alpha:]])/}"
    }

    # Generic test runner – expects substring present
    # _fst_run "NAME" "command" "expected substring" expected_rc
    _fst_run() {
        local name="$1" command="$2" expect_sub="$3" expect_rc="$4"
        local out rc clean ok=1
        (( total++ ))
        out=$(eval "$command" 2>&1)
        rc=$?
        clean=$(_fst_strip_ansi "$out")

        # Forbidden phrase check (global)
        if [[ "$clean" == *"$FORBIDDEN_PHRASE"* ]]; then
            ok=0
            (( quiet == 0 )) && echo "[${r}FAIL$x] [$name] Forbidden phrase detected: '$FORBIDDEN_PHRASE'"
        fi

        if [[ -n "$expect_rc" && $rc -ne $expect_rc ]]; then
            ok=0
            (( quiet == 0 )) && echo "[${r}FAIL$x] [$name] Return code $rc (expected $expect_rc)"
        fi
        if [[ -n "$expect_sub" && "$clean" != *"$expect_sub"* ]]; then
            ok=0
            if (( quiet == 0 )); then
                echo "[${r}FAIL$x] [$name] Missing substring: $expect_sub"
                echo "---- OUTPUT (clean) ----"
                echo "$clean"
                echo "------------------------"
            fi
        fi
        if (( ok )); then
            (( pass++ ))
            (( quiet == 0 )) && echo "[${g}OK  $x] [$name]"
        else
            (( fail++ ))
            failed_names+=("$name")
        fi
    }

    # Runner sprawdzający, że substring NIE występuje
    # _fst_run_absent "NAME" "command" "forbidden substring" expected_rc
    _fst_run_absent() {
        local name="$1" command="$2" forbid_sub="$3" expect_rc="$4"
        local out rc clean ok=1
        (( total++ ))
        out=$(eval "$command" 2>&1)
        rc=$?
        clean=$(_fst_strip_ansi "$out")

        # Forbidden phrase check (global)
        if [[ "$clean" == *"$FORBIDDEN_PHRASE"* ]]; then
            ok=0
            (( quiet == 0 )) && echo "[${r}FAIL$x] [$name] Forbidden phrase detected: '$FORBIDDEN_PHRASE'"
        fi

        if [[ -n "$expect_rc" && $rc -ne $expect_rc ]]; then
            ok=0
            (( quiet == 0 )) && echo "[${r}FAIL$x] [$name] Return code $rc (expected $expect_rc)"
        fi
        if [[ "$clean" == *"$forbid_sub"* ]]; then
            ok=0
            if (( quiet == 0 )); then
                echo "[${r}FAIL$x] [$name] Unexpected substring present: $forbid_sub"
                echo "---- OUTPUT (clean) ----"
                echo "$clean"
                echo "------------------------"
            fi
        fi
        if (( ok )); then
            (( pass++ ))
            (( quiet == 0 )) && echo "[${g}OK  $x] [$name]"
        else
            (( fail++ ))
            failed_names+=("$name")
        fi
    }

    #####################################################
    # Local test functions
    #####################################################

    _fst_func_args() {
        local -A f a o _def_opts
        f[info]="Self-test function (args+opts)."
        f[version]="0.1"
        f[date]="2025-09-21"
        a[1]="first,r,first argument"
        a[2]="second,r,second argument"
        a[3]="third,o,third argument"
        o[level]="l,medium,difficulty level,[easy|medium|hard]"
        o[mode]="m,fast,execution mode,[fast|slow]"
        local _k _spec _parts
        for _k in level mode; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        print -- "ARGS first='${a[first]}' second='${a[second]}' third='${a[third]}'"
        for opt in level mode; do
            if [[ -n ${o[$opt]+_} ]]; then
                print -- "SET:${opt}=${o[$opt]}"
            else
                print -- "UNSET(${opt} default=${_def_opts[$opt]})"
            fi
        done
        return 0
    }

    _fst_func_opts() {
        local -A f o _def_opts
        f[info]="Self-test options only."
        o[alpha]="a,1,alpha flag,[0|1]"
        o[color]="c,red,color value,[red|green|blue]"
        local _k _spec _parts
        for _k in alpha color; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        for opt in alpha color; do
            if [[ -n ${o[$opt]+_} ]]; then
                print -- "SET:${opt}=${o[$opt]}"
            else
                print -- "UNSET(${opt} default=${_def_opts[$opt]})"
            fi
        done
        return 0
    }

    _fst_func_opts_extra() {
        local -A f o _def_opts
        f[info]="Self-test extended options."
        o[name]="n,,custom name"
        o[path]="p,/tmp,file path,[]"
        o[free]="f,42,free value"
        o[strict]="s,one,strict option,[one|two]"
        local _k _spec _parts
        for _k in name path free strict; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        for opt in name path free strict; do
            if [[ -n ${o[$opt]+_} ]]; then
                print -- "SET:${opt}=${o[$opt]}"
            else
                print -- "UNSET(${opt} default=${_def_opts[$opt]})"
            fi
        done
        return 0
    }

    _fst_func_suggest() {
        local -A f a o _def_opts
        f[info]="Suggestion test."
        a[1]="arg1,r,first"
        a[2]="arg2,r,second"
        o[level]="l,medium,difficulty level,[easy|medium|hard]"
        o[mode]="m,fast,execution mode,[fast|slow]"
        local _k _spec _parts
        for _k in level mode; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        return 0
    }

    _fst_func_args_info() {
        local -A f a o i _def_opts
        f[info]="Args+opts+info."
        a[1]="first,r,first argument"
        a[2]="second,r,second argument"
        o[level]="l,medium,difficulty level,[easy|medium|hard]"
        local _k _spec _parts
        for _k in level; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        print -- "INFO_TEST_OK"
        return 0
    }

    _fst_func_opts_dup() {
        local -A f o _def_opts
        f[info]="Duplicate option test."
        o[color]="c,red,color value,[red|green|blue]"
        local _k _spec _parts
        for _k in color; do
            _spec="${o[$_k]}"
            _parts=("${(@s:,:)_spec}")
            _def_opts[$_k]="${_parts[2]}"
        done
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        return 0
    }

    _fst_func_none() {
        local -A f
        f[info]="No-args function."
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        print -- "OK no-args"
        return 0
    }

    _fst_func_ansi() {
        local -A f
        f[info]=$'\e[31mRED_TEXT\e[0m'
        fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
        return 0
    }

    #####################################################
    # Test set (43)
    #####################################################

    # Basic args
    _fst_run "NO_ARGS_OK"              "_fst_func_none"                                           "OK no-args" 0
    _fst_run "ARGS_REQUIRED_OK"        "_fst_func_args one two"                                   "ARGS first='one' second='two' third=''" 0
    _fst_run "ARGS_WITH_OPTIONAL"      "_fst_func_args one two three"                             "third='three'" 0
    _fst_run "ARGS_MISSING"            "_fst_func_args one"                                       "Missing required argument" 1
    _fst_run "ARGS_TOO_MANY"           "_fst_func_args one two three four"                        "Too many arguments" 1

    # Options defaults / overrides / validation
    _fst_run "OPTS_DEFAULTS"           "_fst_func_args one two"                                   "UNSET(level default=medium)" 0
    _fst_run "OPTS_OVERRIDE"           "_fst_func_args one two --level=hard --mode=slow"          "SET:level=hard" 0
    _fst_run "OPTS_INVALID_VALUE"      "_fst_func_args one two --level=impossible"                "invalid value" 1
    _fst_run "OPTS_DUPLICATE"          "_fst_func_opts --color=red --color=green"                 "already used" 1
    _fst_run "OPTS_DEFAULT_ALPHA"      "_fst_func_opts"                                           "UNSET(alpha default=1)" 0
    _fst_run "OPTS_CHANGED"            "_fst_func_opts --alpha=0 --color=blue"                    "SET:color=blue" 0
    _fst_run "OPTS_COLOR_INVALID"      "_fst_func_opts --color=yellow"                            "invalid value" 1

    # Extended option patterns
    _fst_run "OPTS_NODEFAULT_UNSET"    "_fst_func_opts_extra"                                     "UNSET(name default=)" 0
    _fst_run "OPTS_NODEFAULT_SET"      "_fst_func_opts_extra --name=Alice"                       "SET:name=Alice" 0
    _fst_run "OPTS_EMPTY_ALLOWED_UNSET" "_fst_func_opts_extra"                                    "UNSET(path default=/tmp)" 0
    _fst_run "OPTS_EMPTY_ALLOWED_SET"  "_fst_func_opts_extra --path=/var/tmp"                     "SET:path=/var/tmp" 0
    _fst_run "OPTS_NO_VALIDATION_SET"  "_fst_func_opts_extra --free=100"                         "SET:free=100" 0
    _fst_run "OPTS_STRICT_DEFAULT"     "_fst_func_opts_extra"                                     "UNSET(strict default=one)" 0
    _fst_run "OPTS_STRICT_SET_VALID"   "_fst_func_opts_extra --strict=two"                        "SET:strict=two" 0
    _fst_run "OPTS_STRICT_SET_INVALID" "_fst_func_opts_extra --strict=three"                      "invalid value" 1

    # Suggestion
    _fst_run "OPTS_SUGGESTION"         "_fst_func_suggest one two --levl=hard"                    "Did you mean" 1

    # Option format edge cases
    _fst_run "OPT_TOO_MANY_DASHES_SHORT" "_fst_func_args one two ---l=hard"                       "too many leading dashes" 1
    _fst_run "OPT_TOO_MANY_DASHES_LONG"  "_fst_func_args one two ----level=hard"                  "too many leading dashes" 1
    _fst_run "OPT_MULTIPLE_EQUALS"       "_fst_func_args one two --level=hard=extra"              "multiple equal signs" 1
    _fst_run "OPT_EMPTY_NAME_EQUALS_SHORT" "_fst_func_args one two -=x"                           "empty name with equals sign" 1
    _fst_run "OPT_EMPTY_NAME_EQUALS_LONG"  "_fst_func_args one two --=x"                          "empty name with equals sign" 1
    _fst_run "OPT_EMPTY_NAME_SINGLE_DASH" "_fst_func_args one two -"                              "empty name in" 1
    _fst_run "OPT_EMPTY_NAME_DOUBLE_DASH" "_fst_func_args one two --"                             "empty name in" 1
    _fst_run "OPT_EMPTY_VALIDATED_VALUE" "_fst_func_args one two --level="                        "invalid value" 1
    _fst_run "OPT_EMPTY_FREE_VALUE" "_fst_func_opts_extra --name="                                "SET:name=" 0
    _fst_run_absent "DEBUG_SUPPRESSED" "_fst_func_args one two -d=dfi"                            "Debug mode" 0

    # Duplicate short + long
    _fst_run "DUPLICATE_SHORT_LONG"    "_fst_func_opts_dup -c=red --color=green"                  "already used" 1

    # Multi-error (unknown + too many args)
    _fst_run "MULTI_ERRORS_UNKNOWN"    "_fst_func_args one two three four --badopt=1"            "unknown in" 1
    _fst_run "MULTI_ERRORS_TOOMANY"    "_fst_func_args one two three four --badopt=1"            "Too many arguments" 1

    # Optional / required argument empties
    _fst_run "ARGS_OPTIONAL_EMPTY"     "_fst_func_args one two \"\""                              "third=''" 0
    _fst_run "ARGS_REQUIRED_EMPTY"     "_fst_func_args one \"\""                                  "cannot be empty" 1

    # Strict option implicit default
    _fst_run "OPTS_STRICT_IMPLICIT"    "_fst_func_opts_extra --strict"                            "SET:strict=one" 0

    # Debug combined
    _fst_run "DEBUG_COMBINED"          "_fst_func_args one two -d=afiO"                           "Option long names" 0
    # Debug mode (normal)
    _fst_run "DEBUG_MODE_F"            "_fst_func_args one two -d=f"                              "Function properties" 0
    _fst_run "DEBUG_MODE_FLAG_ONLY"    "_fst_func_args one two -d"                                "Function properties" 0
    # Debug exit mode (-d=fe) – brak body
    _fst_run_absent "DEBUG_EXIT_MODE"  "_fst_func_args one two -d=fe"                             "ARGS first=" 0

    # Early exits: version / info / help
    _fst_run_absent "VERSION_EARLY_EXIT" "_fst_func_args one two -v"                              "ARGS first=" 0
    _fst_run_absent "INFO_EARLY_EXIT"    "_fst_func_args one two -i"                              "ARGS first=" 0
    _fst_run_absent "HELP_EARLY_EXIT"    "_fst_func_args one two -h"                              "ARGS first=" 0

    # Debug environment info
    _fst_run "DEBUG_MODE_I"            "_fst_func_args_info one two -d=i"                         "Environment information" 0
    # Time measurement present
    _fst_run "TIME_MEASURE"            "_fst_func_args one two -d=f"                              "time_fnmake" 0

    # ANSI checks
    _fst_run "ANSI_INFO"               "_fst_func_ansi -i"                                        "RED_TEXT" 0
    _fst_run "ANSI_STRIPPER_LOCAL"     "_fst_strip_ansi \$'\e[32mGREEN\e[0m plain'"               "GREEN plain" 0

    #####################################################
    # Summary
    #####################################################
    local summary="SELF-TEST: total=$total pass=$pass fail=$fail"
    local now=$(gdate +%s%3N 2>/dev/null)
    local diff=$((now - self_test_started))
    if (( fail > 0 )); then
        echo "$summary"
        if (( quiet == 0 )); then
            echo "Failed tests:"
            for t in "${failed_names[@]}"; do
                echo "  - $t"
            done
        fi
        echo "Self-test interrupted after ${diff} ms."
        (( fail > 255 )) && return 255 || return $fail
    else
        echo "$summary (${g}OK$x) completed in ${diff} ms."
        return 0
    fi
}

##########################################################
# Function examples and templates
##########################################################

# Full function example with all features and detailed comments
function fn_function_example() {
 ## Initialize required f[] associative array
    # it carries function properties and return code (cannot be omitted)
    local -A f
 ## Initialize optional associative arrays (you can omit their initialization)
    # a[] array is used to store arguments
    # Omit initialization if you do not need arguments
    local -A a
    # o[] array is used to specify options and their values
    # Omit initialization if you do not need extra options
    local -A o
    # s[] array can be used to store string values
    # Omit initialization if you do not need array of strings
    local -A s
    # t[] array can be used to store this function's data
    # Omit initialization if you do not need such array
    local -A t
    # i[] array stores information about the environment and execution context
    # Omit initialization if you do not need this information (speeds up execution)
    local -A i
 ## Define function properties
    f[info]="Template for functions." # info about the function
    f[version]="1.1" # version of the function
    f[date]="2025-05-20" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
 ## Define arguments
    # Arguments are positional and must be provided in the specified sequence
    # Format: a[<position>]="<name>,<required_flag>,<description>"
    a[1]="arg_one,r,description of the first argument"
    a[2]="arg_two,r,description of the second argument"
    a[3]="arg_three,o,description of the third argument"
    a[4]="arg_four,o,description of the fourth argument"
 ## Define extra options
    # Default options are: [i]nfo, [h]elp, [v]ersion, [d]ebug, [V]erbose
    # Format: o[<long_name>]="<short_name>,<default_value>,<description>,[allowed_values]"
    # Options examples:
    o[something]="s,0,some other option,[0|1|2]" # Restricts values to only 0, 1, or 2
    o[level]="l,medium,difficulty level,[easy|medium|hard]" # Only specific predefined values allowed
    o[format]="f,json,output format,[csv|json|xml|text|tsv]" # Only specific format values allowed
    o[name]="n,,custom name" # Empty default value, accepts any user input (no validation)
    o[path]="p,/tmp,file path,[]" # Has default value, but accepts any user input (empty brackets)
    # Run fn_make() to parse arguments and options
    fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
 ## Main function goes here
    # Setting a value in 'this' t[] array
    t[example]="This a function example."
    # This is return code from fn_make()
    print "Return code from fn_make(): ${f[return]}"
    # Accessing arguments in a[] array:
    echo "This is the 1st argument: ${a[argument1]}"
    # Accessing options in o[] array:
    echo "This is the value of the 'something' option: ${o[something]}"
    # Accessing strings in s[] array:
    echo "This is the name of the function: ${s[name]}"
    # Accessing function properties in f[] array:
    echo "This is the path to the function file: ${f[file_path]}"
    # Accessing information in i[] array:
    echo "This function was run by user: ${i[user]}"
    # Debug the t[] array and exit
    # fn_debug te
}

# Basic function template (one argument and no extra options)
function fn_function_template() {
    local -A a; local -A f
    f[info]="Template for functions."
    f[version]="1.05"
    f[date]="2025-05-20"
    a[1]="argument1,r,description of the first argument"
    fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
 ## Main function goes here
    print "Main function goes here."
}

# Minimal function template (without arguments and extra options)
function fn_function_template_short() {
    local -A f
    fn_make "$@"; [[ "${f[return]}" ]] && return "${f[return]}"
 ## Main function goes here
    print "This function doesn't take any arguments."
}