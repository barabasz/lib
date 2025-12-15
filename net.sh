#!/bin/zsh

# Networking functions
# zsh-specific functions - requires zsh, will not work in bash

# Function to retrieve the public IP address (IPv4 or IPv6)
# Usage: wanip [-6] [-v] [-t TIMEOUT]
#   -6: Get IPv6 address instead of IPv4
#   -v: Verbose mode (show which service was used)
#   -t: Set timeout in seconds (default: 1)
wanip() {
    local ipv6 verbose timeout=1 ip service
    local -a services_v4 services_v6
    
    # Parse options
    while [[ "$1" == -* ]]; do
        case "$1" in
            -6) ipv6=1 ;;
            -v) verbose=1 ;;
            -t) timeout="$2"; shift ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
        shift
    done
    
    # Define services for IPv4 and IPv6
    services_v4=(
        "icanhazip.com:curl -4 -fsS -m $timeout https://icanhazip.com"
        "ifconfig.me:curl -4 -fsS -m $timeout https://ifconfig.me/ip"
        "ipify.org:curl -4 -fsS -m $timeout https://api.ipify.org"
        "ipecho.net:curl -4 -fsS -m $timeout https://ipecho.net/plain"
        "OpenDNS:dig +short -4 myip.opendns.com @resolver1.opendns.com"
        "Akamai:dig +short -4 whoami.akamai.net @ns1-1.akamaitech.net"
    )
    
    services_v6=(
        "icanhazip.com:curl -6 -fsS -m $timeout https://icanhazip.com"
        "ifconfig.me:curl -6 -fsS -m $timeout https://ifconfig.me/ip"
        "ipify.org:curl -6 -fsS -m $timeout https://api6.ipify.org"
        "ipv6.icanhazip.com:curl -6 -fsS -m $timeout https://ipv6.icanhazip.com"
    )
    
    # Select services based on IP version
    local -a services
    if [[ -n "$ipv6" ]]; then
        services=("${services_v6[@]}")
        ip_regex='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^([0-9a-fA-F]{0,4}:){1,7}:[0-9a-fA-F]{0,4}$|^([0-9a-fA-F]{0,4}:){1,7}:$|^:([0-9a-fA-F]{0,4}:){1,7}$|^::$|^::([0-9a-fA-F]{0,4}:){1,7}$|^([0-9a-fA-F]{0,4}:){1,7}::$'
    else
        services=("${services_v4[@]}")
        ip_regex='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
    fi
    
    # Try each service
    for service_info in "${services[@]}"; do
        service_name=${service_info%%:*}
        service_cmd=${service_info#*:}
        
        ip=$(eval "$service_cmd" 2>/dev/null)
        
        # Validate IP format
        if [[ $ip =~ $ip_regex ]]; then
            if [[ -n "$verbose" ]]; then
                echo "IP found using $service_name: $ip" >&2
            fi
            echo "$ip"
            return 0
        fi
    done
    
    [[ -n "$verbose" ]] && echo "Failed to retrieve public IP address" >&2
    return 1
}

# Function to retrieve the local IP address (non-localhost)
# Usage: lanip [-6] [-i INTERFACE] [-a]
#   -6: Get IPv6 address instead of IPv4
#   -i: Specify network interface (e.g., eth0)
#   -a: Return all addresses instead of just the first one
lanip() {
    local ipv6 interface all_ips
    local result=""
    
    # Parse options
    while [[ "$1" == -* ]]; do
        case "$1" in
            -6) ipv6=1 ;;
            -i) interface="$2"; shift ;;
            -a) all_ips=1 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
        shift
    done
    
    # For IPv6 detection
    local ip_family="inet"
    local localhost_pattern="^127\."
    local ip_cmd_args=""
    
    if [[ -n "$ipv6" ]]; then
        ip_family="inet6"
        localhost_pattern="^::1"
    fi
    
    if [[ -n "$interface" ]]; then
        ip_cmd_args="dev $interface"
    fi
    
    # Method 1: Try 'ip' command (more modern Linux systems)
    if (( $+commands[ip] )); then
        if [[ -n "$all_ips" ]]; then
            result=$(ip -f $ip_family addr show $ip_cmd_args 2>/dev/null | awk -v pattern="$localhost_pattern" '$1 == "inet" || $1 == "inet6" {gsub(/\/.*$/, "", $2); if ($2 !~ pattern) print $2}')
        else
            result=$(ip -f $ip_family addr show $ip_cmd_args 2>/dev/null | awk -v pattern="$localhost_pattern" '$1 == "inet" || $1 == "inet6" {gsub(/\/.*$/, "", $2); if ($2 !~ pattern) {print $2; exit}}')
        fi
    # Method 2: Try 'ifconfig' (older systems)
    elif (( $+commands[ifconfig] )); then
        if [[ -n "$interface" ]]; then
            if [[ -n "$all_ips" ]]; then
                result=$(ifconfig "$interface" 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2}')
            else
                result=$(ifconfig "$interface" 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2; exit}')
            fi
        else
            if [[ -n "$all_ips" ]]; then
                result=$(ifconfig 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2}')
            else
                result=$(ifconfig 2>/dev/null | awk -v family="$ip_family" -v pattern="$localhost_pattern" '$1 == family && $2 !~ pattern {print $2; exit}')
            fi
        fi
    # Method 3: Try 'hostname' (fallback)
    elif (( $+commands[hostname] )); then
        if [[ -n "$ipv6" ]]; then
            # hostname doesn't easily distinguish IPv6 addresses
            result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9a-fA-F:]+$/ && $i !~ /^::1/) print $i}')
            if [[ -n "$all_ips" ]]; then
                # Just keep all IPv6 results
                :
            else
                # Take first result only
                result=$(echo "$result" | head -n 1)
            fi
        else
            if [[ -n "$all_ips" ]]; then
                result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i !~ /^127\./) print $i}')
            else
                result=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $i !~ /^127\./) {print $i; exit}}')
            fi
        fi
    fi
    
    # Return result or error
    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}