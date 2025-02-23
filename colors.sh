#!/bin/zsh

# ANSI colors for functions

# http://jafrog.com/2013/11/23/colors-in-terminal.html
# https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124

# To list all colors available in 256 color mode with their codes run
# 256-color mode — foreground: ESC[38;5;#m   background: ESC[48;5;#m
# for code in {0..255}
#     do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
# done

function showcolors() {
    printh "Standard colors"
    printf "${red}red${reset}, ${green}green${reset}, ${yellow}yellow${reset}, ${blue}blue${reset}, ${purple}purple${reset}, ${cyan}cyan${reset}, ${white}white${reset}"
    printh "Intensive colors"
    printf "${redi}red${reset}, ${greeni}green${reset}, ${yellowi}yellow${reset}, ${bluei}blue${reset}, ${purplei}purple${reset}, ${cyani}cyan${reset}, ${whitei}white${reset}"
    printh "Bold colors"
    printf "${redb}red${reset}, ${greenb}green${reset}, ${yellowb}yellow${reset}, ${blueb}blue${reset}, ${purpleb}purple${reset}, ${cyanb}cyan${reset}, ${whiteb}white${reset}"
    printh "Background colors"
    printf "${bgred}   ${reset}, ${bggreen}     ${reset}, ${bgyellow}yellow${reset}, ${bgblue}blue${reset}, ${bgpurple}purple${reset}, ${bgcyan}cyan${reset}, ${bgwhite}white${reset}"
    printh "Intensive background colors"
    printf "${bgredi}red${reset}, ${bggreeni}green${reset}, ${bgyellowi}yellow${reset}, ${bgbluei}blue${reset}, ${bgpurplei}purple${reset}, ${bgcyani}cyan${reset}, ${bgwhitei}white${reset}"
    printf "\n"
}

function showcolors256() {
    printh "256 colors"
    for code in {0..255}
        do echo -e "\e[38;5;${code}m"'\\e[38;5;'"$code"m"\e[0m"
    done
}

## clear all
clear='\e[0m'
reset='\e[0m'

## text standard
black='\e[0;30m'
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
blue='\e[0;34m'
purple='\e[0;35m'
cyan='\e[0;36m'
white='\e[0;37m'

## text bold
blackb='\e[1;30m'
redb='\e[1;31m'
greenb='\e[1;32m'
yellowb='\e[1;33m'
blueb='\e[1;34m'
purpleb='\e[1;35m'
cyanb='\e[1;36m'
whiteb='\e[1;37m'

## text intensive
blacki='\e[0;90m'
redi='\e[0;91m'
greeni='\e[0;92m'
yellowi='\e[0;93m'
bluei='\e[0;94m'
purplei='\e[0;95m'
cyani='\e[0;96m'
whitei='\e[0;97m'

## text bold intensive
blackbi='\e[1;90m'
redbi='\e[1;91m'
greenbi='\e[1;92m'
yellowbi='\e[1;93m'
bluebi='\e[1;94m'
purplebi='\e[1;95m'
cyanbi='\e[1;96m'
whitebi='\e[1;97m'

## background standard
bgblack='\e[40m'
bgred='\e[41m'
bggreen='\e[42m'
bgyellow='\e[43m'
bgblue='\e[44m'
bgpurple='\e[45m'
bgcyan='\e[46m'
bgwhite='\e[47m'

## background intensive
bgblacki='\e[0;100m'
bgredi='\e[0;101m'
bggreeni='\e[0;102m'
bgyellowi='\e[0;103m'
bgbluei='\e[0;104m'
bgpurplei='\e[0;105m'
bgcyani='\e[0;106m'
bgwhitei='\e[0;107m'
