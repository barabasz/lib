#!/bin/zsh
#
# Test functions
# zsh-specific functions - requires zsh, will not work in bash

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

function is_array_empty() {
    local array_name=$1
    if (( ${(P)#array_name} == 0 )); then
        print "$array_name is empty."
    else 
        print "$array_name is not empty."
    fi
}

function is_array_initialized() {
    local array_name=$1
    if [[ "${(Pt)array_name}" != *association* ]]; then
        print "$array_name was not initialized."
    else
        print "$array_name was initialized."
    fi
}