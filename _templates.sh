#!/bin/zsh
#
# TEMPLATES

### FUNCTION TEMPLATE

function _fn_tpl() {
    local -A f; local -A o; local -A a; local -A s
    f[info]="Template for functions." # info about the function
    f[args_required]="agrument1 argument2" # required arguments
    f[args_optional]="agrument3 agrument4" # optional arguments
    f[opts]="debug help info version example" # optional options
    f[version]="0.2" # version of the function
    f[date]="2025-05-06" # date of last update
    f[help]="It is just a help stub..." # content of help, i.e.: f[help]=$(<help.txt)
    fn_make "$@" && [[ -n "${f[return]}" ]] && return "${f[return]}"
    shift "$f[opts_count]"
### main function
    [[ $o[d] == 1 ]] && fn_debug # show debug info
    echo "This is the output of the $s[name] function."
    echo "This is the path to the function: $s[path]"
    echo "This is the first argument: $a[1]"
    echo "This is 'example' option value: $o[e]"
}
