#!/bin/zsh
#
# Linux-specific functions

# Minimize login information
function minimize-login-info() {
    if [[ "$(osname)" == "ubuntu" ]]; then
        sudo chmod -x /etc/update-motd.d/00-header
        sudo chmod -x /etc/update-motd.d/10-help-text
        sudo chmod -x /etc/update-motd.d/50-motd-news
        #sudo chmod -x /etc/update-motd.d/90-updates-available
        sudo chmod -x /etc/update-motd.d/91-contract-ua-esm-status
    elif [[ "$(osname)" == "debian" ]]; then
        #sudo chmod -x /etc/update-motd.d/10-uname
        sudo cp /etc/motd /etc/motd.org
        sudo rm -f /etc/motd
        sudo touch /etc/motd
    fi
    if [[ ! "$(osname)" == "macos" ]]; then
        sudo ln -sf ~/GitHub/config/motd/05-header /etc/update-motd.d
    fi
}

# modify /etc/needrestart/needrestart.conf
# use: needrestart-mod parameter value
if [[ "$(osname)" != "macos" ]]; then
    function needrestart-mod() {
        filename=/etc/needrestart/needrestart.conf
        sudo sed -i "s/^#\?\s\?\$nrconf{$1}.*/\$nrconf{$1} = $2;/" $filename
    }
    function needrestart-quiet() {
        needrestart-mod verbosity 0
        needrestart-mod systemctl_combine 0
        needrestart-mod kernelhints 0
        needrestart-mod ucodehints 0
    }
    function needrestart-verbose() {
        needrestart-mod verbosity 1
        needrestart-mod systemctl_combine 1
        needrestart-mod kernelhints 1
        needrestart-mod ucodehints 1
    }
fi