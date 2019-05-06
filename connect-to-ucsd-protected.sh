nmcli con down hotspot
nmcli con modify hotspot connection.autoconnect no
if [ -f "/etc/NetworkManager/system-connections/UCSD-PROTECTED" ]; then
    # nmcli con modify UCSD-PROTECTED ipv4.method auto wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "${2:-cogrob}" 802-1x.phase2-auth mschapv2  802-1x.password "${1-Atkhall6}"
    rm /etc/NetworkManager/system-connections/UCSD-PROTECTED
fi
nmcli con add type wifi con-name UCSD-PROTECTED ifname "${3:-wlp1s0}" ssid UCSD-PROTECTED -- ipv4.method auto  wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "${2:-cogrob}" 802-1x.phase2-auth mschapv2    802-1x.password "${1:-AtkHall6}"
nmcli con up UCSD-PROTECTED
