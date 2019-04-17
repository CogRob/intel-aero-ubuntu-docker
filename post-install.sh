#!/bin/bash

aero-bios-update && reboot

jam -aprogram /etc/fpga/aero-rtf.jam

TTYID=ttyS$(grep mmio /proc/tty/driver/serial | grep CTS | cut -d: -f 1)
sed -i -e "s#/dev/ttyS1#/dev/S{TTYID}#" /usr/sbin/aerofc-update.sh
cd /etc/aerofc/px4/ \
  && aerofc-update.sh nuttx-aerofc-v1-default.px4

cd /etc/aerofc/ardupilot/ \
  && aerofc-update.sh arducopter-aerofc-v1.px4

sed -i -e "s#/dev/ttyS1#/dev/S{TTYID}#" /etc/mavlink-router/main.conf
sed -i -e "s#/tty/ttyS1#/tty/${TTYID}#" /lib/systemd/system/mavlink-routerd.service
echo 4 > /sys/class/tty/${TTYID}/rx_trig_bytes
/usr/bin/mavlink-routerd &> /var/log/mavlink-routerd.log 
#systemctl restart mavlink-router

/bin/bash

