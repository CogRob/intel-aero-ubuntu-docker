nmcli con down hotspot
nmcli con modify hotspot connection.autoconnect no
if [ -f "/etc/NetworkManager/system-connections/UCSD-PROTECTED" ]; then
    nmcli con modify UCSD-PROTECTED ipv4.method auto wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "${2:vdhiman}" 802-1x.phase2-auth mschapv2 802-1x.password "$1"
else
    nmcli con add type wifi con-name UCSD-PROTECTED ifname "${3:wlp1s0}" ssid UCSD-PROTECTED -- ipv4.method auto wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.identity "${2:vdhiman}" 802-1x.phase2-auth mschapv2 802-1x.password "$1"
fi
nmcli con up UCSD-PROTECTED
