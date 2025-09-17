#!/bin/zsh
#
# Functions for OS detection and information

# Get OS name
function osname() {
    local ostype=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [[ $ostype == 'darwin' ]]; then
        printf "macos"
    elif [[ $ostype == 'linux' ]]; then
        if [[ -f /etc/os-release ]]; then
            local id=$(cat /etc/os-release | grep "^ID=")
            printf "${id#*=}"
        fi
    else
        printf "unknown"
    fi
}

# Get OS Name (proper case)
function osName() {
    local osName=""
    case $(osname) in
        macos) echo "macOS" ;;
        ubuntu) echo "Ubuntu" ;;
        debian) echo "Debian" ;;
        *) echo "unknown" ;;
    esac
}

# Get OS code name
function oscodename() {
    local codename=""
    if [[ $(osname) == 'macos' ]]; then
        codename=$(macosname)
    else
        codename=$(awk -F= '/^VERSION_CODENAME=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
    fi
    echo "${(C)codename}"
}

# Get macOS codename
function macosname() {
    local version=$(sw_vers -productVersion)
    local version="10.5"
    local major=$(echo $version | cut -d. -f1)
    case $major in
        26) printf "Tahoe" ;;
        15) printf "Seqouia" ;;
        14) printf "Sonoma" ;;
        13) printf "Ventura" ;;
        12) printf "Monterey" ;;
        11) printf "Big Sur" ;;
        10) 
            local minor=$(echo $version | cut -d. -f2)
            case $minor in
                16) printf "Big Sur" ;;
                15) printf "Catalina" ;;
                14) printf "Mojave" ;;
                13) printf "High Sierra" ;;
                12) printf "Sierra" ;;
                11) printf "El Capitan" ;;
                10) printf "Yosemite" ;;
                9)  printf "Mavericks" ;;
                8)  printf "Mountain Lion" ;;
                7)  printf "Lion" ;;
                6)  printf "Snow Leopard" ;;
                5)  printf "Leopard" ;;
                *)  printf "Unknown" ;;
            esac
            ;;
        *)  printf "Unknown" ;;
    esac
}

# Display OS version
function osversion() {
    local osver=""
    if [[ $(osname) == "macos" ]]; then
        osver=$(sw_vers -productVersion)
    else
        osver=$(awk -F= '/^VERSION_ID=/{gsub(/^"|"$/, "", $2); print $2}' /etc/os-release)
    fi
    echo $osver
}

# Get OS icon
function osicon() {
    case $(osname) in
        macos) printf "\Uf8ff" ;;
        ubuntu) printf "\Uf31b" ;;
        debian) printf "\Uf306" ;;
        redhat) printf "\Uef5d" ;;
        *) printf "" ;;
    esac
}

# Calculate uptime in hours
function uptimeh() {
    local uptime=0 boot_timestamp=0 current_timestamp=0
    if [[ $(osname) == "macos" ]]; then
        boot_timestamp=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
        current_timestamp=$(date +%s)
        uptime=$((current_timestamp - boot_timestamp))
    else
        uptime=$(awk '{printf "%d\n", $1}' /proc/uptime)
    fi
    echo "$(htime $uptime)"
}
