#!/usr/bin/env sh

set -euo pipefail

title(){
  echo -e "\e[1;36m<----- Ubuntu Debloating/Hardening Script ----->\e[0m"
}

check_network(){

  echo -e "\e[1;32m Checking Connectivity... ! \e[0m"

  wget -q --spider https://duckduckgo.com/

  if [ $? -eq  0 ]; then
    return
  else
    echo -e "\e[1;31m [x] Not Connected to internet ! \e[0m"
    echo -e "\e[1;31m [x] Please connect and try again ! \e[0m"
    exit 1
  fi

}

check_su(){

if [ $EUID -ne 0 ]; then
  echo -e "\e[1;31m [x] Please use "sudo" or run the script as a root user\e[0m"
  exit 1
fi

}

update(){
  echo -e "\e[1;32m Updating and Upgrading System Packages... \e[0m"
  apt update && apt upgrade -y
}

remove_snap(){

  echo -e "\e[1;32m Removing Snaps... \e[0m"
  for snap in $(snap list | awk 'NR > 1 && $1 !~ /^(core24|bare|core22|snapd)$/ {print $1}'); do
    sudo snap remove "$snap"
  done

  echo -e "\e[1;32m Removing Snap Daemon and disabling it services ... \e[0m"

  if systemctl cat snapd.service &>/dev/null; then
    sudo systemctl disable --now snapd.service
    sudo systemctl disable --now snapd.socket
  else
    return
  fi

  if command -v snapd &>/dev/null;
    apt remove snapd -y
    rm -rf ~/snap
    rm -rf /var/lib/snapd
    sudo find /etc -name "*snap*" -exec rm -rf {} \;
  else
    return
  fi

## This will prevent snapd from being installed by all repositories

tee /etc/apt/preferences.d/nosnap.pref << EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

}

remove_telemetry(){

  PRO=$(grep -o "LTS" /etc/os-release | uniq)
  echo -e "\e[1;32m Disabling telemetry services... \e[0m"

  if systemctl cat apport.service &>/dev/null; then
    systemctl disable --now apport.service
  else
    return
  fi

  if systemctl cat whoopsie.service &>/dev/null; then
    systemctl mask whoopsie.service
  else
    return
  fi

  if systemctl cat motd-news.timer &>/dev/null; then
    systemctl disable --now motd-news.timer
    systemctl mask motd-news.service
  else
    return
  fi

  echo -e "\e[1;32m Removing bloatware.. \e[0m"

  if command -v apport whoopsie ubuntu-report &>/dev/null; then
    apt purge -y apport whoopsie ubuntu-report
  else
    return
  fi

  if [ $PRO == "LTS" ]; then
    apt remove ubuntu-pro-client -y
  else
    return
  fi

}

# Added For users who prefer to use .deb instead

mozilla_repo(){

if [ ! -e /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-resolute.sources ]; then
  add-apt-repository ppa:mozillateam/ppa
else
  return
fi
# Giving A high priority for ppa so it never fallbacks to snapd

tee /etc/apt/preferences.d/mozillateamppa << EOF
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF

}

firewall(){
  echo -e "\e[1;32m Configuring firewall... \e[0m"

  if command -v ufw &>/dev/null; then
    apt install -y ufw
  else
    return
  fi

  ufw default deny incoming
  ufw default allow outgoing
  ufw allow ssh
  ufw enable
}

disable_ipv6(){
  echo -e "\e[1;32m Disabling IPv6... \e[0m"

  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1

  if [ -e /etc/sysctl.conf ]; then
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  else
    return
  fi
}

auditing(){
  echo -e "\e[1;32m Enabling process accounting... \e[0m"

  if command -v auditd &>/dev/null; then
    apt install -y auditd
  else
    return
  fi

  systemctl enable --now auditd
}

fail2ban(){
  echo -e "\e[1;32m Installing Fail2Ban... \e[0m"

  if command -v fail2ban &>/dev/null; then
    apt install -y fail2ban
  else
    return
  fi

  systemctl enable --now fail2ban
}

useless_services(){
  echo -e "\e[1;32m Disabling unnecessary services... \e[0m"
  systemctl disable --now cups.service
  systemctl disable cups-browsed.service
  systemctl disable avahi-daemon.service
  systemctl disable --now bluetooth.service
}



cleanup(){
  echo -e "\e[1;32m Cleaning up system... \e[0m"
  apt autoremove -y
  apt autoclean -y
  apt clean -y
}

main(){
  check_network
  check_su
  update
  remove_snap
  remove_telemetry
  mozilla_repo
  firewall
  disable_ipv6
  auditing
  fail2ban
  useless_services
  cleanup
}

main

echo -e "\e[1;32m Successfully Debloated Ubuntu! Ubuntu is great again ! Reboot your system using "reboot" !\e[0m"
