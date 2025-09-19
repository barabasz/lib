#!/bin/zsh
#
# Test functions

function test_print_arr() {

    local podstawowa_tablica
    podstawowa_tablica=("Pierwszy element" "Drugi element" "Trzeci element")
    log::info "Podstawowa zwykła tablica"
    print::arr "$(typeset -p podstawowa_tablica)"

    local -A dane_osobowe
    dane_osobowe[imie]="Anna"
    dane_osobowe[nazwisko]="Kowalska"
    dane_osobowe[wiek]="25"
    dane_osobowe[miasto]="Kraków"
    log::info "\nPodstawowa tablica asocjacyjna:"
    print::arr "$(typeset -p dane_osobowe)"

    local pusta_zwykla=()
    log::info "\nPusta zwykła tablica:"
    print::arr "$(typeset -p pusta_zwykla)"

    local -A pusta_asocjacyjna=()
    log::info "\nPusta tablica asocjacyjna:"
    print::arr "$(typeset -p pusta_asocjacyjna)"

}

function fn_template_bad() {
    local -A a; local -A f; local -A o; local -A s
    o[something]="s,0,some other option"
    o[something2]="ss,0,some other option"
    fn_make "$@"; [[ -n "${f[return]}" ]] && return "${f[return]}"
    echo "This is the output of the $s[name] function."
}
